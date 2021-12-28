QUEST_PEDS = {
	16, -- NSK
	17, -- GRK
	27, -- MSK
}

START_POINTS = {
	{ x = 438.914, y = -2415.161 + 860, z = 20.588 }, -- NSK
	{ x = 1914.698, y = -493.090 + 860, z = 60.553 }, -- GRK
	{ x = 1416.114, y = 2644.231 + 860, z = 9.864 }, -- MSK
}

ENTERS = {
	{ x = 398.834, y = -2450.267 + 860, z = 23.532 },
	{ x = 1877.931, y = -528.075 + 860, z = 60.795 },
	{ x = 1422.393, y = 2722.102 + 860, z = 10.910 },
}

GEs = {
	vehicles = { },
	blockVehicleByPlayer = function ( player, seat )
		if seat == 0 and source ~= GEs.vehicles[ player ] then
			cancelEvent( )
		end
	end,
}

QUEST_DATA = {
	id = "task_medic_5",

	title = "Патрулирование территории",
	description = "",

	replay_timeout = 0,

	CheckToStart = function( player )
		return player:IsInFaction( )
	end,

	OnAnyFinish = {
		client = function( )
			localPlayer:setAnimation( )

			if GEs.watch then
				GEs.watch:destroy( )
				GEs.watch = nil
			end
		end,
		server = function ( player )
			if isElement( GEs.vehicles[ player ] ) then
				removeEventHandler( "onVehicleStartEnter", GEs.vehicles[ player ], GEs.blockVehicleByPlayer )
			end

			GEs.vehicles[ player ] = nil
		end,
	},

	tasks = {
		[ 1 ] = {
			name = "Поговори с доктором",

			Setup = {
				client = function ( )
					CreateQuestPointToNPCWithDialog( QUEST_PEDS[ localPlayer:GetFactionDutyCity( ) ], {
						{
							text = [[— Твоя задача заниматься патрулированием улиц
									города на транспорте, помогая пострадавшим!]],
						},
						{
							text = [[— Ты можешь взять в патрулирование напарника,
									для этого ему нужно взять это же задание и на
									этапе выезда с парковки находиться в той же
									машине (на переднем пассажирском сиденье или
									быть водителем).]],
							info = true,
						},
					}, "task_medic_5_step_1", nil, true )
				end,
			},

			event_end_name = "task_medic_5_step_1",
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
						if localPlayer.vehicle and localPlayer.vehicle:GetFaction( ) == localPlayer:GetFaction( ) then
							if localPlayer.vehicleSeat ~= 0 and localPlayer.vehicleSeat ~= 1 then return end

							GEs.vehicle = localPlayer.vehicle
							killTimer( CEs.timer )

							triggerServerEvent( "task_medic_5_step_2", localPlayer )
						end
					end, 500, 0 )
				end
			},

			event_end_name = "task_medic_5_step_2",
		},
		[ 3 ] = {
			name = "Начни прохождение маршрута",

			Setup = {
				client = function ( )
					CreateQuestPoint( START_POINTS[ localPlayer:GetFactionDutyCity( ) ], function ( )
						if localPlayer.vehicle ~= GEs.vehicle then
							localPlayer:ShowError( "Вернись в изначальное ТС" )
							return
						end

						CEs.marker.destroy( )
						triggerServerEvent( "task_medic_5_step_3", localPlayer )
					end, nil, 10, 0, 0 )
					CEs.marker.allow_passenger = true
				end,

				server = function ( player )
					if player.vehicleSeat ~= 0 then return end
					
					GEs.vehicles[ player ] = player.vehicle
					addEventHandler( "onVehicleStartEnter", player.vehicle, GEs.blockVehicleByPlayer )
				end,
			},

			event_end_name = "task_medic_5_step_3",
		},
		[ 4 ] = {
			name = "Проследуй по маршруту",

			Setup = {
				client = function ( )
					local counter = 0
					local passed_points = { }
					local partner = localPlayer.vehicle.occupants[ 1 ]

					CEs.generateNextPoint = function ( )
						local point_num = math.random( 1, #POINTS )
						local distance = getDistanceBetweenPoints3D( localPlayer.position, Vector3( POINTS[ point_num ] ) )

						if passed_points[ point_num ] or distance < 3000 or distance > 4500 then
							CEs.timer = Timer( CEs.generateNextPoint, 50, 1 )
						else
							passed_points[ point_num ] = true

							-- sync point of destination with passenger
							if isElement( partner ) then
								triggerServerEvent( "onPlayerGotPointInMedicTask5", resourceRoot, partner, point_num )
							end

							CEs.createNextMarker( point_num, true )
						end
					end

					CEs.goToFinish = function ( )
						CEs.updateTimerToFail( )

						CreateQuestPoint( START_POINTS[ localPlayer:GetFactionDutyCity( ) ], function ( )
							if localPlayer.vehicle ~= GEs.vehicle then
								localPlayer:ShowError( "Вернись в изначальное ТС" )
								return
							end

							CEs.marker.destroy( )
							triggerServerEvent( "task_medic_5_step_4", localPlayer )
						end, nil, 10, 0, 0 )
						CEs.marker.allow_passenger = true
					end

					CEs.gotMarker = function ( from_server )
						if localPlayer.vehicle ~= GEs.vehicle then
							if from_server then
								CEs.marker.destroy( )
								FailCurrentQuest( "Твой напарник прошёл часть маршрута без тебя" )
							else
								localPlayer:ShowError( "Вернись в изначальное ТС" )
							end
							return
						end

						CEs.marker.destroy( )
						counter = counter + 1

						if counter >= 5 or counter >= #POINTS then -- finish
							CEs.goToFinish( )
							if localPlayer.vehicleSeat == 0 then
								triggerServerEvent( "onPlayerGotPointInMedicTask5", resourceRoot, partner )
							end
						elseif localPlayer.vehicleSeat == 0 then -- generate next
							CEs.generateNextPoint( )
						end
					end

					CEs.vehicleDestroy = function ( )
						FailCurrentQuest( "Рабочий транспорт разбит" )
					end
					addEventHandler( "onClientElementDestroy", GEs.vehicle, CEs.vehicleDestroy )

					GEs.watch = WatchElementCondition( GEs.vehicle, {
						condition = function( self )
							if self.element.health <= 370 or self.element.inWater then
								FailCurrentQuest( "Рабочий транспорт разбит" )
								return true
							end
						end,
					} )

					CEs.updateTimerToFail = function ( )
						StartQuestTimerFail( 30 * 60 * 1000, "Проследуй по маршруту", "Слишком медленно!" )
					end

					CEs.createNextMarker = function ( point_num, is_local )
						if not is_local and CEs.marker then
							CEs.gotMarker( true )
						end

						if point_num then
							CreateQuestPoint( POINTS[ point_num ], function ( )
								CEs.gotMarker( )
							end, nil, 10, 0, 0 )

							CEs.updateTimerToFail( )
						end
					end
					addEventHandler( "onPlayerGotPointInMedicTask5", resourceRoot, CEs.createNextMarker )

					if localPlayer.vehicleSeat == 0 then
						CEs.generateNextPoint( )
					end
				end,
			},

			CleanUp = {
				client = function ( )
					removeEventHandler( "onPlayerGotPointInMedicTask5", resourceRoot, CEs.createNextMarker )

					if isElement( GEs.vehicle ) then
						removeEventHandler( "onClientElementDestroy", GEs.vehicle, CEs.vehicleDestroy )
					end
				end
			},

			event_end_name = "task_medic_5_step_4",
		},
		[ 5 ] = {
			name = "Вернись к доктору",

			Setup = {
				client = function ( )
					CreateQuestPoint( ENTERS[ localPlayer:GetFactionDutyCity( ) ], function ( )
						CEs.marker:destroy( )

						CreateQuestPointToNPCWithDialog( QUEST_PEDS[ localPlayer:GetFactionDutyCity( ) ], {
							{
								text = [[— Неплохая работа, так держать!]],
							},
						}, "task_medic_5_step_5", nil, true )
					end, nil, 1.7, 0, 0, function ( ) return not localPlayer.vehicle end )
				end,
			},

			event_end_name = "task_medic_5_step_5",
		},
	},


	GiveReward = function( player )
		triggerEvent( "onServerCompleteShiftPlan", player, player, "complete_quest", "task_medic_5", 64 )
	end,
	success_text = "Задача выполнена! Вы получили +64 очков",

	rewards = {
		faction_exp = 64,
	},
}