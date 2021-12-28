Extend( "ShDances" )

REGISTERED_ITEMS.dance = {
	rewardPlayer_func = function( player, params )
		player:AddDance( params.id )
	end;

	checkHasItem_func = function( player, params )
		return player:HasDance( params.id )
	end;

	isExchangeAvailable_func = function( player, params )
		return player:HasDance( params.id )
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, "animation", params.id, bg ):center( )
	end;
	
	uiCreateRewardItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 300, 250, "animation", params.id, bg ):center( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = DANCES_LIST[ params.id ].name;
			description = "Движение.\nСтановится доступным\nв школе танцев"
		}
	end;

	uiGetContentTextureRolling = function( id, params )
		return "animation", params.id, 300, 250
	end;

	uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params )
		dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
	end;

	checkHasItem_func = function( player, params )
		return player:HasDance( params.id )
	end;

	isExchangeAvailable_func = function( player, params )
		return player:HasDance( params.id )
	end;
}