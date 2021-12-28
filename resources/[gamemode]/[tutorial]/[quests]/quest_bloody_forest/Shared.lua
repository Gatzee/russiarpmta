QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Роман", voice_line = "Roman_bloody_forest_1", text = "Привет.\nДело простое.\nДавай прокатимся я все на месте тебе расскажу!" },		
		},
	},

	positions = {
		roman_spawn 	= { pos = Vector3( 565.74, -519.72, 21.75 ), rot = Vector3( 0, 0, 0 ) },
		roman_veh_spawn = { pos = Vector3( 553.47, -517.50, 20.62 ), rot = Vector3( 0, 0, 5 ) },

		forest_veh_parking = { pos = Vector3( 789.83, 748.9, 19.22 ), rot = Vector3( 0, 0, 268 ) },
		boat_veh_spawn = { pos = Vector3( 784.385, 1155.941, 0.532 ), rot = Vector3( 0, 0, 0 ) },

		quest_point = { pos = Vector3( 807.733, 977.962, 24.314 ) },

		shot_cutscene_player = { pos = Vector3( 807.733, 977.962, 24.314 ), rot = Vector3( 0, 0, 180 ) },
		shot_cutscene_roman = { pos = Vector3( 811.575, 969.658, 26.764 ), rot = Vector3( 0, 0, 9 ) },
		shot_cutscene_head_cartel = { pos = Vector3( 744.471, 914.906, 36.176 ), rot = Vector3( 0, 0, 313 ), skin_id = 262 },

		shot_cutscene_camera_1 = { 809.75201416016, 982.1909179687, 25.010890960693, 793.2077636718, 883.69445800781, 20.038021087646, 0, 70 },
		shot_cutscene_camera_2 = { 744.31512451172, 914.4185180664, 36.965965270996, 817.2177124023, 979.17352294922, 14.784698486328, 0, 70 },
		shot_cutscene_camera_3 = { 815.39416503906, 968.3935546875, 28.002155303955, 732.6210327148, 1016.066711425, -1.5931440591812, 0, 70 },

		escape = { pos = Vector3( 797.42, 1056.62, 17.94 ), },
		port = { pos = Vector3( 1122.26, 2072.39, 0 ), },

		finish = { pos = Vector3( 1116.218, 2074.171, 1.467 ), rot = Vector3( 0, 0, 258 ) },
	},

	quest_vehicle_id = 6539,
	quest_vehicle_id_2 = 453,
}

GEs = { }

QUEST_DATA = {
	id = "bloody_forest",
	is_company_quest = true,

	title = "Кровавый лес",
	description = "Не знаю, слишком просто все обошлось, надеюсь Роман не догадался.",

	CheckToStart = function( player )
		if player.interior ~= 0 or player.dimension ~= 0 then return end
		return true
	end,

	restart_position = Vector3( 556.4246, -496.3263, 20.9102 ),

	quests_request = { "possible_exposure" },
	level_request = 20,

	OnAnyFinish = {
		client = function()
			fadeCamera( true )
			ClearAIPed( localPlayer )
			toggleControl( "enter_exit", true )
		end,
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			DisableQuestEvacuation( player )
			
			ExitLocalDimension( player )
			triggerEvent( "onGameTimeRequest", player )
		end,
	},

	tasks = 
	{
		{
			name = "Встретиться с Романом",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateMarkerToCutsceneNPC( {
						id = "roman_near_house",
						dialog = QUEST_CONF.dialogs.start,
						radius = 1,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )

							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "roman_near_house" ).ped, nil, true )

							setTimerDialog( function()
								triggerServerEvent( "bloody_forest_step_1", localPlayer )
							end, 6300, 1 )
						end
					} )
				end,

				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, QUEST_CONF.quest_vehicle_id, positions.roman_veh_spawn.pos, positions.roman_veh_spawn.rot )
					vehicle:SetNumberPlate( "1:м421кр178" )
					vehicle:SetColor( 0, 0, 0 )
					
					player:SetPrivateData( "temp_vehicle", vehicle )
				end
			},

			CleanUp = {
				client = function( data, failed )
					StopPedTalk( FindQuestNPC( "roman_near_house" ).ped )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "bloody_forest_step_1",
		},

		{
			name = "Садись в машину",

			Setup = {
				client = function( )
					HideNPCs()
					setTime( 0, 0 )
					local positions = QUEST_CONF.positions

					local fake_npc_roman = FindQuestNPC( "roman_near_house" )
					GEs.roman_bot = CreateAIPed( fake_npc_roman.model, fake_npc_roman.position, fake_npc_roman.rotation )
					LocalizeQuestElement( GEs.roman_bot )
					SetUndamagable( GEs.roman_bot, true )
					setPedStat( GEs.roman_bot, 76, 1000 )
					setPedStat( GEs.roman_bot, 22, 1000 )

					GEs.follow_interface = CreateFollowInterface()
					GEs.follow_interface:follow( GEs.roman_bot )

					GEs.check_roman_dist = setTimer( function()
						local distance = (localPlayer.position - GEs.roman_bot.position).length
						if distance > 150 then
							FailCurrentQuest( "Ты оставил Романа одного!" )
						elseif distance > 50 then
							localPlayer:ShowError( "Вернись за Романом!" )
						end
					end, 2000, 0 )
					
					GEs.temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( GEs.temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 360 or self.element.inWater then
								FailCurrentQuest( "Машина Романа уничтожена" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Закончилось топливо!" )
								return true
							end
						end,
					} ) )

					GEs.check_roman_veh_tmr = setTimer( function()
						if isElementInWater( GEs.temp_vehicle ) then
							FailCurrentQuest( "Машина Романа уничтожена!" )
						end
					end, 2000, 0 )

					CreateQuestPoint( GEs.temp_vehicle.position, function( self, player )
						CEs.marker.destroy( )
					end, _, 5 )
					
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F чтобы сесть на водительское место",
						condition = function( )
							return isElement( GEs.temp_vehicle ) and ( localPlayer.position - GEs.temp_vehicle.position ).length <= 4
						end
					} )

					GEs.OnClientVehicleStartEnter_handler = function( player, seat )
						if (player == localPlayer and seat ~= 0) or GEs.blowed then
							cancelEvent( )
							localPlayer:ShowError( "Садись за руль" )
						elseif player == localPlayer and CEs.hint then
							CEs.hint:destroy()
							CEs.hint = nil
						end
					end
					addEventHandler( "onClientVehicleStartEnter", GEs.temp_vehicle, GEs.OnClientVehicleStartEnter_handler )

					CEs.OnClientVehicleEnter_handler = function( ped )
						if localPlayer.vehicle == GEs.temp_vehicle and GEs.roman_bot.vehicle == GEs.temp_vehicle then
							removeEventHandler( "onClientVehicleEnter", GEs.temp_vehicle, CEs.OnClientVehicleEnter_handler )
							triggerServerEvent( "bloody_forest_step_2", localPlayer )
						end
					end
					addEventHandler( "onClientVehicleEnter", GEs.temp_vehicle, CEs.OnClientVehicleEnter_handler )
				end,
				server = function( player )

				end,
			},

			event_end_name = "bloody_forest_step_2",
		},

		{
			name = "Прибыть на место",

			Setup = {
				client = function( )
					toggleControl( "enter_exit", false )
					GEs.follow_interface:stop_follow( GEs.roman_bot )

					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.forest_veh_parking.pos, function( self, player )
						CEs.marker.destroy( )
						triggerServerEvent( "bloody_forest_step_3", localPlayer )
					end, _, 5, _, _, function( self, player )
						if localPlayer.vehicle ~= GEs.temp_vehicle then
							return false, "А где машина Романа?"
						elseif GEs.roman_bot.vehicle ~= GEs.temp_vehicle then
							return false, "А где Роман?"
						end
						return true
					end )
				end,
				server = function( player )

				end,
			},

			event_end_name = "bloody_forest_step_3",
		},

		{
			name = "Следовать указаниям Романа",

			Setup = {
				client = function( )
					GEs.bg_sound = playSound( "sfx/bg_sound.ogg", true )
					GEs.bg_sound.volume = 0.4

					CreateAIPed( localPlayer )
					AddAIPedPatternInQueue( localPlayer, AI_PED_PATTERN_VEHICLE_EXIT, { 
						end_callback = {
							func = function()
								
							end,
							args = { },
						}
					} )
					AddAIPedPatternInQueue( GEs.roman_bot, AI_PED_PATTERN_VEHICLE_EXIT, {
						end_callback = {
							func = function( )
								GEs.follow_interface:follow( GEs.roman_bot )
							end,
							args = { },
						}
					} )

					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.quest_point.pos, function( self, player )
						CEs.marker.destroy( )
						GEs.follow_interface:stop_follow( GEs.roman_bot )

						local fade_time = 1
						fadeCamera( false, 1 )
						CEs.end_step_tmr = setTimer( triggerServerEvent, fade_time * 1000, 1, "bloody_forest_step_4", localPlayer )
					end, _, 2, _, _, function( self, player )
						if localPlayer.vehicle then
							return false, "Ты зачем на машине приехал?"
						end
						return true
					end )
				end,
				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, QUEST_CONF.quest_vehicle_id_2, positions.boat_veh_spawn.pos, positions.boat_veh_spawn.rot )					
					player:SetPrivateData( "temp_vehicle", vehicle )
				end,
			},

			event_end_name = "bloody_forest_step_4",
		},

		{
			name = "...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					if isTimer( GEs.check_roman_dist ) then killTimer( GEs.check_roman_dist ) end
					if isTimer( GEs.check_roman_veh_tmr ) then killTimer( GEs.check_roman_veh_tmr ) end
					if isElement( GEs.bg_sound ) then destroyElement( GEs.bg_sound ) end

					localPlayer.position = positions.shot_cutscene_player.pos
					localPlayer.rotation = positions.shot_cutscene_player.rot

					GEs.roman_bot.health = 1
					GEs.roman_bot.position = positions.shot_cutscene_roman.pos
					GEs.roman_bot.rotation = positions.shot_cutscene_roman.rot

					SetUndamagable( GEs.roman_bot, false )
					givePedWeapon( GEs.roman_bot, 24, 3000, true )
					setPedAimTarget( GEs.roman_bot, localPlayer.position )
					setPedControlState( GEs.roman_bot, "aim_weapon", true )

					setCameraMatrix( unpack( positions.shot_cutscene_camera_1 ) )
					StartQuestCutscene( { allowed_keys = { "lalt" } })
					
					CEs.func_start_anim = function()
						setPedAnimation( localPlayer, "ped", "handsup", -1, false, false, false, true, 0 )

						CEs.fade_camera_tmr = setTimer( fadeCamera, 2000, 1, false, 0.5 )
						CEs.start_cutscene_tmr = setTimer( CEs.func_start_cutscene, 2500, 1 )
					end

					CEs.func_start_cutscene = function()
						GEs.head_cartel = CreateAIPed( positions.shot_cutscene_head_cartel.skin_id, positions.shot_cutscene_head_cartel.pos, positions.shot_cutscene_head_cartel.rot.z )
						LocalizeQuestElement( GEs.head_cartel )
						SetUndamagable( GEs.head_cartel, true )
						setPedStat( GEs.head_cartel, 76, 1000 )
						setPedStat( GEs.head_cartel, 22, 1000 )
						givePedWeapon( GEs.head_cartel, 34, 3000, true )
						
						setPedAimTarget( GEs.head_cartel, GEs.roman_bot.position )
						setPedControlState( GEs.head_cartel, "aim_weapon", true )

						setCameraMatrix( unpack( positions.shot_cutscene_camera_2 ) )
						fadeCamera( true, 0.5 )

						CEs.start_fire_tmr = setTimer( function()
							setGameSpeed( 0.05 )
							setPedControlState( GEs.head_cartel, "fire", true )
							CEs.off_fire_tmr = setTimer( function()
								setGameSpeed( 1 )
								setPedControlState( GEs.head_cartel, "fire", false )

								local fade_time = 0.1
								fadeCamera( false, fade_time )
								CEs.change_camera_tmr = setTimer( function()
									setCameraMatrix( unpack( positions.shot_cutscene_camera_3 ) )
									fadeCamera( true, fade_time )
									CEs.end_step_tmr = setTimer( triggerServerEvent, 1000, 1, "bloody_forest_step_5", localPlayer )
								end, fade_time * 1000, 1 )

							end, 4000, 1 )
						end, 500, 1 )
					end

					CEs.element_press_key = ibInfoPressKey( {
						do_text = "Нажми",
						text = "чтобы поднять руки",
						key = "lalt",
						black_bg = 0x00000000,
						key_handler = CEs.func_start_anim,
					} )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function()
					localPlayer.frozen = false
					setGameSpeed( 1 )
					FinishQuestCutscene()
				end
			},

			event_end_name = "bloody_forest_step_5",
		},

		{
			name = "Сбеги от снайпера",

			Setup = {
				client = function( )
					toggleControl( "enter_exit", true )
					setPedControlState( GEs.head_cartel, "fire", true )
					setPedAnimation( localPlayer, nil, nil )

					GEs.fire_sniper_tmr = setTimer( function()
						setPedAimTarget( GEs.head_cartel, localPlayer.position + Vector3( math.random( -3, 3 ), math.random( -4, 4 ), 0 ) )
						if (localPlayer.position - GEs.head_cartel.position).length < 60 then
							localPlayer.health = localPlayer.health - 25
						end
					end, 1000, 0 )

					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.escape.pos, function( self, player )
						CEs.marker.destroy( )
						triggerServerEvent( "bloody_forest_step_6", localPlayer )
					end, _, 5 )
				end,
				server = function( player )

				end,
			},

			event_end_name = "bloody_forest_step_6",
		},

		{
			name = "Садись в лодку",

			Setup = {
				client = function( )
					if isTimer( GEs.fire_sniper_tmr ) then killTimer( GEs.fire_sniper_tmr ) end

					local positions = QUEST_CONF.positions

					GEs.temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( GEs.temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 360 then
								FailCurrentQuest( "Лодка уничтожена" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Закончилось топливо!" )
								return true
							end
						end,
					} ) )

					CreateQuestPoint( GEs.temp_vehicle.position, function( self, player )
						CEs.marker.destroy( )
					end, _, 5 )
					
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F чтобы сесть за штурвал",
						condition = function( )
							return isElement( GEs.temp_vehicle ) and ( localPlayer.position - GEs.temp_vehicle.position ).length <= 4
						end
					} )

					GEs.OnClientVehicleStartEnter_handler = function( player, seat )
						if (player == localPlayer and seat ~= 0) or GEs.blowed then
							cancelEvent( )
							localPlayer:ShowError( "Садись за руль" )
						elseif player == localPlayer and CEs.hint then
							CEs.hint:destroy()
							CEs.hint = nil
						end
					end
					addEventHandler( "onClientVehicleStartEnter", GEs.temp_vehicle, GEs.OnClientVehicleStartEnter_handler )

					CEs.OnClientVehicleEnter_handler = function( ped )
						if localPlayer.vehicle == GEs.temp_vehicle then
							removeEventHandler( "onClientVehicleEnter", GEs.temp_vehicle, CEs.OnClientVehicleEnter_handler )
							triggerServerEvent( "bloody_forest_step_7", localPlayer )
						end
					end
					addEventHandler( "onClientVehicleEnter", GEs.temp_vehicle, CEs.OnClientVehicleEnter_handler )
				end,
				server = function( player )

				end,
			},

			event_end_name = "bloody_forest_step_7",
		},

		{
			name = "Отправляйся в порт",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.port.pos, function( self, player )
						CEs.marker.destroy( )
						local fade_time = 1
						fadeCamera( false, fade_time )
						CEs.end_step_tmr = setTimer( function()
							AddAIPedPatternInQueue( localPlayer, AI_PED_PATTERN_VEHICLE_EXIT, {
								end_callback = {
									func = function( )
										localPlayer.position = positions.finish.pos
										localPlayer.rotation = positions.finish.rot
										fadeCamera( true, fade_time )
										triggerServerEvent( "bloody_forest_step_8", localPlayer )
									end,
									args = { },
								}
							} )
						end, fade_time * 1000, 1 )
					end, _, 15, _, _, function( self, player )
						if localPlayer.vehicle ~= GEs.temp_vehicle then
							return false, "А где лодка?"
						end
						return true
					end, nil, nil, nil, nil, nil, nil, nil, true )
				end,
				server = function( player )

				end,
			},

			event_end_name = "bloody_forest_step_8",
		},
	},

	GiveReward = function( player )
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, 
		{
			rewards = { money = QUEST_DATA.rewards.money, exp = QUEST_DATA.rewards.exp }
		} )

		player:SituationalPhoneNotification(
			{ title = "Александр", msg = "Ну ты и мразь! Я к тебе всей душой, а ты...Жду тебя на своей Вилле и посмотрим кто кого!" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "long_awaited_revenge" then
						return "cancel"
					end

					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)
	end,

	rewards = {
		money = 7500,
		exp = 8000,
	},

	no_show_rewards = true,
}