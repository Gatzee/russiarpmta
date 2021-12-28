BUSINESS_TIMERS = {  }

function TakeBusinessDailyPayment( business_id )
    local materials = GetBusinessData( business_id, "materials" )

    local player = GetPlayer( GetBusinessData( business_id, "userid" ), true )
    local client_id = GetBusinessData( business_id, "client_id" )

    if GetBusinessConfig( business_id, "weekly_cost" ) > GetBusinessData( business_id, "balance" ) then
        local time = getRealTime( )
        local weekdays = {
            [ 5 ] = true, -- пт
            [ 6 ] = true, -- сб
            [ 0 ] = true, -- вс
        }
        if weekdays[ time.weekday ] then
            ( player or client_id ):PhoneNotification( {
                title = "Бизнес",
                msg = "На вашем бизнесе " .. GetBusinessConfig( business_id, "name" ) .. " слишком низкий баланс"
            } )
        end
    end

    if materials <= 0 then return false, "Нехватка продукции" end

    local thresholds = GetBusinessConfig( business_id, "sell_thresholds" )
    local amounts = GetBusinessConfig( business_id, "sell_amounts" )
    local percentages = GetBusinessConfig( business_id, "sell_percentages" )

    local percentage, amount

    for i = 1, #thresholds do
        if materials > thresholds[ i ] then
            amount, percentage = amounts[ i ], percentages[ i ]
        end
    end

    -- Меньше других порогов - дефолтно 75% и снятие остатка
    if not amount then
        amount = materials
        percentage = 0.75
    end

    amount = math.min( amount, materials )

    -- Бабло и материалы
	local max_daily_income = GetBusinessConfig( business_id, "daily_income" )
	local income_before_taxes = math.floor( max_daily_income * percentage + 0.5 )
	local result_money, money_real, money_gov = exports.nrp_factions_gov_ui_control:GetBussnessesEconomyPercent( GetBusinessData( business_id, "gov_id" ), income_before_taxes )

    SetBusinessData( business_id, "materials", materials - amount )
    SetBusinessData( business_id, "balance", math.min( GetBusinessConfig( business_id, "max_balance" ), GetBusinessData( business_id, "balance" ) + result_money ) )
    SaveBusinessData( business_id )

    -- Успешность
    if GetBusinessData( business_id, "level" ) < MAX_BUSINESS_LEVEL then
        local succes_value = GetBusinessData( business_id, "succes_value" )
        local new_succes_value = succes_value + math.floor( income_before_taxes / max_daily_income * SUCCES_VALUE_CALC_COEF )
        SetBusinessData( business_id, "succes_value", math.min( new_succes_value, MAX_SUCCES_VALUE ) )
    end

    -- Коины бизнеса
    local result_coins = math.floor( GetBusinessConfig( business_id, "daily_business_coins" ) * percentage + 0.5 )

    WriteLog( 
        "businesses", 
        "[%s/%s/%s] [Ежедневная продажа] Продано продукции: %s, на сумму: %s, текущий баланс: %s, получено коинов: %s",
        business_id, GetBusinessData( business_id, "client_id" ), GetBusinessData( business_id, "client_id" ):GetNickName( ), amount, result_money, GetBusinessData( business_id, "balance" ), result_coins
    )

    -- Если в сети - выдаём и оповещаем
    if player then
        player:GiveBusinessCoins( result_coins, "BUSINESS_DAILYPAYMENT_" .. business_id )
    
    -- Если не в сети - просто пополняем бизнес коины
    else
        DB:exec( "UPDATE nrp_players SET business_coins=`business_coins`+? WHERE id=? LIMIT 1", result_coins, GetBusinessData( business_id, "userid" ) )

    end

    local target = player or client_id
    local balance = GetBusinessData( business_id, "balance" )

    target:PhoneNotification( {
        title = "Изменение баланса бизнеса",
        msg = "Баланс бизнеса " .. GetBusinessConfig( business_id, "name" ) .. " изменился, продукция продана! Сейчас на счете: " .. balance .. " р."
    } )

    target:PhoneNotification( {
        title = FACTIONS_NAMES[ GetBusinessData( business_id, "gov_id" ) ],
        msg = "Надбавка мэрии города за продажу продукции составила: " .. money_gov .. " р."
    } )

    -- Уведомление если бизнес достиг максимального баланса (онлайн + оффлайн)
    if GetBusinessConfig( business_id, "max_balance" ) <= balance then
        target:PhoneNotification( {
            title = "Счёт бизнеса заполнен",
            msg = "Ваш лицевой счет бизнеса " .. GetBusinessConfig( business_id, "name" ) .. " заполнен (" .. balance .. " р.), переведите ваши средства"
        } )
    end

    SetBusinessData( business_id, "payment_date", getRealTimestamp( ) - 1 * 60 )

    return true
end

function StartBusinessTimer( business_id )
    if not HasOwner( business_id ) then return end

    KillBusinessTimer( business_id )

    local purchase_date = GetBusinessData( business_id, "purchase_date" )
    local purchase_time = getRealTime( purchase_date )
    local hour, minute = purchase_time.hour, purchase_time.minute

    local day_time_s = 24 * 60 * 60
    local payment_date = GetBusinessData( business_id, "payment_date" )

    if payment_date ~= 0 and getRealTimestamp( ) - payment_date > day_time_s then
        TakeBusinessDailyPayment( business_id )
    end
  
    -- Нормализуем время
    BUSINESS_TIMERS[ business_id ] = ExecAtTime( hour .. ":" .. minute, 
        function( ) 
            TakeBusinessDailyPayment( business_id )

            -- Долбим по этому времени каждые сутки
            BUSINESS_TIMERS[ business_id ] = setTimer( TakeBusinessDailyPayment, 24 * 60 * 60 * 1000, 0, business_id )
        end
    )
end

function KillBusinessTimer( business_id )
    if BUSINESS_TIMERS[ business_id ] then
        if type( BUSINESS_TIMERS[ business_id ] ) == "table" then
            BUSINESS_TIMERS[ business_id ]:destroy( )
        elseif isTimer( BUSINESS_TIMERS[ business_id ] ) then
            killTimer( BUSINESS_TIMERS[ business_id ] )
        end
    end
end

-- Тестирование

if SERVER_NUMBER > 100 then
    addCommandHandler( "take_business", function( player, cmd, business_id )
        if not business_id then return end
        iprint( "take_business ", business_id )
        TakeBusinessDailyPayment( business_id )
    end )

    addCommandHandler( "start_timer_business", function( player, cmd, business_id )
        if not business_id then return end
        iprint( "start_timer_business ", business_id )
        StartBusinessTimer( business_id )
    end )
end