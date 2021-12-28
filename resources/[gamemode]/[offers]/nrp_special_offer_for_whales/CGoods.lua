local UIe = { }

function ShowOfferGoodsForWhalesUI( state, offer_data )
    if state then
        ShowOfferGoodsForWhalesUI( false )
        showCursor( true )
        ibOverlaySound( )

        UIe.black_bg = ibCreateBackground( _, ShowOfferGoodsForWhalesUI, nil, true )
        UIe.main = ibCreateImage( 0, 0, 1024, 720, "images/goods_bg.png", UIe.black_bg ):center( ):ibData( "alpha", 0 )
        UIe.header = ibCreateImage( 0, 0, UIe.main:width( ), 80, _, UIe.main, ibApplyAlpha( COLOR_BLACK, 5 ) )
        ibCreateLine( 0, UIe.header:ibGetAfterY( -1 ), UIe.header:width( ), _, ibApplyAlpha( COLOR_WHITE, 10 ), 1, UIe.main )

        -- Заголовок
        ibCreateLabel( 30, 0, 0, 0, "Список транспорта", UIe.header, 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_20 ):center_y( )

        local close_btn = ibCreateButton( UIe.header:ibGetAfterX( -60 ), 0, 25, 25, UIe.header, ":nrp_shared/img/confirm_btn_close.png", _, _, 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :center_y( )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end

                ShowOfferGoodsForWhalesUI( false )
                ibClick( )
            end )

        local person_area = ibCreateDummy( UIe.header ):center_y( )
        local account_image = ibCreateImage( 0, 0, 0, 0, "images/account.png", person_area ):ibSetRealSize( ):center_y( )
        local balance_common_area = ibCreateDummy( person_area )
        local balance_area = ibCreateDummy( balance_common_area )
        local balance_title_label = ibCreateLabel( account_image:ibGetAfterX( 10 ), 0, 0, 0, "Ваш баланс: ", balance_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_14 )
        local balance_amount_label = ibCreateLabel( balance_title_label:ibGetAfterX( 8 ), -2, 0, 0, localPlayer:GetMoney( ), balance_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_18 )
        local money_icon = ibCreateImage( balance_amount_label:ibGetAfterX( 8 ), -2, 25, 25, ":nrp_shared/img/money_icon.png", balance_area ):ibData( "disabled", true ):center_y( )

        local deposit_btn = ibCreateButton( account_image:ibGetAfterX( 10 ), money_icon:ibGetAfterY( 4 ), 112, 10,  balance_common_area, "images/deposit.png", _, _, 0xFFFFFFFF, 0xAAFFFFFF, 0x70FFFFFF )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )

                UIe.loading = ibLoading( { parent =  UIe.black_bg } )
                    :ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )
                    :ibTimer( function( self )
                        self:destroy( )
                        ShowOfferGoodsForWhalesUI( false )
                        triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate", "special_offer_for_whales" )
                    end, 750, 1 )
            end )
        
        local function UpdateBalance( )
            balance_amount_label:ibData( "text", format_price( localPlayer:GetMoney( ) ) )
            money_icon:ibData( "px", balance_amount_label:ibGetAfterX( 8 ) )
            person_area:ibData( "px", close_btn:ibGetBeforeX( -30 - money_icon:ibGetAfterX( ) ) )
        end
        UpdateBalance( )
        balance_area:ibTimer( UpdateBalance, 1000, 0 )

        -- person_area:ibData( "px", close_btn:ibGetBeforeX( -10 ) - money_icon:ibGetAfterX( ) )
        balance_common_area:ibData( "sy", deposit_btn:ibGetAfterY( ) ):center_y( 3 )

        local shop_area, shop_scrollbar = ibCreateScrollpane( 30, UIe.header:ibGetAfterY( ), UIe.header:width( ) - 30, UIe.main:height( ) - UIe.header:height( ), UIe.main, { scroll_px = -20 } )
        shop_scrollbar:ibSetStyle( "slim_nobg" )

        -- заполняем товарами
        local i, j = 1, 1
        for k, pItem in pairs( offer_data ) do
            pItem.item_index = k
            CreateItemCard( ( i - 1 ) * 492, 30 + ( j - 1 ) * 386, pItem, shop_area )
            j = ( i % 2 ) == 0 and ( j + 1 ) or j
            i = ( i % 2 ) == 0 and 1 or 2
        end

        shop_area:AdaptHeightToContents( ):ibData( "sy", shop_area:ibData( "sy" ) + 30 )
        shop_scrollbar:UpdateScrollbarVisibility( shop_area )

        local npy = UIe.main:ibData( "py" )
        UIe.main:ibData( "py", npy - 200 ):ibMoveTo( _, npy, 250 ):ibAlphaTo( 255, 250 )
    else
        DestroyTableElements( UIe )
        showCursor( false )
    end
end

function CreateItemCard( px, py, pItem, parent)
    local card_area = ibCreateArea( px, py, 472, 366, parent )
    local card_bg = ibCreateImage( 0, 0, 472, 366,  "images/card_bg.png", card_area)
    local card_hover = ibCreateImage( 0, 0, 472, 366,  "images/card_hover.png", card_area)
        :ibData( "alpha", 0 )
        :ibOnHover( function( )
            source:ibAlphaTo( 255, 200 )
            card_bg:ibAlphaTo( 0, 200 )
        end )
        :ibOnLeave( function( )
            source:ibAlphaTo( 0, 200 )
            card_bg:ibAlphaTo( 255, 200 )
        end )


    local config = VEHICLE_CONFIG[ pItem.vehicle_id ]
    if not config then
        iprint( "not VEHICLE_CONFIG", pItem.vehicle_id )
        return
    end
    local name = config.model .. ( config.variants[ 2 ] and ( " " .. config.variants[ pItem.variant or 1 ].mod ) or "" )
    local item_name_label = ibCreateLabel( 0, 18, 0, 0, name, card_area, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts.regular_16 ):center_x( )
    local item_image = ibCreateContentImage( 26, 56, 600, 316, "vehicle", pItem.vehicle_id, card_area )
        :ibBatchData( { sx = 420, sy = 220, disabled = true } )

    local non_discount_area = ibCreateDummy( card_area )
    local non_discount_title = ibCreateLabel( 0, 0, 0, 0, "Цена без скидки: ", non_discount_area, ibApplyAlpha( COLOR_WHITE, 60 ), 1, 1, "left", "center", ibFonts.regular_16 )
    local non_discount_money = ibCreateImage( non_discount_title:ibGetAfterX( 5 ), 0, 22, 22,  ":nrp_shared/img/money_icon.png", non_discount_area):center_y( ):ibData( "disabled", true )
    local non_discount_cost_label = ibCreateLabel( non_discount_money:ibGetAfterX( 8 ), 0, 0, 0, format_price( pItem.cost_original ), non_discount_area, ibApplyAlpha( COLOR_WHITE, 70 ), _, _, "left", "center", ibFonts.bold_18 )
    ibCreateLine( non_discount_money:ibGetBeforeX( -5 ), 0, non_discount_cost_label:ibGetAfterX( 5 ), _, ibApplyAlpha( COLOR_WHITE, 80 ), 1, non_discount_area )

    local cost_area = ibCreateDummy( card_area )
    local cost_title = ibCreateLabel( 0, 0, 0, 0, "Цена: ", cost_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_16 )
    local cost_money = ibCreateImage( cost_title:ibGetAfterX( 5 ), 0, 22, 22,  ":nrp_shared/img/money_icon.png", cost_area ):center_y( ):ibData( "disabled", true )
    local cost_label = ibCreateLabel( cost_money:ibGetAfterX( 8 ), -1, 0, 0, format_price( pItem.cost ), cost_area, _, _, _, "left", "center", ibFonts.bold_20 )

    non_discount_area:ibBatchData( { px = 20, py = card_area:height( )-60 , sy = non_discount_title:height( ) } )
    cost_area:ibBatchData( { px = 20, py = non_discount_area:ibGetAfterY( 10 ) } )

    ibCreateButton( card_area:width( ) - 20 - 149, 312, 149, 34, card_area, "images/btn_details.png", "images/btn_details_h.png", "images/btn_details_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnHover( function( )
            card_bg:ibAlphaTo( 0, 200 )
            card_hover:ibAlphaTo( 255, 200 )
        end )
        :ibOnLeave( function( )
            card_bg:ibAlphaTo( 255, 200 )
            card_hover:ibAlphaTo( 0, 200 )
        end )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            ShowVehicleDetailsOverlay( pItem )
        end )
end

function ShowVehicleDetailsOverlay( data )
    ibOverlaySound()
    
    local overlay_rt = ibCreateRenderTarget( 0, UIe.header:ibGetAfterY( ), UIe.header:width( ), UIe.main:height( ) - UIe.header:height( ), UIe.main )
		:ibBatchData( { priority = 2, overlay = true } )

    local overlay_bg = ibCreateImage( 0, overlay_rt:height( ), 1024, 640, "images/overlay_bg.png", overlay_rt )
        :ibMoveTo( 0, 0 )

    local config = VEHICLE_CONFIG[ data.vehicle_id ]
    local variant_config = config.variants[ data.variant or 1 ]

    --Название транспорта средства
    local name = config.model .. ( config.variants[ 2 ] and ( " " .. variant_config.mod ) or "" )
    ibCreateLabel( 303, 46, 0, 0, name, overlay_bg, 0xFFFFFFFF, _, _, "center", "center", ibFonts.bold_22 )
    --Превью транспортного средства
    ibCreateContentImage( 95, 134, 600, 316, "vehicle", data.vehicle_id, overlay_bg )
        :ibBatchData( { sx = 420, sy = 220, disabled = true } )

    if not config.special_type then
        -- triangle
        exports.nrp_tuning_shop:generateTriangleTexture( 252, 407, overlay_bg, getVehicleOriginalParameters( data.vehicle_id ) )

        ibCreateImage( 640, 30, 283, 32, "images/automobile_info.png", overlay_bg )
        --Класс автомобиля
        ibCreateLabel( 799, 32, 0, 0, VEHICLE_CLASSES_NAMES[ tostring( data.vehicle_id ):GetTier( 1 ) ], overlay_bg, _, _, _, _, _, ibFonts.regular_18 )
        --Привод
        ibCreateLabel( 925, 36, 0, 0, DRIVE_TYPE_NAMES[ variant_config.handling.driveType ], overlay_bg, _, _, _, _, _, ibFonts.regular_14 )
    end

    local vPower = variant_config.power
    local vMaxSpeed = variant_config.max_speed
    local vAccelerationTo100 = variant_config.ftc
    local vFuelLoss = variant_config.fuel_loss
    local acceleration = variant_config.stats_acceleration

    local progressbar_width = 348
    local function getProgressWidth( value, maximum )
        return math.min( progressbar_width, ( value / maximum ) * progressbar_width )
    end

    -- Мощность
    ibCreateLabel( 646, 92, progressbar_width, 0, vPower .. " л.с.", overlay_bg, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
    ibCreateImage( 646, 111, 0, 14, _, overlay_bg, 0xFFFF965D ):ibResizeTo( getProgressWidth( vPower, 800 ), _, 800, "InOutQuad" )

    -- Разгон от 0 до 100
    ibCreateLabel( 646, 149, progressbar_width, 0, vAccelerationTo100 .. " сек.", overlay_bg, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
    ibCreateImage( 646, 169, 0, 14, _, overlay_bg, 0xFFFF965D ):ibResizeTo( getProgressWidth( vAccelerationTo100, 30 ), _, 800, "InOutQuad" )

    -- Расход
    ibCreateLabel( 646, 208, progressbar_width, 0, vFuelLoss .. " л.", overlay_bg, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
    ibCreateImage( 646, 227, 0, 14, _, overlay_bg, 0xFFFF965D ):ibResizeTo( getProgressWidth( vFuelLoss, 30 ), _, 800, "InOutQuad" )

    -- Максимальная скорость
    ibCreateLabel( 646, 265, progressbar_width, 0, vMaxSpeed .. " км/ч", overlay_bg, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
    ibCreateImage( 646, 285, 0, 14, _, overlay_bg, 0xFFFF965D ):ibResizeTo( getProgressWidth( vMaxSpeed, 400 ), _, 800, "InOutQuad" )

    -- Ускорение
    ibCreateLabel( 646, 325, progressbar_width, 0, acceleration, overlay_bg, 0xFFFFFFFF, _, _, "right", _, ibFonts.regular_12 )
    ibCreateImage( 646, 345, 0, 14, _, overlay_bg, 0xFFFF965D ):ibResizeTo( getProgressWidth( acceleration, 400 ), _, 800, "InOutQuad" )

    -- Выбор цвета
    local no_colored = { [ 520 ] = true, [ 563 ] = true, [ 425 ] = true, }
    local COLORS = { "#ffffff", "#808080", "#0d0c0c", "#ff3232", "#ffaf32", "#3289ff" }
    local COLOR = COLORS[ 1 ]
    if no_colored[ data.vehicle_id ] then
        ibCreateLabel( 646, 405, 348, 0, "Недоступно для данной модели", overlay_bg, 0xFFFFFFFF, nil, nil, "right", nil, ibFonts.regular_12 )
    else
        local btn_sx = 26
        local gap = 25
        UIe.color_btns = { }
        for i, color in pairs( COLORS ) do
            local px = 713 + ( btn_sx + gap ) * ( i - 1 )
            local py = 400
            local color_img = ibCreateImage( px, py, 26, 26, _, overlay_bg, tonumber( "0xFF" .. color:sub( 2 ) ) )
            local btn_img = ibCreateImage( -14, -14, 54, 54, ":nrp_business_carsell/img/btn_color.png", color_img )
            UIe.color_btns[ color ] = btn_img
            ibCreateArea( px, py, 26, 26, overlay_bg )
                    :ibOnHover( function( )
                if color == COLOR then return end
                btn_img:ibData( "texture", ":nrp_business_carsell/img/btn_color_selected.png" )
                btn_img:ibData( "alpha", 150 )
            end )
                    :ibOnLeave( function( )
                if color == COLOR then return end
                btn_img:ibData( "texture", ":nrp_business_carsell/img/btn_color.png" )
                btn_img:ibData( "alpha", 255 )
            end )
                    :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                if color == COLOR then return end
                ibClick( )

                COLOR = color
                UIe.color_selected_btn:ibData( "texture", ":nrp_business_carsell/img/btn_color.png" )
                UIe.color_selected_btn = UIe.color_btns[ COLOR ]:ibData( "texture", ":nrp_business_carsell/img/btn_color_selected.png" ):ibAlphaTo( 255, 100 )
            end )

            if color == COLOR then
                UIe.color_selected_btn = UIe.color_btns[ COLOR ]:ibData( "texture", ":nrp_business_carsell/img/btn_color_selected.png" ):ibAlphaTo( 255, 100 )
            end
        end
    end

    --Цена
    ibCreateLabel( 696, 492, 0, 0, format_price( data.cost ), overlay_bg, 0xFFFFFFFF, _, _, _, _, ibFonts.bold_27)
    if data.cost_original then
        --Цена без скидки
        local previous_price = ibCreateLabel( 753, 476, 0, 0, format_price( data.cost_original ), overlay_bg, ibApplyAlpha( 0xFFFFFFFF, 70 ), _, _, _, _, ibFonts.bold_16 )
        ibCreateLine( 731, 487, previous_price:ibGetAfterX( 2 ), 487, 0xFFFFFFFF, 1, overlay_bg )
    end

    --Кнопка "Купить"
    ibCreateButton( 855, 478, 0, 0, overlay_bg, "images/btn_buy.png", "images/btn_buy_h.png", "images/btn_buy_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibSetRealSize()
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            ibConfirm(
                {
                    title = "ПОДТВЕРЖДЕНИЕ",
                    text = "Ты действительно хочешь приобрести\n " .. name .. " за",
                    cost = data.cost,
                    cost_is_soft = true,
                    fn = function( self )
                        local color = { hex2rgb( COLOR ) }
                        triggerServerEvent( "onPlayerTryPurchaseDiscountedVehicle", resourceRoot, nil, data.item_index, color )
                        self:destroy( )
                    end,
                    escape_close = true,
                }
            )
        end )

    --Кнопка "Скрыть"
    ibCreateButton( 458, 568, 108, 42, overlay_bg, "images/btn_hide.png", "images/btn_hide_h.png", "images/btn_hide_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            overlay_bg:ibMoveTo( _, overlay_bg:ibGetAfterY( ), 150 )

            overlay_rt:ibTimer( destroyElement, 150, 1 )
        end )
end