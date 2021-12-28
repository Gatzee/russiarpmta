FORBESAPP = nil

APPLICATIONS.forbes = {
    id = "forbes",
    icon = "img/apps/forbes.png",
    name = "Форбс",
    elements = { },
    create = function( self, parent, conf )
        self.parent = parent
        self.conf = conf
        self.elements.header_texture = dxCreateTexture( "img/elements/forbes_header.png" )
        local hsx, hsy = dxGetMaterialSize( self.elements.header_texture )

        local tex_list = { "btn_forbes_shop" }
        for k,v in pairs(tex_list) do
            self.elements["tex_"..v] = dxCreateTexture( "img/elements/"..v..".png" )
        end

        local size_y = hsy * conf.sx / hsx
        self.elements.header = ibCreateImage( 0, 0, hsx, size_y, self.elements.header_texture, parent, 0xFFFFFFFF )

        triggerServerEvent( "onClientRequestForbesList", resourceRoot )

        FORBESAPP = self
        return self
    end,
    create_contents = function( self, parent, conf, info )
        local list = info.list
        local player_info = info.player_info
        local office_data = info.office_data

        local hsx, hsy = dxGetMaterialSize( self.elements.header_texture )
        local size_y = hsy * conf.sx / hsx
        local usable_y_space = conf.sy - size_y

        self.elements.rt, self.elements.sc = ibCreateScrollpane( 0, size_y, conf.sx, usable_y_space, UI_elements.background, 
            {
                scroll_px = -22,
                bg_sx = 0,
                handle_sy = 40,
                handle_sx = 16,
                handle_texture = ":nrp_shared/img/scroll_bg_small.png",
                handle_upper_limit = -40 - 20,
                handle_lower_limit = 20,
            }
        )
        self.elements.sc:ibData( "sensivity", 0.1 )

        local parent = self.elements.rt
        
        ibCreateImage( 0, 10, conf.sx, 18, _, parent, 0x55000000 )
        ibCreateLabel( 14, 10, conf.sx-30, 18, "ВАШЕ МЕСТО", parent, 0xFFFFFFFF, _, _, _, "center", ibFonts.regular_10 )

        local coins = player_info and player_info.coins or 0
        local coins = player_info and player_info.coins or 0
        local position = coins and coins > 0 and player_info and player_info.position or "N/A"

        ibCreateLabel( 14, 42, conf.sx-30, 18, position, parent, 0xFFFFFFFF, _, _, _, "center", ibFonts.regular_10 )
        ibCreateImage( conf.sx - 14 - 18, 43, 14, 14, ":nrp_shared/img/business_coin_icon.png", parent, 0xFFFFFFFF )
        ibCreateLabel( conf.sx - 14 - 14 - 10, 42, 0, 0, format_price( coins ), parent, 0xFFFFFFFF, _, _, "right", "top", ibFonts.regular_10 )
        
        ibCreateButton( 14, 67, 176, 30, parent,
                        self.elements.tex_btn_forbes_shop, self.elements.tex_btn_forbes_shop, self.elements.tex_btn_forbes_shop, 
                        0xFFFFFFFF, 0xFFDDDDDD, 0xFFDDDDDD )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
			triggerEvent( "ShowBusinessesShop", root, office_data )
			ShowPhoneUI( false )
        end )

        ibCreateImage( 0, 111, conf.sx, 18, _, parent, 0xFFFFFFFF - 0xAA000000 )
        ibCreateLabel( 14, 111, conf.sx-30, 18, "ТАБЛИЦА ЛИДЕРОВ", parent, 0xFFFFFFFF, _, _, _, "center", ibFonts.regular_10 )

        local npy = 134
        local nsy = 50

        table.sort( list, function( a, b ) return a.business_coins > b.business_coins end )

        for i, v in ipairs( list ) do
            -- Позиция
            ibCreateLabel( 15, npy, conf.sx-30, nsy, i, parent, 0xFFFFFFFF, _, _, _, "center", ibFonts.regular_10 )

            -- Имя
            ibCreateLabel( 44, npy + 5, 0, 0, v.nickname, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_10 )

            -- Коины
            local coins = format_price( v.business_coins )
            local lbl_coins = ibCreateLabel( 44, npy + 25, 0, 0, coins, parent, 0xFFFFFFFF ):ibData( "font", ibFonts.regular_10 )
            ibCreateImage( 44 + lbl_coins:width( ) + 5, npy + 26, 14, 14, ":nrp_shared/img/business_coin_icon.png", parent )

            npy = npy + nsy + 1
        end

        self.elements.rt:AdaptHeightToContents( )
        self.elements.sc:UpdateScrollbarVisibility( self.elements.rt )
    end,

    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        FORBESAPP = nil
    end,
}

function onClientRequestForbesListCallback_handler( conf )
    if not FORBESAPP then return end
    FORBESAPP:create_contents( FORBESAPP.parent, FORBESAPP.conf, conf )
end
addEvent( "onClientRequestForbesListCallback", true )
addEventHandler( "onClientRequestForbesListCallback", root, onClientRequestForbesListCallback_handler )