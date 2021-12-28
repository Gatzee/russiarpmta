function CreateHeader( parent )
    -- "Закрыть"
    ibCreateButton( 750, 24, 24, 24, parent,
                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowDonateUI( false )
            --SendElasticGameEvent( "f4_window_close" )
        end )
        :ibData( "priority", 1 )

    -- Заголовок
    ibCreateLabel( 30, 36, 0, 0, "Магазин", parent, 0xffffffff, _, _, "left", "center", ibFonts.bold_18 )
    
    -- Баланс
    ibCreateImage( 456, 16, 0, 0, "img/icon_account.png", parent ):ibSetRealSize( )

    local lbl_balance         = ibCreateLabel( 511, 27, 0, 0, "Ваш баланс:", parent, 0xffffffff, _, _, "left", "center", ibFonts.regular_15 )
    local lbl_balance_amount  = ibCreateLabel( lbl_balance:ibGetAfterX( 10 ), 25, 0, 0, "0", parent, 0xffffffff, _, _, "left", "center", ibFonts.bold_18 )
    local icon_balance_amount = ibCreateImage( 0, 14, 24, 24, ":nrp_shared/img/hard_money_icon.png", parent )
        
    local function UpdateBalance( )
        lbl_balance_amount:ibData( "text", format_price( localPlayer:GetDonate( ) ) )
        icon_balance_amount:ibData( "px", lbl_balance_amount:ibGetAfterX( 10 ) )
    end
    UpdateBalance( )
    icon_balance_amount:ibTimer( UpdateBalance, 500, 0 )

    local btn_add
        = ibCreateImage( 511, 40, 0, 0, "img/btn_header_add.png", parent )
        :ibSetRealSize( )
        :ibData( "alpha", 200 )

    ibCreateArea( 511, 27, 200, 40, parent )
        :ibOnHover( function( ) btn_add:ibAlphaTo( 255, 200 ) end )
        :ibOnLeave( function( ) btn_add:ibAlphaTo( 200, 200 ) end )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            SwitchNavbar( "donate" )
			
			SendElasticGameEvent( "f4r_f4_currency_link_click" )
        end )
end