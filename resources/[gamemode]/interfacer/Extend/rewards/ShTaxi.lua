REGISTERED_ITEMS.taxi = {
	available_params = 
	{
		count = { required = true, desc = "Количество" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 120, 120 },
	},

	Give = function( player, params )
		player:GiveFreeTaxiTicket( params.count )
	end;

    uiCreateItem = function( id, params, bg, sx, sy )
    	local csx, csy = GetBetterRewardContentSize( id, sx, sy )
        local img = ibCreateContentImage( 0, 0, csx, csy, "other", id, bg ):center( )
        ibCreateLabel( csx/2, csy*0.8, 0, 0,  params.count .. " шт", img )
			:ibBatchData( { font = ibFonts.bold_18, align_x = "center", align_y = "center" } )

		return img
	end;

    uiCreateRewardItem = function( id, params, bg )
        local img = ibCreateContentImage( 0, 0, 120, 120, "other", id, bg ):center( )
        ibCreateLabel( 0, 245, 0, 0, params.count .. " шт", bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Карточка на бесплатную поездку на такси",
		}
	end;
}