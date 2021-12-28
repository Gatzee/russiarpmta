
function ShowPrivateUI( state, data )
    if state then
        data = data or {}
        ShowPrivateUI( false )
        
        UI_elements.black_bg = ibCreateBackground( _, ShowPrivateUI, true, true ):ibData( "alpha", 0 )
        UI_elements.bg = ibCreateImage( 0, 0, 800, 580, "files/img/private/bg.png", UI_elements.black_bg )
        :center()
        
        ibCreateButton( 748, 25, 24, 24, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            ShowPrivateUI( false )
        end )
        
        UI_elements.example_area = ibCreateArea( 463, 98, 307, 348, UI_elements.bg )
        UI_elements.example_img = ibCreateImage( 0, 0, 0, 0, "files/img/girls/big_harley.png", UI_elements.example_area )
        UI_elements.example_name = ibCreateLabel( 463, 517, 0, 0, "",  UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_14 ):ibData( "disabled", true )
        
        if not data.free_dance then
            UI_elements.example_price = ibCreateLabel( 463, 539, 0, 0, "0", UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_15 ):ibData( "disabled", true )
            UI_elements.soft_icon = ibCreateImage( UI_elements.example_price:ibGetAfterX( 6 ), 531, 17, 16, "img/soft_icon.png", UI_elements.bg ):ibData( "disabled", true )
        else
            ibCreateLabel( 463, 470, 0, 0, "Мы видели тебя в топ 1, можешь посмотреть\n1 танец бесплатно!", UI_elements.bg, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_14 ):ibData( "disabled", true )
        end

        ibCreateButton( 647, 517, 124, 33, UI_elements.bg, "files/img/private/btn_pay.png", "files/img/private/btn_pay_hovered.png", "files/img/private/btn_pay_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            if isElement( UI_elements.confirmation ) then
                UI_elements.confirmation:destroy()
            end
            ibClick()
            TryBuyPrivateDance( UI_elements.current_girl.girl_id )
        end )

        function TryBuyPrivateDance( dance_id )
            ticks = getTickCount()
            UI_elements.confirmation = ibConfirm(
            {
                title = "Стрип", 
                text = "Вы действительно хотите " .. (data.free_dance and "посмотреть" or "купить" ) ..  " приватный танец от\n\"" .. UI_elements.current_girl.name .. "\"" .. (data.free_dance and "" or " за " .. UI_elements.current_girl.price .. "р.") .. " ?" ,
                fn = function( self )
                    if getTickCount() - ticks < 200 then return end
                    if not data.free_dance and not localPlayer:IsHasMoney( UI_elements.current_girl.price, UI_elements.current_girl.currency ) then
                        localPlayer:ShowError( "У Вас недостаточно средств для оплаты" )
                        self:destroy()
                        return
                    end
                    
                    triggerServerEvent( "onServerPlayerWantBuyPrivateDance", localPlayer, dance_id )
                    self:destroy()
                end,
                escape_close = true,
            } )
        end

        function ChangeCurrentGirl( girl_id )
            local girl = PRIVATE_DANCE_GIRLS[ girl_id ]
            UI_elements.current_girl = girl
            UI_elements.current_girl.girl_id = girl_id
            UI_elements.example_img:ibData( "texture", "files/img/girls/big_" .. girl.id .. ".png" )
            :ibSetRealSize()
            :center()

            UI_elements.example_name:ibData( "text", girl.name )
            if not data.free_dance then
                UI_elements.example_price:ibData( "text", girl.price )
                UI_elements.soft_icon:ibBatchData( { px = UI_elements.example_price:ibGetAfterX( 8 ), texture = "files/img/" .. girl.currency .. "_icon.png" } )
            end
        end

        UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane( 30, 98, 413, 452, UI_elements.bg, { scroll_px = -20 } )
        UI_elements.scrollbar:ibSetStyle( "slim_nobg" )

        local px, px_1, px_2, py = 10, 10, 202, 10
        for k, v in ipairs( PRIVATE_DANCE_GIRLS ) do
            if k == 1 then
                ChangeCurrentGirl( k )
            end

            UI_elements[ k ] = ibCreateImage( px, py, 180, 180, "files/img/private/item_bg.png", UI_elements.scrollpane )
            :ibOnHover( function( )
                UI_elements[ k ]:ibData( "texture", "files/img/private/item_bg_hovered.png")
            end )
            :ibOnLeave( function( )
                UI_elements[ k ]:ibData( "texture", "files/img/private/item_bg.png")
            end )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick()
                ChangeCurrentGirl( k )
            end )

            local img_item = ibCreateImage( 0, 0, 0, 0, "files/img/girls/" .. v.id .. ".png",  UI_elements[ k ] )
            :ibSetRealSize()
            :center( 0, -1 )
            :ibData( "disabled", true )

            if not data.free_dance then
                local lbl_price = ibCreateLabel( 0, 121, 180, 0, v.price, UI_elements[ k ], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_15 ):ibData( "disabled", true )
                ibCreateImage( lbl_price:ibGetAfterX( 95 ), 112, 17, 16, "files/img/" .. v.currency .. "_icon.png", UI_elements[ k ] ):ibData( "disabled", true )
            end

            ibCreateButton( 52, 142, 76, 28, UI_elements[ k ], "files/img/private/btn_buy.png", "files/img/private/btn_buy_hovered.png", "files/img/private/btn_buy_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnHover( function( )
                UI_elements[ k ]:ibData( "texture", "files/img/private/item_bg_hovered.png")
                ChangeCurrentGirl( k )
            end )
            :ibOnLeave( function( )
                UI_elements[ k ]:ibData( "texture", "files/img/private/item_bg.png")
            end )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                if isElement( UI_elements.confirmation ) then
                    UI_elements.confirmation:destroy()
                end
                ibClick()
                ChangeCurrentGirl( k )
                TryBuyPrivateDance( k )
            end )

            px = px == px_2 and px_1 or px_2
            py = px == px_1 and py + 193 or py
        end

        UI_elements.scrollpane:AdaptHeightToContents()
		UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane )
        UI_elements.black_bg:ibAlphaTo( 255, 300 )

        showCursor( true )
    else
        if isElement( UI_elements and UI_elements.black_bg ) then
            destroyElement( UI_elements.black_bg )
        end

        if UI_elements.confirmation then
            UI_elements.confirmation:destroy( )
        end

        UI_elements = { }
        
        onCloseUI( localPlayer )
        showCursor( false )
    end
end

function onClientPlayerWantOpenPrivateDance_handler( state, data )
    ShowPrivateUI( state, data )
end
addEvent( "onClientPlayerWantOpenPrivateDance", true )
addEventHandler( "onClientPlayerWantOpenPrivateDance", resourceRoot, onClientPlayerWantOpenPrivateDance_handler )