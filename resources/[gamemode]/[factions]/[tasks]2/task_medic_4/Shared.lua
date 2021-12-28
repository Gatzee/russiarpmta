QUEST_PEDS = {
	16, -- NSK
	17, -- GRK
	27, -- MSK
}

POSITIONS = {
	resuscitation = {
		{ x = 467.344, y = -1605.367, z = 1020.968 }, -- NSK
		{ x = 1961.177, y = 305.732, z = 660.974 }, -- GRK
		{ x = -1994.928, y = 2006.366, z = 1797.890 }, -- MSK
	},
	patient = {
		{ x = 471.969, y = -1604.140, z = 1020.9, interior = 1, dimension = 1 }, -- NSK
		{ x = 1966.223, y = 306.869, z = 661, interior = 1, dimension = 1 }, -- GRK
		{ x = -1984.820, y = 2008.783, z = 1798.2, interior = 2, dimension = 2 }, -- MSK
	},
	doctor_pos = {
		{ x = 471.928, y = -1604.925, z = 1020.968, rz = 0 }, -- NSK
		{ x = 1966.074, y = 306.147, z = 660.974, rz = 0 }, -- GRK
		{ x = -1984.437, y = 2008.161, z = 1797.890, rz = 360 }, -- MSK
	},
}

QUEST_DATA = {
	id = "task_medic_4",

	title = "Практика реанимированния",
	description = "",

	replay_timeout = 0,

	CheckToStart = function( player )
		return player:IsInFaction( )
	end,

	OnAnyFinish = {
		client = function( )
			localPlayer:setAnimation( )
		end
	},

	tasks = {
		[ 1 ] = {
			name = "Поговори с доктором",

			Setup = {
				client = function ( )
					CreateQuestPointToNPCWithDialog( QUEST_PEDS[ localPlayer:GetFactionDutyCity( ) ], {
						{
							text = [[— Твоя задача провести операцию!]],
						},
					}, "task_medic_4_step_1", nil, true )
				end,
			},

			event_end_name = "task_medic_4_step_1",
		},
		[ 2 ] = {
			name = "Зайди в операционную",

			Setup = {
				client = function ( )
					local city = localPlayer:GetFactionDutyCity( )

					CreateQuestPoint( POSITIONS.resuscitation[ city ], function ( )
						CEs.marker:destroy( )

						triggerServerEvent( "task_medic_4_step_2", localPlayer )
					end, nil, 0.7, nil, nil, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
				end,
			},

			event_end_name = "task_medic_4_step_2",
		},
		[ 3 ] = {
			name = "Проведи операцию",

			Setup = {
				client = function ( )
					local city = localPlayer:GetFactionDutyCity( )
					local current_action = 0
					local heart_has_good_state = true
					local actions = {
						{
							{ "Нажми", "mouse2", "чтобы взять скальпель" },
							{ "Нажимай", "lalt", "чтобы сделать разрез", click_count = 10, key_text = "ALT" },
							{ "Нажимай", "mouse2", "чтобы передвинуть трахею", click_count = 10 },
							{ "Удерживай", "lalt", "чтобы зашить разрез", hold = true, key_text = "ALT" },
						},
						{
							{ "Нажми", "lalt", "чтобы взять инструмент", key_text = "ALT" },
							{ "Удерживай", "mouse2", "чтобы пробить легкие", hold = true },
							{ "Нажми", "lalt", "чтобы продуть легкие", key_text = "ALT" },
						},
						{
							{ "Нажми", "mouse1", "чтобы взять телескопию" },
							{ "Удерживай", "mouse2", "чтобы ввести трубку", hold = true },
							{ "Удерживай", "lalt", "чтобы достать трубку", hold = true, key_text = "ALT" },
						},
						{
							{ "Нажми", "mouse2", "чтобы взять скальпель" },
							{ "Нажимай", "lalt", "чтобы сделать разрез", click_count = 10, key_text = "ALT" },
							{ "Нажимай", "mouse2", "чтобы установить кардио стимулятор", click_count = 10 },
							{ "Удерживай", "lalt", "чтобы зашить разрез", hold = true, key_text = "ALT" },
						},
					}

					CreateQuestPoint( POSITIONS.doctor_pos[ city ], function ( )
						CEs.marker:destroy( )

						CEs.doGame = function ( action )
							local conf = actions[ current_action ][ action ]
							if not conf then
								CEs.doActions( )
								return
							end

							if conf.click_count then
								CEs.game = ibInfoPressKeyProgress( {
									do_text = conf[ 1 ],
									key = conf[ 2 ],
									text = conf[ 3 ],
									black_bg = 0x00000000,
									click_count = conf.click_count,
									end_handler = function ( )
										CEs.doGame( action + 1 )
									end
								} )
							else
								ibInfoPressKey( {
									do_text = conf[ 1 ],
									key = conf[ 2 ],
									text = conf[ 3 ],
									key_text = conf.key_text or nil,
									hold = conf.hold or nil,
									black_bg = 0x00000000,
									key_handler = function ( )
										CEs.doGame( action + 1 )
									end
								} )
							end

						end

						CEs.doActions = function ( )
							if math.random( 1, 4 ) == 1 and current_action > 0 and not heart_has_good_state then -- heart was stopped
								triggerEvent( "StartPlayerReanimation", resourceRoot, "successTrainingReanimation", "failTrainingReanimation" )
								return
							end

							heart_has_good_state = false
							current_action = current_action + 1

							if not actions[ current_action ] then
								setPedAnimation( localPlayer )

								triggerServerEvent( "task_medic_4_step_3", localPlayer )
							else
								localPlayer.rotation = Vector3( 0, 0, POSITIONS.doctor_pos[ city ].rz )
								localPlayer.position = Vector3( POSITIONS.doctor_pos[ city ] )
								localPlayer:setAnimation( "bd_fire", "wash_up", -1, true, false, false, false )

								CEs.doGame( 1 )
							end
						end

						CEs.successReanimation = function ( )
							heart_has_good_state = true
							CEs.doActions( )
						end
						addEvent( "successTrainingReanimation" )
						addEventHandler( "successTrainingReanimation", resourceRoot, CEs.successReanimation )

						CEs.failTrainingReanimation = function ( )
							triggerServerEvent( "PlayerFailStopQuest", localPlayer, "Вы провалили реанимацию" )
						end
						addEvent( "failTrainingReanimation" )
						addEventHandler( "failTrainingReanimation", resourceRoot, CEs.failTrainingReanimation )

						localPlayer.rotation = Vector3( 0, 0, POSITIONS.doctor_pos[ city ].rz )
						localPlayer.position = Vector3( POSITIONS.doctor_pos[ city ] )
						localPlayer:setAnimation( "bd_fire", "wash_up", -1, true, false, false, false )

						ibInfoPressKey( {
							do_text = "Нажмите",
							key = "lalt",
							text = "чтобы осмотреть",
							key_text = "ALT",
							black_bg = 0x00000000,
							key_handler = function ( )
								CEs.doActions( )
							end
						} )
					end, nil, 0.7, nil, nil, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
				end,
			},

			CleanUp = {
				client = function ( )
					removeEventHandler( "successTrainingReanimation", resourceRoot, CEs.successReanimation )
					removeEventHandler( "failTrainingReanimation", resourceRoot, CEs.failTrainingReanimation )
				end
			},

			event_end_name = "task_medic_4_step_3",
		},
		[ 4 ] = {
			name = "Вернись к доктору",

			Setup = {
				client = function ( )
					CreateQuestPointToNPCWithDialog( QUEST_PEDS[ localPlayer:GetFactionDutyCity( ) ], {
						{
							text = [[— Неплохая работа, так держать!]],
						},
					}, "task_medic_4_step_4", nil, true )
				end,
			},

			event_end_name = "task_medic_4_step_4",
		},
	},


	GiveReward = function( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_medic_4", 13 )
	end,
	success_text = "Задача выполнена! Вы получили +13 очков",

	rewards = {
		faction_exp = 13,
	},
}