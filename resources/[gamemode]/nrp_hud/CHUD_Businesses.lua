HUD_CONFIGS.businesses = {
    elements = { },

    create = function( self, business_config )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_businesses.png", bg ) --ibCreateImage( 0, 0, 340, 80, _, _, 0xd72a323c )
        self.elements.bg = bg
        
        local business_id = business_config.icon and split( business_config.business_id, "_" )[ 1 ] or string.gsub( business_config.business_id, "_%d+$", "" )
        ibCreateImage( 15, 8, 64, 64, ":nrp_businesses/img/icons/64x64/" .. business_id .. ".png", bg )
        
        return bg
    end,

    destroy = function( self )
        local to_destroy = { self.elements.bg }
        DestroyTableElements( to_destroy )
        
        self.elements = { }
    end,
}

function ShowBusinessInfo_handler( business_config )
    AddHUDBlock( "businesses", business_config )
    localPlayer:setData( "business_near", true, false )
end
addEvent( "ShowBusinessInfo", true )
addEventHandler( "ShowBusinessInfo", root, ShowBusinessInfo_handler )

function HideBusinessInfo_handler( )
    RemoveHUDBlock( "businesses" )
    localPlayer:setData( "business_near", false, false )
end
addEvent( "HideBusinessInfo", true )
addEventHandler( "HideBusinessInfo", root, HideBusinessInfo_handler )