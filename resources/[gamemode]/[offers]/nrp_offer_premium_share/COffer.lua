Extend( "ib" )
Extend( "ShUtils" )
Extend( "ShPlayer" )

ibUseRealFonts( true )

local UI = { }

addEvent( "onPlayerOfferPremiumShare", true )
addEventHandler( "onPlayerOfferPremiumShare", localPlayer, function ( )
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

        local time_left = ( ( localPlayer:getData( "offer_premium_share" ) or { } ).time_to or 0 ) - getRealTimestamp( )

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

        local onBuyClick = function( key, state )
            if key ~= "left" or state ~= "up" then return end

            local variant = source:ibData( "id" )
            if not variant or not VARIANTS[ variant ] then return end

            local info = VARIANTS[ variant ]

            UI.bg:ibData( "alpha", 0 )
            local bg = ibCreateImage( 0, 0, 1024, 768, "img/bg_pack.png", UI.black_bg ):center( ):ibData( "alpha", 0 ):ibAlphaTo( 255 )
            ibCreateButton( 971, 28, 24, 24, bg, ":nrp_shared/img/confirm_btn_close.png", nil, nil, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                bg:destroy( )
                UI.bg:ibData( "alpha", 255 )
            end, false )
            ibCreateLabel( 0, 38, 1024, 0, "Набор " .. info.name, bg, nil, nil, nil, "center", "center", ibFonts.bold_19 )
            ibCreateLabel( 386, 120, 0, 0, info.disc[ 1 ] .. " x" .. info.amount[ 1 ], bg, nil, nil, nil, "center", "center", ibFonts.regular_16 )
            ibCreateLabel( 648, 120, 0, 0, info.disc[ 2 ] .. " x" .. info.amount[ 2 ], bg, nil, nil, nil, "center", "center", ibFonts.regular_16 )

            ibCreateContentImage( 270, 130, 472, 360, "case", "tuning_" .. info.tuning_case_id, bg ):ibBatchData( { sx = 246, sy = 188 } )
            ibCreateContentImage( 530, 130, 472, 360, "case", "vinyl_" .. info.vinyl_case_id, bg ):ibBatchData( { sx = 246, sy = 188 } )

            for tier = 1, 5 do
                local old_price = info.prices[ tier ].old
                local new_price = info.prices[ tier ].new
                local discount = string.format( "%.0f", 100 - new_price / old_price * 100 )

                local bg_item = ibCreateImage( 30, 306 + ( tier - 1 ) * 90, 964, 74, "img/bg_item.png", bg )
                ibCreateLabel( 30, 0, 0, 74, "Класс " .. VEHICLE_CLASSES_NAMES[ tier ], bg_item, nil, nil, nil, nil, "center", ibFonts.bold_20 )
                ibCreateLabel( 227, 0, 0, 74, "СКИДКА " .. discount .. "%", bg_item, nil, nil, nil, "center", "center", ibFonts.bold_16 )
                local lbl_old = ibCreateLabel( 488, 0, 0, 70, old_price, bg_item, nil, nil, nil, nil, "center", ibFonts.bold_22 )
                ibCreateImage( 495 + lbl_old:width( ), 21, 28, 28, ":nrp_shared/img/hard_money_icon.png", bg_item )
                ibCreateImage( 484, 35, lbl_old:width( ) + 44, 1, nil, bg_item, COLOR_WHITE )
                local lbl_new = ibCreateLabel( 676, 0, 0, 70, new_price, bg_item, nil, nil, nil, nil, "center", ibFonts.bold_22 )
                ibCreateImage( 682 + lbl_new:width( ), 21, 28, 28, ":nrp_shared/img/hard_money_icon.png", bg_item )

                ibCreateArea( 0, 0, 964, 74, bg_item )
                :ibOnHover( function ( ) bg_item:ibData( "texture", "img/bg_item_h.png" ) end )
                :ibOnLeave( function ( ) bg_item:ibData( "texture", "img/bg_item.png" ) end )

                ibCreateButton( 800, 16, 136, 41, bg_item, "img/btn_buy", true )
                :ibOnHover( function ( ) bg_item:ibData( "texture", "img/bg_item_h.png" ) end )
                :ibOnLeave( function ( ) bg_item:ibData( "texture", "img/bg_item.png" ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end

                    if confirmation then confirmation:destroy( ) end
                    confirmation = ibConfirm( {
                        title = "ПОДТВЕРЖДЕНИЕ",
                        text = "Вы действительно желаете приобрести\nданный набор за " .. format_price( new_price ) .. "?",
                        fn = function( self )
                            self:destroy( )
                            triggerServerEvent( "onPlayerWantBuyCasesViaOffer", resourceRoot, variant, tier )

                            if localPlayer:HasDonate( new_price ) then destroyWindow( ) end
                        end,
                        escape_close = true,
                    } )
                    ibClick( )
                end )
            end

            ibClick( )
        end

        ibCreateButton( 100, 660, 169, 47, UI.bg, "img/btn_more", true ):ibData( "id", 1 ):ibOnClick( onBuyClick )
        ibCreateButton( 428, 660, 169, 47, UI.bg, "img/btn_more", true ):ibData( "id", 3 ):ibOnClick( onBuyClick )
        ibCreateButton( 755, 660, 169, 47, UI.bg, "img/btn_more", true ):ibData( "id", 2 ):ibOnClick( onBuyClick )
    end
end )

function destroyWindow( )
    if isElement( UI.black_bg ) then destroyElement( UI.black_bg ) end
    showCursor( false )
end