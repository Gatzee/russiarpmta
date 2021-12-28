local UI_elements

for i, v in pairs( SELL_POINTS ) do
    v.color = { 25, 100, 255, 5 }
    v.marker_text = "Биржа"
    local tpoint = TeleportPoint( v )

    tpoint:SetImage( "img/marker.png" )
	tpoint.element:setData( "material", true, false )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 25, 100, 255, 255, 2.3 } )
        
    tpoint.elements = {}
    tpoint.elements.blip = createBlipAttachedTo( tpoint.marker, 19, 2, 255, 255, 255, 255, 0, 150 )
    tpoint.text = nil
    tpoint.keypress = false

    tpoint.PostJoin = function( self )
        if ibIsAnyWindowActive( ) then return end
        ShowBusinessSellChooserUI_handler( true )
        localPlayer:CompleteDailyQuest( "np_visit_exchange" )
	end

    tpoint.PostLeave = function( self )
        ShowBusinessSellChooserUI_handler( false )
        ShowBusinessSellUI_handler( false )
        ShowBusinessSellPurchaseUI_handler( false )
	end
end

function isBusinessSellChooserWindowActive( )
    local _, element = next( UI_elements or { } )
    return isElement( element )
end

function ShowBusinessSellChooserUI_handler( state, conf )
	if state then
		ShowBusinessUI_handler( false )

        ibInterfaceSound()
        ShowBusinessSellPurchaseUI_handler( false )
        ShowBusinessSellUI_handler( false )
        ShowBusinessSellChooserUI_handler( false )

        UI_elements = { }

        local x, y = guiGetScreenSize()

        UI_elements.black_bg = ibCreateBackground( _, ShowBusinessSellChooserUI_handler, true, true ):ibData( "alpha", 0 )
        local sx, sy = 600, 400
        local px, py = ( x - sx ) / 2, ( y - sy ) / 2
        UI_elements.bg = ibCreateImage( px, py, sx, sy, "img/bg_selector.png", UI_elements.black_bg )

        UI_elements.btn_close = ibCreateButton(  sx - 24 - 26, 24, 24, 24, UI_elements.bg,
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_close, function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowBusinessSellChooserUI_handler( false )
            ibClick()
        end, false )

        UI_elements.btn_purchase_existing = ibCreateButton( 99, 212, 380, 60, UI_elements.bg,
                                                            "img/btn_purchase_existing.png", "img/btn_purchase_existing_hover.png", "img/btn_purchase_existing_hover.png",
                                                            0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_purchase_existing, function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowBusinessSellChooserUI_handler( false )
            triggerServerEvent( "onBusinessSellPurchaseOpenRequest", resourceRoot )
        end, false )

        UI_elements.btn_sell = ibCreateButton(  99, 132, 380, 60, UI_elements.bg,
                                                "img/btn_sell.png", "img/btn_sell_hover.png", "img/btn_sell_hover.png",
                                                0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_sell, function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowBusinessSellChooserUI_handler( false )
            triggerServerEvent( "onBusinessSellOpenRequest", resourceRoot )
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
addEvent( "ShowBusinessSellChooserUI", true )
addEventHandler( "ShowBusinessSellChooserUI", root, ShowBusinessSellChooserUI_handler )