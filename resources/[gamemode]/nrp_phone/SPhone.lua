loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShPhone" )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SDB" )

CODES = {
    911,
    921,
    999,
    925,
    950,
    935,
}

PHONE_NUMBERS = { }
PHONE_NUMBERS_REVERSE = { }

PLAYERS_PHONEBOOK = { }

function onResourceStart_handler()
    DB:queryAsync( onAsyncPhonelistRequest, { }, "SELECT id, phone FROM nrp_players" )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function onAsyncPhonelistRequest( query )
    local result = query:poll( -1 )
    for i, v in pairs( result ) do
        PHONE_NUMBERS[ v.phone ] = v.id
        PHONE_NUMBERS_REVERSE[ v.id ] = v.phone
    end
    --iprint( PHONE_NUMBERS )
end

function onPlayerCompleteLogin_handler( data )
    local player = source

    --[[local user_id = player:GetUserID( )
    local data = player:GetBatchPermanentData( "phone", "phone_contacts" )
    local phone_number_exists = tonumber( phone_number ) and tonumber( phone_number ) > 0

    -- Генерируем номер телефона
    if not phone_number_exists then
        local final_phone_number, phone_number_is_busy

        while not final_phone_number or phone_number_is_busy do
            -- Создание рандомного телефона
            local random_part_table = { }
            for i = 1, 7 do
                table.insert( random_part_table, tostring( math.random( 0, 9 ) ) )
            end
            local random_part = table.concat( random_part_table, "" )
            local phone = tostring( CODES[ math.random( #CODES ) ] .. random_part )

            -- Проверка на занятость
            if PHONE_NUMBERS[ phone ] then
                phone_number_is_busy = true
            else
                phone_number_is_busy = nil
            end

            final_phone_number = phone
        end

        phone_number = final_phone_number

        player:SetPermanentData( "phone", phone_number )
        PHONE_NUMBERS[ phone_number ] = user_id
        PHONE_NUMBERS_REVERSE[ user_id ] = phone_number
    end


    local phonebook = data.phone_contacts or { }
    local phonebook_numbers = { }
    for i, v in pairs( phonebook ) do
        local v_phone = PHONE_NUMBERS_REVERSE[ v ]
        if v_phone then table.insert( phonebook_numbers, v_phone ) end
    end

    PLAYERS_PHONEBOOK[ player ] = phonebook_numbers]]

    -- Уведомления оффлайн
    local offline_notifications = player:GetPermanentData( "offline_notifications" )
    if type( offline_notifications ) == "table" and #offline_notifications > 0 then
        for i, v in pairs( offline_notifications ) do
            player:PhoneNotification( v )
        end
        player:SetPermanentData( "offline_notifications", nil )
    end

    local phoneNumber = player:GetPhoneNumber( )
    if phoneNumber then
        for _, v in pairs( GetPlayersInGame( ) ) do
            if player ~= v and v:IsPhoneExistContact( phoneNumber ) then
                triggerClientEvent( v, "onPlayerJoinFromContacts", resourceRoot, player )
            end
        end
    end
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerCompleteLogin_handler )