CONST_RELOAD_TIME = 24 * 60 * 60 * 1000
CONST_RESET_NUMBER_TIME = 30 * 24 * 60 * 60 

function ReloadPhoneNumbers()

    --[[
    DB:queryAsync( function( qh )
        local result = qh:poll( -1 )
        
        -- Аналитика :- Сброс номера
        if result and #result > 0 then
            for k, v in pairs( result ) do
                triggerEvent( "onPlayerDropPhoneNumber", resourceRoot, v.client_id, v.level, v.phone_number_type, v.phone_number, "not_in_use" )
            end
        end
        
        -- Удаляем номера из базы
        DB:exec( "UPDATE nrp_players SET phone_number = NULL, phone_number_type = NULL, phone_number_date_pur = NULL WHERE (? - last_date) >= ? AND phone_number IS NOT NULL", getRealTimestamp(), CONST_RESET_NUMBER_TIME )

        -- Обновляем использованные номера
        DB:queryAsync( function( qh )
            local result = qh:poll( -1 )
            if result and #result > 0 then
                local temp = {}
                for k, v in pairs( result ) do
                    temp[ v.phone_number ] = v.id
                end
                NUMBERS.uses_numbers = temp
            end
        end, {}, "SELECT id, phone_number FROM nrp_players WHERE phone_number IS NOT NULL" )

    end, {}, "SELECT client_id, level, phone_number, phone_number_type FROM nrp_players WHERE (? - last_date) >= ? AND phone_number IS NOT NULL", getRealTimestamp(), CONST_RESET_NUMBER_TIME )
    ]]

    -- Обновляем использованные номера
    DB:queryAsync( function( qh )
        local result = qh:poll( -1 )
        if result and #result > 0 then
            local temp = {}
            for k, v in pairs( result ) do
                temp[ v.phone_number ] = v.id
            end
            NUMBERS.uses_numbers = temp
        end
    end, {}, "SELECT id, phone_number FROM nrp_players WHERE phone_number IS NOT NULL" )
end

function TryChangePhoneNumber( player, resulting_number )
    local old_number = player:GetPhoneNumber()
    local success, error = ChangePhoneNumber( player, old_number, resulting_number.number, resulting_number.type )
    if success then
        triggerClientEvent( player, "onPlayerNewNumberReward", resourceRoot, GetNumbersList(), resulting_number.number )
        SendToLogserver( "Игрок " .. getPlayerName( player ) .. "[ " .. player:GetUserID() .. " ] приобрёл номер" .. resulting_number.number .. " за " .. resulting_number.cost .. ", предыдущий номер: " .. (old_number and old_number or " отсуттсвует") )
        player:CompleteDailyQuest( "get_phone_number" )
        player:AddDailyQuest( "np_add_contact", true )
    else
        player:ShowError( error )
    end
end

function ChangePhoneNumber( player, old_number, number, number_type )
    if number_type ~= NUMBERS.ordinary.type then
        if NUMBERS[ number_type ] and not NUMBERS[ number_type ].IsNumber( number ) then
            return false, "Не, не знаем мы такого номера"
        end

        if NUMBERS.uses_numbers[ number ] then
            return false, "Номер уже занят"
        end
    end
    
    if player:getData( "phone.call" ) then
        return false, "Ты бы вызов завершил..."
    end

    local number_cost = NUMBERS[ number_type ].cost
    if player:GetMoney() < number_cost then
        return false, "У Вас недостаточно средств для покупки данного номера"
    end
    
    player:TakeMoney( number_cost, "phone_number_purchase", number_type ) 
    player:SetPermanentData( "phone_number", number )
    player:SetPrivateData( "phone_number", number )

    local player_id = player:GetUserID()
    if old_number then
        NUMBERS.uses_numbers[ old_number ] = nil
        -- Аналитика :- Сброс номера
        triggerEvent( "onPlayerDropPhoneNumber", client, client:GetClientID(), client:GetLevel(), number_type, old_number, "buy_new" )
    end
    
    DB:exec( "UPDATE nrp_players SET phone_number = ?, phone_number_type = ?, phone_number_date_pur = ? WHERE id = ? LIMIT 1", number, number_type, getRealTimestamp(), player_id )
    NUMBERS.uses_numbers[ number ] = player_id
    
    -- Аналитика :- Покупка номера
    triggerEvent( "onPlayerBuyPhoneNumber", client, number_type, number, number_cost, 1 )

    return true
end

function FreePhoneNumber( number )
    NUMBERS.uses_numbers[ number ] = nil
end

function onStart()
    InitializeHelpNumberFunctions()
    ReloadPhoneNumbers()
    setTimer( ReloadPhoneNumbers, CONST_RELOAD_TIME, 0 )
end
addEventHandler( "onResourceStart", resourceRoot, onStart )


function onPlayerReady_handler( player )
	player = player or source
    local phone_number = player:GetPhoneNumber()
    player:SetPrivateData( "phone_number", phone_number )
end
addEvent("onPlayerReadyToPlay", true)
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReady_handler, true, "high+1000000" )


-- Вспомогательные функции

function GetPlayerByPhoneNumber( phone_number )
    if NUMBERS.uses_numbers[ phone_number ] then
        return GetPlayer( NUMBERS.uses_numbers[ phone_number ] )
    end
    return false
end