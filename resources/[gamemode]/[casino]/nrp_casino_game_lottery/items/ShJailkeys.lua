REGISTERED_ITEMS.jailkeys = {
	rewardPlayer_func = function( player, params )
		player:InventoryAddItem( IN_JAILKEYS, nil, params.count )
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		ibCreateImage( 0, 0, 96, 96, ":nrp_shop/img/cases/items/".. id ..".png", bg )
		ibCreateLabel( 0, 0, 0, 0, "X".. params.count, bg ):ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" }):center( 0, 25 )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		return ibCreateContentImage( 102, 60, 90, 90, "other", id, bg )
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 102, 60, 120, 120, "other", id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Карточка свободы";
			description = "Карточка, которая\nпозволяет выйти\nиз тюрьмы один раз"
		}
	end;
}