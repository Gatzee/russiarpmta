Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI = { }

addEvent( "onPlayerShortOfferFV", true )
addEventHandler( "onPlayerShortOfferFV", localPlayer, function ( )
    local data = localPlayer:getData( DATA_NAME )
    local prices = PACK_PRICES[ data.class ]

    destroyWindow( )
    showCursor( true )

    UI.black_bg = ibCreateBackground( nil, nil, true ):ibData( "alpha", 0 ):ibAlphaTo( 255 )
    UI.bg = ibCreateImage( 0, 0, 1024, 768, "img/bg.png", UI.black_bg ):ibSetRealSize( ):center( )

    ibCreateButton( 971, 28, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", nil, nil, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end

        ibClick( )
        destroyWindow( )
    end, false )

    local time_to = data.time_to
    local lbl_timer = ibCreateLabel( 854, 40, 0, 0, "00 ч. 00 мин.", UI.bg, nil, nil, nil, nil, "center", ibFonts.bold_16 )

    local function updateTimer( )
        local time_diff = time_to - getRealTimestamp( )
        if time_diff < 0 then destroyWindow( ) return end

        local hours = math.floor( time_diff / 60 / 60 )
        local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )

        minutes = string.format( "%02d", math.min( minutes, 59 ) )
        local str = hours .. " ч. " .. minutes .. " мин."
        lbl_timer:ibData( "text", str )
    end
    lbl_timer:ibTimer( updateTimer, 500, 0 )
    updateTimer( )

    ibCreateContentImage( 480, 130, 300, 160, "vehicle", data.model, UI.bg )
    ibCreateLabel( 246, 214, 0, 0, VEHICLE_CONFIG[ data.model ].model or "", UI.bg, nil, nil, nil, nil, "center", ibFonts.bold_20 )

    local lbl_price = ibCreateLabel( 479, 652, 0, 0, prices.price, UI.bg, nil, nil, nil, nil, "center", ibFonts.oxaniumbold_26 )
    local lbl_old_price = ibCreateLabel( 479, 678, 0, 0, prices.old_price, UI.bg, ibApplyAlpha( 0xffffffff, 35 ), nil, nil, nil, "center", ibFonts.oxaniumbold_18 )

    ibCreateImage( 479 + lbl_price:width( ) + 6, 639, 28, 28, ":nrp_shared/img/hard_money_icon.png", UI.bg )
    ibCreateImage( 479 + lbl_old_price:width( ) + 6, 670, 18, 18, ":nrp_shared/img/hard_money_icon.png", UI.bg )
    ibCreateImage( 476, 679, lbl_old_price:width( ) + 30, 1, nil, UI.bg, 0xffffffff )

    local discount = math.floor( 100 - ( prices.price / prices.old_price * 100 ) )
    local area = ibCreateRenderTarget( 914, 304, 200, 200, UI.bg )
    ibCreateLabel( 100, 50, 0, 0, discount .. "%", area, nil, nil, nil, "center", "center", ibFonts.oxaniumextrabold_28 )
    :ibData( "rotation_center_x", 100 )
    :ibData( "rotation", 45 )

    ibCreateButton( 576, 642, 140, 48, UI.bg, "img/btn_buy", true )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end

        if confirmation then confirmation:destroy( ) end
        confirmation = ibConfirm( {
            title = "ПОДТВЕРЖДЕНИЕ",
            text = "Вы действительно желаете приобрести\nданный набор за " .. format_price( prices.price ) .. "?",
            fn = function( self )
                self:destroy( )
                triggerServerEvent( "onPlayerWantBuyCasesFV", resourceRoot )

                if localPlayer:HasDonate( prices.price ) then destroyWindow( ) end
            end,
            escape_close = true,
        } )
        ibClick( )
    end )
end )

function destroyWindow( )
    if isElement( UI.black_bg ) then
        destroyElement( UI.black_bg )
    end

    showCursor( false )
end