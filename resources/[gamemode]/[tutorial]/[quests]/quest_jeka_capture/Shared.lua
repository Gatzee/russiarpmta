QUEST_CONF = {
	dialogs = {
		main = {
			{ name = "Сотрудник ДПС", voice_line = "Cop_2_2", text = [[Слушай сюда, будешь делать, что мы велим... Ты ведь не хочешь знать, что будет иначе?! 
У нас серьёзная операция по отлову стритрейсеров. По нашим источникам 
гонки будут проходить в известном месте. Тебе нужно устроить засаду в указанной точке.
Времени мало, выдвигайся!]] },	
		},
		inspektor_finish = {
			{ name = "Сотрудник ДПС", voice_line = "Cop_2_3", text = [[Неплохо вышло! Попадешься еще раз... Сядешь!]] }
		},
		jeka_finish = {
			{ name = "Жека", voice_line = "Jeka_4", text = [[Привет, как ты? Получилось не дурно, но машину мою зачем разбивать было?!
Ладно, страховка часть покрыла, остальное прощаю. Ты все же мудака наказал.]] }
		},
	},
	
	positions = {
		dps_gorki_enter = Vector3( 2236.0390625, -641.59899902344, 61.584289550781 ),
		dps_gorki_leave = Vector3( 2194.8400878906, 214, 601.00872802734 ),
		
		vehicle_spawn = Vector3( 2199.189453125, -617.63761901855, 60.714462280273 ),
		vehicle_spawn_rotation = Vector3( 0, 0, 155 ),
		
		capture_start_point_vehicle = Vector3( 1677.9870605469, -608.26800537109, 58.56 ),
		capture_start_rotation_vehicle =Vector3( -0, 0, 203.79928588867 ),
		capture_start_point_player = Vector3( 1677.9870605469, -608.26800537109, 58.811588287354 ),

		put_stinger = Vector3( 1681.2025146484, -615.61502075195, 58.811588287354 ),

		stinger = 
		{
			{ position = Vector3( 1680.3421630859, 247.44651794434 - 860, 57.9 ), rotation = Vector3( -0, 0, 209.46073913574 ), },
			{ position = Vector3( 1682.1221923828, 243.93351745605 - 860, 57.9 ), rotation = Vector3( -0, 0, 209.46073913574 ), },
		},

		player_wait_crash = Vector3( 1674.7287597656, -601.8283996582, 58.637157440186 ),

		crash_first_camera_from = { 1691.2613525391, -593.83154296875, 68.522308349609, 1651.9926757813, -678.73782348633, 33.636325836182, 0, 70 },
		crash_first_camera_to = { 1691.2613525391, -593.83154296875, 68.522308349609, 1678.8747558594, -686.69288635254, 34.291316986084, 0, 70 },

		crash_second_camera_from = { 1723.4962158203, -587.46920776367, 69.429504394531, 1649.8948974609, -644.05374145508, 33.564228057861, 0, 70 },
		crash_second_camera_to = { 1723.4962158203, -587.46920776367, 69.429504394531, 1808.9543457031, -581.939453125, 17.902370452881, 0, 70 },

		crash_vehicle = Vector3( 1739.6671142578, -584.10403442383, 62.055633544922 ),
		
		crash_vehicle_player = Vector3( 1728.8377685547, -584.39157104492, 60.548500061035 ),
		crash_vehicle_player_rotation = Vector3( -0, 0, 357.4553527832 ),
	},
}

GEs = { }

QUEST_DATA = {
	id = "jeka_capture",
	is_company_quest = true,

	title = "Операция \"Перехват\"",
	description = "Выбора действительно нет, нужно помочь и не провалить операцию перехвата, иначе из этого дерьма не выбраться.",
	--replay_timeout = 5; 

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 2180.2763, -672.6102, 60.3927 ),

	quests_request = { "jeka_race" },
	level_request = 4,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			local vehicles_parked = ExitLocalDimension( player )
			if vehicles_parked then
				player:PhoneNotification( { title = "Эвакуация", msg = "Тебе доступна бесплатная эвакуация использованного в квесте транспорта!" } )
			end

			if player.interior ~= 0 then
				player.interior = 0
				player.position = Vector3( 2179.760, -692.095, 60.386 ):AddRandomRange( 3 )
			end
			
			DisableQuestEvacuation( player )
			player:TakeWeapon( 23 )
		end,
	},

	tasks = {
		{
			name = "Отправляйтесь в отделение ГИБДД",

			Setup = {
				client = function( )
					if localPlayer.dimension == 1 and localPlayer.interior == 1 then
						triggerServerEvent( "jeka_capture_step_1", localPlayer )
					else
						local positions = QUEST_CONF.positions

						CreateQuestPoint( positions.dps_gorki_enter, function( self, player )
							triggerServerEvent( "jeka_capture_step_1", localPlayer )
						end, _, 5, _, _, function( self, player )
							if localPlayer.vehicle then
								return false, "Выйди из транспорта чтобы зайти в ГИБДД"
							end
							return true
						end )
					end

				end,
			},

			event_end_name = "jeka_capture_step_1",
		},

		{
			name = "Поговорить с инспектором",

			Setup = {
				server = function( player )
					EnterLocalDimension( player )
					triggerEvent( "jeka_capture_step_intermediate", player )
				end
			},

			event_end_name = "jeka_capture_step_intermediate",
		},

		{
			name = "Поговорить с инспектором",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					localPlayer.position = positions.dps_gorki_leave
					localPlayer.interior = 1
					FadeBlink( )
					
					local positions = QUEST_CONF.positions
					CreateMarkerToCutsceneNPC( {
						id = "inspektor_dps",
						dialog = QUEST_CONF.dialogs.main,
						interior = 1,
						local_dimension = true,
						callback = function( )
							CEs.marker.destroy( )
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "inspektor_dps" ).ped, nil, true )

							setTimerDialog( function( )
								CEs.dialog:next()
								triggerServerEvent( "jeka_capture_step_2", localPlayer )
							end, 20000, 1 )
						end
					} )
				end,
				server = function( player )
					player.position = QUEST_CONF.positions.dps_gorki_leave
					player.interior = 1
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "inspektor_dps" ).ped )
				end,
			},

			event_end_name = "jeka_capture_step_2",
		},

		{
			name = "Покинь участок ГИБДД",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.dps_gorki_leave, function( self, player )
						triggerServerEvent( "jeka_capture_step_3", localPlayer )
					end, _, 2, _, _, _ )
				end,
			},

			event_end_name = "jeka_capture_step_3",
		},

		{
			name = "Садись в служебную машину",

			Setup = {
				client = function( )
					FadeBlink( )
					local positions = QUEST_CONF.positions

					localPlayer.position = positions.dps_gorki_enter

					CreateQuestPoint( positions.vehicle_spawn, function( self, player )
						CEs.marker.destroy( )
						
					end, _, 2, _, localPlayer:GetUniqueDimension() )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F или key=ENTER чтобы сесть в служебную машину",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					CEs.onEnterInDPSVehicle = function( theVehicle, seat )
						if theVehicle == localPlayer:getData( "temp_vehicle" ) and seat == 0 then
							removeEventHandler( "onClientPlayerVehicleEnter", root, CEs.onEnterInDPSVehicle )
							triggerServerEvent( "jeka_capture_step_4", localPlayer )
						end
					end
					addEventHandler( "onClientPlayerVehicleEnter", root, CEs.onEnterInDPSVehicle )
				end,
				server = function( player )
					local positions = QUEST_CONF.positions
					player.position = positions.dps_gorki_enter
					player.interior = 0
					
					EnableQuestEvacuation( player )
					EnterLocalDimensionForVehicles( player )

					local vehicle = CreateTemporaryVehicle( player, 420, QUEST_CONF.positions.vehicle_spawn, QUEST_CONF.positions.vehicle_spawn_rotation )

					vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_POLICE ) )
					vehicle:setColor( 255, 255, 255 )
					setVehiclePaintjob( vehicle, 0 )
					vehicle:SetFuel( "full" )

					triggerEvent( "SetupVehicleSirens", vehicle, vehicle )

					vehicle:SetExternalTuningValue( TUNING_SIREN, 2 )

					player:SetPrivateData( "temp_vehicle", vehicle )
				end
			},

			event_end_name = "jeka_capture_step_4",
		},

		{
			name = "Отправляйся к месту засады",

			Setup = {
				client = function( )
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					table.insert( GEs, WatchElementCondition( temp_vehicle, {
						condition = function( self, conf )
							if self.element.health <= 370 or self.element.inWater then
								FailCurrentQuest( "Служебная машина уничтожена!", "fail_destroy_vehicle" )
								return true
							elseif self.element:GetFuel( ) <= 0 then
								FailCurrentQuest( "Кончилось топливо!" )
								return true
							end
						end,
					} ) )

					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.capture_start_point_vehicle, function( self, player )
						CEs.marker.destroy( )
						
						local player_vehcile = localPlayer.vehicle
						player_vehcile:setEngineState( false )
						fadeCamera( false, 1.0 )
						addEventHandler( "onClientVehicleStartEnter", player_vehcile, cancelEvent )
						
						setTimer( function()
							setControlState( localPlayer, "enter_exit", true )
							localPlayer.position = positions.capture_start_point_player

							player_vehcile.position = positions.capture_start_point_vehicle
							player_vehcile.rotation = positions.capture_start_rotation_vehicle

							fadeCamera( true, 1.0 )
							triggerServerEvent( "jeka_capture_step_5", localPlayer )
						end, 1300, 1 )
					end, _, 2, _, _, function( self, player )
						if not localPlayer.vehicle then
							return false, "Как будешь ловить стритрейсера? На своих двоих?"
						end
						return true
					end )
				end,
			},

			event_end_name = "jeka_capture_step_5",
		},

		{
			name = "Арестуй гонщика",

			Setup = {
				client = function( )
					EnableCheckQuestDimension( true )
					
					CEs.stinger = {}
					local positions = QUEST_CONF.positions
					
					-- Ожидание попадания вхождения бота в зону шипов, прокалываем колеса
					CEs.colshape = ColShape.Sphere( Vector3( 1681.041015625, -614.31047058105, 58.811588287354 ), 3 )
					addEventHandler( "onClientColShapeHit", CEs.colshape, function( element, dimension )
						if element == GEs.enemy_car then
							setGameSpeed( 0.25 )

							CameraFromTo( positions.crash_first_camera_from, positions.crash_first_camera_to, 2000, "Linear", function( )
								setGameSpeed( 1 )
								fadeCamera( false, 0.15 )
								setTimer( function()
									fadeCamera( true, 0.15 )
									setCameraMatrix( unpack( positions.crash_second_camera_from ) )
									
									setTimer( function()
										ibSoundFX( "crash_auto" )
									end, 700, 1 )

									CameraFromTo( positions.crash_second_camera_from, positions.crash_second_camera_to, 1300, "InOutQuad", function( )
										GEs.enemy_car.frozen = true
										MoveCameraToLocalPlayer( 1.0, function( )
											FadeBlink( 1.0 )
											setCameraTarget( localPlayer )
											DisableHUD( false )
											localPlayer.frozen = false
										end )
									end )
								end, 200, 1 )
								
							end )

							setVehicleTurnVelocity( element, 0, 0, 0.02 )
							setVehicleWheelStates( element, 1, 1, 1, 1 )
						end
					end )

					-- Старт движения бота по маршруту
					CEs.StartMoveBot = function()
						local positions = QUEST_CONF.positions
						
						GEs.enemy_car = createVehicle( 600, Vector3( 0, 0, 1000 ), Vector3( 0, 0, 0 ) )
						LocalizeQuestElement( GEs.enemy_car )
						
						GEs.enemy_car.position = Vector3( 1514.2420654297, -687.3575592041, 37.521583557129 )
						GEs.enemy_car.rotation = Vector3( 0, 0, 283 )
						GEs.enemy_car.velocity = Vector3( 0.25, 0.25, 0 ) * 2
						
						GEs.bot_getaway = CreateAIPed( 54, GEs.enemy_car.position )
						addEventHandler( "onClientPedDamage", GEs.bot_getaway, cancelEvent )
						setElementCollidableWith( GEs.bot_getaway, localPlayer, false )

						LocalizeQuestElement( GEs.bot_getaway )
						
						warpPedIntoVehicle( GEs.bot_getaway, GEs.enemy_car )
						ResetAIPedPattern( GEs.bot_getaway )
						
						SetAIPedMoveByRoute( GEs.bot_getaway, {
							{ x = 1540.6157226563, y = 184.61869812012 - 860, z = 39.780155181885, speed_limit = 100, distance = 10 },
							{ x = 1585.7976074219, y = 207.31275939941 - 860, z = 43.020053863525, speed_limit = 100, distance = 10 },
							{ x = 1659.4047851563, y = 236.56907653809 - 860, z = 58.302715301514, speed_limit = 80, distance = 10 },
							{ x = 1721.1157226563, y = 267.79998779297 - 860, z = 60.156097412109, speed_limit = 70, distance = 10 },
							{ x = 1739.3977050781, y = 273.94247436523 - 860, z = 60.548500061035, speed_limit = 40, distance = 10 },
						}, false, function()
							setTimer( function()
								CEs.GetOutBot()
							end, 1000, 1 )
						end )

					end
					
					-- Подсказка шипов
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=ПКМ чтобы выставить шипы",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - positions.put_stinger ).length <= 2
						end
					} )

					-- Раскалдываем шипы
					CreateQuestPoint( positions.put_stinger, function( self, player )
						setSoundVolume( playSound( "files/sound/metall_.wav" ), 0.8 )
						CEs.marker.destroy( )
						CEs.hint:destroy()
						
						for k, v in pairs( positions.stinger ) do
							local obj = createObject( 2899, v.position, v.rotation )
							LocalizeQuestElement( obj )
							table.insert( CEs.stinger, obj )
						end
						
						-- Встаем в безопасную зону
						CreateQuestPoint( positions.player_wait_crash, function( self, player )
							CEs.marker.destroy( )
							CEs.hint:destroy()
							for k, v in pairs( positions.stinger ) do
								local obj = createObject( 2899, v.position, v.rotation )
								LocalizeQuestElement( obj )
								table.insert( CEs.stinger, obj )
							end

							DisableHUD( true )
							fadeCamera( false, 1.0 )
							setTimer( function()
								localPlayer.frozen = true
								fadeCamera( true, 1.0 )
								setCameraMatrix( unpack( positions.crash_first_camera_from ) )
							end, 1150, 1 )
							
							
							CEs.StartMoveBot()
						end, _, 2, _, _, _ )

					end, _, 2, _, _, _, "mouse2" )

					-- Подсказка как вытащить бота
					CEs.GetOutBot = function()
						CEs.hint = CreateSutiationalHint( {
							text = "Нажми key=TAB чтобы вытащить гонщика из машины",
							condition = function( )
								return isElement( GEs.enemy_car ) and ( localPlayer.position - GEs.enemy_car.position ).length <= 4
							end
						} )
						CreateQuestPoint( GEs.enemy_car.position, function( self, player )
						end, _, 3, _, _ )

					end
					
					-- Событие извлечения бота из тачки
					local t = { }
					t.OnExtractBotFromVehicle = function( )
						removeEventHandler( "onClientPlayerExtractVehicle", root, t.OnExtractBotFromVehicle )
						CEs.marker.destroy( )
						CEs.hint:destroy()

						for k, v in pairs( CEs.stinger ) do
							v:destroy()
						end
						
						-- Включаем возможность выстрела с тайзера
						setPedWeaponSlot( localPlayer, 2 )
						CEs.hint = CreateSutiationalHint( {
							text = "Используй key=ПКМ чтобы прицелиться и key=ЛКМ чтобы выстрелить тайзером",
							condition = function( )
								return ( localPlayer.position - GEs.bot_getaway.position ).length <= 4
							end
						} )
						addEventHandler( "onClientKey", root, t.OnShoot )				
					end
					addEventHandler( "onClientPlayerExtractVehicle", root, t.OnExtractBotFromVehicle )
					
					-- Событие выстрела по боту
					local keys = {}
					for i, v in pairs( getBoundKeys( "fire" ) ) do
						keys[ i ] = true
					end

					t.OnShoot = function( key, state )
						if not keys[ key ] or not state then return end

						local sx, sy, sz = getPedTargetStart(localPlayer)
						local tx, ty, tz = getPedTargetEnd(localPlayer)

						local hit, nx, ny, nz, element = processLineOfSight( sx, sy, sz, tx, ty, tz )
						if hit and element == GEs.bot_getaway and getDistanceBetweenPoints3D( sx, sy, sz, nx, ny, nz ) <= 10 then
							CEs.hint:destroy()
							removeEventHandler( "onClientKey", root, t.OnShoot )

							table.insert( t.pTaserShotsAround, 
							{
								started = getTickCount(),
								source = localPlayer,
								target = GEs.bot_getaway,
							})
							addEventHandler( "onClientRender", root, t.DrawTaserWires )

							playSound( ":nrp_factions_taser/files/sound/taser.mp3" )
							setPedAnimation( GEs.bot_getaway,  "crack", "crckidle" .. math.random( 1, 4 ), -1, true, false, false, false )
							
							
							-- Включаем возможность заключения в наручники
							CEs.hint = CreateSutiationalHint( {
								text = "Нажми key=TAB чтобы заковать наручники",
								condition = function( )
									return isElement( GEs.enemy_car ) and ( localPlayer.position - GEs.bot_getaway.position ).length <= 4
								end
							} )
							
							localPlayer:setData( "fake_handcuffs_enabled", true, false )
							addEventHandler( "onClientPlayerFakeHandcuff", root, t.OnHandcuff )		
						end
					end
					
					-- Событие заключения в наручники
					t.OnHandcuff = function( )
						CEs.hint:destroy()
						localPlayer:setData( "fake_handcuffs_enabled", false, false )
						removeEventHandler( "onClientPlayerFakeHandcuff", root, t.OnHandcuff )

						setElementCollidableWith( GEs.bot_getaway, localPlayer, true )
						triggerServerEvent( "jeka_capture_step_6", localPlayer )
					end

					t.pTaserShotsAround = {}
					t.iHitWiresBlinkDuration = 3000
					t.iMissWiresBlinkDuration = 1000
					t.pTaserBeamMaterial = dxCreateTexture( ":nrp_factions_taser/files/img/beam.png" )

					t.DrawTaserWires = function()
						if #t.pTaserShotsAround == 0 then
							removeEventHandler( "onClientRender", root, t.DrawTaserWires )
						end
					
						for i, shot in pairs( t.pTaserShotsAround ) do
							if getPedWeapon( localPlayer ) == 23 then
								if isElement( GEs.bot_getaway ) then
									local x,y,z = getPedWeaponMuzzlePosition( localPlayer )
									for i = 1, 3 do
										local vecRandBias = Vector3( math.random( 1, 3 ) / 10, math.random( 1, 3 ) / 10, math.random( 1, 3 ) / 10 )
										local tx, ty, tz = getPedBonePosition( GEs.bot_getaway, 2 )
										dxDrawMaterialLine3D( x,y,z, Vector3( tx, ty, tz ) + vecRandBias, t.pTaserBeamMaterial, 0.05 )
									end
					
									if getTickCount() - shot.started >= t.iHitWiresBlinkDuration then
										toggleControl( "aim_weapon", true )
										table.remove( t.pTaserShotsAround, i )
									end
								else
									if getTickCount() - shot.started >= t.iMissWiresBlinkDuration then
										table.remove( t.pTaserShotsAround, i )
									end
								end
							else
								table.remove( t.pTaserShotsAround, i )
							end
						end
					end

				end,
				server = function( player )
					player:GiveWeapon( 23, 100, false, true )
				end,
			},

			CleanUp = {
				client = function( )
					localPlayer:setData( "fake_handcuffs_enabled", nil, false )
					localPlayer.frozen = false
					DisableHUD( false )
					setGameSpeed( 1 )
				end,
			},
			event_end_name = "jeka_capture_step_6",
		},

		{
			name = "Отвези гонщика в ГИБДД",

			Setup = {
				client = function( )

					GEs.bot_getaway:setAnimation( nil, nil )
					GEs.follow = CreatePedFollow( GEs.bot_getaway )
					GEs.follow.same_vehicle = true
					GEs.follow:start( localPlayer )

					setPedWalkingStyle( GEs.bot_getaway, 118 )
					
					local style = 
					{
						idle = "idle_stance",
						sprint = { "sprint_panic", "run_civi",  },
						walk = {  "walk_civi", "walk_start", },
					}

					--engineLoadIFP( ":nrp_factions_handcuffs/files/ifp/next.ifp", "CUSTOM_BLOCK_AREST" )
					engineReplaceAnimation( GEs.bot_getaway, "ped", style.idle, "CUSTOM_BLOCK_AREST", "arest1" )
					for k, v in pairs( style.walk ) do
						engineReplaceAnimation( GEs.bot_getaway, "ped", v, "CUSTOM_BLOCK_AREST", "walk_arest" )
					end
					for k, v in pairs( style.sprint ) do
						engineReplaceAnimation( GEs.bot_getaway, "ped", v, "CUSTOM_BLOCK_AREST", "sprint_arest" )
					end

					local positions = QUEST_CONF.positions
					local t = {}
					t =
					{
						[ 1 ] = function()
							CreateQuestPoint( positions.vehicle_spawn, function( self, player )
								GEs.enemy_car:destroy()
								CEs.marker.destroy( )
								local vehicle = localPlayer:getData( "temp_vehicle" )
								vehicle.frozen = true 
								t:next()
							end, _, 2, _, _ )
						end,
						[ 2 ] = function()
							CreateQuestPoint( positions.dps_gorki_enter, function( self, player )
								CEs.marker.destroy( )
								GEs.follow:destroy( )
								
								fadeCamera( false, 1.0 )
								setTimer( function()
									localPlayer.position = positions.dps_gorki_leave
									localPlayer.interior = 1
									triggerServerEvent( "onPlayerUpdateInteriorRequest", localPlayer, 1 )
									
									GEs.bot_getaway.position = positions.dps_gorki_leave
									GEs.bot_getaway.interior = 1

									fadeCamera( true, 1.0 )
									t:next()
								end, 1150, 1 )
							end, _, 2, _, _, function( self, player )
								if localPlayer.vehicle then
									return false, "Выйди из транспорта чтобы зайти в ГИБДД"
								end
								return true
							end )
						end,
						[ 3 ] = function()
							GEs.follow = CreatePedFollow( GEs.bot_getaway )
							GEs.follow:start( localPlayer )

							CreateMarkerToCutsceneNPC( {
								id = "inspektor_dps",
								dialog = QUEST_CONF.dialogs.inspektor_finish,
								local_dimension = true,
								interior = 1,
								callback = function( )
									GEs.follow:destroy( )
									CEs.marker.destroy( )
									CEs.dialog:next( )
									StartPedTalk( FindQuestNPC( "inspektor_dps" ).ped )
									
									GEs.bot_getaway:destroy()
									setTimerDialog( function( )
										CEs.dialog:next()
										FinishQuestCutscene( )
										triggerServerEvent( "jeka_capture_step_7", localPlayer )
									end, 5500, 1 )
								end
							} )
						end,
					}

					t.next = function()
						t.t = (t.t or 0) + 1
						t[ t.t ]()
					end

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F или key=ENTER чтобы сесть в служебную машину",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )
					
					local vehicle = localPlayer:getData( "temp_vehicle" )
					removeEventHandler( "onClientVehicleStartEnter", vehicle, cancelEvent )

					CreateQuestPoint( positions.crash_vehicle_player, function( self, player ) end, _, 2, _, _ )

					t.onEnterInDPSVehicle = function( player, seat )
						if player == localPlayer and seat == 0 then
							removeEventHandler( "onClientVehicleEnter", root, t.onEnterInDPSVehicle )
							CEs.marker.destroy( )
							CEs.hint:destroy()
							t:next()
						end
					end
					addEventHandler( "onClientVehicleEnter", vehicle, t.onEnterInDPSVehicle )
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					if vehicle then
						local positions = QUEST_CONF.positions
						vehicle.position = positions.crash_vehicle_player
						vehicle.rotation = positions.crash_vehicle_player_rotation
					end
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "inspektor_dps" ).ped )
				end,
				server = function( player )
					DestroyAllTemporaryVehicles( player )
				end,
			},

			event_end_name = "jeka_capture_step_7",
		},

		{
			name = "Поговори с Жекой",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.dps_gorki_leave, function( self, player )
						CEs.marker.destroy( )

						fadeCamera( false, 1.0 )
						setTimer( function()
							localPlayer.position = positions.dps_gorki_enter
							localPlayer.interior = 0
							triggerServerEvent( "onPlayerUpdateInteriorRequest", localPlayer, 0 )

							fadeCamera( true, 1.0 )
							CreateMarkerToCutsceneNPC( {
								id = "jeka",
								dialog = QUEST_CONF.dialogs.jeka_finish,
								local_dimension = true,
								callback = function( )
									CEs.marker.destroy( )
									CEs.dialog:next( )
									StartPedTalk( FindQuestNPC( "jeka" ).ped, nil, true )
		
									setTimerDialog( function( )
										triggerServerEvent( "jeka_capture_step_8", localPlayer )
									end, 11000, 1 )
								end,
								check_func = function( self, player )
									if localPlayer.vehicle then
										return false, "Выйди из транспорта чтобы поговорить с Жекой"
									end
									return true
								end
							} )
						end, 1150, 1 )

					end, _, 2, _, _ )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "jeka" ).ped )
				end,
			},
			
			event_end_name = "jeka_capture_step_8",
		},

	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Анжела", msg = "Приветики, у нас тут тусовка намечается, приезжай повеселимся. Журнал квестов F2" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "angela_dance_school" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true
			}
		)
		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				money = 600,
				exp = 800,
			}
		} )
	end,

	rewards = {
		money = 600,
		exp = 800,
	},

	no_show_rewards = true,
}

function onPlayerUpdateInteriorRequest_handler( interior )
	client.interior = interior
end
addEvent( "onPlayerUpdateInteriorRequest", true )
addEventHandler( "onPlayerUpdateInteriorRequest", root, onPlayerUpdateInteriorRequest_handler )

addEvent( "onClientPlayerFakeHandcuff" )
addEvent( "onClientPlayerExtractVehicle" )