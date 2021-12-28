ibUseRealFonts( true )

local ATTEMPT_COUNT = 0
local SELF_HOUSE_LIST = {}
local IS_DATA_RECEIVED = false

function GetHouseHumanViewData( pData )
	local hid = pData.hid
	local house_type = pData.house_type
	if not hid then
		hid = pData.id == 0 and VIP_HOUSES_LIST[ pData.number ].hid or ( pData.id .. "_" .. pData.number )
		house_type = GetHouseTypeFromHID( hid )
	end

	local location_id = GetLocationIDFromHID( hid, house_type )
	local location_name = CONST_LOCATION_INFO[ location_id ][ "name" ]

	local house_image_path = CONST_HOUSE_TYPE_INFO[ house_type ][ "image" ]

	local house_name = CONST_HOUSE_TYPE_INFO[ house_type ][ "name" ]
	local inventory_max_weight
	if house_type == CONST_HOUSE_TYPE.APARTMENT then
		local id, number = hid:match( "^(%d+)_(%d+)$" )
		id = tonumber( id )
		local class = APARTMENTS_LIST[ id ].class
		house_name = house_name .. " #" .. number .. " (" .. tostring( class ) .. " класс)"
		inventory_max_weight = APARTMENTS_CLASSES[ class ].inventory_max_weight
	elseif house_type == CONST_HOUSE_TYPE.VILLA then
		house_name = hid == "vh1" and "Вилла 'Око'" or house_name
		house_name = house_name .. " (" .. tostring( VIP_HOUSES_REVERSE[ hid ].village_class ) .. " класс)"
		inventory_max_weight = VIP_HOUSES_REVERSE[ hid ].inventory_max_weight
	elseif house_type == CONST_HOUSE_TYPE.COTTAGE then
		house_name = house_name .. " (" .. tostring( VIP_HOUSES_REVERSE[ hid ].cottage_class ) .. " класс)"
		inventory_max_weight = VIP_HOUSES_REVERSE[ hid ].inventory_max_weight
	end

	return location_name, house_name, house_image_path, inventory_max_weight
end

local function ShowSharedSalePopup( state, parent, data )
	if state then
		ShowSharedSalePopup( false )

		UIe.popup = ibCreateImage( 0, parent:height( ), parent:width( ), parent:height( )-92, _, parent, ibApplyAlpha( 0xFF232E3A, 95 ) )
		local area = ibCreateDummy( UIe.popup )
		local lbl = ibCreateLabel( 0, 0, 0, 0, "Сумма продажи недвижимости:", area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_20 )
		local edit_bg = ibCreateImage( -575/2, lbl:ibGetAfterY(30), 0, 0, "images/edit_bg.png", area, 0xFFC7AD7B ):ibSetRealSize( )
		local cost_edit = ibCreateWebEdit( -575/2, lbl:ibGetAfterY(28), 575, 60, "", area, 0xFF858C92, 0 )
			:ibBatchData( { focusable = true, placeholder = "Введите сумму", font = "regular_12_600", text_align = "center", placeholder_color = "0xFF929496" } )


		local min_cost_area = ibCreateDummy( area )
		do
			local info_icon = ibCreateImage( 0, 0, 20, 20, ":nrp_shared/img/icon_timer.png", min_cost_area, 0xFFC7AD7B ):ibData( "disabled", true ):center_y( )
			local min_lbl = ibCreateLabel( info_icon:ibGetAfterX( 8 ), 0, 0, 0, "Минимальная сумма продажи:", min_cost_area, 0xFFC7AD7B, 1, 1, "left", "center", ibFonts.bold_16 )
			local cost_lbl = ibCreateLabel( min_lbl:ibGetAfterX( 10 ), 0, 0, 0, format_price( data.cost.min ), min_cost_area, 0xFFC7AD7B, 1, 1, "left", "center", ibFonts.bold_16 )
			local money_icon = ibCreateImage( cost_lbl:ibGetAfterX( 10 ), 0, 20, 20, ":nrp_shared/img/money_icon.png", min_cost_area ):ibData( "disabled", true ):center_y( )
			min_cost_area:ibBatchData( { sx = money_icon:ibGetAfterX(), sy = money_icon:height(), py = edit_bg:ibGetAfterY(20) } ):center_x( )
		end

		local max_cost_area = ibCreateDummy( area )
		do
			local info_icon = ibCreateImage( 0, 0, 20, 20, ":nrp_shared/img/icon_timer.png", max_cost_area, 0xFFC7AD7B ):ibData( "disabled", true ):center_y( )
			local min_lbl = ibCreateLabel( info_icon:ibGetAfterX( 8 ), 0, 0, 0, "Максимальная сумма продажи:", max_cost_area, 0xFFC7AD7B, 1, 1, "left", "center", ibFonts.bold_16 )
			local cost_lbl = ibCreateLabel( min_lbl:ibGetAfterX( 10 ), 0, 0, 0, format_price( data.cost.max ), max_cost_area, 0xFFC7AD7B, 1, 1, "left", "center", ibFonts.bold_16 )
			local money_icon = ibCreateImage( cost_lbl:ibGetAfterX( 10 ), 0, 20, 20, ":nrp_shared/img/money_icon.png", max_cost_area ):ibData( "disabled", true ):center_y( )
			max_cost_area:ibBatchData( { sx = money_icon:ibGetAfterX(), sy = money_icon:height(), py = min_cost_area:ibGetAfterY( 6 ) } ):center_x( )
		end

		-- кнопка разместить
    	ibCreateButton( 0, max_cost_area:ibGetAfterY( 20 ), 166, 51, area,
			"images/btn_publish.png", "images/btn_publish_hover.png", "images/btn_publish_hover.png",
    	    0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC )
    	    :center_x( )
			:ibOnClick( function( button, state )
            	if button ~= "left" or state ~= "up" then return end
            	ibClick( )

				local cost = tonumber( cost_edit:ibData( "text" ) )
				if not cost then
					return localPlayer:ShowError( "Сумма продажи должно быть числом!" )
				elseif cost < data.cost.min then
					return localPlayer:ShowError( "Сумма продажи меньше минимальной стоимости!" )
				elseif cost > data.cost.max then
					return localPlayer:ShowError( "Сумма продажи превышает максимальную стоимость!" )
				end

				if not data.is_inventory_empty then
					ConfirmInventoryReset( data.hid, cost, target_name )
				else
					TryPublishHouseSale( data.hid, cost, target_name )
				end
        	end )

		area:ibData( "sy", max_cost_area:ibGetAfterY( ) ):center( 0, -50 )

		-- кнопка скрыть
		ibCreateButton( 0, area:ibGetAfterY( 20 ), 108, 42, area,
			"images/btn_hide.png", "images/btn_hide_hover.png", "images/btn_hide.png",
			0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC )
			:center_x( )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "up" then return end
				ibClick( )
				ShowSharedSalePopup( false )
        	end )

	else
		if isElement( UIe.popup ) then destroyElement( UIe.popup ) end
	end
end

local function ShowIndividualSalePopup( state, parent, data )

	if state then
		ShowIndividualSalePopup( false )

		UIe.popup = ibCreateImage( 0, parent:height( ), parent:width( ), parent:height( )-92, _, parent, ibApplyAlpha( 0xFF232E3A, 95 ) )
		local area = ibCreateDummy( UIe.popup )
		local lbl = ibCreateLabel( 0, 140, 0, 0, "Индивидуальная продажа:", area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_20 )
		local name_edit_bg = ibCreateImage( -575/2, 198, 0, 0, "images/edit_bg.png", area, 0xFFC7AD7B ):ibSetRealSize( )
		local name_edit = ibCreateWebEdit( -575/2, 196, 575, 60, "", area, 0xFF858C92, 0 )
			:ibBatchData( { focusable = true, placeholder = "Введите имя игрока", font = "regular_12_600", text_align = "center", placeholder_color = "0xFF929496" } )
		local cost_edit_bg = ibCreateImage( -575/2, 268, 0, 0, "images/edit_bg.png", area, 0xFFC7AD7B ):ibSetRealSize( )
		local cost_edit = ibCreateWebEdit( -575/2, 266, 575, 60, "", area, 0xFF858C92, 0 )
			:ibBatchData( { focusable = true, placeholder = "Введите сумму", font = "regular_12_600", text_align = "center", placeholder_color = "0xFF929496" } )

		local min_cost_area = ibCreateDummy( area )
		do
			local info_icon = ibCreateImage( 0, 0, 20, 20, ":nrp_shared/img/icon_timer.png", min_cost_area, 0xFFC7AD7B ):ibData( "disabled", true ):center_y( )
			local min_lbl = ibCreateLabel( info_icon:ibGetAfterX( 8 ), 0, 0, 0, "Минимальная сумма продажи:", min_cost_area, 0xFFC7AD7B, 1, 1, "left", "center", ibFonts.bold_16 )
			local cost_lbl = ibCreateLabel( min_lbl:ibGetAfterX( 10 ), 0, 0, 0, format_price( data.cost.min ), min_cost_area, 0xFFC7AD7B, 1, 1, "left", "center", ibFonts.bold_16 )
			local money_icon = ibCreateImage( cost_lbl:ibGetAfterX( 10 ), 0, 20, 20, ":nrp_shared/img/money_icon.png", min_cost_area ):ibData( "disabled", true ):center_y( )
			min_cost_area:ibBatchData( { sx = money_icon:ibGetAfterX(), sy = money_icon:height(), py = 351 } ):center_x( )
		end

		local max_cost_area = ibCreateDummy( area )
		do
			local info_icon = ibCreateImage( 0, 0, 20, 20, ":nrp_shared/img/icon_timer.png", max_cost_area, 0xFFC7AD7B ):ibData( "disabled", true ):center_y( )
			local min_lbl = ibCreateLabel( info_icon:ibGetAfterX( 8 ), 0, 0, 0, "Максимальная сумма продажи:", max_cost_area, 0xFFC7AD7B, 1, 1, "left", "center", ibFonts.bold_16 )
			local cost_lbl = ibCreateLabel( min_lbl:ibGetAfterX( 10 ), 0, 0, 0, format_price( data.cost.max ), max_cost_area, 0xFFC7AD7B, 1, 1, "left", "center", ibFonts.bold_16 )
			local money_icon = ibCreateImage( cost_lbl:ibGetAfterX( 10 ), 0, 20, 20, ":nrp_shared/img/money_icon.png", max_cost_area ):ibData( "disabled", true ):center_y( )
			max_cost_area:ibBatchData( { sx = money_icon:ibGetAfterX(), sy = money_icon:height(), py = min_cost_area:ibGetAfterY(6) } ):center_x( )
		end

		-- кнопка отправить
    	ibCreateButton( 0, 412, 170, 50, area,
    	    "images/btn_send.png", "images/btn_send_hover.png", "images/btn_send.png",
    	    0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC )
    	    :center_x( )
			:ibOnClick( function( button, state )
            	if button ~= "left" or state ~= "up" then return end
            	ibClick( )

				local target_name = name_edit:ibData( "text" )
				if not target_name then
					return localPlayer:ShowError( "Это поле не должно быть пустым!" )
				end

				local cost = tonumber( cost_edit:ibData( "text" ) )
				if not cost then
					return localPlayer:ShowError( "Сумма продажи должно быть числом!" )
				elseif cost < data.cost.min then
					return localPlayer:ShowError( "Сумма продажи меньше минимальной стоимости!" )
				elseif cost > data.cost.max then
					return localPlayer:ShowError( "Сумма продажи превышает максимальную стоимость!" )
				end

				if not data.is_inventory_empty then
					ConfirmInventoryReset( data.hid, cost, target_name )
				else
					TryPublishHouseSale( data.hid, cost, target_name )
				end
        	end )

		area:center_x( )

		-- кнопка скрыть
		ibCreateButton( 0, 604, 108, 42, area,
			"images/btn_hide.png", "images/btn_hide_hover.png", "images/btn_hide.png",
			0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC )
			:center_x( )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "up" then return end
				ibClick( )

				ShowIndividualSalePopup( false )
        	end )

	else
		if isElement( UIe.popup ) then destroyElement( UIe.popup ) end
	end
end

function ConfirmInventoryReset( hid, cost, target_name )
	if confirmation then confirmation:destroy( ) end
	confirmation = ibConfirm(
		{
			title = "ВНИМАНИЕ",
			text = "После продажи предметы в ящике будут уничтожены",
			fn = function( self )
				self:destroy( )
				TryPublishHouseSale( hid, cost, target_name )
			end,
			escape_close = true,
		}
	)
end

function TryPublishHouseSale( hid, cost, target_name )
	triggerServerEvent( "onPlayerTryPublishHouseSale", resourceRoot, hid, cost, target_name )

	ShowIndividualSalePopup( false )

	SELF_HOUSE_LIST = { }
	ATTEMPT_COUNT = 0
	IS_DATA_RECEIVED = false
	UpdateSelfHouseListArea( )
end

local function CreateHouseInfoCard( px, py, pData, parent )

	local location_name, house_name, house_image_path = GetHouseHumanViewData( pData )

	local card_bg = ibCreateImage( px, py, 964, 184, "images/house_info_bg.png", parent )

	local logo_area = ibCreateArea(0, 0, 297, card_bg:height(), card_bg )
	ibCreateImage( 0, 0, 0, 0, "images/" .. house_image_path, logo_area ):ibSetRealSize( ):center( )

	local info_area = ibCreateArea(logo_area:ibGetAfterX( ), 0, card_bg:ibGetAfterX( ) - logo_area:width( ), card_bg:height( ), card_bg )
	local house_name_label = ibCreateLabel( 0, 27, info_area:width(), 0, house_name, info_area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_18 )

	local area = ibCreateArea(0, house_name_label:ibGetAfterY( 48 ), 311, 0, info_area)
	local location_label = ibCreateLabel( 0, 0, area:width( ), 0, location_name, area, 0xFFAEB3B8, 1, 1, "right", "center", ibFonts.regular_16 )
	local debt_label = ibCreateLabel( area:ibGetAfterX( 44 ), 0, 0, 0, "Долг ЖКХ: "..format_price( pData.debt ), area, 0xFFAEB3B8, 1, 1, "left", "center", ibFonts.regular_16 )
	local money_icon = ibCreateImage( debt_label:ibGetAfterX( 10 ), 0, 22, 22, ":nrp_shared/img/money_icon.png", area ):ibData( "disabled", true ):center_y( )

	local btn_area = ibCreateArea(0, area:ibGetAfterY( 35 ), 0, 0, info_area)
	local publish_btn = ibCreateButton( 0, 0, 250, 34, btn_area, "images/place_ads_btn.png", "images/place_ads_btn_h.png", "images/place_ads_btn_h.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( button, state )
		    if button ~= "left" or state ~= "up" then return end
			ibOverlaySound( )
			ShowSharedSalePopup( true, UIe.bg, pData )
			UIe.popup:ibMoveTo( _, 92, 200 )
		end )

	local target_sell_btn = ibCreateButton( publish_btn:ibGetAfterX( 24 ), 0, 250, 34, btn_area, "images/target_sell_btn.png", "images/target_sell_btn_h.png", "images/target_sell_btn_h.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( button, state )
		    if button ~= "left" or state ~= "up" then return end
			ibOverlaySound( )
			ShowIndividualSalePopup( true, UIe.bg, pData )
			UIe.popup:ibMoveTo( _, 92, 200 )
		end )
	btn_area:ibData( "sx", target_sell_btn:ibGetAfterX( ) ):center_x( )
end

function UpdateSelfHouseListArea( )
	if not isElement( UIe.self_house_area ) then return end

	if IS_DATA_RECEIVED then
		for _, elem in ipairs( UIe.self_house_area:getChildren( ) )do
			destroyElement( elem )
		end

		if SELF_HOUSE_LIST and next( SELF_HOUSE_LIST ) then

        	local i = 1
        	for k, pData in pairs( SELF_HOUSE_LIST or {} ) do
        	    CreateHouseInfoCard( 0, ( i - 1 ) * 205, pData, UIe.self_house_area )
				i = i + 1
        	end

        	UIe.self_house_area:AdaptHeightToContents( )
        	UIe.self_house_scrollbar:UpdateScrollbarVisibility( UIe.self_house_area )

		else
			local not_found_text = "У вас нету недвижимости для продажи."
			ibCreateLabel( 0, 0, 0, 0, not_found_text, UIe.self_house_area, COLOR_WHITE, 1, 1, "center", "center", ibFonts.regular_18 )
				:center( 0, -30 )
		end

	else
		if ATTEMPT_COUNT > 3 then
			ATTEMPT_COUNT = 0
			localPlayer:InfoWindow( "Ошибка обновления списка домов." )
			return outputDebugString ( "nrp_house_sale: Превышено число попыток обновления списка домов", 1 )
		end

        ATTEMPT_COUNT = ATTEMPT_COUNT + 1

		triggerServerEvent( "onPlayerRequestSelfHouseList", resourceRoot )

		UIe.loading = ibLoading( { parent = UIe.black_bg } )
			:ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )
			:ibTimer( function( self )
				self:destroy( )
				UpdateSelfHouseListArea( )
			end, 1500, 1 )
	end
end

function ShowHouseSaleUI( state )
	if state then

		ATTEMPT_COUNT = 0
		SELF_HOUSE_LIST = { }
		IS_DATA_RECEIVED = false

		ShowHouseSaleUI( false )

		showCursor( true )
		ibInterfaceSound()

		UIe.black_bg = ibCreateBackground( 0x1D252EBF, ShowHouseSaleUI, true, true )
		UIe.bg = ibCreateImage( 0, 0, 1024, 768, _, UIe.black_bg, ibApplyAlpha( 0xFF475D75, 95 ) ):center()

		UIe.head_bg = ibCreateImage( 0, 0, UIe.bg:ibData( "sx" ), 92, _, UIe.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
		ibCreateImage( 0, UIe.head_bg:ibGetAfterY( -1 ), UIe.bg:ibData( "sx" ), 1, _, UIe.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
		UIe.head_label = ibCreateLabel( 30, 0, 0, UIe.head_bg:ibData( "sy" ), "Разместить обьявление", UIe.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 )

		local close_btn = ibCreateButton( UIe.head_bg:ibGetAfterX( -60 ), 0, 25, 25, UIe.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:center_y( )
			:ibOnClick( function( button, state )
			    if button ~= "left" or state ~= "up" then return end

			    ShowHouseSaleUI( false )
			    ibClick( )
			end )

		local person_area = ibCreateDummy( UIe.head_bg ):center_y( )
		local account_image = ibCreateImage( 0, 0, 0, 0, ":nrp_shared/img/account.png", person_area ):ibSetRealSize( ):center_y( )
		local balance_common_area = ibCreateDummy( person_area )
		local balance_area = ibCreateDummy( balance_common_area )
		local balance_title_label = ibCreateLabel( account_image:ibGetAfterX( 10 ), 2, 0, 0, "Ваш баланс: ", balance_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_14 )
		local balance_amount_label = ibCreateLabel( balance_title_label:ibGetAfterX( 6 ), 0, 0, 0, format_price( localPlayer:GetMoney( ) ), balance_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_18 )
		local money_icon = ibCreateImage( balance_amount_label:ibGetAfterX( 10 ), 0, 25, 25, ":nrp_shared/img/money_icon.png", balance_area ):ibData( "disabled", true ):center_y( )

		local deposit_btn = ibCreateButton( account_image:ibGetAfterX( 10 ), money_icon:ibGetAfterY( 4 ), 112, 10,  balance_common_area, "images/deposit.png", _, _, 0xFFFFFFFF, 0xAAFFFFFF, 0x70FFFFFF )
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

        person_area:ibData( "px", close_btn:ibGetBeforeX( -25 ) - money_icon:ibGetAfterX( ) )
        balance_common_area:ibData( "sy", deposit_btn:ibGetAfterY( ) ):center_y( 3 )

		local bottom_info_bg = ibCreateImage( 0, UIe.bg:height( ) - 100, UIe.bg:ibData( "sx" ), 100, _, UIe.bg, 0xFF5A6E83 )
		ibCreateImage( 31, 0, 0, 0, "images/info_xs.png", bottom_info_bg ):ibSetRealSize( ):center_y( )
		ibCreateLabel( 98, 22, 0, 0, "Недвижимость можно перепродать только после 3-х дней со дня покупки", bottom_info_bg, 0xFFC2C8CF, 1, 1, "left", "center", ibFonts.regular_15 )
		ibCreateLabel( 98, 41, 0, 0, "Комиссия продажи недвижимости будет составлять 5%", bottom_info_bg, 0xFFC2C8CF, 1, 1, "left", "center", ibFonts.regular_15 )
		ibCreateLabel( 98, 60, 0, 0, "Расширения хранилища сохраняются при продаже", bottom_info_bg, 0xFFC2C8CF, 1, 1, "left", "center", ibFonts.regular_15 )
		ibCreateLabel( 98, 79, 0, 0, "Содержимое хранилища удаляется при продаже", bottom_info_bg, 0xFFC2C8CF, 1, 1, "left", "center", ibFonts.regular_15 )

        UIe.self_house_area, UIe.self_house_scrollbar = ibCreateScrollpane( 30, 113, UIe.bg:width( ) - 30, UIe.bg:height( ) - UIe.head_bg:height( ) - 140, UIe.bg, { scroll_px = -20 } )
        UIe.self_house_scrollbar:ibSetStyle( "slim_nobg" )

		UpdateSelfHouseListArea( )

	else
        if isElement( UIe and UIe.black_bg ) then
            destroyElement( UIe.black_bg )
        end
        showCursor( false )
        UIe = {}
	end
end

function ShowChooseActionView( state )
	if state then
		ShowChooseActionView( false )

		showCursor( true )
		ibInterfaceSound()

		UIe.black_bg = ibCreateBackground( 0x1D252EBF, ShowChooseActionView, true, true )
		UIe.bg = ibCreateImage( 0, 0, 1024, 768, _, UIe.black_bg, ibApplyAlpha( 0xFF475D75, 95 ) ):center()

		UIe.head_bg = ibCreateImage( 0, 0, UIe.bg:ibData( "sx" ), 92, _, UIe.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
		ibCreateImage( 0, UIe.head_bg:ibGetAfterY( -1 ), UIe.bg:ibData( "sx" ), 1, _, UIe.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
		UIe.head_label = ibCreateLabel( 30, 0, 0, UIe.head_bg:ibData( "sy" ), "Перепродажа", UIe.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 )

		local close_btn = ibCreateButton( UIe.head_bg:ibGetAfterX( -60 ), 0, 25, 25, UIe.head_bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:center_y( )
			:ibOnClick( function( button, state )
			    if button ~= "left" or state ~= "up" then return end

			    ShowChooseActionView( false )
			    ibClick( )
			end )

		local sides = ibCreateDummy( UIe.bg )
		local left_side_hover = ibCreateImage( 0, 0, 0, 0, "images/side_hover.png", sides ):ibSetRealSize( )
			:ibData( "alpha", 0 )
			:ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
			:ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
		local left_side = ibCreateImage( 2, 0, 0, 0, "images/left_side.png", sides ):ibSetRealSize( ):ibData( "disabled", true )
		ibCreateLabel( 8, 40, left_side:width( ), 0, "Купить недвижимость", left_side, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_18 )
		ibCreateButton( 0, left_side_hover:ibGetAfterY( -70 ), 182, 45, left_side, "images/choose_btn.png", "images/choose_btn_hover.png", _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:center_x( )
			:ibOnHover( function( ) left_side_hover:ibAlphaTo( 255, 200 ) end )
			:ibOnLeave( function( ) left_side_hover:ibAlphaTo( 0, 200 ) end )
			:ibOnClick( function( button, state )
			    if button ~= "left" or state ~= "up" then return end
			    ibClick( )

				ShowChooseActionView( false )
				ShowHouseBuyUI( true )
			end )

		local right_side_hover = ibCreateImage( left_side:ibGetAfterX( 28 ), 0, 0, 0, "images/side_hover.png", sides ):ibSetRealSize( )
			:ibData( "alpha", 0 )
			:ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
			:ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
		local right_side = ibCreateImage( left_side:ibGetAfterX( 30 ), 0, 0, 0, "images/right_side.png", sides ):ibSetRealSize( ):ibData( "disabled", true )
		ibCreateLabel( 22, 40, right_side:width( ), 0, "Выложить недвижимость", right_side, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_18 )
		ibCreateButton( 0, right_side_hover:ibGetAfterY( -70 ), 182, 45, right_side, "images/choose_btn.png", "images/choose_btn_hover.png", _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:center_x( )
			:ibOnHover( function( ) right_side_hover:ibAlphaTo( 255, 200 ) end )
			:ibOnLeave( function( ) right_side_hover:ibAlphaTo( 0, 200 ) end )
			:ibOnClick( function( button, state )
			    if button ~= "left" or state ~= "up" then return end
			    ibClick( )

				ShowChooseActionView( false )
				ShowHouseSaleUI( true )
			end )
		sides:ibBatchData( { sx = right_side:ibGetAfterX( ), sy = right_side:height( ) } ):center( 0, 26 )
	else
        if isElement( UIe and UIe.black_bg ) then
            destroyElement( UIe.black_bg )
        end
        showCursor( false )
        UIe = {}
	end
end

addEvent("onFetchSelfHouseList", true)
addEventHandler( "onFetchSelfHouseList", resourceRoot, function( house_list )
	SELF_HOUSE_LIST = house_list
	IS_DATA_RECEIVED = true
end )


addEvent( "onPlayerWantShowHouseSaleUI", true )
addEventHandler( "onPlayerWantShowHouseSaleUI", root, function( )
    ShowHouseSaleUI( true )
end )