HUD_CONFIGS.cases_discounts = {
    elements = { },
    order = 950,
    create = function( self, time_left )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_cases_discount.png", bg )
        self.elements.bg = bg

        local positions = {
            { 33, 40 },
            { 60, 40 },
            { 106, 40 },
            { 135, 40 },
        }

        for i, v in pairs( positions ) do
            local lbl = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "", bg, 0xffffffff, _, _, "center", "center", ibFonts.regular_26 )
            self.elements[ "lbl_symbol_" .. i ] = lbl
        end

        function UpdateTimer( )
            local time_diff = localPlayer:GetCasesDiscountTimeleft( )

            if time_diff < 0 then RemoveHUDBlock( "cases_discounts" ) return end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
            hours = string.format( "%02d", hours )
            minutes = string.format( "%02d", minutes )

            local str = hours .. minutes
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

addEventHandler( "onClientElementDataChange", localPlayer, function( key, old, value )
    if key == "cases_discounts" then
        if value then
            AddHUDBlock( "cases_discounts" )
        else
            RemoveHUDBlock( "cases_discounts" )
        end
    end
end )

function onRefreshCasesDiscount()
    if getElementData( localPlayer, "cases_discounts" ) then
        AddHUDBlock( "cases_discounts" )
    else
        RemoveHUDBlock( "cases_discounts" )
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, onRefreshCasesDiscount )

addEvent( "onClientonRefreshCasesDiscount", true )
addEventHandler( "onClientonRefreshCasesDiscount", root, onRefreshCasesDiscount )

addEvent( "onClientPlayerNRPSpawn", true )
addEventHandler( "onClientPlayerNRPSpawn", root, function( spawn_mode )
    if spawn_mode == 3 then return end
    onRefreshCasesDiscount()
end )
