REGISTERED_CASE_ITEMS.taxi = {
	rewardPlayer_func = function( player, params )
		player:GiveFreeTaxiTicket( params.count )
	end;

    uiCreateItem_func = function( id, params, bg, fonts )
        local img = ibCreateContentImage( 0, 0, 90, 90, "other", id, bg ):center( )
        ibCreateLabel( 45, 72, 0, 0,  params.count .. " шт", img )
			:ibBatchData( { font = ibFonts.bold_18, align_x = "center", align_y = "center" } )
	end;

    uiCreateRewardItem_func = function( id, params, bg, fonts )
        local img = ibCreateContentImage( 0, 0, 120, 120, "other", id, bg ):center( )
        ibCreateLabel( 0, 245, 0, 0, params.count .. " шт", bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Карточка на бесплатную поездку на такси",
		}
	end;

    uiGetContentTextureRolling = function( id, params )
        return "other", id, 120, 120
	end;

	uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params, fonts )
		dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
	end;
}