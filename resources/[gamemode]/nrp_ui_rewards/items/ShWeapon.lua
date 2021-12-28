REGISTERED_ITEMS.weapon = {
	Give = function( player, params )
		player:InventoryAddItem( IN_WEAPON, { params.id, params.ammo }, 1 )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, id, params.id, bg ):center( )
	end;

	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 300, 180, id, params.id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = WEAPONS_LIST[ params.id ].Name,
		}
	end;
}