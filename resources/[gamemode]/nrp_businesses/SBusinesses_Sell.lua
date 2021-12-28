-- Выставка бизнеса на продажу
function onBusinessSellOpenRequest_handler( )
    local businesses = GetOwnedBusinesses( client )

    if #businesses <= 0 then
        client:ErrorWindow( "Ты не владеешь бизнесами!" )
        return
    end

    local configs = { }
    for i, business_id in pairs( businesses ) do
        local min, max = GetBusinessSellMinMaxCost( business_id )
        local conf = {
            business_id = business_id,
            name = GetBusinessConfig( business_id, "name" ),
            level = GetBusinessData( business_id, "level" ),
            min_cost = min,
            max_cost = max,
            on_sale = GetBusinessData( business_id, "on_sale" ) or 0,
            sale_cost = GetBusinessData( business_id, "sale_cost" ) or 0,
            icon = GetBusinessConfig( business_id, "icon" ),
        }
        table.insert( configs, conf )
    end

    triggerClientEvent( client, "ShowBusinessSellUI", resourceRoot, true, 
        {
            businesses = configs
        }
    )
end
addEvent( "onBusinessSellOpenRequest", true )
addEventHandler( "onBusinessSellOpenRequest", root, onBusinessSellOpenRequest_handler )

-- Список продающихся бизнесов на данный момент
function onBusinessSellPurchaseOpenRequest_handler( )
    local businesses = GetBusinessesOnSaleFor( client )

    if #businesses <= 0 then
        client:ErrorWindow( "В текущий момент бизнесов на продажу нет!" )
        return
    end

    triggerClientEvent( client, "ShowBusinessSellPurchaseUI", resourceRoot, true, 
        {
            businesses = businesses
        }
    )
end
addEvent( "onBusinessSellPurchaseOpenRequest", true )
addEventHandler( "onBusinessSellPurchaseOpenRequest", root, onBusinessSellPurchaseOpenRequest_handler )

function onBusinessSellRequest_handler( business_id, cost, target_name )
    if not IsOwnedBy( business_id, client ) then return end

    if GetBusinessData( business_id, "on_sale" ) ~= 0 then
        client:ErrorWindow( "Бизнес уже в процессе продажи!" )
        return
    end

    local can_be_sold, reason = CanBeSold( business_id )
    if not can_be_sold then
        client:ErrorWindow( reason )
        return
    end

    if cost <= 0 or cost ~= math.floor( cost ) then
        client:ErrorWindow( "Неверная сумма продажи!" )
        return
    end

    local min, max = GetBusinessSellMinMaxCost( business_id )

    if cost < min then
        client:ErrorWindow( "Минимальная стоимость продажи этого бизнеса: " .. min .. " р." )
        return
    end

    if cost > max then
        client:ErrorWindow( "Максимальная стоимость продажи этого бизнеса: " .. max .. " р." )
        return
    end

	if target_name then
        local notification = {
            title = "Биржа",
            msg = "На бирже есть бизнес `" .. GetBusinessConfig( business_id, "name" ) .. "` специально для вас"
        }

        -- Попытка 1: Поиск игрока онлайн
        local player
        for i, v in pairs( getElementsByType( "player" ) ) do
            if v:IsInGame( ) then
                if v:GetNickName( ) == target_name then
                    player = v
                    break
                end
            end
        end

        if player == client then
            client:ErrorWindow( "Нельзя выставить бизнес на продажу самому себе!" )
            return
        end

        -- Если игрок найден, выдаём уведомление
        if player then
            player:PhoneNotification( notification )
            SetBusinessData( business_id, "on_sale", player:GetUserID( ) )
            SetBusinessData( business_id, "sale_cost", cost )
            SaveBusinessData( business_id )
            triggerClientEvent( client, "ShowBusinessSellChooserUI", resourceRoot, true )
            client:InfoWindow( "Бизнес успешно выставлен на продажу для " .. player:GetNickName( ) )
        
        -- Если игрока нет в сети, ищем в БД
        else
            DB:queryAsync( function( query, client, business_id, cost )
                local result = query:poll( -1 )
                if #result <= 0 then
                    client:ErrorWindow( "Данный игрок не найден!" )
                    return
                end

                local info = result[ 1 ]
                info.client_id:PhoneNotification( notification )
                SetBusinessData( business_id, "on_sale", info.id )
                SetBusinessData( business_id, "sale_cost", cost )
                SaveBusinessData( business_id )
                triggerClientEvent( client, "ShowBusinessSellChooserUI", resourceRoot, true )
                client:InfoWindow( "Бизнес успешно выставлен на продажу для " .. info.nickname )
            
            end, { client, business_id, cost }, "SELECT id, nickname, client_id FROM nrp_players WHERE nickname LIKE ? LIMIT 1", target_name )
        end
    
    -- Продажа всем
    else
        SetBusinessData( business_id, "on_sale", -1 )
        SetBusinessData( business_id, "sale_cost", cost )
        SaveBusinessData( business_id )
        triggerClientEvent( client, "ShowBusinessSellChooserUI", resourceRoot, true )
        client:InfoWindow( "Бизнес успешно выставлен на продажу" )

    end
end
addEvent( "onBusinessSellRequest", true )
addEventHandler( "onBusinessSellRequest", root, onBusinessSellRequest_handler )

function onBusinessCancelSellRequest_handler( business_id )
    if not IsOwnedBy( business_id, client ) then return end

    if GetBusinessData( business_id, "on_sale" ) == 0 then
        client:ErrorWindow( "Бизнес и так не на продаже!" )
        return
    end

    SetBusinessData( business_id, "on_sale", 0 )
    SetBusinessData( business_id, "sale_cost", 0 )
    SaveBusinessData( business_id )

    triggerClientEvent( client, "ShowBusinessSellChooserUI", resourceRoot, true )
    client:InfoWindow( "Бизнес успешно снят с продажи!" )
end
addEvent( "onBusinessCancelSellRequest", true )
addEventHandler( "onBusinessCancelSellRequest", root, onBusinessCancelSellRequest_handler )

function onBusinessPurchaseSelectRequest_handler( business_id )
    if IsOwnedBy( business_id, client ) then
        client:ErrorWindow( "Нельзя купить бизнес у себя!" )
        return
    end

    if client:GetLevel( ) < 2 then
        client:ErrorWindow( "Покупка бизнеса доступна со второго уровня!" )
        return
    end

	local office_data = client:GetPermanentData( "office_data" )
	if office_data and office_data.class > 2 then
		if #GetOwnedBusinesses( client ) >= 3 then
			client:ErrorWindow( "Можно владеть максимум тремя бизнесами!" )
			return
		end
	elseif #GetOwnedBusinesses( client ) >= 2 then
		client:ErrorWindow( "Без офиса 3-го класса можно владеть максимум двумя бизнесами!" )
		return
	end

    if GetBusinessData( business_id, "on_sale" ) == 0 then
        client:ErrorWindow( "Бизнес больше не продаётся!" )
        return
    end

    local cost = GetBusinessData( business_id, "sale_cost" )
    if client:GetMoney( ) < cost then
        client:ErrorWindow( "Недостаточно средств для покупки!" )
        return
    end

    local can_be_sold, reason = CanBeSold( business_id )
    if not can_be_sold then
        client:ErrorWindow( reason )
        return
    end

    client:TakeMoney( cost, "business_stock_purchase" )

    local notification = {
        title = "Биржа",
        msg = "Вы продали свой `" .. GetBusinessConfig( business_id, "name" ) .. "` за " .. format_price( cost ) .. " р."
    }

    local owner_client_id = GetBusinessData( business_id, "client_id" )
    local owner_userid = GetBusinessData( business_id, "userid" )
    local player = GetPlayer( owner_userid, true )
    -- Если онлайн
    if player then
        player:GiveMoney( math.floor( cost * 0.95 ), "business_sell", business_id )
        player:PhoneNotification( notification )

    -- Если оффлайн
    else
        owner_client_id:GiveMoney( math.floor( cost * 0.95 ), "business_sell" )
        owner_client_id:PhoneNotification( notification )

    end
    
    local old_purchase_date = GetBusinessData( business_id, "purchase_date" )

    -- Ресетим все важные данные
    SetBusinessData( business_id, "on_sale", 0 )
    SetBusinessData( business_id, "sale_cost", 0 )
    SetBusinessData( business_id, "userid", client:GetUserID( ) )
    SetBusinessData( business_id, "client_id", client:GetClientID( ) )
    SetBusinessData( business_id, "purchase_date", getRealTimestamp( ) - 1 * 60 )
    SetBusinessData( business_id, "payment_date", getRealTimestamp( ) - 1 * 60 )

    WriteLog( 
        "businesses", 
        "[%s/%s/%s] [Покупка бизнеса/Биржа] Стоимость: %s, бывший владелец: %s/%s",
        business_id, GetBusinessData( business_id, "client_id" ), GetBusinessData( business_id, "client_id" ):GetNickName( ), cost, owner_client_id, owner_client_id:GetNickName( ) 
    )

    -- Врубаем ежесуточное снятие
    StartBusinessTimer( business_id )

    -- Сразу сохраняем в базу
    SaveBusinessData( business_id )

    triggerClientEvent( client, "ShowBusinessSellChooserUI", resourceRoot, true )
    client:InfoWindow( "Бизнес успешно приобретен!" )

    local days_since_previous_purchase = old_purchase_date > 0 and math.floor( ( getRealTimestamp() - old_purchase_date ) / ( 24 * 60 * 60 ) ) or 0
    triggerEvent( "onBusinessPurchase", client, business_id, cost, true, GetBusinessData( business_id, "level" ), GetBusinessData( business_id, "succes_value" ), days_since_previous_purchase )

    UpdateBusinessBlips( )
end
addEvent( "onBusinessPurchaseSelectRequest", true )
addEventHandler( "onBusinessPurchaseSelectRequest", root, onBusinessPurchaseSelectRequest_handler )

function onBusinessGovSellRequest_handler( business_id )
	if not client then return end

    if not IsOwnedBy( business_id, client ) then return end

    if not client:getData( "test_ignore_business_limit" ) then
        local can_be_sold, reason = CanBeSold( business_id )
        if not can_be_sold then
            client:ErrorWindow( reason )
            return
        end
    end

	local cost = math.floor( GetBusinessConfig( business_id, "cost" ) / 2 )
	if cost <= 0 then return end

    client:GiveMoney( cost, "business_gov_sell", business_id )

	SendToLogserver( "ПРОДАЖА БИЗНЕСА ГОСУДАРСТВУ", {
		logtype = "businesses";
		action = "gov_sell";
		user_id = client:GetID( );
		player_name = client:GetNickName( );
		client_id = client:GetClientID( );
		cost = cost;
		business_id = business_id;
		business_name = GetBusinessConfig( business_id, "name" );
	} )

    -- Ресетим все данные
    ResetBusiness( business_id )

    client:InfoWindow( "Бизнес успешно продан за за " .. format_price( cost ) .. " р." )

    UpdateBusinessBlips( )
end
addEvent( "onBusinessGovSellRequest", true )
addEventHandler( "onBusinessGovSellRequest", root, onBusinessGovSellRequest_handler )