BOX_TARGET_VALUE = 5
POSITIONS = {
	{
		p = { x = 354.861, y = -2085.531, z = 20.955 },
		p2 = { x = 341.354, y = -2054.935, z = 20.962 },
	},
	{
		p = { x = 2202.060, y = -661.695, z = 60.714 },
		p2 = { x = 2207.379, y = -605.706, z = 61.584 },
	},
	{
		p = { x = -1433.370, y = 2498.913, z = 10.714 },
		p2 = { x = -1469.733, y = 2548.795, z = 10.505 },
	},
}
ENTERS = {
	{ x = 344.900, y = -2055.125, z = 20.962 },
	{ x = 2233.869, y = -642.198, z = 60.824 },
	{ x = -1473.567, y = 2546.785, z = 11.468 },
}
CARRYING_CONTROLS = { "jump", "sprint", "fire", "crouch", "aim_weapon", "enter_exit", "next_weapon", "previous_weapon", "enter_passenger" }

QUEST_DATA = {
	id = "task_dps_3",

	title = "Загрузка транспорта",
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
							text = [[— Твоя задача загрузить рабочий транспорт.]],
						},
						{
							text = [[— Груз хрупкий, будь аккуратнее боец!]],
							info = true,
						},
					}, "task_dps_3_step_1", _, true )
				end,
			},

			event_end_name = "task_dps_3_step_1",
		},
		[ 2 ] = {
			name = "Загрузить ТС",

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
						CreateQuestPoint( POSITIONS[ city ].p2, function ( )
							CEs.marker:destroy( )

							CEs.object = Object( 1271, localPlayer.position )
							CEs.object.scale = 0.5
							exports.bone_attach:attachElementToBone( CEs.object, localPlayer, 8, 0.15, 0.4, 0.2, 0, 180, 0 )
							setPedAnimation( localPlayer, "CARRY", "crry_prtial", 0, true, true, false, true )
							localPlayer.weaponSlot = 0
							CEs.carryingControl( true )

							CreateQuestPoint( POSITIONS[ city ].p, function ( )
								CEs.marker:destroy( )

								counter = counter + 1
								destroyElement( CEs.object )
								setPedAnimation( localPlayer, "CARRY", "liftup", 0, false, false, false, false )
								CEs.carryingControl( false )

								if counter >= BOX_TARGET_VALUE then
									triggerServerEvent( "task_dps_3_step_2", localPlayer )
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

			event_end_name = "task_dps_3_step_2",
		},
		[ 3 ] = {
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
						}, "task_dps_3_step_3", _, true )
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

			event_end_name = "task_dps_3_step_3",
		},
	},

	GiveReward = function ( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_dps_3", 23 )
	end,
	success_text = "Задача выполнена! Вы получили +23 очков",

	rewards = {
		faction_exp = 23,
	},
}