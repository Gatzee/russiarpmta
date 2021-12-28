Extend( "ib" )
ibUseRealFonts( true )

function ShowBarUI( state )
    if state then
        ShowBarUI( false )
        
        UI_elements = {}
        UI_elements.black_bg = ibCreateBackground( _, ShowBarUI, true, true ):ibData( "alpha", 0 )

        UI_elements.bg = ibCreateImage( 0, 0, 800, 580, ":nrp_strip_club/files/img/bar/bg.png", UI_elements.black_bg ):center()
        
        ibCreateButton( 748, 25, 24, 24, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                
                ibClick()
                ShowBarUI( false )
            end )
        
        UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane( 0, 72, 800, 508, UI_elements.bg, { scroll_px = -20 } )
        UI_elements.scrollbar:ibSetStyle( "slim_nobg" )

        local px, px_1, px_2, py = 29, 29, 410, 30
        for k, v in ipairs( DRINKS ) do
            
            UI_elements[ k ] = ibCreateImage( px, py, 360, 280, ":nrp_strip_club/files/img/bar/item_bg.png", UI_elements.scrollpane )
                :ibOnHover( function( )
                    UI_elements[ k ]:ibData( "texture", ":nrp_strip_club/files/img/bar/item_bg_hovered.png")
                end )
                :ibOnLeave( function( )
                    UI_elements[ k ]:ibData( "texture", ":nrp_strip_club/files/img/bar/item_bg.png")
                end )

            ibCreateLabel( 0, 11, 360, 17, v.name, UI_elements[ k ], 0xFFFFFFFF, 1, 1, "center", "top", ibFonts.regular_14 ):ibData( "disabled", true )

            local img_item = ibCreateImage( 0, 0, 0, 0, ":nrp_strip_club/files/img/bar/" .. k .. ".png",  UI_elements[ k ] ):ibSetRealSize():center( 0, -13 ):ibData( "disabled", true )

            local lbl_cost = ibCreateLabel( 20, 232, 0, 0, v.cost, UI_elements[ k ], 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_24 ):ibData( "disabled", true )
            ibCreateImage( lbl_cost:ibGetAfterX( 8 ), 238, 28, 22, ":nrp_strip_club/files/img/" .. v.currency .. "_icon.png", UI_elements[ k ] ):ibData( "disabled", true )

            ibCreateButton( 227, 230, 113, 34, UI_elements[ k ], ":nrp_strip_club/files/img/bar/btn_buy.png", ":nrp_strip_club/files/img/bar/btn_buy_hovered.png", ":nrp_strip_club/files/img/bar/btn_buy_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnHover( function( )
                    UI_elements[ k ]:ibData( "texture", ":nrp_strip_club/files/img/bar/item_bg_hovered.png")
                end )
                :ibOnLeave( function( )
                    UI_elements[ k ]:ibData( "texture", ":nrp_strip_club/files/img/bar/item_bg.png")
                end )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "down" then return end
                    if UI_elements.confirmation then
                        UI_elements.confirmation:destroy()
                        UI_elements.confirmation = nil
                    end
                    ibClick()

                    UI_elements.confirmation = ibConfirm(
                    {
                        title = "Бар", 
                        text = "Ты точно хочешь купить \" " .. v.name .. " \" за " .. v.cost .. "р. ?" ,
                        fn = function( self )
                            if localPlayer:GetMoney() < v.cost then
                                localPlayer:ShowError( "У Вас недостаточно средств для покупки" )
                                self:destroy()
                                return
                            end

                            triggerServerEvent( "onServerPlayerWantBuyAlcoholInCasino", resourceRoot, k )
                            self:destroy()
                        end,
                        escape_close = true,
                    } )
                end )

            px = px == px_2 and px_1 or px_2
            py = px == px_1 and py + 300 or py
        end

        ibCreateArea( 0, py, 800, 20, UI_elements.scrollpane )

        UI_elements.scrollpane:AdaptHeightToContents()
		UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane )
        UI_elements.black_bg:ibAlphaTo( 255, 300 )

        showCursor( true )
    elseif isElement(UI_elements and UI_elements.black_bg) then
        destroyElement( UI_elements.black_bg )
        UI_elements = nil

        showCursor( false )
    end
end