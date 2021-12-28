-- Запрос на показ интерфейса
function onBusinessWindowOpenRequest_handler( business_id )
    if HasOwner( business_id ) and not IsOwnedBy( business_id, client ) then
        local on_sale = GetBusinessData( business_id, "on_sale" )
        if on_sale == -1 or on_sale == client:GetUserID( ) then
            client:ErrorWindow( "Данный бизнес принадлежит другому игроку и доступен для покупки на Бирже", "БИЗНЕС ПРОДАЁТСЯ" )
        else
            client:ErrorWindow( "Этот бизнес принадлежит другому игроку!" )
        end
        return
    end

    if not HasOwner( business_id ) then
        triggerClientEvent( client, "ShowBusinessPurchaseUI", resourceRoot, true, 
            { 
                business_id = business_id, 
                cost = GetBusinessConfig( business_id, "cost" ), 
                name = GetBusinessConfig( business_id, "name" ),
                task = GetBusinessConfig( business_id, "task" ),
                icon = GetBusinessConfig( business_id, "icon" ),
            }
        )

    else
        ShowBusinessUI( business_id, client )

    end
end
addEvent( "onBusinessWindowOpenRequest", true )
addEventHandler( "onBusinessWindowOpenRequest", resourceRoot, onBusinessWindowOpenRequest_handler )

-- Запрос на покупку
function onBusinessPurchaseRequest_handler( business_id )
	local client = client or source
	if not client then return end

	PlayerWantBuyBusiness( client, business_id )
end
addEvent( "onBusinessPurchaseRequest", true )
addEventHandler( "onBusinessPurchaseRequest", root, onBusinessPurchaseRequest_handler )

function PlayerWantBuyBusiness( player, business_id, discount )
    if player:GetLevel( ) < 2 then
        player:ErrorWindow( "Покупка бизнеса доступна со второго уровня!" )
        return
    end

    if HasOwner( business_id ) then
        player:ErrorWindow( "Данный бизнес уже куплен!" )
        return
    end

	local cost = GetBusinessConfig( business_id, "cost" )

	if discount then
		cost = math.floor( cost * ( 1 - discount) )
	end

	if player:GetMoney( ) < cost then
		player:EnoughMoneyOffer( "Business purchase", cost, "onBusinessPurchaseRequest", player, business_id )
        return
    end

    if not player:getData( "test_ignore_business_limit" ) then
    	local office_data = player:GetPermanentData( "office_data" )
    	if office_data and office_data.class > 2 then
    		if #GetOwnedBusinesses( player ) >= 3 then
    			player:ErrorWindow( "Можно владеть максимум тремя бизнесами!" )
    			return
    		end
    	elseif #GetOwnedBusinesses( player ) >= 2 then
    		player:ErrorWindow( "Без офиса 3-го класса можно владеть максимум двумя бизнесами!" )
    		return
    	end
    end

    -- Снимаем бабки
    player:TakeMoney( cost, "business_purchase", business_id )

    -- Ставим владельца и время оплаты
    local timestamp = getRealTimestamp( )
    SetBusinessData( business_id, "purchase_date", timestamp - 1 * 60 ) -- Сдвиг на минуту для ежесуточного снятия
    SetBusinessData( business_id, "payment_date", timestamp - 1 * 60 )
    SetBusinessData( business_id, "userid", player:GetUserID( ) )
    SetBusinessData( business_id, "client_id", player:GetClientID( ) )
    SaveBusinessData( business_id )

    -- Врубаем ежесуточное снятие
    StartBusinessTimer( business_id )

    -- Закрываем окно покупки
    triggerClientEvent( player, "ShowBusinessPurchaseUI", resourceRoot, false )

	if not discount then
    	-- Показываем интерфейс бизнеса
		ShowBusinessUI( business_id, player )
	end

    triggerEvent( "onPlayerSomeDo", player, "buy_business" ) -- achievements

    player:InfoWindow( "Ты приобрел бизнес! Также тебе стало доступно приложение 'Форбс' в твоем телефоне!", "Поздравляем!" )
    triggerEvent( "onBusinessPurchase", player, business_id, cost, false, GetBusinessData( business_id, "level" ), GetBusinessData( business_id, "succes_value" ) )

    UpdateBusinessBlips( )

    WriteLog( 
        "businesses", 
        "[%s/%s/%s] [Покупка бизнеса/ГОС] Стоимость: %s",
        business_id, GetBusinessData( business_id, "client_id" ), GetBusinessData( business_id, "client_id" ):GetNickName( ), cost
	)
	
	return true
end

function onBusinessBuyMaterialsAskForCost_handler( business_id, amount )
    if not IsOwnedBy( business_id, client ) then return end

    local max_materials = GetBusinessConfig( business_id, "max_materials" )
    local materials = GetBusinessData( business_id, "materials" )

    if amount == "max" then amount = max_materials end
    amount = math.min( amount, max_materials - materials  )
    
    if amount <= 0 then
        client:ErrorWindow( "Вы превысили максимальное количество продукции! Закупка отменена" )
        return
    end

    local cost = amount * GetBusinessConfig( business_id, "material_cost" )

    triggerClientEvent( client, "onBusinessBuyMaterialsAskForCostCallback", resourceRoot, business_id, cost, amount )
end
addEvent( "onBusinessBuyMaterialsAskForCost", true )
addEventHandler( "onBusinessBuyMaterialsAskForCost", root, onBusinessBuyMaterialsAskForCost_handler )

function onBusinessBuyMaterialsRequest_handler( business_id, amount )
    if not IsOwnedBy( business_id, client ) then return end

    local max_materials = GetBusinessConfig( business_id, "max_materials" )
    local materials = GetBusinessData( business_id, "materials" )

    if amount == "max" then amount = max_materials end
    amount = math.min( amount, max_materials - materials  )

    if amount <= 0 then
        client:ErrorWindow( "Вы превысили максимальное количество продукции! Закупка отменена" )
        return
    end

    local balance = GetBusinessData( business_id, "balance" )

    local cost = amount * GetBusinessConfig( business_id, "material_cost" )
    if cost > balance then
        client:ErrorWindow( "На лицевом счете недостаточно средств для закупки продукции!" )
        return
    end

    SetBusinessData( business_id, "balance", balance - cost )
    SetBusinessData( business_id, "materials", materials + amount )
    SaveBusinessData( business_id )

    -- Живое обновление количества продукции и баланса
    RefreshBalance( business_id, client )
    RefreshMaterials( business_id, client )

    client:InfoWindow( "Вы успешно закупили " .. amount .. " ед. продукции!" )

    WriteLog( 
        "businesses", 
        "[%s/%s/%s] [Закупка продукции] Куплено: %s, стало:, %s стоимость: %s, баланс: %s",
        business_id, GetBusinessData( business_id, "client_id" ), GetBusinessData( business_id, "client_id" ):GetNickName( ), amount, materials + amount, cost, balance - cost
    )
end
addEvent( "onBusinessBuyMaterialsRequest", true )
addEventHandler( "onBusinessBuyMaterialsRequest", root, onBusinessBuyMaterialsRequest_handler )

function onBusinessTakeMoneyRequest_handler( business_id, amount )
    if not IsOwnedBy( business_id, client ) then return end

    if amount <= 0 then
        client:ErrorWindow( "Неверная сумма!" )
        return
    end
    amount = math.floor( amount )

    local balance = GetBusinessData( business_id, "balance" )

    if amount > balance then
        client:ErrorWindow( "На лицевом счете нет такой суммы!" )
        return
    end

    if balance > 0 then
        client:GiveMoney( amount, "business_balance_withdraw", business_id )
        SetBusinessData( business_id, "balance", balance - amount )
        SaveBusinessData( business_id )
        RefreshBalance( business_id, client )
        client:InfoWindow( "Ты успешно снял " .. format_price( amount ) .. " р. с бизнес-счёта" )

        WriteLog( 
            "businesses", 
            "[%s/%s/%s] [Снятие баланса] Снято: %s, баланс: %s",
            business_id, GetBusinessData( business_id, "client_id" ), GetBusinessData( business_id, "client_id" ):GetNickName( ), amount, balance - amount
        )
    else
        client:ErrorWindow( "На балансе бизнеса недостаточно средств!" )
    end
end
addEvent( "onBusinessTakeMoneyRequest", true )
addEventHandler( "onBusinessTakeMoneyRequest", root, onBusinessTakeMoneyRequest_handler )

function onBusinessAddMoneyRequest_handler( business_id, amount )
    if not IsOwnedBy( business_id, client ) then return end 

    if amount <= 0 then
        client:ErrorWindow( "Неверная сумма!" )
        return
    end
    amount = math.floor( amount )

    local balance = GetBusinessData( business_id, "balance" )

    if balance + amount > GetBusinessConfig( business_id, "max_balance" ) then
        client:ErrorWindow( "Сумма превышает максимальнй баланс лицевого счета бизнеса!" )
        return
    end

    if amount > client:GetMoney( ) then
        client:ErrorWindow( "Недостаточно средств!" )
        return
    end

    client:TakeMoney( amount, "business_balance_topup" )
    SetBusinessData( business_id, "balance", balance + amount )
    SaveBusinessData( business_id )
    RefreshBalance( business_id, client )
    client:InfoWindow( "Ты успешно пополнил лицевой счёт на " .. format_price( amount ) .. " р." )
    
    client:CompleteDailyQuest( "recharge_ba" )

    WriteLog( 
        "businesses", 
        "[%s/%s/%s] [Пополнение баланса] Пополнено на: %s, баланс: %s",
        business_id, GetBusinessData( business_id, "client_id" ), GetBusinessData( business_id, "client_id" ):GetNickName( ), amount, balance + amount
    )
end
addEvent( "onBusinessAddMoneyRequest", true )
addEventHandler( "onBusinessAddMoneyRequest", root, onBusinessAddMoneyRequest_handler )

function onBusinessLevelUpRequest_handler( business_id )
    if not IsOwnedBy( business_id, client ) then return end 

    local succes_value = GetBusinessData( business_id, "succes_value" )
    local next_level = GetBusinessData( business_id, "level" ) + 1
    local levelup_cost = GetBusinessDefaultConfig( business_id, "cost" ) * next_level

    if succes_value < MAX_SUCCES_VALUE then
        client:ErrorWindow( "Недостаточно успешности!" )
        return
    end

    if next_level > MAX_BUSINESS_LEVEL then
        client:ErrorWindow( "Достигнут максимальный уровень!" )
        return
    end

    if levelup_cost > client:GetMoney( ) then
        client:ErrorWindow( "Недостаточно средств!" )
        return
    end

    client:TakeMoney( levelup_cost, "business_shop", "business_upgrade" )
    SetBusinessData( business_id, "level", next_level )
    SetBusinessData( business_id, "succes_value", 0 )
    SaveBusinessData( business_id )
    ShowBusinessUI( business_id, client )
    client:InfoWindow( "Ты успешно поднял уровень бизнеса!" )
    
    local days_since_purchase = math.floor( ( getRealTimestamp() - GetBusinessData( business_id, "purchase_date" ) ) / ( 24 * 60 * 60 ) )
    triggerEvent( "onBusinessLevelUp", client, business_id, levelup_cost, next_level, days_since_purchase )

    WriteLog( 
        "businesses", 
        "[%s/%s/%s] [Прокачка уровня] Уровень: %s, стоимость: %s",
        business_id, GetBusinessData( business_id, "client_id" ), GetBusinessData( business_id, "client_id" ):GetNickName( ), next_level, levelup_cost
    )
end
addEvent( "onBusinessLevelUpRequest", true )
addEventHandler( "onBusinessLevelUpRequest", root, onBusinessLevelUpRequest_handler )

function onBusinessTakeBribeRequest_handler( business_id, selected_choice )
    if not IsOwnedBy( business_id, client ) then return end 

    if GetBusinessData( business_id, "level" ) < BRIBE_BUSINESS_LEVEL then
        client:ErrorWindow( "Необходимо прокачать бизнес до 2 уровня" )
        return
    end

    local bribe_date = GetBusinessData( business_id, "bribe_date" ) or 0

    if bribe_date + BRIBE_TAKING_COOLDOWN > getRealTimestamp() then
        client:ErrorWindow( "До следующего отката " .. getHumanTimeString( bribe_date + BRIBE_TAKING_COOLDOWN ) )
        return
    end

    if client:IsInFaction() then
        client:GiveFactionExp( BRIBE_ITEMS.faction.faction_exp )
        client:ChangeSocialRating( BRIBE_ITEMS.faction.social_rating )
    elseif client:IsInClan() then
        client:GiveClanEXP( BRIBE_ITEMS.clan.clan_exp )
        client:ChangeSocialRating( BRIBE_ITEMS.clan.social_rating )
    elseif BRIBE_ITEMS.choice[ selected_choice ] then
        client:ChangeSocialRating( BRIBE_ITEMS.choice[ selected_choice ].social_rating )
    end

    SetBusinessData( business_id, "bribe_date", getRealTimestamp() )
    SaveBusinessData( business_id )
    client:InfoWindow( "Ты успешно получил откат!" )

    triggerClientEvent( client, "onBusinessTakeBribeCallback", resourceRoot )
end
addEvent( "onBusinessTakeBribeRequest", true )
addEventHandler( "onBusinessTakeBribeRequest", root, onBusinessTakeBribeRequest_handler )

-- Показ интерфейса игроку
function ShowBusinessUI( business_id, player )
    local conf = {
        business_id = business_id,
        name = GetBusinessConfig( business_id, "name" ),
        balance = GetBusinessData( business_id, "balance" ),
        materials = GetBusinessData( business_id, "materials" ),
        level = GetBusinessData( business_id, "level" ),
        succes_value = GetBusinessData( business_id, "succes_value" ),
        task = GetBusinessConfig( business_id, "task" ),
        max_balance = GetBusinessConfig( business_id, "max_balance" ),
        task_short = GetBusinessConfig( business_id, "task_short" ),
        max_weekly_income = GetBusinessConfig( business_id, "max_weekly_income" ),
        weekly_cost = GetBusinessConfig( business_id, "weekly_cost" ),
        cost = GetBusinessConfig( business_id, "cost" ),
        default_cost = GetBusinessDefaultConfig( business_id, "cost" ),
        icon = GetBusinessConfig( business_id, "icon" ),
	}
    triggerClientEvent( player, "ShowBusinessUI", resourceRoot, true, conf )

    -- Тестирование
    if SERVER_NUMBER > 100 then
        outputConsole( "business_id " .. business_id )
    end
end

function RefreshBalance( business_id, player )
    triggerClientEvent( player, "onBusinessRefreshBalanceRequest", resourceRoot, GetBusinessData( business_id, "balance" ) )
end

function RefreshMaterials( business_id, player )
    triggerClientEvent( player, "onBusinessRefreshMaterialsRequest", resourceRoot, GetBusinessData( business_id, "materials" ) )
end

function onHelpRequestOwnBusinesses_handler( )
    local businesses = GetOwnedBusinessesPositions( client )
    if #businesses <= 0 then
        client:ErrorWindow( "Ты не владеешь ни одним бизнесом!" )
        return
    end

    triggerClientEvent( client, "ToggleGPS", client, businesses )
end
addEvent( "onHelpRequestOwnBusinesses", true )
addEventHandler( "onHelpRequestOwnBusinesses", root, onHelpRequestOwnBusinesses_handler )