local CASES_NAMES =
{
	"Базовый",
	"Счастливчик",
	"Фартовый",
	"Скоростной удар",
	"Максимальный",
}

local VEHICLE_CLASS_TO_TIER = { }
for tier, class in pairs( VEHICLE_CLASSES_NAMES ) do
	VEHICLE_CLASS_TO_TIER[ class ] = tier
end

REGISTERED_ITEMS.tuning_case = {
	available_params = 
	{
		id = { required = true, desc = "ID кейса" },
		count = {},
		subtype = {},
		class = { desc = "Класс автомобилей кейса (игнорирует окно ручного выбора игроком)" },
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
		local args = args or { }

		local tier = VEHICLE_CLASS_TO_TIER[ params.class ] or params.tier or ( args.vehicle and args.vehicle:GetTier( ) ) or 1
		if tier == 6 then
			args.subtype = nil
		end
		player:GiveTuningCase( params.id, tier, params.subtype or args.subtype or INTERNAL_PART_TYPE_R, params.count or 1 )
	end;

	GetAnalyticsData = function( player, params, args )
		local args = args or { }

		local case_cost, is_soft = exports.nrp_tuning_cases:getCaseCost( params.id, ( args.vehicle and args.vehicle:GetTier( ) ) or 1 )
		if is_soft then
			case_cost = math.floor( case_cost / 1000 )
		end
		return {
			cost = case_cost * ( params.count or 1 ),
		}
	end;
	
	uiCreateItem = function( id, params, bg, sx, sy )
		local csx, csy = GetBetterRewardContentSize( id, sx, sy )
		local img = ibCreateContentImage( 0, 0, csx, csy, "case", "tuning_" .. params.id, bg ):center( )
			:center( )

		if ( params.count or 1 ) > 1 then
			ibCreateLabel( sx/2, sy*0.85, 0, 0, "X".. params.count, bg )
				:ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" } )
		end

		return img
	end;

	uiCreateRewardItem = function( id, params, bg )
		ibCreateContentImage( 0, 0, 372, 252, "case", "tuning_" .. params.id, bg )
			:center( )
	end;

	uiCreateCustomTake = function( params, reward_info_area, reward_item_bg, OnTake )
		-- Если кейс для определенного класса
		-- или у игрока нет машины
		if params.class or params.tier or not next( localPlayer:GetVehicles( nil, true, true ) ) then
			return false
		end

		reward_info_area:center( _, -150 )

		ibCreateLabel( 0, 345, reward_item_bg:width( ), 0, "Выберите тип тюнинг-кейса", reward_item_bg, 0xffffffff, _, _, "center", "top", ibFonts.bold_16 )
        local area_type_btns = ibCreateArea( 0, 380, 0, 0, reward_item_bg )
			local selected_case_type = 1
			local bg_selected_btn = ibCreateImage( -5, -5, 97, 52, ":nrp_shared/img/btn_type_selected.png" )
			for case_type, name in ipairs( INTERNAL_PARTS_NAMES_TYPES ) do
				local btn = ibCreateButton( ( 87 + 10 ) * ( case_type - 1 ), 0, 87, 42, area_type_btns, 
						":nrp_shared/img/btn_type.png", _, _, ibApplyAlpha( 0xFFFFFFFF, 75 ), 0xFFFFFFFF, 0xFFAAAAAA )
					:ibOnClick( function( key, state )
						if key ~= "left" or state ~= "up" then return end
						ibClick( )
						bg_selected_btn.parent = source
						selected_case_type = case_type 
					end )

				if case_type == 1 then
					bg_selected_btn.parent = btn
				end

				ibCreateLabel( 0, 0, 87, 42, "Type " .. name, btn, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
					:ibData( "disabled", true )
			end
        area_type_btns:ibData( "sx", ( 87 + 10 ) * #INTERNAL_PARTS_NAMES_TYPES - 10 ):center_x( )


		local area_list = ibCreateArea( 0, 70, 800, 290, area_type_btns ):center_x( )
		ibCreateLabel( 0, 0, area_list:width(), 0, "Выберите транспорт, к классу которого вы хотите привязать этот кейс", area_list, COLOR_WHITE, _, _, "center", _, ibFonts.bold_16 )
	
		CreateVehicleSelector( 40, area_list, true, function( selected_vehicle )
			if selected_vehicle:GetTier( ) == 6 and selected_case_type > 1 then
				ibConfirm( {
					title = "ПОДТВЕРЖДЕНИЕ", 
					text = "Для мотоциклов доступны только тюнинг-кейсы type R",
					fn = function( self ) 
						self:destroy()
						OnTake( {
							vehicle = selected_vehicle,
						} )
					end,
					escape_close = true,
				} )
			else
				OnTake( {
					vehicle = selected_vehicle,
					subtype = selected_case_type,
				} )
			end
		end )

		return true
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = "Тюнинг-кейс \n\"" .. ( CASES_NAMES[ params.id ] or "" ) .. "\"";
			description = "Кейс с деталями для тюнинга машины";
		}
	end;
}
