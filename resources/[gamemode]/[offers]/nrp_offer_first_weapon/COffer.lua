Extend( "ib" )
Extend( "CPlayer" )

ibUseRealFonts( true )

local UI = { }

addEvent( "onPlayerOfferFirstWeapon", true )
addEventHandler( "onPlayerOfferFirstWeapon", localPlayer, function ( )
    local timestamp = getRealTimestamp( )
    local month = getRealTime( timestamp, false ).month

    destroyWindow( )
    showCursor( true )

    -- window
    UI.black_bg = ibCreateBackground( nil, nil, true ):ibData( "alpha", 0 ):ibAlphaTo( 255 )
    UI.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI.black_bg ):center( )

    if month <= 1 or month == 11 then -- winter theme
        ibCreateImage( 0, 0, 1024, 720, "img/bg_winter.png", UI.bg )
    end

    ibCreateImage( 0, 0, 1024, 720, "img/bg_main.png", UI.bg )

    ibCreateButton( 971, 28, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", nil, nil, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end

        ibClick( )
        destroyWindow( )
    end, false )

    -- timer
    local tick = getTickCount( )
    local label_elements = {
        { 630, 134 },
        { 658, 134 },

        { 705, 134 },
        { 732, 134 },

        { 776, 134 },
        { 804, 134 },
    }

    for i, v in pairs( label_elements ) do
        UI[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "0", UI.bg ):ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
    end

    local data = localPlayer:getData( "offer_first_weapon" ) or { }
    local time_left = ( data.time_to or 0 ) - timestamp

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

    -- packs of offer
    for idx, v in pairs( OFFERS_PACK ) do
        local price = math.ceil( ( 100 - v.discount ) / 100 * v.price )
        local x_offset = 492 * ( idx - 1 )
        local bg_pack = ibCreateImage( 30 + x_offset, 180, 472, 510, "img/bg_pack_" .. idx .. ".png", UI.bg )

        ibCreateLabel( 316, 373, 0, 0, price, bg_pack, nil, nil, nil, "right", "center", ibFonts.bold_24 )
        ibCreateLabel( 316, 404, 0, 0, v.price, bg_pack, nil, nil, nil, "right", "center", ibFonts.bold_20 )

        ibCreateImage( 326, 360, 28, 28, ":nrp_shared/img/hard_money_icon.png", bg_pack )
        ibCreateImage( 330, 394, 22, 22, ":nrp_shared/img/hard_money_icon.png", bg_pack )

        ibCreateImage( 276, 404, 80, 1, nil, bg_pack, 0xffffffff )

        ibCreateButton( 0, 432, 139, 48, bg_pack, "img/btn_buy", true ):center_x( )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end

            if confirmation then confirmation:destroy( ) end
            confirmation = ibConfirm( {
                title = "ПОКУПКА НАБОРА",
                text = "Желаешь приобрести данный набор за " .. price .. "?",
                fn = function( self )
                    self:destroy( )
                    triggerServerEvent( "onPlayerWantBuyFirstWeaponViaOffer", resourceRoot, idx )

                    if localPlayer:HasDonate( price ) then destroyWindow( ) end
                end,
                escape_close = true,
            } )

            ibClick( )
        end )
    end
end )

function destroyWindow( )
    if isElement( UI.black_bg ) then destroyElement( UI.black_bg ) end
    showCursor( false )
end