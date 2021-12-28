local CASES_NAMES =
{
	"Стильный",
	"Легендарный",
	"Королевский",
}

REGISTERED_ITEMS.vinyl_case = {
	available_params = 
	{
		id = { required = true, desc = "ID кейса" },
		count = {},
		name = {},
	},

	available_content_sizes = 
	{
		{ 372, 252 },
		{ 472, 360 },
	},

	OnPreTake = function( params, OnTake )
		if params.class or params.tier then
			return true
		end

		ibConfirm( {
			title = "ПОДТВЕРЖДЕНИЕ", 
			text = "У вас сейчас нет ни одной машины,\nк которой можно было бы привязать этот кейс,\nпоэтому он будет привязан к автомобилям класса А",
			fn = function( self ) 
				self:destroy()
				OnTake( )
			end,
			escape_close = true,
		} )
	end;

	Give = function( player, params, args )
		local vinyl_case_id = VINYL_CASE_TIERS_STR_CONVERT[ "VINYL_CASE_" .. params.id .. "_" .. ( args.vehicle and args.vehicle:GetTier( ) or 1 ) ]
		player:GiveVinylCase( vinyl_case_id, params.count or 1 )
	end;

	GetAnalyticsData = function( player, params, args )
		local vinyl_case_id = VINYL_CASE_TIERS_STR_CONVERT[ "VINYL_CASE_" .. params.id .. "_" .. ( args.vehicle and args.vehicle:GetTier( ) or 1 ) ]
		local case = exports.nrp_tuning_cases:GetVinylCases( )[ vinyl_case_id ]
		local cost = case.cost
		if case.cost_is_soft then
			cost = math.floor( cost / 1000 )
		end
		return {
			cost = cost * ( params.count or 1 ),
		}
	end;
	
	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		local img = ibCreateContentImage( 0, 0, csx, csy, "case", "vinyl_" .. params.id, bg ):center()

		if ( params.count or 1 ) > 1 then
			ibCreateLabel( sx/2, sy*0.85, 0, 0, "X".. params.count, bg )
				:ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" } )
				:center_x()
		end
		
		return img
	end;

	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 0, 372, 252, "case", "vinyl_" .. params.id, bg )
			:center( )
	end;

	uiCreateCustomTake = function( params, reward_info_area, reward_item_bg, OnTake )
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
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Винил кейс \n\"" .. ( CASES_NAMES[ params.id ] or "" ) .. "\"";
		}
	end;
}