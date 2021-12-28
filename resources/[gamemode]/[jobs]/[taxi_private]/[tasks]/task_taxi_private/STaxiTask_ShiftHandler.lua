TAXI_DRIVERS = { }

function onTaxiPrivateShiftStart_handler( )
    local player = source

    if not TAXI_DRIVERS[ player ] then
        player:ResetToShiftStart( )
        triggerClientEvent( player, "ShowTaxiInfo", player, 0 )

        addEventHandler( "onPlayerVehicleEnter", player, onPlayerVehicleEnter_shiftHandler )
        addEventHandler( "onPlayerPreLogout", player, onPlayerPreLogout_shiftHandler, false, "high+100" )
    end
end
addEvent( "onTaxiPrivateShiftStart", true )
addEventHandler( "onTaxiPrivateShiftStart", root, onTaxiPrivateShiftStart_handler )

-- Игрок сел в машину - можно запрещать вытаскивать его, тд
function onPlayerVehicleEnter_shiftHandler( vehicle, seat )
    local player = source

    if TAXI_DRIVERS[ player ].vehicle_id and not TAXI_DRIVERS[ player ].forced then return end

    local taxi_vehicle = player:GetSelectedTaxiVehicle( )

    -- Сел не в ту машину - завершаем смену
    if vehicle:GetOwnerID( ) ~= player:GetUserID( ) then
        player:EndShift( "Ты не являешься владельцем этого транспорта" )
        return
    end

    if vehicle ~= taxi_vehicle then
        player:EndShift( "Ты выбрал другой автомобиль для развозки" )
        return
    end

    if seat ~= 0 then
        player:EndShift( "Нельзя развозить клиентов на пассажирском месте" )
        return
    end

    TAXI_DRIVERS[ player ].vehicle_id = vehicle:GetID( )
    TAXI_DRIVERS[ player ].forced = false
    player:setData( "private_taxi_cur_class", player:GetCurrentClass( ), false )

    -- Вытаскиваем всех пассажиров
    for i, v in pairs( getVehicleOccupants( vehicle ) ) do
        if i ~= 0 then
            v:KickFromVehicle( )
        end
    end

    addEventHandler( "onPlayerVehicleExit", player, onPlayerVehicleExit_shiftHandler )
    addEventHandler( "onVehicleStartEnter", vehicle, onVehicleStartEnter_shiftHandler )
    addEventHandler( "onVehicleChangeBlockState", vehicle, onVehicleChangeBlockState_shiftHandler )

    CreateDriverBlip( player )

    player:ShowInfo( "Выполняется поиск клиентов, ожидайте..." )
end

-- Вышел из своей машины
function onPlayerVehicleExit_shiftHandler( vehicle )
    local player = source
    player:EndShift( "Ты покинул свою машину!" )
end

-- Вышел из игры
function onPlayerPreLogout_shiftHandler( )
    local player = source
    player:EndShift( )
end

-- Попыткка сесть в машину - блокируем посадку в машину
function onVehicleStartEnter_shiftHandler( player, seat )
    local vehicle = source

    local driver = vehicle:GetTaxiDriver( )

    if not driver then 
        cancelEvent( )
        return
    end

    if driver:GetDriveTarget( ) ~= player then
        cancelEvent( )
        player:ShowError( "Таксист ожидает заказ, вы можете заказать такси в приложении" )
    end

    if seat == 0 then
        cancelEvent( )
        player:ShowError( "Можно сесть только на пассажирское место!" )
        return
    end
end

function onVehicleChangeBlockState_shiftHandler( )
    local driver = source:GetTaxiDriver( )
    if driver then
        driver:EndShift( "Машина заблокирована!" )
    end
end
addEvent( "onVehicleChangeBlockState", true )

function onTaxiPrivateShiftEnd_handler( )
    local player = client or source
    if TAXI_DRIVERS[ player ] then
        player:RemoveBlips( )
        DestroyDriverBlip( player )

        local vehicle = GetVehicle( TAXI_DRIVERS[ player ].vehicle_id )
        if isElement( vehicle ) then
            removeEventHandler( "onVehicleStartEnter", vehicle, onVehicleStartEnter_shiftHandler )
            removeEventHandler( "onVehicleStartEnter", vehicle, onPlayerStartEnterTaxi_taskHandler )
            removeEventHandler( "onVehicleEnter", vehicle, onPlayerEnterTaxi_taskHandler )
            removeEventHandler( "onVehicleChangeBlockState", vehicle, onVehicleChangeBlockState_shiftHandler )
        end

        local target = TAXI_DRIVERS[ player ].target
        if isElement( target ) then
            -- Если сейчас игрока везут
            if target:IsCounting( ) then
                target:KickFromVehicle( )
                target:ErrorWindow( "Таксист завершил смену, поездка завершена" )

            -- Если он ждет
            else
                target:StopWaiting( )
                target:ErrorWindow( "Таксист завершил смену, поездка отменена.\nВы можете заказать другую машину в приложении \"Такси\"" )
            end
        end

        TAXI_DRIVERS[ player ] = nil
        triggerClientEvent( player, "HideTaxiInfo", player )

        removeEventHandler( "onPlayerVehicleEnter", player, onPlayerVehicleEnter_shiftHandler )
        removeEventHandler( "onPlayerVehicleExit", player, onPlayerVehicleExit_shiftHandler )
        removeEventHandler( "onPlayerPreLogout", player, onPlayerPreLogout_shiftHandler )
    end
end
addEvent( "onTaxiPrivateShiftEnd" )
addEventHandler( "onTaxiPrivateShiftEnd", root, onTaxiPrivateShiftEnd_handler )

function onTaxiPrivateVehicleChange_handler( vehicle_id, class )
    local player = client or source

    if TAXI_DRIVERS[ player ] then
        TAXI_DRIVERS[ player ].forced = true
        TAXI_DRIVERS[ player ].vehicle_id = vehicle_id
        TAXI_DRIVERS[ player ].class = class
    end
end
addEvent( "onTaxiPrivateVehicleChange" )
addEventHandler( "onTaxiPrivateVehicleChange", root, onTaxiPrivateVehicleChange_handler )