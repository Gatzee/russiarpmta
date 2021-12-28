Extend( "ShNeons" )

REGISTERED_ITEMS.neon = {
	rewardPlayer_func = function( player, params, cost )
		player:GiveNeon( { cost = cost, neon_image = params.id, sell_cost = math.floor( cost * 0.2 ), takeoffs_count = 0 } )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		return ibCreateContentImage( 11, 36, 90, 90, id, params.id, bg ):ibBatchData( { sx = 60, sy = 60 } ):center()
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 11, 36, 300, 160, id, params.id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Неон " .. NEONS_RU_NAMES[ params.id ];
		}
	end;
}