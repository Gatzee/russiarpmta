MARCH = {
    create = function( self, offer )

        UI_elements.black_bg = ibCreateBackground( _, _, true )

        UI_elements.bg_texture = dxCreateTexture( script_folder .. "img/bg.png" )

        local scale = 1
        sx, sy = dxGetMaterialSize( UI_elements.bg_texture )
        sx, sy = sx * scale, sy * scale
        px, py = x / 2 - sx / 2 , y/ 2 - sy / 2

        UI_elements.bg = ibCreateImage( px, -sy, sx, sy, UI_elements.bg_texture, UI_elements.black_bg )
        UI_elements.bg:ibBatchData( { alpha = 0 } ):ibAlphaTo( 255, 500 ):ibMoveTo( px, py, 1000, "OutElastic" )

        UI_elements.button_close = ibCreateButton(	sx - 54, 24, 24, 24, UI_elements.bg,
													":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
													0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.button_close, function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowUI( false )
        end, false )

        local label_elements = {
            { 500, 104 },
            { 528, 104 },

            { 574, 104 },
            { 602, 104 },

            { 646, 104 },
            { 674, 104 },
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

            while utf8.len( hours ) < 2 do
                hours = "0" .. hours
            end

            while utf8.len( minutes ) < 2 do
                minutes = "0" .. minutes
            end

            while utf8.len( seconds ) < 2 do
                seconds = "0" .. seconds
            end

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
            { 35, 267 },
            { 436, 267 },
            { 35, 476 },
            { 436, 476 },
        }

        UI_elements.pack_btn_texture = dxCreateTexture( script_folder .. "img/btn_buy.png" )
        local btn_buy_file = script_folder .. "img/btn_buy.png"

        local bsx, bsy = dxGetMaterialSize( UI_elements.pack_btn_texture )

        for i, v in pairs( buttons ) do
            UI_elements[ 'pack_btn_' .. i ] = ibCreateButton(	v[ 1 ], v[ 2 ], bsx, bsy, UI_elements.bg,
                                                                    btn_buy_file, btn_buy_file, btn_buy_file,
                                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            addEventHandler( "ibOnElementMouseClick", UI_elements[ 'pack_btn_' .. i ], function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ShowUI( false )
                SelectPack( i )
            end, false )                                                    
        end

        UpdateTimer()

    end,
}