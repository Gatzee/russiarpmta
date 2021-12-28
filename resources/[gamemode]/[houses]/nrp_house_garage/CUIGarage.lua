loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "ShApartments" )
Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UIe = {}
local click_timeout = 0

function ShowUIGarage_handler( id, have_slots, bought_slots, veh_list, unlock_data )
	if isElement( UIe.black_bg ) then destroyElement( UIe.black_bg ) end

	showCursor( true )
	ibInterfaceSound()
	
    UIe.black_bg = ibCreateBackground( 0xBF1D252E, HideUIGarage, _, true )
    UIe.bg = ibCreateImage( 0, 0, 800, 600, _, UIe.black_bg, ibApplyAlpha( 0xFF475d75, 97 ) ):center()

	UIe.head_bg    = ibCreateImage( 0, 0, UIe.bg:ibData( "sx" ), 72, _, UIe.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
                     ibCreateImage( 0, UIe.head_bg:ibGetAfterY( -1 ), UIe.bg:ibData( "sx" ), 1, _, UIe.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
	UIe.head_label = ibCreateLabel( 30, 0, 0, UIe.head_bg:ibData( "sy" ), "Управление парковкой", UIe.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
	
	UIe.btn_close = ibCreateButton( UIe.bg:ibData( "sx" ) - 55, 24, 25, 25, UIe.head_bg, "images/button_close.png", "images/button_close.png", "images/button_close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC)
		:ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
			ibClick( )

			HideUIGarage( )
		end)

	UIe.slots_area = ibCreateArea( 510, 0, 100, UIe.head_bg:ibData( "sy" ), UIe.head_bg )
	UIe.car_img = ibCreateImage( 0, 21, 40, 30, "images/icon_car.png", UIe.slots_area)
    UIe.slots_text_label = ibCreateLabel( UIe.car_img:ibGetAfterX( 14 ), 18, 0, 0, "Ваши слоты:", UIe.slots_area, ibApplyAlpha( COLOR_WHITE, 60 ), 1, 1, "left", "top", ibFonts.regular_14 )
	UIe.have_slots_label = ibCreateLabel( UIe.slots_text_label:ibGetAfterX( 8 ), 14, 0, 0, have_slots.." /", UIe.slots_area, ibApplyAlpha( COLOR_WHITE, 60 ), 1, 1, "left", "top", ibFonts.bold_18 )
	UIe.free_slots_label = ibCreateLabel( UIe.have_slots_label:ibGetAfterX( ), 14, 0, 0, " "..math.max( 0, have_slots - #veh_list ), UIe.slots_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
	UIe.btn_buy_slots = ibCreateButton( 0, 20, 97, 20, UIe.slots_text_label, "images/button_buy_slots.png", "images/button_buy_slots.png", "images/button_buy_slots.png", 0xFFFFFFFF, 0xAAFFFFFF, 0x70FFFFFF )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "up" then return end
			ibClick( )

			triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "services" )
			HideUIGarage( )
		end)
	UIe.slots_area:ibData( "px", UIe.btn_close:ibGetBeforeX( -30 - UIe.free_slots_label:ibGetAfterX( ) ) )

	UIe.scrollpane, UIe.scrollbar = ibCreateScrollpane( 0, UIe.head_bg:ibGetAfterY(), UIe.bg:ibData( "sx" ), UIe.bg:ibData( "sy" ) - UIe.head_bg:ibData( "sy" ), UIe.bg, { scroll_px = -20 } )
	UIe.scrollbar:ibSetStyle( "slim_nobg" )

	local str_slots_text = {
		"";
		"Доступно для квартир 1-го класса";
		"Доступно для квартир 2-го класса и коттеждей 1-го";
		"Доступно для квартир 3-го класса и коттеждей 2-го";
		"Доступно для вилл и коттеджей 3-го класса";
		"Доступно для вилл и коттеджей 4-го класса";
		"Доступно для вилл и коттеджей 5-го класса";
		"Доступно для вилл";
		"Доступно для вилл";
		"Доступно для вилл";
	}
	
	local count_selected = 0
	local selected_vehicles = {}
	if unlock_data then
		UIe.head_label:ibData( "text", "Выберите, какой транспорт хотите использовать ( "..count_selected.." из ".. have_slots .." шт. )" )
		UIe.slots_area:ibData( "visible", false )
		UIe.btn_close:ibData( "disabled", true ):ibData( "alpha", 100 )

		for i, info in ipairs( veh_list ) do
			selected_vehicles[ i ] = true

			local item_area = ibCreateArea( 0, 91 * ( i - 1 ), UIe.scrollpane:ibData( "sx" ), 91, UIe.scrollpane )
			if i > 1 then
				ibCreateImage( 0, 0, item_area:ibData( "sx" ), 1, _, item_area, ibApplyAlpha( COLOR_WHITE, 10 ) )
			end

			ibCreateImage( 30, 30, 40, 30, "images/icon_car.png", item_area )

			local lbl_name = ibCreateLabel( 100, 27, 0, 0, info.name, item_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 ):center_y( )
			ibCreateLabel( lbl_name:ibGetAfterX( 5 ), 27, 0, 0, "(" .. info.numberplate .. ")", item_area, 0xAAFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 ):center_y( )

			local check_img = ibCreateImage( item_area:ibData( "sx" ) - 30 - 26, 0, 26, 26, "images/unchecked.png", item_area ):center_y( )
	
			ibCreateArea( 0, 0, item_area:ibData( "sx" ), item_area:ibData( "sy" ), item_area )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "down" then return end
					ibClick( )
					if selected_vehicles[ i ] then
						if count_selected >= have_slots then
							localPlayer:ShowError("Можно выбрать только ".. have_slots .." шт.")
							return
						end

						selected_vehicles[ i ] = false
						count_selected = count_selected + 1
						check_img:ibData( "texture", "images/checked.png" )
						UIe.head_label:ibData( "text", "Выберите, какой транспорт хотите использовать ( "..count_selected.." из ".. have_slots .." шт. )" )
					else
						selected_vehicles[ i ] = true
						count_selected = count_selected - 1
						check_img:ibData( "texture", "images/unchecked.png" )
						UIe.head_label:ibData( "text", "Выберите, какой транспорт хотите использовать ( "..count_selected.." из ".. have_slots .." шт. )" )
					end
				end )

			item_area:ibData( "alpha", 0 )
				:ibTimer( function( self )
					self:ibAlphaTo( 255, 250 )
				end, 50 * ( i - 1 ), 1 )
		end

		for i = #veh_list + 1, #str_slots_text do
			local item_area = ibCreateArea( 0, 91 * ( i - 1 ), UIe.scrollpane:ibData( "sx" ), 91, UIe.scrollpane )
			if i > 1 then
				ibCreateImage( 0, 0, item_area:ibData( "sx" ), 1, _, item_area, ibApplyAlpha( COLOR_WHITE, 10 ) )
			end

			ibCreateImage( 30, 30, 40, 30, "images/icon_car.png", item_area, ibApplyAlpha( COLOR_WHITE, 25 ) )
			ibCreateLabel( 100, 0, 0, 0, str_slots_text[ i ], item_area, ibApplyAlpha( COLOR_WHITE, 25 ), 1, 1, "left", "center", ibFonts.regular_16 ):center_y( )
	
			ibCreateImage( item_area:ibData( "sx" ) - 30 - 20, 30, 20, 24, "images/icon_locked.png", item_area, ibApplyAlpha( COLOR_WHITE, 50 ) ):center_y( )

			item_area:ibData( "alpha", 0 )
				:ibTimer( function( self )
					self:ibAlphaTo( 255, 250 )
				end, 50 * ( i - 1 ), 1 )
		end

		UIe.button_unlock = ibCreateButton( 0, UIe.bg:ibData( "sy" ) - 30 - 34, 140, 34, UIe.bg, 
				"images/button_unlock_idle.png", "images/button_unlock_hover.png", "images/button_unlock_click.png", 0xFFFFFFFF, 0xF0FFFFFF, 0xA0FFFFFF ):center_x( )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "up" then return end
						
				if click_timeout > getTickCount() then return end
				click_timeout = getTickCount() + 700
				
				if count_selected ~= have_slots then
					localPlayer:ShowError( "Выберите ровно ".. have_slots .." шт." )
					return
				end
						
				ibClick( )

				triggerServerEvent("PlayerSelectBlockedVehicles", resourceRoot, selected_vehicles)
				HideUIGarage()
			end )
	else
		local have_no_parked_count = 0
		for i = 1, math.min( #veh_list, have_slots ) do
			local info = veh_list[ i ]

			local item_area = ibCreateArea( 0, 91 * ( i - 1 ), UIe.scrollpane:ibData( "sx" ), 91, UIe.scrollpane )
			if i > 1 then
				ibCreateImage( 0, 0, item_area:ibData( "sx" ), 1, _, item_area, ibApplyAlpha( COLOR_WHITE, 10 ) )
			end

			ibCreateImage( 30, 30, 40, 30, "images/icon_car.png", item_area )

			local name_label = ibCreateLabel( 100, 27, 0, 0, info.name, item_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 ):center_y( )
			ibCreateLabel( name_label:ibGetAfterX( 5 ), 27, 0, 0, "(" .. info.numberplate .. ")", item_area, 0xAAFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 ):center_y( )

			if info.confiscated then
				local y = name_label:ibData( "py" )
				name_label:ibData( "py", y - 14 )
				ibCreateLabel( 100, y + 12, 0, 0, "На штрафстоянке", item_area, ibApplyAlpha( COLOR_WHITE, 30 ), 1, 1, "left", "center", ibFonts.regular_14 )
			end

			if info.parked then
				ibCreateButton( item_area:ibData( "sx" ) - 30 - 100, 0, 100, 34, item_area, 
						"images/button_take_idle.png", "images/button_take_hover.png", "images/button_take_hover.png", _, _, 0xFFCCCCCC ):center_y( )
					:ibOnClick( function( button, state )
						if button ~= "left" or state ~= "up" then return end
						
						if click_timeout > getTickCount() then return end
						click_timeout = getTickCount() + 700

						if have_no_parked_count >= 2 then
							localPlayer:ShowError("Нельзя забрать из гаража больше 2-ух автомобилей")
							return
						end

						if info.confiscated then
							localPlayer:ShowError( "Это авто на штрафстоянке" )
							return
						end
						
						ibClick( )

						if type( id ) == "number" then
							triggerServerEvent("PlayerWantTakeParkedVehicle", resourceRoot, id, i)
						elseif type( id ) == "string" then
							triggerServerEvent("PlayerWantTakeParkedVehicleByHouseName", resourceRoot, id, i)
						end
						HideUIGarage()
					end )
			else
				have_no_parked_count = have_no_parked_count + 1

				local btn = ibCreateButton( item_area:ibData( "sx" ) - 30 - 57, 0, 57, 34, item_area, 
					"images/button_teleport_idle.png", "images/button_teleport_hover.png", "images/button_teleport_hover.png", _, _, 0xFFCCCCCC ):center_y( )
					:ibOnClick( function( button, state )
						if button ~= "left" or state ~= "up" then return end
						
						if click_timeout > getTickCount() then return end
						click_timeout = getTickCount() + 700

						if info.confiscated then
							localPlayer:ShowError( "Это авто на штрафстоянке" )
							return
						end

						if not localPlayer:HasMoney( info.price ) then
							localPlayer:ShowError("У вас недостаточно денег")
							return
						end

						ibClick( )

						if type( id ) == "number" then
							triggerServerEvent("PlayerWantTeleportParkedVehicle", resourceRoot, id, i)
						elseif type( id ) == "string" then
							triggerServerEvent("PlayerWantTeleportParkedVehicleByHouseName", resourceRoot, id, i)
						end
						HideUIGarage()
					end )

				local money_img = ibCreateImage( btn:ibGetBeforeX( -10 - 28 ), 0, 28, 28, ":nrp_shared/img/money_icon.png", item_area ):center_y( )
				ibCreateLabel( money_img:ibGetBeforeX( -8 ), 0, 0, 0, format_price( info.price ), item_area, 0xFFFFFFFF, 1, 1, "right", "center", ibFonts.bold_18 ):center_y( )
			end			

			item_area:ibData( "alpha", 0 )
				:ibTimer( function( self )
					self:ibAlphaTo( 255, 250 )
				end, 50 * ( i - 1 ), 1 )
		end

		for i = #veh_list + 1, have_slots do
			local item_area = ibCreateArea( 0, 91 * ( i - 1 ), UIe.scrollpane:ibData( "sx" ), 91, UIe.scrollpane )
			if i > 1 then
				ibCreateImage( 0, 0, item_area:ibData( "sx" ), 1, _, item_area, ibApplyAlpha( COLOR_WHITE, 10 ) )
			end

			ibCreateImage( 30, 30, 40, 30, "images/icon_car.png", item_area )
			ibCreateLabel( 100, 27, 0, 0, "Свободное место", item_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_16 ):center_y( )

			ibCreateImage( item_area:ibData( "sx" ) - 30 - 100, 0, 100, 34, "images/button_take_idle.png", item_area, ibApplyAlpha( COLOR_WHITE, 20 ) ):center_y( )

			item_area:ibData( "alpha", 0 )
				:ibTimer( function( self )
					self:ibAlphaTo( 255, 250 )
				end, 50 * ( i - 1 ), 1 )
		end

		for i = have_slots + 1, #str_slots_text + bought_slots do
			local item_area = ibCreateArea( 0, 91 * ( i - 1 ), UIe.scrollpane:ibData( "sx" ), 91, UIe.scrollpane )
			if i > 1 then
				ibCreateImage( 0, 0, item_area:ibData( "sx" ), 1, _, item_area, ibApplyAlpha( COLOR_WHITE, 10 ) )
			end

			ibCreateImage( 30, 30, 40, 30, "images/icon_car.png", item_area, ibApplyAlpha( COLOR_WHITE, 25 ) )
			local text = str_slots_text[ i - bought_slots ]
			if veh_list[ i ] then
				local txt_area = ibCreateArea( 100, 0, 100, 91, item_area )
				local name_label = ibCreateLabel( 0, 0, 0, 0, veh_list[ i ].name, txt_area, ibApplyAlpha( COLOR_WHITE, 25 ), 1, 1, "left", "center", ibFonts.bold_16 )
				local text_label = ibCreateLabel( 0, name_label:ibGetAfterY( 14 ), 0, 0, text, txt_area, ibApplyAlpha( COLOR_WHITE, 25 ), 1, 1, "left", "center", ibFonts.regular_14 )
				txt_area:ibData( "sy", text_label:ibGetAfterY( -7 ) ):center_y( )
			else
				ibCreateLabel( 100, 0, 0, 0, text, item_area, ibApplyAlpha( COLOR_WHITE, 25 ), 1, 1, "left", "center", ibFonts.regular_16 ):center_y( )
			end
			ibCreateImage( item_area:ibData( "sx" ) - 30 - 20, 30, 20, 24, "images/icon_locked.png", item_area, ibApplyAlpha( COLOR_WHITE, 50 ) ):center_y( )

			item_area:ibData( "alpha", 0 )
				:ibTimer( function( self )
					self:ibAlphaTo( 255, 250 )
				end, 50 * ( i - 1 ), 1 )
		end
	end

	UIe.scrollpane:AdaptHeightToContents()
	UIe.scrollbar:UpdateScrollbarVisibility( UIe.scrollpane )
end
addEvent("ShowUIGarage", true)
addEventHandler("ShowUIGarage", root, ShowUIGarage_handler)

function UIUnlockSubVehicle( veh_list )
	if isElement( UIe.black_bg ) then destroyElement( UIe.black_bg ) end

	showCursor( true )

    UIe.black_bg = ibCreateBackground( 0xBF1D252E, nil, true )
    UIe.bg = ibCreateImage( 0, 0, 800, 600, _, UIe.black_bg, ibApplyAlpha( 0xFF475d75, 97 ) ):center()

	UIe.head_bg    = ibCreateImage( 0, 0, UIe.bg:ibData( "sx" ), 72, _, UIe.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
                     ibCreateImage( 0, UIe.head_bg:ibGetAfterY( -1 ), UIe.bg:ibData( "sx" ), 1, _, UIe.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
	UIe.head_label = ibCreateLabel( 30, 0, 0, UIe.head_bg:ibData( "sy" ), "Выбор авто", UIe.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
	
	UIe.btn_close = ibCreateButton( UIe.bg:ibData( "sx" ) - 55, 24, 25, 25, UIe.head_bg, "images/button_close.png", "images/button_close.png", "images/button_close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC)
		:ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
			ibClick( )

			HideUIGarage( )
		end)

	UIe.scrollpane, UIe.scrollbar = ibCreateScrollpane( 0, UIe.head_bg:ibGetAfterY(), UIe.bg:ibData( "sx" ), UIe.bg:ibData( "sy" ) - UIe.head_bg:ibData( "sy" ), UIe.bg, { scroll_px = -20 } )
	UIe.scrollbar:ibSetStyle( "slim_nobg" )

	for i, info in ipairs( veh_list ) do
		local item_area = ibCreateArea( 0, 91 * ( i - 1 ), UIe.scrollpane:ibData( "sx" ), 91, UIe.scrollpane )
		if i > 1 then
			ibCreateImage( 0, 0, item_area:ibData( "sx" ), 1, _, item_area, ibApplyAlpha( COLOR_WHITE, 10 ) )
		end

		ibCreateImage( 30, 30, 40, 30, "images/icon_car.png", item_area )

		ibCreateLabel( 100, 27, 0, 0, info.name, item_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 ):center_y( )
		
		ibCreateButton( item_area:ibData( "sx" ) - 30 - 128, 0, 128, 44, item_area, 
			"images/button_attach_idle.png", "images/button_attach_hover.png", "images/button_attach_hover.png", _, _, 0xFFCCCCCC ):center_y( )
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "up" then return end
				ibClick( )
				
				triggerServerEvent( "PlayerSelectSubscriptionUnlockVehicle", resourceRoot, info.id )
				HideUIGarage( )
			end )

		item_area:ibData( "alpha", 0 )
			:ibTimer( function( self )
				self:ibAlphaTo( 255, 250 )
			end, 100 * ( i - 1 ), 1 )
	end

	UIe.scrollpane:AdaptHeightToContents()
	UIe.scrollbar:UpdateScrollbarVisibility( UIe.scrollpane )
end
addEvent( "ShowUIUnlockSubVehicle", true)
addEventHandler( "ShowUIUnlockSubVehicle", root, UIUnlockSubVehicle )

function HideUIGarage( )
	if isElement( UIe and UIe.black_bg ) then
		destroyElement( UIe.black_bg )
	end
	showCursor( false )

	SELECTED_TAB = nil
end
addEvent( "HideUIGarage", true )
addEventHandler( "HideUIGarage", root, HideUIGarage )
