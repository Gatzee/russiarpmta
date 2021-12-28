REGISTERED_ITEMS.car_evac = {
	rewardPlayer_func = function( player, params )
		for i = 1, params.count do
			player:GiveFreeEvacuation( 0 )
		end
	end;
	
	uiCreateProgressionRewardItem_func = function( id, params, bg, fonts )
		return ibCreateContentImage( 102, 60, 90, 90, "other", id, bg )
	end;

	uiCreateScratchItem_func = function( id, params, bg, fonts )
		ibCreateContentImage( 102, 60, 120, 120, "other", id, bg )
	end;
	
	uiGetDescriptionData_func = function( id, params )
		return {
			title = "Бесплатная эвакуация";
			description = "Позволяет бесплатно\nэвакуировать транспорт"
		}
	end;
}