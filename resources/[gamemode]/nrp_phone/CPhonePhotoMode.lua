PHOTO_MODE_APP = nil

APPLICATIONS.photo_mode = {
    id = "photo_mode",
    icon = "img/apps/photo_mode.png",
    name = "Фоторежим",
    elements = { },
    create = function( self, parent, conf )
        if localPlayer:getData( "in_business_carsell" ) then return end

        if localPlayer:getData( "is_tased" ) then
            ShowPhoneUI( false )
            return
        end

        if localPlayer:getData( "is_handcuffed" ) then
            localPlayer:ShowInfo("Ты в наручниках")
            ShowPhoneUI( false )
            return
        end

        if IsMovePlayer( ) then
            localPlayer:ShowInfo("Сначала остановитесь")
            ShowPhoneUI( false )
            return
        end

        triggerEvent( "onClientShowMenuPhotoMode", resourceRoot )
        ShowPhoneUI( false )
        PHOTO_MODE_APP = self
        return self
    end,
    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        PHOTO_MODE_APP = nil
    end,
}

table.insert( ENABLED_APPLICATIONS, "photo_mode" )

function IsMovePlayer( )
    local vehicle = localPlayer.vehicle

    if ( vehicle and vehicle:getVelocity().length > 0 ) or localPlayer:getVelocity().length > 0 then
        return true
    end

    return false
end