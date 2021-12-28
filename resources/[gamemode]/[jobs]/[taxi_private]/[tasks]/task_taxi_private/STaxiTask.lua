loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SPlayerOffline" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SDB" )

RECENT_DRIVES = { }
MIN_REDRIVE_TIME = 3 * 60 * 60 -- 3 часа для повторной поездки с тем же водителем
MIN_REQUEST_AMOUNT = 12

function onTaxiFindRequest_handler( class, request_num )
    if client:isInWater() then
        return
    end

    if TAXI_DRIVERS[ client ] then
        client:ShowError( "Нафига ты ищешь кого-то, если ты сам водитель О_о")
        return
    end

    triggerEvent( "onPlayerSomeDo", client, "find_taxi" ) -- achievements

    local drivers = GetFreeDriversForClass( class )
    if #drivers > 0 then
        local recent_drives = RECENT_DRIVES[ client ] or { }
        local allowed_any_driver = request_num and request_num >= MIN_REQUEST_AMOUNT

        local nearest_driver, distance = _, math.huge
        for i, v in pairs( drivers ) do
            local player = v.player
            local recent_drive_info = recent_drives[ player:GetUserID( ) ]

            local temp_distance = getDistanceBetweenPoints3D( player.position, source.position )
            if distance and temp_distance <= distance and player ~= client and getPedOccupiedVehicle( player ) and TAXI_DRIVERS[ player ].vehicle_id and ( allowed_any_driver or not recent_drive_info or ( getRealTime( ).timestamp - recent_drive_info >= MIN_REDRIVE_TIME ) ) then
                nearest_driver = v
                distance = temp_distance
            end
        end

        if nearest_driver then
            local driver = nearest_driver.player
            local vehicle = driver:GetSelectedTaxiVehicle( )
            local info = {
                vehicle = vehicle,
                license_plate = vehicle:GetNumberPlateHR( ),
                model_name = vehicle:tostring( ):gsub( " (%(ID:%d+%))", "" ),
            }
            triggerClientEvent( client, "onTaxiFindRequest_Found", client, info )

            --triggerEvent( "onTaxiDriverStartTask", nearest_driver.player, source, class )
        end
    end
end
addEvent( "onTaxiFindRequest", true )
addEventHandler( "onTaxiFindRequest", root, onTaxiFindRequest_handler )

function onPlayerConfirmTaxiDrive_handler( vehicle )
    local driver = vehicle:GetTaxiDriver( )

    if not TAXI_DRIVERS[ driver ] then
        client:ShowError( "Водитель больше не на смене!" )
        return
    end

    if getPedOccupiedVehicle( client ) then
        client:ShowError( "Нельзя заказывать такси в транспорте" )
        return
    end

    if getElementDimension( client ) ~= 0 or getElementInterior( client ) ~= 0 then
        client:ShowError( "Здесь нельзя сделать заказ" )
        return
    end

    if isElementInWater(client) then 
        client:ShowError( "Нельзя сделать заказ находясь на воде" )
        return
    end

    if client:IsHandcuffed( ) then
        client:ShowError( "Нельзя сделать заказ в наручниках" )
        return
    end

    if getElementData( client, "jailed" ) then
        client:ShowError( "Нельзя сделать заказ в тюрьме" )
        return
    end

    if driver and not driver:IsBusy( ) then
        -- Отмечаем на карте и ставим заказавшего как цель
        TAXI_DRIVERS[ driver ].target = client
        triggerClientEvent( driver, "AddTaxiBlipTo", client )

        -- Добавляем обработку на попытку сесть в машину
        addEventHandler( "onVehicleStartEnter", vehicle, onPlayerStartEnterTaxi_taskHandler )
        addEventHandler( "onVehicleEnter", vehicle, onPlayerEnterTaxi_taskHandler )

        -- Отсылаем информацию о машине игроку
        client:StartWaitingFor( vehicle )

        -- Отсылаем водителю информацию о игроке
        local nickname, distance = client:GetNickName( ), math.floor( ( driver.position - client.position ).length )
        driver:PhoneNotification( {
            title = "Пассажир отмечен на карте",
            short_msg = nickname .. ", " .. distance .. " м",
            msg = "Клиент: " .. nickname .. ", расстояние: " .. distance .. " м",
            no_sound = true,
        } )
        driver:PlaySound( SOUND_TYPE_2D, ":nrp_shared/sfx/fx/taxi.wav" )
    else
        client:ShowError( "Водитель принял другой заказ!" )
        
    end
end
addEvent( "onPlayerConfirmTaxiDrive", true )
addEventHandler( "onPlayerConfirmTaxiDrive", root, onPlayerConfirmTaxiDrive_handler )

function onPlayerStartEnterTaxi_taskHandler( player, seat )
    local vehicle = source
    local success, err = player:CheckForTaxiVehicle( vehicle, seat )
    if not success then
        player:ShowError( err )
        cancelEvent( )
        return
    end
end

function onPlayerEnterTaxi_taskHandler( player, seat )
    local vehicle = source
    local success, err = player:CheckForTaxiVehicle( vehicle, seat )
    if not success then
        player:ShowError( err )
        cancelEvent( )
        return
    end

    DestroyWaitingTimer( player )

    removeEventHandler( "onVehicleStartEnter", vehicle, onPlayerStartEnterTaxi_taskHandler )
    removeEventHandler( "onVehicleEnter", vehicle, onPlayerEnterTaxi_taskHandler )

    local driver = vehicle:GetTaxiDriver( )

    driver:RemoveBlips( )
    
    -- Начинаем счетчик
    player:StartCounting( driver, vehicle )
end