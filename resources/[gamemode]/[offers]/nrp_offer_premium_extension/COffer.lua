loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "ShPlayer" )

ibUseRealFonts( true )

local UI = { }

addEvent( "onPlayerOfferPremiumExtension", true )
addEventHandler( "onPlayerOfferPremiumExtension", localPlayer, function ( )
    destroyWindow( )
    showCursor( true )

    UI.black_bg = ibCreateBackground( nil, nil, true ):ibData( "alpha", 0 )
    UI.bg = ibCreateImage( 0, 0, 1024, 768, "img/bg.png", UI.black_bg ):ibSetRealSize( ):center( )

    ibCreateButton( 971, 28, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", nil, nil, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end

        ibClick( )
        destroyWindow( )
    end, false )

    do
        -- Таймер акции
        local tick = getTickCount( )
        local label_elements = {
            { 630, 126 },
            { 658, 126 },

            { 705, 126 },
            { 732, 126 },

            { 776, 126 },
            { 804, 126 },
        }

        for i, v in pairs( label_elements ) do
            UI[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "0", UI.bg ):ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
        end

        local data = localPlayer:getData( "offer_premium_extension" ) or { }
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

        local info = VARIANTS[ data.duration ]
        local days_info = data.duration > 3 and "ДНЕЙ" or "ДНЯ"

        ibCreateLabel( 668, 39, 0, 0, "СКИДКА " .. info.discount .. "%", UI.bg, nil, nil, nil, "center", "center", ibFonts.extrabold_12 )
        ibCreateLabel( 0, 235, 1024, 0, "НА " .. data.duration .. " " .. days_info, UI.bg, nil, nil, nil, "center", "center", ibFonts.extrabold_20 )
        ibCreateLabel( 610, 589, 0, 0, info.old_price, UI.bg, ibApplyAlpha( COLOR_WHITE, 50 ), nil, nil, nil, "center", ibFonts.bold_24 )
        ibCreateLabel( 625, 632, 0, 0, info.price, UI.bg, nil, nil, nil, nil, "center", ibFonts.bold_30 )
        ibCreateImage( 554, 588, 108, 1, nil, UI.bg, ibApplyAlpha( COLOR_WHITE, 75 ) )

        ibCreateButton( 0, 682, 223, 56, UI.bg, "img/btn_buy", true ):center_x( )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end

            if confirmation then confirmation:destroy( ) end
            confirmation = ibConfirm( {
                title = "ПРЕМИУМ",
                text = "Продлить премиум на " .. data.duration .. " дн. за " .. info.price .. "?",
                fn = function( self )
                    self:destroy( )
                    triggerServerEvent( "onPlayerWantBuyPremiumViaOffer", resourceRoot )

                    if localPlayer:HasDonate( info.price ) then destroyWindow( ) end
                end,
                escape_close = true,
            } )

            ibClick( )
        end )

        UI.black_bg:ibAlphaTo( 255 )
    end
end )

function destroyWindow( )
    if isElement( UI.black_bg ) then destroyElement( UI.black_bg ) end
    showCursor( false )
end