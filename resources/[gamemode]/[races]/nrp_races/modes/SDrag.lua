
local ignored_vehicles_list = 
{
	[ 468 ] = true, -- Железный конь
	[ 471 ] = true, -- Квадрацикл
	[ 520 ] = true, -- Гидра
}

WAITING_DRAG_LOBBY = {}

function onServerTryStartDragRacing_handler( data )
    if not isElement( client ) or type( data ) ~= "table" or not DRAG_RATES[ data.rate_id ] or WAITING_DRAG_LOBBY[ client ] or isPedDead( client ) then return end
    -------------------------------------------------------------
    -- Хост, Соперник 1
    -------------------------------------------------------------
    local player_vehicle = client.vehicle
    if not CheckJoin( client, player_vehicle, DRAG_RATES[ data.rate_id ] ) then return end
    
    local class_race = player_vehicle:GetTier()
    -------------------------------------------------------------
    -- Соперник 2
    -------------------------------------------------------------
    local rival_player = GetPlayerFromNickName( data.rival_nickname )
    if not rival_player or client == rival_player then
        client:ShowError( "Противник не найден" )
        return
    end

    local can_join_rival, rival_error = rival_player:CanJoinToEvent({ event_type = "race" })
    if not can_join_rival then
        client:ShowError( "Противник не может принять участие в гонке" )
        return
    end

    local rival_vehicle = rival_player.vehicle
    if not isElement( rival_vehicle ) then
        client:ShowError( "Соперник должен сидеть в машине" )
        return
    end

    if not IsPedDriver( rival_player ) or not rival_player:OwnsVehicle( rival_vehicle ) then
        client:ShowError( "Противник должен быть за рулем своей машины" )
        return
    end

    if rival_vehicle:GetTier() ~= class_race or not RACE_VEHICLE_CLASSES_NAMES[ class_race ] then
        client:ShowError( "У противника должна быть машина такого же класса как и у Вас" )
        return
    end
    
    if not IsAvailableVehicleToDrag( rival_player, rival_vehicle ) then
        client:ShowError( "У противника нет подходящий машины для гонки" )
        return
    end

    if IsVehicleHasOccuppants( rival_player, rival_vehicle ) then
        client:ShowError( "У противника лишний груз в машине" )
        return
    end

    if rival_player:GetMoney() < DRAG_RATES[ data.rate_id ] then
        client:ShowError( "У противника недостаточно средств для заезда" )
        return
    end
    
    local lobby = CreateRaceLobby({ 
        track = RACE_TYPES_DATA[ RACE_TYPE_DRAG ].maps[ 1 ], 
        bet   = DRAG_RATES[ data.rate_id ],
        rival = rival_player,
        class = class_race,
        host  = client,
    })
    lobby:PlayerJoin( client, player_vehicle, true )
    WAITING_DRAG_LOBBY[ client ] = lobby

	triggerClientEvent( rival_player, "OnClientReceivePhoneNotification", root, {
		title = RACE_TYPES_DATA[ RACE_TYPE_DRAG ].name,
		msg = "Игрок: " .. client:GetNickName() .. "\nКласс: " .. RACE_VEHICLE_CLASSES_NAMES[ class_race ] .. "\nРазмер ставки: " .. DRAG_RATES[ data.rate_id ] .. "р.",
		special = "race_drag_created",
		args = { id = lobby.id },
    } )
    
    for k, v in pairs( { client, rival_player } ) do
        addEventHandler( "onPlayerQuit", v, onDragPlayerLeaveDragLobby )
        addEventHandler( "onPlayerWasted", v, onDragPlayerLeaveDragLobby )
    end
    addEventHandler( "onPlayerVehicleExit", client, onDragPlayerLeaveDragLobby )

    lobby.destroy_timer = setTimer( function( player )
        local lobby = RACE_LOBBIES[ GetPlayerLobby( player ) ]
        triggerClientEvent( lobby.rival, "RC:NotificationExpired", resourceRoot, lobby.id )
        
        lobby:destroy( true )
    end, DRAG_DESTOY_TIME * 1000, 1, client )
    
    triggerClientEvent( client, "RC:OnClientCreateDragLobby", resourceRoot, getRealTimestamp() )

    client:SetPermanentData( "drag_call_count", (client:GetPermanentData( "drag_call_count" ) or 0) + 1)
end
addEvent( "RC:onServerTryStartDragRacing", true )
addEventHandler( "RC:onServerTryStartDragRacing", resourceRoot, onServerTryStartDragRacing_handler )

function onDragPlayerLeaveDragLobby()
    for k, v in pairs( WAITING_DRAG_LOBBY ) do
        if k == source then
            if isElement( v.rival ) then
                v.rival:ShowError( "Противник отказался от заезда" )
            end
            if isElement( v.host ) then
                triggerClientEvent( v.host, "RC:OnClientIgnoredlDragLobby", resourceRoot )
            end
            RACE_LOBBIES[ GetPlayerLobby( v.host ) ]:destroy( true )
            break
        elseif v.rival == source then
            v.host:ShowError( "Противник отказался от заезда" )
            triggerClientEvent( v.host, "RC:OnClientIgnoredlDragLobby", resourceRoot )
            RACE_LOBBIES[ GetPlayerLobby( v.host ) ]:destroy( true )
            break
        end
    end
end

function OnPlayerAcceptedDragInvitation( state, iLobby )
	local pLobby = RACE_LOBBIES[ iLobby ]
    if not pLobby or pLobby.host == client then return end
    
    local player_vehicle = client.vehicle
    if not CheckJoin( client, player_vehicle, pLobby.bet ) then return end

    if player_vehicle:GetTier() ~= pLobby.class then 
        client:ShowError( "У Вас должна быть машина " .. RACE_VEHICLE_CLASSES_NAMES[ pLobby.class ] .. " класса" )
        return 
    end

    if isTimer( pLobby.destroy_timer ) then
        killTimer( pLobby.destroy_timer )
    end

    local is_players_has_money = true
    for k, v in pairs( { pLobby.rival, pLobby.host } ) do
        if v:GetMoney() < pLobby.bet then
            is_players_has_money = false
            break
        end
    end

    if state and is_players_has_money and isElement( pLobby.rival ) and isElement( pLobby.host ) then
        for k, v in pairs( { pLobby.rival, pLobby.host } ) do
            ResetPlayerDragEventHandlers( v )
            v:setPosition( v:getPosition() )
        
            if v:getData( "phone.call" ) then
                triggerEvent( "onServerEndPhoneCall", v, v )
            end

            v:TakeMoney( pLobby.bet, "drag_bet")
            v:SetPermanentData( "drag_count", (v:GetPermanentData( "drag_count" ) or 0) + 1)
        end
        client:SetPermanentData( "drag_take_count", (client:GetPermanentData( "drag_take_count" ) or 0) + 1)
        
        pLobby:PlayerJoin( client, player_vehicle, false )
        pLobby:SetState( LOBBY_STATE_PROGRESS )
        WAITING_DRAG_LOBBY[ pLobby.host ] = nil
    else
        if isElement( pLobby.host ) then
            pLobby.host:ShowError( "Противник отказался от заезда" )
            triggerClientEvent( pLobby.host, "RC:OnClientIgnoredlDragLobby", resourceRoot )
        end

        local lobby = RACE_LOBBIES[ GetPlayerLobby( pLobby.host ) ]
        lobby:destroy( true )
    end
end
addEvent( "RC:OnPlayerAcceptedDragInvitation", true )
addEventHandler( "RC:OnPlayerAcceptedDragInvitation", root, OnPlayerAcceptedDragInvitation )

function ResetPlayerDragEventHandlers( player )
    if isElement( player ) then 
        removeEventHandler( "onPlayerQuit", player, onDragPlayerLeaveDragLobby )
        removeEventHandler( "onPlayerWasted", player, onDragPlayerLeaveDragLobby )
        removeEventHandler( "onPlayerVehicleExit", player, onDragPlayerLeaveDragLobby )
    end
end

function IsAvailableVehicleToDrag( player, vehicle )
    if not isElement( vehicle ) or not VEHICLE_CONFIG[ vehicle.model ] or ignored_vehicles_list[ vehicle.model ] or vehicle:GetBlocked() or not IsNormalVehicle( player, vehicle ) then 
        return false 
    end
    return true
end

function IsNormalVehicle( player, vehicle )
    if not vehicle or not isElement( vehicle ) then return end
    if player:getData( "quest_vehicle" ) == vehicle then return end
    if getElementDimension( vehicle ) ~= 0 then return end
    local faction = vehicle:GetFaction()
	if faction ~= 0 then return end
	if vehicle:GetSpecialType() then return end

	return true
end

function IsVehicleHasOccuppants( player, vehicle )
    local count_occupants = 0
    for k, v in pairs( getVehicleOccupants( vehicle ) ) do
        count_occupants = count_occupants + 1
    end
    return count_occupants ~= 1
end

function IsPedDriver( ped )
    local target_vehicle = ped.vehicle
    if not target_vehicle then return false end
    return getPedOccupiedVehicleSeat( ped ) == 0
end


function CheckJoin( player, player_vehicle, bet )
    if not isElement( player_vehicle ) then
        player:ShowError( "Вы должны быть в машине для начала заезда" )
        return false
    end

    if not IsAvailableVehicleToDrag( player, player_vehicle ) then
        player:ShowError( "Данный транспорт не подходит для гонки" )
        return false
    end

    if not IsPedDriver( player ) or not player:OwnsVehicle( player_vehicle ) then
        player:ShowError( "Хорошо бы быть за рулем своей машины для гонки" )
        return false
    end

    if IsVehicleHasOccuppants( player, player_vehicle ) then
        player:ShowError( "У Вас лишний груз в машине" )
        return false
    end
    
    if player:GetMoney() < bet then
        player:ShowError( "У Вас не достаточно средств для начал гонки" )
        return false
    end

    local can_join, msg_error = player:CanJoinToEvent({ event_type = "race" })
    if not can_join then
        player:ShowError( msg_error )
        return false
    end
    return true
end

function GetPlayerFromNickName( nickname )
    local players = GetPlayersInGame()
    for k, v in pairs( players ) do
        if v:GetNickName() == nickname then
            return v
        end
    end
    return false
end

function onServerPlayerWantOpenDragRace_handler( data )
    local player_stats = GetPlayerRecords( client )
	triggerClientEvent( client, "RC:onClientShowLobbyCreateUI", client, true, player_stats, RECORDS_DATA, SEASON_NUMBER, SEASON_END, data ) 
end
addEvent( "RC:onServerPlayerWantOpenDragRace", true )
addEventHandler( "RC:onServerPlayerWantOpenDragRace", root, onServerPlayerWantOpenDragRace_handler )
