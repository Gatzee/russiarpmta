REGISTERED_ITEMS.premium = {
	rewardPlayer_func = function( player, params )
		player:GivePremiumExpirationTime( params.days, "lottery" )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		return ibCreateContentImage( 0, 0, 90, 90, "other", id, bg ):center( 0, 15 )
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 102, 46, 120, 120, "other", id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Премиум на ".. params.days .." ".. plural( params.days, "день", "дня", "дней" ),
		}
	end;
}