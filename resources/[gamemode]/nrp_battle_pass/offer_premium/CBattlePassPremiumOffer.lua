function ShowPremiumOffer( offer_data, from_take_button )
	if offer_data then
		localPlayer:setData( "bp_premium_offer", offer_data, false )
	else
		offer_data = localPlayer:getData( "bp_premium_offer" )
		if not offer_data or ( offer_data.finish_ts or 0 ) <= getRealTimestamp( ) then
			offer_data = { cost = BP_PREMIUM_COST }
		end
		if from_take_button then
			triggerServerEvent( "BP:onPlayerShowPremiumOffer", resourceRoot )
		end
	end

	if UI.premoff and isElement( UI.premoff.black_bg ) then return end

	UI.premoff = { }

	UI.premoff.black_bg = ibCreateBackground( _, showCursor )
	showCursor( true, UI.premoff.black_bg )

	UI.premoff.bg = ibCreateImage( 0, 0, 1024, 768, "offer_premium/img/" .. ( offer_data.discount and "bg_sale.png" or "bg.png" ), UI.premoff.black_bg )
		:center( )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

	UI.img_logo = ibCreateImage( 30, 9, 0, 0, "img/logo.png", UI.premoff.bg ):ibSetRealSize( )

	ibCreateButton(	972, 29, 24, 24, UI.premoff.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UI.premoff.black_bg )
		end, false )

	if offer_data.discount then
		ibCreateLabel( 666, 29, 0, 0, "СКИДКА " .. offer_data.discount .. "%", UI.premoff.bg, COLOR_WHITE, _, _, "center", "center", ibFonts.extrabold_12 )
	end

	local timer_text = offer_data.discount and "До конца акции: " or "До конца сезона: "
	local finish_ts = offer_data.finish_ts or BP_CURRENT_SEASON_END_TS
	UI.premoff.area_timer = ibCreateArea( 0, 113, 0, 0, UI.premoff.bg )
	ibCreateImage( 0, 0, 30, 32, ":nrp_shared/img/icon_timer.png", UI.premoff.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ) ):center_y( )
	UI.premoff.lbl_text = ibCreateLabel( 36, 0, 0, 0, timer_text, UI.premoff.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_16 )
	UI.premoff.lbl_timer = ibCreateLabel( UI.premoff.lbl_text:ibGetAfterX( ), 0, 0, 0, getHumanTimeString( finish_ts ) or "0 с", UI.premoff.area_timer, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
		:ibTimer( function( self )
			self:ibData( "text", getHumanTimeString( finish_ts ) or "0 с" )
			UI.premoff.area_timer:ibData( "sx", UI.premoff.lbl_timer:ibGetAfterX( ) ):center_x( )
		end, 1000, 0 )
	UI.premoff.area_timer:ibData( "sx", UI.premoff.lbl_timer:ibGetAfterX( ) ):center_x( )

	if offer_data.discount then
		UI.premoff.lbl_cost_original = ibCreateLabel( 610, 589, 0, 0, BP_PREMIUM_COST, UI.premoff.bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.bold_24 )
		ibCreateLine( 553, 587, UI.premoff.lbl_cost_original:ibGetAfterX( ) + 5, _, ibApplyAlpha( COLOR_WHITE, 75 ), 1, UI.premoff.bg )
	end
	
	ibCreateLabel( 624, 632, 0, 0, offer_data.cost, UI.premoff.bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_30 )

	ibCreateButton(	435, 682, 160, 56, UI.premoff.bg, "offer_premium/img/btn_buy.png", _, _, 0xCCFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
                    
			ibConfirm( {
				title = "ПОДТВЕРЖДЕНИЕ", 
				text = "Ты хочешь купить премиальный билет за",
				cost = offer_data.cost,
				cost_is_soft = false,
				fn = function( self ) 
					self:destroy()
					destroyElement( UI.premoff.black_bg )
					triggerServerEvent( "BP:onPlayerWantBuyPremium", resourceRoot, from_take_button )
				end,
				escape_close = true,
			} )
		end, false )
end
addEvent( "BP:ShowPremiumOffer", true )
addEventHandler( "BP:ShowPremiumOffer", root, ShowPremiumOffer )

addEvent( "BP:UpdateUI", true )
addEventHandler( "BP:UpdateUI", resourceRoot, function( data )
	if data.is_premium_active then
		localPlayer:setData( "bp_premium_offer", false, false )

		if UI.premoff then
			localPlayer:ShowSuccess( "Ты успешно приобрёл премиальный билет!" )
		end
	end
end )