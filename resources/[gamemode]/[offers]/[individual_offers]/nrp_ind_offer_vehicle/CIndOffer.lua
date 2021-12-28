loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UI = { }

function ShowOffer( offer_data )
	if offer_data then
		offer_data.discount = math.ceil( ( 1 - OFFER.cost / OFFER.cost_original ) * 100 - 0.5 )
		localPlayer:setData( OFFER.id, offer_data, false )
	else
		offer_data = localPlayer:getData( OFFER.id )
		if not offer_data then return end
	end

	if isElement( UI.black_bg ) then return end
	showCursor( true )

	UI.black_bg = ibCreateBackground( _, function( ) showCursor( false ) end )
	UI.bg = ibCreateImage( 0, 0, 1024, 720, "img/bg.png", UI.black_bg )
		:center( )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 1000 )

	ibCreateButton(	972, 29, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UI.black_bg )
		end, false )

	local label_elements = { { 585,  123 }, { 614, 123 }, { 661, 123 }, { 688, 123 }, { 732, 123 }, { 760, 123 }, }
	for i, v in pairs( label_elements ) do
		UI[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "0", UI.bg ):ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
	end
	local function UpdateTimer( )
		local str = getTimerString( offer_data.finish_ts, true )

		for i = 1, #label_elements do
			local offset = math.floor( ( i - 1 ) / 2 )
			UI[ "tick_num_" .. i ]:ibData( "text", utf8.sub( str, i + offset, i + offset ) )
		end
	end
	UI.bg:ibTimer( UpdateTimer, 1000, 0 )
	UpdateTimer( )

    ibCreateLabel( 977, 127, 0, 0, offer_data.discount .. "%", UI.bg, _, 1.2, _, "center", "center", ibFonts.oxaniumextrabold_28 ):ibData( "rotation", 45 )

	local l_soft_count = ibCreateLabel( 312, 311, 0, 0, format_price( OFFER.items[ 1 ].count ), UI.bg, _, _, _, "right", "center", ibFonts.oxaniumbold_22 )

	local l_car_discount = ibCreateLabel( 726, 307, 0, 0, OFFER.car_discount .. "%", UI.bg, 0xFFf55353, _, _, "center", "center", ibFonts.oxaniumbold_21 )
		:ibData( "outline", true )
		:ibData( "outline_color", ibApplyAlpha( COLOR_BLACK, 30 ) )

	-- Новая стоимость
	local l_cost = ibCreateLabel( 313, 656, 0, 0, "Новая стоимость:", UI.bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_16 )
	local l_cost_value = ibCreateLabel( l_cost:ibGetAfterX( 6 ), 654, 0, 0, format_price( OFFER.cost ), UI.bg, _, _, _, "left", "center", ibFonts.oxaniumbold_22 )
    local cost_icon = ibCreateImage( l_cost_value:ibGetAfterX( 6 ), 642, 28, 28, ":nrp_shared/img/hard_money_icon.png", UI.bg )

	-- Старая стоимость
	local l_old_cost = ibCreateLabel( 332, 680, 0, 0, "Старая стоимость:", UI.bg, ibApplyAlpha( COLOR_WHITE, 35 ), _, _, "left", "center", ibFonts.regular_14 )
	local l_old_cost_value = ibCreateLabel( l_old_cost:ibGetAfterX( 5 ), 678, 0, 0, format_price( OFFER.cost_original ), UI.bg, ibApplyAlpha( COLOR_WHITE, 35 ), _, _, "left", "center", ibFonts.oxaniumbold_16 )
    local old_cost_icon = ibCreateImage( l_old_cost_value:width( ) + 3, -7, 17, 17, ":nrp_shared/img/hard_money_icon.png", l_old_cost_value, ibApplyAlpha( COLOR_WHITE, 35 ) )
	local old_cost_line = ibCreateImage( -3, 0, old_cost_icon:ibGetAfterX( 6 ), 1, _, l_old_cost_value )

	ibCreateButton(	cost_icon:ibGetAfterX( 20 ), 637, 0, 0, UI.bg, ":nrp_ind_offer_wof/img/btn_buy.png", _, _, 0xDAFFFFFF, 0xFFFFFFFF, 0xFFaaaaaa )
		:ibSetRealSize( )	
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick( )
			ibConfirm( {
				title = "ПОДТВЕРЖДЕНИЕ", 
				text = "Ты хочешь купить этот набор за",
				cost = OFFER.cost,
				cost_is_soft = false,
				fn = function( self ) 
					self:destroy()
					triggerServerEvent( "IO:onPlayerWantBuy", resourceRoot )
				end,
				escape_close = true,
			} )
		end, false )
end
addEvent( "IO:ShowOffer", true )
addEventHandler( "IO:ShowOffer", resourceRoot, ShowOffer )

addEvent( "IO:onClientPurchase", true )
addEventHandler( "IO:onClientPurchase", resourceRoot, function( )
	localPlayer:setData( OFFER.id, nil, false )
	DestroyTableElements( UI )
    localPlayer:ShowSuccess( "Ты успешно приобрёл этот набор!" )
end )