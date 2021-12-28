FORMAT3 = {
    create = function( self, offer )
        local fonts_real = ibIsUsingRealFonts( )
        ibUseRealFonts( true )

        UI_elements.black_bg = ibCreateBackground( nil, nil, true, true )
        UI_elements.bg = ibCreateImage( 0, 0, 0, 0, script_folder .. "img/bg.png", UI_elements.black_bg )
        :ibSetRealSize( ):center( ):ibBatchData( { alpha = 0 } ):ibAlphaTo( 255, 500 )

        UI_elements.button_close = ibCreateButton(	UI_elements.bg:ibData( "sx" ) - 54, 28, 24, 24, UI_elements.bg,
    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowUI( false )
        end )

        -- timer
        local label_elements = {
            { 586, 134 },
            { 613, 134 },
            { 660, 134 },
            { 687, 134 },
            { 732, 134 },
            { 760, 134 },
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

        -- offer
        local render_target = ibCreateRenderTarget( 287, 259, 450, 400, UI_elements.bg )

        local pack = WEB_PACKS.format_3.packs[ 1 ]
        local key = pack.id .. offer.start .. offer.finish
        local counter = pack.limit - ( LIMITED_PACKS_SOLD_COUNTER[ key ] or 0 )
        counter = counter < 0 and 0 or counter
        local percent = math.round( 100 - ( pack.price / pack.hard * 100 ) )
        local text = percent == 50 and "X2" or percent .. "%"

        ibCreateLabel( 450, 54, 0, 0, text, render_target, nil, nil, nil, "center", "center", ibFonts.oxaniumextrabold_28 )
        :ibData( "rotation_center_x", 450 )
        :ibData( "rotation", 45 )

        ibCreateLabel( 346, 55, 0, 0, counter, render_target, nil, nil, nil, "right", "center", ibFonts.oxaniumbold_16 )
        :ibData( "outline", true )
        ibCreateImage( 75, 69, math.floor( counter / pack.limit * 300 ), 14, nil, render_target, 0xffff965d )

        local lbl_hard = ibCreateLabel( 0, 282, 0, 0, format_price( pack.hard ), render_target, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_33 )
        :center_x( - 20 ):ibBatchData( { priority = -1, outline = true } )

        ibCreateImage( 0, 282 - 16, 36, 36, ":nrp_shared/img/hard_money_icon.png", render_target )
        :center_x( lbl_hard:width( ) / 2 + 8 ):ibData( "priority", -1 )

        UI_elements.price_area = ibCreateArea( 2, 318, 446, 80, render_target ):ibData( "priority", -1 )
        if counter > 0 then
            local btn_hover = function ( )
                UI_elements.btn_buy:ibMoveTo( nil, 318, 100 )
                UI_elements.price_area:ibAlphaTo( 0, 150 )
            end

            local btn_leave = function ( )
                UI_elements.btn_buy:ibMoveTo( nil, 318 + 84, 100 )
                UI_elements.price_area:ibAlphaTo( 255, 350 )
            end

            UI_elements.price_area:ibOnHover( btn_hover )
            UI_elements.price_area:ibOnLeave( btn_leave )

            local lbl_cost = ibCreateLabel( 0, 32, 0, 0, "Новая стоимость:", UI_elements.price_area, nil, nil, nil, "center", "center", ibFonts.regular_18 )
            local lbl_price = ibCreateLabel( 0, 30, 0, 0, format_price( pack.price ), UI_elements.price_area, nil, nil, nil, "left", "center", ibFonts.oxaniumbold_22 )
            local lbl_rub = ibCreateLabel( 0, 32, 0, 0, "руб.", UI_elements.price_area, nil, nil, nil, "left", "center", ibFonts.regular_18 )

            lbl_cost:center_x( - 2 - lbl_price:width( ) / 2 - lbl_rub:width( ) / 2 )
            lbl_price:ibData( "px", lbl_cost:ibData( "px" ) + lbl_cost:width( ) / 2 + 5 )
            lbl_rub:ibData( "px", lbl_price:ibData( "px" ) + lbl_price:width( ) + 5 )

            local c = ibApplyAlpha( 0xffffffff, 35 )
            local lbl_cost2 = ibCreateLabel( 0, 56, 0, 0, "Старая стоимость:", UI_elements.price_area, c, nil, nil, "center", "center", ibFonts.regular_16 )
            local lbl_price2 = ibCreateLabel( 0, 54, 0, 0, format_price( pack.hard ), UI_elements.price_area, c, nil, nil, "left", "center", ibFonts.oxaniumbold_18 )
            local lbl_rub2 = ibCreateLabel( 0, 56, 0, 0, "руб.", UI_elements.price_area, c, nil, nil, "left", "center", ibFonts.regular_16 )

            lbl_cost2:center_x( - 2 - lbl_price2:width( ) / 2 - lbl_rub2:width( ) / 2 )
            lbl_price2:ibData( "px", lbl_cost2:ibData( "px" ) + lbl_cost2:width( ) / 2 + 5 )
            lbl_rub2:ibData( "px", lbl_price2:ibData( "px" ) + lbl_price2:width( ) + 5 )

            ibCreateImage( lbl_price2:ibData( "px" ) - 2, 54, lbl_price2:width( ) + lbl_rub2:width( ) + 4, 1, nil, UI_elements.price_area, 0xffffffff )

            UI_elements.btn_buy = ibCreateButton( 2, 318 + 84, 446, 80, render_target, script_folder .. "img/btn_buy", true )
            :ibOnHover( btn_hover )
            :ibOnLeave( btn_leave )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end

                ShowUI( false )
                SelectPack( pack.id )
            end )
        else
            ibCreateLabel( 0, 0, 0, 0, "ТОВАР РАСПРОДАН", UI_elements.price_area, ibApplyAlpha( 0xffffffff, 40 ), nil, nil, "center", "center", ibFonts.bold_30 )
            :center( )
        end

        ibUseRealFonts( fonts_real )
    end,
}