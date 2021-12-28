REGISTERED_ITEMS.vinyl_case = {
    rewardPlayer_func = function( player, params, cost, data )
		local vinyl_case_id = VINYL_CASE_TIERS_STR_CONVERT[ "VINYL_CASE_" .. params.id .. "_" .. ( data and isElement( data.vehicle ) and data.vehicle:GetTier( ) or 1 ) ]
		player:GiveVinylCase( vinyl_case_id, params.count or 1 )

		player:ShowInfo( "Винил кейс успешно получен!\nТы можешь применить его в тюнинг-ателье" )
	end;

	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		local content_img = ibCreateContentImage( 0, 35, 130, 90, "case", "vinyl_" .. params.id, bg )
		content_img:ibBatchData( { sx = 91, sy = 63 } ):center_x()
		return content_img
	end;
	
	uiCreateScratchItem_func = function( id, params, bg, fonts )
        ibCreateContentImage( -18, -25, 360, 280, "case", "vinyl_" .. params.id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = params.name or "Винили кейс";
		}
	end;
}