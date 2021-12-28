Extend( "ib" )
Extend( "ShUtils" )
Extend( "CPlayer" )

ibUseRealFonts( true )

local UI = { }

function setStateWindow( state )
    local current_state = isElement( UI.black_bg )

    if state and not current_state then
        local current_level = localPlayer:GetLevel( )

        UI.black_bg = ibCreateBackground( nil, nil, true ):ibData( "alpha", 0 ):ibAlphaTo( 255 )
        :ibTimer( function ( )
            if current_level ~= localPlayer:GetLevel( ) then
                setStateWindow( false )
            end
        end, 250, 0 )

        UI.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI.black_bg ):ibSetRealSize( ):center( )

        ibCreateButton( 971, 28, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", nil, nil, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, st )
            if key ~= "left" or st ~= "up" then return end

            ibClick( )
            setStateWindow( false )
        end, false )

        local offer_piggy_bank = localPlayer:getData( DATA_NAME ) or 0
        local price = getPriceOfTax( offer_piggy_bank, current_level )

        ibCreateContentImage( 644, 450, 90, 90, "skin", localPlayer.model, UI.bg )
        ibCreateLabel( 754, 508, 0, 0, localPlayer:GetNickName( ), UI.bg, nil, nil, nil, nil, "center", ibFonts.regular_18 )

        local lbl_cashback = ibCreateLabel( 0, 619, 0, 0, format_price( offer_piggy_bank ), UI.bg, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_24 )
        local lbl = ibCreateLabel( 0, 621, 0, 0, "Накопленная сумма:", UI.bg, ibApplyAlpha( 0xffffffff, 75 ), nil, nil, "center", "center", ibFonts.regular_19 )
        local lbl_cashback_px = lbl_cashback:width( ) / 4 + lbl:width( ) / 4 + 4
        lbl_cashback:ibData( "px", 289 + lbl_cashback_px )
        lbl:ibData( "px", 289 - lbl_cashback_px )
        ibCreateImage( 289 + lbl_cashback_px + lbl_cashback:width( ) / 2 + 8, 605, 28, 28, ":nrp_shared/img/money_icon.png", UI.bg )

        local lbl_price = ibCreateLabel( 0, 584, 0, 0, format_price( price ), UI.bg, nil, nil, nil, "center", "center", ibFonts.oxaniumbold_24 )
        local lbl_2 = ibCreateLabel( 0, 586, 0, 0, "Сумма пошлины:", UI.bg, ibApplyAlpha( 0xffffffff, 75 ), nil, nil, "center", "center", ibFonts.regular_18 )
        local lbl_price_px = lbl_price:width( ) / 4 + lbl_2:width( ) / 4 + 4
        lbl_price:ibData( "px", 789 + lbl_price_px )
        lbl_2:ibData( "px", 789 - lbl_price_px )
        ibCreateImage( 789 + lbl_price_px + lbl_price:width( ) / 2 + 8, 571, 28, 28, ":nrp_shared/img/hard_money_icon.png", UI.bg )

        ibCreateButton( 653, 610, 260, 50, UI.bg, "img/btn_buy", true )
        :ibOnClick( function ( key, st )
            if key ~= "left" or st ~= "up" then
                return
            end

            if confirmation then confirmation:destroy( ) end
            confirmation = ibConfirm( {
                title = "НАЛОГОВЫЙ ВЫЧЕТ",
                text = "Желаешь оплатить пошлину, чтобы вернуть налоговый вычет? Сумма пошлины: " .. price,
                fn = function( self )
                    self:destroy( )
                    triggerServerEvent( "onPlayerWantReturnTaxByOffer", resourceRoot )

                    if localPlayer:HasDonate( price ) then
                        setStateWindow( false )
                    end
                end,
                escape_close = true,
            } )
        end )

        showCursor( true )
    elseif not state and current_state then
        destroyElement( UI.black_bg )

        showCursor( false )
    end
end

addEvent( "onPlayerOfferPiggyBank", true )
addEventHandler( "onPlayerOfferPiggyBank", localPlayer, function ( )
    setStateWindow( true )
end )