REGISTERED_ITEMS.case = {
	rewardPlayer_func = function( player, params )
		player:GiveCase( params.id, params.count or 1 )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		local content_img = ibCreateContentImage( 0, 35, 130, 90, "case", params.id, bg )
		content_img:ibBatchData( { sx = 91, sy = 63 } ):center_x()
		return content_img
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( -18, -25, 360, 280, "case", params.id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = params.name or "Кейс";
		}
	end;
}