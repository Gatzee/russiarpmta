REGISTERED_ITEMS.offer_hard = {
	Give = function( player, params )
		GiveHardOffer( player )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		return ibCreateImage( 0, 0, 128, 128, "offer_hard/img/icon.png", bg ):center()
	end;

	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateImage( 0, 0, 512, 512, "offer_hard/img/icon.png", bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Майский пак валюты\n(50% скидка)",
			-- description = "(50% скидка)",
		}
	end;
}