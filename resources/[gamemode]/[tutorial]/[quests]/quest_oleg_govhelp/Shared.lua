QUEST_CONF = {
	dialogs = {
		main = {
			{ name = "Олег", voice_line = "Oleg_3", text = "Привет, слушай тут такое дело, попал в ужасную историю по глупости.\nУстал честным трудом заниматься называется. Теперь полиция с шеи не слезает,\nа доказать не может ничего. Помоги решить проблему." },
		},
		inspector = {
			{ name = "Инспектор", voice_line = "Cop_1_2", text = [[Здравия желаю! О, давно тебя не было. Просто так ты явно не зайдешь, из-за Олега тут?
И не надоело тебе его прикрывать?! Ладно по старому знакомству есть способ решить]] },
			{ name = "Инспектор", text = [[эту проблему. У нас вор-домушник появился, ловкий зараза.
Приведешь его сюда, отстанем от Олега. Держи тайзер и наручники,
голыми руками его точно не схватить! А и служебную машину возьми.]] }
		},
		inspector_finish = {
			{ name = "Инспектор", voice_line = "Cop_1_3", text = "Серьёзно? Мы тут всем отделом...\nЛадно, сдержу слово. Олега больше не будем дергать." }
		},
		finish = {
			{ name = "Олег", voice_line = "Oleg_4", text = "Они отменили сегодня встречу! Твоя работа?! Благодарю. Буду должен!\nУ меня заказ новый пришел на работы. Приходи как освободишься!" },
		},
	},

	positions = {
		pps_marker = Vector3( 1944.296875, -736.14944458008, 60.776985168457 ),

		in_pps = Vector3( 1954.4567871094, 125.52043914795, 631.42138671875 ),

		inspector_talk = Vector3( 1954.517578125, 130.48738098145, 631.42138671875 ),
		inspector_talk_rotation = Vector3( 0, 0, 357.40441894531 ),
		inspector_talk_matrix = { 1952.7899169922, 129.49255371094, 631.94952392578, 2014.9039306641, 207.46253967285, 624.04138183594, 0, 70 },

		vehicle_spawn = Vector3( 1932.7414550781, -715.31834411621, 60.591373443604 ),
		vehicle_spawn_rotation = Vector3( 359.34188842773, 359.97985839844, 62.807861328125 ),

		park_position = Vector3( 2229.9252929688, -1187.20590209961, 60.526672363281 ),

		enemy_vehicle = Vector3( 2255.3081054688, -1132.5475769043, 60.263618469238 ),
		enemy_vehicle_rotation = Vector3( 359.20397949219, 359.98602294922, 339.32894897461 ),
		enemy_spawn_position = Vector3( 2269.1267089844, -1136.63931274414, 60.761199951172 ),
		enemy_matrix = { 2249.005859375, -1139.02340698242, 60.21142578125, 2338.4313964844, -1094.29641723633, 61.818420410156, 0, 70 },

		run_veh_path = {
			{ x = 2266.1008, y = -1102.229, z = 60.2013, speed_limit = 200, distance = 20 },
			{ x = 2264.4187, y = -1087.471, z = 60.2242, speed_limit = 200, distance = 20 },
			{ x = 2257.8173, y = -1073.370, z = 60.2572, speed_limit = 200, distance = 20 },
			{ x = 2250.8857, y = -1059.199, z = 60.2169, speed_limit = 200, distance = 20 },
			{ x = 2243.6135, y = -1045.064, z = 60.2187, speed_limit = 200, distance = 20 },
			{ x = 2236.6066, y = -1031.051, z = 60.1955, speed_limit = 200, distance = 20 },
			{ x = 2229.2971, y = -1016.482, z = 60.2040, speed_limit = 200, distance = 20 },
			{ x = 2222.1892, y = -1002.347, z = 60.2147, speed_limit = 200, distance = 20 },
			{ x = 2214.9621, y = -987.9763, z = 60.2243, speed_limit = 200, distance = 20 },
			{ x = 2207.3911, y = -972.9198, z = 60.2242, speed_limit = 200, distance = 20 },
			{ x = 2200.2575, y = -958.7607, z = 60.2207, speed_limit = 200, distance = 20 },
			{ x = 2193.1723, y = -944.6842, z = 60.2021, speed_limit = 200, distance = 20 },
			{ x = 2185.9191, y = -930.2901, z = 60.2003, speed_limit = 200, distance = 20 },
			{ x = 2178.2875, y = -914.4975, z = 60.1932, speed_limit = 200, distance = 20 },
			{ x = 2172.3349, y = -898.1991, z = 60.2395, speed_limit = 200, distance = 20 },
			{ x = 2169.4968, y = -881.7801, z = 60.3013, speed_limit = 200, distance = 20 },
			{ x = 2169.7062, y = -866.3473, z = 60.3020, speed_limit = 200, distance = 20 },
			{ x = 2169.8273, y = -850.2208, z = 60.3078, speed_limit = 200, distance = 20 },
			{ x = 2166.5283, y = -834.0448, z = 60.3086, speed_limit = 200, distance = 20 },
			{ x = 2159.5322, y = -818.4989, z = 60.3077, speed_limit = 200, distance = 20 },
			{ x = 2149.1723, y = -804.3378, z = 60.2988, speed_limit = 200, distance = 20 },
			{ x = 2138.2504, y = -791.6384, z = 60.3038, speed_limit = 200, distance = 20 },
			{ x = 2127.9294, y = -779.6223, z = 60.2934, speed_limit = 100, distance = 20 },
			{ x = 2117.7126, y = -767.5985, z = 60.2961, speed_limit = 80,  distance = 20 },
			{ x = 2107.2714, y = -755.3112, z = 60.2965, speed_limit = 70,  distance = 20 },
			{ x = 2096.9155, y = -743.0161, z = 60.2995, speed_limit = 40,  distance = 20 },
			{ x = 2086.4492, y = -730.4477, z = 60.3005, speed_limit = 30,  distance = 20 },
			{ x = 2076.3593, y = -718.3950, z = 60.3033, speed_limit = 30,  distance = 20 },
			{ x = 2061.6184, y = -718.4182, z = 60.4611, speed_limit = 30,  distance = 20 },
			{ x = 2055.5254, y = -723.0951, z = 60.4586, speed_limit = 30,  distance = 20 },
			{ x = 2048.8254, y = -727.3951, z = 60.4586, speed_limit = 30,  distance = 20 },
			{ x = 2043.3254, y = -732.3951, z = 60.4586, speed_limit = 30,  distance = 20 },
			{ x = 2036.9051, y = -737.4486, z = 60.4584, speed_limit = 30,  distance = 20 },
			{ x = 2018.6469, y = -755.1194, z = 60.4583, speed_limit = 50,  distance = 20 },
			{ x = 2009.3525, y = -767.4905, z = 60.4585, speed_limit = 60,  distance = 20 },
			{ x = 2004.0294, y = -782.1407, z = 60.4585, speed_limit = 60,  distance = 20 },
		},

		run_path = {
			{ x = 2022.338, y = 58.773 - 860, z = 61.625 },
			{ x = 2029.238, y = 52.944 - 860, z = 62.621 },
			{ x = 2039.678, y = 48.338 - 860, z = 62.621 },
			{ x = 2047.039, y = 40.804 - 860, z = 67.607 },
			{ x = 2064.577, y = 58.823 - 860, z = 67.614 },
			{ x = 2071.646, y = 65.637 - 860, z = 72.621 },
			{ x = 2089.277, y = 77.993 - 860, z = 72.621 },
		},

		jail_marker = Vector3( 1933.9536132813, 128.36901855469, 631.42828369141 ),

		bot_in_jail = Vector3( 1930.9616699219, 128.36250305176, 631.42138671875 ),
		bot_in_jail_rotation = Vector3( 0, 0, 269.69146728516 ),
	}
}

GEs = { }

QUEST_DATA = {
	id = "oleg_govhelp",
	is_company_quest = true,

	title = "Гос. помощь",
	description = "Олег опять со своими проблемами, но если ему помочь, он станет мне должен, а это всегда может пригодиться.",
	--replay_timeout = 5;

	CheckToStart = function( player )
		return player.interior == 0 and player.dimension == 0
	end,

	restart_position = Vector3( 1897.0811, -791.2454, 60.7066 ),

	quests_request = { "angela_risks" },
	level_request = 3,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			ExitLocalDimension( player )

			if player.interior ~= 0 then
				player.interior = 0
				player.position = Vector3( 1895.2722167969, -788.680854797363, 60.706672668457 ):AddRandomRange( 3 )
			end

			player:TakeWeapon( 23 )
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
								triggerServerEvent( "oleg_govhelp_step_1", localPlayer )
							end, 14000, 1 )
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

			event_end_name = "oleg_govhelp_step_1",
		},

		{
			name = "Зайти в ППС",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.pps_marker, function( self, player )
						localPlayer.interior = 1
						localPlayer.position = positions.in_pps
						CEs.marker.destroy( )
						triggerServerEvent( "oleg_govhelp_step_2", localPlayer )
					end,
					_, _, _, localPlayer:GetUniqueDimension( ),
					function( )
						if localPlayer.vehicle then
							return false, "Выйди из транспорта"
						end
						return true
					end )
				end,
			},

			event_end_name = "oleg_govhelp_step_2",
		},

		{
			name = "Поговорить с инспектором",

			Setup = {
				client = function( )
					FadeBlink( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.inspector_talk, function( self, player )
						CEs.marker.destroy( )
						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.inspector } )
						localPlayer.position = positions.inspector_talk
						localPlayer.rotation = positions.inspector_talk_rotation

						setCameraMatrix( unpack( positions.inspector_talk_matrix ) )
						CEs.dialog:next( )
						
						StartPedTalk( FindQuestNPC( "inspector_pps" ).ped, nil, true )
						setTimerDialog( function( )
							CEs.dialog:next( )
							setTimerDialog( function( )
								triggerServerEvent( "oleg_govhelp_step_3", localPlayer )
							end, 14000, 1 )
						end, 12000, 1 )
					end, _, 2 )
				end,
				server = function( player )
					player.interior = 1
				end,
			},

			CleanUp = {
				client = function( )
					StopPedTalk( FindQuestNPC( "inspector_pps" ).ped )
					FinishQuestCutscene( )
				end
			},

			event_end_name = "oleg_govhelp_step_3",
		},

		{
			name = "Покинуть здание ППС",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.in_pps, function( self, player )
						CEs.marker.destroy( )

						localPlayer.interior = 0
						localPlayer.position = positions.pps_marker
						triggerServerEvent( "oleg_govhelp_step_4", localPlayer )
					end, _, 1 )
				end,
				server = function( player )
					local positions = QUEST_CONF.positions
					local vehicle = CreateTemporaryVehicle( player, 426, positions.vehicle_spawn, positions.vehicle_spawn_rotation )
					vehicle.paintjob = 1
					vehicle:SetColor( 255, 255, 255 )
					player:SetPrivateData( "temp_vehicle", vehicle )
					vehicle:SetColor( 255, 255, 255 )
					vehicle:SetStatic( true )

					triggerEvent( "SetupVehicleSirens", vehicle, vehicle )
					vehicle:SetExternalTuningValue( TUNING_SIREN , 2 )
				end,
			},

			event_end_name = "oleg_govhelp_step_4",
		},

		{
			name = "Сесть в служебную машину",

			Setup = {
				client = function( )
					FadeBlink( )
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=F или key=ENTER чтобы сесть на водительское место",
						condition = function( )
							local vehicle = localPlayer:getData( "temp_vehicle" )
							return isElement( vehicle ) and ( localPlayer.position - vehicle.position ).length <= 4
						end
					} )

					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.vehicle_spawn, function( ) end, _, 2, _, _,
						function( )
							return false
						end
					)

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

					GEs.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat ~= 0 then
							cancelEvent( )
							localPlayer:ShowError( "Как ты собрался помогать на пассажирском месте?" )
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, GEs.OnStartEnter )

					GEs.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						triggerServerEvent( "oleg_govhelp_step_5", localPlayer )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.OnEnter )

					GEs.vehicle = createVehicle( 426, positions.enemy_vehicle )
					GEs.vehicle.rotation = positions.enemy_vehicle_rotation
					LocalizeQuestElement( GEs.vehicle )
					GEs.vehicle.frozen = true
				end,
				server = function( player )
					player.interior = 0
				end,
			},

			CleanUp = {
				client = function( )
					removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.OnEnter )

					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					if isElement( temp_vehicle ) and GEs.OnStartEnter then
						removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, GEs.OnStartEnter )
					end
				end
			},

			event_end_name = "oleg_govhelp_step_5",
		},

		{
			name = "Включить сирену",

			Setup = {
				client = function( )
					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=TAB и выбери 'Включить сирену' чтобы включить сирену",
						condition = function( )
							return localPlayer.vehicle
						end
					} )
				end,
			},

			event_end_name = "oleg_govhelp_step_siren",
		},

		{
			name = "Добраться до местоположения вора",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.park_position, function( self, player )
						CEs.marker.destroy( )
						triggerServerEvent( "oleg_govhelp_step_6", localPlayer )
					end,
					_, _, _, _,
					function( )
						if not localPlayer.vehicle then
							return false, "Где ты забыл служебную машину?"
						end
						return true
					end )
				end,
				server = function( player )
					local vehicle = GetTemporaryVehicle( player )
					vehicle:SetStatic( false )
				end,
			},

			event_end_name = "oleg_govhelp_step_6",
		},

		{
			name = "Незаметно преследовать вора",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions

					GEs.vehicle.frozen = false
					GEs.blip_vehicle = createBlipAttachedTo( GEs.vehicle )
					setVehicleParameters( GEs.vehicle, 100, 100, 50 )

					GEs.bot = CreateAIPed( 185, positions.enemy_spawn_position )
					LocalizeQuestElement( GEs.bot )
					addEventHandler( "onClientPedDamage", GEs.bot, cancelEvent )

					StartQuestCutscene( )
					CEs.move = CameraFromTo( _, positions.enemy_matrix, 5000, "InOutQuad" )

					AddAIPedPatternInQueue( GEs.bot, AI_PED_PATTERN_VEHICLE_ENTER, {
						vehicle = GEs.vehicle;
						seat = 0;
						end_callback = {
							func = function( )
								if CEs.move then CEs.move:destroy( ) end

								SetAIPedMoveByRoute( GEs.bot, positions.run_veh_path, false, function( )
									CEs.timer = setTimer( function( )
										if GEs.vehicle.velocity.length <= 0 then
											killTimer( sourceTimer )

											AddAIPedPatternInQueue( GEs.bot, AI_PED_PATTERN_VEHICLE_EXIT, {
												end_callback = {
													func = function( )
														destroyElement( GEs.blip_vehicle )

														SetAIPedMoveByRoute( GEs.bot, positions.run_path, false, function( )
															killTimer( CEs.check_timer )
															GEs.bot.rotation = Vector3( 0, 0, 132 )
															GEs.bot:setAnimation( "ped", "handsup", -1, false )
															triggerServerEvent( "oleg_govhelp_step_7", localPlayer )
														end )
													end,
													args = { },
												}
											} )
										end
									end, 500, 0 )
								end )

								CEs.timer = setTimer( function( )
									CameraFromTo( _, { GetTargetCameraMatrix( localPlayer ) }, 1000, "InOutQuad", function( )
										FinishQuestCutscene( )
									end )
								end, 1000, 1 )

								CEs.check_timer = setTimer( function()
									if isElement( GEs.bot ) and getDistanceBetweenPoints3D( localPlayer.position, GEs.bot.position ) > 250 then
										FailCurrentQuest( "Вор сбежал!" )
									end
								end, 1000, 0 )
							end,
							args = { },
						}
					} )
				end,
			},

			event_end_name = "oleg_govhelp_step_7",
		},

		{
			name = "Арестуй вора с помощью тайзера",

			Setup = {
				client = function( )
					EnableCheckQuestDimension( true )

					CreateQuestPoint( GEs.bot.position, function( self, player ) end, _, 2, _, _ )

					local function getCurrentStep( )
						local is_near = ( localPlayer.position - GEs.bot.position ).length <= 10
						local is_taser = localPlayer.weaponSlot == 2
						local is_aiming = getControlState( "aim_weapon" )

						return is_near and not is_taser and 1
							or is_near and is_taser and not is_aiming and 2
							or is_near and is_taser and is_aiming and 3
					end

					local hints = {
						{
							text = "Используй колесо мыши чтобы выбрать тайзер",
							condition = function( )
								return getCurrentStep( ) == 1
							end
						},
						{
							text = "Используй key=ПКМ чтобы прицелиться",
							condition = function( )
								return getCurrentStep( ) == 2
							end
						},
						{
							text = "Используй key=ЛКМ чтобы выстрелить тайзером",
							condition = function( )
								return getCurrentStep( ) == 3
							end
						}
					}
					for i, v in pairs( hints ) do
						table.insert( CEs, CreateSutiationalHint( v ) )
					end

					local positions = QUEST_CONF.positions
	
					local keys = {}
					for i, v in pairs( getBoundKeys( "fire" ) ) do
						keys[ i ] = true
					end

					local t = { }
					t.OnShoot = function( key, state )
						if not keys[ key ] or not state then return end

						local sx, sy, sz = getPedTargetStart(localPlayer)
						local tx, ty, tz = getPedTargetEnd(localPlayer)

						local hit, nx, ny, nz, element = processLineOfSight( sx, sy, sz, tx, ty, tz )

						iprint( hit, nx, ny, nz, element, element == GEs.bot )
						iprint( "dist", getDistanceBetweenPoints3D( sx, sy, sz, nx, ny, nz ) )
						if hit and element == GEs.bot and getDistanceBetweenPoints3D( sx, sy, sz, nx, ny, nz ) <= 10 then
							if isElement( CEs.marker ) then destroyElement( CEs.marker ) end
							playSound( ":nrp_factions_taser/files/sound/taser.mp3" )
							setPedAnimation( GEs.bot,  "crack", "crckidle" .. math.random( 1, 4 ), -1, true, false, false, false )
							removeEventHandler( "onClientKey", root, t.OnShoot )
							iprint( "TASER WORKED LOL", getTickCount( ) )
							triggerServerEvent( "oleg_govhelp_step_8", localPlayer )
							--triggerServerEvent( "OnPlayerTaserFire", localPlayer, pElement ) 
						end
					end

					addEventHandler( "onClientKey", root, t.OnShoot )
				end,
				server = function( player )
					player:GiveWeapon( 23, 100, false, true )
				end,
			},

			event_end_name = "oleg_govhelp_step_8",
		},

		{
			name = "Закуй вора в наручники",

			Setup = {
				client = function( )
					triggerEvent( "OnClientPlayerTaserFired", localPlayer, GEs.bot, true )

					localPlayer:setData( "fake_handcuffs_enabled", true, false )

					CEs.hint = CreateSutiationalHint( {
						text = "Используй key=TAB чтобы выбрать наручники",
						condition = function( )
							return ( localPlayer.position - GEs.bot.position ).length <= 4
						end
					} )

					local t = { }
					t.OnHandcuff = function( )
						iprint( "HANDCUFFED SUCCESSFULLY", getTickCount( ) )
						localPlayer:setData( "fake_handcuffs_enabled", false, false )
						removeEventHandler( "onClientPlayerFakeHandcuff", root, t.OnHandcuff )

						triggerServerEvent( "oleg_govhelp_step_9", localPlayer )
					end
					addEventHandler( "onClientPlayerFakeHandcuff", root, t.OnHandcuff )
				end,
			},

			event_end_name = "oleg_govhelp_step_9",
		},

		{
			name = "Сесть в служебную машину",

			Setup = 
			{
				client = function()
					local style = 
					{
						idle = "idle_stance",
						sprint = { "sprint_panic", "run_civi",  },
						walk = {  "walk_civi", "walk_start", },
					}

					setPedWalkingStyle( GEs.bot, 118 )
					--engineLoadIFP( ":nrp_factions_handcuffs/files/ifp/next.ifp", "CUSTOM_BLOCK_AREST" )
					engineReplaceAnimation( GEs.bot, "ped", style.idle, "CUSTOM_BLOCK_AREST", "arest1" )
					for k, v in pairs( style.walk ) do
						engineReplaceAnimation( GEs.bot, "ped", v, "CUSTOM_BLOCK_AREST", "walk_arest" )
					end
					for k, v in pairs( style.sprint ) do
						engineReplaceAnimation( GEs.bot, "ped", v, "CUSTOM_BLOCK_AREST", "sprint_arest" )
					end

					GEs.bot:setAnimation( nil, nil )
					GEs.follow = CreatePedFollow( GEs.bot )
					GEs.follow.same_vehicle = true
					GEs.follow:start( localPlayer )


					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					CreateQuestPoint( temp_vehicle.position, function( self, player )
						CEs.marker.destroy( )
					end )
					
					GEs.OnStartEnter = function( player, seat )
						if player ~= localPlayer then return end
						if seat ~= 0 then
							cancelEvent( )
							localPlayer:ShowError( "Собрался перевозить заключенного на пассажирском месте?" )
						end
					end
					addEventHandler( "onClientVehicleStartEnter", temp_vehicle, GEs.OnStartEnter )
	
					GEs.OnEnter = function( vehicle, seat )
						if vehicle ~= temp_vehicle then return end
						triggerServerEvent( "oleg_govhelp_step_10", localPlayer )
					end
					addEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.OnEnter )
				end,
			},

			CleanUp = {
				client = function( )
					removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, GEs.OnEnter )
					
					local temp_vehicle = localPlayer:getData( "temp_vehicle" )
					if isElement( temp_vehicle ) and GEs.OnStartEnter then
						removeEventHandler( "onClientVehicleStartEnter", temp_vehicle, GEs.OnStartEnter )
					end					
				end
			},

			event_end_name = "oleg_govhelp_step_10",
		},

		{
			name = "Отведи вора в участок",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.pps_marker, function( self, player )
						if GEs.bot.vehicle then removePedFromVehicle( GEs.bot ) end

						localPlayer.interior = 1
						localPlayer.position = positions.in_pps

						GEs.bot.position = positions.in_pps + Vector3( 0, 1, 0 )
						GEs.bot.interior = localPlayer.interior

						CEs.marker.destroy( )
						triggerServerEvent( "oleg_govhelp_step_11", localPlayer )
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

			event_end_name = "oleg_govhelp_step_11",
		},

		{
			name = "Посади вора в тюрьму",

			Setup = {
				client = function( )
					setVehicleSirensOn( GEs.vehicle, false )

					FadeBlink( )
					local positions = QUEST_CONF.positions

					CEs.hint = CreateSutiationalHint( {
						text = "Используй key=TAB чтобы посадить вора в тюрьму",
						condition = function( )
							return ( localPlayer.position - positions.jail_marker ).length <= 4
						end
					} )

					CreateQuestPoint( positions.jail_marker, function( self, player ) end,
					_, _, _, _,
					function( ) return false end )
					CEs.timer = setTimer( function( )
						local distance = ( localPlayer.position - positions.jail_marker ).length
						localPlayer:setData( "fake_jail_enabled", distance < 5, false )
					end, 100, 0 )

					local t = { }
					t.OnJail = function( )
						iprint( "JAILED LOL" )
						removeEventHandler( "onClientPlayerFakeJail", root, t.OnJail )
						GEs.follow:destroy( )
						GEs.bot.position = positions.bot_in_jail
						GEs.bot.rotation = positions.bot_in_jail_rotation
						triggerServerEvent( "oleg_govhelp_step_12", localPlayer )
					end
					addEventHandler( "onClientPlayerFakeJail", root, t.OnJail )
				end,
				server = function( player )
					player.interior = 1
				end,
			},

			CleanUp = {
				client = function( )
					localPlayer:setData( "fake_jail_enabled", false, false )
				end
			},

			event_end_name = "oleg_govhelp_step_12",
		},

		{
			name = "Поговорить с инспектором",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.inspector_talk, function( self, player )
						CEs.marker.destroy( )

						StartQuestCutscene( { dialog = QUEST_CONF.dialogs.inspector_finish } )
						localPlayer.position = positions.inspector_talk
						localPlayer.rotation = positions.inspector_talk_rotation

						setCameraMatrix( unpack( positions.inspector_talk_matrix ) )
						CEs.dialog:next( )

						StartPedTalk( FindQuestNPC( "inspector_pps" ).ped, nil, true )
						setTimerDialog( function( )
							triggerServerEvent( "oleg_govhelp_step_13", localPlayer )
						end, 9000, 1 )
					end, _, 2 )
				end,
			},

			CleanUp = {
				client = function( )
					StopPedTalk( FindQuestNPC( "inspector_pps" ).ped )
					FinishQuestCutscene( )
				end,
			},

			event_end_name = "oleg_govhelp_step_13",
		},

		{
			name = "Покинуть здание ППС",

			Setup = {
				client = function( )
					local positions = QUEST_CONF.positions
					CreateQuestPoint( positions.in_pps, function( self, player )
						CEs.marker.destroy( )

						localPlayer.interior = 0
						localPlayer.position = positions.pps_marker
						triggerServerEvent( "oleg_govhelp_step_14", localPlayer )
					end, _, 1 )
				end,
			},

			event_end_name = "oleg_govhelp_step_14",
		},

		{
			name = "Поговорить с Олегом",

			Setup = {
				client = function( )
					CreateMarkerToCutsceneNPC( {
						id = "oleg",
						dialog = QUEST_CONF.dialogs.finish,
						local_dimension = true,
						callback = function( )
							CEs.marker.destroy( )
							CEs.dialog:next( )
							StartPedTalk( FindQuestNPC( "oleg" ).ped, nil, true )
							setVehicleSirensOn( GEs.vehicle, false )

							setTimerDialog( function()
								triggerServerEvent( "oleg_govhelp_step_15", localPlayer )
							end, 11000, 1 )
						end
					} )
				end,
				server = function( player )
					player.interior = 0
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "oleg" ).ped )
				end,
			},

			event_end_name = "oleg_govhelp_step_15",
		},

	},

	GiveReward = function( player )
		if player:GetPermanentData( "reg_date" ) >= NEW_TUTORIAL_RELEASE_DATE then
			player:StartRetentionTask( "drive5", 24 * 60 * 60 )
			setTimer( function( )
				if not isElement( player ) then return end
				player:ShowInfo( "Тебе доступна новая акция! Открой Магазин F4" )
			end, 10000, 1 )
		end

		player:SituationalPhoneNotification(
			{ title = "Олег", msg = "Здраствуй, у меня новый заказ появился. Приезжай поговорим. Журнал квестов F2" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "oleg_parkemployee" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, 
		{
			rewards = { money = QUEST_DATA.rewards.money, exp = QUEST_DATA.rewards.exp }
		} )
	end,

	rewards = {
		money = 500,
		exp = 1300,
	},

	no_show_rewards = true,
}

addEvent( "onClientPlayerFakeHandcuff" )
addEvent( "onClientPlayerFakeJail" )