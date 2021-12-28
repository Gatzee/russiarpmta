REGISTERED_ITEMS.exp = {
	rewardPlayer_func = function( player, params )
		player:GiveExp( params.count, "lottery" )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		return ibCreateContentImage( 102, 60, 90, 90, "other", id, bg )
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 102, 60, 120, 120, "other", id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = format_price( params.count ) .. " опыта";
			img = ":nrp_shop/img/cases/items/big/".. id ..".png",
		}
	end;
}