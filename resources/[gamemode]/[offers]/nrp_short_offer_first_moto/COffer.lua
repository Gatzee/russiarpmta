Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI = { }

addEvent( "onPlayerShortOfferFM", true )
addEventHandler( "onPlayerShortOfferFM", localPlayer, function ( )
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

    local data = localPlayer:getData( DATA_NAME )
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

    ibCreateButton( 576, 642, 140, 48, UI.bg, "img/btn_buy", true )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end

        if confirmation then confirmation:destroy( ) end
        confirmation = ibConfirm( {
            title = "ПОДТВЕРЖДЕНИЕ",
            text = "Вы действительно желаете приобрести\nданный набор за " .. format_price( PACK_PRICE ) .. "?",
            fn = function( self )
                self:destroy( )
                triggerServerEvent( "onPlayerWantBuyCasesFM", resourceRoot )

                if localPlayer:HasDonate( PACK_PRICE ) then destroyWindow( ) end
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