QUEST_CONF = {
	dialogs = {
		main = {
			{ name = "Александр", voice_line = "Alexandr_7", text = "Привет. Садись в машину поедем к бандитам. Будь спокоен(-а), а говорить буду я!" },
		},
		talk = {
			{ name = "Александр", voice_line = "Alexandr_9", text = "Здравствуй старый друг как ты? Слушай у меня просьба к тебе есть" },
			{ name = "Линьку О", voice_line = "Asian_1", text = "Конишуа. Кто тебе сказал, что я должен тебе помочь?" },
			{ name = "Александр", voice_line = "Alexandr_10", text = "Вспомни последнее дело, я тебя спас!" },
			{ name = "Линь ку О", voice_line = "Asian_2", text = "Это ты меня спас?! Ты прятался и визжал как младенец, пока нас спасали мои люди!\nКто ты такой, чтобы приходить в мой дом и просить о помощи! Ребята разберитесь с ними! " },
		},
		finish = {
			{ name = "Александр", voice_line = "Alexandr_8", text = "Отлично...Черт! Ну главное выжили.\nЛадно буду думать, что делать дальше." },
		},
	},

	positions = {
		vehicle_main_spawn = Vector3( 1801.9792480469, -624.90042114258, 61.038932800293 ),
		vehicle_main_spawn_rotation = Vector3( 359.83905029297, 359.97412109375, 16.00439453125 ),

		drive_carsell = {
			{ x = 1801.6173095703, y = -605.64915466309, z = 61.049411773682 },
			{ x = 1809.7469482422, y = -596.5950012207, z = 60.992874145508 },
			{ x = 1819.265625, y = -616.44142150879, z = 60.919952392578 },
			{ x = 1826.8640136719, y = -643.10255432129, z = 60.921993255615 },
			{ x = 1830.416015625, y = -656.30574035645, z = 60.873439788818 },
			{ x = 1814.7966308594, y = -666.82815551758, z = 60.857181549072 },
			{ x = 1803.4609375, y = -670.7144317627, z = 60.859424591064 },
			{ x = 1773.1246337891, y = -680.42919921875, z = 60.854549407959 },
		},

		vehicle_spawn_band = Vector3( 2039.270, -2260.557, 32.286 ),
		vehicle_spawn_band_rotation = Vector3( 3.372802734375, 359.90417480469, 103.82360839844 ),
		drive_band = {
			{ x = 2039.270, y = -2260.557, z = 32.286 },
			{ x = 2002.582, y = -2263.912, z = 29.548 },
			{ x = 1953.752, y = -2261.253, z = 28.967 },
		},

		matrix_drive = { 1978.0169677734, -2269.8616943359, 27.462516784668, 1891.2277832031, -2220.9020996094, 35.8649559021, 0, 70 },

		band_leader = Vector3( 1939.5622558594, -2229.5180664063, 31.594284057617 ),
		band_leader_rotation = Vector3( 0, 0, 181.97273254395 ),

		patrol_1 = {
			{ x = 1924.914, y = -2244.634, z = 30.253, move_type = 4, distance = 1, },
			{ x = 1924.213, y = -2234.519, z = 30.732, move_type = 4, distance = 1, },
			{ x = 1923.025, y = -2226.813, z = 31.102, move_type = 4, distance = 1, },
		},

		patrol_2 = {
			{ x = 1954.204, y = -2244.368, z = 30.287, move_type = 4, distance = 1, },
			{ x = 1955.138, y = -2233.107, z = 30.830, move_type = 4, distance = 1, },
			{ x = 1956.633, y = -2224.416, z = 31.249, move_type = 4, distance = 1, },
		},

		near_leader = Vector3( 1938.9798583984, -2230.7503662109, 31.536180496216 ),
		near_leader_rotation = Vector3( 0, 0, 344.70336914063 ),

		near_leader_bot = Vector3( 1940.1358642578, -2230.7730712891, 31.536512374878 ),
		near_leader_bot_rotation = Vector3( 0, 0, 28.570404052734 ),

		matrix_talks_alexander = { 1939.8032226563, -2229.0753173828, 32.342620849609, 1941.7697753906, -2328.1922607422, 19.228897094727, 0, 70 },
		matrix_talks_leader = { 1939.947265625, -2231.3801269531, 32.284168243408, 1934.9208984375, -2132.2391357422, 20.209102630615, 0, 70 },

		vehicle_spawn_after_band = Vector3( 1939.6737060547, -2264.3333740234, 29.360439300537 ),
		vehicle_spawn_after_band_rotation = Vector3( 1.1154174804688, 359.99853515625, 90.106353759766 ),

		tuning_enter_position = Vector3( 1817.41015625, -699.66282653809, 60.672729492188 ),

		matrix_final_scene = { 1315.4058837891, -710.0126953125, 15.993114471436, 1240.5991210938, -774.039413452148, -1.6524097919464, 0, 70 },

		garage_finish = Vector3( 1305.5462646484, -715.7770324707, 14.97200012207 ),
		garage_finish_rotation = Vector3( 0, 0, 270 ),
		garage_inside_finish = Vector3( 1320.6694335938, -715.7770324707, 15.44987487793 ),
		matrix_garage_scene = { 1307.0594482422, -710.1895904541, 20.010473251343, 1371.1392822266, -772.45011138916, -25.618608474731, 0, 70 },
		out_of_viphouse = Vector3( 1291.4836425781, -849.657180786133, 14.915561676025 ),
	},

	vehicle_start_follow_num = 2,
}

GEs = { }

QUEST_DATA = {
	id = "alexander_talks",
	is_company_quest = true,

	title = "Тонкие переговоры",
	description = "Александр договорился о встрече с местной бандой, возможно они что-нибудь знают, главное чтобы прошло все гладко.",

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 1774.9056, -637.4530, 60.8555 ),

	quests_request = { "alexander_debt" },
	level_request = 3,

	OnAnyFinish = {
		server = function( player, reason, reason_data )
			local suitable_reason_data = {
				wasted = true,
				stop = true,
				fail = true,
			}
			if reason_data and reason_data.type and suitable_reason_data[ reason_data.type ] then
				player.vehicle = nil
			end
			DestroyAllTemporaryVehicles( player )
			ExitLocalDimension( player )
		end,
		client = function()
			localPlayer:setData( "blocked_cruise", false, false )
			localPlayer:setData( "radial_disabled", false, false )
		end,
	},

	tasks = {
		{
			name = "Поговорить с Александром",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "alexander",
						dialog = QUEST_CONF.dialogs.main,
						radius = 1,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "alexander" ).ped, nil, true )

							setTimerDialog( function( )
								triggerServerEvent( "alexander_debt_step_1", localPlayer )
							end, 7000, 1 )
						end
					} )
				end,

				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 6536, positions.vehicle_main_spawn, positions.vehicle_main_spawn_rotation )
					vehicle:SetVariant( 2 )
					player:SetPrivateData( "temp_vehicle", vehicle )
					vehicle:SetColor( 0, 0, 0 )
					vehicle:SetTireDamageEnabled( false )
					vehicle:SetCruiseEnabled( true )
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "alexander" ).ped )
				end,
			},

			event_end_name = "alexander_debt_step_1",
		},

		{
			name = "Сесть в Хаммер на пассажирское место",

			Setup = {
				client = function( )
					localPlayer:setData( "blocked_cruise", true, false )
					localPlayer:setData( "radial_disabled", true, false )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=G чтобы сесть в Хаммер как пассажир",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return not localPlayer.vehicle and isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					HideNPCs( )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							iprint( self.element.health )
							if self.element.health <= 360 or self.element.inWater then
								FailCurrentQuest( "Машина уничтожена", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					GEs.bot = CreateAIPed( 72, Vector3( 1788.6541748047, -627.05662536621, 60.808650970459 ) )
					LocalizeQuestElement( GEs.bot )
					SetUndamagable( GEs.bot, true )
					table.insert( GEs, WatchElementCondition( GEs.bot, {
						condition = function( self, conf )
							if isPedDead( self.element ) or self.element.inWater then
								FailCurrentQuest( "Александр погиб!" )
								return true
							end
						end,
					} ) )

					local t = { }
					local function CheckBothInVehicle( )
						if localPlayer.vehicle and GEs.bot.vehicle then
							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )

							StartQuestCutscene( )
							SetAIPedMoveByRoute( GEs.bot, QUEST_CONF.positions.drive_carsell, false )

							local from = { 1817.2629394531, -645.97256469727, 67.952453613281, 1748.0321044922, -579.63681030273, 38.031032562256, 0, 70 }
							local to = { 1817.1042480469, -690.15292358398, 81.410308837891, 1808.5791015625, -599.66381835938, 42.001167297363, 0, 70 }
							CEs.move = CameraFromTo( from, to, 20000, "OutQuad" )

							setTimerDialog( function( )
								CEs.move:destroy( )
								fadeCamera( false, 1.0 )
								setTimerDialog( function( )
									CleanupAIPedPatternQueue( GEs.bot )
									triggerServerEvent( "alexander_debt_step_2", localPlayer )
								end, 2000, 1 )
							end, 6000, 1 )

						end
					end

					AddAIPedPatternInQueue( GEs.bot, AI_PED_PATTERN_VEHICLE_ENTER, {
						vehicle = temp_vehicle;
						seat = 0;
						end_callback = {
							func = CheckBothInVehicle,
							args = { },
						}
					} )

					t.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat == 0 then
							cancelEvent( )
							localPlayer:ShowError( "Сядь на пассажирское место, Александр сам всё порешает" )
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )

					t.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						CheckBothInVehicle( )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "alexander_debt_step_2",
		},

		{
			name = "Прибытие...",

			Setup = {
				server = function( player )
					local seat = getPedOccupiedVehicleSeat( player )
					DestroyAllTemporaryVehicles( player )

					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 6536, positions.vehicle_spawn_band, positions.vehicle_spawn_band_rotation )
					vehicle:SetVariant( 2 )
					player:SetPrivateData( "temp_vehicle", vehicle )
					vehicle:SetColor( 0, 0, 0 )
					vehicle:SetTireDamageEnabled( false )

					warpPedIntoVehicle( player, vehicle, seat or 1 )

					triggerEvent( "alexander_debt_step_vehicle", player )
				end,
			},

			event_end_name = "alexander_debt_step_vehicle",
		},

		{
			name = "Прибытие...",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					ResetAIPedPattern( GEs.bot )

					setCameraMatrix( unpack( positions.matrix_drive ) )
					fadeCamera( true )

					StartQuestCutscene( )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 360 or self.element.inWater then
								FailCurrentQuest( "Машина уничтожена", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )
					warpPedIntoVehicle( GEs.bot, temp_vehicle )
					temp_vehicle.velocity = Vector3( )
					temp_vehicle.turnVelocity = Vector3( )

					local pos = positions.drive_band[ 1 ]
					temp_vehicle.position = positions.vehicle_spawn_band
					temp_vehicle.rotation = positions.vehicle_spawn_band_rotation

					SetAIPedMoveByRoute( GEs.bot, positions.drive_band, false, function( )
						CEs.timer = setTimer( function( )
							if temp_vehicle.velocity.length <= 0 then
								CreateAIPed( localPlayer )
								for i, v in pairs( { localPlayer, GEs.bot } ) do
									AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, { } )
								end
								triggerServerEvent( "alexander_debt_step_3", localPlayer )
							end
						end, 500, 0 )
					end )

					GEs.leader = CreateAIPed( 20, positions.band_leader )
					SetUndamagable( GEs.leader, true )
					GEs.leader.rotation = positions.band_leader_rotation
					LocalizeQuestElement( GEs.leader )
					GEs.leader.frozen = true

					for i = 1, 2 do
						local patrol = positions[ "patrol_" .. i ]
						local pos = patrol[ 1 ]
						local ped = CreateAIPed( 20 + i, Vector3( pos.x, pos.y, pos.z ) )
						LocalizeQuestElement( ped )
						SetUndamagable( ped )
						givePedWeapon( ped, 30, 9999, true )

						local t = { }

						local function reverse( )
							local tbl = { }
							for i = 1, #patrol do
								table.insert( tbl, 1, patrol[ i ] )
							end
							patrol = tbl
						end

						t.AddPath = function( )
							reverse( )
							SetAIPedMoveByRoute( ped, patrol, false, function( )
								t.AddPath( )
							end )
						end

						t.AddPath( )

						ped.frozen = true
						GEs[ "guard_" .. i ] = ped
					end
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					local positions = QUEST_CONF.positions
					vehicle.position = positions.vehicle_spawn_band
					vehicle.rotation = positions.vehicle_spawn_band_rotation
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "alexander_debt_step_3",
		},

		{
			name = "Сопроводить Александра к Бандитам",

			Setup = {
				client = function( )
					for i = 1, 2 do
						local ped = GEs[ "guard_" .. i ]
						ped.frozen = false
					end

					CEs.timer = setTimer( function( )
						if not GEs.bot.vehicle then
							killTimer( sourceTimer )
							CEs.follow = CreatePedFollow( GEs.bot )
							CEs.follow:start( localPlayer )
						end
					end, 500, 0 )

					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.band_leader + Vector3( 0, 0, 0.15 ), function( self, player )
						CEs.marker.destroy( )
						CEs.follow:destroy( )

						local temp_vehicle = localPlayer:getData( "temp_vehicle" )
						temp_vehicle.position = positions.vehicle_spawn_after_band
						temp_vehicle.rotation = positions.vehicle_spawn_after_band_rotation

						localPlayer.position = positions.near_leader
						localPlayer.rotation = positions.near_leader_rotation

						GEs.bot.position = positions.near_leader_bot
						GEs.bot.rotation = positions.near_leader_bot_rotation

						StartQuestCutscene( {
							dialog = QUEST_CONF.dialogs.talk,
						} )
						CEs.dialog:next( )
						setCameraMatrix( unpack( positions.matrix_talks_alexander ) )

						StartPedTalk( GEs.bot, nil, true )

						setTimerDialog( function( )
							StopPedTalk( GEs.bot )
							StartPedTalk( GEs.leader, nil, true )

							setCameraMatrix( unpack( positions.matrix_talks_leader ) )
							CEs.dialog:next( )
							setTimerDialog( function( )
								StopPedTalk( GEs.leader )
								StartPedTalk( GEs.bot, nil, true )

								setCameraMatrix( unpack( positions.matrix_talks_alexander ) )
								CEs.dialog:next( )
								setTimerDialog( function( )
									StopPedTalk( GEs.bot )
									StartPedTalk( GEs.leader, nil, true )

									setCameraMatrix( unpack( positions.matrix_talks_leader ) )
									CEs.dialog:next( )
									setTimerDialog( function( )
										triggerServerEvent( "alexander_debt_step_4", localPlayer )
									end, 12000, 1 )
								end, 3500, 1 )
							end, 4500, 1 )
						end, 5500, 1 )
					end, _, 1.2, _, _ )
				end,

				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					vehicle:SetStatic( true )
					vehicle.locked = true
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( GEs.leader )
					StopPedTalk( GEs.bot )
				end,
			},

			event_end_name = "alexander_debt_step_4",
		},

		{
			name = "Сесть в машину",

			Setup = {
				server = function( player )
					DestroyAllTemporaryVehicles( player )

					local vehicle = CreateTemporaryVehicle( player, 6536, Vector3( 1939.650, -2264.297, 29.359 ), Vector3( 1.102, 359.976, 91.087 ) )
					vehicle:SetVariant( 2 )
					player:SetPrivateData( "temp_vehicle", vehicle )
					vehicle:SetColor( 0, 0, 0 )
					vehicle:SetTireDamageEnabled( false )

					triggerEvent( "alexander_debt_step_vehicle_2", player )
				end,
			},

			event_end_name = "alexander_debt_step_vehicle_2",
		},

		{
			name = "Сесть в машину",

			Setup = {
				client = function( )
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F или key=ENTER чтобы сесть на водительское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 10
						end
					} )

					StartQuestTimerFail( 30 * 1000, "Сесть в машину", "Слишком медленно!" )

					localPlayer.health = 100
					setTimer( function( )
						for i = 1, 2 do
							local ped = GEs[ "guard_" .. i ]
							CleanupAIPedPatternQueue( ped )
							removePedTask( ped )
							local shoot = CreatePedShoot( ped )
							shoot.speed_spread = { 2.5, 4 }
							shoot.distance_no_spread = 5
							shoot:start( localPlayer )

							CEs[ "shoot_" .. i ] = shoot
						end
					end, 1000, 1 )

					CEs.dead_hint = CreateSutiationalHint( {
						text = "Сваливай на Хаммере, у тебя нет шансов!",
						condition = function( )
							for i = 1, 2 do
								local ped = GEs[ "guard_" .. i ]
								if ( localPlayer.position - ped.position ).length <= 20 then
									return true
								end
							end
						end
					} )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 360 or self.element.inWater then
								FailCurrentQuest( "Машина уничтожена", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					local t = { }
					local function CheckBothInVehicle( )
						if localPlayer.vehicle and GEs.bot.vehicle then
							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )

							triggerServerEvent( "alexander_debt_step_5", localPlayer )
						end
					end

					AddAIPedPatternInQueue( GEs.bot, AI_PED_PATTERN_VEHICLE_ENTER, {
						vehicle = temp_vehicle;
						seat = 1;
						end_callback = {
							func = CheckBothInVehicle,
							args = { },
						}
					} )

					t.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat ~= 0 then
							cancelEvent( )
							localPlayer:ShowError( "Садись на водительское место и вези Александра!" )
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )

					t.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						CheckBothInVehicle( )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					vehicle.locked = false
				end,
			},

			event_end_name = "alexander_debt_step_5",
		},

		{
			name = "Уйти от погони",

			Setup = {
				client = function( )
					StartQuestTimerFail( 3 * 60 * 1000, "Сбежать от бандитов", "Слишком медленно!" )

					toggleControl( "enter_exit", false )

					local path = { }

					local file = fileOpen( "paths/path_enemy.txt" )
					local contents = fileRead( file, fileGetSize( file ) )
					fileClose( file )
					local lines = split( contents, "\n" )

					for i = 1, #lines, 30 do
						local v = lines[ i ]
						local x, y, z = unpack( split( v, "," ) )
						table.insert( path, { x = tonumber( x ), y = tonumber( y ) - 860, z = tonumber( z ) } )
					end

					local n = 0

					local t = { }
					t.CreateNextPath = function( )
						n = n + 1
						local v = path[ n ]

						if v then
							CEs.marker = createMarker( v.x, v.y, v.z, "checkpoint", 10, 255, 0, 0, 150 )
							triggerEvent( "onClientTryGenerateGPSPath", root, {
								x = v.x, y = v.y, z = v.z, route_id = "quest_alexander_talkts",
							} )

							LocalizeQuestElement( CEs.marker )

							addEventHandler( "onClientMarkerHit", CEs.marker, function( )
								CEs.marker:destroy( )

								if n == QUEST_CONF.vehicle_start_follow_num then
									CEs.vehicle = createVehicle( 551, path[ 1 ].x, path[ 1 ].y, path[ 1 ].z )
									LocalizeQuestElement( CEs.vehicle )
									local dx, dy = localPlayer.position.x - CEs.vehicle.position.x, localPlayer.position.y - CEs.vehicle.position.y
									CEs.vehicle.rotation = Vector3( 0, 0, math.deg( math.atan2( dy, dx ) ) - 90 )
									CEs.vehicle.velocity = Vector3( dx, dy, 0 ):getNormalized( ) * 0.5
									CEs.follow_bot = CreateAIPed( 21, CEs.vehicle.position + Vector3( 0, 0, 5 ) )
									LocalizeQuestElement( CEs.follow_bot )
									warpPedIntoVehicle( CEs.follow_bot, CEs.vehicle, 0 )
									ResetAIPedPattern( CEs.follow_bot )

									CEs.follow = CreatePedFollow( CEs.follow_bot )
									CEs.follow.speed_limit = 100
									CEs.follow:start( localPlayer )

									CEs.shoot_bot = createPed( 21, CEs.vehicle.position + Vector3( 0, 0, 5 ) )
									LocalizeQuestElement( CEs.shoot_bot )
									warpPedIntoVehicle( CEs.shoot_bot, CEs.vehicle, 1 )

									givePedWeapon( CEs.shoot_bot, 28, 999999, true )

									local old_state = false
									CEs.shoot_timer = setTimer( function( )
										setPedAimTarget( CEs.shoot_bot, localPlayer.position )

										local state = ( CEs.shoot_bot.position - localPlayer.position ).length <= 100

										if state ~= old_state then
											setPedWeaponSlot( CEs.shoot_bot, state and 4 or 0 )
											setPedDoingGangDriveby( CEs.shoot_bot, state )
											setPedControlState( CEs.shoot_bot, "vehicle_fire", state )
											old_state = state
										end
									end, 250, 0 )

								elseif CEs.vehicle and ( ( CEs.vehicle.position - localPlayer.position ).length >= 50 ) and path[ n - 3 ] and n < 30 then
									local point = path[ n - 1 ]

									if not isPedDead( CEs.follow_bot ) and not getScreenFromWorldPosition( point.x, point.y, point.z ) then
										CEs.vehicle.position = Vector3( point.x, point.y, point.z )
										local dx, dy = localPlayer.position.x - CEs.vehicle.position.x, localPlayer.position.y - CEs.vehicle.position.y
										CEs.vehicle.rotation = Vector3( 0, 0, math.deg( math.atan2( dy, dx ) ) - 90 )
										CEs.vehicle.velocity = Vector3( dx, dy, 0 ):getNormalized( ) * 0.5
										iprint( "Boosted bot", getTickCount( ) )
									end
								end

								iprint( n .. "/" .. #path )

								if n == #path then
									triggerServerEvent( "alexander_debt_step_6", localPlayer )
								else
									t.CreateNextPath( )
								end

								
							end )
						end

					end

					t.CreateNextPath( )
				end,
			},

			CleanUp = {
				client = function( )
					triggerEvent( "onClientTryDestroyGPSPath", root, "quest_alexander_talkts" )

					toggleControl( "enter_exit", true )
					--FinishQuestCutscene( )
					iprint( "START TUNING SCENE" )
				end,
			},

			event_end_name = "alexander_debt_step_6",
		},

		{
			name = "Скрыться в тюнинг-салоне",

			Setup = {
				client = function( )
					StartQuestTimerFail( 20 * 1000, "Скрыться в тюнинг салоне", "Слишком медленно!" )
					CreateQuestPoint( QUEST_CONF.positions.tuning_enter_position, function( self, player )
						CEs.marker.destroy( )

						triggerServerEvent( "alexander_debt_step_7", localPlayer )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle then
							return false, "Вернись в машину, ало"
						end
						return true
					end )
				end,
			},

			event_end_name = "alexander_debt_step_7",
		},

		{
			name = "Установить винилы",

			Setup = {
				client = function( )
					triggerEvent( "onTuningRecolorPreviewStart", localPlayer )
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					vehicle:Fix( )
					vehicle:SetColor( 0, 130, 180 )
				end,
			},

			CleanUp = {
				client = function( )
					triggerEvent( "onTuningRecolorPreviewStop", localPlayer )
				end,
			},

			event_end_name = "alexander_debt_step_8",
		},

		{
			name = "Отвези Александра домой",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					local path = { }

					local file = fileOpen( "paths/path_miss.txt" )
					local contents = fileRead( file, fileGetSize( file ) )
					fileClose( file )
					local lines = split( contents, "\n" )

					for i = 1, #lines, 30 do
						local v = lines[ i ]
						local x, y, z = unpack( split( v, "," ) )
						table.insert( path, { x = tonumber( x ), y = tonumber( y ) - 860, z = tonumber( z ), distance = 10 } )
					end

					CEs.vehicle = createVehicle( 551, Vector3( path[ 1 ].x, path[ 1 ].y, path[ 1 ].z ) )
					LocalizeQuestElement( CEs.vehicle )

					local dx, dy = path[ 2 ].x - path[ 1 ].x, path[ 2 ].y - path[ 1 ].y
					CEs.vehicle.rotation = Vector3( 0, 0, math.deg( math.atan2( dy, dx ) ) - 90 )
					CEs.vehicle.velocity = Vector3( dx, dy, 0 ):getNormalized( ) * 0.5
					CEs.follow_bot = CreateAIPed( 21, CEs.vehicle.position + Vector3( 0, 0, 5 ) )
					LocalizeQuestElement( CEs.follow_bot )
					warpPedIntoVehicle( CEs.follow_bot, CEs.vehicle, 0 )
					ResetAIPedPattern( CEs.follow_bot )
					SetAIPedMoveByRoute( CEs.follow_bot, path, false )

					CreateQuestPoint( positions.garage_finish, function( self, player )
						CEs.marker.destroy( )

						local vehicle = localPlayer.vehicle

						vehicle.position = positions.garage_finish
						vehicle.rotation = positions.garage_finish_rotation
						vehicle.velocity = Vector3( )
						vehicle.turnVelocity = Vector3( )

						StartQuestCutscene( {
							dialog = QUEST_CONF.dialogs.finish,
						} )
						CEs.dialog:next( )
						setCameraMatrix( unpack( positions.matrix_final_scene ) )

						setTimerDialog( function( )
							CreateAIPed( localPlayer )
							AddAIPedPatternInQueue( localPlayer, AI_PED_PATTERN_VEHICLE_EXIT, {
								end_callback = {
									func = function( )

										ResetAIPedPattern( GEs.bot )
										ClearAIPed( localPlayer )
										FadeBlink( 1.0 )
										setCameraMatrix( unpack( positions.matrix_garage_scene ) )
										warpPedIntoVehicle( GEs.bot, vehicle, 0 )
										
										local func_next_step = function()
											triggerServerEvent( "alexander_debt_step_9", localPlayer )
										end

										local pos = positions.garage_inside_finish
										SetAIPedMoveByRoute( GEs.bot, { { x = pos.x, y = pos.y, z = pos.z } }, false, func_next_step )
										CEs.next_step_tmr = setTimer( func_next_step, 8000, 1 )
									end,
									args = { },
								}
							} )
						end, 9000, 1 )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle then
							return false, "Вернись в машину, ало"
						end
						return true
					end )
				end,
				server = function( player )
					GetTemporaryVehicle( player ):SetColor( 0, 130, 180 )
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "alexander_debt_step_9",
		},

		{
			name = "Покинь виллу",

			Setup = {
				client = function( )
					GEs.bot:destroy( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.out_of_viphouse, function( self, player )
						CEs.marker.destroy( )
						triggerServerEvent( "alexander_debt_step_10", localPlayer )
					end )
				end,
				server = function( player )
					DestroyAllTemporaryVehicles( player )
				end,
			},

			event_end_name = "alexander_debt_step_10",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Анжела", msg = "Привет, я знаю чего тебе точно не хватает. Приезжай ко мне! Журнал квестов F2" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "angela_risks" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)

		local given_evacuations = 0
		for i, v in pairs( player:GetVehicles( true ) ) do
			if isElement( v ) then
				local vehicle_id = v:GetID( )
				if not player:HasFreeEvacuation( vehicle_id ) then
					player:GiveFreeEvacuation( vehicle_id )
					given_evacuations = given_evacuations + 1
				end
			end
		end

		if given_evacuations > 0 then
			player:PhoneNotification( { title = "Бесплатная эвакуация", msg = "Тебе доступна бесплатная эвакуация транспорта! Открой эвакуатор в телефоне" } )
		end

		player:GiveCase( "titan", 1 )
		triggerClientEvent( player, "onClientShowFreeCaseMenu", root, { case_id = "titan" } )

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				exp = 1000,
				money = 500,
			}
		} )
	end,

	rewards = {
		exp = 1000,
		money = 500,
	},

	no_show_rewards = true,
}

-- iexe nrp_player GetPlayer(7):setData("quests",{})
-- crun triggerServerEvent("PlayeStartQuest_alexander_debt",root)