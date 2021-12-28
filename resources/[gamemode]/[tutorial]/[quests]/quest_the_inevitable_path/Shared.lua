QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Александр", voice_line = "Alexander_the_inevitable_path_01", text = "Привет. Как тебе Яхта?\nПо глазам вижу, что понравилась." },
			{ name = "Александр", text = "Давай за штурвал, нужно Романа забрать.\nУ него есть хорошие новости!" },
		},
		finish = {
			{ name = "Роман", voice_line = "Roman_the_inevitable_path_01", text = "Думаю мы нашли одного из грабителей.\nЭто некая Ксюша. Дочь главы западного картеля." },
			{ name = "Роман", text = "И я точно знаю где она будет, но там опасно!\nНадо подготовиться.\nЯ тебе сообщу как, буду готов." },
		},
	},

	positions = {
		port_start = { pos = Vector3( 882.7315, -296.3685, 2.1735 ), rot = Vector3( 0, 0, 0 ) },
		yacht_spawn = { pos = Vector3( 936.8310, -294.2126, -0.938 ), rot = Vector3( 0, 0, 249 ) },

		start_talk_alexander = { pos = Vector3( 941.615, -295.426, 1.3999 ), rot = Vector3( 0, 0, 178 ) },
		start_talk_player 	 = { pos = Vector3( 941.334, -296.718, 1.1999 ), rot = Vector3( 0, 0, 345 ) },
		start_talk_matrix 	 = { 941.81414794922, -297.73733520508, 1.9081435203552, 931.20709228516, -200.92387390137, -18.777629852295, 0, 70 },

		roman_sleep = { pos = Vector3( 946.8120, -298.3320, 2.55 ), rot = Vector3( 0, 0, 87 ) },

		roman_spawn = { pos = Vector3( -398.2603, 114.6867, 2.1735 ), rot = Vector3( 0, 0, 180 ) },
		roman_take  = { pos = Vector3( -388.16, 105.33, 0 ), rot = Vector3( 0, 0, 0 ) },
		
		port_parking = { pos = Vector3( -141.67, -358.76, 0 ), rot = Vector3( 0, 0, 0 ) },

		finish_talk_alexander = { pos = Vector3( -113.9613, -375.3678, 1.66 ), rot = Vector3( 0, 0, 180 ) },
		finish_talk_player    = { pos = Vector3( -113.118, -375.736, 1.66 ), rot = Vector3( 0, 0, 145 ) },
		finish_talk_roman     = { pos = Vector3( -113.5613, -376.3678, 1.66  ), rot = Vector3( 0, 0, 340 ) },
		finish_talk_yacht     = { pos = Vector3( -122.448, -374.185, -0.938 ), rot = Vector3( 0, 0, 78 ) },
		finish_talk_matrix    = { -112.98433685303, -374.41036987305, 2.4998853492737, -145.2494354248, -465.91604614258, -9.730875015259, 0, 70 },

		player_finish_position = { pos = Vector3( -112.11, -384.13, 2.17 ), rot = Vector3( 0, 0, 50 ) },
		finish_route = {
			{ x = -231, y = -348, z = 0, speed_limit = 5 },
		},
		finish_matrix    = { -102.05191802979, -392.66091918945, 6.101574420929, -167.29975891113, -318.88543701172, -11.215986251831, 0, 70 },

		return_position = { pos = Vector3( 880.1228, -305.1774, 2.1735 ), rot = Vector3( 0, 0, 270 ) },
	},

	quest_vehicle_id = 453,
}

GEs = { }

QUEST_DATA = {
	id = "the_inevitable_path",
	is_company_quest = true,

	title = "Неизбежный путь",
	description = "Судя по всему, Александр продвинулся в расследовании. Нужно все выяснить!",

	CheckToStart = function( player )
		if player.interior ~= 0 or player.dimension ~= 0 then return end
		return true
	end,

	restart_position = Vector3( 776.3005, -297.8716, 20.7002 ),

	quests_request = { "crazy_vacation" },
	level_request = 20,

	OnAnyFinish = {
		client = function()
			fadeCamera( true, 1 )
		end,
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			DisableQuestEvacuation( player )
			
			if player.dimension == player:GetUniqueDimension() then
				if player.interior ~= 0 then
					player.interior = 0
				end
				if not player:getData( "succes_quest_the_inevitable_path" ) then
					player.position = QUEST_CONF.positions.return_position.pos
					player.rotation = QUEST_CONF.positions.return_position.rot
				end
				player:setData( "succes_quest_the_inevitable_path", false, false )
				ExitLocalDimension( player )
			end
		end,
	},

	tasks = {

		{
			name = "Отправляйся на встречу",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.port_start.pos, function( self, player )
						CEs.marker.destroy( )

						local fade_time = 1
						fadeCamera( false, fade_time )
						CEs.end_tmr = setTimer( function()
							EnterLocalDimension()
							triggerServerEvent( "the_inevitable_path_step_1", localPlayer )
						end, fade_time * 1000, 1 ) 
					end, _, 1 )
				end,

				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, QUEST_CONF.quest_vehicle_id, positions.yacht_spawn.pos, positions.yacht_spawn.rot )
					vehicle.frozen = true				
					player:SetPrivateData( "temp_vehicle", vehicle )
				end
			},

			event_end_name = "the_inevitable_path_step_1",
		},

		{
			name = "...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					localPlayer.position = positions.start_talk_player.pos
					localPlayer.rotation = positions.start_talk_player.rot

					GEs.alexander_bot = CreateAIPed( FindQuestNPC( "alexander" ).model, positions.start_talk_alexander.pos, positions.start_talk_alexander.rot.z )
					LocalizeQuestElement( GEs.alexander_bot )
					SetUndamagable( GEs.alexander_bot, true )
										
					setCameraMatrix( unpack( positions.start_talk_matrix ) )
					
					CEs.start_scene_tmr = setTimer( function()
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.start } )
						StartPedTalk( GEs.alexander_bot, nil, true )
						CEs.dialog:next( )
						
						setTimerDialog( function()
							CEs.dialog:next( )
							setTimerDialog( function()
								StopPedTalk( GEs.alexander_bot )
								triggerServerEvent( "the_inevitable_path_step_2", localPlayer )
							end, 5600 )
						end, 4000, 1 )
					end, 200, 1 )
				end,

				server = function( player )
					EnableQuestEvacuation( player )
					local vehicles = EnterLocalDimensionForVehicles( player )

					local current_vehicle = player.vehicle
					if not vehicles or not current_vehicle or not vehicles[ current_vehicle ] then
						removePedFromVehicle( player )
					end
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "the_inevitable_path_step_2",
		},

		{
			name = "Садись за штурвал яхты",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					attachElements( GEs.alexander_bot, temp_vehicle, -0.3, 5, 2.03, 0, 0, 0 )
					setPedAnimation( GEs.alexander_bot, "playidles", "time" )
					
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 360 then
								FailCurrentQuest( "Яхта уничтожена" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Закончилось топливо!" )
								return true
							end
						end,
					} ) )


					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F чтобы сесть за штурвал",
						condition = function( )
							return not localPlayer.vehicle and isElement( temp_vehicle ) and ( localPlayer.position - temp_vehicle.position ).length <= 4
						end
					} )

					GEs.OnEnterYacht = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						triggerServerEvent( "the_inevitable_path_step_3", localPlayer )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.OnEnterYacht )
				end,

				server = function( player )
				end
			},

			CleanUp = {
				client = function( )
					removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.OnEnterYacht )
				end,
			},

			event_end_name = "the_inevitable_path_step_3",
		},

		{
			name = "Забери Романа",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					GEs.roman_bot = CreateAIPed( FindQuestNPC( "roman_in_house" ).model, positions.roman_spawn.pos, positions.roman_spawn.rot.z )
					LocalizeQuestElement( GEs.roman_bot )
					SetUndamagable( GEs.roman_bot, true )

					CreateQuestPoint( positions.roman_take.pos, function( self, player )
						CEs.marker.destroy( )

						local fade_time = 1
						fadeCamera( false, fade_time )
						CEs.end_tmr = setTimer( function()
							triggerServerEvent( "the_inevitable_path_step_4", localPlayer )
						end, fade_time * 1000, 1 ) 
					end, _, 10, _, _, function( self, player )
						if localPlayer.vehicle ~= temp_vehicle then
							return false, "А где яхта?"
						end
						return true
					end, nil, nil, nil, nil, nil, nil, nil, true )
				end,

				server = function( player )
				end
			},

			event_end_name = "the_inevitable_path_step_4",
		},

		{
			name = "Отправляйся в порт",

			Setup = {
				client = function( )
					fadeCamera( true, 1 )

					local positions = QUEST_CONF.positions
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					attachElements( GEs.roman_bot, temp_vehicle, -1, 5.5, 2.03, 0, 110, 0 )

					CreateQuestPoint( positions.port_parking.pos, function( self, player )
						CEs.marker.destroy( )

						local fade_time = 2
						fadeCamera( false, fade_time )
						CEs.end_tmr = setTimer( function()
							for k, v in pairs( { localPlayer, GEs.alexander_bot, GEs.roman_bot } ) do
								v.frozen = true
							end
							triggerServerEvent( "the_inevitable_path_step_5", localPlayer )
						end, fade_time * 1000, 1 ) 
					end, _, 10, _, _, function( self, player )
						if localPlayer.vehicle ~= temp_vehicle then
							return false, "А где яхта?"
						end
						return true
					end, nil, nil, nil, nil, nil, nil, nil, true )
				end,

				server = function( player )
				end
			},

			CleanUp = {
				server = function( player )
					DestroyAllTemporaryVehicles( player )
				end,
			},

			event_end_name = "the_inevitable_path_step_5",
		},

		{
			name = "...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CEs.fake_boat = createVehicle( QUEST_CONF.quest_vehicle_id, positions.finish_talk_yacht.pos, positions.finish_talk_yacht.rot )
					LocalizeQuestElement( CEs.fake_boat )				
					CEs.fake_boat.frozen = true

					CEs.set_position_tmr = setTimer( function()
						localPlayer.position = positions.finish_talk_player.pos
						localPlayer.rotation = positions.finish_talk_player.rot
						
						GEs.alexander_bot.position = positions.finish_talk_alexander.pos
						GEs.alexander_bot.rotation = positions.finish_talk_alexander.rot
						
						GEs.roman_bot.position = positions.finish_talk_roman.pos
						GEs.roman_bot.rotation = positions.finish_talk_roman.rot

						for k, v in pairs( { localPlayer, GEs.alexander_bot, GEs.roman_bot } ) do
							v.frozen = false
						end

						setCameraMatrix( unpack( positions.finish_talk_matrix ) )
					end, 300, 1 )

					CEs.start_scene_tmr = setTimer( function()
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.finish } )
						StartPedTalk( GEs.roman_bot, nil, true )
						CEs.dialog:next( )

						setTimerDialog( function()
							CEs.dialog:next( )
							setTimerDialog( function()
								if CEs.dialog then CEs.dialog:destroy() end
	
								local fade_time = 1
								fadeCamera( false, fade_time )
								CEs.start_cutscene_tmr = setTimer( function()
									CEs.fake_boat.frozen = false
	
									localPlayer.position = positions.player_finish_position.pos
									localPlayer.rotation = positions.player_finish_position.rot
	
									attachElements( GEs.roman_bot, CEs.fake_boat, -1, 5.5, 2.03, 0, 110, 0 )
	
									warpPedIntoVehicle( GEs.alexander_bot, CEs.fake_boat )
									SetAIPedMoveByRoute( GEs.alexander_bot, positions.finish_route, false, function( ) end )
	
									setCameraMatrix( unpack( positions.finish_matrix ) )
									fadeCamera( true, fade_time )
	
									CEs.fade_tmr = setTimer( function()
										local fade_time = 3
										fadeCamera( false, fade_time )
										CEs.end_tmr = setTimer( function()
											triggerServerEvent( "the_inevitable_path_step_6", localPlayer )
										end, fade_time * 1000, 1 )
									end, 3000, 1 )
								end, 1000, 1 ) 
	
							end, 7600 )
						end, 6000, 1 )
					end, 400, 1 )
				end,

				server = function( player )
					player:setData( "succes_quest_the_inevitable_path", true, false )
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "the_inevitable_path_step_6",
		},
	},

	GiveReward = function( player )
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, 
		{
			rewards = { money = QUEST_DATA.rewards.money, exp = QUEST_DATA.rewards.exp }
		} )

		player:SituationalPhoneNotification(
			{ title = "Роман", msg = "Привет. Я собрал все необходимое. Приезжай!" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "possible_exposure" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)
	end,

	rewards = {
		money = 6500,
		exp = 6500,
	},

	no_show_rewards = true,
}