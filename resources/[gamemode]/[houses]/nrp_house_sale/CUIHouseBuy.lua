UIe = {}

local SALE_HOUSE_LIST = {}
local ATTEMPT_COUNT = 0
local IS_DATA_RECEIVED = false

DEFAULT_MIN_COST = 1000000
DEFAULT_MAX_COST = 150000000
FILTER_MIN_COST = DEFAULT_MIN_COST
FILTER_MAX_COST = DEFAULT_MAX_COST

CONST_LOCATION_INFO_SORTED = {}
for k, v in pairs( CONST_LOCATION_INFO ) do
	table.insert( CONST_LOCATION_INFO_SORTED, v )
end
table.sort( CONST_LOCATION_INFO_SORTED, function(a, b) return a.name < b.name end)

local function CreateRangeSlider( px, py, parent)
	local range_slider = ibCreateDummy( parent )

	local lower_value_label = ibCreateLabel( 10, 0, 0, 0, format_price( FILTER_MIN_COST ), range_slider, 0xFFDBDEE1, 1, 1, "left", "center", ibFonts.bold_16 )
	local money_icon_1 = ibCreateImage( lower_value_label:ibGetAfterX( 7 ), 0, 20, 20, ":nrp_shared/img/money_icon.png", range_slider ):ibData( "disabled", true ):center_y( )

	local upper_group = ibCreateDummy( range_slider )
	local upper_value_label = ibCreateLabel( 10, 0, 0, 0, format_price( FILTER_MAX_COST ), upper_group, 0xFFDBDEE1, 1, 1, "left", "center", ibFonts.bold_16 )
	local money_icon_2 = ibCreateImage( upper_value_label:ibGetAfterX( 7 ), 0, 20, 20, ":nrp_shared/img/money_icon.png", upper_group ):ibData( "disabled", true ):center_y( )
	upper_group
		:ibData( "sx", money_icon_2:ibGetAfterX( ) )
		:ibData( "px", parent:width( ) - upper_group:width( ) - 10 )
		:center_y( )

	local function update_values( )
		lower_value_label:ibData( "text", format_price( FILTER_MIN_COST ) )
		money_icon_1:ibData( "px", lower_value_label:ibGetAfterX( 7 ) )

        -- пересчет габаритов элементов upper_group
        upper_value_label:ibData( "text", format_price( FILTER_MAX_COST ) )
		money_icon_2:ibData( "px", upper_value_label:ibGetAfterX( 7 ) )
		upper_group
			:ibData( "sx", money_icon_2:ibGetAfterX( ) )
			:ibData( "px", parent:width( ) - upper_group:width( ) - 10 )
	end

	local start_pos_px = upper_group:width( ) + 5
	local end_pos_px = upper_group:ibGetBeforeX( -5 )
	local diff = end_pos_px - start_pos_px

	local range_path_bg = ibCreateLine( start_pos_px, 0, end_pos_px, 0, ibApplyAlpha( COLOR_WHITE, 80 ), 1, range_slider ):ibData("priority", 10)
    local active_range_path = ibCreateLine( start_pos_px, 0, end_pos_px, 0, ibApplyAlpha( 0xFFC88564, 70 ), 4, range_slider ):ibData("priority", 10)

	local lower_scrollbar = ibScrollbarH( { px = start_pos_px, py = 0, handle_texture="images/roller.png", handle_sx=12, handle_sy=12, handle_px = 0, handle_py = -6, handle_lower_limit=0, handle_upper_limit=diff, parent=range_slider } )
	local upper_scrollbar = ibScrollbarH( { px = end_pos_px, py = 0, handle_texture="images/roller.png", handle_sx=12, handle_sy=12, handle_px = 0, handle_py = -6, handle_lower_limit=-diff, handle_upper_limit=0, parent=range_slider} )

	local lower_handle = lower_scrollbar:ibData( "handle" )
	local upper_handle = upper_scrollbar:ibData( "handle" )

	lower_handle:ibOnClick(function(button, state)
		if button ~= "left" or state ~= "up" then return end
		ibClick()
		UpdateSaleArea( )
	end)

	upper_handle:ibOnClick(function(button, state)
		if button ~= "left" or state ~= "up" then return end
		ibClick()
		UpdateSaleArea( )
	end)

	local function external_refresh_range_slider( )
		update_values( )

		-- подгонка размеров дорожек ползунков
		start_pos_px = upper_group:width( ) + 5
		end_pos_px = upper_group:ibGetBeforeX( -5 )
		diff = end_pos_px - start_pos_px

		range_path_bg:ibData( "px", start_pos_px + 5 )
		range_path_bg:ibData( "target_px", end_pos_px + 5 )
		active_range_path:ibData( "px", start_pos_px + 5 )
		active_range_path:ibData( "target_px", end_pos_px + 5 )

		-- смена старт позиций
		lower_scrollbar:ibData( "px", start_pos_px )
		upper_scrollbar:ibData( "px", end_pos_px )
		lower_handle:ibData( "handle_upper_limit", diff )
		upper_handle:ibData( "handle_lower_limit", -diff )

		-- сброс позиций ползунков
		local handle_offset = lower_handle:ibData( "original_px" ) or 0
		local x_min = handle_offset + lower_handle:ibData( "lower_limit" ) or 0
		lower_handle:ibData( "px", x_min )
		upper_handle:ibData( "px", x_min )
	end

    addEventHandler( "ibOnElementDataChange", lower_scrollbar, function( key, value, old )
		if key == "position" then
			if key == "position" then
				local upper_handle_px = upper_handle:ibData( "px" )

				local handle_offset = lower_handle:ibData( "original_px" ) or 0
				local x_min = handle_offset + lower_handle:ibData( "lower_limit" ) or 0
				local x_max = lower_scrollbar:ibData( "sx" ) + handle_offset + lower_handle:ibData( "upper_limit" ) or 0

				local x_constrain = ( x_max + upper_handle_px ) > x_min and ( x_max + upper_handle_px ) or x_max

				local x_new = value and ( x_min + ( x_max - x_min ) * value ) or lower_handle:ibData( "px" ) or 0
				x_new = x_new > x_max and x_max or x_new < x_min and x_min or x_new > x_constrain and x_constrain or x_new

				lower_handle:ibData( "px", x_new )
				active_range_path:ibData( "px", start_pos_px + x_new )

				FILTER_MIN_COST = ( x_new - x_min ) / ( x_max - x_min ) * ( DEFAULT_MAX_COST - DEFAULT_MIN_COST ) + DEFAULT_MIN_COST
				update_values( )
        	end
		end
    end, true, "low-10000000" )

	addEventHandler( "ibOnElementDataChange", upper_scrollbar, function( key, value, old )
        if key == "position" then
			local lower_handle_px = lower_handle:ibData( "px" )

			local handle_offset = upper_handle:ibData( "original_px" ) or 0
			local x_min = handle_offset + upper_handle:ibData( "lower_limit" ) or 0
			local x_max = upper_scrollbar:ibData( "sx" ) + handle_offset + upper_handle:ibData( "upper_limit" ) or 0

			local x_constrain = ( x_min + lower_handle_px ) > x_min and ( x_min + lower_handle_px ) or x_min

			local x_new = value and ( x_min + ( x_max - x_min ) * value ) or upper_handle:ibData( "px" ) or 0
			x_new = x_new > x_max and x_max or x_new < x_min and x_min or x_new < x_constrain and x_constrain or x_new

			upper_handle:ibData( "px", x_new )
			active_range_path:ibData( "target_px", end_pos_px + x_new )

			FILTER_MAX_COST = ( x_new - x_min ) / ( x_max - x_min ) * ( DEFAULT_MAX_COST - DEFAULT_MIN_COST ) + DEFAULT_MIN_COST
			update_values( )
        end
    end, true, "low-10000000" )

	range_slider:center_y( )

	UIe.RangeSlider = range_slider
	UIe.RefreshRangeSlider = external_refresh_range_slider
end

local function UpdateBalanceArea( )
	UIe.balance_amount_label:ibData( "text", format_price( localPlayer:GetMoney( ) ) )
	UIe.money_icon:ibData( "px",  UIe.balance_amount_label:ibGetAfterX( 10 ) )
	UIe.person_area:ibData( "px", UIe.close_btn:ibGetBeforeX( -25 ) - UIe.money_icon:ibGetAfterX( ) )
end

local function ShowDropdown( bState, pParent, pOptionsData, pChoosedOption, pLabel )

	if bState then
		ShowDropdown( false )

		UIe.dropdown = ibCreateArea( 0, pParent:height(), 0, 0, pParent )

		local i = 1
		for k, option in pairs( pOptionsData ) do
			local mark, mark2
        	local option_btn = ibCreateButton( 0, ( i - 1 ) * 48, pParent:width( ), 48, UIe.dropdown, 0xFF66809D, 0xFF66809D, _, option.value == pChoosedOption.value and 0xFF768DA7 or 0xFF66809D, 0xFF768DA7, 0xFF6F839B )
				:ibOnHover( function( button, state ) mark:ibData( "alpha", 100 ); mark2:ibData( "alpha", 100 )  end)
				:ibOnLeave( function( button, state ) mark:ibData( "alpha", 0 ); mark2:ibData( "alpha", 0 )  end)
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "up" then return end
			    	ibClick( )

					-- выбранный тип дома / локации
					pChoosedOption.value = option.value
					ShowDropdown( false )

					if isElement( pLabel ) then
						pLabel:ibData( "text", option.name )
					end

                    SALE_HOUSE_LIST = {}
					IS_DATA_RECEIVED = false
                    UpdateSaleArea( )

					UIe.RefreshRangeSlider( )
				end )
			ibCreateLabel( 18, 0, option_btn:width( )-18, option_btn:height( ), option.name, option_btn, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_12 ):ibData( "disabled", true )
			mark = ibCreateLine( option_btn:width( ) - 4, option_btn:height()/2 - 6 , option_btn:width( )-4, option_btn:height()/2 + 10, 0xFFFF965D, 4, option_btn ):ibData( "alpha", 0 )
			mark2 = ibCreateLine( option_btn:width( ) - 4, option_btn:height()/2 - 6 , option_btn:width( )-4, option_btn:height()/2 + 10, 0xFFFF965D, 4, option_btn ):ibData( "alpha", 0 )
			if i ~= 1 then
				ibCreateLine( 0, ( i - 1 ) * 48 - 1 , pParent:width( ), _, 0xFF5C738D, 1, UIe.dropdown )
			end

			i = i + 1
		end
	else
		if isElement( UIe.dropdown ) then destroyElement( UIe.dropdown ) end
	end
end


local function CreateOfferCard ( px, py, pData, parent )

	local location_name, house_name, house_image_path, inventory_max_weight = GetHouseHumanViewData( pData )
	inventory_max_weight = pData.inventory_max_weight or inventory_max_weight

	local card_bg = ibCreateImage( px, py, 964, 250, _, parent, ibApplyAlpha( COLOR_BLACK, 10 ) )
	local card_bg_ = ibCreateImage( px, py, 964, 250, "images/offer_card_bg.png", parent ):ibData( "disabled", true )

	local house_logo_area = ibCreateArea( 0,0, 292, 0, card_bg )
	local house_name_label = ibCreateLabel( 0, 0, house_logo_area:width( ), 0, house_name, house_logo_area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.regular_16 )
	local house_image = ibCreateImage( 0, house_name_label:ibGetAfterY( 24 ), 0, 0, "images/" .. house_image_path, house_logo_area )
		:ibSetRealSize( ):center_x( )
	house_logo_area:ibData( "sy", house_image:ibGetAfterY( ) ):center_y( )

	local house_info_area = ibCreateArea(378,27, 0, 0, card_bg )
	local house_city_title_label = ibCreateLabel( 0, 4, 0, 0, "Город:", house_info_area, 0xFF98A0AB, 1, 1, "left", "center", ibFonts.regular_14 )
	local house_city_label = ibCreateLabel( 0, house_city_title_label:ibGetAfterY( 10 ), 0, 0, location_name, house_info_area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_16 )
	local house_owner_title_label = ibCreateLabel( 0, house_city_label:ibGetAfterY( 22 ), 0, 0, "Владелец:", house_info_area, 0xFF98A0AB, 1, 1, "left", "center", ibFonts.regular_14 )
	local house_owner_label = ibCreateLabel( 0, house_owner_title_label:ibGetAfterY( 12 ), 0, 0, pData.seller_name, house_info_area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_16 )
	local house_debt_title_label = ibCreateLabel( 0, house_owner_label:ibGetAfterY( 24 ), 0, 0, "Долг:", house_info_area, 0xFF98A0AB, 1, 1, "left", "center", ibFonts.regular_14 )
	local house_debt_label = ibCreateLabel( 0, house_debt_title_label:ibGetAfterY( 12 ), 0, 0, format_price( math.abs( pData.debt ) ), house_info_area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_16 )
	local money_icon = ibCreateImage( house_debt_label:ibGetAfterX( 10 ), 0, 20, 20, ":nrp_shared/img/money_icon.png", house_debt_label ):ibData( "disabled", true ):center_y( )
	local house_inventory_title_label = ibCreateLabel( 0, house_debt_label:ibGetAfterY( 22 ), 0, 0, "Хранилище:", house_info_area, 0xFF98A0AB, 1, 1, "left", "center", ibFonts.regular_14 )
	local house_inventory_label = ibCreateLabel( 0, house_inventory_title_label:ibGetAfterY( 12 ), 0, 0, inventory_max_weight .. " кг", house_info_area, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_16 )

	local house_cost_area = ibCreateArea(796,59, 0, 0, card_bg )
	local house_cost_title_label = ibCreateLabel( 0, 6, 0, 0, "Стоимость:", house_cost_area, 0xFF98A0AB, 1, 1, "center", "center", ibFonts.regular_14 )
	local area_dummy = ibCreateArea(0, house_cost_title_label:ibGetAfterY( 36 ), 0, 0, house_cost_area )
	local house_cost_label = ibCreateLabel( 0, 0, 0, 0, format_price( pData.sale_cost ), area_dummy, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_24 )
	local money_icon_3 = ibCreateImage( house_cost_label:ibGetAfterX( 10 ), 0, 26, 26, ":nrp_shared/img/money_icon.png", area_dummy ):ibData( "disabled", true ):center_y( )
	area_dummy:ibData( "sx", money_icon_3:ibGetAfterX( ) ):center_x( )

	-- кнопка отменить продажу дома
	if pData.seller_id == localPlayer:GetUserID( )then
		ibCreateButton( 10, area_dummy:ibGetAfterY( 36 ), 140, 42, house_cost_area, "images/btn_take.png", "images/btn_take_hover.png", "images/btn_take.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFF808080 )
			:center_x( )
			:ibOnClick( function( button, state )
			    if button ~= "left" or state ~= "up" then return end

				if confirmation then confirmation:destroy() end
            	confirmation = ibConfirm({
					title = "ОТМЕНА ПРОДАЖИ",
            	    text = "Ты точно хочешь отменить продажу дома?",
            	    fn = function( self )
						self:destroy( )

						triggerServerEvent( "onPlayerCancelHouseSale", resourceRoot, pData.hid )

						setTimer ( function ( )
							SALE_HOUSE_LIST  = { }
							ATTEMPT_COUNT    =  0
							IS_DATA_RECEIVED = false

							UpdateSaleArea( )
							UIe.RefreshRangeSlider( )
						end, 500, 1)
            	    end
            	} )

			end )
	else
		ibCreateButton( 10, area_dummy:ibGetAfterY( 36 ), 140, 42, house_cost_area, ":nrp_shared/img/btn_buy_i.png", ":nrp_shared/img/btn_buy_h.png", ":nrp_shared/img/btn_buy_c.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:center_x( )
			:ibOnClick( function( button, state )
			    if button ~= "left" or state ~= "up" then return end
			    ibClick( )
			
				if confirmation then confirmation:destroy() end
        	    confirmation = ibConfirm({
					title = "ПОТВЕРДИТЕ ПОКУПКУ",
        	        text = "Ты точно хочешь купить этот дом?",
        	        fn = function( self )
        	            self:destroy()
        	            triggerServerEvent( "onPlayerTryPurchaseHouse", resourceRoot, pData.hid )
					
						setTimer ( function ( )
							SALE_HOUSE_LIST  =  { }
							ATTEMPT_COUNT    =  0
							IS_DATA_RECEIVED =  false
						
							UpdateSaleArea()
							UIe.RefreshRangeSlider( )
							UpdateBalanceArea( )
						end, 1000, 1)
        	        end
        	    } )
			end )
	end
end


function UpdateSaleArea( )
	if not isElement( UIe.sale_area ) then return end

	if IS_DATA_RECEIVED then
		for _, elem in ipairs( UIe.sale_area:getChildren( ) )do
			destroyElement( elem )
		end

		local player_id = localPlayer:GetUserID( )
		table.sort( SALE_HOUSE_LIST, function( a, b )
			return a.seller_id == player_id
		end )

		if SALE_HOUSE_LIST and next( SALE_HOUSE_LIST ) then
			local i = 1
			for k, pData in ipairs( SALE_HOUSE_LIST or {} ) do
				if pData.sale_cost >= FILTER_MIN_COST and pData.sale_cost <= FILTER_MAX_COST then
					if pData.possible_buyer_id == 0 or pData.possible_buyer_id == player_id or pData.seller_id == player_id then
						CreateOfferCard(0, (i - 1) * 270, pData, UIe.sale_area)
						i = i + 1
					end
				end
			end
		else
			local not_found_text = string.format(
				"По запросу 'Тип недвижимости: %s' и 'Место: %s' ничего не найдено.\n\nПопробуйте изменить условия фильтра.",
				 CONST_HOUSE_TYPE_INFO[UIe.house_type.value].name, CONST_LOCATION_INFO[UIe.location.value].name )

			ibCreateLabel( 0, 0, 0, 0, not_found_text, UIe.sale_area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_18 )
				:center( 0, -30 )
		end

		ATTEMPT_COUNT = 0
		UIe.sale_area:AdaptHeightToContents()
		UIe.sale_scrollbar:UpdateScrollbarVisibility(UIe.sale_area)

	else
		if ATTEMPT_COUNT > 3 then
            localPlayer:InfoWindow( "По данному фильтру дома не найдены." )
            ATTEMPT_COUNT = 0
			return outputDebugString ( "nrp_house_sale: Превышено число попыток обновления списка продав.домов", 1 )
		end

        ATTEMPT_COUNT = ATTEMPT_COUNT + 1

		triggerServerEvent( "onPlayerRequestOnSaleHouseList", resourceRoot, UIe.location.value, UIe.house_type.value )

		UIe.loading = ibLoading( { parent = UIe.black_bg } )
			:ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )
			:ibTimer( function( self )
				self:destroy( )
				UpdateSaleArea( )
			end, 1500, 1 )
	end
end


function ShowHouseBuyUI( bState )
	if bState then
		ShowHouseBuyUI( false )

		showCursor( true )
		ibInterfaceSound()

		UIe.black_bg = ibCreateBackground( 0x1D252EBF, ShowHouseBuyUI, true, true )
		UIe.bg = ibCreateImage( 0, 0, 1024, 768, _, UIe.black_bg, ibApplyAlpha( 0xFF475D75, 95 ) ):center( )

		UIe.head_bg = ibCreateImage( 0, 0, UIe.bg:ibData( "sx" ), 92, _, UIe.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
		ibCreateImage( 0, UIe.head_bg:ibGetAfterY( -1 ), UIe.bg:ibData( "sx" ), 1, _, UIe.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
		UIe.head_label = ibCreateLabel( 30, 0, 0, UIe.head_bg:ibData( "sy" ), "Купить недвижимость", UIe.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 )

		UIe.close_btn = ibCreateButton( UIe.head_bg:ibGetAfterX( -60 ), 0, 25, 25, UIe.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:center_y( )
			:ibOnClick( function( button, state )
			    if button ~= "left" or state ~= "up" then return end

			    ShowHouseBuyUI( false )
			    ibClick( )
			end )

		UIe.person_area = ibCreateDummy( UIe.head_bg ):center_y( )
		local account_image = ibCreateImage( 0, 0, 0, 0, ":nrp_shared/img/account.png", UIe.person_area ):ibSetRealSize( ):center_y( )
		local balance_common_area = ibCreateDummy( UIe.person_area )
		local balance_area = ibCreateDummy( balance_common_area )
		UIe.balance_title_label = ibCreateLabel( account_image:ibGetAfterX( 10 ), 2, 0, 0, "Ваш баланс: ", balance_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_14 )
		UIe.balance_amount_label = ibCreateLabel( UIe.balance_title_label:ibGetAfterX( 6 ), 0, 0, 0, format_price( localPlayer:GetMoney( ) ), balance_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_18 )
		UIe.money_icon = ibCreateImage( UIe.balance_amount_label:ibGetAfterX( 10 ), 0, 25, 25, ":nrp_shared/img/money_icon.png", balance_area ):ibData( "disabled", true ):center_y( )

		local deposit_btn = ibCreateButton( account_image:ibGetAfterX( 10 ), UIe.money_icon:ibGetAfterY( 4 ), 112, 10,  balance_common_area, "images/deposit.png", _, _, 0xFFFFFFFF, 0xAAFFFFFF, 0x70FFFFFF )
			:ibOnClick( function( button, state )
			    if button ~= "left" or state ~= "up" then return end
			    ibClick( )

			    UIe.loading = ibLoading( { parent =  UIe.black_bg } )
			        :ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )
			        :ibTimer( function( self )
			            self:destroy( )
			            ShowHouseBuyUI( false )
			            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate" )
			        end, 750, 1 )
			end )

        UIe.person_area:ibData( "px", UIe.close_btn:ibGetBeforeX( -25 ) - UIe.money_icon:ibGetAfterX( ) )
        balance_common_area:ibData( "sy", deposit_btn:ibGetAfterY( ) ):center_y( 3 )

        UIe.sale_area, UIe.sale_scrollbar = ibCreateScrollpane( 30, 175, UIe.bg:width( ) - 30, UIe.bg:height( ) - UIe.head_bg:height( ) - 90, UIe.bg, { scroll_px = -20 } )
        UIe.sale_scrollbar:ibSetStyle( "slim_nobg" )

		-- дефолтные опции фильтра
		UIe.location   = { value = CONST_LOCATION.NSK }
		UIe.house_type = { value = CONST_HOUSE_TYPE.APARTMENT }

		UpdateSaleArea( )

        -- dropdown тип недвижимости
		local filter_area = ibCreateArea(30,113, 0, 0, UIe.bg )
		local house_type_dropdown_btn = ibCreateButton( 0, 0, 284, 42, filter_area, "images/filter_house.png","images/filter_hover_house.png", _ )
			:ibOnClick( function( button, state )
			    if button ~= "left" or state ~= "up" then return end
			    ibClick( )

				if isElement( UIe.dropdown ) then
					ShowDropdown( false )
				else
					ShowDropdown( true, source, CONST_HOUSE_TYPE_INFO, UIe.house_type, UIe.house_type_dropdown_btn_text )
				end
			end )

        -- dropdown локация
		local location_dropdown_btn = ibCreateButton( house_type_dropdown_btn:ibGetAfterX( 10 ), 0, 328, 42, filter_area, "images/filter_place.png", "images/filter_hover_place.png", _ )
			:ibOnClick( function( button, state )
			    if button ~= "left" or state ~= "up" then return end
			    ibClick( )

				if isElement( UIe.dropdown ) then
					ShowDropdown( false )
				else
					ShowDropdown( true, source, CONST_LOCATION_INFO_SORTED, UIe.location, UIe.location_dropdown_btn_text )
				end
			end )
		local cost_adjust_area = ibCreateButton( location_dropdown_btn:ibGetAfterX( 10 ), 0, 332, 42, filter_area, "images/filter_cost.png", "images/filter_hover_cost.png", _ )

		UIe.house_type_dropdown_btn_text = ibCreateLabel( 10, 0, 0, house_type_dropdown_btn:height( ), "Тип недвижимости", house_type_dropdown_btn, 0xFFDBDEE2, 1, 1, "left", "center", ibFonts.regular_14 )
		UIe.location_dropdown_btn_text = ibCreateLabel( 10, 0, 0, location_dropdown_btn:height( ), "Место", location_dropdown_btn, 0xFFDBDEE2, 1, 1, "left", "center", ibFonts.regular_14 )

		for k, v in ipairs( CONST_HOUSE_TYPE_INFO ) do
			if v.value == UIe.house_type.value then
				UIe.house_type_dropdown_btn_text:ibData( "text", v.name )
			end
		end

		for k, v in ipairs( CONST_LOCATION_INFO_SORTED ) do
			if v.value == UIe.location.value then
				UIe.location_dropdown_btn_text:ibData( "text", v.name )
			end
		end

		CreateRangeSlider( 0, 0, cost_adjust_area )

	else
        if isElement( UIe and UIe.black_bg ) then
            destroyElement( UIe.black_bg )
        end
        showCursor( false )
        UIe = {}
		SALE_HOUSE_LIST = {}
		IS_DATA_RECEIVED = false
	end
end

-- вычисляем диапазон для range_slider на основе мин/макс стоимости дома из результатов запроса
local function ComputeFilterMinMaxCost( )
	local min_value, max_value

	for i, v in ipairs( SALE_HOUSE_LIST or {} ) do
		if not min_value then min_value = v.sale_cost end
		if not max_value then max_value = v.sale_cost end

		if v.sale_cost < min_value then
			min_value = v.sale_cost
		elseif v.sale_cost > max_value then
			max_value = v.sale_cost
		end
	end

	if not min_value or not max_value then return end

	DEFAULT_MIN_COST = min_value
	DEFAULT_MAX_COST = max_value
	FILTER_MIN_COST  = DEFAULT_MIN_COST
	FILTER_MAX_COST  = DEFAULT_MAX_COST
end

addEvent("UpdateOnSaleHouseList", true)
addEventHandler( "UpdateOnSaleHouseList", resourceRoot, function( house_list )
	SALE_HOUSE_LIST = house_list
	IS_DATA_RECEIVED = true

	ComputeFilterMinMaxCost( )

	if isElement( UIe.RangeSlider ) then
		UIe.RefreshRangeSlider( )
	end
end )