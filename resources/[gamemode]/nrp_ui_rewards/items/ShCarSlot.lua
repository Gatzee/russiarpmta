REGISTERED_ITEMS.car_slot = {
	Give = function( player, params )
		local bought_slots = player:GetPermanentData( "car_slots" ) or 0
		bought_slots = bought_slots + ( params.count or 1 )
		player:SetPermanentData( "car_slots", bought_slots )
	end;

	uiCreateItem = function( id, params, bg, fonts )
		local bg = ibCreateImage( 0, 0, 70, 36, "img/rewards/items/".. id ..".png", bg ):center( )
		if ( params.count or 1 ) > 1 then
			bg:center( 0, -10 )
			ibCreateLabel( 0, 0, 0, 0, "X".. params.count, bg )
				:ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" } )
				:center( 0, 35 )
		end
		return bg
	end;

	uiCreateRewardItem = function( id, params, bg, fonts )
		local url = "img/rewards/items/big/".. id ..".png"
		ibCreateImage( 0, 0, 0, 0, url, bg ):ibSetRealSize( ):center( )
		if ( params.count or 1 ) > 1 then
			ibCreateLabel( 0, 0, 0, 0, "X".. params.count, bg ):ibBatchData( { font = ibFonts.bold_40, align_x = "center", align_y = "center" }):center( 5, 115 )
		end
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Слот для транспорта";
			description = "Увеличивает\nвместимость гаража"
		}
	end;
}