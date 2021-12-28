
function CreateJobVehicle( player, city, model )
    local job_class, job_id = player:GetJobClass(), player:GetJobID( )

    local vehicle_positions = city and JOB_DATA[ job_class ].vehicle_position[ city ] or JOB_DATA[ job_class ].vehicle_position[ 1 ]
    local vehicle_position_data = vehicle_positions[ job_id ] and vehicle_positions[ job_id ] or vehicle_positions[ DEFAULT_COMPANY_VEHICLE ]

    local spawn_info = vehicle_position_data.positions[ math.random( 1, #vehicle_position_data.positions ) ]
    triggerEvent( "CreateJobVehicleRequest", player, { 
        position             = spawn_info.position,
        rotation             = spawn_info.rotation,
        model                = model or (type( vehicle_position_data.vehicle_id ) == "table" and vehicle_position_data.vehicle_id[ job_id ] or vehicle_position_data.vehicle_id),
        max_idle             = 20 * 60000,
        destroy_on_shift_end = true,
        damage_threshold     = 400,
        city = city,
        callback_event = "onJobVehicleCreated",
    } )
end
addEvent( "OnPilotJobVehicleRequest" )
addEventHandler( "OnPilotJobVehicleRequest", root, CreateJobVehicle )

function CheckOnJobVehicle( vehicle )
    local job_vehicle = source:getData( "job_vehicle" )
    if isElement( job_vehicle ) and job_vehicle ~= vehicle then
        source:EndShift( "job_vehicle_exit" )
        triggerEvent( "PlayerFailStopQuest", source, { type = "quest_fail", fail_text = "Ты покинул рабочую машину" } )
    end
end

addEvent( "onJobVehicleIdle", true )
addEvent( "onJobVehicleDamage", true )

function onJobVehicleCreated_handler( vehicle, data )
    local player = data.player
    
    local job_class, job_id = player:GetJobClass(), player:GetJobID( )
    local vehicle_data = JOB_DATA[ job_class ].vehicle_position[ data.city ]
    local vehicle_data_city = vehicle_data[ job_id ] and vehicle_data[ job_id ] or vehicle_data[ DEFAULT_COMPANY_VEHICLE ]
    if vehicle_data_city.after_apply_fn then
        vehicle_data_city.after_apply_fn( vehicle )
    end

    warpPedIntoVehicle( player, vehicle )
    setCameraTarget( player, player )
    
    player:SetPrivateData( "job_vehicle", vehicle )
    
    addEventHandler( "onJobVehicleIdle", vehicle, function( data ) 
        if not isElement( player ) then return end

        TryToFinePlayer( player, vehicle )
        player:EndShift( "inaction" )
        triggerEvent( "PlayerFailStopQuest", player, { type = "fail_incation", fail_text = "Машина была забрана за бездействие" } )
    end )

    addEventHandler( "onJobVehicleDamage", vehicle, function( data )
        if not isElement( player ) then return end
        
        TryToFinePlayer( player, vehicle )
        player:EndShift( "destroy_car" )
        triggerEvent( "PlayerFailStopQuest", player, { type = "fail_destroy_vehicle", fail_text = "Ты разбил рабочую машину" } )
    end )
    
    vehicle:setEngineState( false )
end
addEvent( "onJobVehicleCreated", true )
addEventHandler( "onJobVehicleCreated", resourceRoot, onJobVehicleCreated_handler )