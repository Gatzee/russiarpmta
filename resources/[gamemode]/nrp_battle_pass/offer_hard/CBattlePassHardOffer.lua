function ShowHardOffer( offer_data )
	if offer_data then
		localPlayer:setData( "bp_hard_offer", offer_data, false )
	else
		offer_data = localPlayer:getData( "bp_hard_offer" )
		if not offer_data or ( offer_data.finish_ts or 0 ) <= getRealTimestamp( ) then
			return
		end
	end

	if UI.hardoff and isElement( UI.hardoff.black_bg ) then return end

	UI.hardoff = { }

	UI.hardoff.black_bg = ibCreateBackground( _, showCursor )
	showCursor( true, UI.hardoff.black_bg )

	UI.hardoff.bg = ibCreateImage( 0, 0, 1024, 720, "offer_hard/img/bg.png", UI.hardoff.black_bg )
		:center( )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

	UI.img_logo = ibCreateImage( 30, 9, 0, 0, "img/logo.png", UI.hardoff.bg ):ibSetRealSize( )

	ibCreateButton(	972, 29, 24, 24, UI.hardoff.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UI.hardoff.black_bg )
		end, false )

	local label_elements = { { 585,  123 }, { 614, 123 }, { 661, 123 }, { 688, 123 }, { 732, 123 }, { 760, 123 }, }
	for i, v in pairs( label_elements ) do
		UI[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "0", UI.hardoff.bg ):ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
	end
	local function UpdateTimer( )
		local str = getTimerString( offer_data.finish_ts, true )

		for i = 1, #label_elements do
			local offset = math.floor( ( i - 1 ) / 2 )
			UI[ "tick_num_" .. i ]:ibData( "text", utf8.sub( str, i + offset, i + offset ) )
		end
	end
	UI.hardoff.bg:ibTimer( UpdateTimer, 1000, 0 )
	UpdateTimer( )

    ibCreateLabel( 977, 127, 0, 0, offer_data.discount .. "%", UI.hardoff.bg, _, 1.2, _, "center", "center", ibFonts.oxaniumextrabold_28 ):ibData( "rotation", 45 )

	-- Вы получите:
	local l_cost_value = ibCreateLabel( 489, 282, 0, 0, format_price( offer_data.cost_original ), UI.hardoff.bg, _, _, _, "center", "center", ibFonts.oxaniumbold_28 )
	local cost_icon = ibCreateImage( l_cost_value:ibGetAfterX( 10 ), 269, 28, 28, ":nrp_shared/img/hard_money_icon.png", UI.hardoff.bg )

	-- Новая стоимость
	local l_cost = ibCreateLabel( 313, 656, 0, 0, "Новая стоимость:", UI.hardoff.bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_16 )
	local l_cost_value = ibCreateLabel( l_cost:ibGetAfterX( 6 ), 654, 0, 0, format_price( offer_data.cost ), UI.hardoff.bg, _, _, _, "left", "center", ibFonts.oxaniumbold_22 )
	ibCreateLabel( l_cost_value:ibGetAfterX( 6 ), 656, 0, 0, "руб.", UI.hardoff.bg, _, _, _, "left", "center", ibFonts.regular_16 )

	-- Старая стоимость
	local l_old_cost = ibCreateLabel( 332, 680, 0, 0, "Старая стоимость:", UI.hardoff.bg, ibApplyAlpha( COLOR_WHITE, 35 ), _, _, "left", "center", ibFonts.regular_14 )
	local l_old_cost_value = ibCreateLabel( l_old_cost:ibGetAfterX( 5 ), 678, 0, 0, format_price( offer_data.cost_original ), UI.hardoff.bg, ibApplyAlpha( COLOR_WHITE, 35 ), _, _, "left", "center", ibFonts.oxaniumbold_16 )
	local l_old_rub = ibCreateLabel( l_old_cost_value:width( ) + 3, 1, 0, 0, "руб.", l_old_cost_value, ibApplyAlpha( COLOR_WHITE, 35 ), _, _, "left", "center", ibFonts.regular_14 )
	local old_cost_line = ibCreateImage( -3, 0, l_old_rub:ibGetAfterX( 3 ), 1, _, l_old_cost_value, COLOR_WHITE )

	ibCreateButton(	l_cost_value:ibGetAfterX( 55 ), 637, 0, 0, UI.hardoff.bg, "offer_hard/img/btn_buy.png", _, _, 0xDAFFFFFF, 0xFFFFFFFF, 0xFFaaaaaa )
		:ibSetRealSize( )	
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			SetupPaymentWindow( offer_data.pack_id, offer_data.cost, offer_data.url )
		end, false )
end
addEvent( "BP:ShowHardOffer", true )
addEventHandler( "BP:ShowHardOffer", root, ShowHardOffer )

addEvent( "BP:onClientPlayerPurchaseHardOffer", true )
addEventHandler( "BP:onClientPlayerPurchaseHardOffer", resourceRoot, function( )
	localPlayer:setData( "bp_hard_offer", false, false )
	if UI.hardoff and isElement( UI.hardoff.black_bg ) then
		UI.hardoff.black_bg:destroy( )
	end
end )