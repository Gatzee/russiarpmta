SHOPPING_CART_LIST = { }

local shopping_scrollpane
local in_cart_count_labels = { }

function UpdateInCartCountLabel( ingredient_id )
    local in_cart_count = 0
    for i, v in pairs( SHOPPING_CART_LIST ) do
        if v[ 1 ] == ingredient_id then
            in_cart_count = in_cart_count + v[ 2 ]
        end
    end
    local text = in_cart_count > 0 and ( "(в корзине " .. in_cart_count .. ")" ) or ""
    in_cart_count_labels[ ingredient_id ]:ibData( "text", text )
end

function CreateShoppingTab( )
    local columns = { 
        { "Наименование товара", 252 }, 
        { "Время доставки", 212 },
        { "Количество", 207 },
        { "Стоимость", 180 },
    }

    local npx, npy = 30, 26
    for i, v in pairs( columns ) do
        local name, sx = v[ 1 ], v[ 2 ]
        ibCreateLabel( npx, npy, 0, 0, name, UI.tab_area, ibApplyAlpha( COLOR_WHITE, 30 ), 1, 1, "left", "top", ibFonts.regular_12 )
        npx = npx + sx
    end

    local footer_sy = 100

	local scrollpane, scrollbar = ibCreateScrollpane( 0, 52, UI.tab_area:ibData( "sx" ), UI.tab_area:ibData( "sy" ) - 52 - footer_sy, UI.tab_area, { scroll_px = -20 } )
    scrollbar:ibSetStyle( "slim_nobg" )
    shopping_scrollpane = scrollpane

    local i = 0
    local row_sx = scrollpane:ibData( "sx" )
    local row_sy = 64

    for ingredient_id, ingredient in pairs( FOOD_INGREDIENTS ) do
        if GetIngerdientCost( ingredient_id ) then
            i = i + 1
            local item_bg = ibCreateImage( 0, row_sy * ( i - 1 ), row_sx, row_sy, _, scrollpane, ibApplyAlpha( 0xFF314050, ( i % 2 ) * 25 ) )

            local px = 30
            local column = 1
            local item_img = ibCreateImage( px, 0, 0, 0, "images/ingredients/" .. ingredient.sid .. ".png", item_bg )
                :ibSetRealSize( ):center_y( )
            local name_lbl = ibCreateLabel( item_img:ibGetAfterX( 8 ), 20, 0, 0, ingredient.name, item_bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )

            in_cart_count_labels[ ingredient_id ] = ibCreateLabel( name_lbl:width( ) + 7, 5, 0, 0, "", name_lbl, ibApplyAlpha( COLOR_WHITE, 75 ), 1, 1, "left", "top", ibFonts.regular_12 )
            UpdateInCartCountLabel( ingredient_id )

            px = px + columns[ column ][ 2 ]
            column = column + 1
            local timer_img = ibCreateImage( px, 0, 0, 0, "images/icon_timer.png", item_bg )
                :ibSetRealSize( ):center_y( )
            local mins = math.floor( ingredient.delivery_time / 60 )
            local secs = ingredient.delivery_time % 60
            local time_str = ( mins > 0 and ( mins .. " мин " ) or "" ) .. ( secs > 0 and ( secs .. " с" ) or "" )
            ibCreateLabel( timer_img:ibGetAfterX( 8 ), 23, 0, 0, time_str, item_bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_14 )

            px = px + columns[ column ][ 2 ]
            column = column + 1
            local count = 1
            local fn_ChangeItemCount
            ibCreateButton( px, 0, 24, 24, item_bg,
				"images/num_btn_minus.png", "images/num_btn_minus.png", "images/num_btn_minus.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
                :center_y( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end                    
                    ibClick( )

                    fn_ChangeItemCount( -1 )
                end )
            local num_bg = ibCreateImage( px + 32, 0, 38, 24, "images/num_bg.png", item_bg ):center_y( )
            local num_lbl = ibCreateLabel( 0, 0, num_bg:ibData( "sx" ), num_bg:ibData( "sy" ), count, num_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
            ibCreateButton( px + 80, 0, 24, 24, item_bg,
				"images/num_btn_plus.png", "images/num_btn_plus.png", "images/num_btn_plus.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
                :center_y( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end                    
                    ibClick( )

                    fn_ChangeItemCount( 1 )
                end )

            px = px + columns[ column ][ 2 ]
            column = column + 1
            local cost_lbl = ibCreateLabel( px, 18, 0, 0, format_price( GetIngerdientCost( ingredient_id ) ), item_bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
            local cost_img = ibCreateImage( cost_lbl:ibGetAfterX( 6 ), 18, 24, 24, ":nrp_shared/img/money_icon.png", item_bg )
            
            fn_ChangeItemCount = function( delta )
                count = math.max( 1, math.min( MAX_ORDER_ITEM_COUNT, count + delta ) )

                num_lbl:ibData( "text", count )
                cost_lbl:ibData( "text", format_price( GetIngerdientCost( ingredient_id ) ) * count )
                cost_img:ibData( "px", cost_lbl:ibGetAfterX( 6 ) )
            end

            local btn_select = ibCreateButton( item_bg:ibData( "sx" ) - 30 - 113, 0, 113, 34, item_bg, 
                "images/button_addtocart_idle.png", "images/button_addtocart_hover.png", "images/button_addtocart_hover.png", _, _, 0xFFCCCCCC )
                :center_y( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    ibClick( )

                    local is_item_in_cart = false
                    for i, v in pairs( SHOPPING_CART_LIST ) do
                        if v[ 1 ] == ingredient_id then
                            if v[ 2 ] + count <= MAX_ORDER_ITEM_COUNT then
                                v[ 2 ] = v[ 2 ] + count
                                is_item_in_cart = true
                            else
                                localPlayer:ShowError( "Вы не можете заказать больше " .. MAX_ORDER_ITEM_COUNT .. " шт." )
                                return
                            end
                        end
                    end
                    if not is_item_in_cart then
                        table.insert( SHOPPING_CART_LIST, { ingredient_id, count } )
                    end
                    UpdateInCartCountLabel( ingredient_id )
                    UpdateTotalCartCost( )
                end )
        end
    end

	scrollpane:AdaptHeightToContents()
    scrollbar:UpdateScrollbarVisibility( scrollpane )

    local footer_bg = ibCreateImage( 0, UI.tab_area:ibData( "sy" ) - footer_sy, UI.tab_area:ibData( "sx" ), footer_sy, _, UI.tab_area, ibApplyAlpha( COLOR_WHITE, 10 ) )
    ibCreateImage( 0, 0, footer_bg:ibData( "sx" ) - 60, 1, _, footer_bg, ibApplyAlpha( COLOR_WHITE, 10 ) )

    local total_cost = 0
    local total_cost_text_lbl = ibCreateLabel( 30, 24, 0, 0, "Общая стоимость:", footer_bg, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "top", ibFonts.regular_16 )
    local total_cost_lbl = ibCreateLabel( total_cost_text_lbl:width( ) + 8, -4, 0, 0, format_price( total_cost ), total_cost_text_lbl, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_20 )
    local total_cost_img = ibCreateImage( total_cost_lbl:ibGetAfterX( 8 ), -2, 24, 24, ":nrp_shared/img/money_icon.png", total_cost_text_lbl )

    UpdateTotalCartCost = function( delta )
        total_cost = 0
        for i, v in pairs( SHOPPING_CART_LIST ) do
            local ingredient_id = v[ 1 ]
            local count = v[ 2 ]
            local ingredient = FOOD_INGREDIENTS[ ingredient_id ]
            total_cost = total_cost + math.floor( GetIngerdientCost( ingredient_id ) ) * count
        end

        total_cost_lbl:ibData( "text", format_price( total_cost ) )
        total_cost_img:ibData( "px", total_cost_lbl:ibGetAfterX( 6 ) )
    end
    UpdateTotalCartCost( )

    local btn_open_cart = ibCreateButton( 0, 28, 178, 24, total_cost_text_lbl, 
        "images/button_open_cart.png", "images/button_open_cart.png", "images/button_open_cart.png", 0xBFffffff, 0xFFffffff, 0xFFCCCCCC )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end            
            ibClick( )

            ShowCartOverlay( )
        end )

    local btn_order = ibCreateButton( footer_bg:ibData( "sx" ) - 30 - 113, 0, 113, 39, footer_bg, 
        "images/button_order_idle.png", "images/button_order_hover.png", "images/button_order_hover.png", _, _, 0xFFCCCCCC )
        :center_y( )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            if CLICK_TIMEOUT > getTickCount() then return end
            CLICK_TIMEOUT = getTickCount() + 700
            ibClick( )

            if not next( SHOPPING_CART_LIST ) then
                localPlayer:ShowError( "Корзина пуста" )
                return
            end

            if localPlayer:GetMoney( ) < total_cost then
                localPlayer:ShowError( "Недостаточно денег" )
                return
            end

            triggerServerEvent( "onPlayerWantOrderIngredients", localPlayer, SHOPPING_CART_LIST )

            SHOPPING_CART_LIST = { }
            UpdateTotalCartCost( )
            for ingredient_id, label in pairs( in_cart_count_labels ) do
                label:ibData( "text", "" )
            end
        end )
end

function ShowCartOverlay( )
    ibOverlaySound( )

    local cart_bg_sy = UI.tab_area:ibData( "sy" )
    local cart_bg = ibCreateImage( 0, UI.tab_area:ibData( "sy" ), UI.tab_area:ibData( "sx" ), 0, _, UI.tab_area, ibApplyAlpha( 0xFF1f2934, 95 ) )
        :ibMoveTo( 0, 0, 250 ):ibResizeTo( UI.tab_area:ibData( "sx" ), UI.tab_area:ibData( "sy" ), 250 )
    
    local columns = { 
        { "Наименование товара", 280 }, 
        { "Количество", 280 },
        { "Стоимость", 180 },
    }

    local npx, npy = 30, 26
    for i, v in pairs( columns ) do
        local name, sx = v[ 1 ], v[ 2 ]
        ibCreateLabel( npx, npy, 0, 0, name, cart_bg, ibApplyAlpha( COLOR_WHITE, 30 ), _, _, "left", "top", ibFonts.regular_12 )
        npx = npx + sx
    end

    local scrollpane, scrollbar

    function UpdateShoppingCartList( )
        if isElement( scrollpane ) then
            scrollpane:destroy( )
            scrollbar:destroy( )
        end

        scrollpane, scrollbar = ibCreateScrollpane( 0, 52, cart_bg:ibData( "sx" ), cart_bg_sy - 52, cart_bg, { scroll_px = -20 } )
        scrollbar:ibSetStyle( "slim_nobg" )

        local row_sx = scrollpane:ibData( "sx" )
        local row_sy = 64

        for i, order_data in pairs( SHOPPING_CART_LIST ) do
            local ingredient_id = order_data[ 1 ]
            local ingredient = FOOD_INGREDIENTS[ ingredient_id ]
            local count = order_data[ 2 ]

            local item_bg = ibCreateImage( 0, row_sy * ( i - 1 ), row_sx, row_sy, _, scrollpane, ibApplyAlpha( 0xFF314050, ( i % 2 ) * 25 ) )
                :ibData( "alpha", 0 ):ibTimer( function( self ) self:ibAlphaTo( 255, 250 ) end, 50 * i, 1 )

            local px = 30
            local column = 1
            local item_img = ibCreateImage( px, 0, 0, 0, "images/ingredients/" .. ingredient.sid .. ".png", item_bg )
                :ibSetRealSize( ):center_y( )
            ibCreateLabel( item_img:ibGetAfterX( 8 ), 20, 0, 0, ingredient.name, item_bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )

            px = px + columns[ column ][ 2 ]
            column = column + 1
            local fn_ChangeItemCount
            ibCreateButton( px, 0, 24, 24, item_bg,
                "images/num_btn_minus.png", "images/num_btn_minus.png", "images/num_btn_minus.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
                :center_y( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end                    
                    ibClick( )

                    fn_ChangeItemCount( -1 )
                end )
            local num_bg = ibCreateImage( px + 32, 0, 38, 24, "images/num_bg.png", item_bg ):center_y( )
            local num_lbl = ibCreateLabel( 0, 0, num_bg:ibData( "sx" ), num_bg:ibData( "sy" ), count, num_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_14 )
            ibCreateButton( px + 80, 0, 24, 24, item_bg,
                "images/num_btn_plus.png", "images/num_btn_plus.png", "images/num_btn_plus.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFFB0B0B0 )
                :center_y( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end                    
                    ibClick( )

                    fn_ChangeItemCount( 1 )
                end )

            px = px + columns[ column ][ 2 ]
            column = column + 1
            local cost_lbl = ibCreateLabel( px, 18, 0, 0, format_price( GetIngerdientCost( ingredient_id ) * count ), item_bg, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
            local cost_img = ibCreateImage( cost_lbl:ibGetAfterX( 6 ), 18, 24, 24, ":nrp_shared/img/money_icon.png", item_bg )
            
            fn_ChangeItemCount = function( delta )
                count = math.max( 1, math.min( MAX_ORDER_ITEM_COUNT, count + delta ) )
                order_data[ 2 ] = count
                UpdateInCartCountLabel( ingredient_id )
                UpdateTotalCartCost( )

                num_lbl:ibData( "text", count )
                cost_lbl:ibData( "text", format_price( GetIngerdientCost( ingredient_id ) * count ) )
                cost_img:ibData( "px", cost_lbl:ibGetAfterX( 6 ) )
            end

            ibCreateButton( item_bg:ibData( "sx" ) - 30 - 100, 0, 100, 34, item_bg, 
                "images/button_delete_idle.png", "images/button_delete_hover.png", "images/button_delete_hover.png", _, _, 0xFFCCCCCC )
                :center_y( )
                :ibOnClick( function( button, state )
                    if button ~= "left" or state ~= "up" then return end
                    ibClick( )

                    table.remove( SHOPPING_CART_LIST, i )
                    UpdateInCartCountLabel( ingredient_id )
                    UpdateTotalCartCost( )
                    UpdateShoppingCartList( )
                end )
        end

        scrollpane:AdaptHeightToContents()
        scrollbar:UpdateScrollbarVisibility( scrollpane )
    end
    UpdateShoppingCartList( )

    shopping_scrollpane:ibData( "disabled", true )

    local btn_hide_cart = ibCreateButton( 0, cart_bg_sy - 30 - 42, 108, 42, cart_bg, 
        "images/button_hide_idle.png", "images/button_hide_hover.png", "images/button_hide_hover.png", _, _, 0xFFCCCCCC )
        :center_x( ):ibData( "priority", 1 )
        :ibData( "alpha", 0 ):ibTimer( function( self ) self:ibAlphaTo( 255, 250 ) end, 250, 1 )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            cart_bg:destroy( )
            shopping_scrollpane:ibData( "disabled", false )
        end )
end