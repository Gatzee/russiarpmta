loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "ShPlayer" )

ibUseRealFonts( true )

local UI = { }

addEvent( "onPlayerOfferPremium3DStart", true )
addEventHandler( "onPlayerOfferPremium3DStart", resourceRoot, function ( )
    local reward_bg = ibCreateBackground( 0xF2394a5c, _, true ):ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )
    ibCreateImage( 0, 0, 0, 0, "img/brush.png", reward_bg ):ibSetRealSize( ):center( )

    ibCreateLabel( 0, 0, 0, 0, "Бесплатный премиум на 3 дня", reward_bg )
    :ibBatchData( { font = ibFonts.bold_22, align_x = "center", colored = true } )
    :center( 0, - 150 )

    ibCreateContentImage( 0, 0, 120, 120, "other", "premium", reward_bg )
    :center( )

    ibCreateButton( 0, 0, 192, 110, reward_bg, "img/btn_take", true )
    :center( 0, 150 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )
        reward_bg:destroy( )
        showCursor( false )
    end )

    showCursor( true )
    ibSoundFX( "reward_get" )
end )

addEvent( "onPlayerOfferPremium3D", true )
addEventHandler( "onPlayerOfferPremium3D", localPlayer, function ( )
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
            { 585,  123 },
            { 614, 123 },

            { 661, 123 },
            { 688, 123 },

            { 732, 123 },
            { 760, 123 },
        }

        for i, v in pairs( label_elements ) do
            UI[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "0", UI.bg ):ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
        end

        local time_left = ( ( localPlayer:getData( "offer_premium_3d" ) or { } ).time_to or 0 ) - getRealTimestamp( )

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

            if confirmation then confirmation:destroy( ) end
            confirmation = ibConfirm( {
                title = "ПРЕМИУМ",
                text = VARIANTS[ variant ].days .. " дней за " .. VARIANTS[ variant ].price .. "\nПреобрести премиум по сниженной цене?",
                fn = function( self )
                    self:destroy( )
                    triggerServerEvent( "onPlayerWantBuyPremiumViaOffer", resourceRoot, variant )

                    if localPlayer:HasDonate( VARIANTS[ variant ].price ) then destroyWindow( ) end
                end,
                escape_close = true,
            } )

            ibClick( )
        end

        ibCreateButton( 109, 547, 130, 46, UI.bg, "img/btn_buy", true ):ibData( "id", 1 ):ibOnClick( onBuyClick )
        ibCreateButton( 765, 547, 130, 46, UI.bg, "img/btn_buy", true ):ibData( "id", 2 ):ibOnClick( onBuyClick )
        ibCreateButton( 437, 572, 130, 46, UI.bg, "img/btn_buy", true ):ibData( "id", 3 ):ibOnClick( onBuyClick )

        ibCreateButton( 845, 706, 149, 34, UI.bg, "img/btn_more", true )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "premium", "cases_offers" )
            --Задержка между открытием ф4 и выезжанием оверлея
            setTimer( function( ) triggerEvent( "onPremiumDescriptionRequest", localPlayer ) end, 350, 1 )
        end )

        UI.black_bg:ibAlphaTo( 255 )
    end
end )

function destroyWindow( )
    if isElement( UI.black_bg ) then destroyElement( UI.black_bg ) end
    showCursor( false )
end