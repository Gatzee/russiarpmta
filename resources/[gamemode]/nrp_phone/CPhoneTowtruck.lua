TOWTRUCKER_HINT_SEARCH = nil

TOWTRUCK_APP = nil

APPLICATIONS.towtruck = {
    id = "towtruck",
    icon = "img/apps/towtruck.png",
    name = "Эвакуация транспорта",
    elements = { },
    create = function( self, parent, conf )
        TOWTRUCK_APP = self
        if TOWTRUCKER_HINT_EVACUATE then TOWTRUCKER_HINT_EVACUATE = nil end
        
        triggerServerEvent( "onTowtruckListRequest", localPlayer )

        self.parent = parent
        self.conf = conf

        self.elements.header_texture = dxCreateTexture( "img/elements/towtruck_header.png" )
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
    create_secondary = function( self, parent, conf, list, free_evacuations )
        local icon_size = 26
        local money_icon_size = 18

        self.elements.icon_texture               = dxCreateTexture( "img/elements/steering_wheel.png" )
        self.elements.search_texture             = dxCreateTexture( "img/elements/search.png" )
        self.elements.money_icon_texture         = dxCreateTexture( "img/elements/soft.png" )
        self.elements.button_texture             = dxCreateTexture( "img/elements/btn_tow.png" )
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

        for i, v in pairs( list ) do
            local icon_py = 20 + ( 70 + icon_size ) * ( i - 1 )

            local can_be_searched = v[ 5 ] and not v[ 6 ]
            local action_button = ibCreateButton( icon_px, icon_py, icon_size, icon_size, self.elements.rt,
                can_be_searched and self.elements.search_texture or self.elements.icon_texture, can_be_searched and self.elements.search_texture or self.elements.icon_texture, can_be_searched and self.elements.search_texture or self.elements.icon_texture,
                            0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( ) 
                if not can_be_searched then return end
                ibClick( )
                triggerEvent( "ToggleGPS", localPlayer, v[ 1 ].position )
                ShowPhoneUI( false )
                localPlayer:ShowSuccess( "Местоположение отмечено!" )
                
                if TOWTRUCKER_HINT_SEARCH then
                    TOWTRUCKER_HINT_SEARCH = nil
                    triggerEvent( "onClientHideTowtruckerHintSearch", root )
                end
            end )
            
            if TOWTRUCKER_HINT_SEARCH then
                localPlayer:ShowInfo( 'Отметьте транспорт, чтобы найти его' )

                if isElement( v[ 1 ] ) and v[ 1 ].model == 468 then
                    local func_interpolate = function( self )
                        self:ibInterpolate( function( self )
                            if not isElement( self.element ) then return end
                            self.easing_value = 1 + 0.2 * self.easing_value

                            local alpha = ( self.easing_value ) * 15
                            local size_icon = 15 + alpha
                            self.element:ibBatchData( {
                                px = icon_px + 5 - alpha / 2,
                                py = icon_py - alpha / 2,
                                sx = size_icon,
                                sy = size_icon,
                            } )
                        end, 500, "SineCurve" )
                    end

                    action_button:ibTimer( func_interpolate, 1000, 0 )
                    func_interpolate( action_button )
                end
            end
            
            local text_px = icon_px + icon_size + 7
            local text_py = icon_py
            local upper_text = v[ 2 ] .. " (" .. v[ 3 ] .. ")"
            ibCreateLabel( text_px, text_py, conf.sx - text_px, 0, upper_text, self.elements.rt, 0xFFFFFFFF, _, _, _, _, ibFonts.semibold_9 )

            local text_px = icon_px + icon_size + 7
            local text_py = text_py + 13
            local bottom_text = v[ 4 ] and v[ 5 ] and not v[ 6 ] and "Расстояние: " .. v[ 4 ] or v[ 5 ] and v[ 6 ] and "На парковке" or v[ 7 ] and "На штрафстоянке" or "Нельзя эвакуировать"
            
            ibCreateLabel( text_px, text_py, conf.sx - text_px, 0, bottom_text, self.elements.rt, 0xFFFFFFFF - 0x55000000, _, _, _, _, ibFonts.light_8 )

            local button_py = icon_py + 35
            local button_texture = v[ 3 ] and self.elements.button_texture or self.elements.button_unavailable_texture
            ibCreateButton( button_px, button_py, button_sx, button_sy, self.elements.rt, 
                            button_texture, button_texture, button_texture, 
                            v[ 5 ] and 0xffeeeeee or 0xffffffff, 0xffffffff, 0xffffffff )
            :ibOnClick( function( ) 
                if not v[ 5 ] then return end
                ibClick( )

                if TOWTRUCKER_HINT_SEARCH then
                    localPlayer:ShowInfo( 'Нажмите на значок "лупы", чтобы отметить транспорт' )
                    return
                end

                if confirmation then confirmation:destroy( ) end
                
                confirmation = ibConfirm( {
                    title = "Эвакуация",
                    black_bg = 0xcc000000,
                    text = "Вы действительно хотите оплатить эвакуацию\n" .. v[ 2 ] .." стоимостью " .. v[ 5 ] .. "?",
                    fn = function( self )
                        self:destroy()

                        local _, _, rotation = getElementRotation( localPlayer )
                        rotation = rotation - 90

                        local distance = 5
                        local offx, offy = -math.cos( math.rad( rotation ) ) * distance, -math.sin( math.rad( rotation ) ) * distance
                        local expected_position = localPlayer.position + Vector3( offx, offy, 0.8 )

                        if not isLineOfSightClear( localPlayer.position, expected_position ) then
                            localPlayer:ShowError("Что-то мешает эвакуации!")
                            return false
                        end

                        triggerServerEvent( "onTowtruckRequest", localPlayer, v[ 1 ] )
                    end,
                    escape_close = true,
                } )
            end )

            if v[ 5 ] then
                local money_icon_py = icon_py + 35 + button_sy / 2 - money_icon_size / 2
                ibCreateImage( money_icon_px, money_icon_py, money_icon_size, money_icon_size, self.elements.money_icon_texture, self.elements.rt )
                
                local money_text_py = money_icon_py + 1
                ibCreateLabel( money_icon_px + money_icon_size + 7, money_text_py, 0, 0, v[ 5 ] .. " р.", self.elements.rt, 0xFFFFFFFF, _, _, _, _, ibFonts.semibold_9 )
            end
            
            ibCreateImage( line_px, icon_py + 80, line_sx, line_sy, self.elements.line_horizontal_texture, self.elements.rt )
        end

        self.elements.rt:AdaptHeightToContents( )
        self.elements.sc:UpdateScrollbarVisibility( self.elements.rt )
    end,

    destroy = function( self, parent, conf )
        if confirmation then confirmation:destroy() end
        DestroyTableElements( self.elements )
        TOWTRUCK_APP = nil
    end,
}

function onTowtruckListRequestCallback_handler( list, free_evacuations )
    if not TOWTRUCK_APP then return end -- закрыл раньше, чем пришел ответ

    for i, v in pairs( list ) do
        if free_evacuations[ 0 ] or free_evacuations[ v[ 1 ]:GetID( ) ] then
            v[ 5 ] = 0
        end
    end
    TOWTRUCK_APP:create_secondary( TOWTRUCK_APP.parent, TOWTRUCK_APP.conf, list )
end
addEvent( "onTowtruckListRequestCallback", true )
addEventHandler( "onTowtruckListRequestCallback", root, onTowtruckListRequestCallback_handler )

function EnablePhoneTowtruckerHintSearch( state )
    TOWTRUCKER_HINT_SEARCH = state
end
addEvent( "EnablePhoneTowtruckerHintSearch", true )
addEventHandler( "EnablePhoneTowtruckerHintSearch", root, EnablePhoneTowtruckerHintSearch )

function EnablePhoneTowtruckerHintEvacuate( state )
    TOWTRUCKER_HINT_EVACUATE = state
end
addEvent( "EnablePhoneTowtruckerHintEvacuate", true )
addEventHandler( "EnablePhoneTowtruckerHintEvacuate", root, EnablePhoneTowtruckerHintEvacuate )