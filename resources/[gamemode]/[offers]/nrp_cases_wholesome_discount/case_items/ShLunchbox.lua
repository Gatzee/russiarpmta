REGISTERED_CASE_ITEMS.lunchbox = {
	rewardPlayer_func = function( player, params )
		player:InventoryAddNode( IN_FOOD, nil, params.count )
	end;

	uiCreateRewardItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 110, 120, 120, "other", id, bg ):center_x( )

		ibCreateLabel( 0, 238, 0, 0, "x" .. params.count, bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Ланч";
		}
	end;
}