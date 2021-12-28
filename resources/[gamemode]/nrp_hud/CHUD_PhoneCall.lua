HUD_CONFIGS.phone_call = {
    order = -999,
    elements = { },

    create = function( self )
        local bg = ibCreateArea( 0, 0, 340, 60, bg )
        self.elements.bg = bg

        self.elements.box = ibCreateImage( 275, 0, 60, 60, ":nrp_handler_voice/img/voice_small_phone.png", bg )
        
        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        self.elements = { }
    end,
}

function onClientTryPhoneCallPlayer_handler( call_data )
    AddHUDBlock( "phone_call" )
end
addEvent( "onClientTryPhoneCallPlayer", true )
addEventHandler( "onClientTryPhoneCallPlayer", root, onClientTryPhoneCallPlayer_handler )

function onClientEndPhoneCall_handler( call_data )
    RemoveHUDBlock( "phone_call" )
end
addEvent( "onClientEndPhoneCall", true )
addEventHandler( "onClientEndPhoneCall", root, onClientEndPhoneCall_handler )

addEvent( "onClientAcceptPhoneCall", true )
addEventHandler( "onClientAcceptPhoneCall", root, onClientEndPhoneCall_handler )