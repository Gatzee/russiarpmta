Extend( "ib" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "ShClothesShops" )

ibUseRealFonts( true )

local UI = { }

addEvent( "onPlayerOfferSkin", true )
addEventHandler( "onPlayerOfferSkin", localPlayer, function ( )
    destroyWindow( )
    showCursor( true )

    UI.black_bg = ibCreateBackground( nil, nil, true ):ibData( "alpha", 0 )
    UI.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI.black_bg ):center( )

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
            { 629, 128 },
            { 657, 128 },

            { 704, 128 },
            { 731, 128 },

            { 775, 128 },
            { 803, 128 },
        }

        for i, v in pairs( label_elements ) do
            UI[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "0", UI.bg ):ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
        end

        local data = localPlayer:getData( "offer_skin" ) or { }
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

        ibCreateButton( 0, 646, 248, 44, UI.bg, "img/btn_show", true ):center_x( )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end

            localPlayer:ShowInfo( "Установлена метка до ближайшего магазина одежды" )
            triggerEvent( "ToggleGPS", localPlayer, CLOTHES_SHOPS_LIST, true )
            destroyWindow( )
            ibClick( )
        end )

        UI.black_bg:ibAlphaTo( 255 )
    end
end )

function destroyWindow( )
    if isElement( UI.black_bg ) then destroyElement( UI.black_bg ) end
    showCursor( false )
end