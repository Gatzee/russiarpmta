ibUseRealFonts( true )

UI = nil
CLICK_TIMEOUT = 0

function ShowCookingUI( )
	DestroyTableElements( UI )

    UI = { }
    UI.black_bg = ibCreateBackground( 0xBF1D252E, HideCookingUI, _, true )
    UI.bg = ibCreateImage( 0, 0, 1024, 768, _, UI.black_bg, 0xFF465b72 ):center( )

	UI.head_bg  = ibCreateImage( 0, 0, UI.bg:ibData( "sx" ), 80, _, UI.bg, ibApplyAlpha( COLOR_BLACK, 10 ) )
                  ibCreateImage( 0, UI.head_bg:ibGetAfterY( -1 ), UI.bg:ibData( "sx" ), 1, _, UI.head_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )
	UI.head_lbl = ibCreateLabel( 30, 0, 0, UI.head_bg:ibData( "sy" ), "Кулинария", UI.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 )
	
	UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 55, 24, 25, 25, UI.head_bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC )
		:ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
			ibClick( )

			HideCookingUI( )
		end )

    UI.balance_area = ibCreateArea( 0, 0, 100, UI.head_bg:ibData( "sy" ), UI.head_bg )
    UI.account_img = ibCreateImage( 0, 0, 41, 40, "images/icon_account.png", UI.balance_area ):center_y( )
    UI.balance_text_lbl = ibCreateLabel( 55, 20, 0, 0, "Ваш баланс:", UI.balance_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_14 )
    UI.balance_lbl = ibCreateLabel( UI.balance_text_lbl:ibGetAfterX( 8 ), 16, 0, 0, format_price( localPlayer:GetMoney( ) ), UI.balance_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
    UI.balance_money_img = ibCreateImage( UI.balance_lbl:ibGetAfterX( 8 ), 16, 24, 24, ":nrp_shared/img/money_icon.png", UI.balance_area )
    UI.btn_recharge = ibCreateButton( 0, 22, 115, 21, UI.balance_text_lbl, "images/button_recharge.png", "images/button_recharge.png", "images/button_recharge.png", 0xFFFFFFFF, 0xAAFFFFFF, 0x70FFFFFF )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate" )
            HideCookingUI( )
        end )

    local function UpdateBalance( )
        UI.balance_lbl:ibData( "text", format_price( localPlayer:GetMoney( ) ) )
        UI.balance_money_img:ibData( "px", UI.balance_lbl:ibGetAfterX( 8 ) )
        UI.balance_area:ibData( "px", UI.btn_close:ibGetBeforeX( -30 - UI.balance_money_img:ibGetAfterX( ) ) )
    end
    UpdateBalance( )
    UI.balance_area:ibTimer( UpdateBalance, 1000, 0 )


    UI.body = ibCreateArea( 0, UI.head_bg:ibGetAfterY( ), UI.bg:ibData( "sx" ), UI.bg:ibData( "sy" ) - UI.head_bg:ibData( "sy" ), UI.bg )

    CreateTabPanel( )

    showCursor( true )
end

UpdateCookingUI = ShowCookingUI

function HideCookingUI( )
	showCursor( false )
    if isElement( UI.black_bg ) then
		destroyElement( UI.black_bg )
	end
    UI = nil
    SELECTED_TAB = nil
end

SELECTED_TAB = 1
TABS = {
    {
        name = "Список рецептов",
        fn_create = "CreateRecipesTab",
    },
    {
        name = "Приготовление",
        fn_create = "CreateCookingTab",
    },
    {
        name = "Заказ продуктов",
        fn_create = "CreateShoppingTab",
    },
}

function CreateTabPanel( )
    UI.navbar_area = ibCreateArea( 30, 0, UI.body:ibData( "sx" ) - 60, 47, UI.body )

    for i, tab in pairs( TABS ) do
        local px = i == 1 and 0 or UI[ "btn_tab" .. ( i - 1 ) ]:ibGetAfterX( 30 )
        UI[ "btn_tab" .. i ] = ibCreateButton( px, 0, 100, UI.navbar_area:ibData( "sy" ), UI.navbar_area, _, _, _, 0x00000000, 0x00000000, 0x00000000 )
            :ibOnHover( function( )
                if SELECTED_TAB == i then return end
                UI[ "btn_tab_lbl" .. i ]:ibAlphaTo( 255, 100 )
            end )
            :ibOnLeave( function( )
                if SELECTED_TAB == i then return end
                UI[ "btn_tab_lbl" .. i ]:ibAlphaTo( 150, 100 )
            end )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                if SELECTED_TAB == i then return end
                ibClick( )

                SwitchTab( i )
            end )
        UI[ "btn_tab_lbl" .. i ] = ibCreateLabel( 0, 0, 0, 0, tab.name, UI[ "btn_tab" .. i ], COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_16 )
        UI[ "btn_tab" .. i ]:ibData( "sx", UI[ "btn_tab_lbl" .. i ]:width( ) )
        UI[ "btn_tab_lbl" .. i ]:center( ):ibData( "alpha", 150 )
    end

    UI.btn_tab_active_line = ibCreateImage( 0, UI.navbar_area:ibData( "sy" ) - 3, 0, 3, _, UI.navbar_area, 0xffff965d )
    UI[ "btn_tab_lbl" .. ( SELECTED_TAB or 1 ) ]:ibData( "alpha", 255 )
        
    ibCreateImage( 0, UI.navbar_area:ibData( "sy" ) - 1, UI.navbar_area:ibData( "sx" ), 1, _, UI.navbar_area, ibApplyAlpha( COLOR_WHITE, 10 ) )

    SwitchTab( SELECTED_TAB or 1 )
end

function SwitchTab( tab_id )    
    local move_type = SELECTED_TAB and SELECTED_TAB < tab_id and 1 or -1
	if isElement( UI.tab_area ) then
		UI.tab_area:ibMoveTo( -25 * move_type, _, 250 ):ibAlphaTo( 0, 250 ):ibTimer( destroyElement, 250, 1 )

        UI[ "btn_tab_lbl" .. SELECTED_TAB ]:ibAlphaTo( 150, 100 )
	end
    UI.btn_tab_active_line:ibMoveTo( UI[ "btn_tab" .. tab_id ]:ibData( "px" ) ):ibResizeTo( UI[ "btn_tab" .. tab_id ]:width( ) )

	UI.tab_area = ibCreateArea( -25, UI.navbar_area:ibGetAfterY( ), UI.body:ibData( "sx" ), UI.body:ibData( "sy" ) - UI.navbar_area:ibData( "sy" ), UI.body )
    _G[ TABS[ tab_id ].fn_create ]( )
    SELECTED_TAB = tab_id

	UI.tab_area:ibBatchData( {
		alpha = 0;
		px = 25 * move_type;
	} ):ibMoveTo( 0, _, 250 ):ibAlphaTo( 255, 250 )
end