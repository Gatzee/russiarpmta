local UI_elements

function isPurchaseWindowActive( )
    local _, element = next( UI_elements or { } )
    return isElement( element )
end

function ShowBusinessPurchaseUI_handler( state, conf )
    if state then
        ShowBusinessPurchaseUI_handler( false )

        UI_elements = { }

        local x, y = guiGetScreenSize()

        UI_elements.black_bg = ibCreateBackground( _, ShowBusinessPurchaseUI_handler, true, true ):ibData( "alpha", 0 )
        local sx, sy = 600, 426
        local px, py = ( x - sx ) / 2, ( y - sy ) / 2
        UI_elements.bg = ibCreateImage( px, py, sx, sy, "img/bg_purchase.png", UI_elements.black_bg )

        UI_elements.btn_close = ibCreateButton(  sx - 24 - 26, 24, 24, 24, UI_elements.bg,
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_close, function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowBusinessPurchaseUI_handler( false )
        end, false )

        local image = conf.icon and split( conf.business_id, "_" )[ 1 ] or string.gsub( conf.business_id, "_%d+$", "" )
        ibCreateImage( sx / 2 - 128 / 2, 155 - 128 / 2, 128, 128, "img/icons/128x128/" .. image .. ".png", UI_elements.bg )
        ibCreateLabel( sx / 2, 230, 0, 0, conf.name or "Бизнес", UI_elements.bg ):ibBatchData( { font = ibFonts.bold_14, align_x = "center" } )
        ibCreateLabel( sx / 2, 268, 0, 0, conf.task or "Данный бизнес занимается продажей почек для айфонов", UI_elements.bg ):ibBatchData( { font = ibFonts.regular_12, align_x = "center" } )
        
        local lbl_cost = ibCreateLabel( 285, 314, 0, 0, format_price( conf.cost or 0 ), UI_elements.bg ):ibBatchData( { color = 0xffffffff, font = ibFonts.bold_14 } )
        ibCreateImage( 285 + lbl_cost:width( ) + 8, 310, 32, 32, ":nrp_shared/img/money_icon.png", UI_elements.bg )

        UI_elements.btn_purchase = ibCreateButton(  219, 356, 162, 40, UI_elements.bg,
                                                    "img/btn_purchase.png", "img/btn_purchase.png", "img/btn_purchase.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_purchase, function( button, state )
            if button ~= "left" or state ~= "up" then return end
            triggerServerEvent( "onBusinessPurchaseRequest", resourceRoot, conf.business_id )
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
addEvent( "ShowBusinessPurchaseUI", true )
addEventHandler( "ShowBusinessPurchaseUI", root, ShowBusinessPurchaseUI_handler )