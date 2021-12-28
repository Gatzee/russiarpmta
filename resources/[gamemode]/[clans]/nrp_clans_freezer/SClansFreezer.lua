Extend( "SPlayer" )
Extend( "SClans" )

local UPGRADE_ID_BY_PRODUCT_TYPE = {
    [ "alco" ] = CLAN_UPGRADE_ALCO_FACTORY,
    [ "hash" ] = CLAN_UPGRADE_HASH_FACTORY,
}

local COST_BUFF_ID_BY_PRODUCT_TYPE = {
    [ "alco" ] = CLAN_UPGRADE_ALCO_SALE_COST,
    [ "hash" ] = CLAN_UPGRADE_HASH_SALE_COST,
}

addEventHandler( "onResourceStart", resourceRoot, function( )
    setTimer( function( )
        triggerClientEvent( "CF:onClientCreateMarkers", resourceRoot )
    end, 1000, 1 )
end )

function GetClanProductBatches( clan_id )
    local today_product_batches = GetClanData( clan_id, "today_product_batches" )

    -- Сброс счётчика колва партий за день
    if not today_product_batches or ( today_product_batches.reset_ts or 0 ) <= os.time( ) then
        today_product_batches = {
            reset_ts = getCurrentDayTimestamp( ) + 24 * 60 * 60,
        }
        SetClanData( clan_id, "today_product_batches", today_product_batches )
    end

    return today_product_batches
end

function onPlayerWantShowUI( )
    local player = client
    local clan_id = player:GetClanID( )
    if not clan_id then return end


    local upgrades = GetClanData( clan_id, "upgrades" )
    triggerClientEvent( player, "CF:ShowUI", resourceRoot, true, {
        freezer = GetClanData( clan_id, "freezer" ),
        today_batches = GetClanProductBatches( clan_id ),
    } )
end
addEvent( "CF:onPlayerWantShowUI", true )
addEventHandler( "CF:onPlayerWantShowUI", resourceRoot, onPlayerWantShowUI )

function onPlayerAddItem( type, quality, count )
    local player = client
    local clan_id = player:GetClanID( )
    if not clan_id then return end

    local inv_item_id = PRODUCT_TYPE_TO_INV_ITEM_ID[ type ]
    if not inv_item_id then return end

    -- Проверка, что собрано макс колво за день
    local today_product_batches = GetClanData( clan_id, "today_product_batches" )
    if today_product_batches and ( today_product_batches[ type ] or 0 ) >= MAX_BATCHES_COUNT_IN_DAY then
        player:ShowError( "Морозильная камера заполнена" )
        return
    end

    -- Учитываем, сколько есть у игрока
    count = math.min( count, player:InventoryGetItemCount( inv_item_id, { quality } ) )
    if count <= 0 then return end

    local freezer = GetClanData( clan_id, "freezer" )
    if not freezer[ type ] then freezer[ type ] = { } end
    local product = freezer[ type ]
    
    local factory_lvl = GetClanUpgradeLevel( clan_id, UPGRADE_ID_BY_PRODUCT_TYPE[ type ] )
    local need_count_for_batch = FACTORY_UPGRADES[ factory_lvl ].need_count_for_batch

    -- Учитываем, сколько осталось до сбора партии
    count = math.min( count, need_count_for_batch - ( product.total_count or 0 ) )
    if count <= 0 then return end

    player:InventoryRemoveItem( inv_item_id, { quality }, count )

    product.total_count = ( product.total_count or 0 ) + count
    if not product.count_by_quality then
        product.count_by_quality = { 0, 0, 0 }
    end
    product.count_by_quality[ quality ] = ( product.count_by_quality[ quality ] or 0 ) + count

    -- Собрано необходимое колво для партии
    if product.total_count >= need_count_for_batch then
        -- Убираем их из морозильника
        freezer[ type ] = { }

        onProductBatchComplete( clan_id, type, product.count_by_quality, factory_lvl )
    end

    SetClanData( clan_id, "freezer", freezer )

    triggerClientEvent( player, "CF:UpdateUI", resourceRoot, {
        freezer = freezer,
        today_batches = GetClanData( clan_id, "today_product_batches" ),
    } )
end
addEvent( "CF:onPlayerAddItem", true )
addEventHandler( "CF:onPlayerAddItem", resourceRoot, onPlayerAddItem )

function onProductBatchComplete( clan_id, type, count_by_quality, factory_lvl )
    -- Инкрементим счётчик партий
    local today_product_batches = GetClanData( clan_id, "today_product_batches" ) or { }
    today_product_batches[ type ] = ( today_product_batches[ type ] or 0 ) + 1
    SetClanData( clan_id, "today_product_batches", today_product_batches )

    -- Выдаем бабло клану
    local COST_BY_QUALITY = { 1000, 1500, 2000 }
    local total_cost = 0
    for quality, count in pairs( count_by_quality ) do
        total_cost = total_cost + COST_BY_QUALITY[ quality ] * count
    end
    total_cost = math.floor( total_cost * ( 1 + GetClanBuffValue( clan_id, COST_BUFF_ID_BY_PRODUCT_TYPE[ type ] ) / 100 ) )
    GiveClanMoney( clan_id, total_cost )

    -- Выдаем бабло членам
    local need_count_for_batch = FACTORY_UPGRADES[ factory_lvl ].need_count_for_batch
    local money_bonus = FACTORY_UPGRADES[ factory_lvl ].money_bonus
    local batch_quality = GetBatchQuality( count_by_quality, need_count_for_batch )

    local ROLE_INCOME_PERCENT = {
        0.1, -- CLAN_ROLE_JUNIOR
        0.2, -- CLAN_ROLE_MIDDLE
        0.3, -- CLAN_ROLE_SENIOR
        0.4, -- CLAN_ROLE_MODERATOR
        0.5, -- CLAN_ROLE_LEADER
    }

    local BASE_INCOME_VALUES = { 27500, 30000, 32000, 35000, 40000, 42500, 45000, 47500, 50000, 58500, 55000, 57500, 62500, 62500, 65000, 80000, 80000, 80000, 80000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 100000, 102500, 105000, 107500, 110000 }

    local BATCH_QUALITY_BONUSES = { 0, 0.05, 0.10, 0.15, 0.20 }
    local batch_quality_bonus = 1 + BATCH_QUALITY_BONUSES[ batch_quality ]

    local clan_name = GetClanName( clan_id )

    for _, member in pairs( CallClanFunction( clan_id, "GetOnlineMembers" ) or { } ) do
        local level = member:GetLevel( ) - 5
        local base_income = level < 1 and 0 or BASE_INCOME_VALUES[ level ] or BASE_INCOME_VALUES[ #BASE_INCOME_VALUES ]
        local income = ( 1 + money_bonus ) * batch_quality_bonus * ROLE_INCOME_PERCENT[ member:GetClanRole( ) ] * base_income
        member:GiveMoney( income, "clan", "daily_product_receive" )

        member:PhoneNotification( {
            title = "Клан",
            msg = "Ваш клан успешно собрал партию " .. ( type == "alco" and "алкоголя" or "петрушки" ) 
                .. " и продал ее на черном рынке. \nКачество партии: " 
                .. string.rep( "★", batch_quality )
                .. "\nВ общак: +" .. total_cost .. "р. \nНа свой счет: +" .. income .. "р."
        } )

        SendElasticGameEvent( member:GetClientID( ), "clan_daily_batch_complete", {
            clan_id = clan_id,
            clan_name = clan_name,
            product_type = type,
            product_lvl_num = factory_lvl,
            grade_batch_num = batch_quality,
            batch_num = today_product_batches[ type ],
            receive_sum = income,
            currency = "soft",
        } )
    end

    SendElasticGameEvent( nil, "clan_daily_receive_all", {
        clan_id = clan_id,
        clan_name = clan_name,
        product_type = type,
        product_lvl_num = factory_lvl,
        grade_batch_num = batch_quality,
        batch_num = today_product_batches[ type ],
        point_num = total_cost / 2500, -- CLAN_MONEY_SCORE_COEF
        receive_sum = total_cost,
        currency = "soft",
    } )
end

function GetBatchQuality( count_by_quality, need_count_for_batch )
    local VALUE_BY_QUALITY = { 0.10, 0.15, 0.20 }

    local total_quality_value = 0
    for quality, count in pairs( count_by_quality ) do
        total_quality_value = total_quality_value + VALUE_BY_QUALITY[ quality ] * count / need_count_for_batch * 100
    end

    local BATCH_QUALITY_VALUES = { 0, 14.75, 16.25, 17.5, 19 }
    for quality, value in ripairs( BATCH_QUALITY_VALUES ) do
        if total_quality_value >= value then
            return quality
        end
    end
end