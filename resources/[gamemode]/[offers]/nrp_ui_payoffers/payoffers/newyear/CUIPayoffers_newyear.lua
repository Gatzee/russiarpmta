NEWYEAR = {
    create = function( self, offer )

        UI_elements.black_bg = ibCreateBackground( _, _, true )

        UI_elements.bg_texture = dxCreateTexture( script_folder .. "img/bg.png" )

        local scale = 1
        sx, sy = dxGetMaterialSize( UI_elements.bg_texture )
        sx, sy = sx * scale, sy * scale
        px, py = x / 2 - sx / 2 , y/ 2 - sy / 2

        UI_elements.bg 
            = ibCreateImage( px, -sy, sx, sy, UI_elements.bg_texture, UI_elements.black_bg )
            :ibBatchData( { alpha = 0 } )
            :ibAlphaTo( 255, 500 )
            :ibMoveTo( px, py, 1000, "OutElastic" )

        UI_elements.button_close
            = ibCreateButton(	sx - 54, 24, 24, 24, UI_elements.bg,
								":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
								0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ShowUI( false )
            end )

        local label_elements = {
            { 484, 87 },
            { 506, 87 },

            { 542, 87 },
            { 564, 87 },

            { 598, 87 },
            { 620, 87 },
        }

        local time_font = exports.nrp_fonts:DXFont( "OpenSans/OpenSans-Regular.ttf", 22, true )
        for i, v in pairs( label_elements ) do
            UI_elements[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ] - 27, v[ 2 ] + 12, 0, 0, "0", UI_elements.bg ):ibBatchData( { font = time_font, align_x = "center", align_y = "center" } )
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
            { 30, 277 },
            { 431, 277 },
            { 30, 505 },
            { 431, 505 },
        }

        UI_elements.pack_btn_texture = dxCreateTexture( script_folder .. "img/btn_buy.png" )
        local btn_buy_file = script_folder .. "img/btn_buy.png"

        local bsx, bsy = dxGetMaterialSize( UI_elements.pack_btn_texture )

        for i, v in pairs( buttons ) do
            UI_elements[ 'pack_btn_' .. i ] 
                = ibCreateButton(	v[ 1 ] + 13, v[ 2 ], bsx, bsy, UI_elements.bg,
                                    btn_buy_file, btn_buy_file, btn_buy_file,
                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    ShowUI( false )
                    SelectPack( i )
                end )                                                    
        end

        UpdateTimer()
    end,
}