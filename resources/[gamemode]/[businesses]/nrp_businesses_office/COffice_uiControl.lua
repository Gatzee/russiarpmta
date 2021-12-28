Extend( "ib" )
Extend( "CPlayer" )
Extend( "ShUtils" )

ibUseRealFonts( true )

local UIe = { }
local invite_request_timeout = 0

function CreateUI_Control( data )
	DestroyUI_Control()
	
	UIe.black_bg = ibCreateBackground( _, DestroyUI_Control, _, true )

	showCursor( true )

	UIe.bg = ibCreateImage( 0, 0, 800, 600, "img/office_control/bg.png", UIe.black_bg ):center( )

	ibCreateButton(	748, 25, 24, 24, UIe.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end

			ibClick( )
			DestroyUI_Control()
		end, false )

	do
		local lbl_money = ibCreateLabel( 686, 37, 0, 0, format_price( localPlayer:GetMoney( ) ), UIe.bg, 0xFFFFFFFF, 1, 1, "right", "center" ):ibData( "font", ibFonts.bold_18 )
		ibCreateLabel( lbl_money:ibGetBeforeX( -8 ), 38, 0, 0, "Ваш баланс:", UIe.bg, 0xFFFFFFFF, 1, 1, "right", "center" ):ibData( "font", ibFonts.regular_14 )
	end

	ibCreateImage( 30, 92, 740, 200, "img/office_icon/".. data.class ..".png", UIe.bg )

	do
		local lbl_deposit = ibCreateLabel( 141, 370, 0, 0, format_price( data.deposit ), UIe.bg, data.deposit > 0 and 0xFFFFFFFF or tocolor( 245, 128, 128, 255 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_18 )
		ibCreateImage( lbl_deposit:ibGetAfterX( 8 ), 358, 24, 24, ":nrp_shared/img/money_icon.png", UIe.bg )

		local lbl_edit = ibCreateLabel( 305, 369, 0, 0, "Введите сумму", UIe.bg, ibApplyAlpha( COLOR_WHITE, 20 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_12 )
		local edit = ibCreateEdit( 305, 354, 175, 30, "", UIe.bg, 0x00FFFFFF, 0, COLOR_WHITE )
			:ibData( "font", ibFonts.light_14 )
			:ibData( "max_length", 10 )
			:ibOnDataChange( function( key, value )
				if key == "text" then
					if not lbl_edit:ibData( "active" ) then
						lbl_edit:ibData( "active", true )
						lbl_edit:ibData( "color", COLOR_WHITE )
					end
					lbl_edit:ibData( "text", tonumber( value ) and format_price( value ) or value )
				end
			end )

		ibCreateButton(	550, 349, 130, 39, UIe.bg, "img/office_control/btn_balance", true )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				local deposit = tonumber( edit:ibData( "text" ) )
				if not deposit or deposit <= 0 then
					return
				end

				if not localPlayer:HasMoney( deposit ) then
					localPlayer:ShowError( "Недостаточно средств!" )
					return
				end

				triggerServerEvent( "onPlayerOfficeEnterDeposit", resourceRoot, deposit )
			end, false )

		ibCreateButton(	690, 349, 80, 39, UIe.bg, "img/office_control/btn_take2", true )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				local amount = tonumber( edit:ibData( "text" ) )
				if not amount or amount ~= math.floor( amount ) or amount <= 0 then
					localPlayer:ErrorWindow( "Неверная сумма для вывода!" )
					return
				end

				triggerServerEvent( "onPlayerOfficeTakeDeposit", resourceRoot, amount )
			end )
	end

	do
		local lbl_pay_amount = ibCreateLabel( 298, 429, 0, 0, format_price( CONST_OFFICE_PAY_AMOUNT[ data.class ] ), UIe.bg, 0xFFffde96, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_14 )
		ibCreateImage( lbl_pay_amount:ibGetAfterX( 8 ), 419, 20, 20, ":nrp_shared/img/money_icon.png", UIe.bg )
	end

	do
		local lbl_edit = ibCreateLabel( 395, 550, 0, 0, "Введите ник игрока", UIe.bg, ibApplyAlpha( COLOR_WHITE, 20 ), 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_12 )
		local edit = ibCreateEdit( 395, 535, 175, 30, "", UIe.bg, COLOR_WHITE, 0, COLOR_WHITE )
			:ibData( "font", ibFonts.light_14 )
			:ibData( "max_length", 32 )
			:ibOnDataChange( function( key, value )
				if key == "focused" and source:ibData( "text" ) == "" then
					lbl_edit:ibData( "alpha", value and 0 or 255 )
				end
			end )

		ibCreateButton(	640, 530, 130, 39, UIe.bg, "img/office_control/btn_invite", true )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				if invite_request_timeout > getTickCount( ) then
					localPlayer:ShowInfo( "" )
					return
				end

				local nickname = edit:ibData( "text" )
				if nickname == "" then
					return
				end

				ibClick( )
				triggerServerEvent( "onPlayerRequestInvitePlayerInOffice", resourceRoot, nickname )
			end, false )
	end
end
addEvent( "ShowOfficeControlMenu", true )
addEventHandler( "ShowOfficeControlMenu", resourceRoot, CreateUI_Control )

function DestroyUI_Control( )
	if isElement( UIe.black_bg ) then
		destroyElement( UIe.black_bg )
	end
	showCursor( false )
end

function ShowUI_OfficeInvite( office_owner, building_num )
	if not isElement( office_owner ) then return end

	if UIe.confirmation then UIe.confirmation:destroy() end
	showCursor( true )
	UIe.confirmation = ibConfirm(
		{
			title = "ПРИГЛАШЕНИЕ В ОФИС",
			text = office_owner:GetNickName( ) .." пригласил тебя в свой офис.\nХочешь войти?",
			black_bg = 0xaa000000,
			fn = function( self )
				showCursor( false )
				self:destroy( )
				triggerServerEvent( "ClientRequestOfficeEnter", resourceRoot, office_owner, building_num )
			end,

			fn_cancel = function( self )
				showCursor( false )
			end,
			escape_close = true,
		}
	)
end
addEvent( "ShowOfficeInvite", true )
addEventHandler( "ShowOfficeInvite", resourceRoot, ShowUI_OfficeInvite )