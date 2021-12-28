-- Точки взятия груза
PICKUP_POINTS = {
	-- НСК
	[ 0 ] = {
		Vector3( 304.489, -2781.746 + 860, 20.864 ),
	},
	-- Горки
	-- [ 1 ] = { }
}

-- Точки возврата к базе
RETURN_TARGETS = {
	-- НСК
	[ 0 ] = {
		Vector3( 304.489, -2781.746 + 860, 20.864 ),
	},
	-- Горки
	[ 1 ] = { }
}

DELIVERY_TARGETS = {
	-- НСК
	-- [ 0 ] = { },
	-- Горки
	-- [ 1 ] = { }
}

addEvent( "onCourierEarnMoney", true )

QUEST_DATA = {
	id = "task_courier_company";

	title = "Курьер ООО 'Лепта'";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_COURIER 
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

					CreateQuestPoint( pickup_point, 
						function()
							CEs.marker:destroy()
							triggerServerEvent( "PlayerAction_Task_Courier_2_step_1", localPlayer )
							if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
						end
					, _, 4, 0, 0, CheckPlayerQuestVehicle, _, _, _, 0, 255, 0, 20 )
					CEs.marker.slowdown_coefficient = nil
					CEs.marker.PreJoinContinuous = function( self, player )
						return player.vehicle and player.vehicle.velocity.length < 0.01
					end
				end;
			};
			CleanUp = {
				client = function( )
					--triggerServerEvent( "FarmerDaily_AddSell", localPlayer )
				end;
			};
			event_end_name = "PlayerAction_Task_Courier_2_step_1";
			
		};

		[2] = {
			name = "Отвези посылки по адресам";

			Setup = {
				client = function()
					if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
					local city = localPlayer:GetShiftCity( )

					-- Чтение точек из мап файла
					if not DELIVERY_TARGETS[ city ] then
						local targets = LoadXMLIntoVector3Positions( "map/directions_" .. city .. ".map" )
						if targets then DELIVERY_TARGETS[ city ] = targets end
					end

					local points = CalculateLocations( localPlayer.position, DELIVERY_TARGETS[ city ], 1200, 10 )
					local passed_points = 0
					for i, v in pairs( points ) do
						CreateQuestPoint( v, 
							function()
								CEs[ "marker_" .. i ]:destroy()
								CEs[ "marker_" .. i ] = nil
								passed_points = passed_points + 1

								if localPlayer.vehicle then localPlayer.vehicle:ping( ) end

								triggerServerEvent( "onCourierMarkerPass", resourceRoot )

								if passed_points == #points then
									triggerServerEvent( "PlayerAction_Task_Courier_2_step_2", localPlayer )
								else
									local available_points = {}
									local player_position = localPlayer.position
									for i in pairs( points ) do
										local point = CEs[ "marker_" .. i ]
										if point then
											point.distance = getDistanceBetweenPoints3D( point.x, point.y, point.z, player_position.x, player_position.y, player_position.z )
											table.insert( available_points, point )
											break
										end
									end

									table.sort( available_points, function( a, b )
										return a.distance < b.distance
									end )
								end
							end
						, "marker_" .. i, 5, 0, 0, CheckPlayerQuestVehicle, _, _, "cylinder", 255, 100, 255, 20, true )
						CEs[ "marker_" .. i ].slowdown_coefficient = nil
						CEs[ "marker_" .. i ].PreJoinContinuous = function( self, player )
							return player.vehicle and player.vehicle.velocity.length < 0.01
						end
					end
				end;
			};

			event_end_name = "PlayerAction_Task_Courier_2_step_2";
		};

		[3] = {
			name = "Вернись к Ленте за новым грузом";

			Setup = {
				client = function()
					if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
					local city = localPlayer:GetShiftCity( )
					local return_points = RETURN_TARGETS[ city ] or RETURN_TARGETS[ 1 ]
					local return_point = return_points[ math.random( 1, #return_points ) ]

					CreateQuestPoint( return_point, 
						function()
							CEs.marker:destroy()
							triggerServerEvent( "PlayerAction_Task_Courier_2_step_3", localPlayer )
							if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
						end
					, _, 4, 0, 0, false, _, _, _, 0, 255, 0, 20 )
				end;
			};

			event_end_name = "PlayerAction_Task_Courier_2_step_3";
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
	--iprint( "Pre checking quest vehicle" )
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "job_vehicle" ) then
		localPlayer:ShowError( "Ты не в автомобиле Курьера" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не водитель автомобиля Курьера" )
		return false
	end

	return true
end

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