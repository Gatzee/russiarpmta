Extend( "ShBusiness" )
Extend( "CPlayer" )
Extend( "CInterior" )

for i, data in pairs( BUSINESS_ELEMENTS ) do
    if data.business_id == 4 and data.building_type == "sell" then
        local conf = { }

        conf.x, conf.y, conf.z = data.x, data.y + 860, data.z

        conf.radius = 2
        conf.color = { 0, 100, 255, 40 }
        conf.marker_text = data.marker_text or "Продажа транспорта\nГосударству"
        conf.keypress = "lalt"
        conf.text = "ALT Взаимодействие"

        local marker = TeleportPoint( conf )
        --marker:SetImage( "images/marker_icon.png" )
        marker.element:setData( "material", true, false )
        marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.45 } )

        marker.PostJoin = function( self, player )
            if localPlayer.vehicle then return end
            
            CURRENT_SPECIAL_TYPES = data.accepted_special_types

            triggerServerEvent( "onPlayerGovsellListRequest", resourceRoot, CURRENT_SPECIAL_TYPES )
        end

        marker.PostLeave = function( self )
            ShowGovsellUI( false )
        end
    end
end