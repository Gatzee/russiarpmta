BOX_TARGET_VALUE = 3
START_POSITIONS = {
	{ x = 1.461, y = -1699.318, z = 21.696 },
	{ x = 2330.176, y = -980.085, z = 63.111 },
	{ x = -210.540, y = 2125.736, z = 21.609 },
}
VEHICLE_POSITIONS = {
	{ x = -4.223, y = -1740.957, z = 20.821 },
	{ x = 2261.387, y = -1025.956, z = 60.667 },
	{ x = -184.212, y = 2113.945, z = 21.404 },
}
TARGET_POINTS = {
	{
		player = {
			{ x = -355.724, y = -1665.998, z = 22.286 },
			{ x = 395.674, y = -2450.230, z = 23.532 },
			{ x = 338.502, y = -2039.723, z = 21.819 },
		},
		vehicle = {
			{ x = -324.311, y = -1692.798, z = 20.781 },
			{ x = 392.125, y = -2423.437, z = 20.585 },
			{ x = 356.914, y = -2012.478, z = 20.745 },
		},
	},
	{
		player = {
			{ x = 1959.202, y = -725.597, z = 60.784 },
			{ x = 1908.774, y = -521.617, z = 60.795 },
			{ x = 2204.890, y = -603.169, z = 61.584 },
		},
		vehicle = {
			{ x = 1931.055, y = -748.711, z = 60.550 },
			{ x = 1921.725, y = -481.901, z = 60.553 },
			{ x = 2183.301, y = -648.904, z = 60.627 },
		},
	},
	{
		player = {
			{ x = 1224.370, y = 2194.887, z = 8.810 },
			{ x = 1422.271, y = 2726.637, z = 10.910 },
			{ x = -1478.037, y = 2543.884, z = 10.505 },
		},
		vehicle = {
			{ x = 1228.199, y = 2226.792, z = 8.810 },
			{ x = 1418.682, y = 2698.709, z = 9.966 },
			{ x = -1502.857, y = 2470.193, z = 10.505 },
		},
	},
}
END_POINTS = {
	{ x = 1.479, y = -1696.466, z = 21.696 },
	{ x = 2271.135, y = -951.078, z = 61.308 },
	{ x = -119.178, y = 2117.933, z = 21.607 },
}
CARRYING_CONTROLS = { "jump", "sprint", "fire", "crouch", "aim_weapon", "enter_exit", "next_weapon", "previous_weapon", "enter_passenger" }

GEs = {
	vehicles = { },
	blockVehicleInit = function ( _, seat )
		if seat == 0 then
			cancelEvent( )
		end
	end,
	blockVehicleByPlayer = function ( player, seat )
		if seat == 0 and source ~= GEs.vehicles[ player ] then
			cancelEvent( )
		end
	end,
}

QUEST_DATA = {
	id = "task_mayor_4",

	title = "Развозка документов",
	description = "",

	replay_timeout = 0,

	CheckToStart = function ( player )
		return player:IsInFaction( )
	end,

	OnAnyFinish = {
		client = function ( )
			for k, v in pairs( CARRYING_CONTROLS ) do
				toggleControl( v, true )
			end

			setPedAnimation( localPlayer )

			if GEs.vehicle and GEs.vehicleDestroy then
				removeEventHandler( "onClientElementDestroy", GEs.vehicle, GEs.vehicleDestroy )
			end

			GEs.vehicle = nil
			GEs.vehicleDestroy = nil

			if GEs.watch then
				GEs.watch:destroy( )
				GEs.watch = nil
			end
		end,
		server = function ( player )
			GEs.vehicles[ player ] = nil
		end,
	},

	tasks = {
		[ 1 ] = {
			name = "Поговори с клерком",

			Setup = {
				client = function( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Твоя задача доставить документы!]],
						},
					}, "task_mayor_4_step_1", _, true )
				end,
			},

			event_end_name = "task_mayor_4_step_1",
		},
		[ 2 ] = {
			name = "Получи рабочий транспорт",

			Setup = {
				client = function ( )
					local get_vehicle_position = exports.nrp_faction_vehicles:GetVehicleMarkerPositionByFaction( localPlayer:GetFactionDutyCity( ) - 1, localPlayer:GetFaction() )
					if get_vehicle_position then
						CreateQuestPoint( get_vehicle_position, function ( )
							CEs.marker.destroy( )
						end, nil, 5, 0, 0 )
					end

					CEs.timer = Timer( function ( )
						if localPlayer.vehicle and localPlayer.vehicle:GetFaction( ) == localPlayer:GetFaction( ) and localPlayer.vehicleSeat == 0 then
							triggerServerEvent( "task_mayor_4_step_2", localPlayer )
							killTimer( CEs.timer )
						end
					end, 500, 0 )
				end
			},

			event_end_name = "task_mayor_4_step_2",
		},
		[ 3 ] = {
			name = "Подгони транспорт",

			Setup = {
				client = function ( )
					local city = localPlayer:GetFactionDutyCity( )

					CreateQuestPoint( VEHICLE_POSITIONS[ city ], function ( )
						if not localPlayer.vehicleSeat then return end

						if localPlayer.vehicle:GetFaction( ) ~= localPlayer:GetFaction( ) then
							localPlayer:ShowError( "Данный транспорт не подходит для перевозки документов" )
							return
						end

						CEs.marker:destroy( )
						GEs.vehicle = localPlayer.vehicle

						GEs.watch = WatchElementCondition( GEs.vehicle, {
							condition = function( self )
								if self.element.health <= 370 or self.element.inWater then
									FailCurrentQuest( "Рабочий транспорт разбит" )
									return true
								elseif localPlayer.vehicle and localPlayer.vehicle ~= self.element then
									FailCurrentQuest( "Запрещено пользоваться иным ТС во время данного задания" )
									return true
								end
							end,
						} )

						GEs.vehicleDestroy = function ( )
							FailCurrentQuest( "Рабочий транспорт разбит" )
						end
						addEventHandler( "onClientElementDestroy", GEs.vehicle, GEs.vehicleDestroy )

						triggerServerEvent( "task_mayor_4_step_3", localPlayer )
					end, nil, 10 )
				end,
			},

			event_end_name = "task_mayor_4_step_3",
		},
		[ 4 ] = {
			name = "Загрузи транспорт",

			Setup = {
				client = function ( )
					local x, y, z = GEs.vehicle:getBoundingBox( )
					local x2, y2, z2 = getPositionFromElementAtOffset( GEs.vehicle, 0, y - 0.25, 0 )
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

					CEs.initCycle = function ( )
						CreateQuestPoint( START_POSITIONS[ localPlayer:GetFactionDutyCity( ) ], function ( )
							CEs.marker:destroy( )

							CEs.object = Object( 1271, localPlayer.position )
							CEs.object.scale = 0.5
							exports.bone_attach:attachElementToBone( CEs.object, localPlayer, 8, 0.15, 0.4, 0.2, 0, 180, 0 )
							setPedAnimation( localPlayer, "CARRY", "crry_prtial", 0, true, true, false, true )
							localPlayer.weaponSlot = 0
							CEs.carryingControl( true )

							CreateQuestPoint( Vector3( x2, y2, z2 ), function ( )
								CEs.marker:destroy( )

								counter = counter + 1
								destroyElement( CEs.object )
								setPedAnimation( localPlayer, "CARRY", "liftup", 0, false, false, false, false )
								CEs.carryingControl( false )

								if counter >= BOX_TARGET_VALUE then
									triggerServerEvent( "task_mayor_4_step_4", localPlayer )
								else
									localPlayer:ShowInfo( "Осталось перенести еще " .. BOX_TARGET_VALUE - counter .. " шт." )
									CEs.initCycle( )
								end
							end, nil, 0.7, 0, 0, nil, nil, nil, "cylinder", 0, 100, 230, 50 )

						end, nil, 0.7, 0, 0, nil, nil, nil, "cylinder", 0, 100, 230, 50 )
					end

					CEs.initCycle( )
				end,

				server = function ( player )
					GEs.vehicles[ player ] = player.vehicle
					player.vehicle.frozen = true
					addEventHandler( "onVehicleStartEnter", player.vehicle, GEs.blockVehicleInit )
				end,
			},

			CleanUp = {
				server = function ( player )
					if isElement( GEs.vehicles[ player ] ) then
						removeEventHandler( "onVehicleStartEnter", GEs.vehicles[ player ], GEs.blockVehicleInit )
					end
				end,
			},

			event_end_name = "task_mayor_4_step_4",
		},
		[ 5 ] = {
			name = "Отвези документы",

			Setup = {
				client = function( )
					local targets = TARGET_POINTS[ localPlayer:GetFactionDutyCity( ) ]
					GEs.target_num = math.random( 1, #targets.player )
					local target_point = targets.vehicle[ GEs.target_num ]

					CreateQuestPoint( target_point, function ( )
						CEs.marker:destroy( )

						table.insert( CEs, WatchElementCondition( GEs.vehicle, {
							condition = function( self )
								if self.element.velocity.length == 0 then
									triggerServerEvent( "task_mayor_4_step_5", localPlayer )
									return true
								else
									localPlayer:ShowInfo( "Останови транспорт" )
								end
							end,
						} ) )

					end, nil, 10, nil, nil, function ( ) return localPlayer.vehicle == GEs.vehicle end )
				end,

				server = function ( player )
					addEventHandler( "onVehicleStartEnter", GEs.vehicles[ player ], GEs.blockVehicleByPlayer )
				end,
			},

			CleanUp = {
				server = function ( player )
					if isElement( GEs.vehicles[ player ] ) then
						removeEventHandler( "onVehicleStartEnter", GEs.vehicles[ player ], GEs.blockVehicleByPlayer )
					end
				end,
			},

			event_end_name = "task_mayor_4_step_5",
		},
		[ 6 ] = {
			name = "Разгрузи документы",

			Setup = {
				client = function( )
					local counter = 0
					local targets = TARGET_POINTS[ localPlayer:GetFactionDutyCity( ) ]
					local target_point = targets.player[ GEs.target_num ]

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

					CEs.initCycle = function ( )
						local x, y, z = GEs.vehicle:getBoundingBox( )
						local x2, y2, z2 = getPositionFromElementAtOffset( GEs.vehicle, 0, y - 0.25, 0 )

						CreateQuestPoint( Vector3( x2, y2, z2 ), function ( )
							CEs.marker:destroy( )

							CEs.object = Object( 1271, localPlayer.position )
							CEs.object.scale = 0.5
							exports.bone_attach:attachElementToBone( CEs.object, localPlayer, 8, 0.15, 0.4, 0.2, 0, 180, 0 )
							setPedAnimation( localPlayer, "CARRY", "crry_prtial", 0, true, true, false, true )
							localPlayer.weaponSlot = 0
							CEs.carryingControl( true )

							CreateQuestPoint( target_point, function ( )
								CEs.marker:destroy( )

								counter = counter + 1
								destroyElement( CEs.object )
								setPedAnimation( localPlayer, "CARRY", "liftup", 0, false, false, false, false )
								CEs.carryingControl( false )

								if counter >= BOX_TARGET_VALUE then
									triggerServerEvent( "task_mayor_4_step_6", localPlayer )
								else
									localPlayer:ShowInfo( "Осталось перенести еще " .. BOX_TARGET_VALUE - counter .. " шт." )
									CEs.initCycle( )
								end
							end, nil, 0.7, 0, 0, nil, nil, nil, "cylinder", 0, 100, 230, 50 )
						end, nil, 0.7, 0, 0, nil, nil, nil, "cylinder", 0, 100, 230, 50 )
					end

					CEs.initCycle( )
				end,

				server = function ( player )
					player.vehicle.frozen = true
					addEventHandler( "onVehicleStartEnter", GEs.vehicles[ player ], GEs.blockVehicleInit )
				end,
			},

			CleanUp = {
				server = function ( player )
					if isElement( GEs.vehicles[ player ] ) then
						removeEventHandler( "onVehicleStartEnter", GEs.vehicles[ player ], GEs.blockVehicleInit )
					end
				end,
			},

			event_end_name = "task_mayor_4_step_6",
		},
		[ 7 ] = {
			name = "Вернись в мэрию",

			Setup = {
				client = function( )
					CreateQuestPoint( END_POINTS[ localPlayer:GetFactionDutyCity( ) ], function ( )
						CEs.marker:destroy( )

						triggerServerEvent( "task_mayor_4_step_7", localPlayer )
					end, nil, 10, 0, 0 )
				end,
			},

			event_end_name = "task_mayor_4_step_7",
		},
		[ 8 ] = {
			name = "Поговори с клерком",

			Setup = {
				client = function( )
					CreateQuestPointToNPCWithDialog( FACTIONS_TASKS_PED_IDS[ localPlayer:GetFaction( ) ], {
						{
							text = [[— Неплохая работа, так держать!]],
						},
					}, "task_mayor_4_step_8", _, true )
				end,
			},

			event_end_name = "task_mayor_4_step_8",
		},
	},

	GiveReward = function ( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_mayor_4", 48 )
	end,
	success_text = "Задача выполнена! Вы получили +48 очков",

	rewards = {
		faction_exp = 48,
	},
}