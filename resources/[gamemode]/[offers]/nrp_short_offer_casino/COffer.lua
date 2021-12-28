Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI = { }

addEvent( "onPlayerShortOfferCasino", true )
addEventHandler( "onPlayerShortOfferCasino", localPlayer, function ( )
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

    -- Таймер акции
    local tick = getTickCount( )
    local label_elements = {
        { 586, 125 },
        { 614, 125 },

        { 661, 125 },
        { 688, 125 },

        { 732, 125 },
        { 760, 125 },
    }

    for i, v in pairs( label_elements ) do
        UI[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "0", UI.bg ):ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
    end

    local data = localPlayer:getData( DATA_NAME ) or { }
    local time_left = ( data.time_to or 0 ) - getRealTimestamp( )

    local function UpdateTimer( )
        local passed = getTickCount( ) - tick
        local time_diff = math.ceil( time_left - passed / 1000 )

        if time_diff < 0 then OFFER_A_LEFT = nil return end

        local hours = math.floor( time_diff / 60 / 60 )
        local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
        local seconds = math.floor( ( ( time_diff - hours * 60 * 60 ) - minutes * 60 ) )

        if hours > 99 then minutes = 60; seconds = 0 end

        hours = string.format( "%02d", math.min( hours, 99 ) )
        minutes = string.format( "%02d", math.min( minutes, 60 ) )
        seconds = string.format( "%02d", seconds )

        local str = hours .. minutes .. seconds

        for i = 1, #label_elements do
            local element = UI[ "tick_num_" .. i ]
            if isElement( element ) then
                element:ibData( "text", utf8.sub( str, i, i ) )
            end
        end
    end
    UI.bg:ibTimer( UpdateTimer, 500, 0 )
    UpdateTimer( )

    ibCreateButton( 572, 642, 140, 48, UI.bg, "img/btn_buy", true )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end

        if confirmation then confirmation:destroy( ) end
        confirmation = ibConfirm( {
            title = "ПОДТВЕРЖДЕНИЕ",
            text = "Вы действительно желаете приобрести\nданный набор за " .. format_price( PACK_PRICE ) .. "?",
            fn = function( self )
                self:destroy( )
                triggerServerEvent( "onPlayerWantBuyOfferCasino", resourceRoot )

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