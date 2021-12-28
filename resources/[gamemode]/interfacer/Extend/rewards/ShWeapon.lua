REGISTERED_ITEMS.weapon = {
	available_params = 
	{
		id = { required = true, desc = "ID" },
		ammo = { required = true, desc = "Количество патронов" },
	},

	IsValid = function( self, item )
		local params = item.params or item

		if not WEAPONS_LIST[ params.id ] then
			return false, "Оружие с указанным ID не найдено"
		end

		return true
	end,

	Give = function( player, params )
		player:InventoryAddItem( IN_WEAPON, { params.id, params.ammo }, 1 )
	end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		return ibCreateContentImage( 0, 0, csx, csy, id, params.id, bg ):center( )
	end;

	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 0, 300, 180, id, params.id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = WEAPONS_LIST[ params.id ].Name,
		}
	end;
}