-- Изменение текущей бабы
function RefreshCurrentGirl( girl_id )
    local girl = PODIUM_DANCE_GIRLS[ girl_id ]
    UI_elements.current_girl = girl
    UI_elements.current_girl.girl_id = girl_id
    UI_elements.example_img:ibData( "texture", "files/img/girls/big_" .. girl.id .. ".png" )
    :ibSetRealSize()
    :center()
    
    UI_elements.girl_balance:ibData( "text", (PODIM_BANK_DATA[ girl_id ] and PODIM_BANK_DATA[ girl_id ].dance_pay) and PODIUM_DANCE_GIRLS[ girl_id ].price - PODIM_BANK_DATA[ girl_id ].dance_pay or "0" )
    UI_elements.girl_balance_icon:ibBatchData( { px = UI_elements.girl_balance:ibGetAfterX( 6 ), texture = "files/img/" .. girl.currency .. "_icon.png" } )
    UI_elements.full_price:ibData( "text", girl.price )
    UI_elements.full_price_icon:ibData( "texture", "files/img/" .. girl.currency .. "_icon.png" )

    local fProgress = math.min( 1, PODIM_BANK_DATA[ girl_id ] and PODIM_BANK_DATA[ girl_id ].dance_pay / PODIUM_DANCE_GIRLS[ girl_id ].price  or 0 )
    fProgress =  math.floor( 307 * fProgress )
    UI_elements.progress_bar:ibData( "sx", 16 + fProgress )
    UI_elements.progress_bar:ibBatchData( { u = 0, v = 0, u_size = 16 + fProgress } )
end

function RefreshBankUI()
    for k, v in ipairs( PODIUM_DANCE_GIRLS ) do
        if PODIM_BANK_DATA[ k ].dance_pay == PODIUM_DANCE_GIRLS[ k ].price then
            UI_elements[ "lbl_price" .. k ]:ibData( "alpha", 0 )
            UI_elements[ "icon_price" .. k ]:ibData( "alpha", 0 )
            UI_elements[ "btn_buy_" .. k ]:ibBatchData( { disabled =  true, alpha = 0 } )
        else
            UI_elements[ "lbl_price" .. k ]:ibData( "alpha", 255 )
            UI_elements[ "icon_price" .. k ]:ibData( "alpha", 255 )
            UI_elements[ "btn_buy_" .. k ]:ibBatchData( { disabled =  false, alpha = 255 } )
        end
    end
end

function ShowPodiumUI( state, data )
    if state then
        PODIM_BANK_DATA = data
        ShowPodiumUI( false )
        
        UI_elements.black_bg = ibCreateBackground( _, ShowPodiumUI, true, true ):ibData( "alpha", 0 )

        UI_elements.bg_podium = ibCreateImage( 0, 0, 800, 580, "files/img/podium/bg.png", UI_elements.black_bg )
        :center()
        
        ibCreateButton( 748, 25, 24, 24, UI_elements.bg_podium, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            ibClick()
            ShowPodiumUI( false )
        end )

        -- Пример бабы
        UI_elements.example_area = ibCreateArea( 463, 98, 307, 348, UI_elements.bg_podium )
        UI_elements.example_img = ibCreateImage( 0, 0, 0, 0, "files/img/girls/big_harley.png", UI_elements.example_area )
        :ibSetRealSize()
        :center()

        -- Прогресс оплаты танца
        UI_elements.progress_bar = ibCreateImage( 447, 447, 339, 42, "files/img/podium/progress_active.png", UI_elements.bg_podium )
        :ibBatchData( { u = 0, v = 0, u_size = 339 } )

        UI_elements.girl_balance = ibCreateLabel( 553, 490, 0, 0, "0", UI_elements.bg_podium, 0xFF9DA4AD, 1, 1, "left", "center", ibFonts.regular_13 ):ibData( "disabled", true )
        UI_elements.girl_balance_icon = ibCreateImage( UI_elements.girl_balance:ibGetAfterX( 6 ), 481, 17, 16, "files/img/soft_icon.png", UI_elements.bg_podium )
        UI_elements.full_price = ibCreateLabel( 749, 490, 0, 0, "0", UI_elements.bg_podium, 0xFF9DA4AD, 1, 1, "right", "center", ibFonts.regular_13 ):ibData( "disabled", true )
        UI_elements.full_price_icon = ibCreateImage( 754, 481, 17, 16, "files/img/soft_icon.png", UI_elements.bg_podium )
        
        UI_elements.dummy_lbl = ibCreateLabel( 479, 521, 0, 21, "Введите сумму", UI_elements.bg_podium, 0xFF9DA4AD, 1, 1, "left", "center", ibFonts.regular_14 ):ibData( "disabled", true )
        
        UI_elements.edit_pay_money = ibCreateEdit( 479, 512, 140, 40, "", UI_elements.bg_podium, COLOR_WHITE, 0, COLOR_WHITE )
        :ibData( "font", ibFonts.regular_14 )
        :ibOnClick( function()
            if isElement( UI_elements.dummy_lbl ) then
                UI_elements.dummy_lbl:destroy()
            end
        end )
        :ibOnDataChange( function( key, value )
            if key == "text" then
                local text = UI_elements.edit_pay_money:ibData( "text" )
                local new_str = string.gsub( text, "%D", "" )
                local new_len = utf8.len( new_str )
                if utf8.len( text ) ~= new_len then
                    UI_elements.edit_pay_money:ibData( "text", new_str )
                    UI_elements.edit_pay_money:ibData( "caret_position", 0 )
                else
                    setTimer( function()
                        if UI_elements and isElement( UI_elements.edit_pay_money ) then
                            local new_len = utf8.len( UI_elements.edit_pay_money:ibData( "text" ) )
                            UI_elements.edit_pay_money:ibData( "caret_position", new_len )
                        end
                    end, 50, 1 )
                end
            end
        end )

        ibCreateButton( 647, 517, 124, 33, UI_elements.bg_podium, "files/img/podium/btn_pay.png", "files/img/podium/btn_pay_hovered.png", "files/img/podium/btn_pay_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "down" then return end
            if isElement( UI_elements.confirmation ) then
                UI_elements.confirmation:destroy()
            end
            ibClick()

            if PODIUM_DANCE then
                localPlayer:ShowError( "На подиуме уже танцует девушка, кайфуй" )
                return
            end

            local k = UI_elements.current_girl.girl_id
            local pay_money = tonumber( UI_elements.edit_pay_money:ibData( "text" ) )
            if not pay_money or pay_money == 0 then
                localPlayer:ShowError( "Некорректная сумма" )
                return
            elseif PODIM_BANK_DATA[ k ].dance_pay == PODIUM_DANCE_GIRLS[ k ].price then
                localPlayer:ShowError( "Выступление девушки уже оплачено" )
                return
            elseif ( PODIUM_DANCE_GIRLS[ k ].price - PODIM_BANK_DATA[ k ].dance_pay) - pay_money < 0 then
                localPlayer:ShowError( "Сумма превышает цену выступления" )
                return
            end
            
            ticks = getTickCount()
            UI_elements.confirmation = ibConfirm(
            {
                title = "Стрип", 
                text = "Вы действительно хотите внести сумму за танец от\n\"" .. UI_elements.current_girl.name .. "\" в размере " .. pay_money .. "р. ?" ,
                fn = function( self )
                    if getTickCount() - ticks < 200 then return end
                    if not localPlayer:IsHasMoney( pay_money,  UI_elements.current_girl.currency ) then
                        localPlayer:ShowError( "У Вас недостаточно средств для оплаты" )
                        self:destroy()
                        return
                    end
                    
                    triggerServerEvent( "onServerPlayerWantPayMoney", localPlayer, UI_elements.current_girl.girl_id, pay_money )
                    self:destroy()
                end,
                escape_close = true,
            } )
        end )

        -- Сетка баб
        UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane( 30, 98, 413, 452, UI_elements.bg_podium, { scroll_px = -20 } )
        UI_elements.scrollbar:ibSetStyle( "slim_nobg" )

        local px, px_1, px_2, py = 10, 10, 202, 10
        for k, v in ipairs( PODIUM_DANCE_GIRLS ) do
            UI_elements[ k ] = ibCreateImage( px, py, 180, 180, "files/img/podium/item_bg.png", UI_elements.scrollpane )
            :ibOnHover( function( )
                UI_elements[ k ]:ibData( "texture", "files/img/podium/item_bg_hovered.png")
            end )
            :ibOnLeave( function( )
                UI_elements[ k ]:ibData( "texture", "files/img/podium/item_bg.png")
            end )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                ibClick()
                RefreshCurrentGirl( k )
            end )

            local img_item = ibCreateImage( 0, 0, 0, 0, "files/img/girls/" .. v.id .. ".png",  UI_elements[ k ] )
            :ibSetRealSize()
            :center( 0, -1 )
            :ibData( "disabled", true )

            UI_elements[ "lbl_price" .. k ] = ibCreateLabel( 0, 121, 180, 0, v.price, UI_elements[ k ], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_15 ):ibData( "disabled", true )
            UI_elements[ "icon_price" .. k ] = ibCreateImage( UI_elements[ "lbl_price" .. k ]:ibGetAfterX( 95 ), 112, 17, 16, "files/img/" .. v.currency .. "_icon.png", UI_elements[ k ] ):ibData( "disabled", true )
            
            UI_elements[ "btn_buy_" .. k ] = ibCreateButton( 52, 142, 76, 28, UI_elements[ k ], "files/img/podium/btn_buy.png", "files/img/podium/btn_buy_hovered.png", "files/img/podium/btn_buy_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnHover( function( )
                UI_elements[ k ]:ibData( "texture", "files/img/podium/item_bg_hovered.png")
            end )
            :ibOnLeave( function( )
                UI_elements[ k ]:ibData( "texture", "files/img/podium/item_bg.png")
            end )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end
                if isElement( UI_elements.confirmation ) then
                    UI_elements.confirmation:destroy()
                end
                ibClick()
                RefreshCurrentGirl( k )

                if PODIUM_DANCE then
                    localPlayer:ShowError( "На подиуме уже танцует девушка, кайфуй" )
                    return
                end

                ticks = getTickCount()
                UI_elements.confirmation = ibConfirm(
                {
                    title = "Стрип", 
                    text = "Вы действительно хотите оплатить танец от\n\"" .. v.name .. "\" за " .. v.price - PODIM_BANK_DATA[ k ].dance_pay .. "р. ?" ,
                    fn = function( self )
                        if getTickCount() - ticks < 200 then return end
                        if not localPlayer:IsHasMoney( v.price, v.currency ) then
                            localPlayer:ShowError( "У Вас недостаточно средств для оплаты" )
                            self:destroy()
                            return
                        elseif PODIM_BANK_DATA[ k ].dance_pay == PODIUM_DANCE_GIRLS[ k ].price then
                            localPlayer:ShowError( "Выступление девушки уже оплачено" )
                            self:destroy()
                            return
                        end
                        
                        triggerServerEvent( "onServerPlayerWantBuyPodiumDance", localPlayer, k )
                        self:destroy()
                    end,
                    escape_close = true,
                } )
            end )

            px = px == px_2 and px_1 or px_2
            py = px == px_1 and py + 193 or py
        end
        RefreshCurrentGirl( 1 )
        RefreshBankUI()

        UI_elements.scrollpane:AdaptHeightToContents()
		UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane )
        UI_elements.black_bg:ibAlphaTo( 255, 300 )

        showCursor( true )
    elseif UI_elements and isElement( UI_elements.black_bg ) then 
        if isElement(UI_elements and UI_elements.black_bg) then
            destroyElement( UI_elements.black_bg )
        end
        UI_elements = {}
        onCloseUI( localPlayer )
        showCursor( false )
    end
end
addEvent( "onClientShowPodiumUI", true )
addEventHandler( "onClientShowPodiumUI", resourceRoot, ShowPodiumUI )