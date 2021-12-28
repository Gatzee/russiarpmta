-- SActionTasksUtils.lua

_PLAYER_TEMP_VEHS = _PLAYER_TEMP_VEHS or { }

function onPlayerQuit_temporaryVehicleHandler( )
    DestroyAllTemporaryVehicles( source )
end

function CreateTemporaryVehicle( player, model, position, rotation, dimension )
    local position = position or player.position
    local rotation = rotation or player.rotation

    _PLAYER_TEMP_VEHS[ player ] = _PLAYER_TEMP_VEHS[ player ] or { }
    local vehicle = Vehicle.CreateTemporary( model, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z )
    table.insert( _PLAYER_TEMP_VEHS[ player ], vehicle )

    removeEventHandler( "onPlayerQuit", player, onPlayerQuit_temporaryVehicleHandler )
    addEventHandler( "onPlayerQuit", player, onPlayerQuit_temporaryVehicleHandler )

    setElementSyncer( vehicle, player )
    setElementDimension( vehicle, player:GetUniqueDimension( ) )

    return vehicle
end

function DestroyTemporaryVehicle( player, vehicle )
    if _PLAYER_TEMP_VEHS[ player ] then
        for i, v in pairs( _PLAYER_TEMP_VEHS[ player ] ) do
            if v == vehicle then
                if isElement( vehicle ) then destroyElement( vehicle ) end
                table.remove( _PLAYER_TEMP_VEHS[ player ], i )
                break
            end
        end
        if #_PLAYER_TEMP_VEHS[ player ] <= 0 then
            DestroyAllTemporaryVehicles( player )
        end
    end
end

function DestroyAllTemporaryVehicles( player )
    if _PLAYER_TEMP_VEHS[ player ] then
        for i, v in pairs( _PLAYER_TEMP_VEHS[ player ] ) do
            if isElement( v ) then destroyElement( v ) end
        end
        _PLAYER_TEMP_VEHS[ player ] = nil
        removeEventHandler( "onPlayerQuit", player, onPlayerQuit_temporaryVehicleHandler )
    end
end

function GetTemporaryVehicle( player, index )
    return _PLAYER_TEMP_VEHS[ player ] and _PLAYER_TEMP_VEHS[ player ][ index or 1 ]
end

addEventHandler( "onResourceStop", resourceRoot, function( )
    for i, v in pairs( _PLAYER_TEMP_VEHS ) do
        DestroyAllTemporaryVehicles( i )
    end
end )

function EnterLocalDimension( player, ignore_sync )
    setElementData( player, "at_save_dim", player:getData( "at_save_dim" ) or player.dimension, false )
    player.dimension = player:GetUniqueDimension( )
    if not ignore_sync then
        triggerClientEvent( player, "onPlayerMoveQuestElements", player )
    end
end

function EnterLocalDimensionForVehicles( player, position, range )
    local range = range or 100
    local position = position or player.position
    local vehicles_to_take = { }

    for i, v in pairs( player:GetVehicles( true, true ) ) do
        if isElement( v ) and ( position - v.position ).length <= range and not v:GetBlocked( ) and not getElementData( v, 'tow_evac_added' ) and not v:GetParked( ) then
            table.insert( vehicles_to_take, v )
        end
    end

    if #vehicles_to_take > 0 then
        local result_vehicles = { }
        local dimension = player:GetUniqueDimension( )
        for i, v in pairs( vehicles_to_take ) do
            setElementData( v, "at_is_teleported", true, false )
            for _, occupant in pairs( getVehicleOccupants( v ) ) do
                removePedFromVehicle( occupant )
            end
            setElementDimension( v, dimension )
            result_vehicles[ v ] = true
        end

        return result_vehicles
    end
end

function EnableQuestEvacuation( player )
    player:setData( "quest_evacuation", true, false )
end

function DisableQuestEvacuation( player )
    player:setData( "quest_evacuation", false, false )
end

function ExitLocalDimension( player )
    local dimension = getElementData( player, "at_save_dim" ) or 0
    setElementData( player, "at_save_dim", false, false )
    player.dimension = dimension
    triggerClientEvent( player, "onPlayerMoveQuestElements", player )

    return ExitLocalDimensionForVehicles( player )
end

function ExitLocalDimensionForVehicles( player )
    local vehicles_to_park = { }

    for i, v in pairs( player:GetVehicles( true, true ) ) do
        if isElement( v ) and getElementData( v, "at_is_teleported" ) then
            table.insert( vehicles_to_park, v )
        end
    end

    if #vehicles_to_park > 0 then
        local given_evacuations = 0

        for i, v in pairs( vehicles_to_park ) do
            setElementData( v, "at_is_teleported", false, false )
            v:SetParked( true )

            local vehicle_id = v:GetID( )
            if not player:HasFreeEvacuation( vehicle_id ) then
                player:GiveFreeEvacuation( vehicle_id )
                given_evacuations = given_evacuations + 1
            end
        end

        return given_evacuations > 0
    end
end