FORMAT2 = {
    create = function( self, offer )
        local fonts_real = ibIsUsingRealFonts( )
        ibUseRealFonts( true )

        local current_state = localPlayer:getData( "format2_unlocked" )
        local is_locked = not current_state
        local bg_img_path = is_locked and script_folder .. "img/bg_locked.png" or script_folder .. "img/bg_unlocked.png"

        UI_elements.black_bg = ibCreateBackground( nil, nil, true )
        UI_elements.bg = ibCreateImage( 0, 0, 0, 0, bg_img_path, UI_elements.black_bg )
        :ibSetRealSize( ):center( ):ibBatchData( { alpha = 0 } ):ibAlphaTo( 255, 500 )
        :ibTimer( function ( )
            if current_state ~= localPlayer:getData( "format2_unlocked" ) then
                ShowUI( true ) -- reload page of offer
            end
        end, 500, 0 )

        UI_elements.button_close = ibCreateButton(	UI_elements.bg:ibData( "sx" ) - 54, 34, 24, 24, UI_elements.bg,
    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowUI( false )
        end )

        local lbl_timer = ibCreateLabel( 936, 47, 0, 0, "00 ч. 00 мин.", UI_elements.bg, nil, nil, nil, "right", "center", ibFonts.bold_16 )
        local lbl_end = ibCreateLabel( 0, 47, 0, 0, "До конца акции:", UI_elements.bg, ibApplyAlpha( 0xffffffff, 75 ), nil, nil, "right", "center", ibFonts.regular_16 )
        local icon_timer = ibCreateImage( 0, 34, 22, 24, script_folder .. "img/icon_timer.png", UI_elements.bg )

        local function UpdateTimer( )
            local time_diff = offer.finish - getRealTimestamp( )

            if time_diff < 0 then ShowUI( false ) return end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )

            if hours > 99 then minutes = 60 end

            minutes = string.format( "%02d", math.min( minutes, 60 ) )

            local str = hours .. " ч. " .. minutes .. " мин."

            lbl_timer:ibData( "text", str )
            lbl_end:ibData( "px", 936 - lbl_timer:width( ) - 5 )
            icon_timer:ibData( "px", 936 - lbl_end:width( ) - lbl_timer:width( ) - 36 )
        end

        UI_elements.timer_timer = Timer( UpdateTimer, 500, 0 )
        UpdateTimer( )

        local areas = {
            { "small", 30, 450, 300, 240 },
            { "small_2", 350, 450, 324, 240 },
            { "small", 694, 450, 300, 240 },
            { "big", 30, 122, is_locked and 483 or 472, 257, "Выбор игроков!", is_locked and 106 or 0, key = true },
            { "big", is_locked and 511 or 522, 122, is_locked and 483 or 472, 257, "Лучшее предложение!", locked = true },
        }

        for i, pack in ipairs( WEB_PACKS.format_2.packs ) do
            local v = areas[ i ]
            local pack_id = pack.id
            local is_small = v[ 1 ] == "small" or v[ 1 ] == "small_2"

            -- positions
            local hard_py = is_small and 145 or 163

            --- content
            local name = is_small and "Стоимость" or "Новая стоимость"
            local old_name = is_small and "Без скидки" or "Старая стоимость"
            local hard = pack.hard or 0
            local price = pack.price or 0
            local percent = math.round( 100 - ( price / hard * 100 ) )
            local title = ( not v[ 6 ] or is_locked ) and "ВЫГОДА " .. percent .. "%" or v[ 6 ]

            local btn_hover = function ( )
                UI_elements[ "pack_btn_".. pack_id ]:ibMoveTo( nil, v[ 5 ] - 70, 100 )
                UI_elements[ "price_area_".. pack_id ]:ibAlphaTo( 0, 150 )

                if is_small then
                    UI_elements[ "pack_shadow_".. pack_id ] = ibCreateImage( v[ 2 ] - 19, v[ 3 ] - 19, v[ 4 ] + 39, v[ 5 ] + 39, script_folder .. "img/shadow_small.png", UI_elements.bg )
                else
                    local shadow_img_path = is_locked and script_folder .. "img/shadow_big_locked.png" or script_folder .. "img/shadow_big.png"
                    UI_elements[ "pack_shadow_".. pack_id ] = ibCreateImage( v[ 2 ] - 24, v[ 3 ] - 22, v[ 4 ] + 51, v[ 5 ] + 49, shadow_img_path, UI_elements.bg )
                end
                UI_elements[ "pack_shadow_".. pack_id ]:ibData( "priority", -1 )
            end

            local btn_leave = function ( )
                UI_elements[ "pack_btn_".. pack_id ]:ibMoveTo( nil, v[ 5 ], 100 )
                UI_elements[ "price_area_".. pack_id ]:ibAlphaTo( 255, 350 )

                if isElement( UI_elements[ "pack_shadow_".. pack_id ] ) then
                    UI_elements[ "pack_shadow_".. pack_id ]:destroy( )
                end
            end

            local render_target = ibCreateRenderTarget( v[ 2 ], v[ 3 ], v[ 4 ], v[ 5 ], UI_elements.bg )
            UI_elements[ "pack_area_".. pack_id ] = ibCreateArea( 0, 0, v[ 4 ], v[ 5 ], render_target )
            :ibOnHover( btn_hover )
            :ibOnLeave( btn_leave )

            UI_elements[ "pack_btn_".. pack_id ] = ibCreateButton( 2, v[ 5 ], v[ 4 ] - 4, 68, UI_elements[ "pack_area_".. pack_id ], script_folder .. "img/btn_buy_" .. v[ 1 ], true )
            :ibOnHover( btn_hover )
            :ibOnLeave( btn_leave )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end

                ShowUI( false )
                SelectPack( pack_id )
            end )

            ibCreateLabel( 0, 14, 0, 0, title, render_target, nil, nil, nil, "center", "center", ibFonts.bold_14 )
            :center_x( )

            if not is_small and not is_locked then
                local text = percent == 50 and "X2" or percent .. "%"
                ibCreateLabel( 470, 52, 0, 0, text, render_target, nil, nil, nil, "center", "center", ibFonts.oxaniumextrabold_28 )
                :ibData( "rotation_center_x", 470 )
                :ibData( "rotation", 45 )
            end

            local lbl_hard = ibCreateLabel( 0, hard_py, 0, 0, format_price( hard ), render_target, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_24 )
            :center_x( - 14 - ( v[ 7 ] or 0 ) ):ibData( "priority", -1 )

            ibCreateImage( 0, hard_py - 14, 28, 28, ":nrp_shared/img/hard_money_icon.png", render_target )
            :center_x( lbl_hard:width( ) / 2 + 7 - ( v[ 7 ] or 0 ) ):ibData( "priority", -1 )

            UI_elements[ "price_area_".. pack_id ] = ibCreateArea( 2, v[ 5 ] - 70, v[ 4 ], 68, render_target ):ibData( "priority", -1 )
            local lbl_cost = ibCreateLabel( 0, 27, 0, 0, name .. ":", UI_elements[ "price_area_".. pack_id ], nil, nil, nil, "center", "center", ibFonts.regular_16 )
            local lbl_price = ibCreateLabel( 0, 26 - 1, 0, 0, format_price( price ), UI_elements[ "price_area_".. pack_id ], nil, nil, nil, "left", "center", ibFonts.oxaniumbold_20 )
            local lbl_rub = ibCreateLabel( 0, 27, 0, 0, "руб.", UI_elements[ "price_area_".. pack_id ], nil, nil, nil, "left", "center", ibFonts.regular_16 )

            lbl_cost:center_x( - 2 - lbl_price:width( ) / 2 - lbl_rub:width( ) / 2 )
            lbl_price:ibData( "px", lbl_cost:ibData( "px" ) + lbl_cost:width( ) / 2 + 5 )
            lbl_rub:ibData( "px", lbl_price:ibData( "px" ) + lbl_price:width( ) + 5 )

            local c = ibApplyAlpha( 0xffffffff, 35 )
            local lbl_cost2 = ibCreateLabel( 0, 50, 0, 0, old_name .. ":", UI_elements[ "price_area_".. pack_id ], c, nil, nil, "center", "center", ibFonts.regular_14 )
            local lbl_price2 = ibCreateLabel( 0, 48, 0, 0, format_price( hard ), UI_elements[ "price_area_".. pack_id ], c, nil, nil, "left", "center", ibFonts.oxaniumbold_16 )
            local lbl_rub2 = ibCreateLabel( 0, 50, 0, 0, "руб.", UI_elements[ "price_area_".. pack_id ], c, nil, nil, "left", "center", ibFonts.regular_14 )

            lbl_cost2:center_x( - 2 - lbl_price2:width( ) / 2 - lbl_rub2:width( ) / 2 )
            lbl_price2:ibData( "px", lbl_cost2:ibData( "px" ) + lbl_cost2:width( ) / 2 + 5 )
            lbl_rub2:ibData( "px", lbl_price2:ibData( "px" ) + lbl_price2:width( ) + 5 )

            ibCreateImage( lbl_price2:ibData( "px" ) - 2, 48, lbl_price2:width( ) + lbl_rub2:width( ) + 4, 1, nil, UI_elements[ "price_area_".. pack_id ], 0xffffffff )

            if is_locked and v.locked then
                render_target:ibData( "alpha", 50 )

                ibCreateImage( v[ 2 ] - 20, v[ 3 ] - 25, v[ 4 ] + 41, v[ 5 ] + 52, script_folder .. "img/locked.png", UI_elements.bg )
                UI_elements.info = ibCreateImage( v[ 2 ] + 2, v[ 3 ] + 2, v[ 4 ] - 4, v[ 5 ] - 4, script_folder .. "img/info.png", UI_elements.bg )
                :ibData( "alpha", 0 )
                :ibOnHover( function ( )
                    UI_elements.info:ibData( "alpha", 255 )
                end )
                :ibOnLeave( function ( )
                    UI_elements.info:ibData( "alpha", 0 )
                end )
            elseif is_locked and v.key then
                ibCreateArea( 300, 40, 100, 140, render_target )
                :ibAttachTooltip( "Ключ от “Лучшего предложения”" )
                :ibOnHover( btn_hover )
                :ibOnLeave( btn_leave )
            end

            i = i + 1
        end
        
        ibUseRealFonts( fonts_real )
    end,
}

addEvent( "onClientBoughtOfferWithKey", true )
addEventHandler( "onClientBoughtOfferWithKey", resourceRoot, function ( )
    ibUseRealFonts( true )

    local p_id = 664
    local pack = WEB_PACKS[ p_id ] or { }
    local hard = pack.hard or 0
    local price = pack.price or 0

    local bg = ibCreateBackground( ibApplyAlpha( 0xff1f2934, 95 ), nil, true )
    :ibTimer( function ( )
        showCursor( true )
    end, 500, 0 )

    local offer_bg = ibCreateImage( 0, 0, 800, 800, "img/offer_unlocked.png", bg ):center( )
    local offer_area = ibCreateRenderTarget( 166, 273, 468, 253, offer_bg )

    local percent = math.round( 100 - ( price / hard * 100 ) )
    local text = percent == 50 and "X2" or percent .. "%"
    ibCreateLabel( 407 * 2, -66, 0, 0, text, offer_bg, nil, nil, nil, "center", "center", ibFonts.oxaniumextrabold_28 )
    :ibData( "rotation_center_x", 407 * 2 )
    :ibData( "rotation", 45 )

    local lbl_hard = ibCreateLabel( 0, 163, 0, 0, format_price( hard ), offer_area, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_24 )
    :center_x( - 14 ):ibData( "priority", -1 )

    ibCreateImage( 0, 163 - 14, 28, 28, ":nrp_shared/img/hard_money_icon.png", offer_area )
    :center_x( lbl_hard:width( ) / 2 + 7 ):ibData( "priority", -1 )

    local price_area = ibCreateArea( 0, 185, 468, 68, offer_area ):ibData( "priority", -1 )

    local lbl_cost = ibCreateLabel( 0, 27, 0, 0, "Новая стоимость:", price_area, nil, nil, nil, "center", "center", ibFonts.regular_16 )
    local lbl_price = ibCreateLabel( 0, 26 - 1, 0, 0, format_price( price ), price_area, nil, nil, nil, "left", "center", ibFonts.oxaniumbold_20 )
    local lbl_rub = ibCreateLabel( 0, 27, 0, 0, "руб.", price_area, nil, nil, nil, "left", "center", ibFonts.regular_16 )

    lbl_cost:center_x( - 2 - lbl_price:width( ) / 2 - lbl_rub:width( ) / 2 )
    lbl_price:ibData( "px", lbl_cost:ibData( "px" ) + lbl_cost:width( ) / 2 + 5 )
    lbl_rub:ibData( "px", lbl_price:ibData( "px" ) + lbl_price:width( ) + 5 )

    local c = ibApplyAlpha( 0xffffffff, 35 )
    local lbl_cost2 = ibCreateLabel( 0, 50, 0, 0, "Старая стоимость:", price_area, c, nil, nil, "center", "center", ibFonts.regular_14 )
    local lbl_price2 = ibCreateLabel( 0, 48, 0, 0, format_price( hard ), price_area, c, nil, nil, "left", "center", ibFonts.oxaniumbold_16 )
    local lbl_rub2 = ibCreateLabel( 0, 50, 0, 0, "руб.", price_area, c, nil, nil, "left", "center", ibFonts.regular_14 )

    lbl_cost2:center_x( - 2 - lbl_price2:width( ) / 2 - lbl_rub2:width( ) / 2 )
    lbl_price2:ibData( "px", lbl_cost2:ibData( "px" ) + lbl_cost2:width( ) / 2 + 5 )
    lbl_rub2:ibData( "px", lbl_price2:ibData( "px" ) + lbl_price2:width( ) + 5 )

    ibCreateImage( lbl_price2:ibData( "px" ) - 2, 48, lbl_price2:width( ) + lbl_rub2:width( ) + 4, 1, nil, price_area, 0xffffffff )

    ibCreateButton( 0, 568, 140, 54, offer_bg, "img/btn_hide", true ):center_x( )
    :ibOnClick( function ( key, state )
        if key ~= "left" or state ~= "up" then return end

        bg:destroy( )
        ibClick( )

        if not next( UI_elements ) and not next( UI_Browser ) then
           showCursor( false )
        end
    end )

    ibUseRealFonts( false )
end )