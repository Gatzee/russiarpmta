-------------------------------------
-----------------MAIN----------------
-------------------------------------
CONTENT = {}

function CWeddingShopSetState_handler( state )
	if state then
		ibWindowSound()
		CWeddingShopSetState_handler( false )
		IB_elements.shop = { }

		IB_elements.shop.black_bg = ibCreateBackground( 0xaa000000, CWeddingShopSetState_handler, true, true )
			:ibData( "alpha", 0 )
			:ibAlphaTo( 255, 500 )

		IB_elements.shop.bg_texture = dxCreateTexture( "files/bg_shop.png" )
		local sx, sy = dxGetMaterialSize( IB_elements.shop.bg_texture )

		local x, y = guiGetScreenSize( )
		local px, py = x / 2 - sx / 2, y / 2 - sy / 2

		IB_elements.shop.bg_image = ibCreateImage( px, py + 100, sx, sy, "files/bg_shop.png", IB_elements.shop.black_bg )
		 :ibMoveTo( px, py, 500 )
		
		IB_elements.shop.bg = ibCreateRenderTarget( 0, 0, sx, sy, IB_elements.shop.bg_image )
		:ibData( "modify_content_alpha", true )
		
		--Заголовок окна
		SUBM_Header( IB_elements.shop.bg )
		
		--Навигация
		SUBM_Navbar( IB_elements.shop.bg )
		
		--Контент
		SUBM_CreateAllContent( IB_elements.shop.bg )

		--
		SUBM_SwitchNavbar( 1 )

		showCursor( true )
	else
		DestroyTableElements( IB_elements.shop )
		OfferOverlayEnable( false )
		IB_elements.shop = {}
		showCursor( false )
	end
end
addEvent( "CWeddingShopSetState", true )
addEventHandler( "CWeddingShopSetState", localPlayer, CWeddingShopSetState_handler )


-------------------------------------
-----------------SUBM----------------
-------------------------------------
function SUBM_Header( parent )
	-- "Закрыть"
	ibCreateButton( 750, 24, 24, 24, parent,
					":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
					0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			CWeddingShopSetState_handler( false )
		end )
		:ibData( "priority", 1 )

	-- Заголовок
	ibCreateLabel( 60, 36, 0, 0, "Магазин подарков и услуг", parent, 0xffffffff, _, _, "left", "center", ibFonts.bold_13 )
	ibCreateImage( 24, 36 - 24/2, 26, 24, "files/heart.png", parent )
	
	-- Баланс
	ibCreateImage( 456, 16, 0, 0, "files/icon_account.png", parent ):ibSetRealSize( )

	local lbl_balance         = ibCreateLabel( 505, 27, 0, 0, "Ваш баланс:", parent, 0xffffffff, _, _, "left", "center", ibFonts.regular_13 )
	local lbl_balance_amount  = ibCreateLabel( lbl_balance:ibGetAfterX( 10 ), 25, 0, 0, "0", parent, 0xffffffff, _, _, "left", "center", ibFonts.bold_14 )
	local icon_balance_amount = ibCreateImage( 0, 14, 24, 24, ":nrp_shared/img/hard_money_icon.png", parent )
		
	local function UpdateBalance( )
		lbl_balance_amount:ibData( "text", format_price( localPlayer:GetDonate( ) ) )
		icon_balance_amount:ibData( "px", lbl_balance_amount:ibGetAfterX( 10 ) )
	end
	UpdateBalance( )
	icon_balance_amount:ibTimer( UpdateBalance, 500, 0 )

	local btn_add = ibCreateImage( 505, 40, 0, 0, "files/btn_header_add.png", parent )
		:ibSetRealSize( )
		:ibData( "alpha", 200 )

	ibCreateArea( 505, 27, 200, 40, parent )
		:ibOnHover( function( ) btn_add:ibAlphaTo( 255, 200 ) end )
		:ibOnLeave( function( ) btn_add:ibAlphaTo( 200, 200 ) end )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			ibClick()
			CWeddingShopSetState_handler( false )
			triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate", "wedding" )
		end )
	
end

function SUBM_CreateAllContent( parent )
	CONTENT.data = { }

	for i, v in pairs( NAVBAR_TABS ) do
		local tab = TABS_CONF[ v.key ]
		if tab then
			local tab_area = ibCreateArea( 0, 72, 800, 580 - 72, parent )
			:ibBatchData( { alpha = 0, priority = -10 } )
			:ibOnDestroy( function( ) tab.parent = nil end )

			if type( tab.fn_create ) == "function" then
				tab.parent = tab_area
				tab:fn_create( tab_area )
			end

			table.insert( CONTENT.data, { area = tab_area } )
		end
	end
end