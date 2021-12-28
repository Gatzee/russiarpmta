Extend( "ShVinyls" )

REGISTERED_ITEMS.vinyl = {
	uiCreateItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 90, 90, id, params.id, bg ):center( )
	end;
	
	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 300, 300, id, params.id, bg ):center( )
	end;

	uiCreateCustomTake = function( reward_info_area, reward_item_bg, OnTake )
		if not next( localPlayer:GetVehicles( nil, true, true ) ) then
			return false
		end

		reward_info_area:center( _, -100 )

		local area_list = ibCreateArea( 0, 370, 800, 290, reward_item_bg ):center_x( )
		ibCreateLabel( 0, 0, area_list:width(), 0, "Выберите транспорт, к классу которого вы хотите привязать этот винил", area_list, COLOR_WHITE, _, _, "center", _, ibFonts.bold_16 )
	
		CreateVehicleSelector( 40, area_list, true, function( selected_vehicle )
			OnTake( {
				vehicle = selected_vehicle,
			} )
		end )

		return true
	end;

	OnPreTake = function( OnTake )
		ibConfirm( {
			title = "ПОДТВЕРЖДЕНИЕ", 
			text = "У вас сейчас нет ни одной машины,\nк которой можно было бы привязать этот винил,\nпоэтому он будет привязан к автомобилям класса А",
			fn = function( self ) 
				self:destroy()
				OnTake( )
			end,
			escape_close = true,
		} )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Винил " .. ( VINYL_NAMES[ params.id ] or "" );
			description = "Винил для машины";
		}
	end;
}