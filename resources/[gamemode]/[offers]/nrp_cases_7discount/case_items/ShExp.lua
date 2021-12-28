REGISTERED_CASE_ITEMS.exp = {
	rewardPlayer_func = function( player, params )
		player:GiveExp( params.count, "Cases" )
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		local img = ibCreateContentImage( 0, 0, 90, 90, "other", id, bg ):center( )
		ibCreateLabel( 45, 72, 0, 0, params.count, img )
			:ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )
	end;

	uiCreateRewardItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 110, 120, 120, "other", "exp", bg ):center_x( )

		ibCreateLabel( 0, 238, 0, 0, params.count, bg )
			:ibBatchData( { font = ibFonts.bold_34, align_x = "center", align_y = "top" })
			:center_x( )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Игровой опыт";
		}
	end;

	uiCreateTextureRolling = function( id, params )
		return dxCreateTexture( "img/cases/items/big/".. id ..".png" )
	end;

	uiDrawItemInRolling = function( pos_x, pos_y, texture, size_x, size_y, alpha, id, params, fonts )
		dxDrawImage( pos_x - math.floor( size_x / 2 ), pos_y - 20 - math.floor( size_y / 2 ), size_x, size_y, texture, 0, 0, 0, tocolor( 255, 255, 255, alpha ), true )
		dxDrawText( params.count, pos_x, pos_y + 45, pos_x, pos_y + 45, tocolor( 255, 255, 255, alpha ), 1, 1, ibFonts.bold_40, "center", "center", false, false, true )
	end;
}