REGISTERED_ITEMS.inventory_expand = {
	available_params = 
	{
		value = { desc = "Сколько кг добавляем" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
	},
	
	Give = function( player, params )
		exports.nrp_inventory:Inventory_Expand( player, params.value or 25, player )
	end;

    uiCreateItem = function( id, params, bg, sx, sy )
    	local csx, csy = GetBetterRewardContentSize( id, sx, sy )
        local img = ibCreateContentImage( 0, 0, csx, csy, "other", "inventory_player", bg ):center( )
		return img
	end;

    uiCreateRewardItem = function( id, params, bg )
        local img = ibCreateContentImage( 0, 0, 120, 120, "other", "inventory_player", bg ):center( )
		return img
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Расширение рюкзака";
			description = "Увеличивает\nразмер инвентаря"
		}
	end;
}