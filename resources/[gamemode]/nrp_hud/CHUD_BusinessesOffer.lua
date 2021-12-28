HUD_CONFIGS.businesses_offer = {
    elements = { },
    create = function( self )
        local bg = ibCreateImage( 0, 0, 340, 80, "img/bg_red_timer.png", bg )
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

        ibCreateLabel( 169, 15, 0, 0, "Скидка 25%", bg, 0xffff2b2b, _, _, "left", "top", ibFonts.bold_18 )
        ibCreateLabel( 169, 47, 0, 0, "На свободные бизнесы", bg, ibApplyAlpha( COLOR_WHITE, 85 ), _, _, "left", "top", ibFonts.regular_10 )

        function UpdateTimer( )
			local businesses_offer = localPlayer:getData( "businesses_offer" )
            local time_diff = businesses_offer.end_timestamp - getRealTimestamp( )

            if time_diff <= 0 then
                RemoveHUDBlock( "businesses_offer" )
                return
            end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
            hours = string.format( "%02d", math.min( hours, 99 ) )
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

function IsCanShowBusinessOffer()
    if not localPlayer:getData( "in_race" ) then
        return true
    end
    return false
end

function BUSINESSESOFFER_onElementDataChange( key )
    if (not key or key == "businesses_offer") and IsCanShowBusinessOffer() then
        RemoveHUDBlock( "businesses_offer" )

		local businesses_offer = localPlayer:getData( "businesses_offer" )
		if businesses_offer and businesses_offer.segment > 0 and businesses_offer.count > 0 and businesses_offer.end_timestamp > getRealTimestamp( ) then
			AddHUDBlock( "businesses_offer" )
		end
    end
end
addEventHandler( "onClientElementDataChange", localPlayer, BUSINESSESOFFER_onElementDataChange )

addEvent( "onClientRefreshBusinessOffer", true )
addEventHandler( "onClientRefreshBusinessOffer", root, BUSINESSESOFFER_onElementDataChange )

function BUSINESSESOFFER_onStart( )
    BUSINESSESOFFER_onElementDataChange( )
end
addEventHandler( "onClientResourceStart", resourceRoot, BUSINESSESOFFER_onStart )