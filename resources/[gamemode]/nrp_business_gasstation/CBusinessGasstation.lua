loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CVehicle" )
Extend( "ShVehicleConfig" )
Extend( "ShBusiness" )
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "CSound" )
Extend( "ib" )
Extend( "CInterior" )

ibUseRealFonts( true )

UI = {}
GASSTATION_CONFIG = {
	sx = 632,
	sy = 264,
}
GASSTATION_CONFIG.px = _SCREEN_X / 2 - GASSTATION_CONFIG.sx / 2
GASSTATION_CONFIG.py = _SCREEN_Y - GASSTATION_CONFIG.sy

selected_level = 0

function GasstationStart()
	Timer( function()
		for i, data in pairs( BUSINESS_ELEMENTS ) do
			if data.business_id == 1 then
				GasstationCreatePoint( ( data.building_type == "gas" or data.building_type == "electro" ) and true or false, data )
			end
		end
	end, 1000, 1 )
end
addEventHandler( "onClientResourceStart", resourceRoot, GasstationStart )

function GasstationCreatePoint( gasPoint, config )
	--Заправка
	if gasPoint then
		config.accepted_elements = { vehicle = true }
		config.keypress = "lalt"
		config.text = "ALT Взаимодействие"
		config.radius = config.radius or 3
		config.marker_image = config.icon or "img/blue.png"
		config.marker_text = config.name or "ОАО 'Газпром'"
		config.slowdown_coefficient = 3
		config.support_stay = true
		config.y = config.y + 860
		local gasstation = TeleportPoint( config )
		local r, g, b, a = 0, 100, 200, 50
		if config.color then
			r, g, b, a = unpack( config.color )
		end
		gasstation.marker:setColor( r, g, b, a )
		gasstation.element:setData( "material", true, false )
    	gasstation:SetDropImage( { ":nrp_shared/img/dropimage.png", r, g, b, 255, 2.3 } )
		gasstation.PreJoin = function( gasstation, player )
			if player.vehicle:GetSpecialType() and player.vehicle:GetSpecialType() ~= "moto" then return end
	
			if gasstation.is_air then
				local type = getVehicleType( player.vehicle )
				if type ~= "Helicopter" and type ~= "Plane" then
					return false, "Здесь можно заправлять только авиатехнику"
				end
			end

			local is_electric = VEHICLE_CONFIG[ localPlayer.vehicle.model ].is_electric
			if config.building_type == "gas" and is_electric then
				return false, "Здесь можно заправлять только бензиновую технику"
			elseif config.building_type == "electro" and not is_electric then
				return false, "Здесь можно заряжать только электрическую технику"
			end

			local faction = player.vehicle:GetFaction( )
			if faction and faction > 0 then
				player.vehicle:GiveFuel( player.vehicle:GetMaxFuel() )
				player:ShowSuccess( "Фракционный транспорт заправлен" )
				return false
			end
	
			return true
		end
		gasstation.PostJoin = function()
			GasstationShowUI_handler( true, { vehicle = localPlayer.vehicle, is_air = gasstation.is_air } )
		end
		gasstation.PostLeave = function()
			GasstationShowUI_handler( false )
		end

	--Выдача канистр
	else
		config.accepted_elements = { player = true }
		config.keypress = false
		config.radius = 2
		config.marker_image = "img/red.png"
		config.marker_text = "Магазин"
		config.slowdown_coefficient = 3
		config.y = config.y + 860
		local gasjerry = TeleportPoint( config )
		gasjerry.element:setData( "material", true, false )
    	gasjerry:SetDropImage( { ":nrp_shared/img/dropimage.png", 255,0,0, 255, 1.55 } )
		gasjerry.marker:setColor(255,0,0,50)
		gasjerry.PostJoin = function()
			GasstationJerryShowUI_handler( true, { vehicle = localPlayer.vehicle, title = config.title or "Газпром" } )
		end
		gasjerry.PostLeave = function()
			GasstationJerryShowUI_handler( false )
		end
		gasjerry.elements = { }
		gasjerry.elements.blip = Blip( config.x, config.y, config.z, 33, 2, 255, 0, 0, 255, 0, 300 )
	end
end

function ConvertPercentToLiter( percent, fuel_max, fuel )
	return  math.floor( percent == 100 and fuel or percent * fuel_max / 100 )
end

--Меню заправки
addEvent( "GasstationShowUI", true )
function GasstationShowUI_handler( state, conf )
	if state then
		GasstationShowUI_handler( false )

		local vehicle = conf.vehicle
		local is_electric = VEHICLE_CONFIG[ vehicle.model ].is_electric

		if VEHICLE_TYPE_BIKE[ vehicle.model ] then
			localPlayer:ShowInfo( "Данный вид транспорта не требует заправки" )
			return
		end

		local fuel = math.floor( vehicle:GetMaxFuel( ) - vehicle:GetFuel( ) )

		local levels = { math.floor( fuel ) }
		local percents = { 10, 20, 40, 60, 80 }
		for i, v in pairs( percents ) do
			local percent = math.floor( v / 100 * vehicle:GetMaxFuel( ) )
			table.insert( levels, percent )
		end

		local levels_required = {}
		local levels_used = {}
		for i, v in pairs( levels ) do
			if v <= fuel and v > 0 and not levels_used[ v ] then
				table.insert( levels_required, v )
				levels_used[ v ] = true
			end
		end
		table.sort( levels_required )

		if #levels_required <= 0 then
			localPlayer:ShowInfo( "Ваш транспорт не требует " .. ( is_electric and "зарядки" or "заправки" ) )
			return
		end

		local sy = 100 + ( #levels_required ) * 35

		UI.black_bg = ibCreateBackground( _, GasstationShowUI_handler, true, true )
		UI.bg = ibCreateImage( GASSTATION_CONFIG.px, GASSTATION_CONFIG.py, GASSTATION_CONFIG.sx, GASSTATION_CONFIG.sy, is_electric and "img/bg_e.png" or "img/bg.png", UI.black_bg )

		local fuel_max = vehicle:GetMaxFuel( )

		local sx, sy = 40, 120
		for i = 1, 6 do
			local iAmount = 5 * i
			if i == 6 then
				iAmount = is_electric and 100 or fuel
				if iAmount < 25 then
					break
				end
			end

			iAmount = math.floor( iAmount )

			UI[ "fuelamount_box"..i ] = ibCreateImage( sx, sy, 50, 34, nil, UI.bg, 0x00FFFFFF )

			UI[ "fuelamount"..i ] = ibCreateButton( 0, 0, 50, 34, UI[ "fuelamount_box"..i ], "img/rectangle.png", "img/rectangle.png", "img/rectangle.png", 0xFFAAAAAA, 0xFFFFFFFF, 0xFFFFFFFF )
			ibCreateLabel( 0, 0, 0, 0, iAmount .. ( is_electric and "%" or " л." ), UI[ "fuelamount"..i ], _, _, _, "center", "center", ibFonts.bold_11 ):center( )

			UI[ "fuelamount"..i ]:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "down" then return end

				ibClick( )

				selected_level = is_electric and ConvertPercentToLiter( iAmount, fuel_max, fuel ) or iAmount
				UI.price:ibData( "text", format_price( vehicle:GetFuelPrice( selected_level ) ) )

				for c = 1, 6 do
					if isElement( UI[ "fuelamount_box" .. c ] ) then
						if c == i then
							UI[ "fuelamount_box" .. c ]:ibData( "color", 0xFF4444FF )
						else
							UI[ "fuelamount_box" .. c ]:ibData( "color", 0x00FFFFFF )
						end
					end
				end
			end )

			sx = sx + 50
		end

		UI.num1 = ibCreateLabel( 468, 70, 30, 40, "0", UI.bg, COLOR_BLACK, _, _, "center", "center", ibFonts.regular_15 )
		UI.num2 = ibCreateLabel( 506, 70, 30, 40, "0", UI.bg, COLOR_BLACK, _, _, "center", "center", ibFonts.regular_15 )
		UI.num3 = ibCreateLabel( 543, 70, 30, 40, "0", UI.bg, COLOR_BLACK, _, _, "center", "center", ibFonts.regular_15 )

		UI.black_bg:ibOnRender( function( )
			local fuel_str = string.format( "%03d", tostring( math.floor( is_electric and vehicle:GetFuel( ) * 100 / fuel_max or vehicle:GetFuel( ) ) ) )

			for i = 3, 1, -1 do
				local s = string.sub( fuel_str, i, i ) or 0
				UI[ "num".. i ]:ibData( "text", s ~= "" and s or 0 )
			end
		end )

		UI.close = ibCreateButton( GASSTATION_CONFIG.px + GASSTATION_CONFIG.sx - 25, GASSTATION_CONFIG.py - 30, 25, 25, UI.black_bg,
								":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
								0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				GasstationShowUI_handler( false )
			end )

		UI.buy = ibCreateButton( 40, 182, 138, 44, UI.bg, "img/btn_buy.png", "img/btn_buy.png", "img/btn_buy.png", 0xFFDDDDDD, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "down" then return end
				if not selected_level or selected_level <= 0 then return end
				triggerServerEvent( "onGasstationFillRequest", localPlayer, vehicle, selected_level )
			end )
			:ibData( "color_disabled", 0x77ffffff )

		UI.price = ibCreateLabel( 250, 185, 80, 40, "", UI.bg, _, _, _, "left", "center", ibFonts.regular_15 )

		if conf.filling then
			UI.buy:ibData( "disabled", true )
		end

		showCursor( true )
	else
		if isElement( UI and UI.black_bg ) then
            destroyElement( UI.black_bg )
        end
		UI = {}
		showCursor( false )
		selected_level = 0
	end
end
addEventHandler( "GasstationShowUI", localPlayer, GasstationShowUI_handler )

--Меню покупки канистры
addEvent( "GasstationJerryShowUI", true )
function GasstationJerryShowUI_handler( state, conf )
	if state then
		GasstationJerryShowUI_handler( false )

		showCursor( true )
		local oil_count = 1
		local battery_count = 1
		local all_cost = 5000

		UI.black_bg = ibCreateBackground( 0xaa000000, GasstationJerryShowUI_handler, true, true )
			:ibData( "alpha", 0 )
			:ibAlphaTo( 255, 500 )

        UI.bg_texture = dxCreateTexture( "img/shop/bg.png" )
        local sx, sy = dxGetMaterialSize( UI.bg_texture )
        local px, py = _SCREEN_X / 2 - sx / 2, _SCREEN_Y / 2 - sy / 2

		UI.bg_image = ibCreateImage( px, py + 100, sx, sy, "img/shop/bg.png", UI.black_bg )
			:ibMoveTo( px, py, 200 )
        UI.bg = ibCreateRenderTarget( 0, 0, sx, sy, UI.bg_image )
			:ibData( "modify_content_alpha", true )
		
		ibCreateButton( 450, 24, 24, 24, UI.bg,
						":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
						0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				GasstationJerryShowUI_handler( false )
			end )

		ibCreateLabel( 287, 34, 0, 0, "“" .. conf.title .. "”", UI.bg, 0xffffffff, _, _, "left", "center", ibFonts.bold_18 )

		ibCreateLabel( 53, 98, 0, 0, "Канистра с Бензином:", UI.bg, 0x90ffffff, _, _, "left", "center", ibFonts.regular_14 )
		ibCreateLabel( 315, 98, 0, 0, "Батарея с Зарядом:", UI.bg, 0x90ffffff, _, _, "left", "center", ibFonts.regular_14 )

		ibCreateImage( 59, 127, 131, 170, "img/shop/oil.png", UI.bg )
		ibCreateImage( 314, 127, 131, 170, "img/shop/battery.png", UI.bg )
		ibCreateLabel( 112, 264, 0, 0, "20л", UI.bg, 0x90ffffff, _, _, "left", "center", ibFonts.bold_20 )
		ibCreateLabel( 360, 264, 0, 0, "25%", UI.bg, 0x90ffffff, _, _, "left", "center", ibFonts.bold_20 )
		ibCreateLabel( 20, 411, 0, 0, "Стоимость:", UI.bg, 0x90ffffff, _, _, "left", "center", ibFonts.regular_16 )

		local cost_lbl = ibCreateLabel( 115, 408, 0, 0, all_cost, UI.bg, 0xffffffff, _, _, "left", "center", ibFonts.bold_24 )
		local btn = ibCreateImage( 350, 389, 120, 44, "img/shop/btn_buy.png", UI.bg )
		
		ibCreateImage( 0, 0, 0, 0, "img/shop/btn_buy.png", btn ):ibSetRealSize( ):center( )
			:ibData( "alpha", 200 )
			:ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
			:ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
					ibClick( )
					ibConfirm(
							{
								title = "ПОКУПКА КАНИСТРЫ",
								text = "Ты хочешь купить товар за "..all_cost.." ?" ,
								fn = function( self )
									triggerServerEvent( "onGasstationJerryBuyRequest", localPlayer, oil_count, battery_count )
									self:destroy()
								end,
								escape_close = true,
							}
						)
			end )

		ibCreateImage( 106, 317, 48, 30, "img/shop/stroke.png", UI.bg )
		local count_lbl_oil = ibCreateLabel( 129, 332, 0, 0, oil_count, UI.bg, 0xffffffff, _, _, "center", "center", ibFonts.bold_18 )

		ibCreateImage( 356, 317, 48, 30, "img/shop/stroke.png", UI.bg )
		local count_lbl_battery = ibCreateLabel( 380, 332, 0, 0, battery_count, UI.bg, 0xffffffff, _, _, "center", "center", ibFonts.bold_18 )

		ibCreateButton( 70, 317, 30, 30, UI.bg,
			"img/shop/minus.png", "img/shop/minus.png", "img/shop/minus.png",
			0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				if oil_count >= 1 then
				oil_count = oil_count - 1
				all_cost = all_cost - 2500
				count_lbl_oil:ibData( "text", oil_count )
				cost_lbl:ibData( "text", all_cost )
				end
			end )
		ibCreateButton( 159, 317, 30, 30, UI.bg,
			"img/shop/plus.png", "img/shop/plus.png", "img/shop/plus.png",
			0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				if oil_count >= 0 and oil_count < 99 then
					oil_count = oil_count + 1
					all_cost = all_cost + 2500
					count_lbl_oil:ibData( "text", oil_count )
					cost_lbl:ibData( "text", all_cost )
				end
			end )

		ibCreateButton( 320, 317, 30, 30, UI.bg,
			"img/shop/minus.png", "img/shop/minus.png", "img/shop/minus.png",
			0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				if battery_count >= 1 then
				battery_count = battery_count - 1
				all_cost = all_cost - 2500
				count_lbl_battery:ibData( "text", battery_count )
				cost_lbl:ibData( "text", all_cost )
				end
			end )
		ibCreateButton( 409, 317, 30, 30, UI.bg,
			"img/shop/plus.png", "img/shop/plus.png", "img/shop/plus.png",
			0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )
				if battery_count >= 0 and battery_count < 99 then
					battery_count = battery_count + 1
					all_cost = all_cost + 2500
					count_lbl_battery:ibData( "text", battery_count )
					cost_lbl:ibData( "text", all_cost )
				end
			end )

		showCursor( true )
	else
		if isElement( UI and UI.black_bg ) then
            destroyElement( UI.black_bg )
        end
		UI = {}
		showCursor( false )
	end
end
addEventHandler( "GasstationJerryShowUI", localPlayer, GasstationJerryShowUI_handler )

function StartFillingSound( conf )
	START_SOUND = Sound3D( "sfx/fuel_up_get.wav", localPlayer.vehicle.position, false )
	setSoundMaxDistance( START_SOUND, 10 )
	
	setTimer( function()
		FILLING_SOUND = Sound3D( "sfx/fuel_up_pour.wav", localPlayer.vehicle.position, true )
		setSoundMaxDistance( FILLING_SOUND, 10 )
	end, 1050, 1 )
end
addEvent( "StartFillingSound", true )
addEventHandler( "StartFillingSound", localPlayer, StartFillingSound )

function StopFillingSound()
	if isElement( FILLING_SOUND ) then FILLING_SOUND:destroy( ) end
	GasstationShowUI_handler( false )
end
addEvent( "StopFillingSound", true )
addEventHandler( "StopFillingSound", localPlayer, StopFillingSound )

addEventHandler( "onClientPlayerWasted", localPlayer, function( )
	if isElement( UI and UI.bg ) then
		GasstationShowUI_handler( false )
	end
end )