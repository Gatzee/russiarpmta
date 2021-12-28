

function CreateHijackedVehicle( lobby_data )
    local vehicle_id = HIJACKED_CARS_ID[ math.random( 1, #HIJACKED_CARS_ID ) ]
    local hijacked_data = POSITIONS_HIJACKED_CARS[ lobby_data.hijack_point_id ]
    
    local vehicle = CreateTemporaryQuestVehicle( lobby_data.lobby_id, vehicle_id, hijacked_data.vehicle.pos + Vector3( 0, 0, 1 ), hijacked_data.vehicle.rot )
    
    local vehicle_color = HIJACKED_CARS_COLOR[ math.random( 1, #HIJACKED_CARS_COLOR ) ]
    setVehicleColor( vehicle, unpack( vehicle_color ) )

    vehicle:setData( "ignore_removal", true, false )
    vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_AUTO ) )
    vehicle:setData( "block_repair", true, false )
    vehicle:setData( "block_engine", true )
    vehicle:setData( "block_interaction", true )

    vehicle:setEngineState( false )
    
    local driver = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_DRIVER, true )
    addEventHandler( "onVehicleStartEnter", vehicle, function( player, seat )
        if player ~= driver and seat == 0 or not lobby_data.is_success_hacked then cancelEvent() end
    end )

    return vehicle
end

function GenerateHijackPoint( lobby_data )
    if SERVER_NUMBER > 100 and TARGET_POINT_ID then
        return TARGET_POINT_ID
    end

    local point_id = 1
    if lobby_data.hijack_point_id then
        local prev_hijack_point = POSITIONS_HIJACKED_CARS[ lobby_data.hijack_point_id ].vehicle
        for k, v in pairs( POSITIONS_HIJACKED_CARS ) do
            if (prev_hijack_point.pos - v.vehicle.pos).length >= CONST_MIN_DISTANCE_BETWEEN_POINTS and #getElementsWithinRange( v.vehicle.pos, 5, "vehicle" ) == 0 then
                continue = false
                for _, last_point_id in pairs( lobby_data.last_points ) do
                    if last_point_id == k then
                        continue = true
                    end
                end
                if not continue then
                    point_id = k
                end
            end
        end
    else
        point_id = math.random( 1, #POSITIONS_HIJACKED_CARS )
    end

    if not lobby_data.last_points then lobby_data.last_points = {} end
    table.insert( lobby_data.last_points, point_id )
    
    local count_points = #lobby_data.last_points
    if count_points > CONST_MAX_CACHE_HIJACK_POINTS then
        table.remove( lobby_data.last_points, count_points )
    end

    return point_id
end

function GenerateHijackedVehiclePassword( lobby_data )
    lobby_data.password = ""
    for i = 1, 6 do
        lobby_data.password = lobby_data.password .. CONST_PASSOWRD_SYMBOLS[ math.random( 1, #CONST_PASSOWRD_SYMBOLS ) ] 
    end
end