local ACCESSORY_IDS = { }
for id, data in pairs( CONST_ACCESSORIES_INFO ) do
	ACCESSORY_IDS[ data.model ] = id
end

REGISTERED_CASE_ITEMS.accessory = {
	rewardPlayer_func = function( player, params )
		player:AddOwnedAccessory( ACCESSORY_IDS[ params.model ] )
	end;

	checkHasItem_func = function( player, params )
		return player:GetOwnedAccessories( )[ ACCESSORY_IDS[ params.model ] ]
	end;

	isExchangeAvailable_func = function( player, params )
		return player:GetOwnedAccessories( )[ ACCESSORY_IDS[ params.model ] ]
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, id, ACCESSORY_IDS[ params.model ], bg ):center( )
	end;
	
	uiCreateRewardItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 300, 180, id, ACCESSORY_IDS[ params.model ], bg ):center( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = CONST_ACCESSORIES_INFO[ ACCESSORY_IDS[ params.model ] ].name;
			description = "Аксессуар.\nСтановится доступен\nв гардеробе"
		}
	end;

	uiGetContentTextureRolling = function( id, params )
		return id, ACCESSORY_IDS[ params.model ], 300, 180
	end;

	uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params )
		dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
	end;
}