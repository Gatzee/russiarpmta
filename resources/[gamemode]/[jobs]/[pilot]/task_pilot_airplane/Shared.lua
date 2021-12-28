loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ShUtils")

AIRPORT_DATA = 
{
	[1] = {
		zone = { x = -2474.525, y = 1006.61, z = 15.247, radius = 1500 },
		marker = { x = -2668.718, y = 406.764, z = 15.30 },
		polygon = 
		{
			-3006.2839355469, 359.3046875;
			-2248.2648925781, 1674.8588867188;
			-1991.5, 1534.7351074219;
			-2454.8234863281, 802.8856201172;
			-2330.0849609375, 731.3114013672;
			-2407.5571289063, 585.9953613281;
			-2339.0391535156, 544.5881601563;
			-2573.7343203125, 152.3569975586;
			-2793.1870117188, 240.7884521484;
			-3006.2839355469, 359.3046875;
		}
	},

	[2] = {
		zone = { x = 2348.765, y = -2364.445, z = 23.415, radius = 1500 },
		marker = { x = 2348.765, y = -2364.445, z = 23.415 },
		polygon = 
		{
			2574.1218261719, -2173.2413330078;
			2527.046875, -2146.8464355469;
			2409.5959472656, -2257.9459228516;
			2361.8918457031, -2308.2342529297;
			2280.4362792969, -2478.5629882813;
			2268.5339355469, -2550.9892578125;
			2321.5187988281, -2574.5430908203;
			2366.6293945313, -2590.7661132813;
			2580.5068359375, -2191.541015625;
			2574.1218261719, -2173.2413330078;
		},
	},
}


CONST_WAIT_TIME = 0.5 * 60 * 1000
CONST_ROUTE_LENGTH = 10000

START_POSITION = Vector3( -2520.271, 260.115, 16.708 )
PLAYER_RESPAWN_POSITION = Vector3( -2477.332, 254.48, 15.250 )

addEvent( "onPilotEarnMoney", true )

QUEST_DATA = {
	id = "task_pilot_airplane";

	title = "Лётчик";
	description = "Пилот самолёта";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_PILOT
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Возьми самолёт";

			Setup = {
				client = function()
					CreateQuestPoint(  Vector3( -2480.223, 414.174, 15.304 ), 
						function()
							CEs.marker:destroy()
							triggerServerEvent( "OnPlayerTryTakePilotVehicle", resourceRoot, localPlayer )
						end
					)
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_1";
			
		};

		[2] = {
			name = "Дождись своей очереди на взлёт";

			Setup = {
				client = function()
					CEs.zone = createColCircle( -2480.223, 414.174, 100 )
					local function OnColShapeLeave( element )
						if element ~= localPlayer then return end
						destroyElement(source)
						triggerServerEvent("onJobEndShiftRequest", localPlayer, "Ты покинул аэропорт")
					end
					addEventHandler("onClientColShapeLeave", CEs.zone, OnColShapeLeave)

					StartQuestTimerWait( (localPlayer:getData("pilot:time_to_takeoff") or 15) * 1000, "Твой вылет через", _, "PlayerAction_Task_Pilot_2_step_2" )
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_2";
		},

		[3] = {
			name = "Освободи взлётную полосу";

			Setup = {
				client = function()
					CEs.zone = createColPolygon( unpack(AIRPORT_DATA[1].polygon) )

					local function OnColShapeLeave( element )
						if element ~= localPlayer then return end
						destroyElement(source)
						triggerServerEvent( "PlayerAction_Task_Pilot_2_step_3", localPlayer )
					end
					addEventHandler("onClientColShapeLeave", CEs.zone, OnColShapeLeave)

					StartQuestTimerWait( 60000, "Покинуть аэропорт", "Ты не успел вылететь из аэропорта", _, function() 
						triggerServerEvent("onJobEndShiftRequest", localPlayer)
						triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
					end)

				end;

				server = function( player )
					triggerEvent( "OnPilotJobVehicleRequest", player, player, 1, 519 )

					local quest_vehicle = player:getData( "job_vehicle" )
					if isElement( quest_vehicle ) then 
						quest_vehicle:Fix( )
						setVehicleEngineState( quest_vehicle, true )
					end

					toggleControl(player, "enter_exit", false)
				end
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_3";
		},

		[4] = {
			name = "Набери необходимую высоту";

			Setup = {
				client = function()
					local quest_vehicle = localPlayer.vehicle

					local function PreRenderHeight()
						if not isElement(quest_vehicle) then
							removeEventHandler("onClientPreRender", root, PreRenderHeight)
							return 
						end

						local iHeight = quest_vehicle.position.z

						if iHeight >= 200 then
							removeEventHandler("onClientPreRender", root, PreRenderHeight)
							triggerServerEvent( "PlayerAction_Task_Pilot_2_step_4", localPlayer )
						end
					end
					addEventHandler("onClientPreRender", root, PreRenderHeight)

					StartQuestTimerWait( 60000, "Набирай высоту", "Ты не успел набрать высоту", _, function() 
						triggerServerEvent("onJobEndShiftRequest", localPlayer)
						triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
					end)
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_4";
		},

		[5] = {
			name = "Направляйся в аэропорт";

			Setup = {
				client = function()
					CEs.timer = setTimer(function()
						if localPlayer.position.z < 200 then
							localPlayer:ShowError("Набирай высоту, ты летишь слишком низко")
						end

						if localPlayer.position.z < 150 then
							triggerServerEvent("onJobEndShiftRequest", localPlayer, "Ты летел слишком низко")
							triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
						end
					end, 3000, 0)

					local zone_data = AIRPORT_DATA[2].zone

					CreateQuestPoint( Vector3(zone_data.x, zone_data.y, 250), function() end)

					CEs.zone = createColCircle( zone_data.x, zone_data.y, zone_data.radius )

					local function OnColShapeHit( element )
						if element ~= localPlayer then return end
						destroyElement(source)
						triggerServerEvent( "PlayerAction_Task_Pilot_2_step_5", localPlayer )
					end
					addEventHandler("onClientColShapeHit", CEs.zone, OnColShapeHit)
				end;

				server = function( player )
				end
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_5";
		},

		[6] = {
			name = "Снижайся и посади самолёт в аэропорту";

			Setup = {
				client = function()
					local iTimeOnGround = 0
					local quest_vehicle = localPlayer:getData( "job_vehicle" )

					local iLastTick = 0

					local zone_data = AIRPORT_DATA[2].zone
					CreateQuestPoint( Vector3(zone_data.x, zone_data.y, zone_data.z), function() end)
					CEs.col = createColPolygon( unpack(AIRPORT_DATA[2].polygon) )

					local function PreRenderLanding()
						if not isElement(quest_vehicle) then
							removeEventHandler("onClientPreRender", root, PreRenderLanding)
							return 
						end

						if isVehicleOnGround( quest_vehicle ) then
							iTimeOnGround = iTimeOnGround + getTickCount() - iLastTick
						else
							iTimeOnGround = 0
						end

						if iTimeOnGround >= 3000 then
							if not isElementWithinColShape( localPlayer, CEs.col ) then
								localPlayer:ShowError("Это не аэропорт!")
								iTimeOnGround = 0
								return
							end

							CEs.marker:destroy()
							CEs.col:destroy()

							removeEventHandler("onClientPreRender", root, PreRenderLanding)
							triggerServerEvent( "PlayerAction_Task_Pilot_2_step_6", localPlayer )
						end

						iLastTick = getTickCount()
					end
					addEventHandler("onClientPreRender", root, PreRenderLanding)

					StartQuestTimerWait( 120000, "Посади самолёт", "Ты не успел посадить самолёт", _, function() 
						triggerServerEvent("onJobEndShiftRequest", localPlayer)
						triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
					end)
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_6";
		},

		[7] = {
			name = "Припаркуйся для погрузки";

			Setup = {
				client = function()
					if isTimer(CEs.timer) then killTimer(CEs.timer) end

					local load_position = Vector3( 2348.765, -2364.445, 23.415 )

					CreateQuestPoint( load_position, function()
						CEs.marker:destroy()
						triggerServerEvent( "PlayerAction_Task_Pilot_2_step_7", localPlayer )
						if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
					end)

					StartQuestTimerWait( 120000, "Припаркуйся", "Ты не успел начать погрузку", _, function() 
						triggerServerEvent("onJobEndShiftRequest", localPlayer)
						triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
					end)
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_7";
		},

		[8] = {
			name = "Дождись окончания погрузки";

			Setup = {
				client = function()
					local quest_vehicle = localPlayer:getData( "job_vehicle" )

					quest_vehicle.frozen = true
					quest_vehicle.engineState = false

					StartQuestTimerWait( 15000, "Погрузка...", _, "PlayerAction_Task_Pilot_2_step_8" )
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_8";
		},

		[9] = {
			name = "Освободи взлётную полосу";

			Setup = {
				client = function()
					local quest_vehicle = localPlayer:getData( "job_vehicle" )

					quest_vehicle.frozen = false
					quest_vehicle.engineState = true

					CEs.zone = createColPolygon( unpack(AIRPORT_DATA[2].polygon) )

					local function OnColShapeLeave( element )
						if element ~= localPlayer then return end
						destroyElement(source)
						triggerServerEvent( "PlayerAction_Task_Pilot_2_step_9", localPlayer )
					end
					addEventHandler("onClientColShapeLeave", CEs.zone, OnColShapeLeave)

					StartQuestTimerWait( 60000, "Покинуть аэропорт", "Ты не успел вылететь из аэропорта", _, function() 
						triggerServerEvent("onJobEndShiftRequest", localPlayer)
						triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
					end)
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_9";
		},

		[10] = {
			name = "Набери необходимую высоту";

			Setup = {
				client = function()
					local quest_vehicle = localPlayer:getData( "job_vehicle" )

					local function PreRenderHeight()
						if not isElement(quest_vehicle) then
							removeEventHandler("onClientPreRender", root, PreRenderHeight)
							return 
						end

						local iHeight = quest_vehicle.position.z

						if iHeight >= 200 then
							removeEventHandler("onClientPreRender", root, PreRenderHeight)
							triggerServerEvent( "PlayerAction_Task_Pilot_2_step_10", localPlayer )
						end
					end

					StartQuestTimerWait( 60000, "Набирай высоту", "Ты не успел набрать высоту", _, function() 
						triggerServerEvent("onJobEndShiftRequest", localPlayer)
						triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
					end)

					addEventHandler("onClientPreRender", root, PreRenderHeight)
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_10";
		},

		[11] = {
			name = "Возвращайся в аэропорт";

			Setup = {
				client = function()
					CEs.timer = setTimer(function()
						if localPlayer.position.z < 210 then
							localPlayer:ShowError("Набирай высоту, ты летишь слишком низко")
						end

						if localPlayer.position.z < 160 then
							triggerServerEvent("onJobEndShiftRequest", localPlayer, "Ты летел слишком низко")
							triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
						end
					end, 3000, 0)

					local zone_data = AIRPORT_DATA[1].zone

					CreateQuestPoint( Vector3(zone_data.x, zone_data.y, 200), function() end)

					CEs.zone = createColCircle( zone_data.x, zone_data.y, zone_data.radius )

					local function OnColShapeHit( element )
						if element ~= localPlayer then return end
						destroyElement(source)
						triggerServerEvent( "PlayerAction_Task_Pilot_2_step_11", localPlayer )
					end
					addEventHandler("onClientColShapeHit", CEs.zone, OnColShapeHit)
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_11";
		},

		[12] = {
			name = "Снижайся и посади самолёт в аэропорту";

			Setup = {
				client = function()
					local iTimeOnGround = 0
					local quest_vehicle = localPlayer:getData( "job_vehicle" )

					local iLastTick = 0

					local zone_data = AIRPORT_DATA[1].zone
					CreateQuestPoint( Vector3(zone_data.x, zone_data.y, zone_data.z), function() end)
					CEs.col = createColPolygon( unpack(AIRPORT_DATA[1].polygon) )

					local function PreRenderLanding()
						if not isElement(quest_vehicle) then
							removeEventHandler("onClientPreRender", root, PreRenderLanding)
							return 
						end

						if isVehicleOnGround( quest_vehicle ) then
							iTimeOnGround = iTimeOnGround + getTickCount() - iLastTick
						else
							iTimeOnGround = 0
						end

						if iTimeOnGround >= 5000 then
							if not isElementWithinColShape( localPlayer, CEs.col ) then
								localPlayer:ShowError("Это не аэропорт!")
								return
							end

							CEs.marker:destroy()
							CEs.col:destroy()

							removeEventHandler("onClientPreRender", root, PreRenderLanding)
							triggerServerEvent( "PlayerAction_Task_Pilot_2_step_12", localPlayer )
						end

						iLastTick = getTickCount()
					end
					addEventHandler("onClientPreRender", root, PreRenderLanding)

					StartQuestTimerWait( 120000, "Посади самолёт", "Ты не успел посадить самолёт", _, function() 
						triggerServerEvent("onJobEndShiftRequest", localPlayer)
						triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
					end)
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_12";
		},

		[13] = {
			name = "Рейс завершён";

			Setup = {
				client = function()
					triggerServerEvent( "PlayerAction_Task_Pilot_2_step_13", localPlayer )
				end;

				server = function( player )
					removePedFromVehicle( player )
					player.position = PLAYER_RESPAWN_POSITION:AddRandomRange(5)
					setCameraTarget(player, player)
					toggleControl(player, "enter_exit", true)
				end
			};
			event_end_name = "PlayerAction_Task_Pilot_2_step_13";
		},
	};

	GiveReward = function( player )
		triggerEvent( "onPilotMarkerPass", resourceRoot, player, 1 )
		triggerEvent( "PilotDaily_AddDelivery", player )
		StartAgain( player )
	end;

	no_show_rewards = true;
}

function StartAgain( player )
	setTimer( function()
		if not isElement( player ) then return end
		triggerEvent( "onJobRequestAnotherTask", player, player, false )
	end, 5000, 1 )
end

function CheckPlayerQuestVehicle()
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "job_vehicle" ) then
		localPlayer:ShowError( "Ты не в самолёте" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не водитель" )
		return false
	end

	return true
end