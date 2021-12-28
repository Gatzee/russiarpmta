local LOST_BAGS = {}

-- Попытка вызова ППС
function TryCallPPS( player )
    local lobby_data = GetLobbyDataByPlayer( player )
    if not lobby_data then return end

    local timestamp = getRealTimestamp()
    local diff = timestamp - (lobby_data.pps_call_timeout or 0)
    if diff < 0 then
        player:ShowError( "ППС уже вызвано, следующий вызов можно будет сделать через " .. math.abs( diff ) .. plural( math.abs( diff ), " секунда", " секунды", " секунд" ) )
        return false
    end

    lobby_data.pps_call_timeout = timestamp + PPS_CALL_TIMEOUT
    lobby_data.pps_accepts = {}

    local target_players = GetNearPPSPlayers( lobby_data, PPS_CALL_DISTANCE )
    if #target_players > 0 then
        triggerClientEvent( target_players, "OnClientReceivePhoneNotification", root, 
	    {
	    	title   = "Инкассатор",
	    	msg     = "Произошло нападание на инкассаторов. Вам необходимо предотвратить угрозу",
	    	special = "incasator_pps_call",
	    	args    = { id = lobby_data.lobby_id, trigger = "onServerPlayerAcceptPPSCall", },
        } )
    end
    
    player:ShowInfo( "Вы вызвали ППС" )

    -- Аналитика: Инкассатор вызвал сотрудников ППС
    onIncasatorJobCallPolice( player, lobby_data.lobby_id )
end

function onServerPPSArrivedAtPoint_handler( lobby_id )
    if not PPS_FACTIONS[ client:GetFaction() ] or not client:IsOnFactionDuty( ) then return end

    local lobby_data = GetLobbyDataById( lobby_id )
    if not lobby_data then return end

    local timestamp = getRealTimestamp()
    local diff = timestamp - lobby_data.pps_call_timeout
    if diff > 0 then return end
    
    triggerEvent( "onServerCompleteShiftPlan", client, client, "shift_call", _, 0 )
end
addEvent( "onServerPPSArrivedAtPoint", true )
addEventHandler( "onServerPPSArrivedAtPoint", resourceRoot, onServerPPSArrivedAtPoint_handler )

-- Удаление уведомления у ППС
function RemovePPSNotifications( lobby_data )
    local target_players = GetNearPPSPlayers( lobby_data, 99999 )
    if not target_players or #target_players == 0 then return end

    triggerClientEvent( target_players, "RC:NotificationExpired", root, lobby_data.lobby_id )
end

-- Удаление маркеров у ППС, созданных после принятия вызова
function HideCallPPS( lobby_data )
    if lobby_data.pps_accepts and #lobby_data.pps_accepts > 0 then
        local target_players = {}
        for k, v in pairs( lobby_data.pps_accepts ) do
            if isElement( v ) then
                table.insert( target_players, v )
            end
        end
		triggerClientEvent( target_players, "onClientHideAtackedIncasators", resourceRoot, lobby_data.lobby_id )
	end
end

-- Получить игроков фракции ППС в заданной дистанции
function GetNearPPSPlayers( lobby_data, distance )
    if not isElement( lobby_data.job_vehicle ) then return end

    local target_players = {}
    local vehicle_position = lobby_data.job_vehicle.position
    for k, v in pairs( GetPlayersInGame() ) do
        local player_faction = v:GetFaction()
        if PPS_FACTIONS[ player_faction ] and v:IsOnFactionDuty() and getDistanceBetweenPoints3D( vehicle_position, v.position ) <= distance then
            table.insert( target_players, v )
        end
    end
    return target_players
end

-- Принятие вызова ППС-никами от инкассаторов
function onServerPlayerAcceptPPSCall_handler( lobby_id )
    local player = client
    if not isElement( player ) then return end

    local lobby_data = GetLobbyDataById( lobby_id )
    if not lobby_data then 
        player:ShowError( "Cотрудники инкасации отбились от нападения" )
        return false 
    end

    if #lobby_data.pps_accepts == PPS_MAX_COUNT_ACCEPT then
        player:ShowError( "Наряд уже выехал на помощь сотрудникам инкасации" )
        return false
    end

    table.insert( lobby_data.pps_accepts, player )

    if #lobby_data.pps_accepts == PPS_MAX_COUNT_ACCEPT then
        RemovePPSNotifications( lobby_data )
    end
    
    triggerClientEvent( player, "onClientShowAtackedIncasators", resourceRoot, lobby_data.lobby_id, lobby_data.pps_call_timeout, lobby_data.job_vehicle )

    -- Аналитика: Сотрудник ППС принял вызов
    onIncasatorJobPoliceAccepted( player, lobby_id )
end
addEvent( "onServerPlayerAcceptPPSCall", true )
addEventHandler( "onServerPlayerAcceptPPSCall", root, onServerPlayerAcceptPPSCall_handler )


-- Охранник умер с мешком
function onIncasatorGuardWasted()
    local lobby_id_bug = GetPlayerBag( source )
    if lobby_id_bug then
        source:setData( "incasator_has_bag", nil, false )

        local bag_id = source:GetID()
        LOST_BAGS[ bag_id ] = {}
        LOST_BAGS[ bag_id ].timestamp = getRealTimestamp()
        LOST_BAGS[ bag_id ].lobby_id = lobby_id_bug

        triggerClientEvent( GetPlayersInGame(), "onClientPlayerLostBagMoney", resourceRoot, source, bag_id )

        onIncasatorJobNotProtect( source, lobby_id_bug )
    end
end
addEventHandler( "onPlayerWasted", root, onIncasatorGuardWasted )

-- Поппытка подобрать мешок с деньгами
function onServerPlayerTryTakeLostBag_handler( bag_id )
    local player = client
    if not isElement( player ) then return end

    local timestamp = getRealTimestamp()
    if not isElement( player ) or player.dead or not LOST_BAGS[ bag_id ] or (timestamp - LOST_BAGS[ bag_id ].timestamp > BAG_MAX_TIME) or player:GetCoopJobRole() == JOB_ROLE_DRIVER then return end
    
    if player:IsInFaction() then
        player:ShowInfo( "Предмет принадлежит банку" )
        return false
    end

    local lobby_data = GetLobbyDataById( LOST_BAGS[ bag_id ].lobby_id )
    if player:GetJobClass() == JOB_CLASS_INKASSATOR and player:GetCoopJobRole() == JOB_ROLE_GUARD and player:getData( "onshift" ) then
        
        local incasator_lobby_data = GetLobbyDataByPlayer( player )
        if LOST_BAGS[ bag_id ].lobby_id ~= incasator_lobby_data.lobby_id then
            return false
        end

        if GetPlayerBag( player ) then
            player:ShowInfo( "Ты не можешь взять сразу 2 мешка" )
            return false
        end

        GivePlayerBag( player, lobby_data )
        triggerClientEvent( player, "onClientCreateLoadingPoint", resourceRoot, lobby_data.job_vehicle )
    else
        
        player:InventoryAddItem( IN_BAG_MONEY, nil, 1 )
        player:ShowInfo( "Вы подобрали мешок с деньгами" )

        if lobby_data then
            onGuardLostBag( player, lobby_data )
        end
    end

    LOST_BAGS[ bag_id ] = nil
    triggerClientEvent( GetPlayersInGame(), "onClientDestroyLostBag", resourceRoot, bag_id )
end
addEvent( "onServerPlayerTryTakeLostBag", true )
addEventHandler( "onServerPlayerTryTakeLostBag", resourceRoot, onServerPlayerTryTakeLostBag_handler )

-- Обналичивание
function onServerTryCashOutMoney_handler()
	local player = client
	if not isElement( player ) then return end
	
	local bags_count = player:InventoryGetItemCount( IN_BAG_MONEY )
	if bags_count == 0 then
		player:ShowError( "У тебя нет мешков для обналичивания" )
		return false
	end

	player:InventoryRemoveItem( IN_BAG_MONEY )

	local bags_cost  = bags_count * GetIncasatorBagMoneyValue()
	player:GiveMoney( bags_cost, "take_money", "cash_out" )
	player:ShowInfo( "Банда обналичила для тебя " .. bags_count .. plural( bags_count, "мешок", "мешка", "мешков" ) .. " на " .. bags_cost .. " рублей" )
end
addEvent( "onServerTryCashOutMoney", true )
addEventHandler( "onServerTryCashOutMoney", resourceRoot, onServerTryCashOutMoney_handler )

-- Удаление мешков с земли
setTimer( function()
    local timestamp = getRealTimestamp()
    for k, v in pairs( LOST_BAGS ) do
        if timestamp - v.timestamp > BAG_MAX_TIME then
            LOST_BAGS[ k ] = nil
        end
    end
end, 60 * 1000, 0 )