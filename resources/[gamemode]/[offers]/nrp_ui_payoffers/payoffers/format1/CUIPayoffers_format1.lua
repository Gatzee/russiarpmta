FORMAT1 = {
    create = function( self, offer )
        local fonts_real = ibIsUsingRealFonts( )
        ibUseRealFonts( true )

        UI_elements.black_bg = ibCreateBackground( nil, nil, true )
        UI_elements.bg = ibCreateImage( 0, 0, 0, 0, script_folder .. "img/bg.png", UI_elements.black_bg )
        :ibSetRealSize( ):center( ):ibBatchData( { alpha = 0 } ):ibAlphaTo( 255, 500 )

        UI_elements.button_close = ibCreateButton(	UI_elements.bg:ibData( "sx" ) - 54, 24, 24, 24, UI_elements.bg,
    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowUI( false )
        end )

        local label_elements = {
            { 586, 125 },
            { 613, 125 },
            { 660, 125 },
            { 687, 125 },
            { 732, 125 },
            { 760, 125 },
        }

        for i, v in pairs( label_elements ) do
            UI_elements[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "0", UI_elements.bg )
            :ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
        end

        local function UpdateTimer( )
            local time_diff = offer.finish - getRealTimestamp( )

            if time_diff < 0 then ShowUI( false ) return end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
            local seconds = math.floor( ( ( time_diff - hours * 60 * 60 ) - minutes * 60 ) )

            if hours > 99 then minutes = 60; seconds = 0 end

            hours = string.format( "%02d", math.min( hours, 99 ) )
            minutes = string.format( "%02d", math.min( minutes, 60 ) )
            seconds = string.format( "%02d", seconds )

            local str = hours .. minutes .. seconds

            for i = 1, #label_elements do
                local element = UI_elements[ "tick_num_" .. i ]
                if isElement( element ) then
                    element:ibData( "text", utf8.sub( str, i, i ) )
                end
            end
        end

        UI_elements.timer_timer = Timer( UpdateTimer, 500, 0 )
        UpdateTimer( )

        local areas = {
            { "small", 30, 171 },
            { "small", 276, 171 },
            { "small", 522, 171 },
            { "small", 768, 171 },
            { "big", 30, 417, "Выбор игроков!" },
            { "big", 522, 417, "Лучшее предложение!" },
        }

        for i, pack in ipairs( WEB_PACKS.format_1.packs ) do
            local pack_id = pack.id
            local v = areas[ i ]
            local is_small = v[ 1 ] == "small"

            -- positions
            local area_sx = is_small and 226 or 472
            local area_sy = is_small and 226 or 273
            local b_py = is_small and 156 or 202
            local b_sx = is_small and 222 or 468
            local b_sy = is_small and 68 or 69
            local hard_py = is_small and 133 or 179

            --- content
            local name = is_small and "Стоимость" or "Новая стоимость"
            local old_name = is_small and "Без скидки" or "Старая стоимость"
            local hard = pack.hard or 0
            local price = pack.price or 0
            local percent = math.round( 100 - ( price / hard * 100 ) )
            local title = not v[ 4 ] and "ВЫГОДА " .. percent .. "%" or v[ 4 ]

            local btn_hover = function ( )
                UI_elements[ "pack_btn_".. pack_id ]:ibMoveTo( b_px, b_py, 100 )
                UI_elements[ "price_area_".. pack_id ]:ibAlphaTo( 0, 150 )

                if is_small then
                    UI_elements[ "pack_shadow_".. pack_id ] = ibCreateImage( v[ 2 ] - 37, v[ 3 ] - 37, 300, 300, script_folder .. "img/shadow_small.png", UI_elements.bg )
                else
                    UI_elements[ "pack_shadow_".. pack_id ] = ibCreateImage( v[ 2 ] - 20, v[ 3 ] - 20, 512, 313, script_folder .. "img/shadow_big.png", UI_elements.bg )
                end
                UI_elements[ "pack_shadow_".. pack_id ]:ibData( "priority", -1 )
            end

            local btn_leave = function ( )
                UI_elements[ "pack_btn_".. pack_id ]:ibMoveTo( b_px, b_py + b_sy + 2, 100 )
                UI_elements[ "price_area_".. pack_id ]:ibAlphaTo( 255, 350 )

                if isElement( UI_elements[ "pack_shadow_".. pack_id ] ) then
                    UI_elements[ "pack_shadow_".. pack_id ]:destroy( )
                end
            end

            local render_target = ibCreateRenderTarget( v[ 2 ], v[ 3 ], area_sx, area_sy, UI_elements.bg )
            UI_elements[ "pack_area_".. pack_id ] = ibCreateArea( 0, 0, area_sx, area_sy, render_target )
            :ibOnHover( btn_hover )
            :ibOnLeave( btn_leave )

            UI_elements[ "pack_btn_".. pack_id ] = ibCreateButton( 2, b_py + b_sy + 2, b_sx, b_sy, UI_elements[ "pack_area_".. pack_id ], script_folder .. "img/btn_buy_" .. v[ 1 ], true )
            :ibOnHover( btn_hover )
            :ibOnLeave( btn_leave )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end

                ShowUI( false )
                SelectPack( pack_id )
            end )

            ibCreateLabel( 0, 14, 0, 0, title, render_target, nil, nil, nil, "center", "center", ibFonts.bold_14 )
            :center_x( )

            if not is_small then
                local text = percent == 50 and "X2" or percent .. "%"
                ibCreateLabel( 470, 52, 0, 0, text, render_target, nil, nil, nil, "center", "center", ibFonts.oxaniumextrabold_28 )
                :ibData( "rotation_center_x", 470 )
                :ibData( "rotation", 45 )
            end

            local lbl_hard = ibCreateLabel( 0, hard_py, 0, 0, format_price( hard ), render_target, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_24 )
            :center_x( - 14 ):ibData( "priority", -1 )

            ibCreateImage( 0, hard_py - 12, 28, 28, ":nrp_shared/img/hard_money_icon.png", render_target )
            :center_x( lbl_hard:width( ) / 2 + 7 ):ibData( "priority", -1 )

            UI_elements[ "price_area_".. pack_id ] = ibCreateArea( 2, b_py, b_sx - 4, b_sy, render_target ):ibData( "priority", -1 )
            local lbl_cost = ibCreateLabel( 0, 27, 0, 0, name .. ":", UI_elements[ "price_area_".. pack_id ], nil, nil, nil, "center", "center", ibFonts.regular_16 )
            local lbl_price = ibCreateLabel( 0, 26 - 1, 0, 0, format_price( price ), UI_elements[ "price_area_".. pack_id ], nil, nil, nil, "left", "center", ibFonts.oxaniumbold_20 )
            local lbl_rub = ibCreateLabel( 0, 27, 0, 0, "руб.", UI_elements[ "price_area_".. pack_id ], nil, nil, nil, "left", "center", ibFonts.regular_16 )

            lbl_cost:center_x( - 2 - lbl_price:width( ) / 2 - lbl_rub:width( ) / 2 )
            lbl_price:ibData( "px", lbl_cost:ibData( "px" ) + lbl_cost:width( ) / 2 + 5 )
            lbl_rub:ibData( "px", lbl_price:ibData( "px" ) + lbl_price:width( ) + 5 )

            local c = ibApplyAlpha( 0xffffffff, 35 )
            local lbl_cost2 = ibCreateLabel( 0, 50, 0, 0, old_name .. ":", UI_elements[ "price_area_".. pack_id ], c, nil, nil, "center", "center", ibFonts.regular_14 )
            local lbl_price2 = ibCreateLabel( 0, 49, 0, 0, format_price( hard ), UI_elements[ "price_area_".. pack_id ], c, nil, nil, "left", "center", ibFonts.oxaniumbold_16 )
            local lbl_rub2 = ibCreateLabel( 0, 50, 0, 0, "руб.", UI_elements[ "price_area_".. pack_id ], c, nil, nil, "left", "center", ibFonts.regular_14 )

            lbl_cost2:center_x( - 2 - lbl_price2:width( ) / 2 - lbl_rub2:width( ) / 2 )
            lbl_price2:ibData( "px", lbl_cost2:ibData( "px" ) + lbl_cost2:width( ) / 2 + 5 )
            lbl_rub2:ibData( "px", lbl_price2:ibData( "px" ) + lbl_price2:width( ) + 5 )

            ibCreateImage( lbl_price2:ibData( "px" ) - 2, 50, lbl_price2:width( ) + lbl_rub2:width( ) + 4, 1, nil, UI_elements[ "price_area_".. pack_id ], 0xffffffff )

            i = i + 1
        end
        
        ibUseRealFonts( fonts_real )
    end,
}