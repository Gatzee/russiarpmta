REGISTERED_CASE_ITEMS.weapon = {
	rewardPlayer_func = function( player, params )
		player:InventoryAddItem( IN_WEAPON, { params.id, params.ammo }, 1 )
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, id, params.id, bg ):center( )
	end;

	uiCreateRewardItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 300, 180, id, params.id, bg ):center( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = WEAPONS_LIST[ params.id ].Name,
		}
	end;

	uiGetContentTextureRolling = function( id, params )
		return id, params.id, 300, 180
	end;

	uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params, fonts )
		dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
	end;
}