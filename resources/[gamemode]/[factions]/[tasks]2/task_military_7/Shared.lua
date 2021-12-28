POSITIONS = {
	table = { x = -2406.083, y = -257.978, z = 20.105 },
	warehouse = { x = -2406.894, y = -252.225, z = 20.105 },
	pos = { x = -2535.825, y = -165.388, z = 20.103 },
	pos_end = { x = -2562.268, y = -180.460, z = 20.103 },
}

GEs = { }

QUEST_DATA = {
	id = "task_military_7",

	title = "Практическая стрельба",
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
		end
	},

	tasks = {
		[ 1 ] = {
			name = "Поговори с прапорщиком",

			Setup = {
				client = function( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Твоя задача взять оружие со склада
									и пройти тактическую подготовку!]],
						},
					}, "task_military_7_step_1", _, true )
				end,
			},

			event_end_name = "task_military_7_step_1",
		},
		[ 2 ] = {
			name = "Взять оружие",

			Setup = {
				client = function ( )
					CreateQuestPoint( POSITIONS.warehouse, function ( )
						CEs.marker:destroy( )

						GEs.object = Object( 355, localPlayer.position )
						exports.bone_attach:attachElementToBone( GEs.object, localPlayer, 3, 0, -0.2, -0.05, -10, -45, 0 )

						triggerServerEvent( "task_military_7_step_2", localPlayer )
					end, nil, 0.7, 0, 0, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
				end,
			},

			event_end_name = "task_military_7_step_2",
		},
		[ 3 ] = {
			name = "Займи позицию",

			Setup = {
				client = function ( )
					CreateQuestPoint( POSITIONS.pos, function ( )
						CEs.marker:destroy( )
						GEs.object:destroy( )

						triggerServerEvent( "task_military_7_step_3", localPlayer )
					end, nil, 0.7, 0, 0, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
				end,
			},

			event_end_name = "task_military_7_step_3",
		},
		[ 4 ] = {
			name = "Порази мишени",

			Setup = {
				client = function ( )
					local dim = localPlayer:GetUniqueDimension( )
					local amount = #TARGETS
					local time = getRealTimestamp( )
					local time_to_fail = 5 * 60 * 1000
					local counter = 0
					local points = 0
					local damaged = { }

					StartQuestTimerFail( time_to_fail, "Порази мишени. Очков: 0", "Слишком медленно!" )

					-- create targets
					for target_id, v in pairs( TARGETS ) do
						for idx, c in pairs( COMPONENTS_OF_TARGET ) do
							local object = Object( c.model, v.x, v.y, v.z + 0.35, 0, 0, v.rz )
							object.dimension = dim
							object.scale = 0.75

							addEventHandler( "onClientObjectBreak", object, function ( )
								if damaged[ target_id ] then
									return
								end

								damaged[ target_id ] = true
								points = points + ( c.is_head and 3 or 1 )
								counter = counter + 1
								StartQuestTimerFail( time_to_fail - ( getRealTimestamp( ) - time ) * 1000, "Порази мишени. Очков: " .. points, "Слишком медленно!" )

								if counter == amount then
									CEs.createExit( )
								end
							end )
						end
					end

					for i, v in pairs( POLYGON ) do
						v.element.dimension = dim

						if v.element2 then
							v.element2.dimension = dim
						end
					end

					CEs.createExit = function ( )
						CreateQuestPoint( POSITIONS.pos_end, function ( )
							CEs.marker:destroy( )

							GEs.object = Object( 355, localPlayer.position )
							exports.bone_attach:attachElementToBone( GEs.object, localPlayer, 3, 0, -0.2, -0.05, -10, -45, 0 )

							triggerServerEvent( "task_military_7_step_4", localPlayer )
						end, nil, 0.7, 0, dim, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
					end
				end,

				server = function ( player )
					player:GiveWeapon( 30, 120, true, true )
					player:Teleport( nil, player:GetUniqueDimension( ) )
				end,
			},

			CleanUp = {
				client = function ( )
					for i, v in pairs( POLYGON ) do
						v.element.dimension = 0
					end
				end,

				server = function ( player )
					player:Teleport( nil, 0 )
				end,
			},

			event_end_name = "task_military_7_step_4",
		},
		[ 5 ] = {
			name = "Вернуть оружие на склад",

			Setup = {
				client = function ( )
					CreateQuestPoint( POSITIONS.warehouse, function ( )
						CEs.marker:destroy( )
						GEs.object:destroy( )

						triggerServerEvent( "task_military_7_step_5", localPlayer )
					end, nil, 0.7, 0, 0, localPlayer.vehicle, nil, nil, "cylinder", 0, 100, 230, 50 )
				end,
			},

			event_end_name = "task_military_7_step_5",
		},
		[ 6 ] = {
			name = "Вернись к прапорщику",

			Setup = {
				client = function( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Неплохая работа боец, так держать!]],
						},
					}, "task_military_7_step_6", _, true )
				end,
			},

			event_end_name = "task_military_7_step_6",
		},
	},

	GiveReward = function ( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_military_7", 30 )
	end,
	success_text = "Задача выполнена! Вы получили +30 очков",

	rewards = {
		faction_exp = 30,
	},
}