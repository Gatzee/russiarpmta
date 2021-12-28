Extend( "ib" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "ShApartments" )

ibUseRealFonts( true )

local UI = { }

addEvent( "onPlayerOfferProperty", true )
addEventHandler( "onPlayerOfferProperty", localPlayer, function ( )
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
            { 586, 125 },
            { 614, 125 },

            { 660, 125 },
            { 688, 125 },

            { 732, 125 },
            { 760, 125 },
        }

        for i, v in pairs( label_elements ) do
            UI[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "0", UI.bg ):ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
        end

        local data = localPlayer:getData( "offer_property" ) or { }
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

        for class_id = 1, 3 do
            local cost = APARTMENTS_CLASSES[ class_id ].cost

            local area = ibCreateArea( 30 + ( ( class_id - 1 ) * 328 ), 185, 308, 407, UI.bg )
            local lbl = ibCreateLabel( 230, 286, 0, 0, format_price( cost ), area, ibApplyAlpha( COLOR_WHITE, 75 ), nil, nil, "center", "center", ibFonts.bold_16 )
            ibCreateLine( 161 + ( class_id == 1 and 8 or 0 ), 286, lbl:ibGetAfterX( 5 ), 286, 0xFFFFFFFF, 1, area )
            ibCreateLabel( 235, 312, 0, 0, format_price( math.floor( cost * 0.8 ) ), area, 0xFFFFFFFF, nil, nil, "center", "center", ibFonts.bold_18 )

            ibCreateButton( 0, 340, 230, 37, area, "img/btn_show_map_location", true ):center_x( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end

                local positions = { }
                for idx, v in ipairs( APARTMENTS_LIST ) do
                    if v.class == class_id then
                        local vec3 = v.enter_position
                        table.insert( positions, { vec3, math.abs( ( localPlayer.position - vec3 ):getLength( ) ) } )
                    end
                end
                table.sort( positions, function( a, b ) return a[ 2 ] < b[ 2 ] end )

                triggerEvent( "ToggleGPS", localPlayer, positions[ 1 ][ 1 ] )

                localPlayer:ShowInfo( "Установлена метка до ближайшей квартиры данного класса" )
                destroyWindow( )
                ibClick( )
            end )
        end

        UI.black_bg:ibAlphaTo( 255 )
    end
end )

function destroyWindow( )
    if isElement( UI.black_bg ) then destroyElement( UI.black_bg ) end
    showCursor( false )
end