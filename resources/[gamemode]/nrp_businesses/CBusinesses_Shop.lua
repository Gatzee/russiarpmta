local UI_elements = {}

function isBusinessShopWindowActive( )
    local _, element = next( UI_elements or { } )
    return isElement( element )
end

function ShowBusinessShopUI_handler( state, conf )
    if state then
        ShowBusinessShopUI_handler( false )

        UI_elements = { }

        local x, y = guiGetScreenSize()

        UI_elements.black_bg = ibCreateBackground( _, ShowBusinessShopUI_handler, true, true ):ibData( "alpha", 0 )
        local sx, sy = 800, 580
        local px, py = ( x - sx ) / 2, ( y - sy ) / 2
        UI_elements.bg = ibCreateImage( px, py, sx, sy, "img/bg_unique_shop.png", UI_elements.black_bg )

        UI_elements.btn_close = ibCreateButton(  sx - 24 - 26, 24, 24, 24, UI_elements.bg,
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_close, function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowBusinessShopUI_handler( false )
        end, false )

        UI_elements.black_bg:ibAlphaTo( 255, 300 )

        showCursor( true )
        
    else
        if isElement( UI_elements and UI_elements.black_bg ) then
            destroyElement( UI_elements.black_bg )
        end
        UI_elements = nil
        showCursor( false )
    end
end

function onBusinessShopShowRequest_handler( )
    ShowBusinessShopUI_handler( true )
end
addEvent( "onBusinessShopShowRequest", true )
addEventHandler( "onBusinessShopShowRequest", root, onBusinessShopShowRequest_handler )