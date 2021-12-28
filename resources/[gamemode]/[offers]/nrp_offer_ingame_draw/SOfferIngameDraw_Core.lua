Extend( "SDB" )
Extend( "SPlayer" )

function ShowPlayerOfferIngameDraw( player, is_show_first )
    local is_offer_active = IsOfferActive()
    local is_offer_summing_result = IsOfferSummingResults()
    
    local remaining_time = player:GetRemainingTime()
    if is_offer_active and is_show_first and remaining_time > 0 then 
        player:SetTimestapmSession()
    end

    local is_has_ticket = player:IsHasTicket()
    if is_offer_active or (is_offer_summing_result and is_has_ticket) then
        local data =
        {
            is_offer_active = is_offer_active,
            contact     = player:IsSelectContact(),
            ticket_code = player:GenerateTickedCode(),
            remaining_time = remaining_time,
        }
        triggerClientEvent( player, "onClientShowOfferIngameDraw", resourceRoot, data, is_show_first )
    end
end

function onServerRequestIngameDraw_handler()
    local player = client or source
    if (not IsOfferActive() and not IsOfferSummingResults()) or player:GetLevel() < 3 then return end
    
    ShowPlayerOfferIngameDraw( player, source == player )
end
addEvent( "onServerRequestIngameDraw", true )
addEventHandler( "onServerRequestIngameDraw", root, onServerRequestIngameDraw_handler )

addEventHandler( "onPlayerReadyToPlay", root, onServerRequestIngameDraw_handler ) 

function onPlayerPreLogout_handler()
    if not IsOfferActive() then return end

    local remaining_time = source:GetRemainingTime()
    if remaining_time > 0 then
        source:SetRemainingTime( remaining_time ) 
    end
end
addEvent( "onPlayerPreLogout" )
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )

function onServerPlayerTryGetTicket_handler()
    if not IsOfferActive() or not isElement( client ) or client:IsHasTicket() then return end

    local remaining_time = client:GetRemainingTime()
    if remaining_time == 0 then
        client:SetRemainingTime( 0 )
        
        local ticket_code = client:GenerateTickedCode()
        client:MarkTicketCode()
        triggerClientEvent( client, "onClientPlayerTakeTicket", resourceRoot, ticket_code )
        
        -- Аналитика :-
        onGlobalDrawTakeTicket( client, ticket_code )
    end
end
addEvent( "onServerPlayerTryGetTicket", true )
addEventHandler( "onServerPlayerTryGetTicket", resourceRoot, onServerPlayerTryGetTicket_handler )

function onServerPlayerSelectedContact_handler( type_contact, contact_text )
    if not IsOfferActive() or not isElement( client ) or client:IsSelectContact() or not IsContactDataValid( type_contact, contact_text ) then return end
    
    client:MarkSelectedContact()
    onGlobalDrawContact( client, type_contact, contact_text )
end
addEvent( "onServerPlayerSelectedContact", true )
addEventHandler( "onServerPlayerSelectedContact", resourceRoot, onServerPlayerSelectedContact_handler )

function onServerPlayerTryParticipateIngameDraw_handler()
    if not IsOfferActive() or not isElement( client ) or client:GetRemainingTime() >= 0 or client:IsHasTicket() then return end

    client:SetRemainingTime( CONST_INGAME_TIME_SEC )
    client:SetTimestapmSession()
    triggerClientEvent( client, "onClientStartIngameDraw", resourceRoot, CONST_INGAME_TIME_SEC )

    -- Аналитика :-
    onGlobalDrawInparty( client )
end
addEvent( "onServerPlayerTryParticipateIngameDraw", true )
addEventHandler( "onServerPlayerTryParticipateIngameDraw", resourceRoot, onServerPlayerTryParticipateIngameDraw_handler )


if SERVER_NUMBER > 100 then
    addCommandHandler( "clear_ingame_" .. OFFER_NAME, function( player )
        for k, v in pairs( getElementsByType( "player" ) ) do
            v:SetRemainingTime( nil )
        end
        triggerClientEvent( "onClientHideIngameDrawOfferInfo", root, OFFER_NAME )

        player:setData( "start_ingame_" .. OFFER_NAME, false, false )
        player:SetPermanentData( OFFER_NAME .. "_is_select_contact", false )
        player:SetPermanentData( OFFER_NAME .. "_ticket", false )

        player:ShowInfo( "Оффер очищен" )
    end )

    addCommandHandler( "show_ingame_" .. OFFER_NAME, function( player, cmd, arg )
        ShowPlayerOfferIngameDraw( player, true )
    end )

    addCommandHandler( "set_time_ingame_" .. OFFER_NAME, function( player, cmd, arg )
        CONST_INGAME_TIME_SEC = tonumber( arg )

        player:ShowInfo( "Время в игре изменено на " .. arg .. " сек." )
    end )
end