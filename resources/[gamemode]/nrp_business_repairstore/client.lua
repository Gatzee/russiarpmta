Extend( "ShBusiness" )
Extend( "CInterior" )
Extend( "CVehicle" )
Extend( "CPlayer" )
Extend( "ib" )

ibUseRealFonts( true )
local UI_bg = nil

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	for i, data in pairs( BUSINESS_ELEMENTS ) do
		if data.business_id == 2 then
			local config = { }
			config.x, config.y, config.z = data.x, data.y +860, data.z

			local is_create_blip = true
			for k,v in pairs( getElementsByType("blip") ) do
				if getBlipIcon(v) == 27 then
					if (v.position - Vector3(config.x, config.y +860, config.z)).length <= 50 then
						is_create_blip = false
						break
					end
				end
			end

			if is_create_blip then
				config.elements = { }
				config.elements.blip = createBlip( config.x, config.y +860, config.z, 27, 2, 255, 0, 0, 255, 0, 300 )
			end

			config.radius = 3
			config.marker_text = ""
			config.keypress = "lalt";
			config.text = "ALT Взаимодействие"
			config.accepted_elements = { vehicle = true }

			tpoint = TeleportPoint( config )
			tpoint.marker:setColor( 0, 100, 200, 10 )

			tpoint:SetImage( { "img/icon.png", 255, 255, 255, 255, 3 } )
			tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 0, 100, 200, 255, 2.2 } )

			tpoint.PreJoin = function( seld, player )
				if player.vehicle == nil then return false end
				local special_type = player.vehicle:GetSpecialType( )
				if special_type and special_type ~= "moto" then return false end

				return true
			end

			tpoint.PostJoin = function( self, player )
				if isElement( UI_bg ) then return end

				triggerServerEvent( "RequestRepairData", resourceRoot )
			end

			tpoint.PostLeave = function( self, player )
				DestroyUI( )
			end
		end
	end
end )

addEvent( "CreateRepairUI", true )
addEventHandler( "CreateRepairUI", resourceRoot, function( status_number, capital_repair_count, capital_repair_cost )
	local vehicle = localPlayer.vehicle
	if not vehicle then return end

	DestroyUI( )

	UI_bg = ibCreateBackground( nil, DestroyUI, nil, true ):ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )
	showCursor( true )

	local bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI_bg ):center( )

	ibCreateButton(	972, 26, 24, 24, bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
	:ibOnClick( function( key, state )
		if key ~= "left" or state ~= "up" then return end

		ibClick( )
		DestroyUI( )
	end )

	do
		local variant = variant or vehicle:GetVariant( ) or 1
		local vehicle_name = VEHICLE_CONFIG[ vehicle.model ].model
		local vehicle_variant_name = VEHICLE_CONFIG[ vehicle.model ].variants[ variant ].mod or ""
		ibCreateLabel( 115, 116, 0, 0, vehicle_name .." ".. vehicle_variant_name, bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_16 )
	end

	do
		local vehicle_status = VEHICLE_CONFIG[ vehicle.model ].is_moto and MOTO_STATUS_NAMES[ status_number ] or CAR_STATUS_NAMES[ status_number ]
		local lbl = ibCreateLabel( 123, 148, 0, 0, vehicle_status, bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_16 )

		local loss = {
			[ STATUS_TYPE_HARD ] = 10,
			[ STATUS_TYPE_CRIT ] = 20,
		}
		if loss[ status_number ] then
			ibCreateLabel( lbl:ibGetAfterX( 10 ), 148, 0, 0, "(скорость снижена на " .. ( loss[ status_number ] or 0 ) .. ")", bg, ibApplyAlpha( 0xffffde9e, 60 ), 1, 1, "left", "center", ibFonts.regular_14 )
		end
	end

	ibCreateLabel( 246, 180, 0, 0, capital_repair_count, bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_16 )

	local repair_price = GetRepairPrice( vehicle )
	do
		local repair_engine_cost = GetEngineRepairCost( vehicle, repair_price )
		local repair_wheels_cost = GetWheelsRepairCost( vehicle, repair_price )
		local repair_cost = repair_engine_cost + repair_wheels_cost
		if repair_cost > 0 then
			local icon_bg = ibCreateArea( 266, 578, 0, 0, bg )
			if repair_engine_cost > 0 and repair_wheels_cost > 0 then
				ibCreateImage( 0, 0, 205, 71, "img/icon_engine_and_wheels.png", icon_bg ):center( )
			else
				if repair_engine_cost > 0 then
					ibCreateImage( 0, 0, 83, 71, "img/icon_engine.png", icon_bg ):center( )
				else
					ibCreateImage( 0, 0, 70, 70, "img/icon_wheels.png", icon_bg ):center( )
				end
			end

			ibCreateButton(	352, 628, 130, 42, bg, "img/btn_buy", true )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end

				ibClick( )
				triggerServerEvent( "RequestRepair", resourceRoot )
				DestroyUI( )
			end )

			ibCreateLabel( 50, 649, 0, 0, "Стоимость:", bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_18 )
			local lbl = ibCreateLabel( 154, 649, 0, 0, format_price( repair_cost ), bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_21 )
			ibCreateImage( lbl:ibGetAfterX( 10 ), 635, 28, 28, ":nrp_shared/img/money_icon.png", bg )
		else
			ibCreateLabel( 265, 592, 0, 0, "Ремонт не требуется", bg, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "center", "center", ibFonts.regular_18 )
		end
	end

	do
		if capital_repair_cost > 0 then
			ibCreateImage( 635, 543, 246, 70, "img/icon_capital_repair.png", bg )
			ibCreateButton(	844, 628, 130, 42, bg, "img/btn_buy", true )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end

				ibClick( )
				ibConfirm( {
					title = "ПОДТВЕРЖДЕНИЕ ОПЛАТЫ",
					text = "Вы уверены, что хотите выполнить капитальный ремонт за " .. format_price( capital_repair_cost ) .. " р.?",
					fn = function( self )
						self:destroy( )
						triggerServerEvent( "RequestCapitalRepair", resourceRoot )
						DestroyUI( )
					end,
					escape_close = true,
				} )
			end )

			ibCreateLabel( 542, 649, 0, 0, "Стоимость:", bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_18 )
			local lbl = ibCreateLabel( 646, 649, 0, 0, format_price( capital_repair_cost ), bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_21 )
			ibCreateImage( lbl:ibGetAfterX( 10 ), 635, 28, 28, ":nrp_shared/img/money_icon.png", bg )
		else
			ibCreateLabel( 758, 592, 0, 0, "Ремонт не требуется", bg, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "center", "center", ibFonts.regular_18 )
		end
	end
end )

function DestroyUI( )
	showCursor( false )

	if isElement( UI_bg ) then
		UI_bg:destroy( )
	end
end