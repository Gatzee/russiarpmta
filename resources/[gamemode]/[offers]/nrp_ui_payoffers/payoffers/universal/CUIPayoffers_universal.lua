UNIVERSAL = {
    create = function( self, offer ) 
        local fonts_real = ibIsUsingRealFonts( )
        ibUseRealFonts( true )

        UI_elements.black_bg = ibCreateBackground( _, _, true )

        UI_elements.bg 
            = ibCreateImage( 0, 0, 0, 0, script_folder .. "img/bg.png", UI_elements.black_bg )
            :ibSetRealSize( )
            :center()
            :ibBatchData( { alpha = 0 } )
            :ibAlphaTo( 255, 500 )

        UI_elements.button_close
            = ibCreateButton(	UI_elements.bg:ibData( "sx" ) - 54, 24, 24, 24, UI_elements.bg,
								":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
								0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ShowUI( false )
            end )

        local label_elements = {
            { 586, 127 },
            { 613, 127 },

            { 660, 127 },
            { 687, 127 },

            { 732, 127 },
            { 760, 127 },
        }

        -- local time_font = exports.nrp_fonts:DXFont( "OpenSans/OpenSans-Regular.ttf", 22, true )
        for i, v in pairs( label_elements ) do
            UI_elements[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "0", UI_elements.bg )
                :ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
        end

        local function UpdateTimer()

            local time_diff = offer.finish - getRealTimestamp()

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


        local buttons = {
            { 78, 369 },
            { 590, 369 },
            { 78, 662 },
            { 590, 662 },
        }

        for i, v in pairs( buttons ) do
            UI_elements[ 'pack_btn_' .. i ] 
                = ibCreateButton(	v[ 1 ], v[ 2 ], 0, 0, UI_elements.bg,
                                    script_folder .. "img/btn_buy.png", _, _,
                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                :ibSetRealSize( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    ShowUI( false )
                    SelectPack( i )
                end )                                                    
        end

        UpdateTimer()
        
        ibUseRealFonts( fonts_real )
    end,
}