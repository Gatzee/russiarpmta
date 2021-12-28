QUEST_CONF = {
	dialogs = {
		main = {
			{ name = "Олег", voice_line = "Oleg_1", text = "Приветствую, как ты? Хотя знаешь, потом расскажешь.\nУ меня тут подработка есть, надо пару грузов развести.\nПодсобишь? За мной не заржавеет." },
		},
		finish = {
			{ name = "Олег", voice_line = "Oleg_2", text = "Благодарю тебя, честная работа, честная награда!" },
		},
	},

	positions = {
		courier_marker = Vector3( 2057.505, -638.497 + 860, 60.713 ),

		courier_marker_1 = Vector3( 2224.762, -883.585 + 860, 60.400 ),
		courier_marker_2 = Vector3( 1996.521, -963.993 + 860, 60.680 ),

		stand_position = Vector3( 1993.114, -963.391 + 860, 60.673 ),
		stand_rotation = Vector3( 0, 0, 219 ),

		bot_path_1 = {
			{ x = 1996.009, y = -972.856 + 860, z = 60.680 },
			{ x = 1993.114, y = -963.391 + 860, z = 60.673 },
		},

		bot_path_2 = {
			{ x = 1981.095, y = -939.779 + 860, z = 60.680, distance = 1 },
			{ x = 1982.083, y = -919.993 + 860, z = 60.680, distance = 1 },
			{ x = 1990.628, y = -910.757 + 860, z = 60.637, distance = 1 },
		},

		after_cutscene_position = Vector3( 1989.847, -959.094 + 860, 60.680 ),
		after_cutscene_rotation = Vector3( 0, 0, 17 ),
	}
}

QUEST_DATA = {
	id = "oleg_courier",
	is_company_quest = true,

	title = "Помощь курьером",
	description = "Олег в былые времена мне сильно помог. А сейчас сильно нужны деньги. Надо с ним встретиться и узнать какая подработка.",
	--replay_timeout = 5;

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 1897.0811, -791.2454 + 860, 60.7066 ),

	-- Любой из двух квестов
	quests_request = { { "alexander_get_vehicle_bike", "alexander_get_vehicle", "tutorial_1" } },
	level_request = 2,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			local vehicles_parked = ExitLocalDimension( player )
			if vehicles_parked then
				player:PhoneNotification( { title = "Эвакуация", msg = "Тебе доступна бесплатная эвакуация использованного в квесте транспорта!" } )
			end
			DisableQuestEvacuation( player )
		end,
		client = function( )
			ShowNPCs( )
			localPlayer:setData( "hud_counter", false, false )
		end,
	},

	tasks = {
		{
			name = "Поговорить с Олегом",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "oleg",
						dialog = QUEST_CONF.dialogs.main,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "oleg" ).ped, nil, true )

							setTimerDialog( function( )
								triggerServerEvent( "oleg_courier_step_1", localPlayer )
							end, 9000, 1 )
						end
					} )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "oleg" ).ped )
				end,
			},

			event_end_name = "oleg_courier_step_1",
		},

		{
			name = "Начать смену курьером",

			Setup = {
				client = function( )
					localPlayer:ShowInfo( "Начни смену на работе курьера" )
					
					CreateQuestPoint( QUEST_CONF.positions.courier_marker, function( self, player )
						CEs.marker.destroy( )

						ShowJobUI( true )
					end,
					_, _, _, localPlayer:GetUniqueDimension( ),
					function( )
						if localPlayer.vehicle then
							return false, "Выйди из транспорта"
						end
						return true
					end )
				end,

				server = function( player )
					EnableQuestEvacuation( player )
					local vehicles = EnterLocalDimensionForVehicles( player )

					local current_vehicle = player.vehicle
					if not vehicles or not current_vehicle or not vehicles[ current_vehicle ] then
						removePedFromVehicle( player )
					end

					if vehicles then
						for k, v in pairs( vehicles ) do
							if k.model == 468 then
								k.rotation = Vector3( 0, 0, 310 )
								break
							end
						end
					end
				end,
			},

			event_end_name = "oleg_courier_step_2",
		},

		{
			name = "Доставить первую посылку",

			Setup = {
				client = function( )
					localPlayer:setData( "hud_counter", { left = "Доставлено посылок", right = "0/2" }, false )
					CreateQuestPoint( QUEST_CONF.positions.courier_marker_1, function( self, player )
						CEs.marker.destroy( )
						localPlayer:ShowInfo( "Посылка доставлена" )
						triggerServerEvent( "oleg_courier_step_3", localPlayer )
					end,
					_, _, _, _,
					function( )
						if localPlayer.vehicle then
							return false, "Выйди из транспорта"
						end
						return true
					end )
				end,
			},

			event_end_name = "oleg_courier_step_3",
		},

		{
			name = "Доставить вторую посылку",

			Setup = {
				client = function( )
					localPlayer:setData( "hud_counter", { left = "Доставлено посылок", right = "1/2" }, false )
					CreateQuestPoint( QUEST_CONF.positions.courier_marker_2, function( self, player )
						CEs.marker.destroy( )
						localPlayer:ShowInfo( "Посылка доставлена" )
						triggerServerEvent( "oleg_courier_step_4", localPlayer )
					end,
					_, _, _, _,
					function( )
						if localPlayer.vehicle then
							return false, "Выйди из транспорта"
						end
						return true
					end )
				end,
			},

			event_end_name = "oleg_courier_step_4",
		},

		{
			name = "Отдай посылку",

			Setup = {
				client = function( )
					StartQuestCutscene( )

					localPlayer.health = math.max( 50, localPlayer.health )
					local vehicles_hidden = { }
					for i, v in pairs( getElementsByType( "vehicle", root, true ) ) do
						table.insert( vehicles_hidden, v )
						v.alpha = 0
					end
					--setTimer( setPedAnimation, 50, 1, localPlayer, "bomber", "bom_plant_loop", 2000, true, false )

					local from = { 1996.5689697266, -967.37887573242 + 860, 60.093742370605, 1924.7703857422, -897.87971496582 + 860, 63.943897247314, 0, 70 }
					local to = { 1997.7962646484, -965.15365600586 + 860, 60.093742370605, 1898.8435058594, -952.522636413574 + 860, 67.080123901367, 0, 70 }
					local movement = CameraFromTo( from, to, 10000, "InOutQuad", function( )
						for i, v in pairs( vehicles_hidden ) do
							if isElement( v ) then
								v.alpha = 255
							end
						end
					end )

					localPlayer.position = QUEST_CONF.positions.stand_position
					localPlayer.rotation = QUEST_CONF.positions.stand_rotation
					--removePedTask( localPlayer )

					local init_pos = QUEST_CONF.positions.bot_path_1[ 1 ]

					CEs.bot = CreateAIPed( 14, Vector3( init_pos.x, init_pos.y, init_pos.z ) )
					LocalizeQuestElement( CEs.bot )

					SetAIPedMoveByRoute( CEs.bot, QUEST_CONF.positions.bot_path_1, false, function( )
						iprint( "Finished first movement" )
						setPedControlState( CEs.bot, "fire", true )
						setTimer( setPedControlState, 50, 1, CEs.bot, "fire", true )

						CEs.anim_timer = setTimer( function( )

							CEs.timer_camera = setTimer( function( )
								if movement then movement:destroy( ) end
								local to = { 1969.6424560547, -937.615653991699 + 860, 61.086971282959, 2019.1173095703, -851.2872037887573 + 860, 61.448078155518, 0, 70 }
								CameraFromTo( _, to, 13000, "InOutQuad", function( )
									iprint( "Finished camera" )
									triggerServerEvent( "oleg_courier_step_5", localPlayer )
								end )

								setPedAnimation( CEs.bot, nil, nil )
								SetAIPedMoveByRoute( CEs.bot, QUEST_CONF.positions.bot_path_2, false, function( ) iprint( "Done" ) end )
							end, 1500, 1 )
						end, 500, 1 )
					end )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "oleg_courier_step_5",
		},

		{
			name = "Отнять свою посылку",

			Setup = {
				client = function( )
					localPlayer.position = QUEST_CONF.positions.after_cutscene_position
					localPlayer.position = QUEST_CONF.positions.after_cutscene_position

					local init_pos = QUEST_CONF.positions.bot_path_2[ #QUEST_CONF.positions.bot_path_2 ]
					local init_pos_vec = Vector3( init_pos.x, init_pos.y, init_pos.z )
					GEs.bot = createPed( 14, init_pos_vec )
					LocalizeQuestElement( GEs.bot )
					GEs.bot.rotation = Vector3( 0, 0, 90 )
					GEs.bot.health = 30

					CreateQuestPoint( init_pos_vec, function( self, player )
						CEs.marker.destroy( )

						CEs.hint = CreateSutiationalHint( {
							text = "Используй key=ЛКМ чтобы драться",
							condition = function( )
								return ( localPlayer.position - GEs.bot.position ).length <= 10
							end,
						} )

						local current_ctr = 0
						CEs.timer = setTimer( function( )
							if isPedDead( GEs.bot ) then
								triggerServerEvent( "oleg_courier_step_6", localPlayer )
								return
							end

							GEs.bot.rotation = Vector3( 0, 0, math.deg( math.atan2( localPlayer.position.y - GEs.bot.position.y, localPlayer.position.x - GEs.bot.position.x ) ) - 90 )
							
							current_ctr = current_ctr + 1

							if current_ctr >= 0 and current_ctr < 4 then
								setPedControlState( GEs.bot, "fire", not getPedControlState( GEs.bot, "fire" ) )
							elseif current_ctr >= 8 then
								current_ctr = 0
							end
						end, 250, 0 )
					end )
				end,
			},

			event_end_name = "oleg_courier_step_6",
		},

		{
			name = "Забрать посылку",

			Setup = {
				client = function( )
					CEs.timer = setTimer( function( )
						local added_handler = false
						CreateQuestPoint( GEs.bot.position, function( self, player )
							if added_handler then return end
							added_handler = true

							local function IsNearBot( )
								return ( localPlayer.position - GEs.bot.position ).length <= 2
							end
							CEs.hint = CreateSutiationalHint( {
								text = "Нажми key=Alt чтобы забрать посылку",
								condition = IsNearBot,
							} )

							local t = { }
							t.OnAlt = function( )
								if not IsNearBot( ) then return end
								CEs.hint:destroy_with_animation( )
								setPedAnimation( localPlayer, "bomber", "bom_plant", 1000, true, false, false, false )

								unbindKey( "lalt", "down", t.OnAlt )
								triggerServerEvent( "oleg_courier_step_7", localPlayer )
							end
							bindKey( "lalt", "down", t.OnAlt )
						end, _, 1, _, _ )
					end, 1000, 1 )
				end,
			},

			event_end_name = "oleg_courier_step_7",
		},

		{
			name = "Поговорить с Олегом",

			Setup = {
				client = function( )
					localPlayer:setData( "hud_counter", { left = "Доставлено посылок", right = "2/2" }, false )
					CreateMarkerToCutsceneNPC( {
						id = "oleg",
						dialog = QUEST_CONF.dialogs.finish,
						local_dimension = true,
						callback = function( )
							CEs.marker.destroy( )
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "oleg" ).ped, nil, true )

							setTimerDialog( function( )

								setTimer( function( )
									CreateEvacuationHint()
								end, 12000, 1 )

								triggerServerEvent( "oleg_courier_step_8", localPlayer )
							end, 5000, 1 )
						end
					} )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "oleg" ).ped )
				end,
			},

			event_end_name = "oleg_courier_step_8",
		},
	},

	GiveReward = function( player )
		player:InventoryAddItem( IN_CANISTER, nil, 1 )
		player:SituationalPhoneNotification(
			{ title = "Неизвестный номер", msg = "Привет это Анжела, мне твой номер Олег передал. Давай встретимся, по прошлой памяти. Открыть журнал квестов F2" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "angela_cinema" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				money = 1200,
				exp = 1500,
				canister = 1,
			}
		} )
	end,

	rewards = {
		money = 1200,
		exp = 1500,
		canister = 1,
	},
	
	no_show_rewards = true,
}