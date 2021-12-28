Extend( "ib" )
Extend( "CPlayer" )

ibUseRealFonts( true )

local UIe = { }
local CURRENT_TAB = 1
local sizes = {
	[ "skin" ] = {
		sx = 300,
		sy = 280,
		y = -25,
	},
	[ "vehicle" ] = {
		sx = 300,
		sy = 160,
		rsx = 245,
		rsy = 131,
		y = 77,
	},
	[ "accessory" ] = {
		sx = 300,
		sy = 180,
		rsx = 249,
		rsy = 149,
		y = 77,
	},
}

function CreateUI_Shop(  )
	UIe.black_bg = ibCreateBackground( _, DestroyUI_Shop )

	showCursor( true )

	UIe.bg = ibCreateImage( 0, 0, 1024, 720, "images/" .. CURRENT_EVENT .. "/bg.png", UIe.black_bg ):center( )
	UIe.header = ibCreateImage( 0, 0, 1024, 720, "images/" .. CURRENT_EVENT .. "/header.png", UIe.bg ):center( )

	ibCreateButton(	965, 36, 24, 24, UIe.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			destroyElement( UIe.black_bg )
		end, false )

	do
		local lbl_donate = ibCreateLabel( 820, 36, 0, 0, format_price( localPlayer:GetDonate( ) ), UIe.bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_18 )
		ibCreateImage( lbl_donate:ibGetAfterX( 5 ), 22, 28, 28, ":nrp_shared/img/hard_money_icon.png", UIe.bg )
			:ibTimer( function( self )
				lbl_donate:ibData( "text", format_price( localPlayer:GetDonate( ) ) )
				self:ibData( "px", lbl_donate:ibGetAfterX( 8 ) )
			end, 1000, 0 )


		ibCreateButton(	724, 47, 120, 20, UIe.bg, "images/btn_balance", true )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end

				ibClick( )
				destroyElement( UIe.black_bg )
				triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate", "event_shop_main" )
			end, false )
	end

	do
		local lb_info_coins = nil
		local lbl_coins = ibCreateLabel( 898, 130, 0, 0, format_price( localPlayer:getData( EVENT_COINS_VALUE_NAME ) or 0 ), UIe.bg, COLOR_WHITE, 1, 1, "right", "center" ):ibData( "font", ibFonts.bold_18 )
			:ibTimer( function( self )
				self:ibData( "text", format_price( localPlayer:getData( EVENT_COINS_VALUE_NAME ) or 0 ) )
				lb_info_coins:ibData( "px", self:ibGetBeforeX( -8 ) )
			end, 1000, 0 )
		lb_info_coins = ibCreateLabel( lbl_coins:ibGetBeforeX( -8 ), 130, 0, 0, "Ваши пули: ", UIe.bg, COLOR_WHITE, 1, 1, "right", "center" ):ibData( "font", ibFonts.regular_14 )

		local time = getHumanTimeString( localPlayer:getData( EVENT_BOOSTER_VALUE_NAME ) or 0 )
		if time then
			local lbl_coins = ibCreateLabel( lb_info_coins:ibGetBeforeX( -20 ), 130, 0, 0, "Время бонуса от подарков: ".. time, UIe.bg, COLOR_WHITE, 1, 1, "right", "center" ):ibData( "font", ibFonts.regular_14 )
				:ibTimer( function( self )
					local time = getHumanTimeString( localPlayer:getData( EVENT_BOOSTER_VALUE_NAME ) or 0 )
					if time then
						self:ibData( "px", lb_info_coins:ibGetBeforeX( -20 ) )
						self:ibData( "text", "Время бонуса от подарков: ".. time )
					else
						destroyElement( self )
					end
				end, 1000, 0 )
		end
	end

	do
		local tabs = {
			{
				name = "Товары";
				func_Create = function( )
					UIe.scroll_pane, UIe.scroll_bar = ibCreateScrollpane( 30, 175, 963, 545, UIe.bg, { scroll_px = 8, bg_color = 0x00FFFFFF } )
					UIe.scroll_bar:ibSetStyle( "slim_small_nobg" )
					UIe.scroll_bar:ibData( "sensivity", 0.1 )

					for i, info in pairs( SHOP_ITEMS[ CURRENT_EVENT ] ) do
						local bg = ibCreateButton( 328 * ( ( i - 1 ) % 3 ), 330 * math.floor( ( i - 1 ) / 3 ), 308, 310, UIe.scroll_pane, "images/" .. CURRENT_EVENT .. "/item_bg.png", "images/" .. CURRENT_EVENT .. "/item_bg_h.png", "images/" .. CURRENT_EVENT .. "/item_bg_h.png" )

						ibCreateLabel( 0, 22, 0, 0, info.name, bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_14 ):center_x( )

						if sizes[ info.type ] then
							local item = ibCreateContentImage( 0, sizes[ info.type ].y, sizes[ info.type ].sx, sizes[ info.type ].sy, info.type, info.id, bg ):center_x( ):ibData( "disabled", true )
							if sizes[ info.type ].rsx then
								item:ibBatchData( { sx = sizes[ info.type ].rsx, sy = sizes[ info.type ].rsy, } ):center_x( )
							end
						else
							ibCreateImage( 0, 0, 0, 0, "images/" .. CURRENT_EVENT .. "/items/".. info.type .."/".. info.id ..".png", bg ):ibSetRealSize( ):center( ):ibData( "disabled", true )
						end

						if info.type == "booster" then
							do
								local time_format = TIME_FORMATS[ info.time_type ]
								local bg = ibCreateArea( 0, 52, 0, 0, bg )
								local icon = ibCreateImage( 0, 0, 18, 22, "images/timer.png", bg ):center( 0, -1 ):ibData( "disabled", true )
								local lbl = ibCreateLabel( icon:ibGetAfterX( 8 ), 0, 0, 0, "Время действия:", bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_14 )
								local lbl2 = ibCreateLabel( lbl:ibGetAfterX( 8 ), 0, 0, 0, info.time .." ".. plural( info.time, time_format[ 1 ], time_format[ 2 ], time_format[ 3 ] ), bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_14 )
								bg:ibData( "sx", lbl2:ibGetAfterX( ) ):center_x( )
							end

							ibCreateLabel( 0, 213, 0, 0, "Ваша награда в состязаниях\nбудет увеличена в 2 раза", bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_12 ):center_x( )

							do
								local icon = ibCreateImage( 73, 265, 24, 24, ":nrp_shared/img/hard_money_icon.png", bg ):ibData( "disabled", true )
								ibCreateLabel( icon:ibGetBeforeX( -8 ), 275, 0, 0, "Цена:", bg, COLOR_WHITE, 1, 1, "right", "center" ):ibData( "font", ibFonts.regular_16 )
								ibCreateLabel( icon:ibGetAfterX( 8 ), 275, 0, 0, format_price( info.cost ), bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_18 )
							end
						else
							do
								local icon = ibCreateImage( 73, 263, 24, 24, "images/" .. CURRENT_EVENT .. "/coins_icon.png", bg ):ibData( "disabled", true )
								ibCreateLabel( icon:ibGetBeforeX( -8 ), 275, 0, 0, "Цена:", bg, COLOR_WHITE, 1, 1, "right", "center" ):ibData( "font", ibFonts.regular_16 )
								ibCreateLabel( icon:ibGetAfterX( 8 ), 275, 0, 0, format_price( info.cost ), bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_18 )
							end
						end


						local icon_img = ibCreateImage( 250, 227, 31, 31, "images/" .. CURRENT_EVENT .. "/icon.png", bg ):ibData( "disabled", true )
						ibCreateButton(	175, 256, 113, 34, bg, "images/btn_buy", true )
							:ibOnClick( function( key, state )
								if key ~= "left" then return end

								if state == "down" then
									icon_img:ibData( "py", 230 )
								else
									icon_img:ibData( "py", 227 )
								end

								ibClick( )

								ibConfirm( {
									title = SHOP_NAMES[ CURRENT_EVENT ] .. " МАГАЗИН", 
									text = "Ты действительно хочешь купить ".. info.name .."?" ,
									fn = function( self )
										self:destroy( )

										triggerServerEvent( "PlayerWantBuyItem", resourceRoot, i )
									end,
									escape_close = true,
								} )
							end, false )
					end

					UIe.scroll_pane:AdaptHeightToContents( )
					UIe.scroll_bar:UpdateScrollbarVisibility( UIe.scroll_pane )

					UIe.bg:ibData( "texture", "images/" .. CURRENT_EVENT .. "/bg.png" )
				end;
			},
			{
				name = "Описание";
				func_Create = function( )
					UIe.scroll_pane, UIe.scroll_bar = ibCreateScrollpane( 0, 120, 800, 460, UIe.bg, { scroll_px = 8, bg_color = 0x00FFFFFF } )
					UIe.scroll_bar:ibData( "sensivity", 0.1 )

					UIe.bg:ibData( "texture", "images/" .. CURRENT_EVENT .. "/description.png" )

					UIe.scroll_pane:AdaptHeightToContents( )
					UIe.scroll_bar:UpdateScrollbarVisibility( UIe.scroll_pane )
				end;
			},
		}

		CURRENT_TAB = 1
		tabs[ CURRENT_TAB ].func_Create( )

		local line = ibCreateImage( 30, 151, 10, 3, _, UIe.bg, 0xffff965d )

		local pos_x = 30
		local prev_lbl = nil
		for i, tab in pairs( tabs ) do
			local lbl = ibCreateLabel( pos_x, 117, 0, 20, tab.name, UIe.bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_16 ):ibData( "alpha", i == CURRENT_TAB and 255 or 150 )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					if source == prev_lbl then return end

					prev_lbl:ibAlphaTo( 150, 250 )
					source:ibAlphaTo( 255, 250 )

					line:ibMoveTo( source:ibData( "px" ), 151, 250 )
					line:ibResizeTo( source:ibData( "sx" ), 3, 250 )

					prev_lbl = source

					if isElement( UIe.scroll_pane ) then
						destroyElement( UIe.scroll_pane )
						destroyElement( UIe.scroll_bar )
					end
					CURRENT_TAB = i
					tabs[ CURRENT_TAB ].func_Create( )
				end, false )

			lbl:ibData( "sx", lbl:width( ) )
			pos_x = lbl:ibGetAfterX( 20 )

			if i == CURRENT_TAB then
				prev_lbl = lbl
				line:ibData( "sx", lbl:ibData( "sx" ) )
			end
		end
	end
end
addEvent( "ShowUIEventShop" )
addEventHandler( "ShowUIEventShop", resourceRoot, CreateUI_Shop )

function DestroyUI_Shop( )
	showCursor( false )
end