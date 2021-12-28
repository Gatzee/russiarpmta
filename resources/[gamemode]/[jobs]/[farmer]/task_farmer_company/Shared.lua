-- SELL_TARGETS = { }

RETURN_TARGETS = {
	[ 0 ] = {
		{ position = Vector3( -1292.417, -260.013 + 860, 28.732 ) },
	},
	[ 1 ] = {
		{ position = Vector3( -1123.4, -427.39999 + 860, 21.3 ) },
	}
}

addEvent( "onFarmerEarnMoney", true )

QUEST_DATA = {
	id = "task_farmer_company";

	title = "Продажа товара";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_FARMER
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Отвези товар на продажу";

			Setup = {
				server = function( player )
					triggerEvent( "CreateFarmerVehicle", player, player, 0 )
				end;

				client = function( data )
					
					-- Чтение точек из мап файла
					if not SELL_TARGETS then
						local targets = LoadXMLIntoVector3Positions( "map/directions_0.map" )
						if targets then SELL_TARGETS = targets end
					end

					local spawn_info = SELL_TARGETS[ math.random( 1, #SELL_TARGETS ) ]
					CreateQuestPoint( spawn_info, function( )
						triggerServerEvent( "PlayerAction_Task_Farmer_2_step_1", localPlayer )
					end, _, 6, 0, 0, CheckPlayerQuestVehicle, nil, nil, nil, nil, nil, nil, nil, true )

					triggerEvent( "onClientTryGenerateGPSPath", root, {
						x = spawn_info.x, y = spawn_info.y, z = spawn_info.z, route_id = "farmer_company",
					} )
				end;
			};
			CleanUp = {
				client = function( )
					triggerEvent( "onClientTryDestroyGPSPath", root, "farmer_company" )
					triggerServerEvent( "FarmerDaily_AddSell", localPlayer )
				end;
			};
			event_end_name = "PlayerAction_Task_Farmer_2_step_1";
			
		};

		[2] = {
			name = "Вернись на Ферму";

			Setup = {
				client = function( data )
					local city = localPlayer:GetShiftCity( )
					local return_targets = RETURN_TARGETS[ city ]
					local spawn_info = return_targets[ math.random( 1, #return_targets ) ]
					CreateQuestPoint( spawn_info.position, "PlayerAction_Task_Farmer_2_step_2", _, 60, 0, 0, CheckPlayerQuestVehicle, nil, nil, nil, nil, nil, nil, nil, true )
					
					triggerEvent( "onClientTryGenerateGPSPath", root, {
						x = spawn_info.position.x, y = spawn_info.position.y, z = spawn_info.position.z, route_id = "farmer_company",
					} )
				end,
				server = function( player )
					triggerEvent( "onFarmerDeliveryPass", resourceRoot, player )
				end,
			};
			CleanUp = {
				client = function( data )
					triggerEvent( "onClientTryDestroyGPSPath", root, "farmer_company" )
				end,
				server = function( player )
					local quest_vehicle = player:getData( "job_vehicle" )
					if isElement( quest_vehicle ) then
						triggerEvent( "TryToFineFarmer", player, player, quest_vehicle )
						destroyElement( quest_vehicle )
					end
				end;
			};
			event_end_name = "PlayerAction_Task_Farmer_2_step_2";
		};

	};

	GiveReward = function( player )
		StartAgain( player )
	end;

	no_show_rewards = true;
	no_show_success = true;
}

function StartAgain( player )
	setTimer( function()
		if not isElement( player ) then return end
		triggerEvent( "onJobRequestAnotherTask", player, player, false )
	end, 50, 1 )
end

function CheckPlayerQuestVehicle()
  if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "job_vehicle" ) then
    localPlayer:ShowError( "Ты не в автомобиле Фермера" )
    return false
  end

  if localPlayer.vehicleSeat ~= 0 then
    localPlayer:ShowError( "Ты не водитель автомобиля Фермера" )
    return false
  end

	return true
end