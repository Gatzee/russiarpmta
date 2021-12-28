QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Роман", voice_line = "Roman_22", text = [[Я не могу поверить, кто вообще осмелился на такое...
Хм... Картели!! Это точно какой-то из картелей!
Ты там спалился перед Восточным картелем? Охрененный из тебя актив вышел...
Нужно рассказать Александру, после офиса к нему поедем!]] },
		},
		office = {
			{ name = "Роман", voice_line = "Roman_23", text = [[Твою ж мать... Это просто месиво, тут явно не профи работали! 
И пропал только один кейс. Явно кто-то за ним охотился. 
Поехали к боссу, порешаем, что будем дальше делать.]] },
		},
		dialog = {
			{ name = "Александр", voice_line = "Alexandr_24a", text = [[Здравствуй.]] },
			{ name = "Роман", voice_line = "Roman_24a", text = [[Приветствую босс!]] },
			{ name = "Александр", voice_line = "Alexandr_24b", text = [[Дела наши скверны конечно, благо с ментами я уже решил проблему.
Меня эти 2 грабителя удивили, по записям видно, что любители, 
но такое месиво устраивать...]] },
			{ name = "Роман", voice_line = "Roman_24b", text = [[У Вас есть догадки, кто это мог быть? Кому такое в голову пришло?]] },
			{ name = "Александр", voice_line = "Alexandr_24c", text = [[Пока нет, а что-нибудь пропало из офиса?]] },
			{ name = "Роман", voice_line = "Roman_24c", text = [[Да, один только кейс с кодовым замком.]] },
			{ name = "Александр", voice_line = "Alexandr_24d", duration = 13, text = [[Интересно... Когда я узнал, что тебя ограбили я начал искать информацию. 
Еще до твоего прихода ко мне слухи вывели на Восточный картель. 
И пока я здесь, в безопасности, все равно продолжал собирать данные.]] },
			{ name = "Александр", duration = 16.5, text = [[И все что я смог нарыть о том деле лежало в кейсе, который пропал из моего офиса.
Кто-то очень сильно не хочет, чтобы ты докопался до правды!
Давай мы с тобой встретимся позже, тебе Роман напишет. 
А я пока про думаю наши дальнейшие шаги.]] },
		},
	},

	positions = {
		player_start = Vector3{ x = -78.920, y = 2142.373, z = 21.607 },
		interior_player_spawn = Vector3{ x = -102.51, y = -2464.79, z = 4406.25 },
		interior_bot_spawn = Vector3{ x = -104.25, y = -2464.79, z = 4406.25 },
		interior_spawn_rotation = Vector3( 0, 0, 180 ),
	},
}

GEs = { }

QUEST_DATA = {
	id = "unconscious_betrayal",
	is_company_quest = true,

	title = "Неосознанное предательство",
	description = "Ксения не такая простая, как казалось. И судя по всему это был офис Александра...",
	--replay_timeout = 5;

	CheckToStart = function( player )
		if player.interior ~= 0 or player.dimension ~= 0 then return end

		return true
	end,

	restart_position = Vector3( -83.4284, 2120.4079, 21.6073 ),

	quests_request = { "return_of_property" },
	level_request = 10,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			ExitLocalDimension( player )
			DisableQuestEvacuation( player )

			if player.interior ~= 0 then
				player.interior = 0
				player.position = QUEST_CONF.positions.player_start
			end
			player:TakeAllWeapons( true )
		end,
	},
	
	tasks = {
		[ 1 ] = {
			name = "Поговорить с Романом",

			Setup = {
				client = function( )
					HideNPCs( )

					GEs.roman = CreateAIPed( 6733, Vector3( { x = -81.54, y = 2142.21, z = 21.607 } ), 275 )
					SetUndamagable( GEs.roman, true )

					CreateMarkerToCutscene( {
						position = { x = -81.54, y = 2142.21, z = 21.61 },
						dialog = QUEST_CONF.dialogs.start,
						callback = function( )
							CEs.marker.destroy( )
							EnterLocalDimension( )
							LocalizeQuestElement( GEs.roman )

							setCameraMatrix( -77.033660888672, 2144.130859375, 22.045763015747, -162.66040039063, 2092.791015625, 16.364143371582, 0, 70 )
							localPlayer.position = QUEST_CONF.positions.player_start
							localPlayer.rotation = Vector3( 0, 0, 95 )

							CEs.dialog:next( )
							StartPedTalk( GEs.roman, nil, true )

							setTimerDialog( function( )
								triggerServerEvent( "unconscious_betrayal_step_1", localPlayer )
							end, 17000 )
						end,
						check_fn = function( )
							if localPlayer.vehicle then
								return false, "Выйди из транспорта чтобы продолжить"
							end
							return true
						end
					} )
				end,

				server = function( player )
					
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( GEs.roman )
				end,
			},

			event_end_name = "unconscious_betrayal_step_1",
		},

		[ 2 ] = {
			name = "Отвезти Романа в офис",

			Setup = {
				client = function( )
					CEs.follow = CreatePedFollow( GEs.roman )
					CEs.follow.same_vehicle = true
					CEs.follow:start( localPlayer )

					CEs.check_dist_timer = setTimer( function( )
						local dist = GEs.roman.position:distance( localPlayer.position )
						if dist > 50 then
							FailCurrentQuest( "Ты потерял Романа!" )
						elseif dist > 20 then
							localPlayer:ShowError( "Ты куда без Романа собрался?" )
						end
					end, 1000, 0 )

					CreateQuestPoint( { x = 2165.49, y = 2581.49, z = 8.07 }, function( )
						triggerServerEvent( "unconscious_betrayal_step_2", localPlayer )
					end, _, _, _, _, function( )
						if GEs.roman.position:distance( localPlayer.position ) > 10 then
							return false, "Где Роман?"
						end
						return true
					end )

					GEs.pps_vehicle1 = createVehicle( 420, Vector3{ x = 2146.51, y = 2574.15, z = 8.07 }, Vector3( 0, 0, 336 ) )
					-- GEs.pps_vehicle1.frozen = true
					GEs.pps_vehicle1.paintjob = 1
					GEs.pps_vehicle1:SetColor( 255, 255, 255 )
					GEs.pps_vehicle1:SetNumberPlate( "1:o563оо177" )
					LocalizeQuestElement( GEs.pps_vehicle1 )
					GEs.police2 = CreateAIPed( 125, Vector3{ x = 2146.72, y = 2584.42, z = 8.07 } )
					LocalizeQuestElement( GEs.police2 )
					CEs.ped_timer = setTimer( warpPedIntoVehicle, 500, 1, GEs.police2, GEs.pps_vehicle1 )

					GEs.pps_vehicle2 = createVehicle( 426, Vector3{ x = 2153.22, y = 2581.02, z = 8.07 }, Vector3( 0, 0, 70 ) )
					-- GEs.pps_vehicle2.frozen = true
					GEs.pps_vehicle2.paintjob = 1
					GEs.pps_vehicle2:SetColor( 255, 255, 255 )
					GEs.pps_vehicle2:SetNumberPlate( "1:o256оо177" )
					LocalizeQuestElement( GEs.pps_vehicle2 )

					GEs.pps_vehicle3 = createVehicle( 546, Vector3{ x = 2152.648, y = 2591.858, z = 8.072 } )
					-- GEs.pps_vehicle3.frozen = true
					GEs.pps_vehicle3.paintjob = 1
					GEs.pps_vehicle3:SetColor( 255, 255, 255 )
					GEs.pps_vehicle3:SetNumberPlate( "1:o618оо177" )
					LocalizeQuestElement( GEs.pps_vehicle3 )

					GEs.medic_vehicle = createVehicle( 416, Vector3{ x = 2143.410, y = 2591.720, z = 8.3 } )
					-- GEs.medic_vehicle.frozen = true
					GEs.medic_vehicle:SetColor( 255, 255, 255 )
					GEs.medic_vehicle:SetNumberPlate( "1:о870оо177" )
					LocalizeQuestElement( GEs.medic_vehicle )

					GEs.police = CreateAIPed( 125, Vector3{ x = 2146.72, y = 2584.42, z = 8.07 }, 257 )
					-- GEs.police.frozen = true
					LocalizeQuestElement( GEs.police )
					SetUndamagable( GEs.police, true )
				end,

				server = function( player )
					EnableQuestEvacuation( player )
					EnterLocalDimensionForVehicles( player )
				end
			},

			CleanUp = {
				client = function( )
					
				end,
			},

			event_end_name = "unconscious_betrayal_step_2",
		},

		[ 3 ] = {
			name = "Войти в офис",

			Setup = {
				client = function( )
					CEs.police_col = createColSphere( GEs.police.position, 5 )
					addEventHandler( "onClientColShapeHit", CEs.police_col, function( element )
						if element ~= GEs.roman then return end
						if GEs.police_sound then return end
						GEs.police_sound = playSound3D( "sfx/police.wav", GEs.police.position )
						LocalizeQuestElement( GEs.police_sound )
					end )

					if GEs.roman.vehicle then
						AddAIPedPatternInQueue( GEs.roman, AI_PED_PATTERN_VEHICLE_EXIT, { } )
					end
					SetAIPedMoveByRoute( GEs.roman, { 
						{ x = 2147.072, y = 2585.491, z = 8.072 }, 
						{ x = 2135.29, y = 2590.16, z = 7.31 },
					}, false )

					CreateQuestPoint( { x = 2135.29, y = 2590.16, z = 7.31 }, function( )
						fadeCamera( false, 0.5 )
						CEs.timer = setTimer( function( )
							triggerServerEvent( "unconscious_betrayal_step_3", localPlayer )
						end, 500, 1 )
					end )
				end,

				server = function( player )

				end
			},

			CleanUp = {
				client = function( )
					CleanupAIPedPatternQueue( GEs.roman )
					removePedTask( GEs.roman )
				end,
			},

			event_end_name = "unconscious_betrayal_step_3",
		},

		[ 4 ] = {
			name = "Катсцена в офисе",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateAIPed( localPlayer )
					localPlayer.position = positions.interior_player_spawn
					localPlayer.rotation = positions.interior_spawn_rotation
					localPlayer.interior = 1

					GEs.roman.position = positions.interior_bot_spawn
					GEs.roman.rotation = positions.interior_spawn_rotation
					LocalizeQuestElement( GEs.roman )

					local file = fileExists( ":quest_return_of_property/q22.dat" ) and fileOpen( ":quest_return_of_property/q22.dat", true )
					local data = file and fromJSON( file:read( file.size ) or "" ) or {
						{ model = 135, position = { x = -102.79 , y = -2478.82 , z = 4406.26  }, rz = 0   },
						{ model = 1  , position = { x = -97.289 , y = -2486.751, z = 4406.265 }, rz = 0   },
						{ model = 1  , position = { x = -94.529 , y = -2487.022, z = 4406.265 }, rz = 0   },
						{ model = 1  , position = { x = -103.325, y = -2486.618, z = 4406.265 }, rz = 0   },
						{ model = 125, position = { x = -102.464, y = -2464.243, z = 4406.249 }, rz = 180 },
						{ model = 125, position = { x = -104.158, y = -2464.276, z = 4406.249 }, rz = 180 },
					}
					if file then fileClose( file ) end

					for i, ped_data in pairs( data ) do
						CEs[ "ped_" .. i ] = createPed( ped_data.model, Vector3( ped_data.position ), ped_data.rz )
						CEs[ "ped_" .. i ].health = 0
						CEs[ "ped_" .. i ].frozen = true
						LocalizeQuestElement( CEs[ "ped_" .. i ] )
					end
					
					table.insert( CEs, WatchElementCondition( GEs.roman, {
						interval = 100,
						condition = function( self, conf )
							if not localPlayer:isStreamedIn( ) or not GEs.roman:isStreamedIn( ) then return end
							localPlayer.frozen = false
							fadeCamera( true, 1 )

							local camera = getCamera( )
							local camera_position = Vector3{ -103.6148147583, -2477.4904785156, 4406.9321289063 }
							local camera_rotation = Vector3{ 356.923, 0, 0 }
							CEs.focus_camera_timer = setTimer( function( )
								local roman_position = GEs.roman.position
								camera_rotation.z = FindRotation( camera_position.x, camera_position.y, roman_position.x, roman_position.y )
								camera.position = camera_position
								camera.rotation = camera_rotation
							end, 0, 0 )

							SetAIPedMoveByRoute( localPlayer, { { x = -103.6, y = -2475.25, z = 4405.26 } } )
							SetAIPedMoveByRoute( GEs.roman, {
								{ x = -103.6, y = -2475.25, z = 4405.26 },
								{ x = -97.71, y = -2475.3, z = 4405.26 },
								{ x = -97.28, y = -2481.71, z = 4405.27 },
							}, false, function( )

								camera_position = Vector3{ -98.460975646973, -2487.9987792969, 4407.193359375 }

								SetAIPedMoveByRoute( GEs.roman, {
									{ x = -91.96, y = -2481.54, z = 4405.27 },
									{ x = -91.73, y = -2485.1, z = 4405.26 },
									{ x = -91.96, y = -2481.54, z = 4405.27, wait_time = 1000 },
									{ x = -97.42, y = -2483.03, z = 4405.27 },
								}, false, function( )

									localPlayer.position = Vector3{ x = -97.135, y = -2478.563, z = 4406.265 }
									SetAIPedMoveByRoute( localPlayer, { { x = -97.28, y = -2481.71, z = 4405.27 } } )
	
									SetAIPedMoveByRoute( GEs.roman, {
										{ x = -108.75, y = -2481.89, z = 4405.26 },
										{ x = -100.524, y = -2483.532, z = 4406.272, wait_time = 1500 },
										{ x = -98.406, y = -2482.668, z = 4406.272 },
									}, false, function( )
										CEs.focus_camera_timer:destroy( )
										FadeBlink( )
										setCameraMatrix(  -94.784973144531, -2481.7985839844, 4406.61328125, -194.42401123047, -2489.5893554688, 4409.9848632813, 0, 70 )

										GEs.roman.position = Vector3{ x = -98.509, y = -2483.518, z = 4406.272 }
										GEs.roman.rotation = Vector3{ x = 0.000, y = 0.000, z = 334.247 }
										
										StartQuestCutscene( {
											dialog = QUEST_CONF.dialogs.office,
										} )
										
										CEs.dialog:next( )
										StartPedTalk( GEs.roman, nil, true )
					
										setTimerDialog( function( )
											CEs.dialog:destroy_with_animation( )
											
											fadeCamera( false, 0.5 )
											CEs.timer = setTimer( function( )
												triggerServerEvent( "unconscious_betrayal_step_4", localPlayer )
											end, 500, 1 )
										end, 12000, 1 )
									end )
								end )
							end )
							
							return true
						end,
					} ) )
				end,

				server = function( player )
					player.interior = 1
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( GEs.roman )
					ClearAIPed( localPlayer )
					removePedTask( localPlayer )
					CleanupAIPedPatternQueue( GEs.roman )
					removePedTask( GEs.roman )
				end,
			},

			event_end_name = "unconscious_betrayal_step_4",
		},

		[ 5 ] = {
			name = "Приехать к Александру",

			Setup = {
				client = function( )
					fadeCamera( true, 1 )

					localPlayer.position = Vector3{ x = 2134.826, y = 2588.735, z = 8.313 }
					localPlayer.rotation = Vector3( 0, 0, 257 )
					localPlayer.interior = 0

					GEs.roman.position = Vector3{ x = 2135.29, y = 2590.16, z = 8.31 }
					GEs.roman.rotation = Vector3( 0, 0, 257 )
					LocalizeQuestElement( GEs.roman )
					
					CEs.follow = CreatePedFollow( GEs.roman )
					CEs.follow.same_vehicle = true
					CEs.follow:start( localPlayer )

					CEs.check_dist_timer = setTimer( function( )
						local dist = GEs.roman.position:distance( localPlayer.position )
						if dist > 50 then
							FailCurrentQuest( "Ты потерял Романа!" )
						elseif dist > 20 then
							localPlayer:ShowError( "Ты куда без Романа собрался?" )
						end
					end, 1000, 0 )
					
					for name, data in pairs( {
						alexander = { x = 1310.26, y = -753.42, z = 19.17, rz = 270, model = FindQuestNPC( "alexander" ).model },
						guard_1   = { x = 1294.73, y = -839.41, z = 14.88, rz = 180 },
						guard_2   = { x = 1274.21, y = -782.6,  z = 15.43, rz = 210 },
						guard_3   = { x = 1305.03, y = -759.49, z = 14.97, rz = 138 },
					} ) do
						GEs[ name ] = CreateAIPed( data.model or 10, Vector3( data ), data.rz )
						GEs[ name ].frozen = true
						LocalizeQuestElement( GEs[ name ] )
						SetUndamagable( GEs[ name ], true )
					end

					CEs.gate_1 = createObject( 10856, Vector3{ x = 1287.5,  y = -837.45, z = 15.42 }, Vector3( 0, 0, 180 ) )
					LocalizeQuestElement( CEs.gate_1 )
					CEs.gate_2 = createObject( 10856, Vector3{ x = 1293.95, y = -837.45, z = 15.42 } )
					LocalizeQuestElement( CEs.gate_2 )

					CEs.gates_open_col = createColSphere( Vector3{ x = 1291.422, y = -850.512, z = 14.916 }, 18 )
					addEventHandler( "onClientColShapeHit", CEs.gates_open_col, function( element )
						if element ~= localPlayer then return end
						CEs.gate_1:move( 2500, CEs.gate_1.position, 0, 0, -110 )
						CEs.gate_2:move( 2500, CEs.gate_2.position, 0, 0, 110 )
					end )

					CreateQuestPoint( { x = 1290.810, y = -838.495, z = 14.792 }, function( self )
						self:destroy( )
						CreateQuestPoint( { x = 1304.24, y = -715.88, z = 13.97 }, function( )
							fadeCamera( false, 0.5 )
							CEs.timer = setTimer( function( )
								triggerServerEvent( "unconscious_betrayal_step_5", localPlayer )
							end, 500, 1 )
						end, _, _, _, _, function( )
							if GEs.roman.position:distance( localPlayer.position ) > 10 then
								return false, "Где Роман?"
							end
							return true
						end )
					end )
				end,

				server = function( player )
					player.interior = 0
				end
			},

			CleanUp = {
				client = function( )
					GEs.roman:removeFromVehicle( )
				end,
				server = function( player )
					player:removeFromVehicle( )
				end,
			},

			event_end_name = "unconscious_betrayal_step_5",
		},

		[ 6 ] = {
			name = "Поговорить с Александром",

			Setup = {
				client = function( )
					localPlayer.position = Vector3{ x = 1312.45, y = -752.92, z = 19.17 }
					localPlayer.rotation = Vector3( 0, 0, 90 )

					GEs.roman.position = Vector3{ x = 1311.79, y = -754.66, z = 19.17 }
					GEs.roman.rotation = Vector3( 0, 0, 50 )

					StartQuestCutscene( {
						dialog = QUEST_CONF.dialogs.dialog,
					} )

					setCameraMatrix( 1312.5955810547, -750.62554931641, 19.91495513916, 1270.8878173828, -841.44415283203, 16.38828086853, 0, 70 )

					local bot_by_name = {
						[ "Александр" ] = GEs.alexander,
						[ "Роман" ] = GEs.roman,
					}

					CEs.dialog.auto = true
					CEs.dialog:start( 500 )
					CEs.dialog.next_callback = function( self, previous, next )
						if previous then
							StopPedTalk( bot_by_name[ previous.name ] )
						end
						StartPedTalk( bot_by_name[ next.name ], nil, true )
					end
					CEs.dialog.end_callback = function( )
						triggerServerEvent( "unconscious_betrayal_step_6", localPlayer )
					end
				end,

				server = function( player )
					
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( GEs.roman )
					StopPedTalk( GEs.alexander )
				end,
			},

			event_end_name = "unconscious_betrayal_step_6",
		},

		[ 7 ] = {
			name = "Покинуть территорию",

			Setup = {
				client = function( )
					CreateQuestPoint( { x = 1291.270, y = -845.470, z = 14.918 }, function( )
						triggerServerEvent( "unconscious_betrayal_step_7", localPlayer )
					end )
				end,

				server = function( player )
					
				end
			},

			CleanUp = {
				client = function( )

				end,
			},

			event_end_name = "unconscious_betrayal_step_7",
		},
	},

	GiveReward = function( player )
		SendQuest23Invite( player )
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				money = 6500,
				exp = 4500,
				premium = 3,
			}
		} )
		player:GivePremiumExpirationTime( 3, "quest_unconscious_betrayal" )
	end,

	rewards = {
		money = 6500,
		exp = 4500,
		premium = 3,
	},

	no_show_rewards = true,
}