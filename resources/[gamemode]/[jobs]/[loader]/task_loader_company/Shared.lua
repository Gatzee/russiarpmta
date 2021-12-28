-- Точки взятия груза
PICKUP_POINTS = {
	-- НСК
	[ 0 ] = {
		Vector3( -794.801, -1190.638 + 860, 15.79 ),
		Vector3( -782.321, -1190.638 + 860, 15.79 ),
	},
	-- Горки
	--[ 1 ] = { }
}

DELIVERY_TARGETS = {
	-- НСК
	[ 0 ] = {
		Vector3( -840.216, -1272.711 + 860, 15.79 ),
		Vector3( -840.65, -1103.707 + 860, 15.79 ),
		Vector3( -738.045, -1415.589 + 860, 15.785 ),
		Vector3( -741.725, -1415.687 + 860, 15.785 ),
		Vector3( -767.908, -1401.611 + 860, 15.79 ),
		Vector3( -780.103, -1401.647 + 860, 15.785 ),
		Vector3( -792.825, -1401.839 + 860, 15.79 ),
		Vector3( -715.79, -1397.079 + 860, 15.79 ),
		Vector3( -716.171, -1292.302 + 860, 15.79 ),
		Vector3( -759.246, -1311.133 + 860, 15.79 ),
		Vector3( -843.232, -1332.021 + 860, 15.79 ),
		Vector3( -848.012, -1379.462 + 860, 15.79 ),
		Vector3( -767.604, -1338.201 + 860, 15.79 ),
		Vector3( -780.36, -1338.254 + 860, 15.79 ),
		Vector3( -792.791, -1338.454 + 860, 15.79 ),
		Vector3( -796.413, -1256.062 + 860, 15.79 ),
		Vector3( -793.231, -1256.204 + 860, 15.79 ),
		Vector3( -713, -1276.428 + 860, 15.79 ),
		Vector3( -712.835, -1283.895 + 860, 15.79 ),
		Vector3( -837.255, -1180.271 + 860, 15.785 ),
		Vector3( -837.42, -1131.327 + 860, 15.79 ),
		Vector3( -762.43, -1101.275 + 860, 15.79 ),
		Vector3( -746.88, -1120.131 + 860, 15.79 ),
	},
	-- Горки
	--[ 1 ] = { }
}

addEvent( "onLoaderEarnMoney", true )

QUEST_DATA = {
	id = "task_loader_company";

	title = "Водитель погрузчика";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_LOADER 
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Погрузи транспорт";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )
					local pickup_points = PICKUP_POINTS[ city ] or PICKUP_POINTS[ 0 ]
					local pickup_point = pickup_points[ math.random( 1, #pickup_points ) ]

					if isTimer( CHECK_POS_TIMER ) then
						killTimer( CHECK_POS_TIMER )
					end
					StartCheckPosition( pickup_point )

					CreateQuestPoint( pickup_point, 
						function()
							CEs.marker:destroy()
							triggerServerEvent( "PlayerAction_Task_Loader_2_step_1", localPlayer )
							if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
						end
					, _, 4, 0, 0, CheckPlayerQuestVehicle, _, _, "cylinder", 0, 255, 0, 20 )
				end;
			};
			event_end_name = "PlayerAction_Task_Loader_2_step_1";
			
		};

		[2] = {
			name = "Отвези коробки";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )
					local delivery_targets = table.copy( DELIVERY_TARGETS[ city ] or DELIVERY_TARGETS[ 0 ] )

					local required_boxes = {
						loader_company_1 = 1,
						loader_company_2 = 2,
						loader_company_3 = 3,
					}
					local boxes_amount = required_boxes[ localPlayer:GetJobID( ) ]

					local target = delivery_targets[ math.random( 1, #delivery_targets ) ]
					local boxes = { }
					for i = 1, boxes_amount do
						local object = Object( 1271, localPlayer.position )
						object:attach( localPlayer.vehicle, 0, 0.55, 0.22 + ( i - 1) * 0.68 )
						object:setParent( localPlayer.vehicle )
						table.insert( boxes, 1, object )
						CEs[ "box_" .. i ] = object
					end

					CreateQuestPoint( target, 
						function()
							CEs.marker:destroy()

							if localPlayer.vehicle then localPlayer.vehicle:ping( ) end

							triggerServerEvent( "PlayerAction_Task_Loader_2_step_2", localPlayer )
						end
					, _, 5, 0, 0, CheckPlayerQuestVehicle, _, _, "cylinder", 255, 100, 255, 20 )
				end;
			};

			event_end_name = "PlayerAction_Task_Loader_2_step_2";
		};

	};

	GiveReward = function( player )
		triggerEvent( "onLoaderMarkerPass", resourceRoot, player )
		StartAgain( player )
	end;

	no_show_success = true;
	no_show_rewards = true;
}

function StartAgain( player )
	setTimer( function()
		if not isElement( player ) then return end
		triggerEvent( "onJobRequestAnotherTask", player, player, false )
	end, 50, 1 )
end

function CheckPlayerQuestVehicle()
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "job_vehicle" ) then
		localPlayer:ShowError( "Ты не в автомобиле Грузчика" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не водитель автомобиля Грузчика" )
		return false
	end

	return true
end

function StartCheckPosition( target )
	CHECK_POS_TIMER = Timer( function( )
		if getDistanceBetweenPoints3D( target.x, target.y, target.z, getElementPosition( localPlayer ) ) > 250 then
			triggerServerEvent( "onJobEndShiftRequest", resourceRoot )
		end
	end, 5000, 0 )
end

function onLoaderCompany_EndShiftRequestReset()
	if isTimer( CHECK_POS_TIMER ) then
		killTimer( CHECK_POS_TIMER )
	end
end
addEvent("onLoaderCompany_EndShiftRequestReset", true)
addEventHandler( "onLoaderCompany_EndShiftRequestReset", root, onLoaderCompany_EndShiftRequestReset )

function CalculateLocations( starting_point, list, required_distance, required_points, current_list, total_distance )
	local required_points = required_points or 1
	if required_points <= 0 or #list <= 0 then return current_list or { } end

	local current_list = current_list or {}
	local list = table.copy( list )
	local starting_point = table.copy( starting_point )

	local min_distance = required_distance
	local min_distance_smallest = min_distance*0.1
	local start_vec3 = starting_point

	local suitable_list = {}
	for i, data in ripairs(list) do
		local list_vec3 = data
		local distance = (start_vec3 - list_vec3):getLength()
		if distance >= min_distance then
			table.insert(suitable_list, data)
		elseif distance <=  min_distance_smallest then
			table.remove(list, i)
		end
	end

	local point
	local decision_generation = (#current_list + required_points)*required_distance >= (total_distance or 0) and true or false
	if #suitable_list > 0 then
		table.sort(suitable_list, function(a, b) 
			local l1 = (start_vec3 - a):getLength()
			local l2 = (start_vec3 - b):getLength() 
			if decision_generation then
				return l1 < l2
			else
				return l1 > l2
			end
		end)
		point = suitable_list[math.random(1, math.ceil(#suitable_list/1.5))]
	elseif #list >= 1 then
		point = list[math.random(#list)]
	else
		return current_list
	end
	for i, v in pairs(list) do
		if v == point then
			table.remove(list, i)
			break
		end
	end
	local current_list = current_list or {}
	if point then table.insert(current_list, point) end
	local point_vec3 = point

	return CalculateLocations( point, list, required_distance, required_points - 1, current_list, ( total_distance or 0 ) + ( start_vec3 - point_vec3 ):getLength() )
end