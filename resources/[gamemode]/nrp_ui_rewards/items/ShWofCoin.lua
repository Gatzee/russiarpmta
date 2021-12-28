REGISTERED_ITEMS.wof_coin = {
	Give = function( player, params )
		player:GiveCoins( params.count, params.type, "CASE_COINS", "NRPDszx5x" )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		local img = ibCreateContentImage( 0, 0, 90, 90, "other", "wof_coin_".. params.type, bg ):center( )
		ibCreateLabel( 45, 72, 0, 0, params.count, img )
			:ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )
	end;

	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 110, 120, 120, "other", "wof_coin_".. params.type, bg ):center_x( )

		ibCreateLabel( 0, 238, 0, 0, params.count, bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Жетон",
			description = params.type == "gold" and "Для VIP колеса фортуны" or "Для колеса фортуны",
		}
	end;
}