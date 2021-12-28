
local STATIC_GAMES_LOBBY = {
    [ CASINO_GAME_CLASSIC_ROULETTE ] = true,
    [ CASINO_GAME_CLASSIC_ROULETTE_VIP ] = true,
    [ CASINO_GAME_BLACK_JACK ] = true,
}

function onServerCreateLobbyRequest_handler( conf )
    if not conf or not isElement( client ) or client.dead or GetPlayerLobbyID( client ) then return end

    local casino_id = client:getData( "casino_id" )
    if not casino_id or not client:CanPlayInCasino( conf.game ) then
        return false
    end

    local lobby_name_len = utf8.len( conf.name or "" )
    if not conf.name or lobby_name_len < 5 or lobby_name_len > 30 then
        client:ShowError( "Не указано имя!" )
        return
    end

    if not conf.game or not CASINO_GAMES_NAMES[ conf.game ] then
        client:ShowError( "Не указан тип игры!" )
        return
    end

    local player_count_found = false
    for k, v in pairs( COUNT_PLAYER_GAME_VARIANTS[ conf.game ] or COUNT_PLAYER_GAME_VARIANTS.default ) do
        if v == conf.players_count_required then
            player_count_found = true
            break
        end
    end

    if not player_count_found then
        client:ShowError( "Не указано количество игроков!" )
        return
    end

    local bet_found = false
    for k, v in pairs( BET_GAME_VARIANTS[ casino_id ][ conf.game ] or BET_GAME_VARIANTS[ casino_id ].default ) do
        if v == conf.bet then
            bet_found = true
            break
        end
    end

    if not bet_found then
        client:ShowError( "Не указан размер ставки!" )
        return
    end

    conf.bet_hard = conf.game == CASINO_GAME_DICE_VIP

    local iMoney = conf.bet_hard and client:GetDonate() or client:GetMoney()
    if iMoney < conf.bet then
        client:ShowError( "Недостаточно денег!" )
        return
    end
    
    if not CheckLobbyData( client, conf ) then
        return false 
    end

    conf.owner = client
    conf.casino_id = casino_id

    local lobby = LobbyCreate( conf )
    LobbyCall( lobby.id, "join", client )
    
    triggerClientEvent( client, "onClientLobbySuccessCreated", resourceRoot, {
        lobby_data = GetAvailableLobbyByGameId( casino_id, conf.game ), 
        current_lobby = GetPlayerLobbyID( client )
    } )
end
addEvent( "onServerCreateLobbyRequest", true )
addEventHandler( "onServerCreateLobbyRequest", resourceRoot, onServerCreateLobbyRequest_handler )

function CheckLobbyData( source, conf )
	if conf.players_count_required < ( COUNT_PLAYER_GAME_VARIANTS[ conf.game ] or COUNT_PLAYER_GAME_VARIANTS.default )[ 1 ] or conf.bet > 150000 then
        local id = source:GetID()
		for i, player in pairs( GetPlayersInGame() ) do
			if player:IsAdmin() then outputChatBox( "#22dd22[CASINO] #ffffffИгрок #dd2222"..id.." #ffffff пытается создать поддельное лобби для передачи валюты", player, 255, 255, 255, true ) end
        end

        source:ShowError( "Попався, голубчик" )
		return false
    end
    
    return true
end

function onLeaveLobbyRequest_handler( player )
    local player = isElement( player ) and player or client or source
    
    local lobby_id = GetPlayerLobbyID( player )
    if not lobby_id then return end

    local lobby = table.copy( LOBBY_LIST[ lobby_id ] )
    LobbyCall( lobby_id, "leave", player )

    triggerEvent( "onServerPlayerRequestLobbyList", resourceRoot, lobby.game, player )
end
addEvent( "onLeaveLobbyRequest", true )
addEventHandler( "onLeaveLobbyRequest", resourceRoot, onLeaveLobbyRequest_handler )

function onLeaveLobbyWaitingRequest_handler( player )
    local player = isElement( player ) and player or client or source
    
    local lobby_id = GetPlayerLobbyID( player )
    if not lobby_id then return end
    
    if LobbyGet( lobby_id, "state" ) == CASINO_STATE_WAITING then
        local lobby = table.copy( LOBBY_LIST[ lobby_id ] )
        LobbyCall( lobby_id, "leave", player )
        triggerEvent( "onServerPlayerRequestLobbyList", resourceRoot, lobby.game, player )
    end
end
addEvent( "onLeaveLobbyWaitingRequest", true )
addEventHandler( "onLeaveLobbyWaitingRequest", resourceRoot, onLeaveLobbyWaitingRequest_handler )

function onServerJoinLobbyRequest_handler( lobby_id )
    if not lobby_id or not isElement( client ) or PLAYERS_LOBBY[ client ] or GetPlayerLobbyID( client ) then return end

    local casino_id = client:getData( "casino_id" )
    if not casino_id then return end


    local lobby_game_id, lobby_state = LobbyGet( lobby_id, "game" ), LobbyGet( lobby_id, "state" )    
    if lobby_state == CASINO_STATE_WAITING or (lobby_state == CASINO_STATE_PLAYING and STATIC_GAMES_LOBBY[ lobby_game_id ]) then
        
        if CASINO_PREMIUM_GAMES[ lobby_game_id ] and not client:IsPremiumActive() then
            client:ShowError( "Для входа требуется премиум аккаунт" )
            return false
        end

        local player_balance = HARD_GAMES[ lobby_game_id ] and client:GetDonate() or client:GetMoney()
        local min_bet_condition = ((BET_GAME_VARIANTS[ casino_id ][ lobby_game_id ] or BET_GAME_VARIANTS[ casino_id ].default)[ 1 ] * 2) <  player_balance
        if not min_bet_condition then
            client:ShowError( "Минимальная сумма должна быть не меньше х2 от минимальной ставки!" )
            return false
        end

        onLeaveLobbyRequest_handler( client )
        LobbyCall( lobby_id, "join", client )

        triggerClientEvent( client, "onPlayerRequestLobbyList_callback", resourceRoot, { lobby_data = GetAvailableLobbyByGameId( casino_id, game_id ), current_lobby = GetPlayerLobbyID( player ) } )
    end
end
addEvent( "onServerJoinLobbyRequest", true )
addEventHandler( "onServerJoinLobbyRequest", resourceRoot, onServerJoinLobbyRequest_handler )

function onServerJoinFreeLobbyRequest_handler( conf )
    local player = client
    local casino_id = player:getData( "casino_id" )
    if not conf or not conf.game_id or not isElement( player ) or not casino_id or GetPlayerLobbyID( player ) then return end

    if CASINO_PREMIUM_GAMES[ conf.game_id ] and not player:IsPremiumActive() then
        player:ShowError( "Для входа требуется премиум аккаунт" )
        return false
    end

    local player_balance = HARD_GAMES[ conf.game_id ] and player:GetDonate() or player:GetMoney()
    local min_bet_condition = ((BET_GAME_VARIANTS[ casino_id ][ conf.game_id ] or BET_GAME_VARIANTS[ casino_id ].default)[ 1 ] * 2) <  player_balance
    if not min_bet_condition then
        player:ShowError( "Минимальная сумма должна быть не меньше х2 от минимальной ставки!" )
        return false
    end

    for k, v in pairs( LOBBY_LIST ) do
        if v.game == conf.game_id and v.casino_id == casino_id and not v.invisiblethen then
            local lobby_game, lobby_state = LobbyGet( k, "game" ), LobbyGet( k, "state" )
            if lobby_state == CASINO_STATE_WAITING or (lobby_state == CASINO_STATE_PLAYING and STATIC_GAMES_LOBBY[ lobby_game ]) then
                onLeaveLobbyRequest_handler( player )
                LobbyCall( k, "join", player )
                return
            end
        end
    end

    player:ErrorWindow( "Свободное лобби не найдено." .. (STATIC_GAMES_LOBBY[ lobby_game ] and "" or "Вы можете создать новое!") )
end
addEvent( "onServerJoinFreeLobbyRequest", true )
addEventHandler( "onServerJoinFreeLobbyRequest", resourceRoot, onServerJoinFreeLobbyRequest_handler )