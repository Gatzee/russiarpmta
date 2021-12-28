Extend( "ShVinyls" )


-- Проверка продажи из инвентаря
function onVinylSellAttempt_handler( vinyl )
    local player = client
    local rcv = vinyl
    
    local vinyl, vinyl_position = client:FindVinyl( vinyl )
    if vinyl and vinyl_position then
        local price = GetVinylSellPrice( vinyl )
        triggerClientEvent( player, "onVinylSellAttemptCallback", player, vinyl, price )
    else
        --iprint( player, "винил на продажу из инвентаря не найден", rcv, vinyl )
    end

end
addEvent( "onVinylSellAttempt", true )
addEventHandler( "onVinylSellAttempt", root, onVinylSellAttempt_handler )

-- Продажа из инвентаря
function onVinylSellConfirm_handler( vinyl )
    local vinyl, vinyl_position = client:FindVinyl( vinyl )
    if vinyl and vinyl_position then
        
        client:TakeVinyl( vinyl_position )

        local price = GetVinylSellPrice( vinyl )
        client:GiveMoney( price, "tuning", "vinyl_sell" )

        client:RefreshVinylsInventory( )

        client:InfoWindow( "Винил успешно продан за " .. price .. " р. !" )

        triggerEvent( "onTuningVinylSold", client, price, vinyl[ P_CLASS ], tostring( vinyl[ P_NAME ] ) )
    else
        --iprint( player, "винил на продажу с инвентаря не найден" )
    end
end
addEvent( "onVinylSellConfirm", true )
addEventHandler( "onVinylSellConfirm", root, onVinylSellConfirm_handler )

-- Проверка продажи с машины
function onVinylSellFromVehicleAttempt_handler( vinyl )
    local player = client
    local vehicle = player.vehicle

    if not isElement( vehicle ) or vehicle ~= player:getData( "tuning_vehicle" ) then return end
    
    local vinyl = vehicle:FindVinyl( vinyl )
    local is_ability_removed = vehicle:IsRemoveAbilityPermanentVinyl( vinyl )

    if vinyl and is_ability_removed then
        local price = GetVinylSellPrice( vinyl )
        triggerClientEvent( player, "onVinylSellFromVehicleAttemptCallback", player, vinyl, price )
    else
        --iprint( player, "винил на продажу с машины не найден" )
    end
end
addEvent( "onVinylSellFromVehicleAttempt", true )
addEventHandler( "onVinylSellFromVehicleAttempt", root, onVinylSellFromVehicleAttempt_handler )

-- Продажа с машины
function onVinylSellFromVehicleConfirm_handler( vinyl )
    local player = client
    local vehicle = player.vehicle

    if not isElement( vehicle ) or vehicle ~= player:getData( "tuning_vehicle" ) then return end

    local vinyls = vehicle:GetVinyls( )
    for i, v in pairs( vinyls ) do
        if CompareVinyl( v, vinyl ) then

            local result_remove = vehicle:RemovePermanentVinyl( vinyl )

            if not result_remove then
                return false
            end

            if vinyl[ P_PRICE_TYPE ] == "soft" then
                local price = GetVinylSellPrice( vinyl )
                client:GiveMoney( price, "tuning", "vinyl_sell" )
                client:InfoWindow( "Винил успешно снят с машины и продан за " .. price .. " р. !" )
                triggerEvent( "onTuningVinylSold", client, price, vinyl[ P_CLASS ], tostring( vinyl[ P_NAME ] ) )
            elseif vinyl[ P_PRICE_TYPE ] == "hard" then
                client:GiveVinyl( vinyl )
            elseif vinyl[ P_PRICE_TYPE ] == "race" then
                vinyl[ P_LAYER_DATA ] = nil
                client:GiveVinyl( vinyl )
                client:InfoWindow( "Винил успешно снят с машины и помещён в инвентарь" )
            end
                        
            client:RefreshInstalledVinyls( true )

            return
        end
    end
end
addEvent( "onVinylSellFromVehicleConfirm", true )
addEventHandler( "onVinylSellFromVehicleConfirm", resourceRoot, onVinylSellFromVehicleConfirm_handler )

-- Установка из инвентаря
function onVinylInstallAttempt_handler( vinyl )
    local vinyl, vinyl_position = client:FindVinyl( vinyl )
    if not vinyl then
        client:ErrorWindow( "Данный винил не найден в инвентаре" )
        return
    end

    local vehicle = client.vehicle
    if not isElement( vehicle ) or vehicle ~= client:getData( "tuning_vehicle" ) then return end

    if vehicle:GetTier( ) ~= vinyl[ P_CLASS ] then
        client:ErrorWindow( "Винил не соответствует классу машины" )
        return
    end

    vinyl[ P_LAYER_DATA ] = { x = DEFAULT_VINYL_SIZE / 2, y = DEFAULT_VINYL_SIZE / 2, size = 1.5, rotation = 0 }
    local result, error = vehicle:ApplyPermanentVinyl( vinyl, VINYL_SLOTS_COUNT - vinyl[ P_LAYER ] )
    if result then
        client:TakeVinyl( vinyl_position )
        client:RefreshInstalledVinyls( true )

        if vinyl[ P_PRICE_TYPE ] == "soft" then
            client:InfoWindow( "Винил привязыван к машине.\nСнятие винила возможно только через его продажу.", "УСТАНОВКА ВИНИЛА" )
        elseif vinyl[ P_PRICE_TYPE ] == "hard" or vinyl[ P_PRICE_TYPE ] == "race" then
            client:InfoWindow( "Винил не привязан к машине.\nПосле снятия винила, его можно положить в инвентарь.", "УСТАНОВКА ВИНИЛА" )
		end
        triggerEvent( "onTuningVinylInstall", client, vinyl[ P_PRICE ], vinyl[ P_CLASS ], tostring( vinyl[ P_NAME ] ), client.vehicle:getModel() )
    else
        client:ErrorWindow( "Ошибка установки винила: " .. tostring( error ) )
    end
end
addEvent( "onVinylInstallAttempt", true )
addEventHandler( "onVinylInstallAttempt", root, onVinylInstallAttempt_handler )

function onPlayerTuningInventoryRefresh_handler( )
    source:RefreshVinylsInventory( )
end
addEvent( "onPlayerTuningInventoryRefresh", true )
addEventHandler( "onPlayerTuningInventoryRefresh", root, onPlayerTuningInventoryRefresh_handler )


-- Обновление порядка слоев
function UpdateLayers( layer_1, layer_2 )
    if not isElement( client ) then return end

    local vehicle = client.vehicle
    if not isElement( vehicle ) then return end

    local vinyls = vehicle:GetVinyls( vehicle:GetTier( ) )

    if vinyls[ layer_2 ] and vinyls[ layer_1 ] then
        vinyls[ layer_1 ][ P_LAYER ], vinyls[ layer_2 ][ P_LAYER ] = vinyls[ layer_2 ][ P_LAYER ], vinyls[ layer_1 ][ P_LAYER ]
        vinyls[ layer_1 ], vinyls[ layer_2 ] = vinyls[ layer_2 ], vinyls[ layer_1 ]
    elseif vinyls[ layer_1 ] then
        vinyls[ layer_1 ][ P_LAYER ] = layer_2
    end

    vehicle:SetVinyls( vinyls )
    client:RefreshInstalledVinyls()
end
addEvent( "onServerRefreshVinylLayers", true )
addEventHandler( "onServerRefreshVinylLayers", root, UpdateLayers )

if SERVER_NUMBER > 100 then
    addCommandHandler( "add_vinyl", function( player, cmd, arg )
        player:GiveVinyl( { 
			[ P_IMAGE ]      = arg,
			[ P_CLASS ]      = isElement( player.vehicle ) and player.vehicle:GetTier( ) or 1,
			[ P_NAME ]       = VINYL_NAMES[ arg ] or "Unknown",
			[ P_PRICE ]      = 0,
			[ P_PRICE_TYPE ] = "hard",
        } )
        player:ShowInfo( "Винил добавлен" )
    end )
end