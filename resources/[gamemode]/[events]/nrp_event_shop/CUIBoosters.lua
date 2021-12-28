local UIe = { }
local CURRENT_TAB = 1

function CreateUI_Boosters(  )
	UIe.black_bg = ibCreateBackground( _, DestroyUI_Boosters )

	showCursor( true )

	UIe.bg = ibCreateImage( 0, 0, 1024, 720, "images/" .. CURRENT_EVENT .. "/bg_boosters.png", UIe.black_bg ):center( )


	ibCreateButton(	965, 36, 24, 24, UIe.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UIe.black_bg )
		end, false )

	do
		local lbl_donate = ibCreateLabel( 820, 36, 0, 0, format_price( localPlayer:GetDonate( ) ), UIe.bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_18 )
		ibCreateImage( lbl_donate:ibGetAfterX( 8 ), 22, 28, 28, ":nrp_shared/img/hard_money_icon.png", UIe.bg )
			:ibTimer( function( self )
				lbl_donate:ibData( "text", format_price( localPlayer:GetDonate( ) ) )
				self:ibData( "px", lbl_donate:ibGetAfterX( 8 ) )
			end, 1000, 0 )


		ibCreateButton(	724, 47, 120, 20, UIe.bg, "images/btn_balance", true )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end

				ibClick( )
				destroyElement( UIe.black_bg )
				triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate", "event_shop_boosters" )
			end, false )
	end

	for i, info in pairs( SHOP_BOOSTERS[ CURRENT_EVENT ] ) do
		local bg = ibCreateButton( 30 + 328 * ( i - 1 ), 122, 308, 510, UIe.bg, "images/" .. CURRENT_EVENT .. "/item_boost_bg.png", "images/" .. CURRENT_EVENT .. "/item_boost_bg_h.png", "images/" .. CURRENT_EVENT .. "/item_boost_bg_h.png" )

		ibCreateLabel( 0, 37, 0, 0, info.name, bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_20 ):center_x( )
		ibCreateImage( 0, 0, 308, 510, "images/" .. CURRENT_EVENT .. "/items/booster/".. info.id .."_big.png", bg ):center( ):ibData( "disabled", true )

		if info.discount > 0 then
			ibCreateImage( 0, 91, 122, 34, "images/discount.png", bg ):center_x( ):ibData( "disabled", true )
			ibCreateLabel( 0, 109, 0, 0, "ВЫГОДА " .. info.discount .. "%", bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.bold_14 ):center_x( )
		end

		do
			local time_format = TIME_FORMATS[ info.time_type ]
			local bg = ibCreateArea( 0, 70, 0, 0, bg )
			local icon = ibCreateImage( 0, 0, 18, 22, "images/timer.png", bg ):center( 0, -1 ):ibData( "disabled", true )
			local lbl = ibCreateLabel( icon:ibGetAfterX( 8 ), 0, 0, 0, "Время действия:", bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_16 )
			local lbl2 = ibCreateLabel( lbl:ibGetAfterX( 8 ), 0, 0, 0, info.time .." ".. plural( info.time, time_format[ 1 ], time_format[ 2 ], time_format[ 3 ] ), bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_14 )
			bg:ibData( "sx", lbl2:ibGetAfterX( ) ):center_x( )
		end

		do
			local icon = ibCreateImage( 195, 381, 17, 17, ":nrp_shared/img/hard_money_icon.png", bg ):ibData( "disabled", true )
			ibCreateLabel( icon:ibGetBeforeX( -8 ), 391, 0, 0, "Цена за 1 час:", bg, 0x7dffffff, 1, 1, "right", "center" ):ibData( "font", ibFonts.regular_16 )
			ibCreateLabel( icon:ibGetAfterX( 8 ), 391, 0, 0, format_price( info.cost_single ), bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_18 )
		end

		do
			local icon = ibCreateImage( 150, 406, 24, 24, ":nrp_shared/img/hard_money_icon.png", bg ):ibData( "disabled", true )
			ibCreateLabel( icon:ibGetBeforeX( -8 ), 416, 0, 0, "Цена:", bg, COLOR_WHITE, 1, 1, "right", "center" ):ibData( "font", ibFonts.regular_18 )
			ibCreateLabel( icon:ibGetAfterX( 8 ), 416, 0, 0, format_price( info.cost ), bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_20 )
		end

		ibCreateButton(	120 + 328 * ( i - 1 ), 567, 130, 45, UIe.bg, ":nrp_shared/img/btn_buy", true )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end

				ibClick( )
				destroyElement( UIe.black_bg )
				triggerServerEvent( "PlayerWantBuyBooster", resourceRoot, i )
			end, false )
	end
end
addEvent( "ShowUIEventBoosters" )
addEventHandler( "ShowUIEventBoosters", resourceRoot, CreateUI_Boosters )

function DestroyUI_Boosters( )
	showCursor( false )
end