local UI_elements

function ShowPlanUI_handler( state )
    if state then
        InitSimShop( )
        ShowPlanUI_handler( false )

        UI_elements = { }

        x, y = guiGetScreenSize( )
        sx, sy = 669, 580
        px, py = ( x - sx ) / 2, ( y - sy ) / 2

        UI_elements.black_bg = ibCreateBackground( _, ShowPlanUI_handler, true, true )
        UI_elements.bg = ibCreateImage( px, py, sx, sy, "img/bg_plan.png", UI_elements.black_bg )

        UI_elements.btn_close = ibCreateButton(  sx - 24 - 30, 25, 24, 24, UI_elements.bg, 
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )

        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_close, function( key, state )
            if key ~= "left" or state ~= "down" then return end
            ShowPlanUI_handler( false )
        end, false )

        showCursor( true )
    else
        if not _SIM_SHOP_OPEN then
            showCursor( false )
        end
        if isElement(UI_elements and UI_elements.black_bg) then
            destroyElement( UI_elements.black_bg )
        end
        UI_elements = nil
    end
end
addEvent( "ShowPlanUI", true )
addEventHandler( "ShowPlanUI", root, ShowPlanUI_handler )