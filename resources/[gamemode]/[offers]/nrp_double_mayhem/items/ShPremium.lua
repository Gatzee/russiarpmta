REGISTERED_ITEMS.premium = {
	rewardPlayer_func = function( player, params )
		player:GivePremiumExpirationTime( params.days, "Cases" )
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, "other", id, bg ):ibData( "disabled", true ):center( )
	end;

	uiCreateRewardItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 110, 120, 120, "other", id, bg ):center_x( )

		ibCreateLabel( 0, 238, 0, 0, params.days .. " д.", bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Премиум на ".. params.days .." ".. plural( params.days, "день", "дня", "дней" )
		}
	end;
}