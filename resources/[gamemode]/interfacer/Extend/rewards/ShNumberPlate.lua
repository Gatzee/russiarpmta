-- REGISTERED_ITEMS.numberplate = {
-- 	-- TODO: Что делать, если нет машины?
-- 	OnPreTake = function( params, OnTake )
-- 		ibConfirm( {
-- 			title = "ПОДТВЕРЖДЕНИЕ", 
-- 			text = "У вас сейчас нет ни одной машины,\nк которой можно было бы привязать этот номер",
-- 			fn = function( self ) 
-- 				self:destroy()
-- 				OnTake( )
-- 			end,
-- 			escape_close = true,
-- 		} )
-- 	end;

-- 	Give = function( player, params, args, cost )
-- 		local region = tonumber( params.region ) and string.format( "%02d", params.region ) or params.region or "01"
-- 		local numberplate = PLATE_TYPE_SPECIAL .. ":" .. params.text .. region
-- 		triggerEvent( "OnVehicleChangeNumberPlate", args.vehicle, numberplate, cost * 1000 )
-- 	end;
	
-- 	uiCreateItem = function( id, params, bg )
-- 		local plate = ibCreateImage( 0, 0, 108, 47, "img/rewards/items/numberplate.png", bg ):center( 0, -5 )
-- 		local label = ibCreateLabel( 1, 16, 73, 30, params.text, plate, 0xff3a4c5f, _, _, "center", "center", ibFonts.extrabold_18 )
-- 		if label:width( ) >= 70 then
-- 			label:ibData( "font", ibFonts.extrabold_14 )
-- 		end
-- 		local region = tonumber( params.region ) and string.format( "%02d", params.region ) or params.region or "01"
-- 		ibCreateLabel( 76, 16, 31, 18, region, plate, 0xff3a4c5f, _, _, "center", "center", ibFonts.bold_12 )
-- 		return plate, 108, 54
-- 	end;

-- 	uiCreateRewardItem = function( id, params, bg )
-- 		local region = tonumber( params.region ) and string.format( "%02d", params.region ) or params.region or "01"
-- 		local plate_bg = ibCreateImage( 0, 0, 170, 75, ":nrp_shop/img/special_offers/number_plate.png", bg ):center( 0, -15 )
-- 		ibCreateLabel( 0, 28, 120, 48, params.text, plate_bg, 0xff3a4c5f, _, _, "center", "center", not params.plate_font_small and ibFonts.bold_23 or ibFonts.bold_18  )
-- 		ibCreateLabel( 120, 28, 50, 30, region, plate_bg, 0xff3a4c5f, _, _, "center", "center", ibFonts.bold_18  )
-- 	end;
	
-- 	uiGetDescriptionData = function( id, params )
-- 		return {
-- 			title = "Уникальный номер \"" .. params.text .. "\"";
-- 			-- description = "Позволяет бесплатно\nэвакуировать транспорт"
-- 		}
-- 	end;
-- }