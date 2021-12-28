Extend( "ShDances" )

REGISTERED_ITEMS.dance = {
	Give = function( player, params )
		player:AddDance( params.id )
	end;

	checkHasItem = function( player, params )
		return player:HasDance( params.id )
	end;

	isExchangeAvailable = function( player, params )
		return player:HasDance( params.id )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, "animation", params.id, bg ):center( )
	end;
	
	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 300, 250, "animation", params.id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = DANCES_LIST[ params.id ].name;
			description = "Движение.\nСтановится доступным\nв школе танцев"
		}
	end;
}