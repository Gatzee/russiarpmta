local UI_elements = { }

function isBusinessSellPurchaseWindowActive( )
    local _, element = next( UI_elements or { } )
    return isElement( element )
end

function ShowBusinessSellPurchaseUI_handler( state, conf )
    if state then
        ShowBusinessSellPurchaseUI_handler( false )

        --iprint( "Show business sell purchase ui" )

        UI_elements = { }

        local x, y = guiGetScreenSize()

        UI_elements.black_bg = ibCreateBackground( _, function()
            ShowBusinessSellPurchaseUI_handler( false )
            ShowBusinessSellChooserUI_handler( true )
        end, true, true ):ibData( "alpha", 0 )

        local sx, sy = 800, 580
        local px, py = ( x - sx ) / 2, ( y - sy ) / 2
        UI_elements.bg = ibCreateImage( px, py, sx, sy, "img/bg_sell_purchase.png", UI_elements.black_bg )

        UI_elements.btn_close = ibCreateButton(  sx - 24 - 26, 24, 24, 24, UI_elements.bg,
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        addEventHandler( "ibOnElementMouseClick", UI_elements.btn_close, function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ShowBusinessSellPurchaseUI_handler( false )
            ShowBusinessSellChooserUI_handler( true )
        end, false )

        UI_elements.rt, UI_elements.sc = ibCreateScrollpane( 0, 170, sx, sy - 170, UI_elements.bg, 
            {
                scroll_px = -22,
                bg_sx = 0,
                handle_sy = 40,
                handle_sx = 16,
                handle_texture = ":nrp_shared/img/scroll_bg_small.png",
                handle_upper_limit = -40 - 20,
                handle_lower_limit = 20,
            }
        )
        UI_elements.sc:ibData( "sensivity", 0.05 )
        if conf.businesses then 
            UpdateBusinessesList_handler( conf.businesses )
        end
        
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
addEvent( "ShowBusinessSellPurchaseUI", true )
addEventHandler( "ShowBusinessSellPurchaseUI", root, ShowBusinessSellPurchaseUI_handler )

function UpdateBusinessesList_handler( businesses )
    if not isElement( UI_elements.bg ) then return end

    local element_prefix = "list_bg_"
    local element_num = 1
    while isElement( UI_elements[ element_prefix .. element_num ] ) do
        destroyElement( UI_elements[ element_prefix .. element_num ] )
        element_num = element_num + 1
    end

    local row_height = 58
    local is_black_bg = true
    local npx, npy = 0, 0
    local sx = 800

    for i = 1, #businesses do
        local business_info = businesses[ i ]

        local is_locked = business_info.balance <= 0

        -- Фон
        local element_id = element_prefix .. i
        local bg = ibCreateImage( npx, npy, sx, row_height, _, UI_elements.rt, is_black_bg and 0x33000000 or 0 )

        local padlock = is_locked and ibCreateImage( 30, 21, 12, 14, "img/icon_lock.png", bg )

        local offset = is_locked and 60 or 30

        -- Название и баланс
        local lbl_name = ibCreateLabel( offset, 8, 0, row_height, business_info.name or "Бизнес", bg ):ibData( "font", ibFonts.bold_11 )
        ibCreateLabel( offset + lbl_name:width( ) + 10, 10, 0, row_height, "(" .. ( business_info.level or 1 ) .. ")", bg ):ibBatchData( { font = ibFonts.bold_9, color = 0xaaffffff } )
        ibCreateLabel( offset, 32, 0, row_height, "#f6d08fБаланс лицевого счёта: #ffffff" .. ( business_info.balance or 0 ), bg ):ibBatchData( { font = ibFonts.bold_10, colored = true } )
        
        -- Владелец
        ibCreateLabel( 300, 0, 0, row_height, business_info.owner_name, bg, 0xffffffff, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_10 )

        -- Цена
        local cost = format_price( business_info.cost )
        local lbl_cost = ibCreateLabel( 485, 0, 0, row_height, cost, bg, 0xffffffff, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_12 )
        ibCreateImage( 485 + lbl_cost:width( ) + 10, 16, 24, 24, ":nrp_shared/img/money_icon.png", bg )

        -- Кнопка "Купить"
        local btn_buy = ibCreateButton( 640, 13, 130, 32, bg,
                                        "img/btn_purchase_small.png", "img/btn_purchase_small.png", "img/btn_purchase_small.png",
                                        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 ):ibData( "color_disabled", 0xffffffff )

        addEventHandler( "ibOnElementMouseClick", btn_buy, function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            if UI_elements.confirmation then UI_elements.confirmation:destroy() end
            UI_elements.confirmation = ibConfirm(
                {
                    title = "ПОДТВЕРЖДЕНИЕ ПОКУПКИ",
                    text = "Ты действительно хочешь купить бизнес\n" .. business_info.name .. " (Владелец: " .. business_info.owner_name .. ") за " .. cost .. " р.?",
                    black_bg = 0xaa000000,
                    fn = function( self )
                        triggerServerEvent( "onBusinessPurchaseSelectRequest", resourceRoot, business_info.business_id )
                        self:destroy()
                    end,
                    escape_close = true,
                }
            )

        end, false )

        if is_locked then
            for i, v in pairs( getElementChildren( bg ) ) do
                if v ~= padlock then
                    v:ibData( "alpha", 100 )
                    v:ibData( "disabled", true )
                end
            end

            local area = ibCreateArea( 0, 0, sx, row_height, bg )
            :ibAttachTooltip( "Бизнес заблокирован, так как его лицевой счет не соответствует параметрам продажи." )
        end

        UI_elements[ element_id ] = bg

        is_black_bg = not is_black_bg
        npy = npy + row_height
    end

    UI_elements.rt:AdaptHeightToContents( )
end
addEvent( "UpdateBusinessesList", true )
addEventHandler( "UpdateBusinessesList", root, UpdateBusinessesList_handler )