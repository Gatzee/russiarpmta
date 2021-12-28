QUEST_CONF = {
	dialogs = {
		start = {
			{ name = "Роман", voice_line = "Roman_real_initiative_1", duration = 13, text = 
[[Ну привет. Посмотрим, как на этот раз справишься.
В эту точку приедет кортеж западного картеля, 
большая часть бандитов уйдет охранять приближенного,
и останется всего пару человек у машин.]] },
			{ name = "Роман", duration = 8, text = 
[[Нужно их тихо подрезать и забрать тачку. 
А потом привезти ее ко мне. 
Выдвигайся, они скоро подъедут!]] },
		},
		finish = {
			{ name = "Роман", voice_line = "Roman_real_initiative_2", text = 
[[А ты не перестаешь меня удивлять. Но долг еще не прощен. 
Я позже позову тебя, когда понадобишься!]] },
		},
	},

	positions = {
		start = Vector3{ x = 2190.03, y = 2637.9, z = 8.07 },
	},
}

GEs = { }

QUEST_DATA = {
	id = "real_initiative",
	is_company_quest = true,
	quests_request = { "beginning_proceedings" },
	level_request = 18,

	title = "Настоящая инициатива",
	description = "Проклятый Роман! Сволочь, конечно, но спас тогда, стоит вернуть ему должок.",
	--replay_timeout = 5;

	restart_position = Vector3{ x = 2188.467, y = 2629.484, z = 8.072 },

	CheckToStart = function( player )
		if player.interior ~= 0 or player.dimension ~= 0 then return end

		return true
	end,

	OnAnyFinish = {
		server = function( player )
			DestroyAllTemporaryVehicles( player )
			ExitLocalDimension( player )
			DisableQuestEvacuation( player )

			if player.interior ~= 0 then
				player.interior = 0
				player.position = QUEST_CONF.positions.start
			end
			player:TakeAllWeapons( true )
			
			triggerEvent( "onGameTimeRequest", player )
		end,
	},
	
	tasks = {
		[ 1 ] = {
			name = "Поговорить с Романом",

			Setup = {
				client = function( )
					HideNPCs( )

					local function func_check_veh()
						if localPlayer.vehicle then
							return false, "Для продолжения покинь транспорт"
						end
						return true
					end

					CreateQuestPoint( QUEST_CONF.positions.start, function( )
						fadeCamera( false, 1 )
						CEs.timer = setTimer( function( )
							triggerServerEvent( "real_initiative_step_1", localPlayer )
						end, 1000, 1 )
					end, _, _, _, _, func_check_veh )
				end,

				server = function( player )
					
				end
			},

			event_end_name = "real_initiative_step_1",
		},

		[ 2 ] = {
			name = "Катсцена: Поговорить с Романом",

			Setup = {
				client = function( )
					EnterLocalDimension( )
					
					setTime( 0, 0 )
					setCameraMatrix( -95.936790466309, -2481.1411132813, 4406.84765625, -6.7608675956726, -2526.3205566406, 4404.3051757813, 0, 70 )
					
					localPlayer.interior = 1
					localPlayer.position = Vector3{ x = -94.932, y = -2482.299, z = 4406.272 }
					localPlayer.rotation = Vector3( 0, 0, 283.6 )

					GEs.roman = CreateAIPed( 6733, Vector3( { x = -92.61, y = -2481.62, z = 4406.27 } ), 90 )
					SetUndamagable( GEs.roman, true )
					LocalizeQuestElement( GEs.roman )

					StartQuestCutscene( {
						dialog = QUEST_CONF.dialogs.start,
						ignore_fade_blink = true,
					} )

					CEs.wait_streamin_timer = setTimer( function( )
						fadeCamera( true, 0.5 )
						StartPedTalk( GEs.roman, nil, true )
						CEs.dialog.auto = true
						CEs.dialog:start( 500 )
						CEs.dialog.end_callback = function( )
							fadeCamera( false, 1 )
							CEs.timer = setTimer( function( )
								triggerServerEvent( "real_initiative_step_2", localPlayer )
							end, 1000, 1 )
						end
					end, 1000, 1 )
				end,

				server = function( player )
					player.interior = 1
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( GEs.roman )
				end,
			},

			event_end_name = "real_initiative_step_2",
		},

		[ 3 ] = {
			name = "Прибыть на позицию",

			Setup = {
				client = function( )
					EnableCheckQuestDimension( true )
					fadeCamera( true, 1 )
					
					localPlayer.interior = 0
					localPlayer.position = QUEST_CONF.positions.start
					localPlayer.rotation = Vector3( 0, 0, 150 )	

					CreateQuestPoint( Vector3{ x = 1098.541, y = 2047.388, z = 9.252 }, function( )
						fadeCamera( false, 1 )
						CEs.timer = setTimer( function( )
							triggerServerEvent( "real_initiative_step_3", localPlayer )
						end, 1000, 1 )
					end )
				end,

				server = function( player )
					player.interior = 0
					player:GiveWeapon( 4, 1, true, true )
					
					EnableQuestEvacuation( player )
					EnterLocalDimensionForVehicles( player, QUEST_CONF.positions.start )
				end
			},

			CleanUp = {
				server = function( )
					ExitLocalDimensionForVehicles( player )
				end,
			},

			event_end_name = "real_initiative_step_3",
		},

		[ 4 ] = {
			name = "Катсцена прибытия бандитов",

			Setup = {
				client = function( )
					StartQuestCutscene( { ignore_fade_blink = true } )

					GEs.cartel_vehicles = { }

					for i, pos in pairs( {
						{ x = 1052.429, y = 2085.433, z = 8.455, rz = 176.748 },
						{ x = 1053.781, y = 2098.149, z = 8.450, rz = 171.563 },
						{ x = 1058.173, y = 2112.534, z = 8.364, rz = 161.897 },
					} ) do
						local veh = createVehicle( 6527, Vector3( pos ), Vector3( 0, 0, pos.rz ) )
						veh:SetColor( 0, 0, 0 )
						veh:SetNumberPlate( "5:к10" .. i .. "кк99" )
						LocalizeQuestElement( veh )
						GEs.cartel_vehicles[ i ] = veh
					end

					-- id 259 - 4 шт, id 260 - 1 шт, id 258 - 4 шт
					GEs.cartel_peds = { }
					for ci, ped_conf in pairs( {
						{ model = 260, count = 1 },
						{ model = 258, count = 4 },
						{ model = 259, count = 4 },
					} ) do
						for i = 1, ped_conf.count do
							local ped = CreateAIPed( ped_conf.model, Vector3( 0, 0, 0 ) )
							LocalizeQuestElement( ped )
							table.insert( GEs.cartel_peds, ped )
					
							local ped_i = #GEs.cartel_peds
							local ped_veh = GEs.cartel_vehicles[ ( ped_i - 1 ) % 3 + 1 ]
							table.insert( CEs, setTimer( warpPedIntoVehicle, 100, 1, ped, ped_veh, math.floor( ( ped_i - 1 ) / 3 ) ) )
						end
					end


					CEs.after_warp_timer = setTimer( function( )
						-- Из точки 1 начинает движение кортеж
						-- за ним следит камера 5
						CEs.fade_camera_timer = setTimer( fadeCamera, 500, 1, true, 1 )
						local camera_position = Vector3{ 1079.8356933594, 2039.1273193359, 12.788452148438, }
						local camera_rotation = Vector3{ 358.379, 0, 0 }
						CEs.focus_camera_timer = setTimer( function( )
							local target_position = GEs.cartel_vehicles[ 2 ].position
							camera_rotation.z = FindRotation( camera_position.x, camera_position.y, target_position.x, target_position.y )
							Camera.position = camera_position
							Camera.rotation = camera_rotation
						end, 0, 0 )

						local start_nodes = {
							{ x = 1051.59  , y = 2067.26  , z = 8.29  , distance = 3 },
							{ x = 1053.23  , y = 2086.85  , z = 8.3   , distance = 2 },
							{ x = 1055.014 , y = 2101.427 , z = 8.667 , distance = 2 },
						}

						local common_nodes = {
							{ x = 1046.78  , y = 2056.4   , z = 8.5 },
							{ x = 1041.42  , y = 2047.51  , z = 8.5 },
							{ x = 1035.7   , y = 2039.26  , z = 8.496 },
						}

						local last_nodes = {
							{ x = 988.46, y = 2020.27, z = 8.5, rz = 103.2 },
							{ x = 997.97, y = 2033.22, z = 8.5, rz = 108.7 },
							{ x = 1014.05, y = 2038.3, z = 8.5 },
						}

						local busy_vehicles = { }
						for i, veh in ipairs( GEs.cartel_vehicles ) do
							busy_vehicles[ veh ] = true
							veh.velocity = veh.matrix.forward * 0.3
							for node_i = i, 1, -1 do
								SetAIPedMoveByRoute( veh.controller, { start_nodes[ node_i ] } )
							end
							SetAIPedMoveByRoute( veh.controller, common_nodes )

							SetAIPedMoveByRoute( veh.controller, { last_nodes[ i ] }, false, function( )
								-- как только 1 машина кортежа оказывается в точке 2
								-- переключаем на камеру 7, следит за бандитам, но не поворачивается в сторону под арками 
								if CEs.focus_camera_timer then
									CEs.focus_camera_timer:destroy( )
									CEs.focus_camera_timer = nil
									setCameraMatrix( 978.39276123047, 2004.2769775391, 10.032106399536, 1030.8908691406, 2089.2424316406, 5.0477380752563, 0, 70 )
								end
								for i, ped in pairs( veh.occupants ) do
									-- Выходят из машины
									table.insert( CEs, setTimer( AddAIPedPatternInQueue, math.random( 2000 ), 1, ped, AI_PED_PATTERN_VEHICLE_EXIT, { } ) )
									-- Идут сначала вперёд от машины, чтобы не застревали
									table.insert( CEs, setTimer( function( )
										local first_node = ( ped.position + veh.matrix.forward * ( i < 2 and 4.5 or 5.5 ) ):totable( )
										first_node.move_type = 4
										SetAIPedMoveByRoute( ped, { first_node } )
									end, 2000, 1 ) )
								end
								
								busy_vehicles[ veh ] = nil
								if next( busy_vehicles ) then return end

								CEs.start_walk_timer = setTimer( function( )
									-- бандиты уходят
									for i = 1, #GEs.cartel_peds - 2 do
										SetAIPedMoveByRoute( GEs.cartel_peds[ i ], {
											{ x = 976.73, y = 2006.75, z = 7.5, move_type = 4 },
											{ x = 951.54, y = 2023.46, z = 7.5, move_type = 4 },
										} )
									end

									-- включается камера 6, которая показывает патрулирование оставшихся бандитов в течении 5 сек
									CEs.start_patrol_timer = setTimer( function( )
										for i = 1, #GEs.cartel_peds - 2 do
											GEs.cartel_peds[ i ]:destroy( )
											GEs.cartel_peds[ i ] = nil
										end
										for i, veh in ipairs( GEs.cartel_vehicles ) do
											veh.position = Vector3( last_nodes[ i ] )
											if last_nodes[ i ].rz then
												veh:setRotation( 0, 0, last_nodes[ i ].rz )
											end
										end

										FadeBlink( 2 )
										setCameraMatrix( 1024.6590576172, 2027.9107666016, 13.743310928345, 931.25378417969, 2047.2957763672, -16.251352310181, 0, 70 )

										local patrol_points = {
											{
												{ x = 985.21 , y = 2017.15, z = 8.5, move_type = 4 },
												{ x = 983.466, y = 2019.56, z = 8.5, move_type = 4, wait_time = 4000 },
												{ x = 993.66 , y = 2033.24, z = 8.5, move_type = 4 },
												{ x = 995.35 , y = 2035.3 , z = 8.5, move_type = 4, wait_time = 4000 },
												{ x = 1002.27, y = 2036.57, z = 8.5, move_type = 4 },
												{ x = 1003.36, y = 2034.05, z = 8.5, move_type = 4 },
												{ x = 1002.81, y = 2032.11, z = 8.5, move_type = 4 },
												{ x = 993.27 , y = 2021.04, z = 8.5, move_type = 4, wait_time = 4000 },
												{ x = 993.19 , y = 2018.92, z = 8.5, move_type = 4, wait_time = 4000 },
											},
											{
												{ x = 1001.03, y = 2030.73, z = 8.5, move_type = 4, wait_time = 4000 },
												{ x = 1013.12, y = 2036.36, z = 8.5, move_type = 4 },
												{ x = 999.67 , y = 2038.76, z = 8.5, move_type = 4, wait_time = 4000 },
												{ x = 993.61 , y = 2034.08, z = 8.5, move_type = 4, wait_time = 4000 },
												{ x = 993.034, y = 2031.51, z = 8.5, move_type = 4 },
												{ x = 993.45 , y = 2028.38, z = 8.5, move_type = 4, wait_time = 4000 },
											},
										}
										local function SetPedPatrolling( ped, points )
											SetAIPedMoveByRoute( ped, points, false, function( )
												SetPedPatrolling( ped, points )
											end )
										end

										for i = 0, 1 do
											local ped = GEs.cartel_peds[ #GEs.cartel_peds - i ]
											local points = patrol_points[ i + 1 ]
											ped.position = Vector3( points[ #points ] )
											SetPedPatrolling( ped, points )
										end

										CEs.next_step_timer = setTimer( function( )
											fadeCamera( false, 1 )
											CEs.timer = setTimer( function( )
												triggerServerEvent( "real_initiative_step_4", localPlayer, GEs.cartel_vehicles[ 1 ].position:totable( ), GEs.cartel_vehicles[ 1 ].rotation:totable( ) )
											end, 1000, 1 )
										end, 7000, 1 )

									end, 10000, 1 )

								end, 2000, 1 )
							end )
						end
					end, 300, 1 )
				end,

				server = function( player )
					local vehicle = CreateTemporaryVehicle( player, 6527, Vector3{ x = 0, y = 0, z = 0 } )
					player:SetPrivateData( "temp_vehicle", vehicle )
				end
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )

					GEs.bandits = { }
					for i = 1, #GEs.cartel_peds - 2 do
						if GEs.cartel_peds[ i ] then
							GEs.cartel_peds[ i ]:destroy( )
							GEs.cartel_peds[ i ] = nil
						end
					end
					for i, ped in pairs( GEs.cartel_peds ) do
						table.insert( GEs.bandits, ped )
					end

					GEs.need_vehicle = localPlayer:getData( "temp_vehicle" )
					GEs.need_vehicle.locked = true
					GEs.need_vehicle:SetColor( 0, 0, 0 )
					GEs.need_vehicle:SetNumberPlate( "5:к101кк99" )

					GEs.cartel_vehicles[ 1 ]:destroy( )
				end,
			},

			event_end_name = "real_initiative_step_4",

			event_end_handler = function( player, position, rotation )
				local need_vehicle = player:getData( "temp_vehicle" )
				need_vehicle.position = Vector3( position )
				need_vehicle.rotation = Vector3( rotation )
				return true
			end,
		},

		[ 5 ] = {
			name = "Скрытно убить бандитов",

			Setup = {
				client = function( )
					StartQuestTimerFail( 5 * 60 * 1000, "Скрытно убить бандитов", "Слишком медленно!" )

					setCameraTarget( localPlayer )
					fadeCamera( true, 1 )

					CEs.hint = CreateSutiationalHint( {
						text = "Нажми key=C чтобы присесть",
						condition = function( )
							return not localPlayer.ducked
						end
					} )

					CEs.hint2 = CreateSutiationalHint( {
						text = "Подойди к бандиту сзади, когда он стоит, c зажатой key=ПКМ и нажми key=ЛКМ чтобы убить скрытно",
						condition = function( )
							return localPlayer.ducked
						end
					} )

					local alive_bandits = { }

					for i, bandit in pairs( GEs.bandits ) do
						alive_bandits[ bandit ] = true

						addEventHandler( "onClientPedWasted", bandit, function( )
							alive_bandits[ bandit ] = nil

							if not next( alive_bandits ) then
								CEs.step_timer = setTimer( function( )
									triggerServerEvent( "real_initiative_step_5", localPlayer )
								end, 1000, 1 )
							end
						end )
					end

					local bot_view_angle = 90
					local bot_view_distance = 28
					local bot_view_distance_when_player_ducked = 13

					local function CheckBotDetectedPlayer( bot )
						if bot.dead then return end

						local position = localPlayer.position
						local bot_position = bot.position
						local bot_view_distance = localPlayer.ducked and bot_view_distance_when_player_ducked or bot_view_distance
						
						if bot_position:distance( position ) > bot_view_distance then return end

						local look_rot = FindRotation( bot_position.x, bot_position.y, position.x, position.y )
						
						if math.abs( bot.rotation.z - look_rot ) > bot_view_angle / 2 then return end

						if not isLineOfSightClear ( bot_position, position, true, true, false ) then return end

						return true
					end

					CEs.check_timer = setTimer( function( self, conf )
						for i, bandit in pairs( GEs.bandits ) do
							if CheckBotDetectedPlayer( bandit ) then
								FailCurrentQuest( "Вас заметили" )
								CleanupAIPedPatternQueue( bandit )
								AddAIPedPatternInQueue( bandit, AI_PED_PATTERN_ATTACK_PED, { target_ped = localPlayer } )
								sourceTimer:destroy( )
								return
							end
						end
					end, 300, 0 )

					-- Нужно сразу убить в стелсе
					for i, bandit in pairs( GEs.bandits ) do
						addEventHandler( "onClientPedDamage", bandit, function( attacker, weapon, bodypart, loss )
							if attacker == localPlayer and loss ~= bandit.health then
								FailCurrentQuest( "Вас заметили" )
							end
						end )
					end

					-- Чтобы игроку было чутка легче
					CEs.toggle_fire = setTimer( function( )
						local enabled = not getKeyState( "mouse2" ) or localPlayer.target and localPlayer.target.velocity.length < 0.001
						toggleControl( "fire", enabled )
					end, 50, 0 )

					-- Нельзя пользоваться огнестрелом
					localPlayer.weaponSlot = 1
					toggleControl( "next_weapon", false )
					toggleControl( "previous_weapon", false )
					
					GEs.onClientPlayerWeaponSwitch = function( old_slot, new_slot )
						if old_slot == 1 or new_slot ~= 1 then 
							cancelEvent( )
						end
					end
					addEventHandler( "onClientPlayerWeaponSwitch", localPlayer, GEs.onClientPlayerWeaponSwitch )

					-- Нельзя заезжать на машине
					local col = createColSphere( Vector3{ x = 1004.127, y = 2034.336, z = 8.489 }, 45 )
					addEventHandler( "onClientColShapeHit", col, function( element )
						if element == localPlayer and localPlayer.vehicle then
							FailCurrentQuest( "Вас заметили" )
						end
					end )

					GEs.music = playSound( ":nrp_casino_game_roulette/sfx/bg1.ogg", true )
					GEs.music.volume = 0.25
					localPlayer:setData( "block_radio", true, false )
				end,
			},

			CleanUp = {
				client = function( )
					removeEventHandler( "onClientPlayerWeaponSwitch", localPlayer, GEs.onClientPlayerWeaponSwitch )
					toggleControl( "next_weapon", true )
					toggleControl( "previous_weapon", true )
					toggleControl( "fire", true )

					GEs.music_fadeout = setTimer( function( )
						if GEs.music.volume > 0.003 then
							GEs.music.volume = GEs.music.volume - 0.003
						else
							GEs.music:destroy( )
							sourceTimer:destroy( )
						end
					end, 0, 0 )
					localPlayer:setData( "block_radio", false, false )
				end,
			},

			event_end_name = "real_initiative_step_5",
		},

		[ 6 ] = {
			name = "Угнать машину",

			Setup = {
				client = function( )
					table.insert( GEs, WatchElementCondition( GEs.need_vehicle, {
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

					GEs.need_vehicle.locked = false
					GEs.need_vehicle:SetGPSMarker( { PostJoin = function( ) end } )

					addEventHandler( "onClientVehicleEnter", GEs.need_vehicle, function( element, seat )
						if element ~= localPlayer or seat ~= 0 then return end
						triggerServerEvent( "real_initiative_step_6", localPlayer )
					end )
				end,
			},

			CleanUp = {
				client = function( )
					GEs.need_vehicle:SetGPSMarker( false )
				end,
			},

			event_end_name = "real_initiative_step_6",
		},

		[ 7 ] = {
			name = "Доставить машину",

			Setup = {
				client = function( )
					CreateQuestPoint( { x = 553.21, y = -520.42, z = 19.93 }, function( )
						CEs.marker.destroy( )
						
						-- fadeCamera( false, 1 )
						-- CEs.timer = setTimer( function( )
							triggerServerEvent( "real_initiative_step_7", localPlayer )
						-- end, 1000, 1 )
					end, _, _, _, _, function( )
						if localPlayer.vehicle ~= GEs.need_vehicle then
							return false, "Где тачка?"
						end
						return true
					end )
				end,
			},

			event_end_name = "real_initiative_step_7",
		},

		[ 8 ] = {
			name = "Поговорить с Романом",

			Setup = {
				client = function( )
					GEs.need_vehicle.engineState = false
					GEs.need_vehicle.frozen = true

					CreateMarkerToCutsceneNPC( {
						id = "roman_near_house",
						dialog = QUEST_CONF.dialogs.finish,
						radius = 1,
						local_dimension = true,
						callback = function( )
							CEs.marker.destroy( )
							
							-- fadeCamera( true, 1 )
							StartPedTalk( FindQuestNPC( "roman_near_house" ).ped, nil, true )
							CEs.dialog.auto = true
							CEs.dialog:start( 500 )
							CEs.dialog.end_callback = function( )
								fadeCamera( false, 2 )
								CEs.timer = setTimer( function( )
									triggerServerEvent( "real_initiative_step_8", localPlayer )
								end, 2000, 1 )
							end
						end
					} )
				end,
			},

			CleanUp = {
				client = function( )
					FinishQuestCutscene( )
					StopPedTalk( FindQuestNPC( "roman_near_house" ).ped )
				end,
			},

			event_end_name = "real_initiative_step_8",
		},
	},

	GiveReward = function( player )
		player:SituationalPhoneNotification(
			{ title = "Анжела", msg = "Привеет, мне срочно нужна компания. Приезжай!" },
			{
				condition = function( self, player, data, config )
					local current_quest = player:getData( "current_quest" )
					if current_quest and current_quest.id == "good_game" then
						return "cancel"
					end
					return getRealTime( ).timestamp - self.ts >= 60
				end,
				save_offline = true,
			}
		)

		triggerClientEvent( player, "ShowPlayerUIQuestCompleted", player, {
			rewards = {
				money = 8000,
				exp = 10000,
			}
		} )
	end,

	rewards = {
		money = 8000,
		exp = 10000,
	},

	no_show_rewards = true,
}