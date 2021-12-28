QUEST_DATA = {
	id = "task_fsin_3",

	title = "Патрулирование территории",
	description = "",

	replay_timeout = 0,

	CheckToStart = function( player )
		return player:IsInFaction( )
	end,

	tasks = {
		[ 1 ] = {
			name = "Подойди к дежурному",

			Setup = {
				client = function ( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Твоя задача патрулирование тюрьмы.]],
						},
						{
							text = [[— Смотри чтоб никто не сбежал!]],
							info = true,
						},
					}, "task_fsin_3_step_1", nil, true )
				end,
			},

			event_end_name = "task_fsin_3_step_1",
		},
		[ 2 ] = {
			name = "Пройди по маршруту",

			Setup = {
				client = function ( )
					local path_num = math.random( 1, #PATHS )
					local currentPoint = 0

					CEs.initWatching = function ( )
						StartQuestTimerWait( 20000, "Осмотри территорию", nil, nil, function( )
							CEs.initNextPoint( )
							return true
						end )
					end

					CEs.initNextPoint = function ( )
						currentPoint = currentPoint + 1

						if not PATHS[ path_num ][ currentPoint ] then
							triggerServerEvent( "task_fsin_3_step_2", localPlayer )
						else
							CreateQuestPoint( PATHS[ path_num ][ currentPoint ], function ( )
								CEs.marker:destroy( )
								CEs.initWatching( )
							end, nil, 1.7, 0, 0, function ( )
								return not localPlayer.vehicle
							end, nil, nil, "cylinder", 0, 100, 230, 50 )
						end
					end

					CEs.initNextPoint( )
				end,
			},

			event_end_name = "task_fsin_3_step_2",
		},
		[ 3 ] = {
			name = "Доложи дежурному",

			Setup = {
				client = function ( )
					CreateQuestPoint( { x = -2799.798, y = 1608.287 + 860, z = 14.567 }, function ( )
						CEs.marker:destroy( )

						CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
							{
								text = [[— Отлично справился боец!]],
							},
						}, "task_fsin_3_step_3", nil, true )
					end, nil, 1.7, 0, 0, function ( ) return not localPlayer.vehicle end )
				end,
			},

			event_end_name = "task_fsin_3_step_3",
		},
	},


	GiveReward = function( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_fsin_3", 45 )
	end,
	success_text = "Задача выполнена! Вы получили +45 очков",

	rewards = {
		faction_exp = 45,
	},
}