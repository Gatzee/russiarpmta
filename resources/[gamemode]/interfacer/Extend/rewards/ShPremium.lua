REGISTERED_ITEMS.premium = {
	available_params = 
	{
		days = { required = true, desc = "Количество дней" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
	},

	Give = function( player, params )
		player:GivePremiumExpirationTime( params.days )
	end;

	GetAnalyticsData = function( player, params )
		return {
			id = "prem_" .. params.days .. "d",
		}
	end;

	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		local img = ibCreateContentImage( 0, 0, csx, csy, "other", id, bg ):center( )
		ibCreateLabel( csx/2, csy*0.8, 0, 0, params.days .. " д.", img )
			:ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )
		return img
	end;

	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 110, 120, 120, "other", id, bg ):center_x( )

		ibCreateLabel( 0, 238, 0, 0, params.days .. " д.", bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Премиум"
		}
	end;
}