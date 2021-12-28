local PARTYAPP = nil

APPLICATIONS.party = {
    id = "party",
    icon = "img/apps/party.png",
    name = "Тусовки",
    elements = { },

    create = function( self, parent, conf )
        self.parent = parent
        self.conf = conf
        self.elements.header_texture = dxCreateTexture( "img/elements/party_header.png" )

        local hsx, hsy = dxGetMaterialSize( self.elements.header_texture )
        local size_y = hsy * conf.sx / hsx

        self.elements.header = ibCreateImage( 0, 0, hsx, size_y, self.elements.header_texture, parent, 0xFFFFFFFF )

        triggerServerEvent( "onPartyListRequest", localPlayer )

        PARTYAPP = self
        return self
    end,

    create_contents = function( self, parent, conf, list, can_create )
        ibUseRealFonts( true )

        local hsx, hsy = dxGetMaterialSize( self.elements.header_texture )
        local size_y = hsy * conf.sx / hsx
        local usable_y_space = conf.sy - size_y - ( can_create and 50 or 0 )

        self.elements.rt, self.elements.sc = ibCreateScrollpane( 0, size_y, conf.sx, usable_y_space, UI_elements.background, {
            scroll_px = -22,
            bg_sx = 0,
            handle_sy = 40,
            handle_sx = 16,
            handle_texture = ":nrp_shared/img/scroll_bg_small.png",
            handle_upper_limit = -40 - 20,
            handle_lower_limit = 20,
        } )
        self.elements.sc:ibData( "sensivity", 0.1 )

        local parent = self.elements.rt

        local counter = 0
        for _, party in pairs( list ) do
            local area = ibCreateArea( 0, 74 * counter, conf.sx, 74, parent )
            local name = ibCreateLabel( 12, 9, 0, 0, party.name, area, nil, nil, nil, nil, nil, ibFonts.regular_12 )

            ibCreateImage( 0, 73, conf.sx, 1, nil, area, 0x22000000 )
            ibCreateButton( 12, 36, 97, 23, area, "img/elements/notifications/btn_show_more", true )
            :ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                triggerEvent( "onClientShowPartyUI", localPlayer, party )
            end )

            if party.contain_client then
                ibCreateImage( 20 + name:width( ), 11, 16, 12, ":nrp_shared/img/icon_tick.png", area )
            end

            counter = counter + 1
        end

        self.elements.rt:AdaptHeightToContents( )
        self.elements.sc:UpdateScrollbarVisibility( self.elements.rt )

        if can_create then
            self.elements.bg = ibCreateImage( 0, conf.sy - 50, conf.sx, 50, nil, UI_elements.background, 0xff2f4258 )
            self.elements.shadow = ibCreateImage( 0, conf.sy - 51, conf.sx, 1, nil, UI_elements.background, ibApplyAlpha( 0xff2f4258, 25 ) )
            self.elements.btn = ibCreateButton( 0, conf.sy - 40, 152, 30, UI_elements.background, "img/elements/notifications/btn_create", true )
            :center_x( ):ibOnClick( function ( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                ShowPhoneUI( false )
                triggerEvent( "onClientShowPartyCreation", localPlayer )
            end )
        end

        ibUseRealFonts( false )
    end,

    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        PARTYAPP = nil
    end,
}

addEvent( "onPartyListResponse", true )
addEventHandler( "onPartyListResponse", localPlayer, function ( list, has_party )
    if not PARTYAPP then return end

    PARTYAPP:create_contents( PARTYAPP.parent, PARTYAPP.conf, list, has_party )
end )