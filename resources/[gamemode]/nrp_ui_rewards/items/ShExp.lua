REGISTERED_ITEMS.exp = {
	Give = function( player, params )
		player:GiveExp( params.count, "Cases" )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		local img = ibCreateContentImage( 0, 0, 90, 90, "other", id, bg ):center( )
		ibCreateLabel( 45, 72, 0, 0, params.count, img )
			:ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )
	end;

	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 110, 120, 120, "other", "exp", bg ):center_x( )

		ibCreateLabel( 0, 238, 0, 0, params.count, bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Игровой опыт";
		}
	end;
}