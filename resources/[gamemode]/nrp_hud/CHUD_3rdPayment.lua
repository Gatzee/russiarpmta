HUD_CONFIGS.offer_3rdPayment = {
    elements = { },
    order = 950,
    create = function( self, time_left )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_unique.png", bg )
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

        local tick = getTickCount( )
        function UpdateTimer( )
            local passed = getTickCount( ) - tick
            local time_diff = math.ceil( time_left - passed / 1000 )

            if time_diff < 0 then return end

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
        localPlayer:setData( "offer_3rd_payment_timeleft", time_left, false )

        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function Show3rdPaymentInfo_handler( time_left )
    if not time_left then
        time_left = localPlayer:getData( "offer_3rd_payment_timeleft" )
    end
    if time_left then
        AddHUDBlock( "offer_3rdPayment", time_left )
    end
end
addEvent( "Show3rdPaymentInfo", true )
addEventHandler( "Show3rdPaymentInfo", root, Show3rdPaymentInfo_handler )

function Hide3rdPaymentInfo_handler( )
    RemoveHUDBlock( "offer_3rdPayment" )
end
addEvent( "Hide3rdPaymentInfo", true )
addEventHandler( "Hide3rdPaymentInfo", root, Hide3rdPaymentInfo_handler )