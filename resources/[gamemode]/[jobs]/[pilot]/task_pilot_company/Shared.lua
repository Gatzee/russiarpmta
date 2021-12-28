loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ShUtils")

-- Точки сброса груза для вертолёта
DROP_POINTS = {
	Vector3( -1399.073, -423.625, 230 ),
	Vector3( -2128.037, -1692.824, 230 ),
	Vector3( -2747.609, -1779.887, 230 ),
	Vector3( -2927.687, -768.292, 230 ),
	Vector3( -1480.247, -1534.241, 230 ),
	Vector3( -203.889, -1854.563, 230 ),
	Vector3( 431.489, -2362.324, 230 ),
	Vector3( 393.678, -2793.243, 230 ),
	Vector3( 379.766, -1154.083, 230 ),
	Vector3( 1294.12, -750.855, 230 ),
	Vector3( 1654.856, -268.326, 230 ),
	Vector3( 2469.567, -611.699, 230 ),
	Vector3( 2086.065, -1262.957, 230 ),
	Vector3( 2422.266, -1732.953, 230 ),
	Vector3( 1963.354, -2224.541, 230 ),
	Vector3( 1787.309, -1893.21, 230 ),
	Vector3( 1967.292, -534.763, 230 ),
	Vector3( 1861.733, -778.926, 230 ),
}

CONST_WAIT_TIME = 0.5 * 60 * 1000
CONST_ROUTE_LENGTH = 20000

START_POSITION = Vector3( -2520.271, 260.115, 16.708 )
PLAYER_RESPAWN_POSITION = Vector3( -2477.332, 254.48, 15.250 )

addEvent( "onPilotEarnMoney", true )

QUEST_DATA = {
	id = "task_pilot_company";

	title = "Лётчик";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_PILOT
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Возьми вертолёт";

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
			event_end_name = "PlayerAction_Task_Pilot_1_step_1";
			
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

					StartQuestTimerWait( (localPlayer:getData("pilot:time_to_takeoff") or 15) * 1000, "Твой вылет через", _, "PlayerAction_Task_Pilot_1_step_2" )
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_1_step_2";
		},

		[3] = {
			name = "Набери необходимую высоту";

			Setup = {
				client = function()
					function OnClientVehicleEnter()
						local quest_vehicle = localPlayer.vehicle

						local function PreRenderHeight()
							if not isElement(quest_vehicle) then
								removeEventHandler("onClientPreRender", root, PreRenderHeight)
								return 
							end

							local iHeight = quest_vehicle.position.z
							--dxDrawText( iHeight.."/"..pHeightTable[ quest_vehicle.model ], 400, 400 )

							if iHeight >= 200 then
								removeEventHandler("onClientPreRender", root, PreRenderHeight)
								triggerServerEvent( "PlayerAction_Task_Pilot_1_step_3", localPlayer )
							end
						end

						addEventHandler("onClientPreRender", root, PreRenderHeight)
					end

					addEventHandler("onClientPlayerVehicleEnter", localPlayer, OnClientVehicleEnter)

					StartQuestTimerWait( 50000, "Набирай высоту", "Ты не успел набрать высоту", _, function() 
						triggerServerEvent("onJobEndShiftRequest", localPlayer)
						triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
					end)
				end;
				server = function( player )
					triggerEvent( "OnPilotJobVehicleRequest", player, player, 1 )

					local quest_vehicle = player:getData( "job_vehicle" )
					if isElement( quest_vehicle ) then 
						quest_vehicle:Fix( )
						setVehicleEngineState( quest_vehicle, true )
					end

					toggleControl(player, "enter_exit", false)
				end
			};
			event_end_name = "PlayerAction_Task_Pilot_1_step_3";
		},

		[4] = {
			name = "Сбрось все грузы";

			Setup = {
				client = function()
					local pDropList = {}
					local pRoute, TOTAL_DISTANCE = GenerateRoute( CONST_ROUTE_LENGTH )
					DISTANCE_MUL = 1/#pRoute

					local iCurrentPoint = 1

					CEs.timer = setTimer(function()
						if localPlayer.position.z < 210 then
							localPlayer:ShowError("Набирай высоту, ты летишь слишком низко")
						end

						if localPlayer.position.z < 160 then
							triggerServerEvent("onJobEndShiftRequest", localPlayer, "Ты летел слишком низко")
							triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
						end
					end, 3000, 0)

					function CreateDropPoint()
						iCurrentPoint = iCurrentPoint + 1
						if pRoute[iCurrentPoint] then
							CreateQuestPoint( pRoute[iCurrentPoint], function()
								CEs.marker:destroy()
								StartDropMinigame() 
							end, _, 15, _, _, _, _, _, "corona")
						else
							triggerServerEvent( "PlayerAction_Task_Pilot_1_step_4", localPlayer )
						end
					end

					CEs.count_dropped_cargo = -1
					CEs.func_refresh_number_dropped_cargo = function()
						CEs.count_dropped_cargo = CEs.count_dropped_cargo + 1
						localPlayer:setData( "hud_counter", { left = "Сброшено грузов", right = CEs.count_dropped_cargo .. "/" .. #pRoute }, false )
					end

					CEs.func_refresh_number_dropped_cargo()
					CreateDropPoint()
				end;

				server = function( player )
				end
			};

			CleanUp = {
				client = function()
					localPlayer:setData( "hud_counter", false, false )
					removeEventHandler("onClientPreRender", root, PreRenderMinigame)
				end;
			};

			event_end_name = "PlayerAction_Task_Pilot_1_step_4";
		},

		[5] = {
			name = "Возвращайся в аэропорт";

			Setup = {
				client = function()
					if isTimer(CEs.timer) then killTimer(CEs.timer) end

					CEs.timer = setTimer(function()
						if localPlayer.position.z < 210 then
							localPlayer:ShowError("Набирай высоту, ты летишь слишком низко")
						end

						if localPlayer.position.z < 160 then
							triggerServerEvent("onJobEndShiftRequest", localPlayer, "Ты летел слишком низко")
							triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
						end
					end, 3000, 0)

					CreateQuestPoint( Vector3( -2403.514, 531.235,  200 ), function() end)

					CEs.zone = createColCircle( -2403.514, 531.235, 500 )

					local function OnColShapeHit( element )
						if element ~= localPlayer then return end
						destroyElement(source)
						triggerServerEvent( "PlayerAction_Task_Pilot_1_step_5", localPlayer )
					end
					addEventHandler("onClientColShapeHit", CEs.zone, OnColShapeHit)
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_1_step_5";
		},

		[6] = {
			name = "Посади вертолёт";

			Setup = {
				client = function()
					if isTimer(CEs.timer) then killTimer(CEs.timer) end

					local vecReturnPosition = Vector3( -2403.514, 531.235,  15.291 )

					CreateQuestPoint( vecReturnPosition, function()
						CEs.marker:destroy()
						triggerServerEvent( "PlayerAction_Task_Pilot_1_step_6", localPlayer ) 
					end)

					StartQuestTimerWait( 120000, "Посади вертолёт", "Ты не успел посадить вертолёт", _, function() 
						triggerServerEvent("onJobEndShiftRequest", localPlayer)
						triggerServerEvent( "onPilotRespawnPosition", resourceRoot, localPlayer )
					end)
				end;
			};
			event_end_name = "PlayerAction_Task_Pilot_1_step_6";
		},

		[7] = {
			name = "Задача завершена";

			Setup = {
				client = function()
					triggerServerEvent( "PlayerAction_Task_Pilot_1_step_7", localPlayer )
				end;

				server = function( player )
					removePedFromVehicle( player )
					player.position = PLAYER_RESPAWN_POSITION:AddRandomRange(5)
					setCameraTarget(player, player)
					toggleControl(player, "enter_exit", true)
				end
			};
			event_end_name = "PlayerAction_Task_Pilot_1_step_7";
		}
	};

	GiveReward = function( player )
		triggerEvent( "onPilotMarkerPass", resourceRoot, player, true )
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

function GenerateRoute( len, iter )
	local iter = iter or 1

	local pPoints = table.copy(DROP_POINTS)

	local pRoute, iTotalLength = {}, 0
	
	repeat
		local iRandPoint = math.random(#pPoints)
		if #pRoute > 1 then
			iTotalLength = iTotalLength + ( pRoute[#pRoute] - pPoints[iRandPoint] ).length
		end

		table.insert(pRoute, pPoints[iRandPoint])
		table.remove(pPoints, iRandPoint)
	until
		iTotalLength + (START_POSITION-pRoute[1]).length + (START_POSITION-pRoute[#pRoute]).length >= len

	--iTotalLength = iTotalLength + (START_POSITION-pRoute[#pRoute]).length

	local iBias = math.abs( iTotalLength - len )
	if iBias >= 2000 then
		iter = iter + 1
		return GenerateRoute( len, iter )
	end

	return pRoute, iTotalLength
end