POSITIONS = {
	table = { x = -2406.083, y = -257.978 + 860, z = 20.105 },
	warehouse = { x = -2406.894, y = -252.225 + 860, z = 20.105 },
	pos = { x = -2409.198, y = -269.054 + 860, z = 20.118 },
	pos_weapon = { x = -2409.166, y = -269.834 + 860, z = 19.2 },
}

GEs = { }

QUEST_DATA = {
	id = "task_military_6",

	title = "Чистка вооружения",
	description = "",

	replay_timeout = 0,

	CheckToStart = function ( player )
		return player:IsInFaction( )
	end,

	OnAnyFinish = {
		client = function( )
			localPlayer:setAnimation( )

			if isElement( GEs.object ) then
				GEs.object:destroy( )
			end

			toggleControl( "fire", true )
		end
	},

	tasks = {
		[ 1 ] = {
			name = "Поговори с прапорщиком",

			Setup = {
				client = function( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Твоя задача взять оружие со склада и прочистить его.]],
						},
						{
							text = [[— Держи инструменты, пригодятся.]],
							info = true,
						},
					}, "task_military_6_step_1", _, true )
				end,
			},

			event_end_name = "task_military_6_step_1",
		},
		[ 2 ] = {
			name = "Взять оружие",

			Setup = {
				client = function ( )
					toggleControl( "fire", false )

					CreateQuestPoint( POSITIONS.warehouse, function ( )
						CEs.marker:destroy( )

						GEs.object = Object( 355, localPlayer.position )
						exports.bone_attach:attachElementToBone( GEs.object, localPlayer, 3, 0, -0.2, -0.05, -10, -45, 0 )

						triggerServerEvent( "task_military_6_step_2", localPlayer )
					end, nil, 0.7, 0, 0, function ( ) return not localPlayer.vehicle end, nil, nil, "cylinder", 0, 100, 230, 50 )
				end,
			},

			event_end_name = "task_military_6_step_2",
		},
		[ 3 ] = {
			name = "Займи позицию",

			Setup = {
				client = function ( )
					CreateQuestPoint( POSITIONS.pos, function ( )
						CEs.marker:destroy( )

						GEs.object:destroy( )
						GEs.object = Object( 355, Vector3( POSITIONS.pos_weapon ) )
						localPlayer:setAnimation( "bomber", "bom_plant_loop", -1, true, false, false, false )

						triggerServerEvent( "task_military_6_step_3", localPlayer )
					end, nil, 2.7, 0, 0, function ( ) return not localPlayer.vehicle end )
				end,
			},

			event_end_name = "task_military_6_step_3",
		},
		[ 4 ] = {
			name = "Очисти оружие",

			Setup = {
				client = function ( )
					CEs.game = ibInfoPressKeyProgress( {
						do_text = "Нажимай",
						text = "чтобы разобрать оружие",
						key = "mouse2",
						black_bg = 0x00000000,
						click_count = 10,
						end_handler = function ( )
							CEs.game = ibInfoPressKey( {
								do_text = "Удерживай",
								text = "чтобы прочистить оружие",
								key = "lalt",
								key_text = "ALT",
								hold = true,
								black_bg = 0x00000000,
								key_handler = function ( )
									CEs.game = ibInfoPressKeyProgress( {
										do_text = "Нажимай",
										text = "чтобы собрать оружие",
										key = "mouse2",
										black_bg = 0x00000000,
										click_count = 10,
										end_handler = function ( )
											localPlayer:setAnimation( )
											GEs.object:destroy( )
											GEs.object = Object( 355, localPlayer.position )
											exports.bone_attach:attachElementToBone( GEs.object, localPlayer, 3, 0, -0.2, -0.05, -10, -45, 0 )

											triggerServerEvent( "task_military_6_step_4", localPlayer )
										end,
									} )
								end,
							} )
						end,
					} )

					localPlayer.weaponSlot = 0
					toggleControl( "next_weapon", false )
					toggleControl( "previous_weapon", false )
				end,
			},

			CleanUp = {
				client = function ( )
					toggleControl( "next_weapon", true )
					toggleControl( "previous_weapon", true )
				end
			},

			event_end_name = "task_military_6_step_4",
		},
		[ 5 ] = {
			name = "Вернуть оружие на склад",

			Setup = {
				client = function ( )
					CreateQuestPoint( POSITIONS.warehouse, function ( )
						CEs.marker:destroy( )
						GEs.object:destroy( )

						triggerServerEvent( "task_military_6_step_5", localPlayer )
					end, nil, 0.7, 0, 0, function ( ) return not localPlayer.vehicle end, nil, nil, "cylinder", 0, 100, 230, 50 )
				end,
			},

			event_end_name = "task_military_6_step_5",
		},
		[ 6 ] = {
			name = "Вернись к прапорщику",

			Setup = {
				client = function( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Неплохая работа боец, так держать!]],
						},
					}, "task_military_6_step_6", _, true )
				end,
			},

			event_end_name = "task_military_6_step_6",
		},
	},

	GiveReward = function ( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_military_6", 15 )
	end,
	success_text = "Задача выполнена! Вы получили +15 очков",

	rewards = {
		faction_exp = 15,
	},
}