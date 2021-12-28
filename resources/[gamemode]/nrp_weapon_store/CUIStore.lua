local sx, sy = 1024, 768
local px, py = ( _SCREEN_X - sx ) / 2, ( _SCREEN_Y - sy ) / 2

local ui = Store.ui
local IN_CART_TAGS = {} -- товары, добавляемые в корзину, отмечаются как "в корзине"

function UpdateItemInCartTag( )
    for item_id, in_cart_tag_image in pairs( IN_CART_TAGS ) do
        if not Store.cart_items[ item_id ] then
            in_cart_tag_image:ibData( "alpha", 0 )
        end
    end
end

local function CreateItemCard( px, py, pItem, parent, is_pack )
    local item_image, in_cart_tag_image
    local card_area = ibCreateArea( px, py, 307, 307, parent )
    local card_bg = ibCreateImage( 0, 0, 307, 307,  "img/card/card_bg.png", card_area)
    local card_hovered = ibCreateImage( 0, 0, 307, 307, "img/card/card_bg_hover.png", card_area ):ibData( "alpha", 0 )
    local item_hovered = ibCreateImage( 0, 0, 307, 307, pItem.hover_image, card_area )
    :ibData( "alpha", 200 )
    :ibAttachTooltip( pItem.tooltip or pItem.verbose_name )
    :ibOnHover( function( )
        source:ibAlphaTo( 255, 200 )
        card_hovered:ibAlphaTo( 255, 200 )
        card_bg:ibAlphaTo( 0, 200 )
    end )
    :ibOnLeave( function( )
        source:ibAlphaTo( 200, 200 )
        card_hovered:ibAlphaTo( 0, 200 )
        card_bg:ibAlphaTo( 255, 200 )
    end )

    if is_pack then
        item_image = ibCreateImage( 15, 3, 287, 295, pItem.image, card_area ):ibData( "disabled", true )
    else
        -- название
        ibCreateLabel( 0, 0, 307, 35, pItem.verbose_name, card_area, 0xffffffff, _, _, "center", "bottom", ibFonts.regular_12 )

        item_image = ibCreateImage( 0, 0, 0, 0, pItem.image, card_area )
        :ibSetRealSize( ):ibSetInBoundSize( 245, 120 ):center( 0, -20 ):ibData( "disabled", true )

        local premium_cost_mul = localPlayer:IsPremiumActive( ) and 0.85 or 1
        local cost_area = ibCreateArea( 0, 210, 0, 0, card_area )    
        local item_cost = ibCreateLabel( 0, 0, 0, 0, (IsGunOfferActive() and pItem.class == LICENSE) and format_price( math.ceil( pItem.cost * 0.5 * premium_cost_mul ) ) or format_price( pItem.cost * premium_cost_mul ), cost_area, 0xAAFFFFFF, 1, 1, "left", "top", ibFonts.bold_15 )
        local icon_money = ibCreateImage( item_cost:ibGetAfterX( 10 ), 0, 25, 25, ":nrp_shared/img/money_icon.png", cost_area ):ibData( "disabled", true )
        cost_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center_x( )

        in_cart_tag_image = ibCreateImage( 0, 40, 0, 0,  "img/card/in_cart.png", card_area ):ibSetRealSize( ):ibData( "alpha", 0 ):center_x( )
    end

    -- кнопка "добавить в корзину"
    ibCreateButton( is_pack and 180 or 99, is_pack and 260 or 250, 113, 34, card_area, "img/card/btn_cart_add.png", "img/card/btn_cart_add_hover.png", "img/card/btn_cart_add_hover.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnHover( function( )
            card_bg:ibAlphaTo( 0, 200 )
            card_hovered:ibAlphaTo( 255, 200 )
            item_hovered:ibAlphaTo( 255, 200 )
        end )
        :ibOnLeave( function( )
            card_bg:ibAlphaTo( 255, 200 )
            card_hovered:ibAlphaTo( 0, 200 )
            item_hovered:ibAlphaTo( 0, 200 )
        end )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            local item_count = Store.cart_items[ pItem.item_id ] and Store.cart_items[ pItem.item_id ].count or nil
            if item_count and item_count >= 10 then
                localPlayer:ShowInfo( "Достигнут лимит количества на данный товар." )
                return
            end

            if pItem.class == WEAPON then
                local license_expiration_time = localPlayer:getData( "gun_licenses" ) or 0
                if not IsPlayerGunLicenseActive( license_expiration_time ) then
                    ibInfo( { text = "Необходима действующая лицензия для покупки огнестрельного оружия" } )
                    localPlayer:ShowError( "Необходима действующая лицензия для покупки огнестрельного оружия" )
                    return
                end
            elseif pItem.class == ARMOR then
                if ( GetTotalArmorAmmoInStoreCart( pItem.item_id ) + localPlayer.armor ) > 100 then
                    ibInfo( { text = "Вы не можете купить больше брони" } )
                    return
                end
            elseif pItem.class == LICENSE then  
                if IsGunOfferActive() and item_count == 1 then
                    localPlayer:ShowError( "По скидке доступна только 1 лицензия" )
                    return
                end
                local is_permitted, message = CanPlayerBuyGunLicense( localPlayer )
                if not is_permitted then
                    localPlayer:ShowError( message )
                    return
                end
            end

            if not is_pack then
                in_cart_tag_image:ibData( "alpha", 255 )
                IN_CART_TAGS[ pItem.item_id ] = in_cart_tag_image
            end

            AddItemToCart( pItem.item_id, is_pack )

            local npx, npy = card_area:ibData( "px" ) + item_image:ibData( "px" ), card_area:ibData( "py" ) + item_image:ibData( "py" )
            ibCreateImage( npx , npy , item_image:width( ), item_image:height( ),  pItem.image, parent )
                :ibResizeTo( 10, 10, 550 )
                :ibMoveTo( parent:width( ) - 200, -70, 750 )
                :ibTimer( destroyElement, 800, 1 )
        end )
end

function IsGunOfferActive()
    return (localPlayer:getData( "offer_gun_license_time_left" ) or 0) > getRealTimestamp()
end

function ShowUI_WeaponStore( state )
    if state then
        ShowUI_WeaponStore( )

        showCursor( true )
        ibWindowSound( )

        ui.black_bg = ibCreateBackground( 0xAA000000, ShowUI_WeaponStore, true, true )
        ui.main = ibCreateArea( px + 200, py, sx, sy, ui.black_bg ):ibData( "alpha", 0 )
        ibCreateImage( 0, 0, sx, sy, "img/main_bg.png", ui.main )
        ui.header_bar = ibCreateImage( 0, 0, sx, 90, "img/header_overlay.png", ui.main )

        local body_area = ibCreateArea( 100, ui.header_bar:ibGetAfterY( ), ui.header_bar:width( ), ui.main:height( ) - ui.header_bar:height( ), ui.main ):ibData( "alpha", 0 )

        -- Заголовок
        ibCreateLabel( 30, 44, 0, 0, "Магазин оружия", ui.header_bar, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_19 )

        ui.close_btn = ibCreateButton( sx - 58, 32, 24, 24, ui.header_bar, ":nrp_shared/img/confirm_btn_close.png", nil, nil, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end

                ShowUI_WeaponStore( false )
                ibClick( )
            end )

        -- баланс игрока
        ibCreateImage( 910, 26, 25, 25, ":nrp_shared/img/money_icon.png", ui.header_bar )
        ui.lbl_balance_v = ibCreateLabel( 902, 38, 0, 0, 0, ui.header_bar, 0xFFFFFFFF, 1, 1, "right", "center", ibFonts.bold_18 )
        ui.lbl_balance = ibCreateLabel( 0, 39, 0, 0, "Ваш баланс:", ui.header_bar, nil, 1, 1, "left", "center", ibFonts.regular_14 )
        ui.btn_card = ibCreateButton( 0, 54, 0, 0, ui.header_bar, "img/btn_shopcart.png", nil, nil, 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibSetRealSize( )
        :ibTimer( function ( )
            ui.lbl_balance_v:ibData( "text", format_price( localPlayer:GetMoney( ) ) )

            local new_px = 896 - ui.lbl_balance_v:width( ) - ui.lbl_balance:width( )
            ui.lbl_balance:ibData( "px", new_px )
            ui.btn_card:ibData( "px", new_px )
        end, 500, 0 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end

            if not isElement( ui.cart_area ) then
                ibOverlaySound( )
                ShowUI_StoreCart( )
                ui.cart_area:ibMoveTo( _, ui.header_bar:ibGetAfterY( ), 200 )
            end

            ibClick( )
        end )

        local shop_area, shop_scrollbar = ibCreateScrollpane( 30, 20, 994, 640, body_area, { scroll_px = -21, scroll_py = -20 } )
        shop_scrollbar:ibSetStyle( "slim_nobg" )

        local i, j = 1, 1

        -- паки
        local end_time = localPlayer:getData( "gun_shop_offer_finish" )
        local licenses = localPlayer:getData( "gun_licenses" )
        local time = getRealTimestamp( )
        local is_lecenses = licenses and licenses > time or false

        if ( ( end_time ) or 0 ) >= time and is_lecenses then
            segment = localPlayer:getData( "weapon_shop_segment" )
            local pack_count = 0
            for k, pack in pairs( SEGMENTS[ segment ].packs ) do
                local px, py = ( i - 1 ) * 327, ( j - 1 ) * 327
                CreateItemCard( px, py, pack, shop_area, true )
                j = ( i % 3 ) == 0 and ( j + 1 ) or j
                i = ( i % 3 ) == 0 and 1 or ( i + 1 )

                pack_count = pack_count + 1
                ui[ "tick_num_" .. pack_count ] = ibCreateLabel( px + 185, py + 65, 0, 0, "0", shop_area ):ibBatchData( { font = ibFonts.bold_14, align_x = "left", align_y = "center" } )
            end

            local pack_count = table.size( SEGMENTS[ segment ].packs )
            local function UpdateTimer( )
                for i = 1, pack_count do
                    local element = ui[ "tick_num_" .. i ]
                    if isElement( element ) then
                        element:ibData( "text", getHumanTimeString( end_time, true ) )
                    end
                end
            end
            ui.main:ibTimer( UpdateTimer, 500, 0 )
            UpdateTimer( )
        end

        -- заполняем товарами
        for k, index in pairs( GOODS_SORT ) do
            local item = GOODS[ index ]
            if item then
                CreateItemCard( ( i - 1 ) * 327, ( j - 1 ) * 327, item, shop_area )
                j = ( i % 3 ) == 0 and ( j + 1 ) or j
                i = ( i % 3 ) == 0 and 1 or ( i + 1 )
            end
        end

        shop_area:AdaptHeightToContents( )
        shop_scrollbar:UpdateScrollbarVisibility( shop_area )

        ui.main:ibMoveTo( px, py, 400 ):ibAlphaTo( 255, 400, "InQuad" )
        body_area:ibMoveTo( 0, _, 480, "OutQuad" ):ibAlphaTo( 255, 400 )
    else
        for k, v in pairs( ui ) do
            if isElement( v ) then
                destroyElement( v )
            end
        end

        Store.cart_items = {}
        IN_CART_TAGS = {}
        showCursor( false )
    end
end
addEvent( "ShowWeaponStoreUI", true )
addEventHandler( "ShowWeaponStoreUI", root, ShowUI_WeaponStore )
