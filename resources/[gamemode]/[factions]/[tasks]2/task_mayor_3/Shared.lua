BOX_TARGET_VALUE = 3
START_POSITIONS = {
	{ x = -74.967, y = -865.456, z = 1047.537 },
	{ x = 2311.471, y = -94.094, z = 671.013 },
	{ x = 1360.026, y = 2461.148, z = 2292.546 },
}
END_POSITIONS = {
	{ x = -43.988, y = -875.820, z = 1047.537 },
	{ x = 2268.889, y = -74.276, z = 670.997 },
	{ x = 1352.931, y = 2424.899, z = 2285.563 },
}
CARRYING_CONTROLS = { "jump", "sprint", "fire", "crouch", "aim_weapon", "enter_exit", "next_weapon", "previous_weapon", "enter_passenger" }

QUEST_DATA = {
	id = "task_mayor_3",

	title = "Сортировка документов",
	description = "",

	replay_timeout = 0,

	CheckToStart = function ( player )
		return player:IsInFaction( )
	end,

	OnAnyFinish = {
		client = function( )
			for k, v in pairs( CARRYING_CONTROLS ) do
				toggleControl( v, true )
			end

			setPedAnimation( localPlayer )
		end
	},

	tasks = {
		[ 1 ] = {
			name = "Поговори с клерком",

			Setup = {
				client = function( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Твоя задача взять рассортировать документы
									и отнести их на отгрузку.]],
						},
					}, "task_mayor_3_step_1", _, true )
				end,
			},

			event_end_name = "task_mayor_3_step_1",
		},
		[ 2 ] = {
			name = "Займи рабочее место",

			Setup = {
				client = function( )
					CreateQuestPoint( START_POSITIONS[ localPlayer:GetFactionDutyCity( ) ], function ( )
						triggerServerEvent( "task_mayor_3_step_2", localPlayer )
					end, nil, 0.7, nil, nil, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
				end,
			},

			event_end_name = "task_mayor_3_step_2",
		},
		[ 3 ] = {
			name = "Рассортируй документы",

			Setup = {
				client = function ( )
					CEs.game = ibInfoPressKey( {
						do_text = "Нажми",
						text = "чтобы начать сортировку",
						key = "lalt",
						key_text = "ALT",
						black_bg = 0x00000000,
						key_handler = function ( )
							CEs.game = ibInfoPressKeyProgress( {
								do_text = "Нажимай",
								text = "чтобы отсортировать документ",
								key = "mouse2",
								black_bg = 0x00000000,
								click_count = 10,
								black_bg = 0x00000000,
								end_handler = function ( )
									CEs.game = ibInfoPressKey( {
										do_text = "Нажми",
										text = "чтобы закончить сортировку",
										key = "lalt",
										key_text = "ALT",
										black_bg = 0x00000000,
										key_handler = function ( )
											triggerServerEvent( "task_mayor_3_step_3", localPlayer )
										end,
									} )
								end,
							} )
						end,
					} )
				end,
			},

			event_end_name = "task_mayor_3_step_3",
		},
		[ 4 ] = {
			name = "Перенеси ящик на отгрузку",

			Setup = {
				client = function( )
					local city = localPlayer:GetFactionDutyCity( )
					local counter = 0

					CEs.carryingControl = function ( state )
						local timer_state = isTimer( CEs.timer )

						local function setState( st )
							for k, v in pairs( CARRYING_CONTROLS ) do
								toggleControl( v, not st )
							end
						end
						setState( state )

						if not state and timer_state then
							killTimer( CEs.timer )
						elseif state and not timer_state then
							CEs.timer = Timer( function( )
								setState( state )
							end, 10, 0 )
						end
					end

					CEs.watch = WatchElementCondition( localPlayer, {
						condition = function( self )
							if self.element.vehicle then
								FailCurrentQuest( "Запрещено пользоваться ТС во время данного задания" )
								return true
							elseif self.element.interior == 0 then
								FailCurrentQuest( "Взялся за работу, так доделывай её до конца" )
								return true
							end
						end,
					} )

					CEs.initCycle = function ( )
						CreateQuestPoint( START_POSITIONS[ city ], function ( )
							CEs.marker:destroy( )

							CEs.object = Object( 1271, localPlayer.position )
							CEs.object.scale = 0.5
							exports.bone_attach:attachElementToBone( CEs.object, localPlayer, 8, 0.15, 0.4, 0.2, 0, 180, 0 )
							setPedAnimation( localPlayer, "CARRY", "crry_prtial", 0, true, true, false, true )
							localPlayer.weaponSlot = 0
							CEs.carryingControl( true )

							CreateQuestPoint( END_POSITIONS[ city ], function ( )
								CEs.marker:destroy( )

								counter = counter + 1
								destroyElement( CEs.object )
								setPedAnimation( localPlayer, "CARRY", "liftup", 0, false, false, false, false )
								CEs.carryingControl( false )

								if counter >= BOX_TARGET_VALUE then
									triggerServerEvent( "task_mayor_3_step_4", localPlayer )
								else
									localPlayer:ShowInfo( "Осталось перенести еще " .. BOX_TARGET_VALUE - counter .. " шт." )
									CEs.initCycle( )
								end
							end, nil, 0.7, nil, nil, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
						end, nil, 0.7, nil, nil, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
					end

					CEs.initCycle( )
				end,
			},

			event_end_name = "task_mayor_3_step_4",
		},
		[ 5 ] = {
			name = "Вернись к клерку",

			Setup = {
				client = function( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Неплохая работа, так держать!]],
						},
					}, "task_mayor_3_step_5", _, true )
				end,
			},

			event_end_name = "task_mayor_3_step_5",
		},
	},

	GiveReward = function ( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_mayor_3", 19 )
	end,
	success_text = "Задача выполнена! Вы получили +19 очков",

	rewards = {
		faction_exp = 19,
	},
}