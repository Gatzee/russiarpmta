QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Ксюша", voice_line = "Ksusha_20", text = [[Привет... меня ограбили! У меня... Сделка сорвалась!
У меня одна сволочь украла кейс с документами, перед самой важной сделкой!!!
Ладно хоть было к кому обратиться...]] },
			{ name = "Ксюша", text = [[И все же без тебя мне не справиться. 
Ведь ты поддержишь меня, ну поможешь отомстить этим сволочам?
Я знаю, где мои документы, поехали их заберем, только дай я вещи захвачу!]] },
		},
		finish = {
			{ name = "Ксюша", voice_line = "Ksusha_21", text = [[Мы сделали это! Да! Спасибо тебе огромное за помощь, я никогда этого не забуду.
Я советую тебе залечь на дно, пока шумиха не уляжется. 
Мы еще встретимся, я тебе позвоню.]] },
		},
	},

	positions = {
		player_start = Vector3{ x = -899.622, y = 1868.758, z = 10.769 },
		
		vehicle_main_spawn = Vector3{ x = -894.71, y = 1865.18, z = 9.85 },
		vehicle_main_spawn_rotation = Vector3( 0, 0, 137 ),

		office_target = Vector3( { x = 2232.495, y = 2616.677, z = 7.874 } ),

		random_parked_vehicle_spawns = {
			Vector3{ x = 2164.103, y = 2649.609, z = 7.575 },
			Vector3{ x = 2160.919, y = 2652.583, z = 7.576 },
			Vector3{ x = 2157.196, y = 2655.822, z = 7.576 },
			Vector3{ x = 2153.732, y = 2659.195, z = 7.573 },
			Vector3{ x = 2149.784, y = 2661.730, z = 7.573 },
		},
		random_vehicle_spawn_rotation = Vector3( 0, 0, 346.443 ),

		drive_camera = { 2202.7587890625, 2574.8337402344, 31.010938644409, 2159.7907714844, 2653.5556640625, -13.222687721252, 0, 70 },

		path_drive_to_office_parking = {
			{ x = 2232.495, y = 2616.677, z = 7.874 },
			{ x = 2195.977, y = 2607.734, z = 7.877 },
			{ x = 2178.461, y = 2624.229, z = 7.877 },
			{ x = 2175.596, y = 2637.076, z = 7.877 },
		},

		office_enter = { x = 2134.3813476563, y = 2600.1401367188, z = 9.42405128479 },
		office_enter_camera = { 2134.3813476563, 2600.1401367188, 8.42405128479, 2205.9665527344, 2669.9052734375, 6.5321769714355, 0, 70 },
		office_enter_camera_transition = { 2134.3813476563, 2600.1401367188, 8.42405128479, 2134.3813476563, 2600.1401367188, -9.42405128479, 0, 70 },

		interior_camera = { -103.48565673828, -2475.71484375, 4405.9392578125, -101.95265960693, -2375.7629394531, 4408.9311523438, 0, 70 },
		interior_player_spawn = Vector3{ x = -102.51, y = -2464.79, z = 4406.25 },
		interior_bot_spawn = Vector3{ x = -104.25, y = -2464.79, z = 4406.25 },
		interior_spawn_rotation = Vector3( 0, 0, 180 ),

		interior_player_go_to = { x = -102.431, y = -2477.254, z = 4406.265 },
		interior_bot_go_to = { x = -104.500, y = -2477.312, z = 4406.265 },

		path_bot = {
			{ x = 2495.972, y = 80.888, z = 60.763, move_type = 4, },
			{ x = 2500.296, y = 82.010, z = 62.299, move_type = 4, },
			{ x = 2504.386, y = 83.177, z = 63.270, move_type = 4, },
		},
	},
}

GEs = { }
SAVED_DATA = { }

QUEST_DATA = {
	id = "return_of_property",
	is_company_quest = true,

	title = "Возврат имущества",
	description = "У Ксюши серьезные проблемы, отказать ей в помощи точно не получится, слишком она хороша!",
	--replay_timeout = 5;

	CheckToStart = function( player )
		if player.interior ~= 0 or player.dimension ~= 0 then return end

		return true
	end,

	restart_position = Vector3( -880.7896, 1853.1967, 9.9950 ),

	quests_request = { "fast_delivery" },
	level_request = 10,

	OnAnyFinish = {
		client = function( player )
			localPlayer.alpha = 255
			if OLD_SKIN then
				localPlayer.model = OLD_SKIN
			end
		end,

		server = function( player )
			DestroyAllTemporaryVehicles( player )
			ExitLocalDimension( player )

			if player.interior ~= 0 then
				player.interior = 0
				player.position = QUEST_CONF.positions.player_start
			end
			player:TakeAllWeapons( true )

			if SAVED_DATA[ player ] and SAVED_DATA[ player ].armor then
				player.armor = SAVED_DATA[ player ].armor
			end
			SAVED_DATA[ player ] = nil
		end,
	},

	tasks = {
		[ 1 ] = {
			name = "Поговорить с Ксюшей",

			Setup = {
				client = function( )
					FindQuestNPC( "ksusha" ).ped.position = Vector3{ x = -901.96, y = 1870.3, z = 10.77 }
					FindQuestNPC( "ksusha" ).ped.rotation = Vector3{ 0, 0, 230 }

					CreateMarkerToCutscene( {
						position = FindQuestNPC( "ksusha" ).ped.position,
						dialog = QUEST_CONF.dialogs.start,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )

							localPlayer.position = QUEST_CONF.positions.player_start
							localPlayer.rotation = Vector3{ 0, 0, 50 }
							setCameraMatrix( -899.26580810547, 1866.7381591797, 11.480255126953, -954.07067871094, 1950.3693847656, 9.9837093353271, 0, 70 )

							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "ksusha" ).ped, nil, true )

							setTimerDialog( function( )
								CEs.dialog:next( )
								setTimerDialog( function( )
									fadeCamera( false, 1 )
									CEs.timer = setTimer( function( )
										triggerServerEvent( "return_of_property_step_1", localPlayer )
									end, 1000, 1 )
								end, 12000 )
							end, 14000 )
						end
					} )
				end,

				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 6531, positions.vehicle_main_spawn, positions.vehicle_main_spawn_rotation )
					player:SetPrivateData( "temp_vehicle", vehicle )
					vehicle:SetColor( 255, 0, 0 )
					vehicle:SetNumberPlate( "1:м555ур178" )
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "ksusha" ).ped )
				end,
			},

			event_end_name = "return_of_property_step_1",
		},

		[ 2 ] = {
			name = "Сесть в машину Ксюши",

			Setup = {
				client = function( )
					fadeCamera( true, 1 )
					
					HideNPCs( )
					GEs.ksusha = CreateAIPed( FindQuestNPC( "ksusha" ).model, Vector3{ x = -901.96, y = 1870.3, z = 10.77 }, 230 )
					LocalizeQuestElement( GEs.ksusha )
					SetUndamagable( GEs.ksusha, true )

					GEs.backpack = Object( 1449, 0, 0, 0 )
					LocalizeQuestElement( GEs.backpack )
					exports.bone_attach:attachElementToBone( GEs.backpack, GEs.ksusha, 3, 0, -0.08, 0.06, 0, 0, -5 )

					addEventHandler( "onClientPedWasted", GEs.ksusha, function( )
						FailCurrentQuest( "Ксюша погибла!" )
					end )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F или key=ENTER чтобы сесть на водительское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 370 or self.element.inWater then
								FailCurrentQuest( "Машина уничтожена!", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					local t = { }

					local function CheckBothInVehicle( )
						if localPlayer.vehicle and GEs.ksusha.vehicle then
							removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, t.OnStartEnter )
							removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, t.OnEnter )
							triggerServerEvent( "return_of_property_step_2", localPlayer )
						end
					end

					AddAIPedPatternInQueue( GEs.ksusha, AI_PED_PATTERN_VEHICLE_ENTER, {
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
							localPlayer:ShowError( localPlayer:GetGender( ) == 0 and "Ты ж джентельмен, сам отвези девушку" or "Ты ж джентельбаба, сама отвези девушку" )
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

			event_end_name = "return_of_property_step_2",
		},

		[ 3 ] = {
			name = "Попасть в офис",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					CEs.random_parked_vehicles = { }
					for i, position in pairs( positions.random_parked_vehicle_spawns ) do
						CEs.random_parked_vehicles[ i ] = createVehicle( 6601, position )
						CEs.random_parked_vehicles[ i ]:SetNumberPlate( "1:o" .. math.random( 111, 999 ) .. "оо199" )
						LocalizeQuestElement( CEs.random_parked_vehicles[ i ] )
					end

					CreateQuestPoint( { x = 2175.596, y = 2637.076, z = 7.877 }, function( self, player )
						CEs.marker.destroy( )

						StartQuestCutscene( )
						localPlayer.frozen = false

						CreateAIPed( localPlayer )
						
						FadeBlink( 1 )
						local vehicle = localPlayer.vehicle
						setCameraMatrix( vehicle.position + vehicle.matrix.forward * 5 + Vector3( 0, 0, 1.5 ), vehicle.position )

						vehicle.engineState = false
						vehicle.frozen = true

						for i, v in pairs( { localPlayer, GEs.ksusha } ) do
							AddAIPedPatternInQueue( v, AI_PED_PATTERN_VEHICLE_EXIT, { } )
							SetAIPedMoveByRoute( v, { positions.office_enter }, false )
						end

						-- Перешли дорогу
						CEs.timer = setTimer( function( )
							FadeBlink( 1 )
							setCameraMatrix( unpack( positions.office_enter_camera ) )

							-- За несколько метров время замедляется, а камера опускается на землю
							CEs.enter_col = createColSphere( Vector3{ x = 2138.935, y = 2605.803, z = 8.311 }, 3 )
							addEventHandler( "onClientColShapeHit", CEs.enter_col, function( element )
								if element ~= localPlayer and element ~= GEs.ksusha then return end
								setGameSpeed( 0.2 )
								fadeCamera( false, 0.5 )
								CameraFromTo( positions.office_enter_camera, positions.office_enter_camera_transition, 2000, "Linear", function( )
									triggerServerEvent( "return_of_property_step_3", localPlayer )
								end )
							end	)
						end, 5000, 1 )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle then
							return false, "Машину где забыл?"
						end
						return true
					end )
				end,
			},

			CleanUp = {
				client = function( )
					CleanupAIPedPatternQueue( localPlayer )
					removePedTask( localPlayer )
					CleanupAIPedPatternQueue( GEs.ksusha )
					removePedTask( GEs.ksusha )
					removePedFromVehicle( GEs.ksusha )
					setGameSpeed( 1 )
					-- ClearAIPed( localPlayer )
				end,

				server = function( player )
					removePedFromVehicle( player )
				end,
			},

			event_end_name = "return_of_property_step_3",
		},

		[ 4 ] = {
			name = "Захват",

			Setup = {
				client = function( )
					EnableCheckQuestDimension( true )
					
					local positions = QUEST_CONF.positions

					setCameraMatrix( unpack( positions.interior_camera ) )

					OLD_SKIN = localPlayer.model
					local raider_skin_model = localPlayer:GetGender( ) == 1 and 56 or 33
					localPlayer.model = raider_skin_model
					localPlayer.position = positions.interior_player_spawn
					localPlayer.rotation = positions.interior_spawn_rotation
					localPlayer.interior = 1

					GEs.ksusha.model = 56
					GEs.ksusha.position = positions.interior_bot_spawn
					GEs.ksusha.rotation = positions.interior_spawn_rotation
					givePedWeapon( GEs.ksusha, 24, 2000, true )
					LocalizeQuestElement( GEs.ksusha )
					GEs.backpack:destroy( )

					table.insert( CEs, WatchElementCondition( GEs.ksusha, {
						interval = 100,
						condition = function( self, conf )
							if not localPlayer:isStreamedIn( ) or not GEs.ksusha:isStreamedIn( ) then return end
							if localPlayer.model ~= raider_skin_model or GEs.ksusha.model ~= 56 then return end

							StartQuestCutscene( )
							localPlayer.frozen = false

							AddAIPedPatternInQueue( localPlayer, AI_PED_PATTERN_MOVE_TO_POINT, positions.interior_player_go_to )
							AddAIPedPatternInQueue( GEs.ksusha, AI_PED_PATTERN_MOVE_TO_POINT, positions.interior_bot_go_to )
		
							CEs.timer = setTimer( function( )
								playSound( "sfx/Sekretarsha3.wav" )
							end, 500, 1 )

							CEs.timer2 = setTimer( function( )
								fadeCamera( false, 2 )
								CEs.timer = setTimer( function( )
									triggerServerEvent( "return_of_property_step_4", localPlayer )
								end, 2000, 1 )
							end, 3000, 1 )
							
							return true
						end,
					} ) )

				end,

				server = function( player )
					SAVED_DATA[ player ] = {
						armor = player.armor
					}

					player.interior = 1
					player.armor = 100
					player:GiveWeapon( 22, 100, true, true )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					ClearAIPed( localPlayer )
					CleanupAIPedPatternQueue( localPlayer )
					removePedTask( localPlayer )
				end,
			},

			event_end_name = "return_of_property_step_4",
		},

		[ 5 ] = {
			name = "Найти кейс с документами",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					setCameraTarget( localPlayer )
					fadeCamera( true, 1 )
		
					GEs.secretary = CreateAIPed( 135, Vector3( { x = -102.79, y = -2478.82, z = 4406.26 } ) )
					LocalizeQuestElement( GEs.secretary )
					addEventHandler( "onClientElementStreamIn", GEs.secretary, function( )
						GEs.secretary:setAnimation( "ped", "handsup", -1, false, true, false, true )
					end )
		
					for i, position in pairs( {
						Vector3( { x = -97.289, y = -2486.751, z = 4406.265 } ),
						Vector3( { x = -94.529, y = -2487.022, z = 4406.265 } ),
						Vector3( { x = -103.325, y = -2486.618, z = 4406.265 } ),
					} ) do
						local guard = CreateAIPed( 1, position )
						GEs[ "guard_" .. i ] = guard
						LocalizeQuestElement( guard )
						givePedWeapon( guard, 24, 1000, true )
					end

					local is_guard_spotted = false

					-- Либо охранник выходит сам
					SetAIPedMoveByRoute( GEs.ksusha, {
						{ x = -108.487, y = -2477.573, z = 4406.265 },
						{ x = -104.118, y = -2478.894, z = 4406.265, wait_time = 1000 },
						{ x = -105.734, y = -2478.296, z = 4406.265, wait_time = 1000 },
					}, false, function( )
						if is_guard_spotted then return end
						SetAIPedMoveByRoute( GEs.ksusha, { { x = -104.025, y = -2475.538, z = 4406.265 } } ) -- { x = -97.245, y = -2477.382, z = 4406.265 }
						SetAIPedMoveByRoute( GEs[ "guard_1" ], { 
							-- { x = -97.106, y = -2480.406, z = 4406.272 }, 
							{ x = -97.130, y = -2477.910, z = 4406.265 },
						}, false, function( )
							if not isElement( CEs.detect_enter_col ) then return end
							triggerServerEvent( "return_of_property_step_5", localPlayer )
						end )
					end )

					-- Либо игрок забегает сразу к ним
					CEs.detect_enter_col = createColSphere( Vector3{ x = -97.083, y = -2481.117, z = 4406.272 }, 2 )
					addEventHandler( "onClientColShapeHit", CEs.detect_enter_col, function( element ) 
						if element ~= localPlayer then return end
						SetAIPedMoveByRoute( GEs.ksusha, {
							{ x = -104.025, y = -2475.538, z = 4406.265 },
							{ x = -97.245, y = -2477.382, z = 4406.265 },
							{ x = -97.117, y = -2481.315, z = 4406.272 },
						} )
						triggerServerEvent( "return_of_property_step_5", localPlayer )
						is_guard_spotted = true
					end )
				end,

				server = function( player )
					player.interior = 1
				end,
			},

			CleanUp = {
				client = function( )

				end,
			},

			event_end_name = "return_of_property_step_5",
		},

		[ 6 ] = {
			name = "Зачистить офис",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					SetUndamagable( GEs.ksusha, false )

					local last_hit_tick = getTickCount( )
					local protect_duration = 30000
					addEventHandler( "onClientPedDamage", GEs.ksusha, function( attacker, weapon, bodypart, loss )
						setTimer( function( )
							local reduce_ratio = math.max( 0, 1 - ( getTickCount( ) - last_hit_tick ) / protect_duration )
							GEs.ksusha.health = GEs.ksusha.health + loss * reduce_ratio
						end, 0, 1 )
					end )

					GEs.enemies = createElement( "quest_enemies" )
					addEventHandler( "onClientPedDamage", GEs.enemies, function( attacker )
						if attacker == localPlayer then
							last_hit_tick = getTickCount( )
						end
					end )

					for i = 1, 3 do
						local ped = GEs[ "guard_" .. i ]
						ped.parent = GEs.enemies

						GEs[ "guard_attack_" .. i ] = CreatePedAttackMultipleTargets( ped )
						GEs[ "guard_attack_" .. i ]:add_target( localPlayer )
						GEs[ "guard_attack_" .. i ]:add_target( GEs.ksusha )

						-- GEs[ "ksusha_attack" ]:add_target( ped )
					end

					AddAIPedPatternInQueue( GEs.ksusha, AI_PED_PATTERN_ATTACK_PED, {
						target_ped = GEs[ "guard_1" ];
						end_callback = {
							func = function( )
								local function KillNextGuard( )
									AddAIPedPatternInQueue( GEs.ksusha, AI_PED_PATTERN_ATTACK_PED, {
										target_ped = GEs[ "guard_2" ];
										end_callback = {
											func = function( )
												AddAIPedPatternInQueue( GEs.ksusha, AI_PED_PATTERN_ATTACK_PED, {
													target_ped = GEs[ "guard_3" ];
													end_callback = {
														func = function( )
															triggerServerEvent( "return_of_property_step_6", localPlayer )
														end,
													},
												} )
											end,
										}
									} )
								end
								if IsInFirstRoom( GEs.ksusha ) then
									SetAIPedMoveByRoute( GEs.ksusha, {
										{ x = -101.435, y = -2474.923, z = 4406.265 },
										{ x = -97.245, y = -2477.382, z = 4406.265 },
										{ x = -97.209, y = -2481.940, z = 4406.272 },
									}, false, KillNextGuard )
								else
									KillNextGuard( )
								end
							end,
						}
					} )

					CEs.siren_timer = setTimer( function( )
						GEs.siren_sound = playSound3D( "sfx/siren.mp3", Vector3{ x = -100.286, y = -2480.083, z = 4408.763 }, true )
						GEs.siren_sound.volume = 0.3
						GEs.siren_sound:setMaxDistance( 40 )
						LocalizeQuestElement( GEs.siren_sound )
					end, 5000, 1 )
				end,

				server = function( player )
				end,
			},

			CleanUp = {
				client = function( )

				end,
			},

			event_end_name = "return_of_property_step_6",
		},

		[ 7 ] = {
			name = "Найти кейс в офисе",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					if IsInFirstRoom( GEs.ksusha ) then
						SetAIPedMoveByRoute( GEs.ksusha, {
							{ x = -99.691, y = -2475.792, z = 4406.265 },
							{ x = -97.156, y = -2478.793, z = 4406.265 },
							{ x = -97.337, y = -2481.461, z = 4406.272 },
						} )
					end
					
					SetAIPedMoveByRoute( GEs.ksusha, {
						{ x = -95.227, y = -2481.464, z = 4406.272 },
						{ x = -91.830, y = -2481.362, z = 4406.272, wait_time = 1500 },
						{ x = -91.714, y = -2485.516, z = 4406.265, wait_time = 2000 },
						{ x = -93.267, y = -2485.294, z = 4406.265, wait_time = 3000 },
						{ x = -91.321, y = -2484.145, z = 4406.265, wait_time = 4000 },
						{ x = -92.880, y = -2481.940, z = 4406.272 },
						{ x = -110.780, y = -2483.683, z = 4406.265 },
						{ x = -113.385, y = -2487.309, z = 4406.265 },
						{ x = -115.091, y = -2486.181, z = 4406.265, wait_time = 3000 },
						{ x = -115.021, y = -2481.672, z = 4406.265 },
						{ x = -112.172, y = -2481.373, z = 4406.265 },
						{ x = -106.347, y = -2485.277, z = 4406.265 },
						{ x = -104.367, y = -2485.065, z = 4406.265 },
						{ x = -105.097, y = -2480.947, z = 4406.272 },
						{ x = -109.368, y = -2481.604, z = 4406.265, wait_time = 3000 },
						{ x = -109.368, y = -2481.604, z = 4406.265, wait_time = 5000 },
					}, false, function( )
						triggerServerEvent( "return_of_property_step_7", localPlayer )
					end )
				end,

				server = function( player )
				end,
			},

			CleanUp = {
				client = function( )

				end,
			},

			event_end_name = "return_of_property_step_7",
		},

		[ 8 ] = {
			name = "Забрать кейс",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					playSound( "sfx/Ksusha_phrase1.wav" )

					CreateQuestPoint( { x = -109.37, y = -2481.37, z = 4406.26 }, function( self, player )
						GEs.case_obj = createObject( 747, localPlayer.position )
						exports.bone_attach:attachElementToBone( GEs.case_obj, localPlayer, 11, -0.02, 0.002, 0.41, 175, 0, 85 )
						triggerServerEvent( "return_of_property_step_8", localPlayer )
					end, "case", 1 )
				end,

				server = function( player )
				end,
			},

			CleanUp = {
				client = function( )

				end,
			},

			event_end_name = "return_of_property_step_8",
		},

		[ 9 ] = {
			name = "Взять парашют",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					
					playSound( "sfx/Ksusha_phrase2.wav" )

					SetAIPedMoveByRoute( GEs.ksusha, { 
						{ x = -100.972, y = -2482.997, z = 4406.272 },
						{ x = -100.972, y = -2482.997, z = 4406.272 },
						{ x = -92.854, y = -2481.148, z = 4406.272 },
					}, false, function( )
						givePedWeapon( GEs.ksusha, 46, 1, true )
					end )

					for i, position in pairs( {
						{
							spawn = Vector3{ x = -102.464, y = -2464.243, z = 4406.249 },
							path = {
								{ x = -102.598, y = -2472.412, z = 4406.265 },
								{ x = -97.153, y = -2478.733, z = 4406.265 },
								{ x = -97.282, y = -2484.637, z = 4406.265 },
							},
						},
						{
							spawn = Vector3{ x = -104.158, y = -2464.276, z = 4406.249 },
							path = {
								{ x = -104.248, y = -2472.564, z = 4406.265 },
								{ x = -97.170, y = -2477.593, z = 4406.265 },
								{ x = -97.460, y = -2482.997, z = 4406.272 },
							},
						},
					} ) do
						local police = CreateAIPed( 125, position.spawn )
						police.rotation = Vector3( 0, 0, 180 )
						police.parent = GEs.enemies
						GEs[ "police_" .. i ] = police
						LocalizeQuestElement( police )
						givePedWeapon( police, 24, 1000, true )
						
						-- SetAIPedMoveByRoute( police, position.path, false, function( )
							GEs[ "police_attack" .. i ] = CreatePedAttackMultipleTargets( police )
							GEs[ "police_attack" .. i ]:add_target( localPlayer )
							GEs[ "police_attack" .. i ]:add_target( GEs.ksusha )
						-- end )
					end

					CreateQuestPoint( { x = -93.51, y = -2480.89, z = 4406.27 }, function( self, player )
						triggerServerEvent( "return_of_property_step_9", localPlayer )
					end, "case", 1 )
				end,

				server = function( player )
				end,
			},

			CleanUp = {
				client = function( )
				end,
			},

			event_end_name = "return_of_property_step_9",
		},

		[ 10 ] = {
			name = "Следовать за Ксюшей",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					GEs.ksusha.health = 100
					SetAIPedMoveByRoute( GEs.ksusha, { 
						{ x = -97.175, y = -2480.775, z = 4406.272 },
						{ x = -97.155, y = -2479.048, z = 4406.265 },
						{ x = -102.774, y = -2472.189, z = 4406.265 },
					}, false, function( )
						givePedWeapon( GEs.ksusha, 24, 1000, true )
						AddAIPedPatternInQueue( GEs.ksusha, AI_PED_PATTERN_ATTACK_PED, {
							target_ped = GEs[ "police_1" ];
							end_callback = {
								func = function( )
									AddAIPedPatternInQueue( GEs.ksusha, AI_PED_PATTERN_ATTACK_PED, {
										target_ped = GEs[ "police_2" ];
										end_callback = {
											func = function( )
												SetAIPedMoveByRoute( GEs.ksusha, {
													{ x = -103.356, y = -2464.062, z = 4406.249 },
												}, false, function( )

												end )
											end,
										},
									} )
								end,
							},
						} )
					end )

					CreateQuestPoint( { x = -103.356, y = -2464.062, z = 4406.249 }, function( self, player )
						fadeCamera( false, 0.5 )

						CEs.timer = setTimer( function( )
							triggerServerEvent( "return_of_property_step_10", localPlayer )
						end, 1000, 2 )
					end, "exit", 2 )
				end,

				server = function( player )
					player:GiveWeapon( 46, 1, true, true )
				end,
			},

			CleanUp = {
				client = function( )
				end,
			},

			event_end_name = "return_of_property_step_10",
		},

		[ 11 ] = {
			name = "Спрыгнуть с крыши",

			Setup = {
				client = function( )
					setElementAlpha( GEs.case_obj, 0 )

					local positions = QUEST_CONF.positions

					fadeCamera( true, 1 )
					StartQuestCutscene( )
					localPlayer.interior = 0
					localPlayer.position = Vector3{ x = 1702.788, y = 2665.733, z = 9.051 }

					setCameraMatrix( 2096.58203125, 2619.8137207031, 211.52677612305, 2139.9169921875, 2531.0737304688, 227.25275878906, 0, 70 )

					CEs.border_collision = createObject( 17292, Vector3{ x = 2104.548, y = 2607.517, z = 213.327 }, Vector3( 0, 90, 75 ) )
					CEs.border_collision.alpha = 0

					GEs.player_bot = CreateAIPed( localPlayer.model, Vector3{ x = 2119.140, y = 2607.312, z = 214.084 } )
					localPlayer.alpha = 0

					local t = {
						[ GEs.player_bot ] = {
							start = Vector3{ x = 2104.810, y = 2606.320, z = 214.447 },
							land = Vector3{ x = 1692.99, y = 2661.19, z = 8.56 },
						},

						[ GEs.ksusha ] = {
							start = Vector3{ x = 2105.133, y = 2607.745, z = 214.447 },
							land = Vector3{ x = 1693.87, y = 2659.24, z = 8.49 },
						},
					}
						
					local not_landed_peds = { }
					local parachuting_progress_offset = 0

					local start_offset = 0
					for ped, positions in pairs( t ) do
						not_landed_peds[ ped ] = true

						ped.position = positions.start
						ped.rotation = Vector3( 0, 0, 90 )
						CleanupAIPedPatternQueue( ped )
						removePedTask( ped )
						LocalizeQuestElement( ped )
						SetUndamagable( ped, true )
						givePedWeapon( ped, 46, 1, true )

						if not CEs[ ped ] then
							CEs[ ped ] = { }
						end

						camera_target_z = false

						CEs[ ped ].jump_timer = setTimer( function( )
							setPedControlState( ped, "jump", true )
							setTimer( setPedControlState, 500, 1, ped, "jump", false )

							CEs[ ped ].anim_timer = setTimer( function( )
								setPedAnimation( ped, "PARACHUTE", "FALL_skyDive", -1, true, true, false )	
							end, 700, 1 )

							CEs[ ped ].open_parachute_timer = setTimer( function( )
								triggerEvent( "doAddParachuteToPlayer", ped )

								CEs[ ped ].start_parachuting_timer = setTimer( function( )
									local start_position = ped.position
									local end_position = positions.land
									local direction = end_position - start_position
									local fly_duration = 50 * 1000
									local start_tick = getTickCount( )
			
									local function ProcessParachuting( )
										if not isElement( GEs.ksusha ) then
											removeEventHandler( "onClientRender", root, ProcessParachuting )
											return
										end

										local progress = parachuting_progress_offset + ( getTickCount( ) - start_tick ) / fly_duration
										if progress > 1 then
											removeEventHandler( "onClientRender", root, ProcessParachuting )
											ped.rotation = Vector3( 0, 0, 90 )
											progress = 1

											triggerEvent( "doRemoveParachuteFromPlayer", ped )

											not_landed_peds[ ped ] = nil
											if not next( not_landed_peds ) then
												CEs.timer = setTimer( function( )
													triggerServerEvent( "return_of_property_step_11", localPlayer )
												end, 3000, 1 )
											end
										end
								
										ped:setPosition( start_position + direction * progress, false )
										ped.velocity = Vector3( -0.001, 0, 0.001 )
									end
									addEventHandler( "onClientRender", root, ProcessParachuting )

									if ped == GEs.ksusha then
										CEs.fly_camera_timer = setTimer( function( )
											FadeBlink( )
											parachuting_progress_offset = 0.4
											local progress = parachuting_progress_offset + ( getTickCount( ) - start_tick ) / fly_duration + 0.07
											local camera_target = start_position + direction * progress
											setCameraMatrix( camera_target + GEs.ksusha.matrix.right * 50, camera_target, 0, 70 )

											CEs.land_camera_timer = setTimer( function( )
												FadeBlink( )
												parachuting_progress_offset = 0.8
												setCameraMatrix( 1688.4904785156, 2665.259765625, 8.7683067321777, 1771.6820068359, 2610.1545410156, 15.294298171997, 0, 70 )
											end, 4000, 1 )
										end, 1300, 1 )
									end
								end, 1000, 1 )
							end, 1000, 1 )
						end, 500 + start_offset, 1 )
						start_offset = start_offset + 500
					end
					
					GEs.moto = createVehicle( 522, Vector3{ x = 1686.43, y = 2651.15, z = 8.21 }, Vector3( 0, 0, 231 ) )
					GEs.moto:SetColor( 255, 0, 0 )
					GEs.moto:SetNumberPlate( "2:07892499" )
					LocalizeQuestElement( GEs.moto )
				end,

				server = function( player )
					player.interior = 0
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )

					local file = fileCreate( "q22.dat" )
					if file then
						local data = { }
						for i, ped in pairs( { GEs.secretary, GEs.guard_1, GEs.guard_2, GEs.guard_3, GEs.police_1, GEs.police_2 } ) do
							if ped.health < 30 then
								data[ i ] = { model = ped.model, position = { getElementPosition( ped ) }, rz = ped.rotation.z }
							end
						end
						file:write( toJSON( data ) )
						file:close( )
					end
				end,
			},

			event_end_name = "return_of_property_step_11",
		},

		[ 12 ] = {
			name = "Поговорить с Ксюшей",

			Setup = {
				client = function( )
					setElementAlpha( GEs.case_obj, 255 )

					local positions = QUEST_CONF.positions

					local player_position = GEs.player_bot.position + Vector3( 0, 0, 0.65 )
					CEs.FocusCameraOnKsusha = function( )
						local ksusha_position = GEs.ksusha.position
						ksusha_position.z = player_position.z
						setCameraMatrix( player_position, ksusha_position )
					end
					addEventHandler( "onClientRender", root, CEs.FocusCameraOnKsusha )

					StartQuestCutscene( {
						dialog = QUEST_CONF.dialogs.finish,
					} )
					CEs.dialog:next( )
					GEs.ksusha.rotation = Vector3( 0, 0, 32 )
					StartPedTalk( GEs.ksusha, nil, true )

					setTimerDialog( function( )
						exports.bone_attach:detachElementFromBone( localPlayer )
						exports.bone_attach:attachElementToBone( GEs.case_obj, GEs.ksusha, 12, 0.01, -0.012, 0.38, 180, 0, 75 )


						CEs.dialog:destroy_with_animation( )
						StopPedTalk( FindQuestNPC( "ksusha" ).ped )

						AddAIPedPatternInQueue( GEs.ksusha, AI_PED_PATTERN_VEHICLE_ENTER, {
							vehicle = GEs.moto;
							seat = 0;
							end_callback = {
								func = function()
									exports.bone_attach:detachElementFromBone( GEs.ksusha )
									destroyElement( GEs.case_obj )
								end;
							};
						} )

						SetAIPedMoveByRoute( GEs.ksusha, {
							{ x = 1712.970, y = 2625.224, z = 8.187 },
							{ x = 1718.248, y = 2615.986, z = 8.134 },
							{ x = 1720.817, y = 2542.219, z = 8.641 },
						}, false )

						CEs.timer = setTimer( function( )
							fadeCamera( false, 3 )
			
							CEs.timer = setTimer( function( )
								FinishQuestCutscene( )
								triggerServerEvent( "return_of_property_step_12", localPlayer )
							end, 3000, 1 )
						end, 4000, 1 )
					end, 11000 )
				end,

				server = function( player )
					
				end,
			},

			CleanUp = {
				client = function( )
					removeEventHandler( "onClientRender", root, CEs.FocusCameraOnKsusha )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "return_of_property_step_12",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Роман", msg = "Нас кто-то ограбил! Вот же... Приезжай за мной срочно!" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "unconscious_betrayal" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)

		player:InventoryAddItem( IN_REPAIRBOX, nil, 1 )
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				exp = 5500,
				money = 7000,
				repairbox = 1,
			}
		} )
	end,

	rewards = {
		exp = 5500,
		money = 7000,
		repairbox = 1,
	},

	no_show_rewards = true,
}