loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "CPlayer" )
ibUseRealFonts( true )

local ui = { }

function ShowOfferComfortStart( state )
    if state and not ui.black_bg then
        local sx, sy = 1024, 768
        local px, py = ( _SCREEN_X - sx ) / 2, ( _SCREEN_Y - sy ) / 2

        -- Сам фон
        ui.black_bg = ibCreateBackground( nil, function ( ) ui.bg:destroy( ) end, true )
        ui.bg = ibCreateImage( px, py - 100, sx, sy, "img/bg.png" )
        :ibData( "alpha", 0 ):ibMoveTo( px, py, 500 ):ibAlphaTo( 255, 300 )

        ibCreateButton( sx - 24 - 30, 25, 24, 24, ui.bg, ":nrp_shared/img/confirm_btn_close.png",
    nil, nil, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end

            ibClick( )
            ShowOfferComfortStart( false )
        end )

        -- Таймер акции
        local time_left = ( localPlayer:getData( "comfort_test_offer_end_date" ) or 0 ) - getRealTimestamp( )
        local tick = getTickCount( )
        local label_elements = {
            { 574, 104 },
            { 602, 104 },

            { 648, 104 },
            { 676, 104 },

            { 720, 104 },
            { 748, 104 },
        }

        for i, v in pairs( label_elements ) do
            ui[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 24, 49, "0", ui.bg )
            :ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
        end

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
                local element = ui[ "tick_num_" .. i ]
                if isElement( element ) then
                    element:ibData( "text", utf8.sub( str, i, i ) )
                end
            end
        end

        ui.timer_timer = Timer( UpdateTimer, 500, 0 )
        UpdateTimer( )

        local button_elements = {
            { 208, 670 },
            { 536, 670 },
            { 862, 670 },
        }

        for idx, v in ipairs( button_elements ) do
            ibCreateButton( v[ 1 ], v[ 2 ], 110, 44, ui.bg, "img/btn_buy.png",
        nil, nil, 0xFFFFFFFF, 0xFFF0F0F0, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end

                ibClick( )
                triggerServerEvent( "onPlayerWantBuyPackageComfortStart", resourceRoot, idx )
            end )
        end

        showCursor( true )

    elseif ui.black_bg then
        ui.black_bg:destroy( )
        ui = { }

        showCursor( false )
    end
end

addEvent( "onPlayerShowOfferComfortStart", true )
addEventHandler( "onPlayerShowOfferComfortStart", root, function ( state )
    ShowOfferComfortStart( state )
end )