
MAX_MESSAGE_LEN = 200

function TrySendSms( pSource, phone_number, message, fast_open_chat )

    local pTarget = GetPlayerByPhoneNumber( phone_number )
    if not pTarget then
        pSource:ShowError( "Абонент недоступен" )
        return
    end
    
    for k, v in pairs( { pTarget, pSource } ) do
        local can_talk = IsNumberCanTalk( v )
        if not can_talk then
            client:ShowError( "Абонент недоступен" )
            return false
        end
    end

    local type_contact = pSource:IsPhoneExistContact( phone_number ) and "friend" or "other"
    
    local price = RATE.single[ type_contact ].msg
    if pSource:GetMoney() < price or ( fast_open_chat and message ~= "" ) then
        pSource:ShowError( "У вас недостаточно средств" )
        return
    end

    if pSource == pTarget then
        pSource:ShowError( "Сам с собой собрался общаться?" )
        return
    end

    SendSms( pSource, pTarget, price, message, fast_open_chat )

end

function SendSms( pSource, pTarget, price, message, fast_open_chat )
    if not fast_open_chat then
        pSource:TakeMoney( price, "phone_sms_send" )
    end
    
    message = utf8.sub( message, 1, MAX_MESSAGE_LEN )

    triggerClientEvent( pTarget, "onClientReceivePrivateMessage", pSource, 
    {
        src = pSource:GetUserID(),
        player_id = pSource:GetUserID(),
        player_nick = pSource:GetNickName(),
        phone_number = pSource:GetPhoneNumber(),
        message = message,
        from_tp = fast_open_chat,
    })

    --Вывод сообщения отправителю
    triggerClientEvent( pSource, "onClientReceivePrivateMessage", pSource, 
    {
        src = pSource:GetUserID(),
        player_id = pTarget:GetUserID(),
        player_nick = pTarget:GetNickName(),
        phone_number = pTarget:GetPhoneNumber(),
        message = message,
        from_tp = fast_open_chat,
    })

    -- Аналитика :- Игрок отправил СМС
    triggerEvent( "onPlayerPhoneMessageSend", pSource, price, "soft", 1 )

end

function onSmsListRequest_handler()
    local contact_list, remove_list = GetActualContactList( client )
    triggerClientEvent( client, "onSmsListRequestCallback", client, contact_list, remove_list )
end
addEvent( "onSmsListRequest", true )
addEventHandler( "onSmsListRequest", root, onSmsListRequest_handler )

-- Попытка отправки СМС из телефона
function onServerPlayerSendSms_handler( phone_number, message, fast_open_chat, hand_number )
    if NUMBERS.IsAnyNumber( phone_number ) and NUMBERS.uses_numbers[ phone_number ] and utf8.len( message ) <= MAX_MESSAGE_LEN then
        TrySendSms( client, phone_number, message, fast_open_chat )
    else
        client:ShowError( "Абонент недоступен" )
    end
end
addEvent( "onServerPlayerSendSms", true )
addEventHandler( "onServerPlayerSendSms", root, onServerPlayerSendSms_handler )

-- Попытка отправки СМС из чата
function onServerPlayerSendSmsByChat_handler( player_id, message )
    local player = GetPlayer( player_id )
    if not player then return end

    local phone_number = player:GetPhoneNumber() 
    if phone_number and NUMBERS.IsAnyNumber( phone_number ) and NUMBERS.uses_numbers[ phone_number ] and utf8.len( message ) <= MAX_MESSAGE_LEN then
        TrySendSms( client, phone_number, message )
    else
        client:ShowError( "Абонент недоступен" )
    end
end
addEvent( "onServerPlayerSendSmsByChat", true )
addEventHandler( "onServerPlayerSendSmsByChat", root, onServerPlayerSendSmsByChat_handler )