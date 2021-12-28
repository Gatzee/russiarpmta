REGISTERED_ITEMS.vinyl_case = {
	Give = function( player, params, vehicle )
		local vinyl_case_id = VINYL_CASE_TIERS_STR_CONVERT[ "VINYL_CASE_" .. params.id .. "_" .. ( vehicle and vehicle:GetTier( ) or 1 ) ]
		player:GiveVinylCase( vinyl_case_id, params.count or 1 )
	end;

	uiCreateCustomTake = function( reward_info_area, reward_item_bg, OnTake, params )
		-- Если кейс для определенного класса
		-- или у игрока нет машины
		if params.class or params.tier or not next( localPlayer:GetVehicles( nil, true, true ) ) then
			return false
		end

		reward_info_area:center( _, -100 )

		local area_list = ibCreateArea( 0, 370, 800, 290, reward_item_bg ):center_x( )
		ibCreateLabel( 0, 0, area_list:width(), 0, "Выберите транспорт, к классу которого вы хотите привязать этот кейс", area_list, COLOR_WHITE, _, _, "center", _, ibFonts.bold_16 )
	
		CreateVehicleSelector( 40, area_list, true, function( selected_vehicle )
			OnTake( {
				vehicle = selected_vehicle,
			} )
		end )

		return true
	end;
	
	uiCreateItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 130, 90, "case", params.id, bg ):center( )
	end;

	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 50, 372, 252, "case", params.id, bg ):center( )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Винил кейс \n\"" .. params.name .. "\"";
		}
	end;
}