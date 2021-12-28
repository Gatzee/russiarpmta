QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Анжела", voice_line = "Angela_good_game_01", text = [[Привет, Зайка. Ты не поверишь у меня просто дурдом полный, не могу больше! 
Душа требует отдыха и развлечений! Давай прокатимся.
Я тебе одно место покажу..]] },
		},
		casino = {

			{ name = "Анжела", voice_line = "Angela_good_game_02", text = [[Охренеть! Ты видел?
Я выиграла суперприз. Сегодня точно мой день! 
Давай проверим ее в деле!]] },
		},
		finish = {
			{ name = "Анжела", voice_line = "Angela_good_game_03", text = [[Воу, а ты отлично водишь! Проводить время с тобой всегда в радость,
но сейчас мне нужно возвращаться.
Еще увидимся, пока!]] },
		},
	},

	positions = {
		angela_spawn = { pos = Vector3( 672.96, -79.15, 20.9353 ), rot = Vector3( 0, 0, 180 ) },

		casino_veh_parking = { pos = Vector3( 2497.45, 2588.76, 6.87 ), rot = Vector3( 0, 0, 0 ) },

		casino_outer = { pos = Vector3( 2536.77, 2580.75, 8.08 ), rot = Vector3( 0, 0, 90 ), rz = 90 },
		casino_inner = { pos = Vector3( 2399.34, -1332.97, 2800.07 ), rot = Vector3( 0, 0, 0 ), rz = 0 },

		blackjack_in = { pos = Vector3( 2432.14, -1317.91, 2800.07 ), rot = Vector3( 0, 0, 0 ), rz = 90 },
		--classic_roulette_in = { pos = Vector3( -66.34, -501.75, 914 ), rot = Vector3( 0, 0, 0 ), rz = 90 },

		angela_casino_path = {
			{ x = 2432.1240, y = -1318.2843, z = 2800.0783 },
			{ x = 2431.4523, y = -1315.1611, z = 2800.0783 },
			{ x = 2426.9855, y = -1315.1075, z = 2800.0783 },
			{ x = 2419.5566, y = -1315.2330, z = 2800.0783 },
			{ x = 2412.4638, y = -1315.2138, z = 2800.0783 },
			{ x = 2405.5104, y = -1314.3197, z = 2800.0783 },
			{ x = 2397.1452, y = -1312.5804, z = 2800.0783 },
			{ x = 2392.9743, y = -1311.6296, z = 2800.0783 },
			{ x = 2389.4099, y = -1309.7830, z = 2800.0783 },
		},

		angela_casino_dialog_matrix   = { 2390.4787597656, -1310.7077636719, 2800.8635253906, 2313.7639160156, -1247.3732910156, 2790.6867675781, 0, 70 },
		angela_casino_dialog_position = { pos = Vector3( 2389.4099, -1309.7830, 2800.0783 ), rot = Vector3( 0, 0, 236 ), cz = 69.384582519531 },
		player_casino_dialog_position = { pos = Vector3( 2390.0314, -1310.1055, 2800.0783 ), rot = Vector3( 0, 0, 67 ), cz = 255.50622558594 },

		buggati_spawn = { pos = Vector3( 2510.9860, 2568.3208, 7.4856 ), rot = Vector3( 0, 0, 295 ) },

		buggati_path = {
			Vector3( 2450.21, 2542.03, 7.87 ),
			Vector3( 2454.03, 2681.03, 7.87 ),
			Vector3( 2629.24, 2679.99, 7.87 ),
			Vector3( 2679.54, 2326.65, 7.88 ),
			Vector3( 2284.05, 2077.47, 7.88 ),
			Vector3( 2043,   2443.57, 7.88 ),
			Vector3( 2036.83, 2624.85, 7.88 ),
			Vector3( 2265.67, 2718.14, 7.88 ),
			Vector3( 2423.76, 2573.8,  7.87 ),
			Vector3( 2511.6,  2563.03, 7.88 ),
		},

		angela_street_dialog_matrix = { 2511.1748046875, 2567.2795410156, 8.7641353607178, 2446.6599121094, 2493.2924804688, -10.30802822113, 0, 70 },
		player_street_dialog_position = { pos = Vector3( 2518.8134, 2566.9450, 8.0754 ), rot = Vector3( 0, 0, 111 ) },

		restore_fail_mission = { pos = Vector3( 2522.33, 2573.19, 8.07 ), rot = Vector3( 0, 0, 122 ), cz = 90 },
	},
}

GEs = { }

QUEST_DATA = {
	id = "good_game",
	is_company_quest = true,

	title = "Удачная игра",
	description = "Все становится явно хуже, нужно проветрить голову и взглянуть на все со стороны. Лучший способ — провести время с Анжелой!",

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 673.8060, -114.5921, 20.9096 ),

	quests_request = { "real_initiative" },
	level_request = 18,

	OnAnyFinish = {
		client = function()
			fadeCamera( true )
			DestroyFollowHandlers()
			setCameraTarget( localPlayer )
			triggerEvent( "SwitchRadioEnabled", root, true )
		end,
		server = function( player, reason, reason_data )
			if player.interior ~= 0 and player.dimension == player:GetUniqueDimension() then
				player.interior = 0
				player.position = QUEST_CONF.positions.restore_fail_mission.pos:AddRandomRange( 3 )
				player.rotation = QUEST_CONF.positions.restore_fail_mission.rot
			end

			local frozen_vehicle = player:getData( "frozen_vehicle" )
			if frozen_vehicle then
				frozen_vehicle:SetStatic( false )
				player:setData( "frozen_vehicle", false, false )
			end

			ExitLocalDimension( player )
			DisableQuestEvacuation( player )
			DestroyAllTemporaryVehicles( player )		
		end
	},

	tasks = {
		{
			name = "Встреться с Анжелой",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "angela_rublevo_near_house",
						dialog = QUEST_CONF.dialogs.start,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )
							
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "angela_rublevo_near_house" ).ped, nil, true )

							setTimerDialog( function()
								triggerServerEvent( "good_game_step_1", localPlayer )
							end, 11200 )
						end
					} )
				end,
			},

			CleanUp = {
				client = function( data, failed )
					StopPedTalk( FindQuestNPC( "angela_rublevo_near_house" ).ped )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "good_game_step_1",
		},

		{
			name = "Отправляйся в казино",

			Setup = {
				client = function( )
					HideNPCs( )

					local positions = QUEST_CONF.positions
					
					GEs.angela_bot = CreateAIPed( FindQuestNPC( "angela_rublevo_near_house" ).ped.model, positions.angela_spawn.pos, positions.angela_spawn.rot.z )
					LocalizeQuestElement( GEs.angela_bot )
					SetUndamagable( GEs.angela_bot, true )
					CreateFollowHandlers( { GEs.angela_bot } )

					CreateQuestPoint( positions.casino_veh_parking.pos, function( self, player )
						if localPlayer.vehicle then
							CreateAIPed( localPlayer )
							AddAIPedPatternInQueue( localPlayer, AI_PED_PATTERN_VEHICLE_EXIT, { } )
						end

						CEs.marker.destroy( )
						CEs.timer = setTimer( triggerServerEvent, 500, 1, "good_game_step_2", localPlayer )						
					end, _, 5 )

					CEs.check_angela_distance = function()
						local distance = (localPlayer.position - GEs.angela_bot.position).length
						if distance > 150 then
							FailCurrentQuest( "Ты оставил Анжелу одну!" )
						elseif distance > 50 then
							localPlayer:ShowError( "Вернись за Анжелой!" )
						end
					end
					CEs.check_tmr = setTimer( CEs.check_angela_distance, 2000, 0 )
				end,
				server = function( player )
					EnableQuestEvacuation( player )
					EnterLocalDimensionForVehicles( player )
				end,
			},

			event_end_name = "good_game_step_2",
		},

		{
			name = "Зайди в казино",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					local func_check_veh = function()
						if localPlayer.vehicle then
							return false, "Выйди из транспорта чтобы войти"
						end
						return true
					end

					CreateQuestPoint( positions.casino_outer.pos, function( self, player )
						CEs.marker.destroy( )
						fadeCamera( false, 0.5 )

						CEs.timer = setTimer( function()
							DestroyFollowHandlers()
							triggerServerEvent( "good_game_step_3", localPlayer )
						end, 500, 1 )						
					end, _, 1, _, _, func_check_veh )
				end,
				server = function( player )
					DisableQuestEvacuation( player )	

					local player_vehicle = player.vehicle
					if player_vehicle then
						player:setData( "frozen_vehicle", player_vehicle, false )
						player_vehicle:SetStatic( true )
					end
				end,
			},
			
			event_end_name = "good_game_step_3",
		},

		{
			name = "Сыграй в блек джек",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					localPlayer.position = positions.casino_inner.pos + Vector3( 1.5, 0, 0 )
					localPlayer.rotation = positions.casino_inner.rot
					setPedCameraRotation( localPlayer, positions.casino_inner.rz )

					GEs.angela_bot.interior = 4
					GEs.angela_bot.position = positions.casino_inner.pos
					GEs.angela_bot.rotation = positions.casino_inner.rot
					
					GEs.StartFolowPedToPlayer( GEs.angela_bot )

					CreateQuestPoint( positions.blackjack_in.pos, function( self, player )
						GEs.StopFollowToPlayer( GEs.angela_bot )

						CEs.marker.destroy( )
						fadeCamera( false, 0.5 )

						CEs.timer = setTimer( function()
							localPlayer.position.position = localPlayer.position.position
							CreateBlackJackGame( function()
								triggerServerEvent( "good_game_step_4", localPlayer )
							end )
						end, 500, 1 )						
					end, _, 1, 4 )

					fadeCamera( true, 0.5 )
				end,
				server = function( player )
					player.interior = 4
				end,
			},

			CleanUp = {
				client = function( data, failed )
					DestroyBlackJackGame()
				end,
			},
			
			event_end_name = "good_game_step_4",
		},

		{
			name = "Следуй за Анжелой",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					GEs.angela_bot.position = Vector3( positions.angela_casino_path[ 1 ] )

					local OnMovedClassicLottery = function( is_timer )
						if is_timer then
							GEs.angela_bot.position = Vector3( positions.angela_casino_path[ #positions.angela_casino_path ] )
						elseif isTimer( CEs.timer_move ) then 
							killTimer( CEs.timer_move ) 
						end
						
						GEs.angela_bot:setAnimation( "bd_fire", "wash_up", 1000, false, false, false, false )
						CEs.finish_tmr = setTimer( function()
							CEs.follow_player:destroy()

							triggerServerEvent( "good_game_step_5", localPlayer )
						end, 1500, 1 )
					end

					CEs.start_move_tmr = setTimer( function()
						SetAIPedMoveByRoute( GEs.angela_bot, positions.angela_casino_path, false, OnMovedClassicLottery )
					end, 1000, 1 )

					CEs.follow_player = CreatePedFollow( localPlayer )
					CEs.follow_player.distance = 2
					CEs.follow_player:start( GEs.angela_bot )

					CEs.timer_move = setTimer( OnMovedClassicLottery, 10000 + 1000, 1, true ) -- TODO: time_path
				end,
				server = function( player )

				end,
			},
			
			event_end_name = "good_game_step_5",
		},

		{
			name = "Победа...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					setCameraMatrix( unpack( positions.angela_casino_dialog_matrix ) )
					StartQuestCutscene( { dialog = QUEST_CONF.dialogs.casino } )
					
					localPlayer.position = positions.player_casino_dialog_position.pos
					localPlayer.rotation = positions.player_casino_dialog_position.rot
					
					GEs.StopFollowToPlayer( GEs.angela_bot )
					GEs.angela_bot.position = positions.angela_casino_dialog_position.pos
					GEs.angela_bot.rotation = positions.angela_casino_dialog_position.rot

					StartPedTalk( GEs.angela_bot, nil, true )

					CEs.dialog:next( )

					setTimerDialog( function() 
						triggerServerEvent( "good_game_step_6", localPlayer )
					end, 7200 )
				end,
				server = function( player )
					
				end,
			},
			
			CleanUp = {
				client = function( data, failed )
					StopPedTalk( GEs.angela_bot )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "good_game_step_6",
		},

		{
			name = "Покинь казино",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					GEs.StartFolowPedToPlayer( GEs.angela_bot )
					
					CreateQuestPoint( positions.casino_inner.pos, function( self, player )
						GEs.StopFollowToPlayer( GEs.angela_bot )

						CEs.marker.destroy( )
						fadeCamera( false, 0.5 )

						CEs.timer = setTimer( function()
							triggerServerEvent( "good_game_step_7", localPlayer )
						end, 500, 1 )						
					end, _, 1, 4 )
					
				end,
				server = function( player )
					local vehicle = CreateTemporaryVehicle( player, 526, QUEST_CONF.positions.buggati_spawn.pos, QUEST_CONF.positions.buggati_spawn.rot )
					vehicle:SetColor( 255, 0, 0 )
					vehicle:SetNumberPlate( "1:o" .. math.random(111, 999) .. "oo077" )
					vehicle.frozen = true
					player:SetPrivateData( "temp_vehicle", vehicle )
				end,
			},
			
			event_end_name = "good_game_step_7",
		},

		{
			name = "Садись в Bugatti Chiron",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					localPlayer.position = positions.casino_outer.pos - Vector3( 1.5, 0, 0 )
					localPlayer.rotation = positions.casino_outer.rot
					setPedCameraRotation( localPlayer, positions.casino_outer.rz )

					GEs.angela_bot.interior = 0
					GEs.angela_bot.position = positions.casino_outer.pos
					GEs.angela_bot.rotation = positions.casino_outer.rot
					
					CreateFollowHandlers( { GEs.angela_bot } )
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F или key=ENTER чтобы сесть в авто",
						condition = function( )
							return isElement( temp_vehicle ) and ( localPlayer.position - temp_vehicle.position ).length <= 8
						end
					} )

					CreateQuestPoint( temp_vehicle.position, function( self, player )
						CEs.marker.destroy( )
					end, _, 5 )

					GEs.onEnterVehicle = function( ped )
						if ped == localPlayer and CEs.hint then
							CEs.hint:destroy()
							CEs.hint = nil
						end

						if localPlayer.vehicle == temp_vehicle and GEs.angela_bot.vehicle == temp_vehicle then
							DestroyFollowHandlers()

							removeEventHandler( "onClientVehicleEnter", temp_vehicle, GEs.onEnterVehicle )
							triggerServerEvent( "good_game_step_8", localPlayer )
						end
					end
					addEventHandler( "onClientVehicleEnter", temp_vehicle, GEs.onEnterVehicle )

					GEs.onClientVehicleStartEnter = function( player, seat, door )
						if GEs.angela_bot.vehicle == temp_vehicle or GEs.finish_drive then cancelEvent() end
						if player == localPlayer and seat ~= 0 then 
							localPlayer:ShowError( "Садись на водительское место" )
							cancelEvent()
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, GEs.onClientVehicleStartEnter )

					CEs.check_angela_distance = function()
						local distance = (localPlayer.position - GEs.angela_bot.position).length
						if distance > 150 then
							FailCurrentQuest( "Ты оставил Анжелу одну!" )
						elseif distance > 50 then
							localPlayer:ShowError( "Вернись за Анжелой!" )
						end
					end
					CEs.check_tmr = setTimer( CEs.check_angela_distance, 2000, 0 )

					triggerEvent( "SwitchRadioEnabled", root, false )
					fadeCamera( true, 0.5 )
				end,
				server = function( player )
					player.interior = 0
				end,
			},

			CleanUp = {
				client = function( data, failed )
					DestroyFollowHandlers()
				end,
			},
			
			event_end_name = "good_game_step_8",
		},

		{
			name = "Прокати Анжелу",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )

					local count_points = #positions.buggati_path
					CEs.NextPoint = function()
						CEs.current_point = (CEs.current_point or 0) + 1
						if positions.buggati_path[ CEs.current_point ] then
							CreateQuestPoint( positions.buggati_path[ CEs.current_point ], function( self, player )
								if localPlayer.vehicle ~= temp_vehicle then return end

								CEs.marker.destroy( )
								CEs.NextPoint()
							end, _, 8, nil, nil, nil, nil, nil, nil, 0, 255, 0, 100 )
							
							if CEs.current_point ~= count_points then
								CEs.marker.slowdown_coefficient = nil
							end
						else
							GEs.finish_drive = true
							triggerServerEvent( "good_game_step_9", localPlayer )
						end
					end
					
					CEs.NextPoint()
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					if isElement( vehicle ) then vehicle.frozen = false end
				end,
			},
			
			event_end_name = "good_game_step_9",
		},

		{
			name = "Круто водишь...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					
					positions.angela_street_dialog_matrix[ 4 ] = temp_vehicle.position.x
					positions.angela_street_dialog_matrix[ 5 ] = temp_vehicle.position.y
					positions.angela_street_dialog_matrix[ 6 ] = temp_vehicle.position.z

					setCameraMatrix( unpack( positions.angela_street_dialog_matrix ) )
					StartQuestCutscene( { dialog = QUEST_CONF.dialogs.finish } )

					CEs.dialog:next( )
					StartPedTalk( GEs.angela_bot, nil, true )

					setTimerDialog( function()
						AddAIPedPatternInQueue( localPlayer, AI_PED_PATTERN_VEHICLE_EXIT, {
							end_callback = {
								func = function( )
									localPlayer.position = positions.player_street_dialog_position.pos:AddRandomRange( 3 )
									localPlayer.rotation = positions.player_street_dialog_position.rot
									triggerServerEvent( "good_game_step_10", localPlayer )
								end,
								args = { },
							}
						} )
						
						fadeCamera( false, 1.5 )
					end, 9200 )
				end,
				server = function( player )

				end,
			},

			CleanUp = {
				client = function( data, failed )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "good_game_step_10",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification( { title = "Роман", msg = "Здравствуй, я тебя жду, приезжай!" },
		{
			condition = function( self, player, data, config )
				local current_quest = player:getData( "current_quest" )
				if current_quest and current_quest.id == "quest_murderous_setup" then
					return "cancel"
				end
				return getRealTime( ).timestamp - self.ts >= 60
			end,
			save_offline = true,
		} )
		
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, 
		{
			rewards = { money = QUEST_DATA.rewards.money, exp = QUEST_DATA.rewards.exp, wof_coin_gold = QUEST_DATA.rewards.wof_coin_gold }
		} )
	end,

	rewards = {
		money = 6500,
		exp = 5500,
		wof_coin_gold = 1,
	},
	no_show_rewards = true,
}
