function CreateCart( )
    DestroyCart( true )

    UI_elements.bg_black_cart = ibCreateBackground( 0xaa000000, _, true ):ibData( "priority", 1 )
    UI_elements.bg_cart = ibCreateImage( wCart.px, wCart.py, wCart.sx, wCart.sy, "img/bg_cart_window.png" ):ibData( "priority", 1 )

    UI_elements.btn_cart_cancel = ibCreateButton(   184, 435, 111, 45, UI_elements.bg_cart,
                                                    "img/btn_cancel.png", "img/btn_cancel.png", "img/btn_cancel.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 ):ibData( "color_disabled", 0x55ffffff )
    addEventHandler( "ibOnElementMouseClick", UI_elements.btn_cart_cancel, function( key, state )
        if key ~= "left" or state ~= "up" then return end
        DestroyCart( )
    end, false )

    UI_elements.btn_cart_buy = ibCreateButton(  288, 418, 144, 80, UI_elements.bg_cart,
                                                "img/btn_buy.png", "img/btn_buy.png", "img/btn_buy.png",
                                                0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 ):ibData( "color_disabled", 0x55ffffff )

    addEventHandler( "ibOnElementMouseClick", UI_elements.btn_cart_buy, function( key, state )
        if key ~= "left" or state ~= "up" then return end

        local _, total_price = CartGetCalculated( )

        if confirmation then confirmation:destroy() end
        confirmation = ibConfirm(
            {
                title = "ПОДТВЕРЖДЕНИЕ ПОКУПКИ",
                text = "Ты действительно хочешь оплатить товары на сумму " .. total_price .. " р.?",
                black_bg = 0xaa000000,
                priority = 10,
                fn = function( self )
                    self:destroy()
                    triggerServerEvent( "onTuningShopCartPurchase", localPlayer, CartGet( ) )
                end,
                escape_close = true,
            }
        )

    end, false )

    -- Количество позиций
    UI_elements.lbl_cart_items = ibCreateLabel( 161, 89, 0, 0, "0", UI_elements.bg_cart ):ibBatchData( { font = ibFonts.semibold_10 } )

    -- Стоимость
    UI_elements.lbl_cart_cost = ibCreateLabel( wCart.sx-30, 87, 0, 0, "0", UI_elements.bg_cart ):ibBatchData( { font = ibFonts.semibold_12, align_x = "right" } )
    UI_elements.icon_cart_soft = ibCreateImage( wCart.sx-30, 87, 24, 21, "img/icon_soft.png", UI_elements.bg_cart )
    UI_elements.lbl_cart_cost_title = ibCreateLabel( wCart.sx-30, 87, 0, 0, "Общая стоимость:", UI_elements.bg_cart ):ibBatchData( { color = 0xffc6ced5, align_x = "right", font = ibFonts.semibold_12 } )

    -- Скролл
    UI_elements.cart_rt, UI_elements.cart_sc = ibCreateScrollpane( 30, 123, 520, 295, UI_elements.bg_cart, { bg_color = 0 } )
end

function ShowCart( instant )
    if isTimer( UI_elements.cart_destroy_timer ) then killTimer( UI_elements.cart_destroy_timer ) end
    if instant then
        UI_elements.bg_black_cart:ibData( "alpha", 255 )
        UI_elements.bg_cart:ibBatchData(
            {
                px = wCart.px, py = wCart.py
            }
        )

    else
        UI_elements.bg_black_cart:ibAlphaTo( 255, 150 * ANIM_MUL )
        UI_elements.bg_cart:ibMoveTo( wCart.px, wCart.py, 150 * ANIM_MUL, "OutQuad" )

    end

    RefreshCart( )
end

function HideCart( instant )
    if instant then
        UI_elements.bg_black_cart:ibData( "alpha", 0 )
        UI_elements.bg_cart:ibBatchData(
            {
                px = wCart.px, py = -wCart.sy
            }
        )

    else
        UI_elements.bg_black_cart:ibAlphaTo( 0, 150 * ANIM_MUL )
        UI_elements.bg_cart:ibMoveTo( wCart.px, -wCart.sy, 150 * ANIM_MUL, "OutQuad" )

    end

end

function DestroyCart( instant )
    if isTimer( UI_elements.cart_destroy_timer ) then killTimer( UI_elements.cart_destroy_timer ) end
    if instant then
        if isElement( UI_elements.bg_black_cart ) then destroyElement( UI_elements.bg_black_cart ) end
        if isElement( UI_elements.bg_cart ) then destroyElement( UI_elements.bg_cart ) end
        UI_elements.bg_black_cart = nil
        UI_elements.bg_cart = nil
    else
        HideCart( instant )
        UI_elements.cart_destroy_timer = setTimer( DestroyCart, 150 * ANIM_MUL, 1, true )
    end
end

function ClearCart( )
    local i = 1
    while isElement( UI_elements[ "cart_bg_" .. i ] ) do
        destroyElement( UI_elements[ "cart_bg_" .. i ] )
        i = i + 1
    end
end

function RefreshCart( )
    if not isElement( UI_elements.cart_rt ) then return end

    local items, total_price = CartGetCalculated( )

    -- Подсчёт количества предметов в корзине
    local items_count = #items
    UI_elements.lbl_cart_items:ibData( "text", items_count )

    -- Подсчёт общей стоимости предметов
    local total_price_str = format_price( total_price )
    UI_elements.lbl_cart_cost:ibData( "text", total_price_str )

    -- Длина текста в пикселях
    local total_price_len = dxGetTextWidth( total_price_str, 1, UI_elements.lbl_cart_cost:ibData( "font" ) )

    -- Позиция изначального текста
    local text_px = UI_elements.lbl_cart_cost:ibData( "px" )

    -- Сдвиг иконки
    local icon_px = text_px - total_price_len - 10 - 24
    UI_elements.icon_cart_soft:ibData( "px", icon_px )

    -- Сдвиг заголовка слева от иконки
    local title_px = icon_px - 10
    UI_elements.lbl_cart_cost_title:ibData( "px", title_px )

    if #items <= 0 then
        DestroyCart( )
        return
    end

    ClearCart( )

    local sx, sy = 550, 128
    local npx, npy = 0, 0
    for i, v in pairs( items ) do
        local bg = CreateCartItem( npx, npy, v.item, v.price )

        local isx, isy = 19, 24
        local btn_delete = ibCreateButton(  npx + sx - 30 - isx, sy / 2 - isy / 2, isx, isy, bg,
                                            "img/icon_delete.png", "img/icon_delete.png", "img/icon_delete.png",
                                            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )

        addEventHandler( "ibOnElementMouseClick", btn_delete, function( key, state )
            if key ~= "left" or state ~= "up" then return end

            if confirmation then confirmation:destroy() end

            confirmation = ibConfirm(
                {
                    title = "УДАЛЕНИЕ ИЗ КОРЗИНЫ", 
                    text = "Ты точно хочешь удалить предмет из корзины?" ,
                    fn = function( self ) 
                        self:destroy()
                        CartRemove( unpack( v.item ) )
                    end,
                    escape_close = true,
                    priority = 15,
                }
            )

        end, false )

        UI_elements[ "cart_bg_" .. i ] = bg
        npy = npy + 128
    end

    if npy >= UI_elements.cart_rt:ibData( "viewport_sy" ) then
        UI_elements.cart_sc:ibData( "alpha", 255 )
    else
        UI_elements.cart_sc:ibData( "alpha", 0 )
    end
    UI_elements.cart_sc:ibData( "position", 0 )
    UI_elements.cart_rt:AdaptHeightToContents( )

end
addEvent( "onTuningShopCartClear", true )
addEvent( "onTuningShopCartAdd", true )
addEvent( "onTuningShopCartRemove", true )
addEventHandler( "onTuningShopCartClear", root, RefreshCart )
addEventHandler( "onTuningShopCartAdd", root, RefreshCart )
addEventHandler( "onTuningShopCartRemove", root, RefreshCart )

function CreateCartItem( px, py, item, price )
    local parent = UI_elements.cart_rt
    if not isElement( parent ) then return end

    local item_id, item_params = unpack( item )

    local sx, sy = 550, 128

    local conversion = {
        [ TUNING_TASK_WHEELS ] = "Колёса",
        [ TUNING_TASK_WHEELS_EDIT ] = "Изменение колёс",
        [ TUNING_TASK_HYDRAULICS ] = "Гидравлика",
        [ TUNING_TASK_SUSPENSION ] = "Высота подвески",
    }

    local bg = ibCreateArea( px, py, sx, sy, parent )

    -- Нижняя линия
    ibCreateImage( 0, sy, wCart.sx, 1, _, bg, 0x15ffffff ):ibData( "priority", 5 )

    -- Цвет машины
    if item_id == TUNING_TASK_COLOR then
        CreateColorItem( "Цвет автомобиля", price, bg, sx, sy, tocolor( unpack( item_params ) ) )

    -- Цвет фар
    elseif item_id == TUNING_TASK_LIGHTSCOLOR then
        CreateColorItem( "Цвет фар", price, bg, sx, sy, tocolor( unpack( item_params ) ) )

    elseif item_id == TUNING_TASK_WHEELS_COLOR then
        CreateColorItem( "Цвет дисков", price, bg, sx, sy, tocolor( unpack( item_params ) ) )
    
    -- Внешний тюнинг
    elseif TUNING_IDS[ item_id ] then
        local component_id = TUNING_IDS[ item_id ]
        local component_friendly_name = TUNING_PARTS_NAMES[ component_id ] or "Неизвестный компонент"

        CreateNamedItem( "Внешний тюнинг: " .. component_friendly_name, price, bg, sx, sy )

    -- Уровень тонировки
    elseif item_id == TUNING_TASK_TONING then
        CreateColorItem( "Тонировка", price, bg, sx, sy, 0xaa000000 )

    elseif item_id == TUNING_TASK_NUMBERS then
        local pNumber = split( item_params[1], ":" )
        CreateNamedItem( "Номера: " .. pNumber[2], price, bg, sx, sy )

    elseif item_id == TUNING_TASK_NEON then
        CreateNamedItem( "Неон" .. inspect( item_params ), price, bg, sx, sy )

    -- Другие вещи
    elseif conversion[ item_id ] then
        CreateNamedItem( conversion[ item_id ], price, bg, sx, sy )

    end

    return bg
end

function CreateColorItem( title, price, bg, sx, sy, color )
    local rsx, rsy = 63, 63
    ibCreateImage( 0, sy / 2 - rsy / 2, rsx, rsy, "img/icon_rounded_rectangle.png", bg, color )
    ibCreateLabel( 84, 36, 0, 0, title or "Цвет", bg ):ibBatchData( { font = ibFonts.regular_12 } )
    ibCreateImage( 84, 65, 24, 21, "img/icon_soft.png", bg )
    ibCreateLabel( 84 + 24 + 12, 65 + 21 / 2, 0, 0, format_price( price ), bg ):ibBatchData( { font = ibFonts.semibold_12, align_y = "center" } )
end

function CreateNamedItem( title, price, bg, sx, sy )
    ibCreateLabel( 0, 36, 0, 0, title or "Цвет", bg ):ibBatchData( { font = ibFonts.regular_12 } )
    ibCreateImage( 0, 65, 24, 21, "img/icon_soft.png", bg )
    ibCreateLabel( 24 + 12, 65 + 21 / 2, 0, 0, format_price( price ), bg ):ibBatchData( { font = ibFonts.semibold_12, align_y = "center" } )
end