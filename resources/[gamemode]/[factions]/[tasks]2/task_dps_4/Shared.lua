ENTERS = {
	{ x = 344.900, y = -2055.125, z = 20.962 },
	{ x = 2233.869, y = -642.198, z = 60.824 },
	{ x = -1473.567, y = 2546.785, z = 11.468 },
}

QUEST_DATA = {
	id = "task_dps_4",

	title = "Проверка рабочих машин",
	description = "",

	replay_timeout = 0,

	CheckToStart = function ( player )
		return player:IsInFaction( )
	end,

	OnAnyFinish = {
		client = function( )
			setPedAnimation( localPlayer )
			toggleControl( "fire", true )
		end
	},

	tasks = {
		[ 1 ] = {
			name = "Поговори с лейтенантом",

			Setup = {
				client = function( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Твоя задача проверить рабочий транспорт
									и подготовить его к работе.]],
						},
						{
							text = [[— Держи инструменты, пригодятся.]],
							info = true,
						},
					}, "task_dps_4_step_1", _, true )
				end,
			},

			event_end_name = "task_dps_4_step_1",
		},
		[ 2 ] = {
			name = "Подойти к транспорту на парковке",

			Setup = {
				client = function ( )
					local position = VEHICLES[ localPlayer:GetFaction( ) ]

					CreateQuestPoint( Vector3( position.x, position.y, position.z ), function ( )
						CEs.marker:destroy( )
						toggleControl( "fire", false )
						triggerServerEvent( "task_dps_4_step_2", localPlayer )
					end, nil, 3.5, 0, 0, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
				end,
			},

			event_end_name = "task_dps_4_step_2",
		},
		[ 3 ] = {
			name = "Проверь транспорт",

			Setup = {
				client = function ( )
					CEs.details = { }
					local vehicle = VEHICLES[ localPlayer:GetFaction( ) ].element

					for k, v in pairs( VARIABLE_VEHICLE_DETAILS[ math.random( 1, #VARIABLE_VEHICLE_DETAILS ) ] ) do
						local position, mrk_position = getPositionsFromVehicleDetail( vehicle, v )
						CEs.details[ k ] = { name = v, position = position, mrk_position = mrk_position }
					end

					local current_marker = 1
					local function addNextMarker( )
						local detail = CEs.details[ current_marker ]
						if detail then
							CreateQuestPoint( detail.mrk_position, function ( )
								CEs.marker:destroy( )

								CEs.game = ibInfoPressKey( {
									do_text = "Нажми",
									text = "чтобы осмотреть",
									key = "lalt",
									key_text = "ALT",
									black_bg = 0x00000000,
									key_handler = function ( )
										setRotationToTarget( localPlayer, detail.position )

										if detail.name == "bonnet_dummy" or detail.name == "windscreen_dummy" then
											localPlayer:setPosition( getElementPosition( localPlayer ) )
											localPlayer:setAnimation( "bd_fire", "wash_up", 3000, true, false, false, false )
										else
											localPlayer:setAnimation( "bd_fire", "wash_up", 1, true, false, true, false )
											localPlayer:setAnimation( "bomber", "bom_plant_loop", 3000, true, false, false, false )
										end

										CEs.timer = setTimer( function ( )
											current_marker = current_marker + 1
											addNextMarker( )
										end, 2000, 1 )
									end,
								} )
							end, nil, 1, 0, 0, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
						else
							triggerServerEvent( "task_dps_4_step_3", localPlayer )
						end
					end
					addNextMarker( )
				end,
			},

			event_end_name = "task_dps_4_step_3",
		},
		[ 4 ] = {
			name = "Обслужи транспорт",

			Setup = {
				client = function( )
					local vehicle = VEHICLES[ localPlayer:GetFaction( ) ].element

					CEs.mini_game = {
						counter = 0,
						current_action = nil,

						getRandomActionNum = function ( self )
							local next_action = math.random( 1, #CEs.mini_game )
							if next_action == self.current_action then
								return self:getRandomActionNum( )
							else
								return next_action
							end
						end,

						nextAction = function ( self )
							self.counter = self.counter + 1

							if self.counter > 3 then
								triggerServerEvent( "task_dps_4_step_4", localPlayer )
							else
								self.current_action = self:getRandomActionNum( )

								local detail_name = self.detailToAction[ self.current_action ]
								local det_position, mrk_position = getPositionsFromVehicleDetail( vehicle, detail_name )

								CreateQuestPoint( mrk_position, function ( )
									CEs.marker:destroy( )
									CEs.mini_game[ self.current_action ]( )
									CEs.mini_game.startAnimByDetail( detail_name )
									setRotationToTarget( localPlayer, det_position )
								end, nil, 1, 0, 0, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
							end
						end,

						endAction = function ( self )
							localPlayer:setAnimation( )
							self:nextAction( )
						end,

						startAnimByDetail = function ( detail_name )
							local not_bomber = {
								bonnet_dummy = true,
								door_lf_dummy = true,
								windscreen_dummy = true,
							}

							if not_bomber[ detail_name ] then
								localPlayer:setPosition( getElementPosition( localPlayer ) )
								localPlayer:setAnimation( "bd_fire", "wash_up", -1, true, false, false, false )
							else
								localPlayer:setAnimation( "bd_fire", "wash_up", 1, true, false, true, false )
								localPlayer:setAnimation( "bomber", "bom_plant_loop", -1, true, false, false, false )
							end
						end,

						detailToAction = { "bonnet_dummy", "wheel_lb_dummy", "wheel_lf_dummy", "windscreen_dummy", "door_lf_dummy" },

						[ 1 ] = function ( )
							CEs.game = ibInfoPressKeyProgress( {
								do_text = "Нажимай",
								text = "чтобы открыть капот",
								key = "mouse2",
								black_bg = 0x00000000,
								click_count = 10,
								end_handler = function ( )
									vehicle:setData( "cd_state_0", 1, false )
									setVehicleDoorOpenRatio( vehicle, 0, 1, 1000 )
									CEs.game = ibInfoPressKey( {
										do_text = "Удерживай",
										text = "чтобы измерить уровень масла",
										key = "lalt",
										key_text = "ALT",
										hold = true,
										black_bg = 0x00000000,
										key_handler = function ( )
											CEs.game = ibInfoPressKeyProgress( {
												do_text = "Нажимай",
												text = "чтобы закрыть капот",
												key = "mouse2",
												black_bg = 0x00000000,
												click_count = 10,
												end_handler = function ( )
													vehicle:setData( "cd_state_0", 0, false )
													setVehicleDoorOpenRatio( vehicle, 0, 0, 1000 )
													CEs.mini_game:endAction( )
												end,
											} )
										end,
									} )
								end,
							} )
						end,

						[ 2 ] = function ( )
							CEs.game = ibInfoPressKey( {
								do_text = "Нажми",
								text = "чтобы взять тряпку",
								key = "lalt",
								key_text = "ALT",
								black_bg = 0x00000000,
								key_handler = function ( )
									CEs.game = ibInfoPressKeyProgress( {
										do_text = "Нажимай",
										text = "чтобы протереть",
										key = "mouse2",
										black_bg = 0x00000000,
										click_count = 10,
										end_handler = function ( )
											CEs.mini_game:endAction( )
										end,
									} )
								end,
							} )
						end,

						[ 3 ] = function ( )
							CEs.game = ibInfoPressKey( {
								do_text = "Нажми",
								text = "чтобы взять инструмент",
								key = "lalt",
								key_text = "ALT",
								black_bg = 0x00000000,
								key_handler = function ( )
									CEs.game = ibInfoPressKey( {
										do_text = "Удерживай",
										text = "чтобы проверить давление",
										key = "mouse2",
										hold = true,
										black_bg = 0x00000000,
										key_handler = function ( )
											CEs.game = ibInfoPressKey( {
												do_text = "Нажми",
												text = "чтобы положить инструмент",
												key = "lalt",
												key_text = "ALT",
												black_bg = 0x00000000,
												key_handler = function ( )
													CEs.mini_game:endAction( )
												end,
											} )
										end,
									} )
								end,
							} )
						end,

						[ 4 ] = function ( )
							CEs.game = ibInfoPressKeyProgress( {
								do_text = "Нажимай",
								text = "чтобы открыть багажник",
								key = "mouse2",
								black_bg = 0x00000000,
								click_count = 10,
								end_handler = function ( )
									setVehicleDoorOpenRatio( vehicle, 1, 1, 1000 )
									vehicle:setData( "cd_state_1", 1, false )
									CEs.game = ibInfoPressKey( {
										do_text = "Удерживай",
										text = "чтобы проверить багажник",
										key = "lalt",
										key_text = "ALT",
										hold = true,
										black_bg = 0x00000000,
										key_handler = function ( )
											CEs.game = ibInfoPressKeyProgress( {
												do_text = "Нажимай",
												text = "чтобы закрыть багажник",
												key = "mouse2",
												black_bg = 0x00000000,
												click_count = 10,
												end_handler = function ( )
													setVehicleDoorOpenRatio( vehicle, 1, 0, 1000 )
													vehicle:setData( "cd_state_1", 0, false )
													CEs.mini_game:endAction( )
												end,
											} )
										end,
									} )
								end,
							} )
						end,

						[ 5 ] = function ( )
							CEs.game = ibInfoPressKeyProgress( {
								do_text = "Нажимай",
								text = "чтобы открыть дверь",
								key = "mouse2",
								black_bg = 0x00000000,
								click_count = 10,
								end_handler = function ( )
									vehicle:setDoorOpenRatio( 2, 1, 1000 )
									CEs.game = ibInfoPressKey( {
										do_text = "Удерживай",
										text = "чтобы очистить салон",
										key = "lalt",
										key_text = "ALT",
										hold = true,
										black_bg = 0x00000000,
										key_handler = function ( )
											CEs.game = ibInfoPressKeyProgress( {
												do_text = "Нажимай",
												text = "чтобы закрыть дверь",
												key = "mouse2",
												black_bg = 0x00000000,
												click_count = 10,
												end_handler = function ( )
													vehicle:setDoorOpenRatio( 2, 0, 1000 )
													CEs.mini_game:endAction( )
												end,
											} )
										end,
									} )
								end,
							} )
						end,
					}

					CEs.mini_game:nextAction( )
				end,
			},

			event_end_name = "task_dps_4_step_4",
		},
		[ 5 ] = {
			name = "Вернись к лейтенанту",

			Setup = {
				client = function( )
					local faction_id = localPlayer:GetFaction( )
					local ped_position = QUESTS_NPC[ FACTIONS_TASKS_PED_IDS[ faction_id ] ].position

					local function createNextMarker( )
						CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ faction_id ], {
							{
								text = [[— Неплохая работа боец, так держать!]],
							},
						}, "task_dps_4_step_5", _, true )
					end

					CEs.watch = WatchElementCondition( localPlayer, {
						condition = function( )
							if localPlayer.dimension == 1 and localPlayer.interior == 1
							and getDistanceBetweenPoints3D( ped_position, localPlayer.position ) < 20 then
								CEs.marker:destroy( )
								createNextMarker( )
								return true
							end
						end,
					} )

					CreateQuestPoint( ENTERS[ localPlayer:GetFactionDutyCity( ) ], function ( )
						CEs.marker:destroy( )
						createNextMarker( )
					end, nil, 1.7, 0, 0, function ( ) return not localPlayer.vehicle end )
				end,
			},

			event_end_name = "task_dps_4_step_5",
		},
	},

	GiveReward = function ( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_dps_4", 33 )
	end,
	success_text = "Задача выполнена!",

	rewards = {
		faction_exp = 33,
	},
}