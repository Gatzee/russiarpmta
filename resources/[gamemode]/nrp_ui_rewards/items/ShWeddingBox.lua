REGISTERED_ITEMS.wedding_box = {
	Give = function( player, params )
		player:InventoryAddItem( IN_WEDDING_START, nil, params.count or 1 )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		local bg = ibCreateImage( 0, 0, 46, 53, "img/rewards/items/".. id ..".png", bg ):center( )
		if ( params.count or 1 ) > 1 then
			bg:center( -10 )
			ibCreateLabel( 0, 0, 0, 0, "X".. params.count, bg ):ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" }):center( 0, 35 )
		end
		
		return bg
	end;

	uiCreateRewardItem = function( id, params, bg, fonts )
		local url = "img/rewards/items/big/".. id ..".png"
		ibCreateImage( 0, 0, 0, 0, url, bg ):ibSetRealSize( ):center( )
		if ( params.count or 1 ) > 1 then
			ibCreateLabel( 0, 0, 0, 0, "X".. params.count, bg ):ibBatchData( { font = ibFonts.bold_40, align_x = "center", align_y = "center" }):center( 5, 115 )
		end
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Свадебный набор";
		}
	end;
}