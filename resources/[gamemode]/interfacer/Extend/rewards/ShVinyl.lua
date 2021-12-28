Import( "ShVinyls" )

REGISTERED_ITEMS.vinyl = {
	available_params = 
	{
		id = { required = true, desc = "ID" },
	},

	available_content_sizes = 
	{
		{ 90, 90 },
		{ 300, 160 },
		{ 300, 300 },
	},

	IsValid = function( self, item )
		local params = item.params or item

		if not VINYL_NAMES[ params.id ] then
			return false, "Винил с указанным ID не найден"
		end

		return true
	end,

	OnPreTake = function( params, OnTake )
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

	Give = function( player, params, args, cost )
		player:GiveVinyl( { 
			[ P_PRICE_TYPE ] = "hard",
			[ P_IMAGE ]      = params.id,
			[ P_CLASS ]      = args.vehicle and args.vehicle:GetTier( ) or 1,
			[ P_NAME ]       = VINYL_NAMES[ params.id ],
			[ P_PRICE ]      = cost,
		} )
        player:ShowInfo( "Винил успешно получен!\nТы можешь применить его в тюнинг-ателье" )
	end;
	
	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		return ibCreateContentImage( 0, 0, csx, csy, id, params.id, bg ):center( )
	end;

	uiCreateRewardItem = function( id, params, bg )
		return ibCreateContentImage( 0, 0, 300, 300, id, params.id, bg ):center( )
	end;

	uiCreateCustomTake = function( params, reward_info_area, reward_item_bg, OnTake )
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
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Винил \n\"" .. ( VINYL_NAMES[ params.id ] or "" ) .. "\"";
		}
	end;
}