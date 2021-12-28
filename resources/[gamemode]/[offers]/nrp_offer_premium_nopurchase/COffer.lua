Extend( "ib" )
Extend( "ShUtils" )
Extend( "ShPlayer" )
Extend( "ShVehicleConfig" )
Extend( "ShVehicle" )

ibUseRealFonts( true )

local UI = { }
local selected = {
    tier = 1,
    variant = 1,
    pack_id = 1,
}

function createConfirm( )
    if confirmation then confirmation:destroy( ) end

    local pack = VARIANTS[ selected.variant ][ selected.pack_id ]
    local vinil_info = pack.vinyl_id and "Винил входящий в набор будет привязан к " .. VEHICLE_CLASSES_NAMES[ selected.tier ] .. " классу" or ""

    confirmation = ibConfirm( {
        title = "ПРЕМИУМ НАБОР",
        text = "Вы действительно желаете приобрести данный набор за " .. pack.price .. "? " .. vinil_info,
        fn = function( self )
            self:destroy( )
            triggerServerEvent( "onPlayerWantBuyFirstPremium", resourceRoot, selected.pack_id, selected.tier )

            if localPlayer:HasDonate( pack.price ) then destroyWindow( ) end
        end,
        escape_close = true,
    } )
end

function createSelector( parent )
    local pVehicles = localPlayer:GetVehicles( nil, true )

    local bg = ibCreateImage( 0, 80, 1024, 688, nil, parent, ibApplyAlpha( 0xff1f2934, 95 ) )

    ibCreateLabel( 0, 35, 1024, 0, "Установка винила", bg, 0xffffffff, nil, nil, "center" ):ibData( "font", ibFonts.bold_20 )
    ibCreateLabel( 0, 70, 1024, 0, "Выберите автомобиль к классу которого вы хотите привязать винил", bg, ibApplyAlpha( COLOR_WHITE, 60 ), nil, nil, "center", nil, ibFonts.regular_16 )

    ibCreateImage( 30, 140, 1024 - 60, 1, nil, bg, 0xFF59616A )

    local scrollpane, scrollbar = ibCreateScrollpane( 0, 140, 1024, 450, bg, { scroll_px = -20 } )
    scrollbar:ibSetStyle( "slim_nobg" )

    local sx, sy = parent:width( ), 74
    local px, py = 0, 0

    for idx, v in pairs( pVehicles ) do
        if VEHICLE_CONFIG[ v.model ] and ( not VEHICLE_CONFIG[ v.model ].is_airplane and not VEHICLE_CONFIG[ v.model ].is_boat and v.model ~= 468 ) then
            local hover = ibCreateImage( 0, py, sx, sy, nil, scrollpane, 0x0cffffff ):ibData( "alpha", 0 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )

            ibCreateImage( px + 30, py + sy / 2 - 16, 49, 33, "img/icon_vehicle.png", scrollpane ):ibData( "disabled", true )
            ibCreateLabel( px + 100, py, 0, sy, VEHICLE_CONFIG[ v.model ].model, scrollpane, 0xffffffff, nil, nil, "left", "center", ibFonts.regular_16 ):ibData( "disabled", true )

            ibCreateImage( 30, py + sy - 1, sx - 60, 1, nil, scrollpane, 0xFF59616A )

            ibCreateButton( sx - 152, py + sy / 2 - 19, 126, 38, scrollpane, "img/btn_select.png", "img/btn_select_hover.png", "img/btn_select_hover.png" )
            :ibOnHover( function( ) hover:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) hover:ibAlphaTo( 0, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                selected.tier = v:GetTier( )
                bg:destroy( )
                createConfirm( )
            end )

            py = py + sy
        end
    end

    scrollpane:AdaptHeightToContents( )
    scrollbar:UpdateScrollbarVisibility( scrollpane )

    ibCreateButton( 0, 615, 108, 42, bg, "img/btn_notification_hide.png", nil, nil, ibApplyAlpha( 0xffffffff, 85 ), 0xffffffff, 0xffffffff )
    :center_x( ):ibOnClick( function ( key, state )
        if key ~= "left" or state ~= "up" then return end

        ibClick( )
        bg:destroy( )
    end )
end

addEvent( "onPlayerOfferPremiumNopurchase", true )
addEventHandler( "onPlayerOfferPremiumNopurchase", localPlayer, function ( )
    destroyWindow( )
    showCursor( true )

    local data = localPlayer:getData( "offer_premium_np" )
    local img_path = data.variant == 1 and "bg.png" or "bg_2.png"
    local variants = VARIANTS[ data.variant ]

    UI.black_bg = ibCreateBackground( nil, nil, true ):ibData( "alpha", 0 )
    UI.bg = ibCreateImage( 0, 0, 1024, 768, "img/" .. img_path, UI.black_bg ):ibSetRealSize( ):center( )

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

        local time_left = data.time_to - getRealTimestamp( )

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

            local pack_id = source:ibData( "id" )
            if not pack_id or not variants[ pack_id ] then return end

            selected.pack_id = pack_id
            selected.variant = data.variant

            if variants[ pack_id ].vinyl_id then
                createSelector( UI.bg )
            else
                createConfirm( )
            end

            ibClick( )
        end

        ibCreateButton( 63, 612, 130, 46, UI.bg, "img/btn_buy", true ):ibData( "id", 1 ):ibOnClick( onBuyClick )
        ibCreateButton( 319, 612, 130, 46, UI.bg, "img/btn_buy", true ):ibData( "id", 2 ):ibOnClick( onBuyClick )
        ibCreateButton( 575, 612, 130, 46, UI.bg, "img/btn_buy", true ):ibData( "id", 3 ):ibOnClick( onBuyClick )
        ibCreateButton( 831, 612, 130, 46, UI.bg, "img/btn_buy", true ):ibData( "id", 4 ):ibOnClick( onBuyClick )

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