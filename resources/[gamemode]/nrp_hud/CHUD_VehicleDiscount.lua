HUD_CONFIGS.vehicle_discount = {
    elements = { },
    order = 997,
    create = function( self, block_config )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_vehicle_discount.png", bg )
        self.elements.bg = bg

        local positions = {
            { 33, 40 },
            { 62, 40 },
            { 84, 38 },
            { 108, 40 },
            { 136, 40 },
        }

        for i, v in pairs( positions ) do
            local lbl = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "", bg, 0xffffffff, _, _, "center", "center", ibFonts.regular_26 )
            self.elements[ "lbl_symbol_" .. i ] = lbl
        end

        local discount_data = getElementData( localPlayer, "temp_vehicle_discount" )

        if discount_data then
            ibCreateLabel( 170, 30, 0, 0, "Скидка "..discount_data.percent.."%", bg, 0xFFff2f2f, _, _, "left", "center", ibFonts.bold_18 )
            ibCreateLabel( 170, 55, 155, 0, "На покупку "..VEHICLE_CONFIG[ discount_data.model ].model , bg, 0xFFffffff, _, _, "left", "center", ibFonts.regular_9 )
            :ibData( "wordbreak", true )
        end

        function UpdateTimer( )
            local server_timestamp = getRealTimestamp( )
            local discount_data = getElementData( localPlayer, "temp_vehicle_discount" ) or { }

            local time_diff = ( discount_data.timestamp or 0 ) - server_timestamp

            if time_diff <= 0 then
                RemoveHUDBlock( "vehicle_discount" )
                return
            end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
            hours = string.format( "%02d", hours )
            minutes = string.format( "%02d", minutes )

            local str = hours .. ":" .. minutes
            for i = 1, #positions do
                local symbol = utf8.sub( str, i, i )
                self.elements[ "lbl_symbol_" .. i ]:ibData( "text", symbol )
            end
        end

        self.elements.timer = setTimer( UpdateTimer, 200, 0 )
        UpdateTimer( )

        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function VEHICLEDISCOUNT_onElementDataChange( key )
    if not key or key == "temp_vehicle_discount" then
        local value = getElementData( localPlayer, "temp_vehicle_discount" )
        if not value then RemoveHUDBlock( "vehicle_discount" ) return end

        AddHUDBlock( "vehicle_discount", value )
    end
end
addEventHandler( "onClientElementDataChange", localPlayer, VEHICLEDISCOUNT_onElementDataChange )

function VEHICLEDISCOUNT_onStart( )
    VEHICLEDISCOUNT_onElementDataChange( )
end
addEventHandler( "onClientResourceStart", resourceRoot, VEHICLEDISCOUNT_onStart )