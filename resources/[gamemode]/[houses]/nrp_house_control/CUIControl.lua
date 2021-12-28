loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "ShApartments" )
Extend( "CInterior" )
Extend( "CPlayer" )
Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UIe = {}

local TAB_LIST
local SELECTED_TAB
local SwitchControlTab

local DATA = {}

function ShowUIControl_handler( info )
	if isElement( UIe.black_bg ) then destroyElement( UIe.black_bg ) end

	DATA = info

	showCursor( true )
	ibInterfaceSound()
	
    UIe.black_bg = ibCreateBackground( 0xBF1D252E, HideUIControl, _, true )
    UIe.bg = ibCreateImage( 0, 0, 800, 580, _, UIe.black_bg, ibApplyAlpha( 0xFF475d75, 97 ) ):center( )

	UIe.head_bg    = ibCreateImage( 0, 0, UIe.bg:ibData( "sx" ), 72, _, UIe.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
                     ibCreateImage( 0, UIe.head_bg:ibGetAfterY( -1 ), UIe.bg:ibData( "sx" ), 1, _, UIe.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
	UIe.head_label = ibCreateLabel( 30, 0, 0, UIe.head_bg:ibData( "sy" ), "Оплата ЖКХ", UIe.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
	
	UIe.btn_close = ibCreateButton( UIe.bg:ibData( "sx" ) - 55, 24, 25, 25, UIe.head_bg, "images/button_close.png", "images/button_close.png", "images/button_close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC )
		:ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
			ibClick( )

			HideUIControl( )
		end )

	UIe.info_area = ibCreateArea( 274, 0, 100, UIe.head_bg:ibData( "sy" ), UIe.head_bg )
	
	local days = math.max( 0, DATA.days )
	UIe.days_text_label	= ibCreateLabel( 0, 18, 0, 0, "Оплаченные дни:", UIe.info_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_14 )
	UIe.days_label = ibCreateLabel( UIe.days_text_label:ibGetAfterX( 4 ), 16, 0, 0, days..plural( days, " день", " дня", " дней" ), UIe.info_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_16 )
	
	local debt = math.max( 0, -DATA.days )
	UIe.debt_text_label	= ibCreateLabel( 0, 20, 0, 0, "Долг:", UIe.days_text_label, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_14 )
	UIe.debt_label = ibCreateLabel( UIe.debt_text_label:ibGetAfterX( 4 ), -2, 0, 0, debt..plural( debt, " день", " дня", " дней" ), UIe.debt_text_label, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_16 )
	
	UIe.balance_text_label	= ibCreateLabel( UIe.days_label:ibGetAfterX( 40 ), 18, 0, 0, "Ваш баланс:", UIe.info_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_14 )
	UIe.balance_label = ibCreateLabel( UIe.balance_text_label:ibGetAfterX( 8 ), 14, 0, 0, format_price( localPlayer:GetMoney( ) ), UIe.info_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
	UIe.balance_money_img = ibCreateImage( UIe.balance_label:ibGetAfterX( 8 ), 16, 24, 21, ":nrp_shared/img/money_icon.png", UIe.info_area )
	UIe.btn_recharge = ibCreateButton( 0, 20, 115, 21, UIe.balance_text_label, "images/button_recharge.png", "images/button_recharge.png", "images/button_recharge.png", 0xFFFFFFFF, 0xAAFFFFFF, 0x70FFFFFF )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "up" then return end
			ibClick( )

			triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate", "house_control" )
			HideUIControl( )
		end )

	UIe.info_area:ibData( "px", UIe.btn_close:ibGetBeforeX( -30 - UIe.balance_money_img:ibGetAfterX( ) ) )

    UIe.body = ibCreateArea( 30, UIe.head_bg:ibGetAfterY( ), UIe.bg:ibData( "sx" ) - 60, UIe.bg:ibData( "sy" ) - UIe.head_bg:ibData( "sy" ), UIe.bg )
    
    UIe.btn_tab_pay = ibCreateButton( 0, 0, 233, 44, UIe.body, _, _, _, 0x00000000, 0x00000000, 0x00000000 )
		:ibOnHover( function( )
			if SELECTED_TAB == "pay" then return end
			UIe.btn_tab_pay_label:ibAlphaTo( 255, 100 )
		end )
		:ibOnLeave( function( )
			if SELECTED_TAB == "pay" then return end
			UIe.btn_tab_pay_label:ibAlphaTo( 150, 100 )
		end )
		:ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
			if SELECTED_TAB == "pay" then return end
			ibClick( )

			UIe.btn_tab_active_line:ibMoveTo( UIe.btn_tab_pay:ibData( "px" ) ):ibResizeTo( UIe.btn_tab_pay:width( ) )
			UIe.btn_tab_upgrade_label:ibAlphaTo( 150, 100 )

			SwitchControlTab( "pay", -1 )
		end )
    UIe.btn_tab_pay_label = ibCreateLabel( 0, 0, 0, 0, DATA.name, UIe.btn_tab_pay, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
	UIe.btn_tab_pay:ibData( "sx", UIe.btn_tab_pay_label:width( ) + 4 )
	UIe.btn_tab_pay_label:center( )

	UIe.btn_tab_upgrade = ibCreateButton( UIe.btn_tab_pay:ibGetAfterX( 20 ), 0, 115, 44, UIe.body, _, _, _, 0x00000000, 0x00000000, 0x00000000 )
		:ibOnHover( function( )
			if SELECTED_TAB == "upgrade" then return end
			UIe.btn_tab_upgrade_label:ibAlphaTo( 255, 100 )
		end )
		:ibOnLeave( function( )
			if SELECTED_TAB == "upgrade" then return end
			UIe.btn_tab_upgrade_label:ibAlphaTo( 150, 100 )
		end )
		:ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
			if SELECTED_TAB == "upgrade" then return end
			ibClick( )

			UIe.btn_tab_active_line:ibMoveTo( UIe.btn_tab_upgrade:ibData( "px" ) ):ibResizeTo( UIe.btn_tab_upgrade:width( ) )
			UIe.btn_tab_pay_label:ibAlphaTo( 150, 100 )

			SwitchControlTab( "upgrade", 1 )
		end )
	local txt = "Уменьшить "..(DATA.is_apartments and "квартплату" or "содержание")
    UIe.btn_tab_upgrade_label = ibCreateLabel( 0, 0, 0, 0, txt, UIe.btn_tab_upgrade, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
    UIe.btn_tab_upgrade:ibData( "sx", UIe.btn_tab_upgrade_label:width( ) + 4 )
	UIe.btn_tab_upgrade_label:center( )

	local SELECTED_TAB_btn = UIe["btn_tab_" .. ( SELECTED_TAB or "pay" )]
    UIe.btn_tab_active_line = ibCreateImage( SELECTED_TAB_btn:ibData( "px" ), SELECTED_TAB_btn:ibGetAfterY( -3 ), SELECTED_TAB_btn:ibData( "sx" ), 3, _, UIe.body, 0xffff965d )
	UIe["btn_tab_" .. ( ( SELECTED_TAB or "pay" ) == "pay" and "upgrade" or "pay" ) .."_label"]:ibData( "alpha", 150 )

	ibCreateImage( 0, UIe.btn_tab_pay:ibGetAfterY( -1 ), UIe.body:ibData( "sx" ), 1, _, UIe.body, ibApplyAlpha( COLOR_WHITE, 10 ) )

	UIe.foot_bg = ibCreateImage( 0, UIe.bg:ibData( "sy" ) - 110, UIe.bg:ibData( "sx" ), 110, _, UIe.bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
		ibCreateImage( 0, 0, UIe.bg:ibData( "sx" ), 1, _, UIe.foot_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
	local sale_info = "Вы можете продать недвижимость"
	UIe.sale_info_label = ibCreateLabel( 29, 0, 0, UIe.head_bg:ibData( "sy" ), sale_info, UIe.foot_bg, 0xFF00F957, 1, 1, "left", "center", ibFonts.regular_18 ):center_y( )

	UIe.btn_gov_sell = ibCreateButton( UIe.foot_bg:ibGetAfterX( -445 ), 0, 243, 43, UIe.foot_bg, "images/btn_gov_sell.png", "images/btn_gov_sell_hover.png", "images/btn_gov_sell_hover.png", _, _, 0xFFBBBBBB ):center_y( )
		:ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
			ibClick( )
			
			if confirmation then confirmation:destroy( ) end
			confirmation = ibConfirm( 
				{
					title = "ПРОДАЖА "..(DATA.is_apartments and "КВАРТИРЫ" or "ДОМА"), 
					text = "Вы действительно хотите продать \n"..DATA.name.." за " .. format_price( math.floor( DATA.cost * 0.5 ) ) .. "р.?\nПредметы в ящике будут уничтожены.",
					fn = function( self ) 
						self:destroy( )

						if DATA.is_apartments then
							triggerServerEvent( "PlayerWantSellApartment", resourceRoot, DATA.id, DATA.number )
						else							
							triggerServerEvent( "onViphouseSellAttempt", resourceRoot, DATA.hid )
						end
						HideUIControl( )
					end,
					escape_close = true,
				}
			 )
		end )

	UIe.btn_shared_sell = ibCreateButton( UIe.foot_bg:ibGetAfterX( -182 ), 0, 150, 43, UIe.foot_bg, "images/btn_shared_sell.png", "images/btn_shared_sell_hover.png", "images/btn_shared_sell_hover.png", _, _, 0xFFBBBBBB ):center_y( )
		:ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
			ibClick( )

			HideUIControl( )
			triggerEvent( "onPlayerWantShowHouseSaleUI", resourceRoot)
		end )


    SwitchControlTab( SELECTED_TAB or "pay", 1 )
end
addEvent( "ShowUIControl", true )
addEventHandler( "ShowUIControl", root, ShowUIControl_handler )

function SwitchControlTab( tab_id, move_type )
	if not TAB_LIST[ tab_id ] then return end

	SELECTED_TAB = tab_id

	if isElement( UIe.tab_bg ) then
		UIe.tab_bg:ibMoveTo( -25 * move_type, _, 250 ):ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )
		
		UIe.tab_bg = nil
	end

	UIe.tab_bg = ibCreateArea( 0, UIe.btn_tab_pay:ibGetAfterY( ), UIe.body:ibData( "sx" ), UIe.body:ibData( "sy" ) - UIe.btn_tab_pay:ibData( "sy" ), UIe.body )
	TAB_LIST[ tab_id ]:create( )

	UIe.tab_bg:ibBatchData( {
		alpha = 0;
		px = 25 * move_type;
	} ):ibMoveTo( 0, _, 250 ):ibAlphaTo( 255, 250 )
end

TAB_LIST = {
	pay = {
		create = function( )
			for i, days in pairs( { 1, 3, 7, 14 } ) do
				local item_body = ibCreateArea( 0, 88 * ( i - 1 ), UIe.tab_bg:ibData( "sx" ), UIe.tab_bg:ibData( "sy" ), UIe.tab_bg )
				
				ibCreateImage( 0, 19, 50, 50, "images/icon_pay.png", item_body )
				ibCreateLabel( 0, 19 + 24, 50, 0, days, item_body, 0xffb6bfc8, 1, 1, "center", "top", ibFonts.bold_14 )
				
				local cost = math.floor( days * DATA.cost_day ) * ( localPlayer:IsPremiumActive() and 0.5 or 1 )

				ibCreateLabel( 70, 22, 50, 0, "Оплата за ".. days .. plural( days, " день", " дня", " дней" ), item_body, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_16 )
				local cost_text_label = ibCreateLabel( 70, 50, 50, 0, "Сумма оплаты:", item_body, ibApplyAlpha ( COLOR_WHITE, 50 ), 1, 1, "left", "top", ibFonts.regular_14 )
				local cost_label = ibCreateLabel( cost_text_label:ibGetAfterX( 8 ), cost_text_label:ibGetBeforeY( -7 ), 50, 0, format_price( cost ), item_body, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_20 )
				ibCreateImage( cost_label:ibGetAfterX( 9 ), cost_text_label:ibGetBeforeY( -4 ), 24, 21, ":nrp_shared/img/money_icon.png", item_body )

				ibCreateButton( item_body:ibGetAfterX( -110 ), 22, 110, 39, item_body, "images/button_pay_idle.png", "images/button_pay_hover.png", "images/button_pay_hover.png", _, _, 0xFFCCCCCC )
					:ibOnClick( function( button, state )
						if button ~= "left" or state ~= "up" then return end
						ibClick( )
						if not localPlayer:HasMoney( cost ) then
							localPlayer:ShowError( "У вас недостаточно денег" )
							return
						end

						if DATA.is_apartments then
							triggerServerEvent( "PlayerWantPayApartment", resourceRoot, DATA.id, DATA.number, days )
						else							
							triggerServerEvent( "onViphouseAddcashAttempt", resourceRoot, DATA.hid, days )
						end
					end )

				ibCreateImage( 0, 88, item_body:ibData( "sx" ), 1, _, item_body, ibApplyAlpha( COLOR_WHITE, 10 ) )
			end
		end
	},

	upgrade = {
		create = function( )
			local apartments_upgrades = { "Счетчик за электроснабжение", "Счетчик за водоснабжение", "Магнит на счетчик" }

			for i, txt in pairs( apartments_upgrades ) do
				local item_body = ibCreateArea( 0, 88 * ( i - 1 ), UIe.tab_bg:ibData( "sx" ), UIe.tab_bg:ibData( "sy" ), UIe.tab_bg )

				ibCreateImage( 0, 19, 50, 50, "images/icon_upgrade_"..i..".png", item_body )
				
				local cost = 0
				if DATA.is_apartments then
					cost = APARTMENTS_CLASSES[ APARTMENTS_LIST[ DATA.id ].class ].upgrades[ i ].cost
				else
					cost = DATA.services[ i ].cost
					txt = DATA.services[ i ].name
				end
				ibCreateLabel( 70, 22, 50, 0, txt, item_body, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_16 )
				local cost_text_label = ibCreateLabel( 70, 50, 50, 0, "Стоимость:", item_body, ibApplyAlpha ( COLOR_WHITE, 50 ), 1, 1, "left", "top", ibFonts.regular_14 )
				local cost_label = ibCreateLabel( cost_text_label:ibGetAfterX( 8 ), cost_text_label:ibGetBeforeY( -7 ), 50, 0, format_price( cost ), item_body, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_20 )
				ibCreateImage( cost_label:ibGetAfterX( 9 ), cost_text_label:ibGetBeforeY( -4 ), 24, 21, ":nrp_shared/img/money_icon.png", item_body )

				if i > DATA.paid_upgrade then
					ibCreateButton( item_body:ibGetAfterX( -110 ), 22, 110, 39, item_body, "images/button_upgrade_idle.png", "images/button_upgrade_hover.png", "images/button_upgrade_hover.png", _, _, 0xFFCCCCCC )
						:ibData( "disabled", i ~= DATA.paid_upgrade + 1 )
						:ibData( "alpha", i ~= DATA.paid_upgrade + 1 and 150 or 255 )
						:ibOnClick( function( button, state )
							if button ~= "left" or state ~= "up" then return end
							ibClick( )
							if not localPlayer:HasMoney( cost ) then
								localPlayer:ShowError( "У вас недостаточно денег" )
								return
							end

							if DATA.is_apartments then
								triggerServerEvent( "PlayerWantBuyPaidUpgradeApartment", resourceRoot, DATA.id, DATA.number )
							else							
								triggerServerEvent( "onViphouseServicePurchase", resourceRoot, DATA.hid, i )
							end
						end )
				else
					ibCreateLabel( item_body:ibGetAfterX( -110 * 0.5 ), 44, 0, 0, "Установлено", item_body, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_16 )
				end

				local reduction = 0
				if DATA.is_apartments then
					reduction = APARTMENTS_CLASSES[ APARTMENTS_LIST[ DATA.id ].class ].upgrades[ i ].profit
				else
					reduction = DATA.services[ i ].reduction
				end
				item_body:ibAttachTooltip( "Стоимость содержания уменьшится на " .. format_price( reduction ).." р." )

				ibCreateImage( 0, 88, item_body:ibData( "sx" ), 1, _, item_body, ibApplyAlpha( COLOR_WHITE, 10 ) )
			end
		end
	}
}

function HideUIControl( )
	if isElement( UIe and UIe.black_bg ) then
		destroyElement( UIe.black_bg )
	end
	showCursor( false )

	SELECTED_TAB = nil
end
addEvent( "HideUIControl", true )
addEventHandler( "HideUIControl", root, HideUIControl )
