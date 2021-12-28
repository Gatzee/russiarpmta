Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UIe = { }
local CURRENT_TAB = 1

function CreateUI( office_data )
	UIe.black_bg = ibCreateBackground( _, DestroyUI, nil, true )

	showCursor( true )

	CURRENT_TAB = 1

	UIe.bg = ibCreateImage( 0, 0, 800, 580, "img/bg.png", UIe.black_bg ):center( )

	ibCreateButton(	748, 24, 24, 24, UIe.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			DestroyUI()
		end, false )

	do
		local tabs = {
			{
				name = "Офис";
				func_Create = function( )
					UIe.scroll_pane, UIe.scroll_bar = ibCreateScrollpane( 30, 140, 740, 430, UIe.bg, { scroll_px = 8, bg_color = 0x00FFFFFF } )
					UIe.scroll_bar:ibData( "sensivity", 0.1 )

					for i, info in pairs( SHOP_ITEMS.office ) do
						local bg = ibCreateImage( 0, 220 * ( i - 1 ), 740, 210, ":nrp_businesses_office/img/office_icon/".. info.id ..".png", UIe.scroll_pane )
							:ibAttachTooltip( info.tooltip_text )

						ibCreateLabel( 720, 25, 0, 0, info.name, bg, COLOR_WHITE, 1, 1, "right", "center" ):ibData( "font", ibFonts.bold_20 ):ibData( "outline", 1 )

						do
							ibCreateLabel( 18, 153, 0, 0, "Стоимость:", bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_16 )
							local label_cost = ibCreateLabel( 18, 180, 0, 0, format_price( info.cost ), bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_24 )
							ibCreateImage( label_cost:ibGetAfterX( 8 ), 167, 28, 28, ":nrp_shared/img/money_icon.png", bg )
						end

						if office_data and office_data.class == info.id then
							ibCreateImage( 0, 0, 740, 210, _, bg, ibApplyAlpha( COLOR_BLACK, 50 ) )
						else
							ibCreateButton(	607, 160, 113, 34, bg, "img/btn_buy", true )
								:ibOnClick( function( key, state )
									if key ~= "left" or state ~= "up" then return end

									ibClick( )

									if office_data then
										ibConfirm(
											{
												title = "ПОКУПКА ОФИСА", 
												text = "Можно иметь только 1 офис, после покупки ты потеряешь прошлый. Купить новый офис?" ,
												fn = function( self )
													triggerServerEvent( "PlayerWantBuyItem", resourceRoot, "office", i )
													self:destroy()
													DestroyUI()
												end,
												escape_close = true,
											}
										)
									else
										DestroyUI()
										triggerServerEvent( "PlayerWantBuyItem", resourceRoot, "office", i )
									end
								end, false )
						end
					end

					UIe.scroll_pane:AdaptHeightToContents( )
					UIe.scroll_bar:UpdateScrollbarVisibility( UIe.scroll_pane )
				end;
			},
			{
				name = "Секретарша";
				func_Create = function( )
					UIe.scroll_pane, UIe.scroll_bar = ibCreateScrollpane( 30, 140, 740, 420, UIe.bg, { scroll_px = 8, bg_color = 0x00FFFFFF } )
					UIe.scroll_bar:ibData( "sensivity", 0.1 )

					for i, info in pairs( SHOP_ITEMS.secretary ) do
						local bg = ibCreateButton( 380 * ( ( i - 1 ) % 2 ), 300 * math.floor( ( i - 1 ) / 2 ), 360, 280, UIe.scroll_pane, "img/item_bg.png", "img/item_bg_h.png", "img/item_bg_h.png" )

						ibCreateLabel( 0, 22, 0, 0, info.name, bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_14 ):center_x( )
						ibCreateImage( 0, 50, 0, 0, "img/items/secretary/".. info.id ..".png", bg ):ibSetRealSize( ):center_x( )

						do
							local label_cost = ibCreateLabel( 18, 250, 0, 0, format_price( info.cost ), bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_24 )
							ibCreateImage( label_cost:ibGetAfterX( 8 ), 237, 28, 28, ":nrp_shared/img/money_icon.png", bg )
						end

						ibCreateArea( 0, 0, 360, 280, bg )
							:ibAttachTooltip( "Открывает возможность управлять бизнесами удаленно" )

						if office_data and office_data.secretary == info.id then
							ibCreateImage( 0, 0, 360, 280, _, bg, ibApplyAlpha( COLOR_BLACK, 50 ) )
						else
							ibCreateButton(	227, 230, 113, 34, bg, "img/btn_buy", true )
								:ibOnClick( function( key, state )
									if key ~= "left" or state ~= "up" then return end
	
									ibClick( )
									if office_data and office_data.secretary then
										ibConfirm(
											{
												title = "НАЙМ СЕКРЕТАРШИ", 
												text = "Можно нанять только 1 секретаршу, после найма ты потеряешь прошлую. Нанять новую секретаршу?" ,
												fn = function( self )
													triggerServerEvent( "PlayerWantBuyItem", resourceRoot, "secretary", i )
													self:destroy()
													DestroyUI()
												end,
												escape_close = true,
											}
										)
									else
										DestroyUI()
										triggerServerEvent( "PlayerWantBuyItem", resourceRoot, "secretary", i )
									end
								end, false )
						end
					end

					UIe.scroll_pane:AdaptHeightToContents( )
					UIe.scroll_bar:UpdateScrollbarVisibility( UIe.scroll_pane )
				end;
			},
			{
				name = "Одежда";
				func_Create = function( )
					UIe.scroll_pane, UIe.scroll_bar = ibCreateScrollpane( 30, 140, 740, 420, UIe.bg, { scroll_px = 8, bg_color = 0x00FFFFFF } )
					UIe.scroll_bar:ibData( "sensivity", 0.1 )

					for i, info in pairs( SHOP_ITEMS.skins ) do
						local bg = ibCreateButton( 380 * ( ( i - 1 ) % 2 ), 300 * math.floor( ( i - 1 ) / 2 ), 360, 280, UIe.scroll_pane, "img/item_bg.png", "img/item_bg_h.png", "img/item_bg_h.png" )
						ibCreateArea( 0, 0, 360, 280, bg )

						ibCreateLabel( 0, 22, 0, 0, info.name, bg, COLOR_WHITE, 1, 1, "center", "center" ):ibData( "font", ibFonts.regular_14 ):center_x( )
						ibCreateImage( 0, 50, 0, 0, "img/items/skins/".. info.id ..".png", bg ):ibSetRealSize( ):center_x( )

						do
							local label_cost = ibCreateLabel( 18, 250, 0, 0, format_price( info.cost ), bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_24 )
							ibCreateImage( label_cost:ibGetAfterX( 8 ), 237, 28, 28, ":nrp_shared/img/money_icon.png", bg )
						end


						ibCreateButton(	227, 230, 113, 34, bg, "img/btn_buy", true )
							:ibOnClick( function( key, state )
								if key ~= "left" or state ~= "up" then return end

								ibClick( )
								triggerServerEvent( "PlayerWantBuyItem", resourceRoot, "skins", i )
							end, false )
					end

					UIe.scroll_pane:AdaptHeightToContents( )
					UIe.scroll_bar:UpdateScrollbarVisibility( UIe.scroll_pane )
				end;
			},
		}

		tabs[ CURRENT_TAB ].func_Create( )

		local line = ibCreateImage( 30, 114, 10, 3, _, UIe.bg, 0xffff965d )

		local pos_x = 30
		local prev_lbl = nil
		for i, tab in pairs( tabs ) do
			local lbl = ibCreateLabel( pos_x, 87, 0, 20, tab.name, UIe.bg, COLOR_WHITE, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_14 ):ibData( "alpha", i == CURRENT_TAB and 255 or 150 )
				:ibOnClick( function( key, state )
					if key ~= "left" or state ~= "up" then return end
					ibClick( )

					if source == prev_lbl then return end

					prev_lbl:ibAlphaTo( 150, 250 )
					source:ibAlphaTo( 255, 250 )

					line:ibMoveTo( source:ibData( "px" ), 114, 250 )
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
addEvent( "ShowBusinessesShop", true )
addEventHandler( "ShowBusinessesShop", resourceRoot, CreateUI )

function DestroyUI( )
	if isElement( UIe.black_bg ) then
		destroyElement( UIe.black_bg )
	end
	showCursor( false )
end