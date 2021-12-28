-- Точки взятия груза
PICKUP_POINTS = {
	-- НСК
	[ 0 ] = {
		Vector3( -876.636, -1742.561 + 860, 21.512 ),
	},
	-- Горки
	[ 1 ] = {
		Vector3( 2066.313, -633.956 + 860, 60.641 ),
	}
}

-- Направления
DELIVERY_TARGETS = {
	-- НСК
	-- [ 0 ] = { },
	-- Горки
	-- [ 1 ] = { }
}

-- Точки возврата к базе
RETURN_TARGETS = {
	-- НСК
	[ 0 ] = {
		Vector3( -876.636, -1742.561 + 860, 21.512 ),
	},
	-- Горки
	[ 1 ] = {
		Vector3( 2066.313, -633.956 + 860, 60.641 ),
	}
}

addEvent( "onCourierEarnMoney", true )

QUEST_DATA = {
	id = "task_courier_base";

	title = "Курьер на подработке";
	description = "";

	CheckToStart = function( player )
		return player:GetJobClass( ) == JOB_CLASS_COURIER
	end;

	replay_timeout = 0;

	tasks = {
		[1] = {
			name = "Забери посылки";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )
					local pickup_points = PICKUP_POINTS[ city ]
					--iprint( "Client city", city, "points", pickup_points )
					local pickup_point = pickup_points[ math.random( 1, #pickup_points ) ]

					CreateQuestPoint( pickup_point, 
						function()
							CEs.marker:destroy()
							triggerServerEvent( "PlayerAction_Task_Courier_1_step_1", localPlayer )
						end
					, _, 2, 0, 0, false, "lalt", "Нажми 'Левый Alt' чтобы забрать посылки", "cylinder", 0, 255, 0, 20 )
				end;
			};

			event_end_name = "PlayerAction_Task_Courier_1_step_1";
		};
		[2] = {
			name = "Отвези посылки по адресам";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )

					-- Чтение точек из мап файла
					if not DELIVERY_TARGETS[ city ] then
						local targets = LoadXMLIntoVector3Positions( "map/directions_" .. city .. ".map" )
						if targets then DELIVERY_TARGETS[ city ] = targets end
					end

					local points = CalculateLocations( localPlayer.position, DELIVERY_TARGETS[ city ], 200, 5 )
					local passed_points = 0
					for i, v in pairs( points ) do
						CreateQuestPoint( v, 
							function()
								CEs[ "marker_" .. i ]:destroy()
								CEs[ "marker_" .. i ] = nil
								passed_points = passed_points + 1

								triggerServerEvent( "onCourierMarkerPass", resourceRoot )

								if passed_points == #points then
									triggerServerEvent( "PlayerAction_Task_Courier_1_step_2", localPlayer )
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
						, "marker_" .. i, 2, 0, 0, false, _, _, "cylinder", 255, 100, 255, 20, true )
					end
				end;
			};

			event_end_name = "PlayerAction_Task_Courier_1_step_2";
		};
		[3] = {
			name = "Вернись на почту";

			Setup = {
				client = function()
					local city = localPlayer:GetShiftCity( )
					local return_point = RETURN_TARGETS[ city ][ math.random( 1, #RETURN_TARGETS[ city ] ) ]

					CreateQuestPoint( return_point, 
						function()
							CEs.marker:destroy()
							triggerServerEvent( "PlayerAction_Task_Courier_1_step_3", localPlayer )
						end
					, _, 2, 0, 0, false, _, _, "cylinder", 0, 255, 0, 20 )
				end;
				CleanUp = function()

				end;
			};

			event_end_name = "PlayerAction_Task_Courier_1_step_3";
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
	end, 5000, 1 )
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