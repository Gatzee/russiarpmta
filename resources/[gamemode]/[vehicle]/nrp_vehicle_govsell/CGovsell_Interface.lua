local UI, UI_INFO
Extend( "ib" )
Extend( "CVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShUtils" )
local TEMP_VEHLIST

function ShowGovsellUI( state, conf )
	if state then
		ShowGovsellUI( false )
		UI = { }

		UI.black_bg = ibCreateBackground( 0x99000000, function()
			ShowGovsellUI( false )
			TEMP_VEHLIST = nil
		end, true, true )
		:ibData( "alpha", 0 )
		:ibAlphaTo( 255, 500 )

		local sx, sy = 800, 600
		local x, y = guiGetScreenSize( )
		local px, py = ( x - sx ) / 2, ( y - sy ) / 2

		UI.bg = ibCreateImage( px, py + 100, sx, sy, "img/bg.png", UI.black_bg )
			:ibMoveTo( px, py, 500 )

        ibInterfaceSound()
		ibCreateLabel( 30, 35, 0, 0, "Продажа транспорта государству", UI.bg, _, _, _, "left", "center", ibFonts.bold_18 )

		UI.rt, UI.sc = ibCreateScrollpane( 0, 72, sx, 528, UI.bg, { scroll_px = -20 } )
		UI.sc
			:ibSetStyle( "slim_nobg" )
			:ibBatchData( { sensivity = 100, absolute = true, color = 0x99ffffff } )

		RefreshVehicleList( conf.list )

		ibCreateButton( sx - 24 - 26, 24, 24, 24, UI.bg, 
						":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 
						0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				ShowGovsellUI( false )
				TEMP_VEHLIST = nil
			end, false )

		showCursor( true )

	else
		DestroyTableElements( UI )
		UI = nil
		showCursor( false )

	end
end

function RefreshVehicleList( list )
	if not UI then return end
	DestroyTableElements( getElementChildren( UI.rt ) )

	local list = list or {}

	local height = 90
	local npy = 0

	for i, v in pairs( list ) do
		local area = ibCreateArea( 0, npy, 800, height, UI.rt )

		-- Название
		local name = GetVehicleNameFromModel( v.model ) or v.model
		local icon = ibCreateImage( 30, 0, 0, 0, "img/icon_vehicle.png", area ):ibSetRealSize( ):center_y( )
		ibCreateLabel( icon:ibGetAfterX( 30 ), 0, 0, 0, name, area, _, _, _, "left", "center", ibFonts.regular_16 ):center_y( )

		-- Цена
		local variant = v.variant or 1
		local cost = math.floor( ( v.cost or ( VEHICLE_CONFIG[ v.model ].variants[ variant ] or VEHICLE_CONFIG[ v.model ].variants[ 1 ] ).cost or 0 ) )
		
		v.cost = cost 
		v.name = name
		v.color = v.color
		v.max_speed = VEHICLE_CONFIG[ v.model ].variants[ variant ] and VEHICLE_CONFIG[ v.model ].variants[ variant ].max_speed or VEHICLE_CONFIG[ v.model ].variants[ 1 ].max_speed
		v.acceleration = VEHICLE_CONFIG[ v.model ].variants[ variant ] and VEHICLE_CONFIG[ v.model ].variants[ variant ].stats_acceleration or VEHICLE_CONFIG[ v.model ].variants[ 1 ].stats_acceleration
		v.dskill = VEHICLE_CONFIG[ v.model ].variants[ variant ] and VEHICLE_CONFIG[ v.model ].variants[ variant ].stats_handling or VEHICLE_CONFIG[ v.model ].variants[ 1 ].stats_handling

		local cost = format_price( cost )
		local lbl_cost_title = ibCreateLabel( 374, 0, 0, 0, "Стоимость:", area, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left" ,"center", ibFonts.regular_14 ):center_y( )
		local lbl_cost = ibCreateLabel( lbl_cost_title:ibGetAfterX( 10 ), 0, 0, 0, cost, area, _, _, _, "left", "center", ibFonts.bold_20 ):center_y( )
		ibCreateImage( lbl_cost:ibGetAfterX( 5 ), lbl_cost:ibGetCenterY( ) - 12, 24, 24, ":nrp_shared/img/money_icon.png", area )

		-- Кнопка продажи
		local bg = ibCreateImage( 670, 0, 0, 0, "img/btn_sell.png", area ):ibSetRealSize( ):center_y( ):ibData( "alpha", 200 )
			:ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
			:ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )

		-- Обработка ошибок
		local error_msg_list = { }

		if v.is_untradable then
			table.insert( error_msg_list, ERR_UNTRADABLE )
		end

		if v.trade_time_left then
			table.insert( error_msg_list, "Этот транспорт можно будет продать через " .. v.trade_time_left .. " ч." )
		end

		if v.is_not_owned then
			table.insert( error_msg_list, ERR_NOT_OWNED )
		end

		if v.is_on_taxi then
			table.insert( error_msg_list, ERR_IS_ON_TAXI )
		end

		if #error_msg_list > 0 then
			local area_overlay = ibCreateImage( 0, 0, area:width( ), area:height( ), _, area, 0x99000000 ):ibData( "priority", 1 )
			area_overlay:ibAttachTooltip( error_msg_list[ 1 ] )

		else
			bg:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				ShowGovsellUI( false )
				ShowGovsellInfoUI_handler( true, v )
			end )
		end

		-- Разделение линией
		if i ~= #list then ibCreateLine( 30, height, 740, _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, area ) end

		npy = npy + height
	end

	UI.rt:AdaptHeightToContents( )
	UI.sc:UpdateScrollbarVisibility( UI.rt )
end

function ShowGovsellInfoUI_handler( state, data )
	if state then
		UI_INFO = {}
		UI_INFO.black_bg = ibCreateBackground( 0x99000000, function()
			ShowGovsellInfoUI_handler( false )
			ShowGovsellUI( true, { list = TEMP_VEHLIST } )
		end, true, true )
		:ibData( "alpha", 0 )
		:ibAlphaTo( 255, 500 )

		UI_INFO.bg = ibCreateImage( 0, 0, 0, 0, "img/bg3.png" )
		:ibSetRealSize()
		:center()
		
		UI_INFO.lbl_cost = ibCreateLabel( 440, 80, 0, 0, format_price( data.cost ), UI_INFO.bg )
		:ibData( "font", ibFonts.bold_14 )
		UI_INFO.lbl_cost_img = ibCreateImage(  UI_INFO.lbl_cost:ibGetAfterX( 7 ),  UI_INFO.lbl_cost:ibGetCenterY() - 14, 28, 28, ":nrp_shared/img/money_icon.png", UI_INFO.bg )
		ibCreateLabel( UI_INFO.lbl_cost_img:ibGetAfterX( 10 ), 80, 1, 1, "?", UI_INFO.bg )
		:ibData( "font", ibFonts.bold_14 )

		UI_INFO.lbl_model = ibCreateLabel( 128, 155, 0, 0, data.name, UI_INFO.bg )
		:ibData( "font", ibFonts.bold_14 )

		UI_INFO.color = ibCreateImage( 67.5, 196.5, 20.5, 20.5, _, UI_INFO.bg, tocolor( unpack( data.color ) ) )

		UI_INFO.lbl_model = ibCreateLabel( 69, 229, 0, 0, "Class " .. data.class, UI_INFO.bg )
		:ibData( "font", ibFonts.bold_14 )

		ibCreateButton( 800 - 24 - 26, 20, 24, 24, UI_INFO.bg, 
			":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 
			0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			ShowGovsellInfoUI_handler( false )
			ShowGovsellUI( true, { list = TEMP_VEHLIST } )
		end, false )

		UI_INFO.lbl_max_speed = ibCreateLabel( 229, 352, 0, 0, data.max_speed, UI_INFO.bg )
		:ibData( "font", ibFonts.bold_14 )
		UI_INFO.lbl_acceleration = ibCreateLabel( 135, 389, 0, 0, data.acceleration, UI_INFO.bg )
		:ibData( "font", ibFonts.bold_14 )
		UI_INFO.lbl_dskill = ibCreateLabel( 143, 427, 0, 0, data.dskill, UI_INFO.bg )
		:ibData( "font", ibFonts.bold_14 )
		UI_INFO.cancel = ibCreateButton( 28, 530, 0, 0, UI_INFO.bg, "img/but_cancel_sell.png", "img/but_cancel_sell.png", "img/but_cancel_sell.png", 0xCCFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF  )
		:ibSetRealSize()
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			ShowGovsellInfoUI_handler( false )
			ShowGovsellUI( true, { list = TEMP_VEHLIST } )
		end, false )

		UI_INFO.apply = ibCreateButton( UI_INFO.cancel:ibGetAfterX( 23 ), 530, 0, 0, UI_INFO.bg, "img/but_apply_sell.png", "img/but_apply_sell.png", "img/but_apply_sell.png", 0xCCFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF  )
		:ibSetRealSize()
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			if confirmation then confirmation:destroy( ) end
			confirmation = ibConfirm(
			    {
			        title = "ПРОДАЖА ТРАНСПОРТА",
			        text = "Ты действительно хочешь продать\n" .. data.name .. " за " .. data.cost .. " р. ?\nЭто действие нельзя отменить",
					fn = function( self )
						if not data.is_inventory_empty then
							ConfirmInventoryReset( data )
						else
							RequestVehicleSell( data )
						end
			            self:destroy( )
					end,
					escape_close = true,
			    }
			)
		end, false )
	else
		for i, v in pairs( UI_INFO ) do
			if isElement( v ) then v:destroy(); end
		end
		UI_INFO = {}
	end
	showCursor( state )
end

function ConfirmInventoryReset( data )
	if confirmation then confirmation:destroy( ) end
	confirmation = ibConfirm(
		{
			title = "ПРОДАЖА ТРАНСПОРТА",
			text = "Предметы в багажнике будут уничтожены",
			fn = function( self )
				self:destroy( )
				RequestVehicleSell( data )
			end,
			escape_close = true,
		}
	)
end

function RequestVehicleSell( data )
	triggerServerEvent( "onVehicleSellRequest", resourceRoot, data, CURRENT_SPECIAL_TYPES )
	ShowGovsellInfoUI_handler( false )
	ShowGovsellUI( true, { list = { } } )
end

function ShowGovsell_handler( list, update_only )
	if #list <= 0 then
		ShowGovsellUI( false )
		return
	end
	
	if update_only then
		RefreshVehicleList( list )
	else
		ShowGovsellUI( true, { list = list } )
		TEMP_VEHLIST = list
	end
end
addEvent( "ShowGovsell", true )
addEventHandler( "ShowGovsell", root, ShowGovsell_handler )