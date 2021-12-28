function math.round( num,  idp )
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function showLimitedUI( state, params )
    local currentState = UI_limited

    if state and not currentState then
        if localPlayer:GetLevel( ) < 2 then return end

        local percent = math.round( 100 - params.cost / params.cost_original * 100 )

        UI_limited = { }

        UI_limited.black_bg = ibCreateBackground( nil, nil, true )
        UI_limited.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg_limited.png", UI_limited.black_bg )
        :center( ):ibBatchData( { alpha = 0 } ):ibAlphaTo( 255, 500 )

        UI_limited.button_close = ibCreateButton( UI_limited.bg:ibData( "sx" ) - 54, 28, 24, 24, UI_limited.bg,
        ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            showLimitedUI( false )
        end )

        ibCreateLabel( 0, 52, 0, 0, "Скидка #f3595e" .. percent .. "% #ffffffна уникальный транспорт!", UI_limited.bg, nil, nil, nil, "center", "center", ibFonts.bold_16 )
        :center_x( ):ibBatchData( { colored = true, alpha = 210 } )
        ibCreateLabel( 0, 166, UI_limited.bg:ibData( "sx" ), 0, params.name, UI_limited.bg, nil, nil, nil, "center", "center", ibFonts.extrabold_44 )
        ibCreateContentImage( 0, 0, 600, 316, "vehicle", params.model, UI_limited.bg ):center( 0, 30 )

        local render_target = ibCreateRenderTarget( 0, 0, 1024, 720, UI_limited.bg )
        ibCreateLabel( 100, 264, 0, 0, percent .. "%", render_target, nil, nil, nil, "center", "center", ibFonts.extrabold_44 )
        :ibData( "rotation_center_x", 100 )
        :ibData( "rotation", -15 )

        ibCreateLabel( 1012, 313, 0, 0, percent .. "%", render_target, nil, nil, nil, "left", "center", ibFonts.extrabold_34 )
        :ibData( "rotation_center_x", 1012 )
        :ibData( "rotation", 30 )

        local c = ibApplyAlpha( 0xffffffff, 50 )
        local lbl_o_price = ibCreateLabel( 0, 580, 0, 0, "Цена без скидки:", UI_limited.bg, c, nil, nil, "center", "center", ibFonts.regular_18 )
        local img_o_hard = ibCreateImage( 0, 570, 24, 24, ":nrp_shared/img/hard_money_icon.png", UI_limited.bg )
        local lbl_o_price_v = ibCreateLabel( 0, 580, 0, 0, format_price( params.cost_original ), UI_limited.bg, c, nil, nil, "center", "center", ibFonts.bold_20 )

        lbl_o_price:center_x( - 2 - lbl_o_price_v:width( ) / 2 - img_o_hard:width( ) / 2 )
        img_o_hard:ibData( "px", lbl_o_price:ibData( "px" ) + lbl_o_price:width( ) / 2 + 10 )
        lbl_o_price_v:ibData( "px", img_o_hard:ibData( "px" ) + lbl_o_price_v:width( ) / 2 + img_o_hard:width( ) + 8 )

        ibCreateImage( img_o_hard:ibData( "px" ) - 5, 580, img_o_hard:width( ) + lbl_o_price_v:width( ) + 16, 1, nil, UI_limited.bg, 0xffffffff )

        local lbl_price = ibCreateLabel( 0, 612, 0, 0, "Уникальная цена:", UI_limited.bg, nil, nil, nil, "center", "center", ibFonts.regular_20 )
        local img_hard = ibCreateImage( 0, 600, 28, 28, ":nrp_shared/img/hard_money_icon.png", UI_limited.bg )
        local lbl_price_v = ibCreateLabel( 0, 612, 0, 0, format_price( params.cost ), UI_limited.bg, nil, nil, nil, "center", "center", ibFonts.bold_24 )

        lbl_price:center_x( - 2 - lbl_price_v:width( ) / 2 - img_hard:width( ) / 2 )
        img_hard:ibData( "px", lbl_price:ibData( "px" ) + lbl_price:width( ) / 2 + 10 )
        lbl_price_v:ibData( "px", img_hard:ibData( "px" ) + lbl_price_v:width( ) / 2 + img_hard:width( ) + 8 )

        ibCreateButton( 0, 644, 180, 46, UI_limited.bg, "img/btn_more", true ):center_x( )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            showLimitedUI( false )
            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "special" )
            ibClick( )
        end )

        showCursor( true )
    elseif not state and currentState then
        UI_limited.black_bg:destroy( )
        UI_limited = nil

        if not UI then
            showCursor( false )
        end
    end
end