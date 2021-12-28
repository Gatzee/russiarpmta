
CALL_LIST = {}

OUTGOING = "OUTGOING"
INCOMING = "INCOMING"

TRY_CALL_TIME = 30000

function TryCall( pSource, phone_number )
    
    local pTarget = GetPlayerByPhoneNumber( phone_number )
    if not pTarget then
        return false, "not_abonent"
    end

    for k, v in pairs( { pTarget, pSource } ) do
        local can_talk = IsNumberCanTalk( v )
        if not can_talk then
            return false, "not_abonent"
        end
    end

    local type_contact = pSource:IsPhoneExistContact( phone_number ) and "friend" or "other"
    if pSource:GetMoney() < RATE.single[ type_contact ].call then
        pSource:ShowError( "У вас недостаточно средств" )
        return false, "not_money"
    end

    return StartCall( pSource, pTarget, RATE.single[ type_contact ].call )

end

function IsNumberCanTalk( pTarget )

    if pTarget:getData( "jailed" ) then
        return false
    end
    
    if pTarget:getData( "in_race" ) then
        return false
    end

    if IsPlayerTalkingOnPhone( pTarget ) then
        return false
    end

    return true
end


function StartCall( pSource, pTarget, price )

    if CALL_LIST[ pSource ] or CALL_LIST[ pTarget ] then return end
    
    CALL_LIST[ pSource ] = createCallModel( pSource, pTarget, OUTGOING, price, -1 )
    CALL_LIST[ pTarget ] = createCallModel( pSource, pSource, INCOMING, price, -1 )

    CALL_LIST[ pSource ].try_call_timer = setTimer( function( player )
        StopCall( player, "NOT_ANSWER" )
    end, TRY_CALL_TIME, 1, pSource )
    
    addEventHandler( "onPlayerQuit", pSource, onEarlyCallReset )
    addEventHandler( "onPlayerWasted", pSource, onEarlyCallReset )

    addEventHandler( "onPlayerQuit", pTarget, onEarlyCallReset )
    addEventHandler( "onPlayerWasted", pTarget, onEarlyCallReset )
    
    triggerClientEvent( pTarget, "onClientTryPhoneCallPlayer", pSource, CALL_LIST[ pTarget ], pTarget:GetPhoneContacts() )

    return true    
end

function AcceptCall( pSource )
    if not CALL_LIST[ pSource ] then return end
    
    local call_model = CALL_LIST[ pSource ]
    if not isElement( call_model.abonent ) then
        StopCall( pSource, "not_abonent" )
        return false
    end
    
    for k, v in pairs( { pSource, call_model.abonent } ) do
        
        if isTimer( CALL_LIST[ v ].try_call_timer ) then
            killTimer( CALL_LIST[ v ].try_call_timer )
        end

        CALL_LIST[ v ].start_time = getRealTimestamp()

        removeEventHandler( "onPlayerQuit", v, onEarlyCallReset )
        removeEventHandler( "onPlayerWasted", v, onEarlyCallReset )

        addEventHandler( "onPlayerQuit", v, onEarlyCallReset )
        addEventHandler( "onPlayerWasted", v, onEarlyCallReset )

        setElementData( v, "phone.call", true, false )
        v:SetPrivateData( "phone.call", true )
    end

    triggerClientEvent( { pSource, call_model.abonent }, "onClientAcceptPhoneCall", call_model.abonent, CALL_LIST[ call_model.abonent ], CALL_LIST[ pSource ] )

    return true
end

function IgnoreCall( pSource )
    if not CALL_LIST[ pSource ] then return end
    StopCall( pSource, "NOT_ANSWER" )
    return true
end

function StopCall( pPlayer, reason )
    
    if not CALL_LIST[ pPlayer ] then return end

    local call_model = table.copy( CALL_LIST[ pPlayer ] )
    CALL_LIST[ pPlayer ] = nil

    local c_reason = reason
    if isTimer( call_model.timer ) then
        killTimer( call_model.timer )
        reason = nil
    end

    if isTimer( call_model.try_call_timer ) then
        killTimer( call_model.try_call_timer )
        c_reason = "INCOMING"
        reason = nil
    end

    if call_model.type_call == OUTGOING and call_model.start_time ~= -1 then
        local time_call = getRealTimestamp() - call_model.start_time
        local price = math.ceil( time_call * call_model.price_call )
        pPlayer:TakeMoney( price, "phone_call" )

        -- Аналитика :- Игрок завершил звонок
        triggerEvent( "onPlayerPhoneCall", pPlayer, price, time_call, "soft", 1, call_model.abonent )

    end

    if isElement( call_model.abonent ) then
        StopCall( call_model.abonent, c_reason )
    end
    
    if isElement( pPlayer ) then
        removeEventHandler( "onPlayerQuit", pPlayer, onEarlyCallReset )
        removeEventHandler( "onPlayerWasted", pPlayer, onEarlyCallReset )

        setElementData( pPlayer, "phone.call", nil, false )
        pPlayer:SetPrivateData( "phone.call", nil )
        
        if reason == "NOT_ANSWER" and call_model.type_call ~= "INCOMING" then
            call_model.type_call = "NOT_ANSWER"
        elseif reason == "INCOMING" then
            call_model.type_call = "INCOMING"
        end

        triggerClientEvent( pPlayer, "onClientEndPhoneCall", pPlayer, call_model )
        triggerEvent( "onPlayerVoiceStart", pPlayer )
    end

end

-- Игрок уже разговаривает?
function IsPlayerTalkingOnPhone( pPlayer )
    if CALL_LIST[ pPlayer ] then
        return true
    end
    return false
end

-- Если вдруг игрок вышел досрочно останавливаем вызов
function onEarlyCallReset( pPlayer, reason )
    local player = source or pPlayer
    if CALL_LIST[ player ] then
        local call_model = CALL_LIST[ player ]
        StopCall( player, reason or "player_leave" )        
    end
end

function createCallModel( source_call, abonent, type_call, price_call, start_time )
    
    local callModel = 
    {
        phone_number = abonent:GetPhoneNumber(),
        abonent = abonent,
        type_call = type_call,
        price_call = price_call,
        start_time = start_time,
    }

    if type_call == OUTGOING then
        local timer = nil
        timer = setTimer( function( source_call, abonent )
            local callModel = CALL_LIST[ source_call ]
            if isElement( source_call ) and callModel and callModel.start_time > 0 then
                
                local player_money = source_call:GetMoney()
                local time_call = getRealTimestamp() - callModel.start_time
                
                local price = math.ceil( time_call * callModel.price_call )
                -- Если у игрока недостаточно средств для оплаты следующей секунды, то сбрасываем вызов 
                if price + callModel.price_call > player_money then
                    onEarlyCallReset( source_call, "not_money" )
                end
            elseif not callModel then
                -- Если по какой-то мистической причине вызывающий игрок пропал чистим данные за ним и абонентом, которому звонил
                if isTimer( timer ) then
                    killTimer( timer )
                end
                if CALL_LIST[ abonent ] and CALL_LIST[ abonent ].abonent == source_call then
                    StopCall( abonent )
                end
            end

        end, 1000, 0, source_call, abonent )
        
        callModel.timer = timer

    end

    return callModel

end

--[[ 
Статус коды:
    0: Игрок свободен
    1: Игрок звонит
    2: Игроку звонят
    3: Игрок разговаривает
]]

function GetStatusPhoneCallPlayer( player )
    local status = { code = 0, data = CALL_LIST[ player ] }
    if CALL_LIST[ player ] and CALL_LIST[ player ].start_time == -1 and CALL_LIST[ player ].type_call == OUTGOING then
        status.code = 1
    elseif CALL_LIST[ player ] and CALL_LIST[ player ].start_time == -1 and CALL_LIST[ player ].type_call == INCOMING then
        status.code = 2
    elseif CALL_LIST[ player ] then
        status.code = 3
    end
    return status
end

function GetAbonentByPlayer( player )
    if CALL_LIST[ player ] then
        return CALL_LIST[  player ].abonent
    end
    return false
end

addEventHandler( "onResourceStart", resourceRoot, function()
    local players = getElementsByType( "player" )
    for k, v in pairs( players ) do
        v:SetPrivateData( "phone.call", false )
        v:setData( "phone.call", nil, false )
    end
end )