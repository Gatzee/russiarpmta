local CASES_NAMES =
{
	"Тюнинг кейс \"Базовый\"",
	"Тюнинг кейс \"Счастливчик\"",
	"Тюнинг кейс \"Фартовый\"",
	"Тюнинг кейс \"Скоростной\" удар",
	"Тюнинг кейс \"Максимальный\"",
}

REGISTERED_ITEMS.tuning_case = {
	uiCreateItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 130, 90, "case", params.id, bg ):center( )
	end;

	uiCreateCustomTake = function( reward_info_area, reward_item_bg, OnTake, params )
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
	
	uiCreateRewardItem = function( id, params, bg, fonts )
		ibCreateContentImage( 0, 0, 372, 252, "case", params.id, bg ):center( 0, 48 )
	end;
	
	uiGetDescriptionData = function( id, params )
		return {
			title = params.name or (CASES_NAMES[ params.id ] .. ( params.class and " (класс " .. params.class .. ")" or "" ));
			description = "Кейс с деталями для тюнинга машины";
		}
	end;
}