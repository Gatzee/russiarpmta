loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CInterior" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "ShInventoryConfig" )

TRUNK_INVENTORY_MARKER = nil

addEvent( "onVehicleTrunkStateChange", true )
addEventHandler( "onVehicleTrunkStateChange", root, function( is_open )
    if TRUNK_INVENTORY_MARKER then
        TRUNK_INVENTORY_MARKER:destroy()
    end

    if not is_open then return end

    local vehicle = source
    local x0, y0, z0, x1, y1, z1 = vehicle:getBoundingBox()
    local y = FRONT_TRUNK_VEHICLES[ vehicle.model ] and y1 or y0

    local conf = {
        attach_to = vehicle,
        attach_offset = Vector3( 0, y, z0 + 1 ),
        radius = 1.4,
        color = { 10, 20, 200, 0 },
        -- marker_text = "Багажник",
        keypress = "lalt",
        text = "ALT Взаимодействие",
    }

    local tpoint = TeleportPoint( conf )
    -- tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255 } )
    -- tpoint:SetImage( ":nrp_radial_menu/files/img/icons/VehicleTrunk.png" )
    -- tpoint.element:setData( "material", true, false )

    tpoint.PostJoin = function( self, player )
        triggerServerEvent( "onPlayerWantShowVehicleInventory", vehicle )
    end

    tpoint.PostLeave = function( self, player )
        triggerEvent( "CloseInventory", resourceRoot, vehicle )
    end

    TRUNK_INVENTORY_MARKER = tpoint
end )
