loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )

ibUseRealFonts( true )

local UI_elements

function ShowCases50_handler( state, conf )
    if state then
        ShowCases50_handler( false )

        UI_elements = { }

        -- Фон
        UI_elements.reward_bg
            = ibCreateBackground( 0xdd394a5c, _, true )
            :ibData( "alpha", 0 )
            :ibData( "priority", 1 )
        
        ibCreateImage( 0, 0, 800, 570, "img/brush.png", UI_elements.reward_bg )
            :center( 0, 0 )

        -- Данные
        local bg_data
            = ibCreateImage( 0, 0, 0, 0, "img/bg_data.png", UI_elements.reward_bg )
            :ibSetRealSize( )
            :center( 0, -70 )

        local label_elements = { 0, 28, 74, 74+28, 145, 145+28 }
        local start_tick = getTickCount( )
        local time_font = ibFonts.regular_30
        for i, v in pairs( label_elements ) do
            UI_elements[ "tick_num_" .. i ] = ibCreateLabel( 383 + v, 92, 0, 0, "0", bg_data ):ibBatchData( { font = time_font, align_x = "center", align_y = "center" } )
        end

        local function UpdateTimer()
            local passed_tick = getTickCount( ) - start_tick
            local time_diff = math.floor( conf.duration - passed_tick / 1000 )

            if time_diff < 0 then return end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
            local seconds = math.floor( ( ( time_diff - hours * 60 * 60 ) - minutes * 60 ) )

            if hours > 99 then minutes = 60; seconds = 0 end

            hours = string.format( "%02d", math.min( hours, 99 ) )
            minutes = string.format( "%02d", math.min( minutes, 60 ) )
            seconds = string.format( "%02d", seconds )

            local str = hours .. minutes .. seconds

            for i = 1, #label_elements do
                local element = UI_elements[ "tick_num_" .. i ]
                if isElement( element ) then
                    element:ibData( "text", utf8.sub( str, i, i ) )
                end
            end

        end

		UI_elements.timer_timer = Timer( UpdateTimer, 500, 0 )
		UpdateTimer( )

        -- Кейс
        ibCreateImage( 0, 0, 0, 0, ":nrp_shop/img/cases/big/" .. conf.case_id .. ".png", UI_elements.reward_bg )
            :ibSetRealSize( )
            :center( 0, -40 )
        
        -- Кнопка "понял, спс"
        UI_elements.btn_ok 
            = ibCreateButton(	0, 0, 0, 0, UI_elements.reward_bg,
                                "img/btn_ok.png", "img/btn_ok.png", "img/btn_ok.png", 
                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibSetRealSize( )
            :center( 0, 180 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowCases50_handler( false )
            end )
        
        UI_elements.reward_bg:ibAlphaTo( 255, 500 )

        showCursor( true )

        playSound( ":nrp_shop/sfx/reward_small.mp3" )
    else
        DestroyTableElements( UI_elements )
        UI_elements = nil
        showCursor( false )
    end
end
addEvent( "ShowCases50", true )
addEventHandler( "ShowCases50", root, ShowCases50_handler )

--[[bindKey( "3", "down", function( )
    local possible_cases = { "bronze", "silver", "gold", "platinum" }
    local case_id = possible_cases[ math.random( 1, #possible_cases ) ]
    ShowCases50_handler( true, { case_id = case_id, duration = 24 * 60 * 60 } )
end )]]