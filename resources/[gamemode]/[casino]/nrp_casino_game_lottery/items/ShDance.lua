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

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		return ibCreateContentImage( 66, 26, 90, 90, "animation", params.id, bg )
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 66, 26, 300, 250, "animation", params.id, bg )
			:ibBatchData( { sx = 192, sy = 160 } )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Движение " .. DANCES_LIST[ params.id ].name;
		}
	end;
}