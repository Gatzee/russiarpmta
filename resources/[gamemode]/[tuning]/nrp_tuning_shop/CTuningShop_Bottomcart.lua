function CreateBottomCart( data )
    UI_elements.bg_bottom_cart = ibCreateImage( wBottomCart.px, wBottomCart.py, wBottomCart.sx, wBottomCart.sy, "img/bg_cart.png" )


    UI_elements.btn_bottom_cart_reset = ibCreateButton(    338, 12, 111, 45, UI_elements.bg_bottom_cart,
                                                    "img/btn_reset.png", "img/btn_reset.png", "img/btn_reset.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 ):ibData( "color_disabled", 0x55ffffff )
    addEventHandler( "ibOnElementMouseClick", UI_elements.btn_bottom_cart_reset, function( key, state )
        if key ~= "left" or state ~= "up" then return end

        ibClick()
        if confirmation then confirmation:destroy() end
        confirmation = ibConfirm(
            {
                title = "ОЧИСТКА КОРЗИНЫ",
                text = "Ты действительно хочешь очистить корзину?",
                black_bg = 0xaa000000,
                fn = function( self )
                    self:destroy()
                    CartClear( )
                end,
                escape_close = true,
            }
        )

    end, false )

    UI_elements.btn_bottom_cart_open = ibCreateButton(     442, -5, 144, 80, UI_elements.bg_bottom_cart,
                                                    "img/btn_cart.png", "img/btn_cart.png", "img/btn_cart.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 ):ibData( "color_disabled", 0x55ffffff )

    addEventHandler( "ibOnElementMouseClick", UI_elements.btn_bottom_cart_open, function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick()
        CreateCart( )
        HideCart( true )
        ShowCart( )
    end, false )

    UI_elements.lbl_bottom_cart_amount = ibCreateLabel( 115, 35, 0, 0, "0", UI_elements.bg_bottom_cart ):ibBatchData( { font = ibFonts.semibold_14 } )

end

function ShowBottomCart( instant )
    if instant then
        UI_elements.bg_bottom_cart:ibBatchData(
            {
                px = wBottomCart.px, py = wBottomCart.py
            }
        )

    else
        UI_elements.bg_bottom_cart:ibMoveTo( wBottomCart.px, wBottomCart.py, 150 * ANIM_MUL, "OutQuad" )

    end

    if IS_HOME_MENU then
        ShowBottombar( instant, true )
    end
end

function HideBottomCart( instant )
    if instant then
        UI_elements.bg_bottom_cart:ibBatchData(
            {
                px = wBottomCart.px, py = y
            }
        )

    else
        UI_elements.bg_bottom_cart:ibMoveTo( wBottomCart.px, y, 150 * ANIM_MUL, "OutQuad" )

    end

    if IS_HOME_MENU then
        ShowBottombar( instant, false )
    end
end

function RefreshBottomCart( )

    local items, total_price = CartGetCalculated( )
    UI_elements.lbl_bottom_cart_amount:ibData( "text", format_price( total_price ) )

    -- Запрет использования кнопок если корзина пустая
    local is_cart_empty = #items <= 0

    UI_elements.btn_bottom_cart_reset:ibData( "disabled", is_cart_empty )
    UI_elements.btn_bottom_cart_open:ibData( "disabled", is_cart_empty )

    if is_cart_empty then
        HideBottomCart( )
    else
        ShowBottomCart( )
    end
end
addEvent( "onTuningShopCartClear", true )
addEvent( "onTuningShopCartAdd", true )
addEvent( "onTuningShopCartRemove", true )
addEventHandler( "onTuningShopCartClear", root, RefreshBottomCart )
addEventHandler( "onTuningShopCartAdd", root, RefreshBottomCart )
addEventHandler( "onTuningShopCartRemove", root, RefreshBottomCart )
