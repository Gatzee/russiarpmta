REGISTERED_ITEMS.repairbox = {
	rewardPlayer_func = function( player, params )
		player:InventoryAddItem( IN_REPAIRBOX, nil, params.count )
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, "other", id, bg ):ibData( "disabled", true ):center( 0, 5 )
	end;

	uiCreateRewardItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 110, 120, 120, "other", id, bg ):center_x( )

		ibCreateLabel( 0, 238, 0, 0, "x" .. params.count, bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Ремкомплект";
			description = "Позволяет мгновенно\nвосстановить транспорт\nв дороге"
		}
	end;
}