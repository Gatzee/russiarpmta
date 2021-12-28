QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Барыга", voice_line = "Huckster_long_awaited_revenge_1", text = "Здраво. Спасибо еще раз за защиту. Красиво вы их тогда!" },
			{ name = "Барыга", text = "У меня сейчас новая поставка вооружения.\nЗабирай!" },
			{ name = "Барыга", text = "Главное — не забудь рассказать как испытаешь его!" },		
		},
		finish = {
			{ name = "Александр", voice_line = "Alexander_long_awaited_revenge_1", text = "Я ведь все сделал, кхе. Чтобы уложить тебя в гроб. Но ты..." },
			{ name = "Александр", text = "Кхе Не понимаю как можно было,\nкхе не сломаться!" },
			{ name = "Александр", text = "Чего ты, су.., ждешь! Кхе! Стреляй!!!" },		
		},
	},

	positions = {
		village_start = { pos = Vector3( 1287.316, -850.429, 14.916 ), rot = Vector3( 0, 0, 356 ) },

		enemy = {
			{ pos = Vector3( 1265.56, -738.47, 15.2 ), rot = Vector3( 0, 0, 270 ), skin_id = 26 },
			{ pos = Vector3( 1311.71, -787.56, 15.2 ), rot = Vector3( 0, 0, 90 ),  skin_id = 26 },
			{ pos = Vector3( 1312.67, -756.31, 15.2 ), rot = Vector3( 0, 0, 0 ),   skin_id = 26 },
			{ pos = Vector3( 1300.39, -726.67, 15.2 ), rot = Vector3( 0, 0, 270 ), skin_id = 26 },
			{ pos = Vector3( 1317.98, -739.14, 15.2 ), rot = Vector3( 0, 0, 90 ),  skin_id = 26 },
			{ pos = Vector3( 1309.97, -720.42, 19.2 ), rot = Vector3( 0, 0, 180 ), skin_id = 26 },
			{ pos = Vector3( 1318.37, -737.05, 19.2 ), rot = Vector3( 0, 0, 90 ),  skin_id = 26 },
			{ pos = Vector3( 1310.85, -753.44, 19.2 ), rot = Vector3( 0, 0, 307 ), skin_id = 26 },
		},

		static_vehs = {	
			{ pos = Vector3( 1300.21, -807.43, 13.97 ), rot = Vector3( 0, 0, 269 ), vehicle_id = 551 },
			{ pos = Vector3( 1279.71, -767.61, 13.97 ), rot = Vector3( 0, 0, 48 ), vehicle_id = 551 },
			{ pos = Vector3( 1274.99, -745.56, 13.97 ), rot = Vector3( 0, 0, 48 ), vehicle_id = 551 },
			{ pos = Vector3( 443.55, -1155.50, 21.2 ), rot = Vector3( 0, 90, 240 ), vehicle_id = 515, frozen = true },
		},

		player_veh_spawn = { pos = Vector3( 1300.36, -764.71, 13.97 ), rot = Vector3( 0, 0, 95 ), vehicle_id = 551 },
		alexander_vehicle = { pos = Vector3( 1319.31, -715.65, 14.45 ), rot = Vector3( 0, 0, 90 ), vehicle_id = 6535 },

		alexander_run_path = {
			{ x = 1284.8378906250, y = -716.90295410156, z = 14.349987030029, speed_limit = 20 },
			{ x = 1280.6573486328, y = -722.56695556641, z = 14.348968505859, speed_limit = 20 },
			{ x = 1280.6381835938, y = -735.00585937502, z = 14.349711418152, speed_limit = 20 },
			{ x = 1291.0312500001, y = -796.85980224609, z = 14.348752975464, speed_limit = 20 },
			{ x = 1291.7998046875, y = -846.11547851563, z = 14.294621467591, speed_limit = 20 },
			{ x = 1300.2756347656, y = -893.65075683594, z = 14.290912628174, speed_limit = 20 },
		},

		alexander_run_camera_1 = Vector3( 1263.2163085938, -716.80346679688, 24.700654983521 ),
		alexander_run_camera_2 = Vector3( 1327.8494873047, -807.16204833984, 25.288047790527 ),

		path_of_pursuit = {
			Vector3( 1291.0740, -835.48236, 14.3489 ),
			Vector3( 667.52673, -1121.4576, 19.3436 ),
		},

		alexander_veh_start_crush = { pos = Vector3( 548.1057, -1213.1779, 20.4218 ), rot = Vector3( 0, 0, 103 ) },
		alexander_crush_path = {
			{ x = 487.92172241211, y = -1212.3520507813, z = 20.045721054077, speed_limit = 150 },
			{ x = 462.13449096682, y = -1211.5760498047, z = 19.972494125366, speed_limit = 200 },
			{ x = 437.80862426758, y = -1180.7624511719, z = 20.845344543457, speed_limit = 200 },
			{ x = 429.67633056641, y = -1148.9282226563, z = 17.728057861328, speed_limit = 200 },
			{ x = 424.22967529297, y = -1113.0837402344, z = 6.0806274414063, speed_limit = 200 },
		},

		alexander_crush_camera_1 = Vector3( 437.9790, -1238.4534, 32.3724 ),
		alexander_crush_camera_2 = Vector3( 462.94671630859, -1201.4803466797, 26.017549514771 ),

		finish_veh_parking = { pos = Vector3( 424.76083374023, -1129.4338378906, 18.608478546143 ), },

		player_finish = { pos = Vector3( 425.50, -1092.80, 7.68 ), rot = Vector3( 0, 0, 276 ) },
		alexander_finish = { pos = Vector3( 427.07, -1092.78, 8.13 ), rot = Vector3( 0, 0, 45 ) },
		alexander_finish_matrix = { 427.39547729492, -1092.3663330078, 7.5068879127502, 338.33264160156, -1133.1721191406, 27.574279785156, 0, 70 },
		alexander_finish_matrix_2 = { 431.61566162109, -1094.5573730469, 10.494704246521, 344.03128051758, -1073.7679443359, -33.057250976563, 0, 70 },

		finish_positions = {
			{ pos = Vector3( 653.49, 1892.45, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 654.95, 1891.77, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 656.81, 1891.01, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 658.09, 1890.32, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 659.37, 1889.91, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 660.75, 1889.39, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 661.88, 1888.83, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 660.91, 1887.11, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 659.14, 1887.79, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 657.89, 1888.36, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 656.49, 1888.97, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 655.25, 1889.51, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 653.65, 1890.21, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 653.13, 1888.42, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 653.73, 1888.02, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 654.89, 1887.61, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 656.02, 1887.12, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 657.56, 1886.42, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 658.89, 1885.87, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 657.91, 1884.72, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 656.47, 1885.21, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 655.01, 1885.78, 24.1 ), rot = Vector3( 0, 0, 0 ) },
			{ pos = Vector3( 653.19, 1886.55, 24.1 ), rot = Vector3( 0, 0, 0 ) },
		},

		static_objects = {
			{ pos = Vector3( 1314.77, -715.692, 18.099 ), rot = Vector3( 0, 0, 0 ), id = 2933  },
			{ pos = Vector3( 1316.68, -739.567, 15.2972 ), rot = Vector3( 0, 0, 90 ), id = 17299 },
			{ pos = Vector3( 1316.33, -722.808, 15.7574 ), rot = Vector3( 0, 0, 90 ), id = 17293 },
			{ pos = Vector3( 1306.36, -733.354, 19.4754 ), rot = Vector3( 0, 0, 0 ), id = 17296 },
			{ pos = Vector3( 1307.44, -742.133, 19.4754 ), rot = Vector3( 0, 0, 0 ), id = 17300 },
			{ pos = Vector3( 1308.58, -730.470, 19.4754 ), rot = Vector3( 0, 0, 90 ), id = 17295 },
			{ pos = Vector3( 1313.64, -743.232, 19.4754 ), rot = Vector3( 0, 0, 270 ), id = 17301 },
			{ pos = Vector3( 1316.95, -737.763, 19.7018 ), rot = Vector3( 0, 0, 270 ), id = 17298 },
			{ pos = Vector3( 1299.00, -727.362, 15.4810 ), rot = Vector3( 0, 0, 0 ), id = 17292 },
			{ pos = Vector3( 1302.12, -737.484, 15.4803 ), rot = Vector3( 0, 0, 0 ), id = 17297 },
			{ pos = Vector3( 1315.09, -757.451, 19.7018 ), rot = Vector3( 0, 0, 90 ), id = 17305 },
			{ pos = Vector3( 1314.12, -757.451, 19.7018 ), rot = Vector3( 0, 0, 0 ), id = 17290 },
			{ pos = Vector3( 1312.66, -759.864, 15.4810 ), rot = Vector3( 0, 0, 0 ), id = 17303 },
		}
	},

	player_weapons = {
		{ weapon_id = 4,  ammo = 1   },
		{ weapon_id = 24, ammo = 56  },
		{ weapon_id = 29, ammo = 300 },
	},
}

GEs = { }

QUEST_DATA = {
	id = "long_awaited_revenge",
	is_company_quest = true,

	title = "Долгожданная месть",
	description = "Все летит под откос. И я догадываюсь из-за кого все это началось...",

	CheckToStart = function( player )
		if player.interior ~= 0 or player.dimension ~= 0 then return end
		return true
	end,

	restart_position = Vector3( -1349.2681, 221.8425, 18.9833 ),

	quests_request = { "bloody_forest" },
	level_request = 20,

	OnAnyFinish = {
		client = function()
			fadeCamera( true )
			ClearAIPed( localPlayer )
			toggleControl( "enter_exit", true )
			setCameraTarget( localPlayer )
		end,
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			DisableQuestEvacuation( player )
			
			ExitLocalDimension( player )
			RestoreWeapon( player, QUEST_CONF.player_weapons )
		end,
	},

	tasks = 
	{
		{
			name = "Встретиться с барыгой",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateMarkerToCutsceneNPC( {
						id = "huckster",
						dialog = QUEST_CONF.dialogs.start,
						radius = 8,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )

							FindQuestNPC( "huckster" ).ped.dimension = localPlayer.dimension
							StartPedTalk( FindQuestNPC( "huckster" ).ped, nil, true )

							CEs.dialog:next( )

							setTimerDialog( function()
								CEs.dialog:next( )
								setTimerDialog( function()
									CEs.dialog:next( )
									setTimerDialog( function()
										local fade_time = 1
										fadeCamera( false, fade_time )
										CEs.end_step_tmr = setTimer( triggerServerEvent, fade_time * 1000, 1, "long_awaited_revenge_step_1", localPlayer )
									end, 3400, 1 )
								end, 3900, 1 )
							end, 4800, 1 )
						end
					} )
				end,

				server = function( player )

				end
			},

			CleanUp = {
				client = function( data, failed )
					FinishQuestCutscene( { ignore_fade_blink = true } )
					local target_ped = FindQuestNPC( "huckster" ).ped
					target_ped.dimension = 0
					StopPedTalk( target_ped )
				end,
			},

			event_end_name = "long_awaited_revenge_step_1",
		},

		{
			name = "Убрать охранников Александра",

			Setup = {
				client = function( )
					toggleControl( "enter_exit", false )
					EnableCheckQuestDimension( true )
					local positions = QUEST_CONF.positions

					GEs.static_vehs = CreateQuestVehicles( positions.static_vehs )
					GEs.static_objects = CreateStaticObjects( positions.static_objects )
					GEs.alexander_vehicle = CreateStaticVehicle( positions.alexander_vehicle )
					
					GEs.enemy_bots = CreateEnemyBots( positions.enemy )
					GEs.enemy_bots_attack_interface = CreateAttackBotsInterface( table.copy( GEs.enemy_bots ) )

					local need_kills_enemy = #GEs.enemy_bots
					CEs.on_enemy_bot_dead = function()
						CEs.enemy_bots_blips[ source ]:destroy()
						CEs.count_kills_enemy_bots = (CEs.count_kills_enemy_bots or 0) + 1
						if CEs.count_kills_enemy_bots == need_kills_enemy or source == GEs.enemy_bots[ #GEs.enemy_bots ] then
							local fade_time = 1
							fadeCamera( false, fade_time )
							CEs.end_step_tmr = setTimer( triggerServerEvent, fade_time * 1000, 1, "long_awaited_revenge_step_2", localPlayer )
						end
					end

					CEs.enemy_bots_blips = {}
					for k, v in pairs( GEs.enemy_bots ) do
						CEs.enemy_bots_blips[ v ] = createBlipAttachedTo( v, 0, 1 )
						addEventHandler( "onClientPedWasted", v, CEs.on_enemy_bot_dead )
					end

					localPlayer.position = positions.village_start.pos
					localPlayer.rotation = positions.village_start.rot

					fadeCamera( true, 1 )
				end,

				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, positions.player_veh_spawn.vehicle_id, positions.player_veh_spawn.pos, positions.player_veh_spawn.rot )
					vehicle:SetNumberPlate( "1:м155кр178" )
					vehicle:SetWindowsColor( 0, 0, 0, 255 )
					vehicle:SetColor( 0, 0, 0 )
					
					player:SetPrivateData( "temp_vehicle", vehicle )
					GiveQuestWeapon( player, QUEST_CONF.player_weapons )
				end
			},

			CleanUp = {
				client = function( data, failed )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "long_awaited_revenge_step_2",
		},

		{
			name = "RUN SANYA RUN",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					GEs.alexander_bot = CreateAIPed( FindQuestNPC( "alexander" ).ped.model, Vector3(), 0 )
					LocalizeQuestElement( GEs.alexander_bot )
					SetUndamagable( GEs.alexander_bot, true )
					warpPedIntoVehicle( GEs.alexander_bot, GEs.alexander_vehicle )

					SetAIPedMoveByRoute( GEs.alexander_bot, positions.alexander_run_path, false )

					CEs.func_start_cutscene = function()
						setCameraMatrix( positions.alexander_run_camera_1 )
						StartQuestCutscene()
						GEs.watch_element_interface = WatchToElementInterface( GEs.alexander_bot )
						
						fadeCamera( true, 1 )
						CEs.next_cutscene = setTimer( CEs.func_second_camera, 9000, 1 )
					end

					CEs.func_second_camera = function()
						GEs.watch_element_interface:change_camera_position( positions.alexander_run_camera_2 )
						CEs.next_cutscene = setTimer( CEs.func_end_step, 4000, 1 )
					end

					CEs.func_end_step = function()
						local fade_time = 1
						fadeCamera( false, fade_time )
						CEs.end_step_tmr = setTimer( function()
							GEs.watch_element_interface:destroy()
							GEs.watch_element_interface = nil

							removePedTask( GEs.alexander_bot )
							GEs.alexander_vehicle.position = Vector3( -2499, -132, 20 )
							triggerServerEvent( "long_awaited_revenge_step_3", localPlayer )
						end, fade_time * 1000, 1 )
					end

					CEs.func_start_cutscene()
				end,

				server = function( player )

				end
			},

			CleanUp = {
				client = function()
					FinishQuestCutscene({ ignore_fade_blink = true })
				end,
			},

			event_end_name = "long_awaited_revenge_step_3",
		},

		{
			name = "Садись в машину",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					GEs.temp_vehicle = localPlayer:getData( "temp_vehicle" )
					GEs.temp_vehicle.health = 1000
					table.insert( GEs, WatchElementCondition( GEs.temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 360 or self.element.inWater then
								FailCurrentQuest( "Машина уничтожена" )
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
						text = "Нажми key=F чтобы сесть на водительское место",
						condition = function( )
							return isElement( GEs.temp_vehicle ) and ( localPlayer.position - GEs.temp_vehicle.position ).length <= 4
						end
					} )

					GEs.OnClientVehicleStartEnter_handler = function( player, seat )
						if player == localPlayer and seat ~= 0 then
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
							triggerServerEvent( "long_awaited_revenge_step_4", localPlayer )
						end
					end
					addEventHandler( "onClientVehicleEnter", GEs.temp_vehicle, CEs.OnClientVehicleEnter_handler )

					StartQuestTimerFail( 0.5 * 60 * 1000, "Садись в машину", "Слишком медленно!" )

					toggleControl( "enter_exit", true )
					setCameraTarget( localPlayer )
					fadeCamera( true, 1 )
				end,

				server = function( player )

				end
			},

			event_end_name = "long_awaited_revenge_step_4",
		},

		{
			name = "Догони Александра",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CEs.func_create_next_point = function( point_id )
						CreateQuestPoint( positions.path_of_pursuit[ point_id ], function( self, player )
							CEs.marker.destroy( )
							if #positions.path_of_pursuit == point_id then
								fadeCamera( false, 1 )
								CEs.end_step_tmr = setTimer( function( )
									localPlayer.vehicle.frozen = true
									triggerServerEvent( "long_awaited_revenge_step_5", localPlayer )
								end, 1000, 1 )
							else
								CEs.func_create_next_point( point_id + 1 )
							end
						end, _, 15 )
						CEs.marker.slowdown_coefficient = nil
					end
					CEs.func_create_next_point( 1 )
					
					StartQuestTimerFail( 4 * 60 * 1000, "Догони Александра", "Александр ушёл!" )
				end,

				server = function( player )

				end
			},

			event_end_name = "long_awaited_revenge_step_5",
		},

		{
			name = "...",

			Setup = {
				client = function( )
					GEs.temp_vehicle.frozen = false
					local positions = QUEST_CONF.positions

					GEs.alexander_vehicle.position = positions.alexander_veh_start_crush.pos
					GEs.alexander_vehicle.rotation = positions.alexander_veh_start_crush.rot
					
					CEs.func_start_cutscene = function()
						SetAIPedMoveByRoute( GEs.alexander_bot, positions.alexander_crush_path, false )
						setElementVelocity( GEs.alexander_vehicle, Vector3( -0.4, 0, 0 ) )

						setCameraMatrix( positions.alexander_crush_camera_1 )
						StartQuestCutscene()
						GEs.watch_element_interface = WatchToElementInterface( GEs.alexander_bot )
						
						CEs.next_cutscene = setTimer( CEs.func_end_step, 6500, 1 )
					end

					CEs.func_end_step = function()
						local fade_time = 1
						fadeCamera( false, fade_time )
						CEs.end_step_tmr = setTimer( function()
							GEs.watch_element_interface:destroy()
							GEs.watch_element_interface = nil
							FinishQuestCutscene()
							triggerServerEvent( "long_awaited_revenge_step_6", localPlayer )
						end, fade_time * 1000, 1 )
					end

					CEs.start_cutscene_tmr = setTimer( CEs.func_start_cutscene, 150, 1 )
				end,

				server = function( player )

				end
			},

			CleanUp = {
				client = function()
					FinishQuestCutscene({ ignore_fade_blink = true })
				end,
			},

			event_end_name = "long_awaited_revenge_step_6",
		},

		{
			name = "Добить Александра",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					removePedTask( GEs.alexander_bot )
					CleanupAIPedPatternQueue( GEs.alexander_bot )
					removePedFromVehicle( GEs.alexander_bot )
					destroyElement( GEs.alexander_vehicle )

					GEs.alexander_bot.position = positions.alexander_finish.pos
					GEs.alexander_bot.rotation = positions.alexander_finish.rot
					setPedAnimation( GEs.alexander_bot, "crack", "crckidle4" )

					CEs.func_start_cutscene = function()
						GEs.fake_player_bot = CreateAIPed( localPlayer.model, positions.player_finish.pos, positions.player_finish.rot.z )
						LocalizeQuestElement( GEs.fake_player_bot )
						givePedWeapon( GEs.fake_player_bot, 24, 999, true )

						setPedWeaponSlot( GEs.fake_player_bot, 2 )
						setPedAimTarget( GEs.fake_player_bot, Vector3( 427.29547729492, -1092.30663330078, 6.7568879127502 ) )
						setPedControlState( GEs.fake_player_bot, "aim_weapon", true )

						SetUndamagable( GEs.alexander_bot, false )

						setCameraMatrix( unpack( positions.alexander_finish_matrix_2 ) )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.finish } )
						CEs.dialog:next()

						setTimerDialog( CEs.func_second_dialog_sub, 4700, 1 )
					end

					CEs.func_second_dialog_sub = function()
						CEs.dialog:next()
						FadeBlink( 1 )
						setCameraMatrix( unpack( positions.alexander_finish_matrix ) )
						setTimerDialog( CEs.func_third_dialog_sub, 3400, 1 )
					end

					CEs.func_third_dialog_sub = function()
						CEs.dialog:next()
						setTimerDialog( CEs.func_end_cutscene, 3500, 1 )
					end

					CEs.func_end_cutscene = function()
						setPedControlState( GEs.fake_player_bot, "fire", true )
						CEs.off_fire_tmr = setTimer( setPedControlState, 500, 1, "fire", false )
							
						local fade_time = 1
						fadeCamera( false, fade_time )
						CEs.start_cutscene_tmr = setTimer( function()
							setPedControlState( GEs.fake_player_bot, "fire", false )
							localPlayer.position = positions.finish_positions[ math.random( 1, #positions.finish_positions ) ].pos
							triggerServerEvent( "long_awaited_revenge_step_7", localPlayer )
						end, fade_time * 1000, 1 )
					end

					CreateQuestPoint( positions.finish_veh_parking.pos, function( self, player )
						CEs.marker.destroy( )
						local fade_time = 1
						fadeCamera( false, fade_time )
						
						if localPlayer.vehicle then
							CreateAIPed( localPlayer )
							AddAIPedPatternInQueue( localPlayer, AI_PED_PATTERN_VEHICLE_EXIT, {
								end_callback = {
									func = function( )
										CEs.func_start_cutscene()
									end,
									args = { },
								}
							} )
						else
							CEs.func_start_cutscene()
						end
						toggleControl( "enter_exit", false )
					end, _, 5 )
				end,

				server = function( player )

				end
			},

			CleanUp = {
				client = function()
					ClearAIPed( localPlayer )
					FinishQuestCutscene()
				end,
			},

			event_end_name = "long_awaited_revenge_step_7",
		},
	},

	GiveReward = function( player )
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, 
		{
			rewards = { money = QUEST_DATA.rewards.money, exp = QUEST_DATA.rewards.exp, premium = 3 }
		} )
		player:GivePremiumExpirationTime( 3, "quest_unconscious_betrayal" )
	end,

	rewards = {
		money = 8000,
		exp = 10000,
		premium = 3,
	},

	no_show_rewards = true,
}