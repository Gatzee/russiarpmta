loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SVehicle" )

PLAYER_VEHICLES = { }

Player.CanAccessPanel = function( self )
    return self:GetAccessLevel() >= ACCESS_LEVEL_SUPERVISOR or self:GetPermanentData( "vehpanel" )
end

function onResourceStop_handler( )
    for i, v in pairs( PLAYER_VEHICLES ) do
        if isElement( i ) then
            destroyElement( i )
        end
    end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )

function onPlayerQuit()
    for i, v in pairs( PLAYER_VEHICLES ) do
        if source == v and isElement( i ) then
            i:destroy()
            PLAYER_VEHICLES[ i ] = nil
        end
    end
end

function vehpanel_handler( player )
    if not player:CanAccessPanel() then return end
    triggerClientEvent( player, "ToggleVehpanel", resourceRoot )
end
addCommandHandler( "vehpanel", vehpanel_handler )

function onVehpanelCreateRequest_handler( vehicle_id )
    if not client then return end
    if not client:CanAccessPanel() then return end

	local px, py, pz = client.position.x, client.position.y, client.position.z
    local vehicle = Vehicle.CreateTemporary( vehicle_id, px, py, pz, 0, 0, 0 )
    if vehicle then
        PLAYER_VEHICLES[ vehicle ] = client
        addEventHandler( "onElementDestroy", vehicle, 
            function()
                PLAYER_VEHICLES[ source ] = nil
            end
        )
        removeEventHandler( "onPlayerQuit", client, onPlayerQuit )
        addEventHandler( "onPlayerQuit", client, onPlayerQuit )
        warpPedIntoVehicle( client, vehicle, 0 )
        triggerClientEvent( client, "onVehpanelCreate", resourceRoot, vehicle )
    end
end
addEvent( "onVehpanelCreateRequest", true )
addEventHandler( "onVehpanelCreateRequest", root, onVehpanelCreateRequest_handler )


function onVehpanelDestroyRequest_handler( id )
    if not client then return end
    if not client:CanAccessPanel() then return end
    local vehicle = GetVehicle( id )
    if vehicle then vehicle:destroy() end
end
addEvent( "onVehpanelDestroyRequest", true )
addEventHandler( "onVehpanelDestroyRequest", root, onVehpanelDestroyRequest_handler )

function onVehpanelTeleportRequest_handler( id )
    if not client then return end
    if not client:CanAccessPanel() then return end
    local vehicle = GetVehicle( id )
    if vehicle then
        local occupants = getVehicleOccupants( vehicle )
        for i, v in pairs( occupants ) do
            removePedFromVehicle( v )
        end
        vehicle.position = client.position
        vehicle.interior = client.interior
        vehicle.dimension = client.dimension
        warpPedIntoVehicle( client, vehicle )
    end
end
addEvent( "onVehpanelTeleportRequest", true )
addEventHandler( "onVehpanelTeleportRequest", root, onVehpanelTeleportRequest_handler )