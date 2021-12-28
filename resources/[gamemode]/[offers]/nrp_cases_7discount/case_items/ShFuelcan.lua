REGISTERED_CASE_ITEMS.fuelcan = {
	rewardPlayer_func = function( player, params )
		player:InventoryAddItem( IN_CANISTER, nil, params.count )
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
        local img = ibCreateContentImage( 0, 0, 90, 90, "other", id, bg ):center( )
        ibCreateLabel( 45, 72, 0, 0,  params.count .. " шт", img )
			:ibBatchData( { font = ibFonts.bold_18, align_x = "center", align_y = "center" } )
	end;

	uiCreateRewardItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 110, 120, 120, "other", id, bg ):center_x( )

		ibCreateLabel( 0, 238, 0, 0, "x" .. params.count, bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Канистру бензина";
		}
	end;
}