HUD_CONFIGS["7cases"] = {
    elements = { },
    order = 950,
    create = function( self, time_left )
        local pDiscountData

        local resource = getResourceFromName( "nrp_cases_7discount" )
        if resource and getResourceState( resource ) == "running" then
            pDiscountData = exports.nrp_cases_7discount:Get7CasesDiscountData() 
        end

        if not pDiscountData then return end

        self.discount_data = pDiscountData

        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_7cases.png", bg )
        self.elements.bg = bg

        self.elements.overlay = ibCreateImage( 0, 0, 352, 85, "img/7cases_overlay.png", bg ):center( )

        local positions = {
            { 27, 40 },
            { 52, 40 },
            { 96, 40 },
            { 123, 40 },
        }

        for i, v in pairs( positions ) do
            local lbl = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "", bg, 0xffffffff, _, _, "center", "center", ibFonts.regular_26 )
            self.elements[ "lbl_symbol_" .. i ] = lbl
        end

        local function UpdateTimer( )
            local time_diff = self.discount_data.finish_ts - getRealTimestamp()

            if time_diff < 0 then RemoveHUDBlock( "7cases" ) return end

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

        self.elements.timer = setTimer( UpdateTimer, 30000, 0 )
        UpdateTimer( )

        self.overlay_state = false

        local function BlinkOverlay()
            self.overlay_state = not self.overlay_state
            self.elements.overlay:ibAlphaTo( self.overlay_state and 255*0.25 or 255, 1000, "InOutQuad" )
        end

        self.elements.blink_timer = setTimer( BlinkOverlay, 1000, 0 )
        BlinkOverlay()

        unbindKey( "f4", "up", ToggleBlinking )
        bindKey( "f4", "up", ToggleBlinking )

        return bg
    end,

    destroy = function( self )
        unbindKey( "f4", "up", ToggleBlinking )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function ToggleBlinking()
    local self = HUD_CONFIGS["7cases"]

    if isTimer( self.elements.blink_timer ) then
        killTimer( self.elements.blink_timer )
    end

    if not isElement( self.elements.overlay ) then return end

    self.elements.overlay:ibAlphaTo( 0, 0 )

    unbindKey( "f4", "up", ToggleBlinking )
end

addEventHandler( "onClientElementDataChange", localPlayer, function( key, old, value )
    if key == "7cases_discounts" then
        if value then
            AddHUDBlock( "7cases" )
        else
            RemoveHUDBlock( "7cases" )
        end
    end
end )

function onRefreshCasesDiscount()
    if getElementData( localPlayer, "7cases_discounts" ) then
        AddHUDBlock( "7cases" )
    else
        RemoveHUDBlock( "7cases" )
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, onRefreshCasesDiscount )