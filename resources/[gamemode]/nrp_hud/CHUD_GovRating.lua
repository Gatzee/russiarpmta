CURRENT_MAYOR_RATING = nil

HUD_CONFIGS.gov_rating = {
	elements = { },
	independent = true, -- Не управлять позицией худа
	create = function( self )
		local bg = ibCreateArea( 97, math.floor( y / 2 ) + 60, 206, 22 )
		self.elements.bg = bg

		ibCreateImage( 0, 0, 34, 30, "img/gov_rating_icon.png", bg )
		local progress_bg = ibCreateImage( 38, 11, 136, 16, "img/gov_rating_progress_bg.png", bg )
		self.elements.progress = ibCreateImage( 1, 1, 134, 14, _, progress_bg, 0xff7fa5d0 )

		self.elements.lbl_rating = ibCreateLabel( 182, 18, 0, 0, "100%", bg, nil, nil, nil, "left", "center", ibFonts.bold_14 ):ibData( "outline", true )

		return bg
	end,

	destroy = function( self )
		DestroyTableElements( self.elements )
		
		self.elements = { }
	end,
}

function GOV_RATING_onUpdateMayorRating_handler( rating )
	if not rating then
		RemoveHUDBlock( "gov_rating" )
		CURRENT_MAYOR_RATING = nil

		return
	end

	if not CURRENT_MAYOR_RATING then
		AddHUDBlock( "gov_rating" )
		CURRENT_MAYOR_RATING = rating
	end

	HUD_CONFIGS.gov_rating.elements.progress:ibResizeTo( 134 * ( rating / 100 ), 14, 200 )
	HUD_CONFIGS.gov_rating.elements.lbl_rating:ibData( "text", math.ceil( rating ) .."%" )
end
addEvent( "onUpdateMayorRating", true )
addEventHandler( "onUpdateMayorRating", root, GOV_RATING_onUpdateMayorRating_handler )