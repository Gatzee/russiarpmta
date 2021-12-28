-- Максимальное количество снятий одного и того же неона
NEON_MAX_TAKEOFFS = 3

-- Неоны, продающиеся в магазине (софта онли)
SHOP_NEONS = {
    {
        neon_image = 3,
        cost = 2190000,
    },
    {
        neon_image = 4,
        cost = 2390000,
    },
    {
        neon_image = 5,
        cost = 2290000,
    },
    {
        neon_image = 6,
        cost = 1890000,
    },
    {
        neon_image = 7,
        cost = 2190000,
    },
    {
        neon_image = 8,
        cost = 2190000,
    },
    {
        neon_image = 9,
        cost = 2290000,
    },
    {
        neon_image = 10,
        cost = 2490000,
    },
    {
        neon_image = 13,
        cost = 1890000,
    },
    {
        neon_image = 16,
        cost = 2190000,
    },
    {
        neon_image = 17,
        cost = 1990000,
    },
    {
        neon_image = 18,
        cost = 1990000,
    },
    {
        neon_image = 20,
        cost = 2290000,
    },
    {
        neon_image = 23,
        cost = 1990000,
    },
    {
        neon_image = 25,
        cost = 1990000,
    },
    {
        neon_image = 26,
        cost = 2190000,
    },

    {
        neon_image = 29,
        cost = 1890000,
    },
    {
        neon_image = 30,
        cost = 1790000,
    },
    {
        neon_image = 31,
        cost = 1890000,
    },
    {
        neon_image = 32,
        cost = 2190000,
    },

    {
        neon_image = 35,
        cost = 1990000,
    },

    {
        neon_image = 39,
        cost = 2490000,
    },
    {
        neon_image = 40,
        cost = 2190000,
    },

    --[[{
        neon_image = 43,
        cost = 2490000,
    },
    {
        neon_image = 44,
        cost = 2490000,
    },
    {
        neon_image = 45,
        cost = 2490000,
    },]]
    {
        neon_image = 46,
        cost = 2490000,
    },
    {
        neon_image = 47,
        cost = 2490000,
    },
    {
        neon_image = 48,
        cost = 2190000,
    },

    {
        neon_image = 56,
        cost = 2490000,
    },
    {
        neon_image = 57,
        cost = 1990000,
    },
    {
        neon_image = 61,
        cost = 2390000,
    },
    {
        neon_image = 65,
        cost = 2290000,
    },
}

function OnPlayerRequestNeonsList_handler( )
    local player = client or source
    local vehicle = player.vehicle

    if vehicle ~= player:getData( "tuning_vehicle" ) then return end

    local inventory_neons = player:GetNeons( )

    -- Текущий неон тачки показываем сверху списка инвентаря
    local vehicle_neon = vehicle:GetNeon( )
    if next( vehicle_neon ) then
        vehicle_neon.current = true
        table.insert( inventory_neons, 1, vehicle_neon )
    end

    triggerClientEvent( player, "OnClientNeonsReceive", resourceRoot, SHOP_NEONS, inventory_neons )
end
addEvent( "OnPlayerRequestNeonsList", true )
addEventHandler( "OnPlayerRequestNeonsList", root, OnPlayerRequestNeonsList_handler )

function onClientRequestShopNeonPurchase_handler( neon_data )
    local player = client or source
    local vehicle = player.vehicle

    if vehicle ~= player:getData( "tuning_vehicle" ) then return end

    local shop_neon = nil

    -- Убеждаемся что данный неон есть в продаже в магазине
    for i, v in pairs( SHOP_NEONS ) do
        if v.neon_image == neon_data.neon_image and v.cost == neon_data.cost then
            shop_neon = table.copy( v )
            break
        end
    end

    if shop_neon then
        local cost = ApplyDiscount( shop_neon.cost, player )
		if not player:TakeMoney( cost, "tuning", "tuning_neon" ) then
			player:ErrorWindow( "Недостаточно средств" )
			return
		end

        shop_neon.sell_cost = math.floor( 0.2 * shop_neon.cost )
        shop_neon.takeoffs_count = 0
        
        if not next( vehicle:GetNeon( ) ) then
            player:InfoWindow( "Покупка успешна! Неон куплен и автоматически применен к твоей машине!" )
            vehicle:SetNeon( shop_neon )
            triggerClientEvent( player, "onTuningPreviewChangeNeon", player, shop_neon.neon_image )
        else
            player:InfoWindow( "Покупка успешна! Неон куплен и добавлен в твой инвентарь неонов" )
            player:GiveNeon( shop_neon )
        end

        triggerEvent( "OnPlayerRequestNeonsList", player )

        SendElasticGameEvent( player:GetClientID( ), "tuning_neon_purchase", {
            id_neon = "neon_" .. shop_neon.neon_image,
            name_neon = NEONS_ENG_NAMES[ shop_neon.neon_image ],
            cost_neon = cost,
            quantity = 1,
            spend_sum = cost,
            currency = "soft",
        } )

        player:PlaySound( SOUND_TYPE_2D, "sfx/sell1.mp3" )
    else
        player:ErrorWindow( "Данный неон не найден в магазине. Попробуйте открыть меню магазина и повторить покупку" )
    end
end
addEvent( "onClientRequestShopNeonPurchase", true )
addEventHandler( "onClientRequestShopNeonPurchase", root, onClientRequestShopNeonPurchase_handler )

function onClientRequestNeonSell_handler( neon_data )
    local player = client or source
    local vehicle = player.vehicle

    if vehicle ~= player:getData( "tuning_vehicle" ) then return end

    local sell_neon = nil

    -- Продажа напрямую с машины
    if neon_data.current then
        local vehicle_neon = vehicle:GetNeon( )
        if vehicle_neon.sell_cost then
            player:GiveMoney( vehicle_neon.sell_cost, "tuning", "tuning_neon" )
            sell_neon = vehicle_neon
        end

        vehicle:SetNeon( )
        triggerClientEvent( player, "onTuningPreviewChangeNeon", player, nil )
        triggerEvent( "OnPlayerRequestNeonsList", player )
        player:PlaySound( SOUND_TYPE_2D, "sfx/sell1.mp3" )
    
    -- Продажа из юзерского инвентаря
    else
        if player:TakeNeon( neon_data ) then
            player:GiveMoney( neon_data.sell_cost, "tuning", "tuning_neon" )
            sell_neon = neon_data
            triggerEvent( "OnPlayerRequestNeonsList", player )
            player:PlaySound( SOUND_TYPE_2D, "sfx/sell1.mp3" )
        end
    end

    if sell_neon then
        SendElasticGameEvent( player:GetClientID( ), "tuning_neon_sell", {
            id_neon = "neon_" .. sell_neon.neon_image,
            name_neon = NEONS_ENG_NAMES[ sell_neon.neon_image ],
            cost_neon = sell_neon.sell_cost,
            quantity = 1,
            receive_sum = sell_neon.sell_cost,
            currency = "soft",
        } )
    end
end
addEvent( "onClientRequestNeonSell", true )
addEventHandler( "onClientRequestNeonSell", root, onClientRequestNeonSell_handler )

function onClientRequestNeonInstall_handler( neon_data )
    local player = client or source
    local vehicle = player.vehicle

    if vehicle ~= player:getData( "tuning_vehicle" ) then return end

    if not next( vehicle:GetNeon( ) ) then
        if player:TakeNeon( neon_data ) then
            iprint( "Take set", neon_data )
            vehicle:SetNeon( neon_data )
            triggerEvent( "OnPlayerRequestNeonsList", player )
            --[[ if neon_data.takeoffs_count == NEON_MAX_TAKEOFFS - 1 then  -- Ограничение на установку неонов(максимум 3 раза установить)
                player:InfoWindow( "Неон успешно установлен!\nДанный неон можно будет снять ОДИН ПОСЛЕДНИЙ РАЗ" )
            elseif neon_data.takeoffs_count == NEON_MAX_TAKEOFFS then
                player:InfoWindow( "Неон успешно установлен!\nДанный неон можно будет ТОЛЬКО ПРОДАТЬ!" )
            else
                local takeoffs_left = NEON_MAX_TAKEOFFS - neon_data.takeoffs_count
                player:InfoWindow( "Неон успешно установлен!\nДанный неон еще можно будет снять " .. takeoffs_left .. " " .. ( takeoffs_left == 1 and " раз" or "раза" ) )
            end]]
            player:InfoWindow( "Неон успешно установлен!" )  -- Текст о установке винила(так-как старый мы вырезали)
            triggerClientEvent( player, "onTuningPreviewChangeNeon", player, neon_data.neon_image )
        else
            player:ErrorWindow( "Неон не найден в инвентаре" )
        end
    else
        player:ErrorWindow( "На машине уже установлен неон! Чтобы установить другой нужно сначала снять или продать текущий" )
    end
end
addEvent( "onClientRequestNeonInstall", true )
addEventHandler( "onClientRequestNeonInstall", root, onClientRequestNeonInstall_handler )

function onClientRequestNeonTakeoff_handler( )
    local player = client or source
    local vehicle = player.vehicle

    if vehicle ~= player:getData( "tuning_vehicle" ) then return end

    local neon = vehicle:GetNeon( )
    if next( neon ) then
        if ( neon.takeoffs_count or 0 ) >= NEON_MAX_TAKEOFFS then
            player:ErrorWindow( "Данный неон больше нельзя снять! Можно лишь только продать" )
        else
            vehicle:SetNeon( )
            neon.takeoffs_count = neon.takeoffs_count + 1
            player:GiveNeon( neon )
            triggerClientEvent( player, "onTuningPreviewChangeNeon", player, nil )
            triggerEvent( "OnPlayerRequestNeonsList", player )
        end
    end
end
addEvent( "onClientRequestNeonTakeoff", true )
addEventHandler( "onClientRequestNeonTakeoff", root, onClientRequestNeonTakeoff_handler )

