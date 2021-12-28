REGISTERED_ITEMS.wof_coin = {
	rewardPlayer_func = function( player, params )
		player:GiveCoins( params.count, params.type, "LOTTERY", "NRPDszx5x" )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		local content_img = ibCreateContentImage( 19, 28, 90, 90, "other", "wof_coin_".. params.type, bg ):center_x()
		ibCreateLabel( 0, 52, 90, 0, format_price( params.count ), content_img, COLOR_WHITE, 1, 1, "center", "top", ibFonts.oxaniumbold_18 )
		return content_img
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 102, 46, 120, 120, "other", "wof_coin_".. params.type, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Жетон " .. ( params.type == "gold" and "для VIP колеса фортуны" or "для колеса фортуны" ),
		}
	end;
}