QUEST_DATA = {
	id = "task_fsin_4",

	title = "Проверка заключенных",
	description = "",

	replay_timeout = 0,

	CheckToStart = function( player )
		return player:IsInFaction( )
	end,

	OnAnyFinish = {
		client = function( )
			toggleControl( "fire", true )
			toggleControl( "enter_exit", true )
			localPlayer:setAnimation( )
		end
	},

	tasks = {
		[ 1 ] = {
			name = "Подойди к дежурному",

			Setup = {
				client = function ( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Твоя задача проверить заключенных тюрьмы.]],
						},
						{
							text = [[— Главное будь аккуратным!]],
							info = true,
						},
					}, "task_fsin_4_step_1", nil, true )
				end,
			},

			event_end_name = "task_fsin_4_step_1",
		},
		[ 2 ] = {
			name = "Пройди по маршруту",

			Setup = {
				client = function ( )
					local peds = { }
					local gotPeds = { }
					local currentPoint = 0
					local canFind = false

					CEs.fillTable = function ( )
						local idx = math.random( 1, #POINTS )

						if not gotPeds[ idx ] then
							gotPeds[ idx ] = true
							table.insert( peds, POINTS[ idx ] )
						end

						if #peds < 10 then
							CEs.fillTable( )
						end
					end

					CEs.fillTable( )

					CEs.initWatching = function ( )
						toggleControl( "fire", false )
						toggleControl( "enter_exit", false )
						localPlayer:setAnimation( "bomber", "bom_plant_loop", -1, true, false, false, false )

						StartQuestTimerWait( 10000, "Осмотри территорию", nil, nil, function ( )
							local distance = getDistanceBetweenPoints3D( Vector3( peds[ currentPoint ] ), localPlayer.position )
							local is_wrong_distance = distance > 15

							if is_wrong_distance then
								localPlayer:ShowError( "Проверять следует вблизи указанного участка" )
							end
							CEs.initNextPoint( is_wrong_distance )

							return true
						end )
					end

					CEs.initMiniGame = function ( )
						ibInfoPressKey( {
							do_text = "Нажми",
							key = "mouse1",
							text = "чтобы взять заточку",
							black_bg = 0x00000000,
							key_handler = function ( )
								ibInfoPressKey( {
									do_text = "Удерживай",
									key = "mouse2",
									text = "чтобы сломать заточку",
									hold = true,
									black_bg = 0x00000000,
									key_handler = function ( )
										ibInfoPressKey( {
											do_text = "Нажми",
											key = "lalt",
											text = "чтобы сложить заточку",
											key_text = "ALT",
											black_bg = 0x00000000,
											key_handler = function ( )
												CEs.initNextPoint( )
											end
										} )
									end
								} )
							end
						} )
					end

					CEs.initNextPoint = function ( is_wrong_distance )
						if not is_wrong_distance then
							if canFind and math.random( 0, 1 ) == 1 then
								canFind = false
								CEs.initMiniGame( )
								return
							end

							toggleControl( "fire", true )
							toggleControl( "enter_exit", true )
							localPlayer:setAnimation( )

							canFind = true
							currentPoint = currentPoint + 1
						end

						if not peds[ currentPoint ] then
							triggerServerEvent( "task_fsin_4_step_2", localPlayer )
						else
							CreateQuestPoint( peds[ currentPoint ], function ( )
								CEs.marker:destroy( )
								CEs.initWatching( )
							end, nil, 1.7, 0, 0, function ( )
								return not localPlayer.vehicle
							end, "lalt", "Нажми 'Левый ALT' чтобы осмотреть", "cylinder", 0, 100, 230, 50 )
						end
					end

					CEs.initNextPoint( )
				end,
			},

			event_end_name = "task_fsin_4_step_2",
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
						}, "task_fsin_4_step_3", nil, true )
					end, nil, 1.7, 0, 0, function ( ) return not localPlayer.vehicle end )
				end,
			},

			event_end_name = "task_fsin_4_step_3",
		},
	},


	GiveReward = function( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_fsin_4", 63 )
	end,
	success_text = "Задача выполнена! Вы получили +63 очков",

	rewards = {
		faction_exp = 63,
	},
}