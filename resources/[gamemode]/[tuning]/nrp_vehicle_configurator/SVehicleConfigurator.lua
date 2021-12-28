loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

function VehConfiguratorSet_handler( conf )
    local player = client or source

    local vehicle = player.vehicle
    for i, v in pairs( conf ) do
        setModelHandling( vehicle.model, vehicle:GetVariant( ) - 1, i, v )
    end
end
addEvent( "VehConfiguratorSet", true )
addEventHandler( "VehConfiguratorSet", root, VehConfiguratorSet_handler )

function VehConfiguratorLoad_handler( )
    local player = client or source
    triggerClientEvent( player, "ShowConfiguratorUI", player, true )
end
addEvent( "VehConfiguratorLoad", true )
addEventHandler( "VehConfiguratorLoad", root, VehConfiguratorLoad_handler )

function VehConfiguratorReset_handler( )
    client.vehicle:ParseHandling( )
    triggerEvent( "VehConfiguratorLoad", client )
end
addEvent( "VehConfiguratorReset", true )
addEventHandler( "VehConfiguratorReset", root, VehConfiguratorReset_handler )

function ApplyVehicleToVehicle_handler( vehmodel, variant )
    local vals = { }

    for i, v in pairs( values ) do
        local k = getModelHandling( vehmodel )[ v ]
        vals[ v ] = k
    end

    for i, v in pairs( VEHICLE_CONFIG[ vehmodel ].variants[ variant ].handling ) do
        vals[ i ] = v
    end

    triggerEvent( "VehConfiguratorSet", client, vals )

    triggerClientEvent( client, "ShowConfiguratorUI", client, true, { values = vals } )
end
addEvent( "ApplyVehicleToVehicle", true )
addEventHandler( "ApplyVehicleToVehicle", root, ApplyVehicleToVehicle_handler )

function ApplyTableToVehicle_handler( tab )
    local vals = { }
    local vehmodel = client.vehicle.model

    for i, v in pairs( values ) do
        local k = getModelHandling( vehmodel )[ v ]
        vals[ v ] = k
    end

    for i, v in pairs( tab ) do
        vals[ i ] = v
    end

    triggerEvent( "VehConfiguratorSet", client, vals )

    triggerClientEvent( client, "ShowConfiguratorUI", client, true, { values = vals } )
end
addEvent( "ApplyTableToVehicle_handler", true )
addEventHandler( "ApplyTableToVehicle_handler", root, ApplyTableToVehicle_handler )

addCommandHandler( "handling", function( player )
    triggerEvent( "VehConfiguratorLoad", player )
end )