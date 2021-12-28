SVEHICLES_APP = nil

APPLICATIONS.svehicles = {
    id = "svehicles",
    icon = "img/apps/svehicles.png",
    name = "Заказ спецтранспорта",
    elements = { },
    create = function( self, parent, conf )
        SVEHICLES_APP = self
        triggerServerEvent( "onSVehiclesListRequest", localPlayer )

        self.parent = parent
        self.conf = conf

        self.elements.header_texture = dxCreateTexture( "img/elements/svehicles_header.png" )
        local hsx, hsy = dxGetMaterialSize( self.elements.header_texture )

        local size_y = hsy * conf.sx / hsx
        self.elements.header = ibCreateImage( 0, 0, hsx, size_y, self.elements.header_texture, parent, 0xFFFFFFFF )

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

        self.header_y = size_y

        return self
    end,
    create_secondary = function( self, parent, conf, list )
        local icon_size = 26
        local money_icon_size = 18

        self.elements.airplane_texture           = dxCreateTexture( "img/elements/icon_plane.png" )
        self.elements.boat_texture               = dxCreateTexture( "img/elements/icon_boat.png" )
        self.elements.search_texture             = dxCreateTexture( "img/elements/search.png" )
        self.elements.money_icon_texture         = dxCreateTexture( "img/elements/soft.png" )
        self.elements.button_texture             = dxCreateTexture( "img/elements/btn_order.png" )
        self.elements.button_unavailable_texture = dxCreateTexture( "img/elements/btn_tow_unavailable.png" )
        self.elements.line_horizontal_texture    = dxCreateTexture( "img/elements/line_horizontal.png" )
        
        local button_sx, button_sy = dxGetMaterialSize( self.elements.button_texture )
        local line_sx, line_sy = dxGetMaterialSize( self.elements.line_horizontal_texture )

        local icon_px = 7

        local button_px = icon_px
        local money_icon_px = button_px + button_sx + 7
        local line_px = conf.sx / 2 - line_sx / 2

        table.sort( list, function( a, b )
            local comp_a = a[ 4 ] and a[ 5 ] and not a[ 6 ] and 2 or a[ 5 ] and a[ 6 ] and 1 or 0
            local comp_b = b[ 4 ] and b[ 5 ] and not b[ 6 ] and 2 or b[ 5 ] and b[ 6 ] and 1 or 0
            return comp_a > comp_b
        end )

        if #list == 0 then
            ibCreateLabel( conf.sx / 2, conf.sy / 2 - 35, 0, 0, "У тебя нет спецтранспорта", self.elements.rt, 0xFFFFFFFF - 0x55000000, _, _, "center", "center", ibFonts.regular_10 )
        end

        for i, v in pairs( list ) do
            local icon_py = 20 + ( 70 + icon_size ) * ( i - 1 )
            local can_be_searched = isElement(v[1])
            local sClass = IsSpecialVehicle( v[3] )
            local icon_texture = can_be_searched and self.elements.search_texture or ( sClass == "boat" and self.elements.boat_texture or self.elements.airplane_texture )
            local select_color = can_be_searched and 0x55FFFFFF or 0xFFFFFFFF

            ibCreateButton( icon_px, icon_py, icon_size, icon_size, self.elements.rt, icon_texture, nil, nil,0xFFFFFFFF, select_color, select_color )
            :ibOnClick( function( ) 
                if not can_be_searched then return end
                triggerEvent( "ToggleGPS", localPlayer, v[ 1 ].position )
                ShowPhoneUI( false )
                localPlayer:ShowSuccess( "Местоположение отмечено!" )
            end )

            local text_px = icon_px + icon_size + 7
            local text_py = icon_py
            local upper_text = v[ 2 ]
            ibCreateLabel( text_px, text_py, conf.sx - text_px, 0, upper_text, self.elements.rt, 0xFFFFFFFF, _, _, _, _, ibFonts.semibold_9 )
            
            --ibCreateLabel( text_px, text_py, conf.sx - text_px, 0, bottom_text, self.elements.rt, 0xffaaaaaa, _, _, _, _, ibFonts.light_8 )

            local button_py = icon_py + 35
            local button_texture = v[ 3 ] and self.elements.button_texture or self.elements.button_unavailable_texture
            ibCreateButton( button_px, button_py, button_sx, button_sy, self.elements.rt, 
                            button_texture, button_texture, button_texture, 
                            v[ 5 ] and 0xffeeeeee or 0xffffffff, 0xffffffff, 0xffffffff )
            :ibOnClick( function( ) 
                if not v[ 5 ] then return end
                if confirmation then confirmation:destroy() end
                
                local sClassStrings = 
                {
                    ["airplane"] = "свой самолёт в ближайший аэропорт",
                    ["helicopter"] = "свой вертолёт в ближайший аэропорт",
                    ["boat"] = "свою лодку на ближайшую пристань",
                }

                confirmation = ibConfirm(
                    {
                        title = "Вызов транспорта",
                        black_bg = 0xcc000000,
                        text = "Вы хотите доставить\n"..sClassStrings[sClass].." за "..v[ 5 ].." рублей?",
                        fn = function( self ) 
                            self:destroy()
                            triggerServerEvent( "onSVehicleRequest", localPlayer, v[ 6 ] )
                        end,
                        escape_close = true,
                    }
                )
            end )

            if v[ 5 ] then
                local money_icon_py = icon_py + 35 + button_sy / 2 - money_icon_size / 2
                ibCreateImage( money_icon_px, money_icon_py, money_icon_size, money_icon_size, self.elements.money_icon_texture, self.elements.rt )
                
                local money_text_py = money_icon_py + 1
                ibCreateLabel( money_icon_px + money_icon_size + 7, money_text_py, 0, 0, v[ 5 ] .. " р.", self.elements.rt, 0xFFFFFFFF, _, _, _, _, ibFonts.semibold_9 )
            end
            
            ibCreateImage( line_px, icon_py + 80, line_sx, line_sy, self.elements.line_horizontal_texture, self.elements.rt, 0xFFFFFFFF )
        end

        self.elements.rt:AdaptHeightToContents( )
        self.elements.sc:UpdateScrollbarVisibility( self.elements.rt )
    end,

    destroy = function( self, parent, conf )
        if confirmation then confirmation:destroy() end
        DestroyTableElements( self.elements )
        SVEHICLES_APP = nil
    end,
}

function onSVehiclesListRequestCallback_handler( list )
    if not SVEHICLES_APP then return end -- закрыл раньше, чем пришел ответ
    SVEHICLES_APP:create_secondary( SVEHICLES_APP.parent, SVEHICLES_APP.conf, list )
end
addEvent( "onSVehiclesListRequestCallback", true )
addEventHandler( "onSVehiclesListRequestCallback", root, onSVehiclesListRequestCallback_handler )