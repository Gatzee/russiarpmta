TUTORIAL_VEHICLES = { }

function CreateTutorialVehicleForPlayer( player, position, rotation, ignore_warp )
    if TUTORIAL_VEHICLES[ player ] then return end

    local position = position or player.position
    local rotation = rotation or player.rotation
    
    local vehicle = Vehicle.CreateTemporary( 550, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z )

    --setVehicleHandling( vehicle, "maxVelocity", 50 )
    vehicle:SetVariant( 2 )
    setVehicleDamageProof( vehicle, true )
    vehicle:SetColor( 0, 0, 0 )
    vehicle:setData( "tutorial", true, false )
    vehicle:SetFuel( "full" )

    setElementSyncer( vehicle, player )
    setElementDimension( vehicle, player.dimension )

    player:SetPrivateData( "tutorial_vehicle", vehicle )
    if not ignore_warp then warpPedIntoVehicle( player, vehicle ) end

    addEventHandler( "onPlayerPreLogout", player, onPlayerPreLogout_handler )

    TUTORIAL_VEHICLES[ player ] = vehicle

    return vehicle
end

function DestroyTutorialVehicle( player, ignore_trigger )
    if TUTORIAL_VEHICLES[ player ] then
        if isElement( TUTORIAL_VEHICLES[ player ] ) then
            destroyElement( TUTORIAL_VEHICLES[ player ] )
        end
        if not ignore_trigger then
            player:SetPrivateData( "tutorial_vehicle", false )
        end
        TUTORIAL_VEHICLES[ player ] = nil
        removeEventHandler( "onPlayerPreLogout", player, onPlayerPreLogout_handler )
    end
end

function onPlayerPreLogout_handler( )
    DestroyTutorialVehicle( source, true )
end

function onResourceStop_handler( )
    for i, v in pairs( TUTORIAL_VEHICLES ) do
        DestroyTutorialVehicle( i )
    end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )