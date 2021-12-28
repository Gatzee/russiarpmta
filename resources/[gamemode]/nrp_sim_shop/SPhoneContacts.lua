

-- Добавление контакта
function onServerPlayerAddPhoneContact_handler( phone_number )
    if NUMBERS.IsAnyNumber( phone_number ) and NUMBERS.uses_numbers[ phone_number ] then

        local pTarget = GetPlayerByPhoneNumber( phone_number )
        if not pTarget then
            client:ShowError( "Контакт не в сети" )
            return
        end

        client:AddPhoneContact( phone_number, pTarget:GetUserID(), pTarget:GetNickName() )
        
        local contact_list, remove_list = GetActualContactList( client )
        triggerClientEvent( client, "onClientContactListRefresh", resourceRoot, contact_list, remove_list, true, GetStatusPhoneCallPlayer( client ) )
    end
end
addEvent( "onServerPlayerAddPhoneContact", true )
addEventHandler( "onServerPlayerAddPhoneContact", root, onServerPlayerAddPhoneContact_handler )

-- Прямой набор номера
function onServerPlayerCallPhoneNumber_handler( phone_number )
    local call_result, call_error = false, "not_abonent"
    if NUMBERS.IsAnyNumber( phone_number ) and NUMBERS.uses_numbers[ phone_number ] then
        call_result, call_error = TryCall( client, phone_number )
    end
    if not call_result then
        triggerClientEvent( client, "onClientFailCall", client, call_error )
    end
end
addEvent( "onServerPlayerCallPhoneNumber", true )
addEventHandler( "onServerPlayerCallPhoneNumber", root, onServerPlayerCallPhoneNumber_handler )

-- Звонок из записной книжки
function onServerPlayerCallPhoneContact_handler( phone_number )
    local call_result, call_error = false, "not_abonent"
    if NUMBERS.IsAnyNumber( phone_number ) and NUMBERS.uses_numbers[ phone_number ] and client:IsPhoneExistContact( phone_number ) then
        call_result, call_error = TryCall( client, phone_number )
    end
    if not call_result then
        triggerClientEvent( client, "onClientFailCall", client, call_error )
    end
end
addEvent( "onServerPlayerCallPhoneContact", true )
addEventHandler( "onServerPlayerCallPhoneContact", root, onServerPlayerCallPhoneContact_handler )

-- Игрок принял звонок
function onServerAcceptPhoneCall_handler( )
    AcceptCall( client )
end
addEvent( "onServerAcceptPhoneCall", true )
addEventHandler( "onServerAcceptPhoneCall", root, onServerAcceptPhoneCall_handler )

-- Игрок игнорировал звонок
function onServerIgnorePhoneCall_handler( )
    IgnoreCall( client )
end
addEvent( "onServerIgnorePhoneCall", true )
addEventHandler( "onServerIgnorePhoneCall", root, onServerIgnorePhoneCall_handler )

-- Игрок завершил звонок
function onServerEndPhoneCall_handler( pTarget )
    local player = client or pTarget
    StopCall( player, "end" )
end
addEvent( "onServerEndPhoneCall", true )
addEventHandler( "onServerEndPhoneCall", root, onServerEndPhoneCall_handler )

-- Задание номера не-/избранными
function onServerSetContactFavorite_handler( phone_number, favorite_state )
    if NUMBERS.IsAnyNumber( phone_number ) and client:IsPhoneExistContact( phone_number ) then
        client:SetContactFavorite( phone_number, favorite_state )
    else
        client:ShowError( "Неизвестный номер" )
    end
end
addEvent( "onServerSetContactFavorite", true )
addEventHandler( "onServerSetContactFavorite", root, onServerSetContactFavorite_handler )

-- При входе отсылаем контакты игрока на клиент
function onClientRequestContactList_handler( )
    local contact_list, remove_list = GetActualContactList( client )
    triggerClientEvent( client, "onClientRequestContactListCallback", client, { contact_list = contact_list, remove_list = remove_list, status = GetStatusPhoneCallPlayer( client ) })
end
addEvent( "onClientRequestContactList", true )
addEventHandler( "onClientRequestContactList", root, onClientRequestContactList_handler )

function GetActualContactList( player )
    local contact_list = player:GetPhoneContacts()
    
    -- Очищаем удаленные контакты, если такие имеются
    local remove_list = {}
    for k, v in pairs( contact_list ) do
        if not NUMBERS.uses_numbers[ v.phone_number ] then
            table.insert( remove_list, v )
            table.remove( contact_list, k )
        end
    end
    if next( remove_list ) then
        player:SetPhoneContacts( contact_list )
    end

    return contact_list, remove_list
end