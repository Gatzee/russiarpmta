BOX_TARGET_VALUE = 5
POSITIONS = {
	{
		p = { x = -393.711, y= -1659.453 + 860, z = 20.913 },
		p2 = { x = -362.774, y = -1664.768 + 860, z = 22.288 },
	},
	{
		p = { x = 1925.423, y = -722.823 + 860, z = 60.789 },
		p2 = { x = 1958.433, y = -726.161 + 860, z = 60.776 },
	},
}
ENTERS = {
	{ x = -358.540, y = -1666.366 + 860, z = 22.286 },
	{ x = 1945.049, y = -735.493 + 860, z = 60.777 },
}
CARRYING_CONTROLS = { "jump", "sprint", "fire", "crouch", "aim_weapon", "enter_exit", "next_weapon", "previous_weapon", "enter_passenger" }

QUEST_DATA = {
	id = "task_police_3",

	title = "Разгрузка транспорта",
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
			name = "Поговори с лейтенантом",

			Setup = {
				client = function( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Твоя задача разгрузить рабочий транспорт.]],
						},
						{
							text = [[— Груз хрупкий, будь аккуратнее боец!]],
							info = true,
						},
					}, "PlayerAction_Task_Police_3_step_1", _, true )
				end,
			},

			event_end_name = "PlayerAction_Task_Police_3_step_1",
		},
		[ 2 ] = {
			name = "Разгрузить ТС",

			Setup = {
				client = function ( )
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

					CEs.watch_cycle = WatchElementCondition( localPlayer, {
						condition = function( self )
							if self.element.vehicle then
								FailCurrentQuest( "Запрещено пользоваться ТС во время данного задания" )
								return true
							end
						end,
					} )

					CEs.initCycle = function ( )
						CreateQuestPoint( POSITIONS[ city ].p, function ( )
							CEs.marker:destroy( )

							CEs.object = Object( 1271, localPlayer.position )
							CEs.object.scale = 0.5
							exports.bone_attach:attachElementToBone( CEs.object, localPlayer, 8, 0.15, 0.4, 0.2, 0, 180, 0 )
							setPedAnimation( localPlayer, "CARRY", "crry_prtial", 0, true, true, false, true )
							localPlayer.weaponSlot = 0
							CEs.carryingControl( true )

							CreateQuestPoint( POSITIONS[ city ].p2, function ( )
								CEs.marker:destroy( )

								counter = counter + 1
								destroyElement( CEs.object )
								setPedAnimation( localPlayer, "CARRY", "liftup", 0, false, false, false, false )
								CEs.carryingControl( false )

								if counter >= BOX_TARGET_VALUE then
									triggerServerEvent( "PlayerAction_Task_Police_3_step_2", localPlayer )
								else
									localPlayer:ShowInfo( "Осталось перенести еще " .. BOX_TARGET_VALUE - counter .. " шт." )
									CEs.initCycle( )
								end
							end, nil, 0.7, 0, 0, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
						end, nil, 0.7, 0, 0, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
					end

					CEs.initCycle( )
				end,
			},

			event_end_name = "PlayerAction_Task_Police_3_step_2",
		},
		[ 3 ] = {
			name = "Вернись к лейтенанту",

			Setup = {
				client = function( )
					CreateQuestPoint( ENTERS[ localPlayer:GetFactionDutyCity( ) ], function ( )
						CEs.marker:destroy( )

						CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
							{
								text = [[— Неплохая работа боец, так держать!]],
							},
						}, "PlayerAction_Task_Police_3_step_3", _, true )
					end, nil, 1.7, 0, 0, function ( ) return not localPlayer.vehicle end )
				end,
			},

			event_end_name = "PlayerAction_Task_Police_3_step_3",
		},
	},

	GiveReward = function ( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_police_3", 22 )
	end,
	success_text = "Задача выполнена! Вы получили +22 очков",

	rewards = {
		faction_exp = 22,
	},
}