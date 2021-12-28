TRUCK_ACTIONS_INFO = {
    open_doors = {
        name = "dveri",
        default_position = Vector3( 0, -4.8612, 1.6751 ),
        delta_position = Vector3( 0, 0, 1 ),
        duration = 2000,
    },
    lift_body = {
        name = "kuzov",
        default_position = Vector3( 0, -2.4964, 0.1328 ),
        delta_position = Vector3( 0, 0, 0.5 ),
        default_rotation = Vector3( 0, 0, 0 ),
        delta_rotation = Vector3( 20, 0, 0 ),
        duration = 5000,
    },
}

local PROCESSING_ACTIONS = { }
for action_name in pairs( TRUCK_ACTIONS_INFO ) do
    PROCESSING_ACTIONS[ action_name ] = { }
end

function ProcessAction( action_name, vehicle, state )
    local action_info = TRUCK_ACTIONS_INFO[ action_name ]
    local action = {
        started = getTickCount( ),
        state = state and 1 or 0,
    }
    if action_info.default_position then
        action.start_position = Vector3( vehicle:getComponentPosition( action_info.name ) )
        local end_position = state and ( action_info.default_position + action_info.delta_position ) or action_info.default_position
        action.delta_position = end_position - action.start_position
    end
    if action_info.default_rotation then
        action.start_rotation = Vector3( vehicle:getComponentRotation( action_info.name ) )
        local end_rotation = state and ( action_info.default_rotation + action_info.delta_rotation ) or action_info.default_rotation
        action.delta_rotation = end_rotation - action.start_rotation
    end
    PROCESSING_ACTIONS[ action_name ][ vehicle ] = action

    removeEventHandler( "onClientPreRender", root, UpdateActionsProgress )
    addEventHandler( "onClientPreRender", root, UpdateActionsProgress )
end

function RemoveAction( action_name, vehicle )
    PROCESSING_ACTIONS[ action_name ][ vehicle ] = nil

    for _action_name, vehicles in pairs( PROCESSING_ACTIONS ) do
        if next( vehicles ) then
            return
        end
    end
end

function UpdateActionsProgress( )
    local tick = getTickCount( )
    local all_actions_processed = true
    for action_name, vehicles in pairs( PROCESSING_ACTIONS ) do
        local action_info = TRUCK_ACTIONS_INFO[ action_name ]
        local component = action_info
        for vehicle, v in pairs( vehicles ) do
            if isElement( vehicle ) then
                local progress = ( tick - v.started ) / action_info.duration
                progress = progress > 1 and 1 or progress
                if progress == 1 then vehicles[ vehicle ] = nil end

                if v.start_position then
                    vehicle:setComponentPosition( component.name, v.start_position + v.delta_position * progress )
                end
                if v.start_rotation then
                    vehicle:setComponentRotation( component.name, v.start_rotation + v.delta_rotation * progress )
                end
            else
                vehicles[ vehicle ] = nil
            end
        end
        if next( vehicles ) then
            all_actions_processed = false
        end
    end
    if all_actions_processed then
        removeEventHandler( "onClientPreRender", root, UpdateActionsProgress )
    end
end

-- Открытие/закрытие кузова
addEvent( "onClientTrashTruckOpenStateChange", true )
addEventHandler( "onClientTrashTruckOpenStateChange", root, function( state )
    ProcessAction( "open_doors", source, state )
end )

-- Опускание/поднятие кузова
addEvent( "onClientTrashTruckLiftStateChange", true )
addEventHandler( "onClientTrashTruckLiftStateChange", root, function( state )
    ProcessAction( "lift_body", source, state )
    if state then
        unloadTrashBagObjectFromTruck( source )
    end
end )

-- Скрытие дефолтного мусора внутри мусоровоза
local SHADER_CODE = [[
	technique tec0
	{
		pass P0
		{
            ZEnable = false;
            AlphaTestEnable = true;
			MaterialDiffuse = float4(0,0,0,0);
		}
	}
]]

local HIDE_SHADER = dxCreateShader( SHADER_CODE, 0, 50, false, "vehicle" )
if HIDE_SHADER then
    engineApplyShaderToWorldTexture( HIDE_SHADER, "musor" )
end

function attachTrashBagObjectToTruck( object, truck )
    object:setCollisionsEnabled( false )
    object.parent = truck

    local trash_bag_objects = truck:getData( "trash_bag_objects" ) or { }
    local trash_bags_count = #trash_bag_objects
    local x = ( trash_bags_count % 3 - 1 ) * 0.6
    local y = -math.floor( trash_bags_count / 3 ) * 0.6
    object:attach( truck, x, y, 0.7, 0, 0, math.random( 360 ) )

    table.insert( trash_bag_objects, object )
    truck:setData( "trash_bag_objects", trash_bag_objects, false )
end

function unloadTrashBagObjectFromTruck( truck )
    local trash_bag_objects = truck:getData( "trash_bag_objects" )
    if not trash_bag_objects then return end

    truck:setData( "trash_bag_objects", nil, false )
    
    local w = 6
    
    local duration = 5000
    local start_tick = getTickCount( )
    local progress = 0

    local start_poses = {  }
    local oy = {  }
    for i = #trash_bag_objects, 1, -1 do
        if not isElement( trash_bag_objects[ i ] ) then
            table.remove( trash_bag_objects, i )
        end
    end
    for i, object in pairs( trash_bag_objects ) do
        oy[ i ] = -math.floor( ( i - 1 ) / 3 ) * 0.6
        start_poses[ i ] = object.position
        object:detach( )
    end
    
    local fall_start_ticks = {  }
    local function TrashFunction( )
        progress = ( getTickCount( ) - start_tick ) / duration
        if progress > 1 then
            removeEventHandler( "onClientRender", root, TrashFunction )
            progress = 1
        end
        
        for i, object in pairs( trash_bag_objects ) do
            local oy = -oy[ i ]
            local current_dy = progress * w
            local current_dz = math.sin( math.rad( progress * 20 ) ) * ( ( 1 - progress ) * ( w - 1 ) - oy )
    
            if current_dy + oy > 5.2 then
                fall_start_ticks[ i ] = fall_start_ticks[ i ] or getTickCount( )
                local fall_progress = math.min( 1, ( getTickCount( ) - fall_start_ticks[ i ] ) / 500 )
                current_dz = -1.5 * fall_progress

                current_dy = current_dy - fall_progress * 0.5
            end
            object.position = start_poses[ i ] - truck.matrix.forward * current_dy + Vector3( 0,0, current_dz )
        end
        
    end
    addEventHandler( "onClientRender", root, TrashFunction )

	addEventHandler( "onClientElementDestroy", truck, function( )
        removeEventHandler( "onClientRender", root, TrashFunction )
        if progress == 1 then return end
        for i, object in pairs( trash_bag_objects ) do
            if isElement( object ) then
                object:destroy( )
            end
        end
        trash_bag_objects = nil
    end )
    
    -- Удаление мусорных мешков через 1 мин
    CEs.delete_bugs_tmr = setTimer( function( )
        if not trash_bag_objects then return end
        local duration = 10000
        local start_tick = getTickCount( )

        local start_poses = {  }
        for i, object in pairs( trash_bag_objects ) do
            if isElement( object ) then
                start_poses[ i ] = object.position
            end
        end

        local function TrashFunction( )
            local progress = ( getTickCount( ) - start_tick ) / duration
            if progress >= 1 then
                removeEventHandler( "onClientRender", root, TrashFunction )
            end
            
            for i, object in pairs( trash_bag_objects ) do
                if isElement( object ) then
                    if progress >= 1 then
                        object:destroy( )
                    else
                        object.position = start_poses[ i ] - Vector3( 0, 0, 2 * progress )
                    end
                end
            end
        end
        addEventHandler( "onClientRender", root, TrashFunction )
    end, 60 * 1000, 1 )
end