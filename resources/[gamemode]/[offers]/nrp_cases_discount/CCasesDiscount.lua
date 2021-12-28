local UI

function onCasesDiscountShowInformation_handler( conf )
    loadstring( exports.interfacer:extend( "Interfacer" ) )( )
    Extend( "ib" )

    ShowInfoUI( true, conf )
end
addEvent( "onCasesDiscountShowInformation", true )
addEventHandler( "onCasesDiscountShowInformation", root, onCasesDiscountShowInformation_handler )

function ShowInfoUI( state, conf )
    if state then
        ShowInfoUI( false )

        UI = { }
        UI.black_bg    = ibCreateBackground( _, _, 0xaa000000 )

        local elastic_duration  = 2200
        local alpha_duration    = 700

        UI.bg
            = ibCreateImage( 0, 0, 0, 0, "img/bg_discount_window.png", UI.black_bg )
            :ibSetRealSize( )
            :center( 0, -100 )
            :ibData( "alpha", 0 )
            :ibMoveTo( 0, 100, elastic_duration, "OutElastic", true ):ibAlphaTo( 255, alpha_duration )


        local label_elements = { 474, 501, 547, 576, 619, 647 }

        local time_font = ibFonts.regular_24
        for i, v in pairs( label_elements ) do
            UI[ "tick_num_" .. i ] = ibCreateLabel( v, 115, 0, 0, "0", UI.bg ):ibBatchData( { font = time_font, align_x = "center", align_y = "center" } )
        end

        local function UpdateTimer()
            local time_diff = conf.finish - getRealTimestamp( )

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
                local element = UI[ "tick_num_" .. i ]
                if isElement( element ) then
                    element:ibData( "text", utf8.sub( str, i, i ) )
                end
            end

        end

		UI.timer_timer = Timer( UpdateTimer, 500, 0 )
		UpdateTimer( )

        local sx = UI.bg:ibData( "sx" )

        UI.button_close
            = ibCreateButton( sx - 24 - 26, 24, 24, 24, UI.bg,
                              ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                               0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowInfoUI( false )
            end )

        UI.btn_more
            = ibCreateButton( 325, 516, 0, 0, UI.bg,
                              "img/btn_more.png", "img/btn_more.png", "img/btn_more.png",
                              0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibSetRealSize( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowInfoUI( false )
                triggerServerEvent( "onPlayerRequestDonateMenu", resourceRoot, "cases", "cases_discount" )
            end )

        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = nil
        showCursor( false )

    end
end