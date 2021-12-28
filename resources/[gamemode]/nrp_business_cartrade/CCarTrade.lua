loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )
Extend( "CVehicle" )
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "ShVehicleConfig" )
Extend( "ib" )

CHECK_VELOCITY_TIMER = nil

local scX, scY = guiGetScreenSize()
local UI = {}
local COSTS_INFO = {
	{ left = "Рекомендуемая стоимость - ", key = "recommended" },
	{ left = "Минимальная стоимость - ", key = "min" },
	{ left = "Максимальная стоимость - ", key = "max" },
	{ left = "Для ввода доступны только цифры" },
};
local STATS_INFO = {
	{ left = "Мощность", key = "power", right = "л.с." },
	{ left = "Разгон до 100 км/ч", key = "ftc", right = "с" },
	{ left = "Расход топлива", key = "fuel_loss", right = "л" },
	{ left = "Максимальная скорость", key = "max_speed", right = "км/ч" },
};
local STATS_LIMITS = {
	['power'] = 1000,
	['ftc'] = 30,
	['fuel_loss'] = 30,
	['max_speed'] = 500,
};

local MODF_INFO = {
	{ left = "Комплектация", key = "modf" },
	{ left = "Вместимость", key = "inventory_max_weight", right = "кг" },
	{ left = "Пробег", key = "mileage", right = "км" },
	{ left = "Привод", key = "gear" },
};
local MILEAGE = 0

addEvent( "CarTradeUIState", true )
function CarTradeUIState_handler( state, veh, page, trade_data )
	if state and not UI.black_bg then
		MILEAGE = mileage or MILEAGE
		ibInterfaceSound()
		CHECK_VELOCITY_TIMER = setTimer( function()
			if not isElement( localPlayer.vehicle ) then
				CarTradeUIState_handler( false )
			end
			if localPlayer.vehicle.velocity:getLength() >= 0.007 then
				CarTradeUIState_handler( false )
			end
		end, 1500, 0 )
		
		local data = formatVehicleDescriptionData( veh, trade_data )
		if not data then return end
		
		showCursor( true )

		UI.black_bg = ibCreateBackground( 0x00000000, CarTradeUIState_handler, _, true )
		UI.bg = ibCreateImage( 0, 0, 0, 0, "img/bg.png", UI.black_bg )
		:ibSetRealSize()
		:center()
		:ibData( "alpha", 0 )

		UI.vehicle_label_info = ibCreateLabel( 30, 100, 0, 0, "Ваш транспорт:", UI.bg, 0x80FFFFFF )
		:ibData( "font", ibFonts.regular_14 )

		UI.vehicle_label_key = ibCreateImage( UI.vehicle_label_info:ibGetAfterX( 7 ), UI.vehicle_label_info:ibGetCenterY( - 12 ) , 24, 24, "img/key.png", UI.bg )

		UI.vehicle_label_model = ibCreateLabel( UI.vehicle_label_key:ibGetAfterX( 10 ), 100, 0, 0, data.name or "Ебаная телега", UI.bg, 0xFFFFFFFF )
		:ibData( "font", ibFonts.bold_14 )

		UI.close = ibCreateButton( UI.bg:width() - 50, 0 + 72/2 - 24/2, 24, 24, UI.bg, "img/close.png", "img/close.png", "img/close.png", 0xFFBBBBBB, 0xFFFFFFFF, 0xFFFFFFFF  )
		:ibOnClick( function( button, state ) 
			if button ~= "left" or state ~= "down" then return end
			CarTradeUIState_handler( false )
		end )

		UI.help_label_info = ibCreateLabel( 30, 152, 0, 0, "ЧО?", UI.bg, 0x80FFFFFF )
		:ibData( "font", ibFonts.regular_14 )
		if page == 1 then
			if UI.bg:ibData( "texture" ) ~= "img/bg.png" then
				UI.bg:ibData( "texture", "img/bg.png" )
			end
			UI.help_label_info:ibData( "text", "Установите сумму продажи:" )

			UI.edit_bg = ibCreateImage( 30, 185, 0, 0, "img/price.png", UI.bg )
			:ibSetRealSize()

			local removed = false
			UI.edit = ibCreateEdit( 10, 0, UI.edit_bg:width() - 10, UI.edit_bg:height(), "Введите стоимость", UI.edit_bg, 0xFFFFFFFF, 0x00FFFFFF, 0xFFFFFFFF )
			:ibData( "font", ibFonts.regular_14 )
			:ibOnDataChange( function( key, value, old )
				if key == "focused" then
					if not removed then
						UI.edit:ibData( "text", "" )
						UI.edit:ibData( "caret_position", 0 )
						removed = true
					end
				end
			end )

			local last_py = 0
			for i, v in pairs( COSTS_INFO ) do
				last_py =  UI.edit_bg:ibGetAfterY( 25 ) + 30 * ( i - 1 )
				local info_img = ibCreateImage( 30, last_py, 18, 18, "img/info.png", UI.bg )
				local info_lbl = ibCreateLabel( info_img:ibGetAfterX( 10 ), last_py, 0, 18, v.left .. ( v.key and format_price( trade_data.cost[v.key] ) or "" ), UI.bg, 0xBFffd992, _, _, "left", "center" )
				:ibData( "font", ibFonts.regular_11 )
				if v.key then
					ibCreateImage( info_lbl:ibGetAfterX( 10 ), last_py + 3, 14, 12, "img/money_small.png", UI.bg )
				end
			end

			UI.cancel = ibCreateButton( 30, last_py + 70, 120, 49, UI.bg, "img/but_cancel_sell.png", "img/but_cancel_sell.png", "img/but_cancel_sell.png", 0xCCFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF  )
			:ibOnClick( function( button, state ) 
				if button ~= "left" or state ~= "down" then return end
				CarTradeUIState_handler( false )
			end )

			UI.apply = ibCreateButton( UI.cancel:ibGetAfterX( 20 ), last_py + 70, 120, 49, UI.bg, "img/but_apply_sell.png", "img/but_apply_sell.png", "img/but_apply_sell.png", 0xCCFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF  )
			:ibOnClick( function( button, state ) 
				if button ~= "left" or state ~= "down" then return end

				local new_cost = tonumber( UI.edit:ibData( "text" ) )
				if new_cost then
					if new_cost ~= math.floor( new_cost ) or not isnumber( new_cost ) then
						localPlayer:ShowError( "Неверно указана сумма" )
						return false
					end

					if new_cost < trade_data.cost['min'] then
						localPlayer:ShowError( "Цена ниже минимальной" )
						return false
					end

					if new_cost > trade_data.cost['max'] then
						localPlayer:ShowError( "Цена выше максимальной" )
						return false
					end

					trade_data.seller_cost = new_cost
					CarTradeUIState_handler( false )
					CarTradeUIState_handler( true, veh, 2, trade_data )
				else
					localPlayer:ShowError( "Введите число" )
				end
			end )
			UI.sell_help = ibCreateImage( 0, 584 - 30*2, 740, 30, "img/sell_help.png", UI.bg )
			:center_x()

		elseif page == 2 or page == 3 then
			if UI.bg:ibData( "texture" ) ~= "img/bg2.png" then
				UI.bg:ibData( "texture", "img/bg2.png" )
			end
			UI.help_label_info:ibData( "text", "Стоковые характеристики:" )

			local stats_progress_bar_sx = 150
			local stats_progress_bar_sy = 8
			local tableOfValues = {
				["power"] = data.power,
				["ftc"] = data.ftc,
				["fuel_loss"] = data.fuel_loss,
				["max_speed"] = data.max_speed,
			};
			local tableOfValues2 = {
				["modf" ] = data.mod ~= "" and data.mod or "Нет",
 				["mileage"] = math.floor( MILEAGE ),
 				["gear"] = data.drivetype,
 				["inventory_max_weight"] = trade_data.inventory_max_weight,
			};

			for i, v in pairs( STATS_INFO ) do
				local stat_lbl = ibCreateLabel( 30, 185 + ( i - 1 ) * 38 + stats_progress_bar_sy * ( i - 1 ), 0, 0, v.left, UI.bg, 0xFFFFFFFF )
				:ibData( "font", ibFonts.regular_10 )

				local stat_bg = ibCreateImage( 30, stat_lbl:ibGetAfterY( 1 ), stats_progress_bar_sx, stats_progress_bar_sy, _, UI.bg, 0xFF292929 )
				local stat_value = ( tableOfValues[v.key] / STATS_LIMITS[v.key] ) * stats_progress_bar_sx
				if v.key == "ftc" or v.key == "fuel_loss" then stat_value = stats_progress_bar_sx - stat_value; end
				stat_value = stat_value > stats_progress_bar_sx and stats_progress_bar_sx or stat_value
				ibCreateImage( 0, 0, stat_value, stats_progress_bar_sy, _, stat_bg, 0xFF6c96c2 )

				local stat_value_lbl = ibCreateLabel( stat_bg:ibGetAfterX( 15 ), stat_lbl:ibGetAfterY( 1 ), 0, stats_progress_bar_sy, tableOfValues[v.key] .. " " .. v.right, UI.bg, 0xFFFFFFFF, _, _, "left", "center" )
				:ibData( "font", ibFonts.regular_10 )
			end

			local i = 0
			for k, v in pairs( MODF_INFO ) do
				if tableOfValues2[v.key] then
					i = i + 1
					local left_lbl = ibCreateLabel( 270, 185 + ( i - 1 ) * 30, 0, 0, v.left .. ": ", UI.bg, 0x80FFFFFF )
					:ibData( "font", ibFonts.regular_13 )
					local right_lbl = ibCreateLabel( left_lbl:ibGetAfterX( 2 ), 185 + ( i - 1 ) * 30, 0, 0, tableOfValues2[v.key] .. ( v.right and ( " " .. v.right ) or "" ), UI.bg, 0xF2FFFFFF )
					:ibData( "font", ibFonts.regular_13 )
				end
			end

			local price_label = ibCreateLabel( 30, 410, 0, 0, "Стоимость:", UI.bg, 0xF2FFFFFF )
			:ibData( "font", ibFonts.regular_14 )
			local price_value = ibCreateLabel( 30, price_label:ibGetAfterY( 5 ), 0, 0, format_price( trade_data.seller_cost ), UI.bg, 0xFFFFFFFF )
			:ibData( "font", ibFonts.bold_14 )
			ibCreateImage( price_value:ibGetAfterX( 7 ), price_value:ibGetCenterY( - 14 ), 28, 28, ":nrp_shared/img/money_icon.png", UI.bg )

			UI.cancel = ibCreateButton( 30, price_value:ibGetAfterY( 30 ), 120, 49, UI.bg, "img/but_cancel_sell.png", "img/but_cancel_sell.png", "img/but_cancel_sell.png", 0xCCFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF  )
			UI.apply = ibCreateButton( UI.cancel:ibGetAfterX( 30 ), price_value:ibGetAfterY( 30 ), 120, 49, UI.bg, _, _, _, 0xCCFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF  )

			
			if page == 2 then --Подтверждение продажи
				UI.cancel:ibOnClick( function( button, state ) 
					if button ~= "left" or state ~= "down" then return end
					CarTradeUIState_handler( false )
				end )
				UI.apply:ibOnClick( function( button, state ) 
					if button ~= "left" or state ~= "down" then return end

					local function sendCarSellRequest()
						triggerServerEvent( "sendCarSellRequest", localPlayer, veh, trade_data.seller_cost )
						CarTradeUIState_handler( false )
					end

					if not trade_data.is_inventory_empty then
						if UI.confirmation then UI.confirmation:destroy() end
						UI.confirmation = ibConfirm(
							{
								title = "ВНИМАНИЕ",
								text = "Предметы в багажнике будут уничтожены.\nТы действительно хочешь совершить продажу?" ,
								priority = 10,
								fn = function( self )
									self:destroy()
									sendCarSellRequest()
								end,
								escape_close = true,
							}
						)
					else
						sendCarSellRequest()
					end
				end )
				:ibBatchData(
					{ 
						texture = "img/but_apply_sell.png",
						texture_hover = "img/but_apply_sell.png",
						texture_click = "img/but_apply_sell.png"
					}
				)
			else --Подтверждение покупки
				UI.cancel:ibOnClick( function( button, state ) 
					if button ~= "left" or state ~= "down" then return end
					triggerServerEvent( "onVehicleSellRequestAccepted", localPlayer, veh, trade_data.seller_cost, true )
					CarTradeUIState_handler( false )
				end )
				UI.apply:ibOnClick( function( button, state ) 
					if button ~= "left" or state ~= "down" then return end
					triggerServerEvent( "onVehicleSellRequestAccepted", localPlayer, veh, trade_data.seller_cost )
					CarTradeUIState_handler( false )
				end )
				:ibBatchData(
					{ 
						texture = "img/but_apply_buy.png",
						texture_hover = "img/but_apply_buy.png",
						texture_click = "img/but_apply_buy.png"
					}
				)
			end
		end
		UI.bg:ibAlphaTo( 255, 300 )

	elseif not state and UI.black_bg then
		if isTimer( CHECK_VELOCITY_TIMER ) then killTimer( CHECK_VELOCITY_TIMER ) end

		if isElement( UI and UI.black_bg ) then
			destroyElement( UI.black_bg )
		end

		UI = {}
		showCursor( false )
	end
end
addEventHandler( "CarTradeUIState", resourceRoot, CarTradeUIState_handler )