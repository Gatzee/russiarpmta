local RecreatePremium
local DISCOUNTS

TABS_CONF.premium = {
    fn_create = function( self, parent )
        function RecreatePremium( )
            if not isElement( parent ) then return end
            -- Очищаем текущее окно
            DestroyTableElements( getElementChildren( parent ) )
            
            if localPlayer:IsPremiumActive() then
                local auto_prolong_enabled = CONF.premium_renewal

                ibCreateImage( 30, 62, 32, 30, "img/premium/icon_crown_small.png", parent )
                local lbl_timeleft = ibCreateLabel( 70, 70, 0, 0, "Премиум активрован", parent, ibApplyAlpha( COLOR_WHITE, 60 ) ):ibData( "font", ibFonts.regular_16 )
                local function RefreshPremiumTime( )
                    lbl_timeleft:ibData( "text", "Премиум активирован (Осталось " .. ( getHumanTimeString( localPlayer:getData( "premium_time_left" ) ) or 0 ) .. ")" )
                end
                RefreshPremiumTime( )
                lbl_timeleft:ibTimer( RefreshPremiumTime, 1000, 0 )

                local auto_prolong_bg = ibCreateImage( 500, 72, 138, 23, "img/premium/auto_prolong.png", parent )
                :ibData( "alpha", auto_prolong_enabled and 255*0.9 or 255*0.2 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( auto_prolong_enabled and 255*0.9 or 255*0.2, 200 ) end )

                local auto_prolong_check = ibCreateImage( 5, 6, 12, 10, "img/premium/auto_prolong_check.png", auto_prolong_bg )
                :ibData( "alpha", auto_prolong_enabled and 255 or 0 )
                :ibData( "disabled", true )

                auto_prolong_bg:ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    
                    auto_prolong_enabled = not auto_prolong_enabled
                    auto_prolong_check:ibAlphaTo( auto_prolong_enabled and 255 or 0, 200 )

                    triggerServerEvent( "OnPlayerChangeAutoProlong", resourceRoot, auto_prolong_enabled )
                end )

                ibCreateImage( 655, 67, 115, 34, "img/premium/btn_extend.png", parent )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_premium_purchase_button_click" )
                        --CreatePurchaseWindow( )
                        onOverlayNotificationRequest_handler( OVERLAY_PROLONG_PREMIUM )
                    end )
                ibCreateLabel( 30, 125, 0, 0, "Настройка:", parent ):ibData( "font", ibFonts.regular_14 )

                ibCreateButton( 30, 108, 166, 13, parent, 
                    "img/premium/btn_details.png", "img/premium/btn_details.png", "img/premium/btn_details.png", 0xFFEEEEEE, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    onOverlayNotificationRequest_handler( OVERLAY_PREMIUM_FEATURES )
                end )

                local buttons = {
                    {
                        icon = "nickname",
                        fn_create = function( )
                            local area = ibCreateArea( 30, 262, 0, 0, parent )

                            ibCreateLabel( 0, 0, 0, 0, "Сменить цвет ника", area ):ibData( "font", ibFonts.bold_18 )
                            ibCreateLabel( 0, 40, 0, 0, "Выбор цвета:", area, ibApplyAlpha( COLOR_WHITE, 60 ) ):ibData( "font", ibFonts.regular_14 )

                            local selected_color = tonumber( localPlayer:getData( "nickname_color" ) ) or 1
                            local color_images = { }
                            local function SelectColor( num )
                                color_images[ selected_color ]:ibAlphaTo( 0, 100 )
                                color_images[ num ]:ibAlphaTo( 255, 100 )

                                selected_color = num
                            end

                            local npx = 0
                            for i, v in pairs( PLAYER_NAMETAG_COLORS ) do
                                color_images[ i ] = ibCreateImage( npx - 2, 64, 37, 37, "img/subscription/icon_circle.png", area, i == 1 and 0xFF222222 or COLOR_WHITE ):ibData( "alpha", 0 )
                                ibCreateImage( npx, 66, 33, 33, "img/subscription/icon_circle.png", area, 0xff000000 + v )
                                    :ibOnHover( function( ) color_images[ i ]:ibAlphaTo( 255, 200 ) end )
                                    :ibOnLeave( function( ) if selected_color ~= i then color_images[ i ]:ibAlphaTo( 0, 200 ) end end )
                                    :ibOnClick( function( key, state )
                                        if key ~= "left" or state ~= "up" then return end
                                        ibClick( )
                                        SelectColor( i )
                                    end )

                                npx = npx + 33 + 7
                            end

                            SelectColor( selected_color )

                            local btn, lbl
                            local function RefreshNickname( )
                                DestroyTableElements( { btn, lbl } )
                                local nickname_color_timeout = false --localPlayer:getData( "nickname_color_timeout" )
                                
                                if nickname_color_timeout and nickname_color_timeout - getRealTimestamp( ) > 0 then
                                    local time = getHumanTimeString( nickname_color_timeout )
                                    lbl = ibCreateLabel( 200, 200, 0, 0, "Смена цвета никнейма будет доступна через " .. time, area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", _, ibFonts.regular_12 )
                                
                                else
                                    btn = ibCreateImage( 290, 174, 159, 42, "img/subscription/btn_recolor.png", area )
                                        :ibData( "alpha", 200 )
                                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                                        :ibOnClick( function( key, state )
                                            if key ~= "left" or state ~= "up" then return end
                                            ibClick( )
                                            triggerServerEvent( "onSubscriptionChangeNicknameColorRequest", resourceRoot, selected_color )
                                        end )
                                end
                            end
                            RefreshNickname( )

                            local function RefreshOnDataChange( key, old )
                                if key == "nickname_color_timeout" then
                                    RefreshNickname( )
                                end
                            end
                            addEventHandler( "onClientElementDataChange", localPlayer, RefreshOnDataChange )
                            area:ibOnDestroy( function( )
                                removeEventHandler( "onClientElementDataChange", localPlayer, RefreshOnDataChange )
                            end )

                            return area
                        end,
                    },
                    {
                        icon = "tuning",
                        fn_create = function( )
                            local area = ibCreateArea( 30, 262, 0, 0, parent )
                            ibCreateImage( 0, 0, 0, 0, "img/subscription/desc_tuning.png", area ):ibSetRealSize( )

                            local btn, lbl
                            local function RefreshSelectedVehicle( )
                                DestroyTableElements( { btn, lbl } )
                                local vehicle_access_sub_time = false --localPlayer:getData( "vehicle_access_sub_time" )

                                if #localPlayer:GetVehicles( ) <= 0 then
                                    lbl = ibCreateLabel( 180, 200, 0, 0, "Тебе не доступен тюнинг так как нет в наличии автомобиля", area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", _, ibFonts.regular_12 )
                                
                                elseif vehicle_access_sub_time and vehicle_access_sub_time - getRealTimestamp( ) > 0 then
                                    local time = getHumanTimeString( vehicle_access_sub_time )
                                    lbl = ibCreateLabel( 200, 200, 0, 0, "Выбор машины будет доступен через " .. time, area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", _, ibFonts.regular_12 )
                                
                                else
                                    btn = ibCreateImage( 290, 174, 159, 42, "img/subscription/btn_select_vehicle.png", area )
                                        :ibData( "alpha", 200 )
                                        :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                                        :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                                        :ibOnClick( function( key, state )
                                            if key ~= "left" or state ~= "up" then return end
                                            ibClick( )
                                            --iprint( "SELECT VEHICLE" )
                                            triggerServerEvent( "onSubscriptionShowUnlockVehicle", resourceRoot )
                                        end )
                                end
                            end
                            RefreshSelectedVehicle( )

                            local function RefreshOnDataChange( key, old )
                                if key == "vehicle_access_sub_time" then
                                    RefreshSelectedVehicle( )
                                end
                            end
                            addEventHandler( "onClientElementDataChange", localPlayer, RefreshOnDataChange )
                            area:ibOnDestroy( function( )
                                removeEventHandler( "onClientElementDataChange", localPlayer, RefreshOnDataChange )
                            end )
                                
                            return area
                        end,
                    },
                    {
                        icon = "vehicles",
                        fn_create = function( )
                            return ibCreateImage( 30, 262, 0, 0, "img/subscription/desc_vehicles.png", parent ):ibSetRealSize( )
                        end,
                    },
                    {
                        icon = "skins",
                        fn_create = function( )
                            return ibCreateImage( 30, 262, 0, 0, "img/subscription/desc_skins.png", parent ):ibSetRealSize( )
                        end,
                    },
                    {
                        icon = "accessories",
                        fn_create = function( )
                            return ibCreateImage( 30, 262, 0, 0, "img/subscription/desc_accessories.png", parent ):ibSetRealSize( )
                        end
                    }
                }

                local items_bgs = { }
                local current_item, current_item_bg
                local function SelectItem( num )
                    if current_item == num then return end

                    if num and items_bgs[ current_item ] then
                        items_bgs[ current_item ]:ibAlphaTo( ibGetAlpha( 10 ), 200 )
                    end

                    if isElement( current_item_bg ) then
                        current_item_bg:ibAlphaTo( 0, 200 ):ibTimer( function( self ) self:destroy( ) end, 200, 1 )
                    end

                    current_item_bg = buttons[ num ] and buttons[ num ].fn_create( )

                    if isElement( current_item_bg ) then
                        items_bgs[ num ]:ibAlphaTo( ibGetAlpha( 20 ), 200 )
                        current_item_bg:ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )
                        current_item = num
                    else
                        current_item_bg, current_item = nil, nil
                    end
                end

                local npx = 30
                for i, v in pairs( buttons ) do
                    local area = ibCreateArea( npx, 155, 89, 89, parent )
                    local bg = ibCreateImage( 0, 0, 89, 89, _, area, 0xff000000 ):ibData( "alpha", ibGetAlpha( 10 ) )
                        :ibOnHover( function( ) source:ibAlphaTo( ibGetAlpha( 20 ), 200 ) end )
                        :ibOnLeave( function( ) if current_item ~= i then source:ibAlphaTo( ibGetAlpha( 10 ), 200 ) end end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            --iprint( "Select menu", i, v.icon )
                            SelectItem( i )
                        end )

                    ibCreateImage( 0, 0, 0, 0, "img/subscription/icon_" .. v.icon .. ".png", area ):ibData( "disabled", true ):ibSetRealSize( ):center( )
                    npx = npx + area:width( ) + 5

                    items_bgs[ i ] = bg
                end

                SelectItem( 1 )
            else
                local selected_item = 1
                local buttons_shown = false

                local parent, scrollbar = ibCreateScrollpane( 0, 64, parent:width( ), parent:height( ) - 64, parent, { scroll_px = -20 } )
                scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )

                local parent_area = ibCreateArea( 0, 0, parent:width( ), parent:height( ), parent )

                -- Description
                local desc_bg = ibCreateImage( 30, 10, 738, 221, "img/premium/premium_bg.png", parent )

                local desc, desc_scrollbar = ibCreateScrollpane( 190, 0, 540, 221, desc_bg, { scroll_px = -10 } )
                desc_scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )

                local pDescriptionLines = 
                {
                    { 
                        title = { s_type = "img", sx = 18, sy = 18, path = "img/premium/icon_calendar.png" }, 
                        s_body = "Специальные ежедневные награды",
                    },

                    { 
                        title = { s_type = "img", sx = 18, sy = 18, path = "img/premium/icon_crown_tiny.png" }, 
                        s_body = "Уникальное украшение для твоего ника",
                    },

                    { 
                        title = { s_type = "string", text = "X2", color = 0xFF23f965, font = "bold_18" }, 
                        s_body = "Опыт на всех работах",
                    },

                    { 
                        title = { s_type = "string", text = "X2", color = 0xFF23f965, font = "bold_18" }, 
                        s_body = "Внутреннего опыта во фракциях и бандах",
                    },

                    { 
                        title = { s_type = "string", text = "X1.5", color = 0xFF23f965, font = "bold_18" }, 
                        s_body = "Зарплаты во фракциях",
                    },

                    { 
                        title = { s_type = "string", text = "X2", color = 0xFF23f965, font = "bold_18" }, 
                        s_body = "Опыт за выполнение квестов",
                    },

                    { 
                        title = { s_type = "string", text = "X2", color = 0xFF23f965, font = "bold_18" }, 
                        s_body = "Денег за выполнение квестов",
                    },

                    { 
                        title = { s_type = "string", text = "+20%", color = 0xFFffd236, font = "bold_18" }, 
                        s_body = "К зарплате на всех работах",
                    },

                    { 
                        title = { s_type = "string", text = "15%", color = 0xFFff5252, font = "bold_18" }, 
                        s_body = "Скидка на весь товар у барыги и в оружейном магазине",
                    },

                    { 
                        title = { s_type = "string", text = "50%", color = 0xFFff5252, font = "bold_18" }, 
                        s_body = "Снижение стоимости содержания недвижимости",
                    },

                    {
                        title = { s_type = "img", sx = 12, sy = 12, path = "img/premium/icon_circle.png" }, 
                        s_body = "Выдача дополнительного одного жетона Колеса фортуны",
                    },

                    { 
                        title = { s_type = "string", text = "+1", color = 0xFFffd236, font = "bold_18" }, 
                        s_body = "Час к смене на работе",
                    },

                    { 
                        title = { s_type = "img", sx = 12, sy = 12, path = "img/premium/icon_circle.png" }, 
                        s_body = "Уникальные аксессуары для персонажа",
                    },

                    { 
                        title = { s_type = "img", sx = 12, sy = 12, path = "img/premium/icon_circle.png" }, 
                        s_body = "Выбор цвета ника",
                    },

                    { 
                        title = { s_type = "img", sx = 12, sy = 12, path = "img/premium/icon_circle.png" }, 
                        s_body = "Черный рынок для машин",
                    },

                    { 
                        title = { s_type = "img", sx = 12, sy = 12, path = "img/premium/icon_circle.png" }, 
                        s_body = "Доступ к особым машинам",
                    },

                    { 
                        title = { s_type = "img", sx = 12, sy = 12, path = "img/premium/icon_circle.png" }, 
                        s_body = "Доступ к особым скинам",
                    },
                }

                ibCreateLabel( 20, 10, 0, 0, "Полный список того, что даёт новый премиум:", desc, 0xFFFFFFFF ):ibData("font", ibFonts.regular_16)

                local py = 40
                for k,v in pairs(pDescriptionLines) do
                    if v.title.s_type == "string" then
                        local label_title = ibCreateLabel( 20, py, 0, 30, v.title.text, desc, v.title.color, _, _, "left", "center" ):ibData("font", ibFonts[ v.title.font ])
                        ibCreateLabel( 20 + label_title:width(), py, 0, 30, " - "..v.s_body, desc, 0x90FFFFFF, _, _, "left", "center" ):ibData("font", ibFonts.regular_14)
                    elseif v.title.s_type == "img" then
                        ibCreateImage( 20, py+15-v.title.sy/2, v.title.sx, v.title.sy, v.title.path, desc )
                        ibCreateLabel( 22 + v.title.sx, py, 0, 30, " - "..v.s_body, desc, 0x90FFFFFF, _, _, "left", "center" ):ibData("font", ibFonts.regular_14)
                    end

                    py = py + 30
                end

                desc:AdaptHeightToContents( )
                desc_scrollbar:UpdateScrollbarVisibility( desc )

                -- Variant selector
                local pPremiumVariants = 
                {
                    {
                        title = "3 дня",
                        days = 3,
                        cost = 199, --299,
                        old_cost = 299,
                    },
                    {
                        title = "7 дней",
                        days = 7,
                        cost = 399, --599,
                        old_cost = 599,
                    },
                    {
                        title = "14 дней",
                        days = 14,
                        cost = 499, --799,
                        old_cost = 799,
                    },
                    {
                        title = "1 месяц",
                        days = 30,
                        cost = 799, --999,
                        old_cost = 999,
                    },
                    --[[{
                        title = "3 месяца",
                        days = 90,
                        cost = 1999,
                    },]]
                }

                local finish_time = GetPremiumDiscountFinishTime( )
                local variants_area, variants_scrollbar = ibCreateScrollpane( 105, 260, 593, 104, parent )
                variants_area:ibTimer( function ( )
                    if finish_time and getRealTimestamp( ) >= finish_time then
                        DISCOUNTS = nil
                        RecreatePremium( )
                    end
                end, 1000, 0 )

                local buttons = { }
                local icon_hovered = false

                local px = 0
                for k, v in pairs( pPremiumVariants ) do
                    buttons[k] = ibCreateButton( px, 0, 140, 100, variants_area, nil, nil, nil, 0x80333d4c, 0xB0333d4c, 0xB0333d4c )
                    
                    local discount = GetPremiumDiscountsForDays( v.days )
                    if discount and getRealTimestamp( ) < ( finish_time or 0 ) then
                        ibCreateLabel( 0, 25, 140, 0, v.title, buttons[k], 0xA0FFFFFF, _, _, "center", "center" ):ibData("font", ibFonts.bold_18):ibData("disabled", true)

                        local label_cost = ibCreateLabel( 30, 40, 0, 30, "за "..discount, buttons[k], 0xFFFFFFFF, _, _, "left", "center" ):ibData("font", ibFonts.bold_21):ibData("disabled", true)
                        local label_cost_old = ibCreateLabel( 20, 65, 0, 30, "вместо "..v.old_cost, buttons[k], 0x80FFFFFF, _, _, "left", "center" ):ibData("font", ibFonts.regular_16):ibData("disabled", true)
                        
                        ibCreateImage( 35+label_cost:width(), 40+15-8, 18, 16, "img/premium/icon_hard.png", buttons[k] ):ibData("disabled", true)
                        ibCreateImage( 25+label_cost_old:width(), 65+15-8, 18, 16, "img/premium/icon_hard.png", buttons[k], 0x80FFFFFF ):ibData("disabled", true)
                        
                        ibCreateImage( 25+label_cost_old:width()-30, 65+15, 52, 1, nil, buttons[k], 0x80FFFFFF )
                    else
                        ibCreateLabel( 0, 30, 140, 0, v.title, buttons[k], 0xA0FFFFFF, _, _, "center", "center" ):ibData("font", ibFonts.bold_18):ibData("disabled", true)

                        local label_cost = ibCreateLabel( 30, 50, 0, 30, "за "..v.old_cost, buttons[k], 0xFFFFFFFF, _, _, "left", "center" ):ibData("font", ibFonts.bold_21):ibData("disabled", true)
                        ibCreateImage( 35+label_cost:width(), 50+15-8, 18, 16, "img/premium/icon_hard.png", buttons[k] ):ibData("disabled", true)
                    end

                    buttons[k]:ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )

						SendElasticGameEvent( "f4r_f4_premium_choose_icon_click" )
                        if not buttons_shown then
                            ShowPremiumButtons()
                        end

                        if isElement(icon_hovered) then destroyElement( icon_hovered ) end

                        selected_item = k
                        icon_hovered = ibCreateImage( 0, 0, 140, 100, "img/premium/premium_selector.png", source )
                        :ibData("alpha", 0)
                        :ibAlphaTo(255, 500)
                        :ibData("priority", -1)
                    end )

                    px = px + 150
                end

                variants_area:AdaptHeightToContents( )
                variants_scrollbar:UpdateScrollbarVisibility( variants_area )

                local last_move = 0
                local current_bias, bias_max = 0, #pPremiumVariants - 4

                ibCreateButton( 30, 300, 18, 30, parent, 
                    "img/premium/arrow_big.png", "img/premium/arrow_big.png", "img/premium/arrow_big.png", 0xFFAAAAAA, 0xFFFFFFFF, 0xFFFFFFFF ):ibData("rotation", 180)
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    if getTickCount() - last_move <= 600 then return end
                    if current_bias <= 0 then return end
                    ibClick( )

                    for k,v in pairs(buttons) do
                        v:ibMoveTo( v:ibData("px")+150, v:ibData("py"), 500 )
                        current_bias = current_bias - 1
                    end

                    last_move = getTickCount()
                end )

                ibCreateButton( 750, 300, 18, 30, parent, 
                    "img/premium/arrow_big.png", "img/premium/arrow_big.png", "img/premium/arrow_big.png", 0xFFAAAAAA, 0xFFFFFFFF, 0xFFFFFFFF )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    if getTickCount() - last_move <= 600 then return end
                    if current_bias >= bias_max then return end
                    ibClick( )

                    for k,v in pairs(buttons) do
                        v:ibMoveTo( v:ibData("px")-150, v:ibData("py"), 500 )
                        current_bias = current_bias + 1
                    end

                    last_move = getTickCount()
                end )


                -- Action buttons
                function ShowPremiumButtons()
                    ibCreateButton( 300, 380, 122, 46, parent, 
                        "img/premium/btn_buy.png", "img/premium/btn_buy.png", "img/premium/btn_buy.png", 0xFFEEEEEE, 0xFFFFFFFF, 0xFFFFFFFF )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_premium_purchase_button_click" )
                        if localPlayer:GetDonate( ) < pPremiumVariants[ selected_item ].cost then
                            ShowPaymentForPremium( pPremiumVariants[ selected_item ].days )
                        else
                            triggerServerEvent( "onPremiumPurchaseRequest", resourceRoot, pPremiumVariants[ selected_item ].days )
                        end
                    end )


                    btn_gift = ibCreateButton( 435, 381, 44, 44, parent, 
                        "img/premium/btn_gift.png", "img/premium/btn_gift.png", "img/premium/btn_gift.png", 0xFFEEEEEE, 0xFFFFFFFF, 0xFFFFFFFF )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
						SendElasticGameEvent( "f4r_f4_premium_present_icon_click" )
                        if input then input:destroy() end
                        input = ibInput(
                            {
                                title = "ПРЕМИУМ В ПОДАРОК", 
                                text = "",
                                edit_text = "Введи имя игрока, кому хочешь подарить премиум на " .. pPremiumVariants[ selected_item ].days .. " д.",
                                btn_text = "ПОДАРИТЬ",
                                fn = function( self, text )
									SendElasticGameEvent( "f4r_f4_premium_present_button_click" )
                                    triggerServerEvent( "onPremiumGiftRequest", resourceRoot, pPremiumVariants[ selected_item ].days, text )
                                    self:destroy()
                                end
                            }
                        )
                    end )

                    buttons_shown = true
                end

                local function WatchPremiumUpdates( key )
                    if key == "premium_time_left" then
                        RecreatePremium( )
                    end
                end
                addEventHandler( "onClientElementDataChange", localPlayer, WatchPremiumUpdates )
                parent_area:ibOnDestroy( function( ) removeEventHandler( "onClientElementDataChange", localPlayer, WatchPremiumUpdates ) end )
            
                parent:AdaptHeightToContents( )
                scrollbar:UpdateScrollbarVisibility( parent )
            end
        end
        RecreatePremium( )
    end,

    fn_open = function( )
        --[[if IsPremiumDiscountActive() then
            triggerServerEvent("OnPremiumWindowShown", resourceRoot)
        end]]
    end,
}


addEvent( "onPremiumDescriptionRequest", true )
addEventHandler( "onPremiumDescriptionRequest", root, function() onOverlayNotificationRequest_handler( OVERLAY_PREMIUM_FEATURES ) end )
----------------------------
-- START: СКИДКИ НА ПРЕМИУМ

function GetPremiumDiscountsForDays( premium_num )
	return DISCOUNTS and DISCOUNTS.array and DISCOUNTS.array[ premium_num ]
end

function HasPremiumDiscounts( )
    local finish_time = GetPremiumDiscountFinishTime( )
	return finish_time and finish_time >= getRealTimestamp( ) and DISCOUNTS and next( DISCOUNTS ) ~= nil and DISCOUNTS
end

function GetPremiumDiscountFinishTime( )
	return DISCOUNTS and DISCOUNTS.finish_time and DISCOUNTS.finish_time
end

function DoesPremiumIncludeGift( )
    return HasPremiumDiscounts( ) and DISCOUNTS.include_gift
end

function DoesPremiumIncludeProlonging( )
    return HasPremiumDiscounts( ) and DISCOUNTS.include_prolonging
end

function onPremiumDiscountsSync_handler( discounts, finish_time )
	DISCOUNTS = discounts or { }
    DISCOUNTS.finish_time = finish_time

    if RecreatePremium then RecreatePremium( ) end
end
addEvent( "onPremiumDiscountsSync", true )
addEventHandler( "onPremiumDiscountsSync", root, onPremiumDiscountsSync_handler )