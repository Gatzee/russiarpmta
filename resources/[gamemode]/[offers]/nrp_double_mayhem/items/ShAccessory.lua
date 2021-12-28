local ACCESSORY_IDS = { }
for id, data in pairs( CONST_ACCESSORIES_INFO ) do
	ACCESSORY_IDS[ data.model ] = id
end

REGISTERED_ITEMS.accessory = {
	rewardPlayer_func = function( player, params )
		player:AddOwnedAccessory( ACCESSORY_IDS[ params.model ] )
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, id, ACCESSORY_IDS[ params.model ], bg ):ibData( "disabled", true ):center( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = CONST_ACCESSORIES_INFO[ ACCESSORY_IDS[ params.model ] ].name;
			description = "Аксессуар.\nСтановится доступен\nв гардеробе"
		}
	end;
}