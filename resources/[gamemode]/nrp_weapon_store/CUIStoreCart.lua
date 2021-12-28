local ui = Store.ui

function AddItemToCart( item_id, is_pack )
    local item = Store.cart_items[ item_id ]
    item_count = item and item.count + 1 or 1
    item_count = math.min( item_count, 10 )
    Store.cart_items[ item_id ] = { count = item_count, is_pack = is_pack, }
end

function RemoveItemFromCart( item_id )
    local item_count = Store.cart_items[ item_id ].count

    item_count = item_count or 1
    item_count = math.max( item_count - 1 , 0 )

    if item_count > 0 then
        Store.cart_items[ item_id ].count = item_count
    else
        Store.cart_items[ item_id ] = nil
        UpdateItemInCartTag( )
    end
end

function CalculateTotalCost( )
    if not next( Store.cart_items ) then return 0 end

    local premium_cost_mul = localPlayer:IsPremiumActive( ) and 0.85 or 1

    local offer_gun_license = ( localPlayer:getData( "offer_gun_license_time_left" ) or 0 ) > getRealTimestamp( )
    local totalCost = 0

    for index, cart_item in pairs( Store.cart_items ) do
        local segment = cart_item.is_pack and localPlayer:getData( "weapon_shop_segment" )
        local item = cart_item.is_pack and SEGMENTS[ segment ].packs[ index ] or GOODS[ index ]
        local discount = 1

        if offer_gun_license and item.class == LICENSE then discount = 0.5 end
        if cart_item.is_pack then discount = item.discount end

        totalCost = totalCost + math.ceil( item.cost * discount ) * cart_item.count * (cart_item.is_pack and 1 or premium_cost_mul)
    end

    return totalCost
end

local function CreateCartItem( i, pItem, parent, is_dark, is_pack )
    local premium_cost_mul = (not is_pack and localPlayer:IsPremiumActive( )) and 0.85 or 1

    local item_area = ibCreateArea( 0, ( i - 1 ) * 64, parent:width( ), 64, parent )
    item_area:setData( "bg_image", ibCreateImage( 0, 0, item_area:width( ), item_area:height( ), _, item_area, is_dark and 0xAA314050 or 0x00000000 ), false )

    local item_icon = ibCreateImage( 30, 30, 0, 0, pItem.icon, item_area):ibSetRealSize( ):ibSetInBoundSize( 64 ):center_y( ):ibData( "disabled", true )
    ibCreateLabel( 125, 0, 0, 0, pItem.verbose_name, item_area, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_11 ):center_y( )

    local cost_lbl, count_lbl, cost_img
    local btn_minus = ibCreateButton( 295 + 110, 0, 25, 25, item_area, "img/cart/btn_minus.png", "img/cart/btn_minus_hover.png", "img/cart/btn_minus_hover.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :center_y( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end

            RemoveItemFromCart( pItem.item_id )

            local count = Store.cart_items[ pItem.item_id ] and Store.cart_items[ pItem.item_id ].count or nil
            if count then
                count_lbl:ibData( "text", count )
                cost_lbl:ibData( "text", format_price( ( pItem.discount and math.ceil( pItem.cost * pItem.discount * premium_cost_mul ) or pItem.cost * premium_cost_mul ) * count ) )
                cost_img:ibData( "px", cost_lbl:ibGetAfterX( 8 ) )
            else
                if isElement( item_area ) then destroyElement( item_area ) end
                item_area = nil
            end

            UpdateCartContent( )

            ibClick( )
        end )

    local count_border = ibCreateImage( btn_minus:ibGetAfterX( 5 ), 0, 0, 0,  "img/cart/border.png", item_area):ibSetRealSize( ):center_y( )
    count_lbl = ibCreateLabel( 0, 0, 0, 0, Store.cart_items[ pItem.item_id ].count, count_border, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_10 ):center( )

    local btn_plus = ibCreateButton( count_border:ibGetAfterX( 5 ), 0, 25, 25, item_area, "img/cart/btn_plus.png", "img/cart/btn_plus_hover.png", "img/cart/btn_plus_hover.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :center_y( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            if IsGunOfferActive() and pItem.class == LICENSE and Store.cart_items[ pItem.item_id ].count == 1 then
                localPlayer:ShowError( "По скидке доступна только 1 лицензия" )
                return
            end

            if pItem.class == ARMOR and ( GetTotalArmorAmmoInStoreCart( pItem.item_id ) + localPlayer.armor ) > 100 then
                ibInfo( { text = "Вы не можете купить больше брони" } )
                return
            end

            AddItemToCart( pItem.item_id, Store.cart_items[ pItem.item_id ].is_pack )

            local count = Store.cart_items[ pItem.item_id ].count
            count_lbl:ibData( "text", count )
            cost_lbl:ibData( "text", format_price( ( pItem.discount and math.ceil( pItem.cost * pItem.discount * premium_cost_mul ) or pItem.cost * premium_cost_mul ) * count ) )
            cost_img:ibData( "px", cost_lbl:ibGetAfterX( 8 ) )

            UpdateCartContent( )
        end )

    local item_count = Store.cart_items[ pItem.item_id ].count
    local item_cost = ( IsGunOfferActive() and pItem.class == LICENSE ) and math.ceil ( pItem.cost * 0.5 * premium_cost_mul ) or ( pItem.discount and math.ceil( pItem.cost * pItem.discount * premium_cost_mul ) or pItem.cost * premium_cost_mul ) 

    cost_lbl = ibCreateLabel( 500 + 150, 0, 0, 0, format_price( item_cost * item_count ), item_area, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_12 ):center_y( )
    cost_img = ibCreateImage( cost_lbl:ibGetAfterX( 8 ), 0, 25, 25, ":nrp_shared/img/money_icon.png", item_area ):center_y( )

    -- кнопка "удалить"
    ibCreateButton( 0, 0, 100, 34, item_area, "img/cart/btn_delete.png", "img/cart/btn_delete_hover.png", "img/cart/btn_delete_hover.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibData( "px", item_area:width( ) - 130 ):center_y( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            Store.cart_items[ pItem.item_id ] = nil
            UpdateItemInCartTag( )

            if isElement( item_area ) then destroyElement( item_area ) end
            item_area = nil

            UpdateCartContent( )

            ibClick( )
        end )
end

function UpdateCartContent( )
    local i = 1
    local is_dark = true
    local ui_elements = ui.cart_rt:getChildren( )
    for _, elem in ipairs( ui_elements ) do
        elem:ibData( "py", ( i - 1 ) * 64 )
        elem:getData( "bg_image", false ):ibData( "color", is_dark and 0xAA314050 or 0x00000000 )
        i = i + 1
        is_dark = not is_dark
    end

    ui.cart_rt:AdaptHeightToContents( )
    ui.cart_scrollbar:UpdateScrollbarVisibility( ui.cart_rt )

    ui.total_cost_label:ibData( "text", format_price( CalculateTotalCost( ) ) )
    ui.total_cost_label:getData( "icon_money", false ):ibData( "px", ui.total_cost_label:ibGetAfterX( 10 ) )
end

function ShowUI_StoreCart( )
    DestroyCart( )

    ui.cart_area = ibCreateArea( 0, ui.main:height( ), ui.header_bar:width( ), ui.main:height( ) - ui.header_bar:height( ), ui.main )
    ibCreateImage( 0, 0, ui.cart_area:width( ), ui.cart_area:height( ),  "img/cart/cart_bg.png", ui.cart_area):ibData( "disabled", true ):center( )

    -- названия колонок в корзине
    ibCreateLabel( 30, 0, 0, 50, "Наименование товара", ui.cart_area, 0xFFAAAAAA, 1, 1, "left", "center", ibFonts.regular_10)
    ibCreateLabel( 295 + 110, 0, 0, 50, "Количество", ui.cart_area, 0xFFAAAAAA, 1, 1, "left", "center", ibFonts.regular_10)
    ibCreateLabel( 500 + 150, 0, 0, 50, "Стоимость", ui.cart_area, 0xFFAAAAAA, 1, 1, "left", "center", ibFonts.regular_10)
    --

    ibCreateLine( 0, 50, ui.cart_area:width( ), _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, ui.cart_area )

    ui.cart_rt, ui.cart_scrollbar = ibCreateScrollpane( 0, 50, 1024, 420, ui.cart_area, { scroll_px = -20 } )
    ui.cart_scrollbar:ibSetStyle( "slim_nobg" )

    local i = 1
    local is_dark = true
    local segment = localPlayer:getData( "weapon_shop_segment" )

    for index, cart_item in pairs( Store.cart_items ) do
        local item = cart_item.is_pack and SEGMENTS[ segment ].packs[ index ] or GOODS[ index ]

        CreateCartItem( i, item, ui.cart_rt, is_dark, cart_item.is_pack )
        i = i + 1
        is_dark = not is_dark
    end

    ui.cart_rt:AdaptHeightToContents( )
    ui.cart_scrollbar:UpdateScrollbarVisibility( ui.cart_rt )

    local cart_footer = ibCreateArea( 0, ui.cart_rt:ibGetAfterY( ), ui.cart_area:width( ), 100, ui.cart_area )
    ibCreateImage( 0, 0, ui.cart_area:width( ), 100,  "img/cart/footer_overlay.png", cart_footer ):ibData( "disabled", true )
    ibCreateLine( 0, 0, cart_footer:width( ), _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, cart_footer )
    ibCreateLine( 0, 100, cart_footer:width( ), _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, cart_footer )


    -- общая стоимость
    local total_cost_area = ibCreateDummy( cart_footer )
    local total_cost_title_label = ibCreateLabel( 30, 0, 0, 0, "Общая стоимость: ", total_cost_area, 0xAAFFFFFF, 1, 1, "left", "center", ibFonts.regular_12 )
    ui.total_cost_label = ibCreateLabel( total_cost_title_label:ibGetAfterX( 2 ), 0, 0, 0, format_price( CalculateTotalCost( ) ), total_cost_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_15 )
    local icon_money = ibCreateImage( ui.total_cost_label:ibGetAfterX( 7 ), 0, 25, 25, ":nrp_shared/img/money_icon.png", total_cost_area ):ibData( "disabled", true ):center_y( )
    ui.total_cost_label:setData( "icon_money", icon_money, false )

    total_cost_area:center_y( 1 )

    -- кнопка "купить"
    ibCreateButton( cart_footer:width( ) - 130, 0, 100, 39, cart_footer, "img/cart/btn_buy.png", "img/cart/btn_buy_hover.png", _, 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :center_y( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            if not next( Store.cart_items ) then
                localPlayer:ShowInfo( "В вашей корзине нету товаров!" )
                return false
            end

            local totalCost = CalculateTotalCost( )
            if localPlayer:GetMoney( ) < totalCost then
                localPlayer:ShowError( "Недостаточно денег" )
                return false
            end

            if confirmation then confirmation:destroy( ) end

            confirmation = ibConfirm(
                {
                    title = "ПОДТВЕРЖДЕНИЕ",
                    text = "Ты действительно хочешь приобрести\nтовары на сумму " .. totalCost .. "?",
                    fn = function( self )
                        self:destroy( )
                        triggerServerEvent( "onPlayerTryBuyWeaponStoreItems", resourceRoot, Store.cart_items )

                        local ui_elements = ui.cart_rt:getChildren( )
                        for _, elem in ipairs( ui_elements ) do
                            destroyElement( elem )
                        end

                        Store.cart_items = {}
                        UpdateCartContent( )
                        UpdateItemInCartTag( )
                    end,
                    fn_cancel = function( self )
                        self:destroy( )
                    end,
                    escape_close = true,
                }
            )
        end )

    -- кнопка "скрыть"
    ibCreateButton( 0, 130, 108, 42, cart_footer, "img/cart/btn_hide.png", "img/cart/btn_hide_hover.png", _, 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :center_x( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end

            DestroyCart( )
            ibClick( )
        end )
end

function DestroyCart( )
    if isElement( ui.cart_area ) then destroyElement( ui.cart_area ) end
    ui.cart_area = nil
end