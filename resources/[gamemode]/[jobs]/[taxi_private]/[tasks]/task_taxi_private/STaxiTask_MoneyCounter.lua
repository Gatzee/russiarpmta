COUNTERS_INFO = { }

function Player.IsCounting( self )
    return COUNTERS_INFO[ self ]
end

function Player.StartCounting( self, driver, vehicle )
    if COUNTERS_INFO[ self ] then return end

    driver:SetPermanentData( "taxi_fails", nil )

    local class = vehicle:GetTier( )
    local money, exp = exports.nrp_handler_economy:GetEconomyJobData( "taxi_private_" .. class )

    -- Если игрок найден в последних поездках, не давать опыт
    local deliveries = driver:GetRateList( )
    local client_id = self:GetClientID( )
    for i, v in pairs( deliveries ) do
        if v[ 1 ] == client_id then
            exp = 0
            break
        end
    end

    COUNTERS_INFO[ self ] = { 
        distance = 0, 
        money = 0,
        class = class, 
        last_position = nil, 
        per_100m = money,
        per_100m_exp = exp,
        driver = driver, 
        driver_client_id = driver:GetClientID( ),
        vehicle = vehicle,
    }

    triggerClientEvent( self, "onTaxiStartCounting", resourceRoot, money )

    self:ShowInfo( "Такси начало выполнение заказа" )
    driver:ShowInfo( "Ты начал выполнение заказа, счетчик запущен" )

    -- Обработка выхода из машины и из игры
    addEventHandler( "onPlayerVehicleExit", self, onPlayerLeaveTaxi_handler )
    addEventHandler( "onPlayerPreLogout", self, onPlayerLeaveTaxi_handler )
end

function Player.StopCounting( self )
    if not COUNTERS_INFO[ self ] then return end

    removeEventHandler( "onPlayerVehicleExit", self, onPlayerLeaveTaxi_handler )
    removeEventHandler( "onPlayerPreLogout", self, onPlayerLeaveTaxi_handler )

    triggerClientEvent( self, "onTaxiStopCounting", resourceRoot )

    local info = COUNTERS_INFO[ self ]
    
    -- Выдача денег водителю по завершению маршрута
    local driver = info.driver
    if isElement( driver ) then
        local cur_class = driver:getData( "private_taxi_cur_class" ) or 2
        driver:setData( "private_taxi_cur_class", false, false )

        local total_exp = math.floor( info.per_100m_exp * info.distance / 100 )
        driver:GiveMoney( info.money, "job_salary", "taxi_private" )
        triggerEvent( "onJobEarnMoney", driver, JOB_CLASS_TAXI_PRIVATE, info.money, "Класс " .. VEHICLE_CLASSES_NAMES[ cur_class ], total_exp or 0 )

        triggerEvent( "onJobFinishedVoyage", driver, info.money, total_exp )

        if total_exp > 0 then
            driver:GiveExp( total_exp, "TAXI_PRIVATE_FINISH" )
            driver:ShowInfo( "Ты заработал " .. format_price( info.money ) .. " р. и " .. total_exp .. " опыта за поездку" )
        else
            driver:ShowInfo( "Ты заработал " .. format_price( info.money ) .. " р. за поездку" )
        end

        if info.money > 0 then
             --Событие оплаты для ивента
            self:CompleteDailyQuest( "np_use_taxi" )
        end

        -- Возвращаем водителя на состояние начала смены и сбрасываем инфу
        driver:ResetToShiftStart( )
        triggerClientEvent( driver, "onTaxiClientAdd", driver )

        -- Заставляем игрока рейтить водителя с показом окна
        driver:AddNewRate( self, 4, info.money ) -- Дефолтный рейтинг 4
        self:SetRateTarget( driver, info.money )
        self:SendRateInfo( true )

        -- Дейлик на доставку
        triggerEvent( "TaxiPrivateDaily_AddDelivery", driver, info.money )

        -- Отмечаем что водитель ездил с этим пассажиром для блокировки на 3 часа
        if not RECENT_DRIVES[ self ] then
            RECENT_DRIVES[ self ] = { [ driver:GetUserID( ) ] = getRealTime( ).timestamp }
        else
            RECENT_DRIVES[ self ][ driver:GetUserID( ) ] = getRealTime( ).timestamp
        end
    else
        local client_id = info.driver_client_id
        client_id:GiveMoney( info.money, "job_salary", "taxi_private" )
    end

    COUNTERS_INFO[ self ] = nil
end

function Player.ResetToShiftStart( self )
    local class = self:GetCurrentClass( )
    local old_id = TAXI_DRIVERS[ self ] and TAXI_DRIVERS[ self ].vehicle_id

    local vehicle = GetVehicle( old_id )
    if vehicle then
        removeEventHandler( "onVehicleStartEnter", vehicle, onPlayerStartEnterTaxi_taskHandler )
        removeEventHandler( "onVehicleEnter", vehicle, onPlayerEnterTaxi_taskHandler )
    end
    
    TAXI_DRIVERS[ self ] = { id = self:GetUserID( ), player = self, class = class, vehicle_id = old_id, target = nil }
end

function onPlayerLeaveTaxi_handler( vehicle )
    local player = source

    player:StopCounting( )
end

MAX_TAXI_DISTANCE = 10000
function onTaxiPlayerDistancePulse_handler( distance, new_position )
    local player = client

    if not COUNTERS_INFO[ player ] then return end

    -- Сохраняем постоянные данные
    local money = math.floor( distance * COUNTERS_INFO[ player ].per_100m / 100 )
    money = math.min( money, player:GetMoney( ) )

    COUNTERS_INFO[ player ].money = COUNTERS_INFO[ player ].money + money
    COUNTERS_INFO[ player ].distance = COUNTERS_INFO[ player ].distance + distance
    COUNTERS_INFO[ player ].last_position = new_position -- { x, y, z }

    -- Обновляем проеханное расстояние для водителя
    local driver = COUNTERS_INFO[ player ] and COUNTERS_INFO[ player ].driver

    -- Если нет денег на оплату, вытаскиваем из машины
    local success = false
    if player:HasFreeTaxiTicket( ) then
        success = true
        
        local taxi_free_distance = player:GetPermanentData( "taxi_free_distance" ) or 0
        taxi_free_distance = taxi_free_distance + distance
        
        if taxi_free_distance >= 6000 then
            player:SetPermanentData( "taxi_free_distance", 0 )
            player:TakeFreeTaxiTicket( 1 )
            player:ShowInfo( "Ты потратил карточку бесплатной поездки на такси" )
        else
            player:SetPermanentData( "taxi_free_distance", taxi_free_distance )
        end
    else
        success = player:TakeMoney( money, "taxi_private_passenger" )
    end

    if not success then
        driver:ShowInfo( "У пассажира кончились деньги, поездка завершена" )
        if getPedOccupiedVehicle( player ) then
            player:KickFromVehicle( )
        end
    end

    triggerEvent( "TaxiPrivateDaily_AddDistance", player, driver, distance, money )

    if COUNTERS_INFO[ player ] then
        -- Завершение поездки по максимальному расстоянию
        if COUNTERS_INFO[ player ].distance >= MAX_TAXI_DISTANCE then
            local readable_dist = math.floor( MAX_TAXI_DISTANCE / 100 ) / 10
            driver:ShowInfo( "Превышена максимальная дистанция одной поездки: " .. readable_dist .. " км" )
            player:ShowInfo( "Превышена максимальная дистанция одной поездки: " .. readable_dist .. " км" )
            if getPedOccupiedVehicle( player ) then
                player:KickFromVehicle( )
            end
        end
    end
end
addEvent( "onTaxiPlayerDistancePulse", true )
addEventHandler( "onTaxiPlayerDistancePulse", root, onTaxiPlayerDistancePulse_handler )