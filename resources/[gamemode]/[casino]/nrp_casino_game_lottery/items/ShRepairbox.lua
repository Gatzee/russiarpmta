REGISTERED_ITEMS.repairbox = {
	rewardPlayer_func = function( player, params )
		player:InventoryAddItem( IN_REPAIRBOX, nil, params.count )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		return ibCreateContentImage( 0, 0, 90, 90, "other", id, bg ):center(0, 15)
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 102, 60, 120, 120, "other", id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Ремкомплект";
			description = "Позволяет мгновенно\nвосстановить транспорт\nв дороге"
		}
	end;
}