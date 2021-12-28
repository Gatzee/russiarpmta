REGISTERED_ITEMS.wedding_box = {
	available_params = 
	{
		count = { required = true, desc = "Количество" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
	},

	Give = function( player, params )
		player:InventoryAddItem( IN_WEDDING_START, nil, params.count or 1 )
	end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		return ibCreateContentImage( 0, 0, csx, csy, "other", id, bg ):center( )
	end;

	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 0, 120, 120, "other", id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Свадебный набор";
		}
	end;
}