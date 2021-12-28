function ShowBoosterOffer( offer_data )
	if offer_data then
		localPlayer:setData( "bp_booster_offer", offer_data, false )
	else
		offer_data = localPlayer:getData( "bp_booster_offer" )
		if not offer_data or ( offer_data.finish_ts or 0 ) <= getRealTimestamp( ) then
			return
		end
	end

	if UI.boostoff and isElement( UI.boostoff.black_bg ) then return end

	UI.boostoff = { }

	UI.boostoff.black_bg = ibCreateBackground( _, showCursor )
	showCursor( true, UI.boostoff.black_bg )

	UI.boostoff.bg = ibCreateImage( 0, 0, 1024, 768, "offer_booster/img/bg.png", UI.boostoff.black_bg )
		:center( )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

	UI.img_logo = ibCreateImage( 30, 9, 0, 0, "img/logo.png", UI.boostoff.bg ):ibSetRealSize( )

	ibCreateLabel( 666, 29, 0, 0, "СКИДКА " .. offer_data.discount .. "%", UI.boostoff.bg, COLOR_WHITE, _, _, "center", "center", ibFonts.extrabold_12 )

	ibCreateButton(	972, 29, 24, 24, UI.boostoff.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UI.boostoff.black_bg )
		end, false )

	UI.boostoff.area_timer = ibCreateArea( 0, 113, 0, 0, UI.boostoff.bg )
	ibCreateImage( 0, 0, 30, 32, ":nrp_shared/img/icon_timer.png", UI.boostoff.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ) ):center_y( )
	UI.boostoff.lbl_text = ibCreateLabel( 36, 0, 0, 0, "До конца акции: ", UI.boostoff.area_timer, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_16 )
	UI.boostoff.lbl_timer = ibCreateLabel( UI.boostoff.lbl_text:ibGetAfterX( ), 0, 0, 0, getHumanTimeString( offer_data.finish_ts ) or "0 с", UI.boostoff.area_timer, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_16 )
		:ibTimer( function( self )
			self:ibData( "text", getHumanTimeString( offer_data.finish_ts ) or "0 с" )
			UI.boostoff.area_timer:ibData( "sx", UI.boostoff.lbl_timer:ibGetAfterX( ) ):center_x( )
		end, 1000, 0 )
	UI.boostoff.area_timer:ibData( "sx", UI.boostoff.lbl_timer:ibGetAfterX( ) ):center_x( )

	ibCreateLabel( 624, 633, 0, 0, offer_data.cost, UI.boostoff.bg, COLOR_WHITE, _, _, "left", "center", ibFonts.bold_30 )

	local booster = BP_BOOSTERS[ offer_data.booster_id ]

	ibCreateButton(	435, 682, 160, 56, UI.boostoff.bg, "offer_premium/img/btn_buy.png", _, _, 0xCCFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
                    
			ibConfirm( {
				title = "ПОДТВЕРЖДЕНИЕ", 
				text = "Ты хочешь купить ускоритель на " .. booster.days .. plural( booster.days, " день", " дня", " дней" ) ..  " за ",
				cost = offer_data.cost,
				cost_is_soft = false,
				fn = function( self ) 
					self:destroy()
					triggerServerEvent( "BP:onPlayerWantBuyBooster", resourceRoot, offer_data.booster_id )
				end,
				escape_close = true,
			} )
		end, false )
end
addEvent( "BP:ShowBoosterOffer", true )
addEventHandler( "BP:ShowBoosterOffer", root, ShowBoosterOffer )

addEvent( "BP:UpdateUI", true )
addEventHandler( "BP:UpdateUI", resourceRoot, function( data )
	if data.booster_end_ts then
		local offer_data = localPlayer:getData( "bp_booster_offer" )
		if offer_data then
			localPlayer:setData( "bp_booster_offer", false, false )

			if UI.boostoff and isElement( UI.boostoff.black_bg ) then
				UI.boostoff.black_bg:destroy( )
				localPlayer:ShowSuccess( "Ты успешно приобрёл ускоритель!" )
			end
		end
	end
end )