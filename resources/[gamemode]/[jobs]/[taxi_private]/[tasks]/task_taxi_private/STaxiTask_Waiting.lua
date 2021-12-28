WAITING_TIMERS = { }
WAITING_INFO = { }

GENERAL_FAIL_EVENTS = {
    "onPlayerWasted", -- Смерть
    "onPlayerTaserDamage", -- Тайзер
    "onPlayerGotHandcuffed", -- Наручники
    "RC:OnPlayerJoined", -- Гонки
    "onPlayerEnterApartments", -- Вход в квартиру
    "onPlayerEnterViphouse", -- Вход в коттеджи и випдома
    "onPlayerEnterDrivingSchool", -- Вход в автошколу
}

for i, v in pairs( GENERAL_FAIL_EVENTS ) do
    addEvent( v, true )
end

function DestroyWaitingTimer( player )
    if isTimer( WAITING_TIMERS[ player ] ) then killTimer( WAITING_TIMERS[ player ] ) end
    removeEventHandler( "onPlayerPreLogout", player, onPlayerPreLogout_waitingHandler )
    removeEventHandler( "onPlayerVehicleEnter", player, onPlayerVehicleEnter_waitingHandler )
    for i, v in pairs( GENERAL_FAIL_EVENTS ) do
        removeEventHandler( v, player, onPlayerGeneralStuff_waitingHandler )
    end
    WAITING_TIMERS[ player ] = nil
    WAITING_INFO[ player ] = nil
end

function Player.StartWaitingFor( self, vehicle )
    local driver = vehicle:GetTaxiDriver( )
    local info = {
        vehicle = vehicle,
        license_plate = vehicle:GetNumberPlateHR( ),
        model_name = vehicle:tostring( ):gsub( " (%(ID:%d+%))", "" ),
    }

    local server_info = {
        vehicle = vehicle,
        driver = driver,
    }

    local function OnFuckWaiting( )
        local vehicle = server_info.vehicle
        -- Определяем кто виноват - водитель или пассажир
        local got_strike, failed = false, false
        if  
            isElement( vehicle ) and
            getDistanceBetweenPoints3D( vehicle.position, self.position ) > 100 and 
            not isElementInWater( self ) and 
            getElementDimension( self ) == 0 and 
            getElementInterior( self ) == 0 and
            not getElementData( self, "jailed" )
        then
            local fails = driver:GetPermanentData( "txp_fails" ) or 0
            fails = fails + 1
            got_strike = true
            if fails >= 5 then
                driver:SetPermanentData( "txp_fails", nil )
                driver:SetPermanentData( "txp_locked", getRealTime( ).timestamp )
                failed = true
            else
                driver:SetPermanentData( "txp_fails", fails )
            end
        end

        -- Если водитель получил страйк
        if got_strike then
            DestroyWaitingTimer( self )

            -- Водителю отменяем поездку
            driver:RemoveBlips( )
            driver:ResetToShiftStart( )
            if failed then
                driver:EndShift( "Ты не успел приехать к пассажиру!\nЗа частые срывы поездок ты отстранён на 1 неделю" )
            else
                driver:EndShift( "Ты не успел приехать к пассажиру!\nЗа частые срывы поездок ты будешь отстранён на 1 неделю" )
            end

            -- Пассажиру больше не нужно ждать
            self:StopWaiting( )
            self:InfoWindow( "Водитель не успел приехать за требуемое время и поездка была аннулирована" )

        -- Если водитель не получил страйк, просто отменяем поездку
        else
            triggerEvent( "onTaxiPrivateFailWaiting", self, "Время ожидания поездки истекло, поиск других пассажиров...", "Время ожидания водителя истекло" )

        end
    end
    WAITING_TIMERS[ self ] = setTimer( OnFuckWaiting, 5 * 60 * 1000, 1 )
    WAITING_INFO[ self ] = server_info
    addEventHandler( "onPlayerPreLogout", self, onPlayerPreLogout_waitingHandler )
    addEventHandler( "onPlayerVehicleEnter", self, onPlayerVehicleEnter_waitingHandler )
    for i, v in pairs( GENERAL_FAIL_EVENTS ) do
        addEventHandler( v, self, onPlayerGeneralStuff_waitingHandler )
    end

    triggerClientEvent( self, "onTaxiStartWaiting", self, info )
end

-- Завершать ожидание
function onPlayerVehicleEnter_waitingHandler( vehicle )
    if WAITING_INFO[ source ].vehicle ~= vehicle then
        triggerEvent( "onTaxiPrivateFailWaiting", source, "Пассажир отменил заказ", "Ты сел в другой транспорт, заказ Такси отменен" )
    end
end

function onPlayerPreLogout_waitingHandler( )
    triggerEvent( "onTaxiPrivateFailWaiting", source, "Пассажир покинул игру" )
end

function onPlayerGeneralStuff_waitingHandler( )
    triggerEvent( "onTaxiPrivateFailWaiting", source, "Пассажир отменил заказ" )
end

-- Функционал отмены ожидания по кастомной причине
function onTaxiPrivateFailWaiting_handler( reason_driver, reason_passenger )
    if WAITING_INFO[ source ] then
        local driver = WAITING_INFO[ source ].driver
        if isElement( driver ) then
            -- Водителю отменяем поездку
            driver:RemoveBlips( )
            driver:ResetToShiftStart( )

            if reason_driver then
                driver:ShowInfo( reason_driver )
            end
        end

        -- Пассажиру больше не нужно ждать
        source:StopWaiting( )
        
        if reason_passenger then
            source:ShowInfo( reason_passenger )
        end
    end
end
addEvent( "onTaxiPrivateFailWaiting", true )
addEventHandler( "onTaxiPrivateFailWaiting", root, onTaxiPrivateFailWaiting_handler )

function onTaxiPrivateFailWaitingCallerEnterInWater_handler()
    triggerEvent( "onTaxiPrivateFailWaiting", client, "Пассажир отменил заказ", "Ты зашёл в воду, заказ Такси отменен" )
end
addEvent( "onTaxiPrivateFailWaitingCallerEnterInWater", true )
addEventHandler( "onTaxiPrivateFailWaitingCallerEnterInWater", root, onTaxiPrivateFailWaitingCallerEnterInWater_handler )

function Player.StopWaiting( self )
    DestroyWaitingTimer( self )
    triggerClientEvent( self, "onTaxiStopWaiting", self )
end