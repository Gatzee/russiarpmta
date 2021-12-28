local MAX_IN_CART_ITEM_COUNT = 99

local SHOP_ITEMS = nil
local CART_ITEMS = { }

local SHOP_ITEMS_SCROLLPANE
local IN_CART_COUNT_LABELS = { }

function UpdateInCartCountLabel( item_id )
    local in_cart_count = 0
    for i, item in pairs( CART_ITEMS ) do
        if item.id == item_id then
            in_cart_count = in_cart_count + item.count
        end
    end
    local text = in_cart_count > 0 and ( "(в корзине " .. in_cart_count .. " шт.)" ) or ""
    if IN_CART_COUNT_LABELS[ item_id ] then
        IN_CART_COUNT_LABELS[ item_id ]:ibData( "text", text )
    end
end

TABS_CONF.shop = {
    fn_create = function( self, parent )
        SHOP_ITEMS = exports.nrp_clans_shop:GetShopAssortment( localPlayer, "clanpanel" )

        local filter_types = {
            "all",
            "drugs",
            "weapon",
        }

        local current_selected_btn
        local px = 30
        for i, filter_type in ipairs( filter_types ) do
            local btn = ibCreateButton( px, 20, 0, 0, parent, 
                    "img/shop/btn_" .. filter_type .. ".png", _, _, 0xAAFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                :ibSetRealSize( )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    current_selected_btn:ibBatchData( {
                        color = 0xAAFFFFFF, 
                        disabled = false, 
                    } )
                    source:ibBatchData( {
                        color = 0xFFFFFFFF, 
                        disabled = true, 
                    } )
                    current_selected_btn = source
                    ShowShopItems( filter_type )
                end )

            if i == 1 then
                current_selected_btn = btn:ibBatchData( {
                    color = 0xFFFFFFFF, 
                    disabled = true, 
                } )
            end
            px = px + btn:ibData( "sx" ) + 20
        end

        local btn_open_cart = ibCreateButton( parent:ibData( "sx" ) - 30 - 163, 28, 163, 19, parent, "img/shop/btn_open_cart.png", _, _, 0xBFffffff, 0xFFffffff, 0xFFAAAAAA )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end            
                ibClick( )

                ShowCartOverlay( parent )
            end )

        ibCreateImage( btn_open_cart:ibGetBeforeX( -20 ), 20, 1, 33, _, parent, ibApplyAlpha( COLOR_WHITE, 10 ) )

        local total_cost = 0
        local total_cost_area = ibCreateArea( 0, 30, 0, 0, parent )
        local total_cost_text_lbl = ibCreateLabel( 0, 0, 0, 0, "Итого:", total_cost_area, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "top", ibFonts.regular_12 )
        local total_cost_lbl = ibCreateLabel( total_cost_text_lbl:ibGetAfterX( 6 ), -1, 0, 0, format_price( total_cost ), total_cost_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_14 )
        local total_cost_img = ibCreateImage( total_cost_lbl:ibGetAfterX( 4 ), -2, 20, 20, ":nrp_shared/img/money_icon.png", total_cost_area )
        
        UpdateTotalCost = function( delta )
            total_cost = 0
            for i, item in pairs( CART_ITEMS ) do
                total_cost = total_cost + math.floor( item.cost ) * item.count
            end

            total_cost_lbl:ibData( "text", format_price( total_cost ) )
            total_cost_img:ibData( "px", total_cost_lbl:ibGetAfterX( 4 ) )
            total_cost_area:ibData( "px", btn_open_cart:ibGetBeforeX( -40 - total_cost_img:ibGetAfterX( ) ) )
            return total_cost
        end
        UpdateTotalCost( )

        local scrollpane, scrollbar = ibCreateScrollpane( 30, 73, parent:width( ) - 60, parent:height( ) - 73, parent, { scroll_px = 10 } )
        scrollbar:ibSetStyle( "slim_nobg" )
        SHOP_ITEMS_SCROLLPANE = scrollpane

        local area_items_bg
        function ShowShopItems( filter_type )
            IN_CART_COUNT_LABELS = { }

            if isElement( area_items_bg ) then
                area_items_bg:ibAlphaTo( 0, 100 ):ibTimer( destroyElement, 100, 1 )
                scrollbar:ibData( "position", 0 )
            end
            area_items_bg = ibCreateArea( 0, 0, 0, 0, scrollpane )

            local col_count = 3
            local col_sx = 309
            local gap = 19
            local npx, npy = 0, 0
            local i = 0
            for _i, item_info in pairs( SHOP_ITEMS ) do
                if filter_type == "all" or item_info.type == filter_type then
                    i = i + 1
                    if i > 1 and i % col_count == 1 then
                        npx = 0
                        npy = npy + col_sx + gap
                    elseif i > 1 then
                        npx = npx + col_sx + gap
                    end
                    
                    local bg = ibCreateImage( npx, npy, col_sx, col_sx, "img/shop/bg_item.png", area_items_bg )
                        :ibData( "alpha", 0 )
                    local bg_hover = ibCreateImage( 0, 0, col_sx, col_sx, "img/shop/bg_item_hover.png", bg )
                        :ibData( "disabled", true )
                        :ibData( "alpha", 0 )
                        
                    bg  
                        :ibData( "disabled", not item_info.available )
                        :ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )

                    local lbl_name = ibCreateLabel( 0, 20, 0, 0, item_info.name, bg, COLOR_WHITE, 1, 1, "center", "top", ibFonts.regular_16 )
                        :center_x( )

                    if not item_info.available then
                        ibCreateImage( lbl_name:ibGetBeforeX( -12 - 8 ), 22, 12, 16, "img/shop/icon_locked.png", bg )
                    end

                    IN_CART_COUNT_LABELS[ item_info.id ] = ibCreateLabel( 0, 42, 0, 0, item_info.lock_hint or "", bg, ibApplyAlpha( COLOR_WHITE, 65 ), 1, 1, "center", "top", ibFonts.regular_12 )
                        :center_x( )
                    if item_info.available then
                        UpdateInCartCountLabel( item_info.id )
                    end

                    ibCreateImage( 0, 0, 0, 0, "img/shop/items/" .. item_info.img .. ".png", bg )
                        :ibData( "disabled", true )
                        :ibSetRealSize( )
                        :center( 0, -20 )
                        :ibData( "alpha", not item_info.available and 120 or 255 )

                    local cost_area = ibCreateArea( 0, 210, 0, 0, bg )
                    local lbl_cost = ibCreateLabel( 0, 0, 0, 0, format_price( item_info.cost ), cost_area ):ibData( "font", ibFonts.bold_20 )
                    local icon_money = ibCreateImage( lbl_cost:ibGetAfterX( 5 ), -4, 28, 28, ":nrp_shared/img/money_icon.png", cost_area ):ibData( "disabled", true )
                    cost_area:ibData( "sx", icon_money:ibGetAfterX( ) ):center_x( )

                    local btn = ibCreateButton( 0, bg:height( ) - 20 - 34, 113, 34, bg, 
                            "img/shop/btn_addtocart.png", "img/shop/btn_addtocart_hover.png", "img/shop/btn_addtocart_hover.png", _, _, 0xFFAAAAAA )
                        :ibData( "disabled", not item_info.available )
                        :ibData( "alpha", not item_info.available and 120 or 255 )
                        :center_x( )
                        :ibOnHover( function( ) bg_hover:ibAlphaTo( 255, 200 ) end )
                        :ibOnLeave( function( ) bg_hover:ibAlphaTo( 0, 200 ) end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )

                            local is_item_in_cart = false
                            for i, v in pairs( CART_ITEMS ) do
                                if v.id == item_info.id then
                                    if v.count + 1 <= MAX_IN_CART_ITEM_COUNT then
                                        v.count = v.count + 1
                                        is_item_in_cart = true
                                    else
                                        localPlayer:ShowError( "Вы не можете купить больше " .. MAX_IN_CART_ITEM_COUNT .. " шт." )
                                        return
                                    end
                                end
                            end
                            if not is_item_in_cart then
                                local new_item = { iid = item_info.iid, count = 1 }
                                setmetatable( new_item, { __index = item_info } )
                                table.insert( CART_ITEMS, new_item )
                            end
                            UpdateInCartCountLabel( item_info.id )
                            UpdateTotalCost( )
                        end )
                    
                    bg:ibTimer( bg.ibAlphaTo, 50 * i, 1, 255, 300 )
                end
            end

            area_items_bg:ibData( "sy", npy + col_sx + 20 )
            scrollpane:AdaptHeightToContents( )
            scrollbar:UpdateScrollbarVisibility( scrollpane )
        end
        ShowShopItems( "all" )
    end,
}

function ShowCartOverlay( parent )
    if isElement( UI.bg_overlay ) then
        UI.bg_overlay
            :ibMoveTo( _, UI.bg_overlay:height( ), 200 )
            :ibTimer( destroyElement, 200, 1 )
        SHOP_ITEMS_SCROLLPANE:ibData( "disabled", false )
    end
    if not parent then return end

    ibOverlaySound( )

    local navbar_sy = UI.tab_panel.navbar.sy
    local bg_overlay = ibCreateImage( 0, parent:height( ) + navbar_sy, parent:width( ), parent:height( ) + navbar_sy, _, parent, ibApplyAlpha( 0xff1f2934, 95 ) )
        :ibData( "priority", 2 )
        :ibMoveTo( 0, -navbar_sy, 250 )
    UI.bg_overlay = bg_overlay

    local footer_sy = 202

    local columns = { 
        { "Наименование товара", 280 }, 
        { "Количество", 280 },
        { "Стоимость", 180 },
    }

    local npx, npy = 30, 84
    for i, v in pairs( columns ) do
        local name, sx = v[ 1 ], v[ 2 ]
        ibCreateLabel( npx, npy, 0, 0, name, bg_overlay, ibApplyAlpha( COLOR_WHITE, 30 ), _, _, "left", "top", ibFonts.regular_12 )
        npx = npx + sx
    end

    local scrollpane, scrollbar

    function UpdateShoppingCartList( )
        if isElement( scrollpane ) then
            scrollpane:destroy( )
            scrollbar:destroy( )
        end

        scrollpane, scrollbar = ibCreateScrollpane( 0, 113, bg_overlay:ibData( "sx" ), bg_overlay:ibData( "sy" ) - 113 - footer_sy, bg_overlay, { scroll_px = -20 } )
        scrollbar:ibSetStyle( "slim_nobg" )

        local row_sx = scrollpane:ibData( "sx" )
        local row_sy = 64

        for i, item in pairs( CART_ITEMS ) do
            local item_bg = ibCreateImage( 0, row_sy * ( i - 1 ), row_sx, row_sy, _, scrollpane, ibApplyAlpha( 0xFF314050, ( i % 2 ) * 25 ) )
                :ibData( "alpha", 0 ):ibTimer( function( self ) self:ibAlphaTo( 255, 250 ) end, 50 * i, 1 )

            local px = 30
            local column = 1
            local area = ibCreateArea( px + 6, 0, 60, row_sy, item_bg )
            local item_img = ibCreateImage( px + 6, 0, 0, 0, "img/shop/items/" .. item.img .. ".png", area )
                :ibSetRealSize( )
                :ibSetInBoundSize( 60, 50 )
                :center( )
            ibCreateLabel( px + 100, 0, 0, row_sy, item.name, item_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_14 )

            px = px + columns[ column ][ 2 ]
            column = column + 1
            local count = item.count
            local fn_ChangeItemCount
            local num_bg = ibCreateImage( px + 32, 0, 42, 26, "img/shop/num_bg.png", item_bg ):center_y( )
            local num_edit = ibCreateEdit( 0, 0, num_bg:width( ), num_bg:height( ), count, num_bg, 0xFFFFFFFF, 0, 0xFFFFFFFF )
                :ibBatchData( {
                    font = ibFonts.bold_14,
                    align_x = "center",
                    max_length = 2,
                    viewable_characters = 2,
                    pattern = "%d+",
                } )
                :ibOnDataChange( function( key, value )
                    value = tonumber( value )
                    if key ~= "text" or not value then return end
                    count = value
                    fn_ChangeItemCount( 0 )
                end )
            ibCreateButton( px, 0, 25, 25, item_bg, "img/shop/num_btn_minus.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
                :center_y( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end                    
                    ibClick( )
                    fn_ChangeItemCount( -1 )
                end )
            ibCreateButton( px + 80, 0, 25, 25, item_bg, "img/shop/num_btn_plus.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
                :center_y( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end                    
                    ibClick( )
                    fn_ChangeItemCount( 1 )
                end )

            px = px + columns[ column ][ 2 ]
            column = column + 1
            local cost_lbl = ibCreateLabel( px, 0, 0, row_sy, format_price( item.cost * count ), item_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
            local cost_img = ibCreateImage( cost_lbl:ibGetAfterX( 6 ), 18, 24, 24, ":nrp_shared/img/money_icon.png", item_bg )
                :center_y( )
            
            fn_ChangeItemCount = function( delta )
                count = math.max( 1, math.min( MAX_IN_CART_ITEM_COUNT, count + delta ) )
                item.count = count
                UpdateInCartCountLabel( item.id )
                UpdateTotalCartCost( )

                if tonumber( num_edit:ibData( "text" ) ) ~= count then
                    num_edit:ibData( "text", count )
                end
                cost_lbl:ibData( "text", format_price( item.cost * count ) )
                cost_img:ibData( "px", cost_lbl:ibGetAfterX( 6 ) )
            end

            ibCreateButton( item_bg:ibData( "sx" ) - 30 - 100, 0, 100, 34, item_bg, 
                    "img/shop/btn_delete.png", "img/shop/btn_delete_hover.png", "img/shop/btn_delete_hover.png", _, _, 0xFFCCCCCC )
                :center_y( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    ibClick( )

                    table.remove( CART_ITEMS, i )
                    UpdateInCartCountLabel( item.id )
                    UpdateTotalCartCost( )
                    UpdateShoppingCartList( )
                end )
        end

        scrollpane:AdaptHeightToContents()
        scrollbar:UpdateScrollbarVisibility( scrollpane )
    end
    UpdateShoppingCartList( )

    local footer_bg = ibCreateImage( 0, bg_overlay:height( ) - footer_sy, bg_overlay:width( ), 100, _, bg_overlay, ibApplyAlpha( COLOR_WHITE, 10 ) )
    ibCreateLine( 0, 0, footer_bg:width( ), _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, footer_bg )

    local total_cost = 0
    local total_cost_text_lbl = ibCreateLabel( 30, 45, 0, 0, "Общая стоимость:", footer_bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "top", ibFonts.regular_16 )
    local total_cost_lbl = ibCreateLabel( total_cost_text_lbl:width( ) + 8, -4, 0, 0, format_price( total_cost ), total_cost_text_lbl, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_20 )
    local total_cost_img = ibCreateImage( total_cost_lbl:ibGetAfterX( 8 ), -2, 24, 24, ":nrp_shared/img/money_icon.png", total_cost_text_lbl )

    UpdateTotalCartCost = function( delta )
        local total_cost = UpdateTotalCost( )

        total_cost_lbl:ibData( "text", format_price( total_cost ) )
        total_cost_img:ibData( "px", total_cost_lbl:ibGetAfterX( 6 ) )
    end
    UpdateTotalCartCost( )

    local btn_buy = ibCreateButton( footer_bg:ibData( "sx" ) - 30 - 113, 0, 113, 39, footer_bg, 
            "img/shop/btn_buy.png", "img/shop/btn_buy_hover.png", "img/shop/btn_buy_hover.png", _, _, 0xFFCCCCCC )
        :center_y( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            if ( CLICK_TIMEOUT or 0 ) > getTickCount() then return end
            CLICK_TIMEOUT = getTickCount() + 1000
            ibClick( )

            if not next( CART_ITEMS ) then
                localPlayer:ShowError( "Корзина пуста" )
                return
            end

            triggerServerEvent( "onClanPlayerWantBuyWeapon", localPlayer, "clanpanel", CART_ITEMS )

            CART_ITEMS = { }
            UpdateShoppingCartList( )
            UpdateTotalCartCost( )
            for item_id, label in pairs( IN_CART_COUNT_LABELS ) do
                label:ibData( "text", "" )
            end
        end )


    local btn_hide = ibCreateButton( 0, bg_overlay:height( ) - 30 - 42, 108, 42, bg_overlay, 
            "img/shop/btn_hide.png", "img/shop/btn_hide_hover.png", "img/shop/btn_hide_hover.png", _, _, 0xFFAAAAAA )
        :center_x( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowCartOverlay( false )
        end )

    SHOP_ITEMS_SCROLLPANE:ibData( "disabled", true )
end

function onClanCartCleanRequest_handler()
    if not isElement( UI.bg ) then return end

    CART_ITEMS = { }
    UpdateTotalCartCost( )
    for item_id, label in pairs( IN_CART_COUNT_LABELS ) do
        label:ibData( "text", "" )
    end
    ShowCartOverlay( false )
end
addEvent( "onClanCartCleanRequest", true )
addEventHandler( "onClanCartCleanRequest", root, onClanCartCleanRequest_handler )