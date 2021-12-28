Extend( "ShNeons" )

REGISTERED_ITEMS.neon = {
	Give = function( player, params, cost )
		player:GiveNeon( { cost = cost * 1000, neon_image = params.id, sell_cost = math.floor( ( cost * 1000 ) * 0.2 ), takeoffs_count = 0 } )
	end;
	
	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 300, 160, id, params.id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Неон " .. NEONS_RU_NAMES[ params.id ];
		}
	end;
}