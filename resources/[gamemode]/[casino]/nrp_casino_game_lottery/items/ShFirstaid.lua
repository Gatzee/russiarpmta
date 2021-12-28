REGISTERED_ITEMS.firstaid = {
	rewardPlayer_func = function( player, params )
		player:InventoryAddItem( IN_FIRSTAID, nil, params.count )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		return ibCreateContentImage( 102, 60, 90, 90, "other", id, bg )
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 102, 60, 120, 120, "other", id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Аптечка";
			description = "Восстанавливает\nполовину твоего\nздоровья"
		}
	end;
}