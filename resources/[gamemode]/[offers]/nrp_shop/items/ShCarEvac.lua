REGISTERED_ITEMS.car_evac = {
	rewardPlayer_func = function( player, params )
		for i = 1, params.count do
			player:GiveFreeEvacuation( 0 )
		end
	end;

	uiCreateItem_func = function( id, params, bg, fonts )
		local img = ibCreateContentImage( 0, 0, 90, 90, "other", id, bg ):center( )
		ibCreateLabel( 45, 72, 0, 0, "X".. params.count, img )
			:ibBatchData( { font = ibFonts.bold_16, align_x = "center", align_y = "center" } )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Бесплатная эвакуация";
			description = "Позволяет бесплатно\nэвакуировать транспорт"
		}
	end;
}