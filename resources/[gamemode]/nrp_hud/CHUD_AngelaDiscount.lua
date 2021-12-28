HUD_CONFIGS.angela_discount = {
    elements = { },
    order = 997,
    create = function( self )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_red_timer.png", bg )
        self.elements.bg = bg

        local data = localPlayer:GetAllVehiclesDiscount( )

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

        ibCreateLabel( 169, 15, 0, 0, "Скидка " .. data.percentage .. "%", bg, 0xffff2b2b, _, _, "left", "top", ibFonts.bold_18 )
        ibCreateLabel( 169, 47, 0, 0, "На покупку первого авто", bg, ibApplyAlpha( COLOR_WHITE, 85 ), _, _, "left", "top", ibFonts.regular_10 )

        function UpdateTimer( )
            local time_diff = localPlayer:GetAllVehiclesDiscount( ).timestamp - getRealTimestamp( )

            if time_diff <= 0 then
                RemoveHUDBlock( "angela_discount" )
                return
            end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
            hours = string.format( "%02d", hours )
            minutes = string.format( "%02d", minutes )

            local str = hours .. " " .. minutes
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

function ANGELADISCOUNT_onElementDataChange( key )
    if not key or key == "all_vehicles_discount" then
        RemoveHUDBlock( "angela_discount" )

        local data = localPlayer:GetAllVehiclesDiscount( )
        if not data then return end

        AddHUDBlock( "angela_discount" )
    end
end
addEventHandler( "onClientElementDataChange", localPlayer, ANGELADISCOUNT_onElementDataChange )

function ANGELADISCOUNT_onStart( )
    ANGELADISCOUNT_onElementDataChange( )
end
addEventHandler( "onClientResourceStart", resourceRoot, ANGELADISCOUNT_onStart )

addEvent( "onClientRefreshAngelaDiscount", true )
addEventHandler( "onClientRefreshAngelaDiscount", root, ANGELADISCOUNT_onElementDataChange )