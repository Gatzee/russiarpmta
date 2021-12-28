BLIPS = { }

function AddTaxiBlipTo_handler( player )
    local player = player or source

    onClientPlayerQuit_handler( player )
    local r, g, b = 255, 255, 0

    BLIPS[ player ] = createBlipAttachedTo( player, 41, 2, r, g, b, 255, 0, 99999, root )
    BLIPS[ player ]:setData( "extra_blip", 81, false )

    addEventHandler( "onClientPlayerQuit", player, onClientPlayerQuit_handler )

    local player_position = player.position
    triggerEvent( "onClientTryGenerateGPSPath", root, {
        x = player_position.x, y = player_position.y, z = player_position.z, route_id = "taxi_private",
    } )
end
addEvent( "AddTaxiBlipTo", true )
addEventHandler( "AddTaxiBlipTo", root, AddTaxiBlipTo_handler )

function RemoveAllTaxiBlips_handler()
    for i, v in pairs( BLIPS ) do
        onClientPlayerQuit_handler( i )
    end
    triggerEvent( "onClientTryDestroyGPSPath", root, "taxi_private" )
end
addEvent( "RemoveAllTaxiBlips", true )
addEventHandler( "RemoveAllTaxiBlips", root, RemoveAllTaxiBlips_handler )

function onClientPlayerQuit_handler( player )
    local player = isElement( player ) and player or source
    if isElement( BLIPS[ player ] ) then destroyElement( BLIPS[ player ] ) end
    removeEventHandler( "onClientPlayerQuit", player, onClientPlayerQuit_handler )

    triggerEvent( "onClientTryDestroyGPSPath", root, "taxi_private" )
end
