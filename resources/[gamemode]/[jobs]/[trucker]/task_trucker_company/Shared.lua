-- Точки взятия груза
PICKUP_POINTS = {
	--НСК
	[ 0 ] = {
		{ position = Vector3( -2912.27, -816.36 + 860, 17.36 ), rotation = Vector3( 0, 0, 202 ) },
		{ position = Vector3( -2916.85, -818.21 + 860, 17.36 ), rotation = Vector3( 0, 0, 202 ) },
		{ position = Vector3( -2921.49, -820.24 + 860, 17.36 ), rotation = Vector3( 0, 0, 202 ) },
		{ position = Vector3( -2925.82, -823.3 + 860, 17.36 ), rotation = Vector3( 0, 0, 202 ) },
		{ position = Vector3( -2930.85, -824.3 + 860, 17.36 ), rotation = Vector3( 0, 0, 202 ) },
		{ position = Vector3( -2935.37, -826.44 + 860, 17.36 ), rotation = Vector3( 0, 0, 202 ) },
		{ position = Vector3( -2940, -828.01 + 860, 17.36 ), rotation = Vector3( 0, 0, 202 ) },
	},

	--ГОРКИ
	[ 1 ] = {
		{ position = Vector3( 2436.362, -1685.22 + 860, 73 ), rotation = Vector3( ) },
		{ position = Vector3( 2442.362, -1685.22 + 860, 73 ), rotation = Vector3( ) },
		{ position = Vector3( 2448.362, -1685.22 + 860, 73 ), rotation = Vector3( ) },
		{ position = Vector3( 2454.362, -1685.22 + 860, 73 ), rotation = Vector3( ) },
		{ position = Vector3( 2460.362, -1685.22 + 860, 73 ), rotation = Vector3( ) },
		{ position = Vector3( 2466.56, -1685.22 + 860, 73 ), rotation = Vector3( ) },

		{ position = Vector3( 2491.64, -1725.273 + 860, 73 ), rotation = Vector3( 0, 0, -90 ) },
		{ position = Vector3( 2491.64, -1728.773 + 860, 73 ), rotation = Vector3( 0, 0, -90 ) },
		{ position = Vector3( 2491.64, -1732.273 + 860, 73 ), rotation = Vector3( 0, 0, -90 ) },
		{ position = Vector3( 2491.64, -1735.773 + 860, 73 ), rotation = Vector3( 0, 0, -90 ) },
		{ position = Vector3( 2491.64, -1739.273 + 860, 73 ), rotation = Vector3( 0, 0, -90 ) },

		{ position = Vector3( 2508.867, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2505.367, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2501.867, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2498.367, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2494.867, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2491.367, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2487.867, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2484.367, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2480.867, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2477.367, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2473.867, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2470.367, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2466.867, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
		{ position = Vector3( 2463.367, -1809.575 + 860, 73 ), rotation = Vector3( 0, 0, 180 ) },
	},
}

-- Точки возврата к базе
RETURN_TARGETS = {
	--НСК
	[ 0 ] = { 
		Vector3( -2894.9106, -714.4548 + 860, 18.36 ),
	},

	--ГОРКИ
	[ 1 ] = {
		Vector3( 2390.4348, -1740.5379 + 860, 73.925 ),
	}
}

DELIVERY_TARGETS = {
	[ 0 ] = {
		Vector3( 2219.875, 1575.028 + 860, 16.163 ),
		Vector3( 1656.906, 716.471 + 860, 16.160 ),
		Vector3( 1435.418, 1271.794 + 860, 16.163 ),
		Vector3( 1655.166, 1851.713 + 860, 16.161 ),
		Vector3( 164.1, 910.57 + 860, 21.53 ),
	},
	[ 1 ] = {
		Vector3( -2517.013, 236.753 + 860, 15.254 ),
		Vector3( -1785.9399, 40.52002 + 860, 75.19 ),
		Vector3( -1086.235, -490.258 + 860, 22.332 ),
		Vector3( -2089.911, 251.207 + 860, 18.764 ),
	},
}

CONST_WAIT_TIME = 0.5 * 60 * 1000

addEvent( "onTruckerEarnMoney", true )

QUEST_DATA = {
	id = "task_trucker_company";

	title = "Дальнобойщик";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_TRUCKER
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Загрузи грузовик";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )
					local pickup_points = PICKUP_POINTS[ city ]		
					local pickup_point
					local n = 0

					while not pickup_point or #getElementsWithinRange( pickup_point.position, 4, "vehicle" ) > 0 do
						pickup_point = pickup_points[ math.random( 1, #pickup_points ) ]
						n = n + 1

						if n > 2048 then break end
					end

					CreateQuestPoint( pickup_point.position, 
						function()
							CEs.marker:destroy()
							localPlayer.vehicle.position = pickup_point.position + Vector3( 0, 0, 1 )
							localPlayer.vehicle.rotation = pickup_point.rotation
							triggerServerEvent( "PlayerAction_Task_Trucker_1_step_1", localPlayer )
							if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
						end
					, _, 4, 0, 0, CheckPlayerQuestVehicle, _, _, "cylinder", 0, 255, 0, 20 )
				end;
			};
			event_end_name = "PlayerAction_Task_Trucker_1_step_1";			
		};

		[2] = {
			name = "Ожидай загрузки...";

			Setup = {
				client = function()
					StartQuestTimerWait( CONST_WAIT_TIME, "Ждем загрузки...", _, "PlayerAction_Task_Trucker_1_step_2" )
					if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
				end;
				server = function( player )
					local quest_vehicle = player:getData( "job_vehicle" )
					if isElement( quest_vehicle ) then 
						quest_vehicle:Fix( )
						quest_vehicle:SetStatic( true )
					end

					local city = player:GetShiftCity( )
					player:SetPrivateData( "TRUCKER_JOB_DELIVERY_TARGET_NUM", math.random( 1, #DELIVERY_TARGETS[ city ] ) )
				end
			};
			event_end_name = "PlayerAction_Task_Trucker_1_step_2";
		},

		[3] = {
			name = "Отвези груз до адреса";

			Setup = {
				client = function()					
					if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
					local city = localPlayer:GetShiftCity( )

					DELIVERY_TARGET_NUM = localPlayer:getData( "TRUCKER_JOB_DELIVERY_TARGET_NUM" ) or 1
					local target = DELIVERY_TARGETS[ city ][ DELIVERY_TARGET_NUM ]

					CreateQuestPoint( target, 
						function()
							CEs.marker:destroy()
							triggerServerEvent( "PlayerAction_Task_Trucker_1_step_3", localPlayer )
							if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
						end
					, _, 14, 0, 0, CheckPlayerQuestVehicle, _, _, "cylinder", 255, 100, 255, 20 )
					CEs.marker.slowdown_coefficient = nil
					CEs.marker.PreJoinContinuous = function( self, player )
						local quest_vehicle = localPlayer:getData( "job_vehicle" )
						local x, y, z = getPositionFromElementAtOffset( quest_vehicle, 0, -7, 0 )

						if getDistanceBetweenPoints3D( x, y, z, target.x, target.y, target.z ) < 10 then
							return false, "Слишком близко"
						end

						return true
					end
				end;
				server = function( player )
					local quest_vehicle = player:getData( "job_vehicle" )
					if isElement( quest_vehicle ) then 
						quest_vehicle:Fix( )
						quest_vehicle:SetStatic( false )
					end

					local city = player:GetShiftCity( )
					DELIVERY_TARGET_NUM = player:getData( "TRUCKER_JOB_DELIVERY_TARGET_NUM" ) or 1
					local target = DELIVERY_TARGETS[ city ][ DELIVERY_TARGET_NUM ]
					DELIVERY_DISTANCE = ( player.position - target ).length
					player:SetPrivateData( "TRUCKER_JOB_DELIVERY_DISTANCE", DELIVERY_DISTANCE )
				end;
			};
			event_end_name = "PlayerAction_Task_Trucker_1_step_3";
		};

		[4] = {
			name = "Разгрузи 5 коробок";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )
					local target = DELIVERY_TARGETS[ city ][ DELIVERY_TARGET_NUM ]

					local counter = 0
					local is_carrying = false

					CEs.StartDelivery = function( )
						CEs.marker:destroy()
						is_carrying = true
						counter = counter + 1

						StartCarrying( { model = 3052 } )

						CreateQuestPoint( target, 
							function()
								is_carrying = nil
								CEs.marker:destroy( )
								StopCarrying( { animate = true } )

								if counter >= 5 then
									triggerServerEvent( "PlayerAction_Task_Trucker_1_step_4", localPlayer )
									triggerServerEvent( "onTruckerMarkerPass", resourceRoot, false )
								else
									CEs.CreateDeliveryMarker( )
								
								end
							end
						, _, 1.5, 0, 0, _, _, _, "cylinder", 255, 100, 255, 20 )
					end

					CEs.CreateDeliveryMarker = function( )
						if not is_carrying then
							StopCarrying( )

							local quest_vehicle = localPlayer:getData( "job_vehicle" )
							local x, y, z = getPositionFromElementAtOffset( quest_vehicle, 0, -7, 0 )

							CreateQuestPoint( Vector3( x, y, z ), CEs.StartDelivery, _, 1.5, 0, 0, _, _, _, "cylinder", 255, 100, 255, 20 )
						end
					end
					
					CEs.CreateDeliveryMarker( )
				end;
				server = function( player )
					local quest_vehicle = player:getData( "job_vehicle" )
					if isElement( quest_vehicle ) then quest_vehicle:SetStatic( true ) end

					player:SetPrivateData( "TRUCKER_JOB_DELIVERY_UNLOAD_1", true )
				end;
			};

			CleanUp = {
				client = function()
					StopCarrying( )
				end;
				server = function()
					local quest_vehicle = player:getData( "job_vehicle" )
					if isElement( quest_vehicle ) then quest_vehicle:SetStatic( false ) end
				end
			};
			event_end_name = "PlayerAction_Task_Trucker_1_step_4";
		};

		[5] = {
			name = "Вернись к погрузке за наградой";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )
					if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
					local return_points = RETURN_TARGETS[ city ]
					local return_point = return_points[ math.random( 1, #return_points ) ]

					CreateQuestPoint( return_point, 
						function()
							CEs.marker:destroy()
							if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
							triggerServerEvent( "PlayerAction_Task_Trucker_1_step_5", localPlayer )
							triggerServerEvent( "onTruckerMarkerPass", resourceRoot, true )
						end
					, _, 30, 0, 0, CheckPlayerQuestVehicle, _, _, "cylinder", 0, 255, 0, 20 )
				end;
				server = function( player )
					triggerEvent( "TruckerDaily_AddDelivery", player )
					player:SetPrivateData( "TRUCKER_JOB_DELIVERY_UNLOAD_2", true )
				end,
			};
			event_end_name = "PlayerAction_Task_Trucker_1_step_5";
		};

	};

	GiveReward = function( player )
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
		localPlayer:ShowError( "Ты не в автомобиле Дальнобойщика" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не водитель автомобиля Дальнобойщика" )
		return false
	end

	return true
end

function getPositionFromElementAtOffset( element, x, y, z )
	if not x or not y or not z then      
		return x, y, z   
	end        
	local matrix = getElementMatrix ( element )
	local offX = x * matrix[1][1] + y * matrix[2][1] + z * matrix[3][1] + matrix[4][1]
	local offY = x * matrix[1][2] + y * matrix[2][2] + z * matrix[3][2] + matrix[4][2]
	local offZ = x * matrix[1][3] + y * matrix[2][3] + z * matrix[3][3] + matrix[4][3]
	return offX, offY, offZ
end