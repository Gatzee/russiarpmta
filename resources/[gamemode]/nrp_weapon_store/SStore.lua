Extend("SPlayer")

local PROCESS_BY_CLASS =
{
    [WEAPON] = function( pPlayer, pItem, count )
        pPlayer:InventoryAddItem( pItem.inv_type, { pItem.item_id, pItem.ammo }, count or 1 )
        triggerEvent( "onPlayerWeaponPurchase", pPlayer, pItem.item_id, count )
    end,

    [ARMOR] = function( pPlayer, pItem, count, is_pack )
        count = count or 1
        if pPlayer.armor < 100 and not is_pack then
            local corrective = count % 2 == 1 and 0.875 or 0
            local new_armor = math.min( pPlayer.armor + pItem.ammo * count + corrective, 100 )
            pPlayer:setArmor( new_armor )
            pPlayer:ShowInfo( "Вы надели бронежилет" )
        end

        if is_pack then
            pPlayer:InventoryAddItem( pItem.inv_type, { pItem.item_id, pItem.ammo }, count or 1 )
        end
        triggerEvent( "onPlayerArmorPurchase", pPlayer, pItem.ammo * count )
    end,

    [LICENSE] = function( pPlayer, pItem, count )
        count = count or 1
        local time_left = getRealTime( ).timestamp

        local licenses = pPlayer:GetPermanentData( "gun_licenses" ) or {}

        if licenses.expires and IsPlayerGunLicenseActive( licenses.expires ) then
            -- при наличии у игрока действующей лицензии, прибавляем остаток времени
            local diff_time = licenses.expires - time_left
            time_left = diff_time > 0 and ( time_left + diff_time ) or time_left
        end

        licenses.expires = time_left + count * 30 * 24 * 60 * 60
        pPlayer:SetPermanentData( "gun_licenses", licenses )
        pPlayer:SetPrivateData( "gun_licenses", licenses.expires )

        pPlayer:InventoryRemoveItem( pItem.inv_type )
        pPlayer:InventoryAddItem( pItem.inv_type, nil, 1 )
    end
}

function onPlayerTryBuyWeaponStoreItems_handler( pCart )
    if type( pCart ) ~= "table" or not next( pCart ) then return end

    local licenses = client:GetPermanentData( "gun_licenses" )

    local has_player_active_gun_license = licenses and IsPlayerGunLicenseActive( licenses.expires ) or false
    local can_player_buy_gun_license, message = CanPlayerBuyGunLicense( client )

    if client:GetSocialRating( ) <= 0 then
        can_player_buy_gun_license = false
        message = "Социальный рейтинг должен быть положительным"
    end

    local offer_gun_license = getRealTimestamp( ) < ( client:getData( "offer_gun_license_time_left" ) or 0 )
    local weapon_shop_purchase = client:GetPermanentData( "weapon_shop_purchase" ) or 0
    local weapon_shop_purchase_cost = 0

    local weapon_shop_purchase = client:GetPermanentData( "weapon_shop_purchase" ) or 0
    local weapon_shop_purchase_cost = 0

    -- проверяем валидность суммарной стоимости и доступности предметов игроку
    local total_cost = 0
    local premium_cost_mul = client:IsPremiumActive( ) and 0.85 or 1

    local timestamp = getRealTimestamp( )
    local is_weapon_shop_offer = timestamp > OFFER_CONFIG.start_date and timestamp < OFFER_CONFIG.finish_date
    local segment

    for index, cart_item in pairs( pCart ) do
        segment = cart_item.is_pack and client:getData( "weapon_shop_segment" )
        local item = cart_item.is_pack and SEGMENTS[ segment ].packs[ index ] or GOODS[ index ]
        local discount = 1

        if offer_gun_license and item.class == LICENSE then
            discount = 0.5

            total_cost = total_cost + math.ceil( item.cost * 0.5 )
            if cart_item.count > 1 then
                total_cost = total_cost + item.cost * ( cart_item.count - 1 )
            end
        elseif cart_item.is_pack then
            discount = item.discount
            total_cost = total_cost + math.ceil( item.cost * discount ) * cart_item.count
        else
            local cost = item.cost * cart_item.count
            total_cost = total_cost + cost
        end

        total_cost = total_cost * premium_cost_mul

        if item.class == WEAPON or item.class == ARMOR then
            local cost = item.cost * cart_item.count
            weapon_shop_purchase_cost = weapon_shop_purchase_cost + cost
        end

        if item.class == WEAPON and not has_player_active_gun_license then
            client:ShowError( "Необходима действующая лицензия для покупки огнестрельного оружия" )
            return
        elseif item.class == LICENSE and not can_player_buy_gun_license then
            client:ShowError( message )
            return
        elseif IsGunOfferActive( client ) and item.class == LICENSE and cart_item.count > 1 then
            client:ShowError( "По скидке доступна только 1 лицензия" )
            return
        elseif cart_item.is_pack and not has_player_active_gun_license then
            client:ShowError( "Необходима действующая лицензия для покупки огнестрельного оружия" )
            return
        end
    end

    if client:GetMoney( ) < total_cost then
        client:ShowError( "Недостаточно денег для покупки всех товаров" )
        return
    end

    -- списываем деньги со счета игрока, готовим данные для аналитики
    local cart_items_data = {}
    local cart_items_total = 0
    local update_licence = false

    for index, cart_item in pairs( pCart ) do
        segment = cart_item.is_pack and client:getData( "weapon_shop_segment" )
        local item = cart_item.is_pack and SEGMENTS[ segment ].packs[ index ] or GOODS[ index ]
        local discount = 1

        if type( cart_item.count ) == "number" and cart_item.count > 0 then
            if cart_item.is_pack then
                local total_pack_cost = item.cost * cart_item.count

                for k, pack_item in ipairs( item.items ) do
                    local goods_item = GOODS[ pack_item.id ]
                    local cost = math.ceil( goods_item.cost * item.discount * premium_cost_mul )
                    local cost_total = cost * pack_item.count * cart_item.count
                    
                    --total_pack_cost = total_pack_cost + cost_total

                    PROCESS_BY_CLASS[ goods_item.class ]( client, goods_item, pack_item.count * cart_item.count, true )

                    cart_items_total = cart_items_total + pack_item.count * cart_item.count
                    local item_data = {
                        item_name = goods_item.name,
                        item_id = goods_item.item_id,
                        item_count = pack_item.count,
                        item_cost_per_item = cost,
                        item_cost_total = cost_total,
                        currency = goods_item.currency,
                        item_type = "pack",
                    }
                    table.insert( cart_items_data, item_data )
                end

                client:TakeMoney( total_pack_cost, "gun_shop", item.item_id )
            else
                PROCESS_BY_CLASS[ item.class ]( client, item, cart_item.count )
                local cost

                if offer_gun_license and item.class == LICENSE then
                    cost = math.ceil( item.cost * 0.5 )
                    
                    if cart_item.count > 1 then
                        cost = cost + item.cost * ( cart_item.count - 1 )
                    end

                    cost = cost * premium_cost_mul

                    client:TakeMoney( cost, "gun_shop_purchase", item.name )
                else
                    client:TakeMoney( item.cost * cart_item.count * premium_cost_mul, "gun_shop_purchase", item.name )
                end

                if item.class == LICENSE and not has_player_active_gun_license then
                    update_licence = true
                end

                cart_items_total = cart_items_total + cart_item.count
                local item_data = {
                    item_name = item.name,
                    item_id = item.item_id,
                    item_count = cart_item.count,
                    item_cost_per_item = item.cost,
                    item_cost_total = item.cost * cart_item.count,
                    currency = item.currency,
                    item_type = "common",
                }
                table.insert( cart_items_data, item_data )
            end

        end
    end

    if not segment then segment = GetSegment( client, weapon_shop_purchase ) end
    weapon_shop_purchase = weapon_shop_purchase + weapon_shop_purchase_cost
    client:SetPermanentData( "weapon_shop_purchase", weapon_shop_purchase )

    local new_segment = GetSegment( client, weapon_shop_purchase )
    local client_id = client:GetClientID( )

    if new_segment > segment then
        client:SetPrivateData( "weapon_shop_segment", new_segment )
        triggerClientEvent( client, "ShowWeaponStoreUI", resourceRoot, true )
        triggerClientEvent( client, "ShowGunShopOffer", resourceRoot, true, true )

        -- analytics
        SendElasticGameEvent( client_id, "offer_pack_gun_segment_change", {
            segment_num = new_segment,
        } )

        update_licence = false
    end

    if update_licence then
        triggerClientEvent( client, "ShowWeaponStoreUI", resourceRoot, true )
    end

    client:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/buy_product.wav" )
    client:ShowSuccess( "Спасибо за покупку!" )

    triggerEvent( "onPlayerSomeDo", client, "use_weapon_store" ) -- achievements

    -- analytics
    SendElasticGameEvent( client_id, "gun_shop_purchase", {
        client_id        = client_id,
        cart_total_cost  = total_cost,
        currency         = "soft",
        cart_items_total = cart_items_total,
        cart_items       = toJSON( cart_items_data, true )
    } )

end
addEvent( "onPlayerTryBuyWeaponStoreItems", true )
addEventHandler( "onPlayerTryBuyWeaponStoreItems", resourceRoot, onPlayerTryBuyWeaponStoreItems_handler )

function IsGunOfferActive( player )
    return (player:getData( "offer_gun_license_time_left" ) or 0) > getRealTimestamp()
end

function onPlayerShowGunLicense_handler( target )
    local licenses = source:GetPermanentData( "gun_licenses" )

    local is_license_active = licenses and IsPlayerGunLicenseActive( licenses.expires ) or nil

    if not is_license_active then
        source:InventoryRemoveItem( IN_GUN_LICENSE )
        source:ShowError( "Ваша лицензия на владение оружием просрочена" )
        return
    end

    target:triggerEvent( "RequestShowGunLicenseUI", source, true, source, licenses.expires )
end
addEvent( "onPlayerShowGunLicense", true )
addEventHandler( "onPlayerShowGunLicense", root, onPlayerShowGunLicense_handler )

function onPlayerReadyToPlay_handler( player )
    local player = isElement( player ) and player or source

    local licenses = player:GetPermanentData( "gun_licenses" )

    if not licenses then return end

    local diff_time = licenses.expires - getRealTime( ).timestamp
    if diff_time <= 0 then
        player:SetPermanentData( "gun_licenses", nil )
        player:ShowError( "Ваша лицензия на владение оружием просрочена" )
        return
    elseif diff_time <= 24 * 60 * 60 then
        player:PhoneNotification( { title = "Лицензия на оружие", msg = "Срок действия вашей лицензии на оружие истекает через 1 день. Необходимо продлить для легального использования." } )
    end

    player:SetPrivateData( "gun_licenses", licenses.expires )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler, true, "low-10000" )


------------------------------------------------------------------------------------------------------------------------
-- Для теста
if SERVER_NUMBER > 100 then
    function SetLicenseAsExpired( player, command )
        local licenses = player:GetPermanentData( "gun_licenses" )
        if not licenses then
            outputConsole( "Сначало купите лицензию в магазине" )
            return
        else
            licenses.expires = getRealTime( ).timestamp - 24 * 60 * 60 - 60
            player:SetPermanentData( "gun_licenses", licenses )
            player:SetPrivateData( "gun_licenses", licenses.expires )
            outputConsole( "Время действия лицензии установлено просроченным на день / лицензии не должно быть в инвентаре" )
        end
        onPlayerReadyToPlay_handler( player )
    end
    addCommandHandler( "gun_license_expired", SetLicenseAsExpired )

    addCommandHandler( "gun_license_check_notify", function( player )
        local licenses = player:GetPermanentData( "gun_licenses" )

        if not licenses then
            outputConsole( "Сначало купите лицензию в магазине" )
            return
        else
            licenses.expires = getRealTime( ).timestamp + 24 * 60 * 60 - 60
            player:SetPermanentData( "gun_licenses", licenses )
            player:SetPrivateData( "gun_licenses", licenses.expires )
            outputConsole( "Время действия лицензии установлено на 1 день" )
        end

        onPlayerReadyToPlay_handler( player )
    end )

    addCommandHandler( "gun_shop_daily_quest", function( player )
        local is_found = false
        local daily_quest_list = player:GetPermanentData( "daily_quest_list" )
        for _, v in pairs( daily_quest_list ) do
            if v.id == "np_visit_weapon_store" then
                is_found = true
                break
            end
        end

        if is_found then
            player:AddDailyQuest("np_visit_weapon_store")
            outputConsole( "Дейлик 'Посети оружейный магазин' добавлен." )
        else
            outputConsole( "Произошла ошибка." )
        end
    end )

    addCommandHandler( "clear_inventory", function( player )
        player:InventoryRemoveItem( IN_WEAPON )
        player:InventoryRemoveItem( IN_HEAVYARMOR )
        player:InventoryRemoveItem( IN_MEDIUMARMOR )
        player:InventoryRemoveItem( IN_LIGHTARMOR )
        player:InventoryRemoveItem( IN_GUN_LICENSE )

        player:SetPermanentData( "gun_licenses", nil )
        player:SetPrivateData( "gun_licenses", nil )
        outputConsole( "Инвентарь очищен." )
    end )

    addCommandHandler( "get_weapon_shop_purchase", function( player )
        iprint( "get_weapon_shop_purchase", player:GetPermanentData( "weapon_shop_purchase" ) )
    end )
end

function SwitchPosition_handler( )
    triggerEvent( "onTaxiPrivateFailWaiting", client, "Пассажир отменил заказ", "Ты зашёл в помещение, заказ в Такси отменен" )
end
addEvent( "SwitchPosition", true )
addEventHandler( "SwitchPosition", resourceRoot, SwitchPosition_handler )