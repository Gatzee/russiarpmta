HUD_CONFIGS.timer = {
    elements = { },
    independent = true, -- Не управлять позицией худа
    create = function( self )
        local x, y = guiGetScreenSize( )

        local bg = ibCreateArea( 20, y - ( IsHUDBlockActive( "wanted" ) and 400 or 340 ), 0, 0 )

        ibUseRealFonts( true )

		local data = getElementData( localPlayer, "hud_timer_data" )
		if data.text then
			ibCreateLabel( 0, 0, 0, 0, data.text, bg, data.text_color or 0xffff6363, _, _, "left", "center", ibFonts.regular_14 ):ibData( "outline", 1 )
		end

		local s = math.abs( getRealTimestamp( ) - data.timestamp )
		local h = math.floor( s / 60 / 60 )
		local m = math.floor( s / 60 - h * 60 )
		local s = math.floor( s - m * 60 - h * 60 * 60 )

        ibCreateImage( 0, 15, 30, 32, ":nrp_shared/img/icon_timer.png", bg )
		ibCreateLabel( 40, 31, 0, 0, ( "%02d:%02d:%02d" ):format( h, m, s ), bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_21 ):ibData( "outline", 1 )
			:ibTimer( function( self )
				local data = getElementData( localPlayer, "hud_timer_data" )
				if data then
					local s = math.abs( getRealTimestamp( ) - data.timestamp )
					local h = math.floor( s / 60 / 60 )
					local m = math.floor( s / 60 - h * 60 )
					local s = math.floor( s - m * 60 - h * 60 * 60 )
					self:ibData( "text", ( "%02d:%02d:%02d" ):format( h, m, s ) )
				end
			end, 1000, 0 )

        ibUseRealFonts( false )

        table.insert( self.elements, bg )
        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements )
        
        self.elements = { }
    end,
}

function CheckTimer_handler( key, _, value )
    if not key or key == "hud_timer_data" then
        RemoveHUDBlock( "timer" )

		if value then
            AddHUDBlock( "timer" )
		end
	end
end
addEventHandler( "onClientElementDataChange", localPlayer, CheckTimer_handler )

function Timer_onStart( )
    CheckTimer_handler( )
end
addEventHandler( "onClientResourceStart", resourceRoot, Timer_onStart )