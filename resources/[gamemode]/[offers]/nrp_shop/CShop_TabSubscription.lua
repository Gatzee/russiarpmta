--[[
addEvent( "onSubscriptionBuyRequest_Success", true )

TABS_CONF.subscription = {
    fn_create = function( self, parent )
        local subscription_state = localPlayer:IsSubscriptionActive( )

        local fns = { }

        local function ResetWindow( )
            DestroyTableElements( getElementChildren( parent ) )
        end

        local function CreatePurchaseWindow( )
            ResetWindow( )

            ibCreateImage( 78, 65, 0, 0, "img/subscription/sub_30.png", parent ):ibSetRealSize( )
            ibCreateImage( 468, 65, 0, 0, "img/subscription/sub_90.png", parent ):ibSetRealSize( )

            local line = ibCreateLine( 400, 65, _, 475, ibApplyAlpha( COLOR_WHITE, 10 ), 1, parent )

            local function onSubscriptionBuyRequest_Success_handler( )
                fns.CreateDataWindow( )
            end
            addEventHandler( "onSubscriptionBuyRequest_Success", root, onSubscriptionBuyRequest_Success_handler )

            line:ibOnDestroy( function( ) removeEventHandler( "onSubscriptionBuyRequest_Success", root, onSubscriptionBuyRequest_Success_handler ) end )

            local confs = {
                {
                    purchase = { 118, 434 },
                    gift     = { 248, 434 },
                    days     = 30,
                    id       = 1,
                },
                {
                    purchase = { 508, 434 },
                    gift     = { 638, 434 },
                    days     = 90,
                    id       = 2,
                }
            }

            for i, v in pairs( confs ) do
                local bg = ibCreateImage( v.purchase[ 1 ], v.purchase[ 2 ], 120, 44, "img/premium/btn_buy.png", parent )
                ibCreateImage( 0, 0, 0, 0, "img/premium/btn_buy_hover.png", bg ):ibSetRealSize( ):center( )
                    :ibData( "alpha", 0 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 0, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        iprint( "buy", v.days )
                        triggerServerEvent( "onSubscriptionBuyRequest", resourceRoot, v.id )
                    end )

                ibCreateImage( v.gift[ 1 ], v.gift[ 2 ], 44, 44, "img/premium/btn_gift.png", parent )
                    :ibData( "alpha", 200 )
                    :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                    :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        if input then input:destroy() end
                        input = ibInput(
                            {
                                title = "ПОДПИСКА В ПОДАРОК", 
                                text = "Введи имя игрока, кому хочешь подарить подписку на " .. v.days .. " д.",
                                edit_text = "Введи имя игрока",
                                btn_text = "ПОДАРИТЬ",
                                fn = function( self, text )
                                    triggerServerEvent( "onSubscriptionBuyRequest", resourceRoot, v.id, text )
                                    self:destroy()
                                end
                            }
                        )
                    end )
            end
        end

        local function CreateDataWindow( )
            ResetWindow( )
            ibCreateImage( 30, 66, 31, 29, "img/subscription/icon_subscription.png", parent )
            local lbl_timeleft = ibCreateLabel( 70, 70, 0, 0, "У вас подписка NEXT.Plus", parent, ibApplyAlpha( COLOR_WHITE, 60 ) ):ibData( "font", ibFonts.regular_16 )
            local function RefreshSubscriptionTime( )
                lbl_timeleft:ibData( "text", "У тебя подписка NEXT.Plus (Осталось " .. getHumanTimeString( localPlayer:getData( "subscription_time_left" ) ) .. ")" )
            end
            RefreshSubscriptionTime( )
            lbl_timeleft:ibTimer( RefreshSubscriptionTime, 1000, 0 )

            ibCreateImage( 655, 67, 115, 34, "img/subscription/btn_prolong.png", parent )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    --CreatePurchaseWindow( )
                    onOverlayNotificationRequest_handler( OVERLAY_PROLONG_SUBSCRIPTION )
                end )
            ibCreateLabel( 30, 125, 0, 0, "Настройка:", parent ):ibData( "font", ibFonts.regular_14 )

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
                            local nickname_color_timeout = localPlayer:getData( "nickname_color_timeout" )
                            
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
                            local vehicle_access_sub_time = localPlayer:getData( "vehicle_access_sub_time" )

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
                                        iprint( "SELECT VEHICLE" )
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
                    icon = "daily_bonus",
                    fn_create = function( )
                        local area = ibCreateArea( 30, 262, 0, 0, parent )
                        ibCreateImage( 0, 0, 0, 0, "img/subscription/desc_daily_bonus.png", area ):ibSetRealSize( )

                        local btn, lbl
                        local function RefreshDailyBonus( )
                            DestroyTableElements( { btn, lbl } )
                            local subscription_reward_time = localPlayer:getData( "subscription_reward_time" )

                            if subscription_reward_time and subscription_reward_time - getRealTimestamp( ) > 0 then
                                local time = getHumanTimeString( subscription_reward_time )
                                lbl = ibCreateLabel( 220, 200, 0, 0, "Ты сможешь забрать бонусы через " .. time, area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", _, ibFonts.regular_12 )
                            
                            else
                                btn = ibCreateImage( 310, 174, 118, 42, "img/subscription/btn_take.png", area )
                                :ibData( "alpha", 200 )
                                :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
                                :ibOnLeave( function( ) source:ibAlphaTo( 200, 200 ) end )
                                :ibOnClick( function( key, state )
                                    if key ~= "left" or state ~= "up" then return end
                                    ibClick( )
                                    iprint( "TAKE" )
                                    triggerServerEvent( "onSubscriptionTakeRewardsRequest", resourceRoot )
                                end )
                            end
                        end
                        RefreshDailyBonus( )

                        local function RefreshOnDataChange( key, old )
                            if key == "subscription_reward_time" then
                                RefreshDailyBonus( )
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
                        iprint( "Select menu", i, v.icon )
                        SelectItem( i )
                    end )

                ibCreateImage( 0, 0, 0, 0, "img/subscription/icon_" .. v.icon .. ".png", area ):ibData( "disabled", true ):ibSetRealSize( ):center( )
                npx = npx + area:width( ) + 5

                items_bgs[ i ] = bg
            end

            SelectItem( 1 )
        end

        fns.CreateDataWindow     = CreateDataWindow
        fns.CreatePurchaseWindow = CreatePurchaseWindow

        if subscription_state then
            CreateDataWindow( )
        else
            CreatePurchaseWindow( )
        end

    end,
}
]]