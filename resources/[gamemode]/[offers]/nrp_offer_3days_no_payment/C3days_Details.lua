local UI_elements = { }

function ShowCaseInfo( state, conf )
    if state then
        ShowCaseInfo( false )
        local conf = conf or { }

        x, y = guiGetScreenSize( )
        sx, sy = 800, 570
        px, py = ( x - sx ) / 2, ( y - sy ) / 2

        -- Сам фон
        UI_elements.black_bg = ibCreateBackground( 0x99000000, _, true )
        UI_elements.bg = ibCreateImage( px, py - 100, sx, sy, "img/bg_case_info.png" ):ibData( "alpha", 0 ):ibMoveTo( px, py, 500 ):ibAlphaTo( 255, 300 )

        -- Кнопка "Закрыть"
        ibCreateButton( sx - 24 - 30, 25, 24, 24, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowCaseInfo( false )
        end )

        -- Кнопка "Назад"
        local btn_back = ibCreateButton( 0, 0, 41 * 2 + 8, 30 * 2 + 13, UI_elements.bg, nil, nil, nil, 0, 0, 0 )
        local bg_back = ibCreateImage( 20, 22, 30, 30, "img/btn_back_hover.png", btn_back ):ibBatchData( { disabled = true, alpha = 0 } )
        ibCreateImage( 30, 30, 8, 13, "img/btn_back.png", btn_back ):ibBatchData( { disabled = true, alpha = 255 } )
        btn_back:ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowCaseInfo( false )
            Show3days_Remembered_handler( true )
        end )
        :ibOnHover( function( ) bg_back:ibAlphaTo( 255, 200 ) end )
        :ibOnLeave( function( ) bg_back:ibAlphaTo( 0, 200 ) end )

        local case_conf = conf.case_conf

        -- Название кейса
        ibCreateLabel( 400, 35, 0, 0, case_conf.name, UI_elements.bg, _, _, _, "center", "center", ibFonts.semibold_20 )

        UI_elements.rt, UI_elements.sc = ibCreateScrollpane( 400, 73, 398, 496, UI_elements.bg, { scroll_px = -20 } )
        UI_elements.sc:ibSetStyle( "slim_nobg" ):ibBatchData( { sensivity = 100, absolute = true, color = 0x99ffffff } )

        -- Контент
        local content_img = ibCreateImage( 30, 30, 0, 0, "img/cases_info/" .. conf.case_num .. ".png", UI_elements.rt ):ibSetRealSize( )
        UI_elements.rt:ibData( "sy", content_img:ibData( "sy" ) + 60 )
        UI_elements.sc:UpdateScrollbarVisibility( UI_elements.rt )

        ibCreateImage( -15, 0, 0, 0, "img/cases/" .. conf.case_num .. "_info.png", UI_elements.bg )
            :ibSetRealSize( )
            :ibData( "priority", -1 )

        local btn_buy
            = ibCreateButton( 130, 437, 0, 0, UI_elements.bg, "img/btn_buy.png", "img/btn_buy.png", "img/btn_buy.png", 0xffffffff, 0xeeffffff, 0xddffffff )
            :ibSetRealSize( )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                SelectPack( 700 + conf.case_num )
            end )
        
        local lbl_cost
            = ibCreateLabel( btn_buy:ibGetCenterX( ), btn_buy:ibGetAfterY( 20 ), 0, 0, "За " .. case_conf.amount .. " руб.", UI_elements.bg, 0xff00ff89, _, _, "center", "top", ibFonts.semibold_18 )
        
        local lbl_instead
            = ibCreateLabel( lbl_cost:ibGetCenterX( ), lbl_cost:ibGetAfterY( 5 ), 0, 0, "Вместо " .. case_conf.amount_target .. " руб.", UI_elements.bg, 0xff00bc83, _, _, "center", "top", ibFonts.semibold_14 )
        
        local width_cut = dxGetTextWidth( case_conf.amount_target .. " руб.", 1, ibFonts.semibold_14 ) + 2
        ibCreateImage( lbl_instead:ibGetAfterX( 1 ), lbl_instead:ibGetCenterY( ), -width_cut, 1, _, UI_elements.bg, 0xff00b385 )

        -- Описание скидки
        ibCreateImage( 400 - 119 / 2, 73 - 28 / 2, 119, 28, "img/icon_sale.png", UI_elements.bg )
        ibCreateLabel( 400, 73, 0, 0, "Скидка " .. case_conf.discount .. "%", UI_elements.bg, _, _, _, "center", "center", ibFonts.bold_14 )

        showCursor( true )
    else
        DestroyTableElements( UI_elements )
        UI_elements = { }

        showCursor( false )
    end
end

function IsCasesInfoActive( )
    return isElement( UI_elements and UI_elements.bg )
end