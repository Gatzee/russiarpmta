loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )

bModulesLoaded = false

ROOMS = { }

-- Позиции игроков в комнатах
ROOMS_POSITIONS = 
{
    [ CASINO_THREE_AXE ] =
    {
        Vector3( -86.994, -473.728, 913.977 ),
        Vector3( -88.329, -471.815, 913.977 ),
        Vector3( -88.258, -469.516, 913.977 ),
        Vector3( -86.913, -468.408, 913.977 ),
        Vector3( -85.699, -469.821, 913.977 ),
        Vector3( -85.729, -472.192, 913.977 ),
    },
    [ CASINO_MOSCOW ] = 
    {
        Vector3( 2397.4708, -1285.0321, 2794.8085 ),
        Vector3( 2397.4708, -1286.3491, 2794.8085 ),
        Vector3( 2399.1694, -1287.3469, 2794.8085 ),
        Vector3( 2400.8966, -1286.2017, 2794.8085 ),
        Vector3( 2400.8966, -1284.7803, 2794.8085 ),
        Vector3( 2399.0991, -1283.9735, 2794.8085 ),
    }
}

-- Центр комнаты - точка взгляда
LOOKAT = 
{
    [ CASINO_THREE_AXE ] = Vector3( -87.009, -470.814, 913.977 ),
    [ CASINO_MOSCOW ] = Vector3( 2399.106, -1285.647, 2795.639 ),
}

POSITION_CONVERT = {
    [ 1 ] = 1,
    [ 2 ] = 3,
    [ 3 ] = 5,
    [ 4 ] = 2,
    [ 5 ] = 4,
    [ 6 ] = 6,
}

COMMISION_PERCENT = 
{
    soft = 
    {
        [2] = 0.03,
        [3] = 0.05,
        [4] = 0.06,
        [6] = 0.1,
    },

    hard = 
    {
        [2] = 0.05
    }
}

function onCasinoLobbyJoin_handler( lobby_id, lobby_conf )
    if not bModulesLoaded then
        Extend( "SPlayer" )
        Extend( "SInterior" )
        Extend( "SCasino" )
        
        bModulesLoaded = true
    end

    if not lobby_conf or lobby_conf.game ~= CASINO_GAME_ROULETTE then return end
    local player = client or source

    -- TEST
    --lobby_conf.players_count_required = 3

    local players_count = #lobby_conf.players_list
    local max_players_count = lobby_conf.players_count_required

    local function leave( text )
        if text then player:ErrorWindow( text ) end
        LobbyCall( lobby_id, "leave", player, false, true ) 
    end

    if lobby_conf.state and lobby_conf.state ~= CASINO_STATE_WAITING then
        return leave( "В этой комнате уже играют!" )
    end

    if players_count > max_players_count then
        return leave( "Все места уже заняты!" )
    end

    local money = lobby_conf.bet_hard and player:GetDonate() or player:GetMoney()
    if money < lobby_conf.bet then
        return leave( "Недостаточно средств для ставки!" )
    end

    if lobby_conf.bet_hard then
        player:TakeDonate( lobby_conf.bet, "casino", "roulette_participate" )
    else
        player:TakeMoney( lobby_conf.bet, "casino", "roulette_participate" )
    end

    player:SetPrivateData( "in_casino", true )

    local player_conf = {
        position    = players_count,
        bet         = lobby_conf.bet,
        reward_sum  = 0,
        state       = CASINO_PLAYER_STATE_WAITING,
        start_time  = getRealTimestamp(),
    }

    if not ROOMS[ lobby_id ] then 
        ROOMS[ lobby_id ] = {
            players = { 
                [ player ] = player_conf
            },
            total_count = max_players_count,
            bet = lobby_conf.bet,
            bet_hard = lobby_conf.bet_hard,
            game = lobby_conf.game,
            casino_id = lobby_conf.casino_id,
            casino_name = lobby_conf.casino_name,
            unic_game_id = lobby_conf.unic_game_id,
            owner = lobby_conf.owner,
            start_time = getRealTimestamp(),
        }
        LobbySet( lobby_id, "state", CASINO_STATE_WAITING )
    else
        ROOMS[ lobby_id ].players[ player ] = player_conf
    end

    -- Если количество игроков сходится, то начинаем
    if players_count == max_players_count then

        local n = 0
        for i, v in pairs( ROOMS[ lobby_id ].players ) do
            n = n + 1
            v.position = POSITION_CONVERT[ n ]

            onCasinoRusRouletteStart( i, ROOMS[ lobby_id ].casino_name, ROOMS[ lobby_id ].unic_game_id, ROOMS[ lobby_id ].game )
        end
        
        ROOMS[ lobby_id ].started = true
        StartGame( lobby_id )
    end

    addEventHandler("onPlayerWasted", player, OnPlayerWasted_handler)
end
addEvent( "onCasinoLobbyJoin" )
addEventHandler( "onCasinoLobbyJoin", root, onCasinoLobbyJoin_handler )

function StartGame( lobby_id )
    LobbySet( lobby_id, "invisible", true )
    LobbySet( lobby_id, "state", CASINO_STATE_PLAYING )
	local players_list = GetPlayersList( lobby_id )
    triggerClientEvent( players_list, "onClientShowUICasinoGame", root, false )

    triggerEvent( "onCasinoGameRouletteStart", root, lobby_id )
    triggerEvent( "onCasinoPlayersGame", root, CASINO_GAME_ROULETTE, players_list, true )
end

function onCasinoLobbyLeave_handler( lobby_id, lobby_conf, from_destroy, ignore_refund, leave_reason )
    if lobby_conf.game ~= CASINO_GAME_ROULETTE then return end
    local player = client or source  

    triggerEvent( "onRouletteTableLeaveRequest", player, lobby_id, from_destroy, leave_reason )

    local is_restarting = lobby_conf.restarting

    if lobby_conf.state ~= CASINO_STATE_WAITING then
        triggerClientEvent( player, "OnCasinoGameRouletteFinished", resourceRoot, is_restarting )
    end

    if (is_restarting or lobby_conf.state == CASINO_STATE_WAITING) and not ignore_refund then
        if lobby_conf.bet_hard then
            player:GiveDonate( lobby_conf.bet, "casino", "roulette_restart_refund" )
        else
            player:GiveMoney( lobby_conf.bet, "casino", "roulette_restart_refund" )
        end
    end

    if ROOMS[ lobby_id ] then
        ROOMS[ lobby_id ].players[ player ] = nil

        if not next( ROOMS[ lobby_id ].players ) then
            StopTurnTimer( lobby_id )
            ROOMS[ lobby_id ] = nil
            
            LobbyDestroy( lobby_id )
        end
    end

    player:SetPrivateData( "in_casino", false )

    removeEventHandler("onPlayerWasted", player, OnPlayerWasted_handler)
end
addEvent( "onCasinoLobbyLeave" )
addEventHandler( "onCasinoLobbyLeave", root, onCasinoLobbyLeave_handler )

function OnCasinoGameRouletteTurnMade( pPlayer  )
    local pPlayer = pPlayer or client
    local lobby_id = GetPlayerLobbyID( pPlayer )

    if not ROOMS[lobby_id] or not ROOMS[lobby_id].players[pPlayer] then return end

    if ROOMS[lobby_id].players[pPlayer].turn_made then return end 
    if getTickCount() - (ROOMS[lobby_id].turn_started or 0) < 1000 then return end

    local result = GetShotResult( #GetPlayersList(lobby_id) )

    SetTurnPlayer( lobby_id, GetNextPlayerAfter( lobby_id, pPlayer ) )

    ROOMS[lobby_id].turn_started = getTickCount()

    ROOMS[lobby_id].players[pPlayer].is_dead = result

    for k,v in pairs( ROOMS[lobby_id].players ) do
        v.turn_made = false
    end

    ROOMS[lobby_id].players[pPlayer].turn_made = true

    triggerClientEvent( GetPlayersList( lobby_id ), "OnCasinoGameRouletteTurnFinished", resourceRoot, { result = result, player = pPlayer } )

    -- is dead
    if result then
        pPlayer:AddCasinoGameLoseAmount( ROOMS[ lobby_id ].bet )
    end

    setTimer(function( lobby_id )
        if not ROOMS[lobby_id] then return end

        if UpdateState( lobby_id ) and ROOMS[lobby_id] then
            triggerClientEvent( GetPlayersList( lobby_id ), "OnCasinoGameRouletteTurnStarted", resourceRoot, ROOMS[ lobby_id ].turn )
        end
    end, 6500, 1, lobby_id)

    StartTurnTimer( lobby_id, 20 )

    WriteLog( "casino_roulette", "[TURN_MADE] Игрок %s совершает выстрел %s. (LOBBY ID: %s )", pPlayer, result, lobby_id )
end
addEvent("OnCasinoGameRouletteTurnMade", true)
addEventHandler("OnCasinoGameRouletteTurnMade", root, OnCasinoGameRouletteTurnMade)

function onCasinoGameRouletteTurnServersideEnd_handler( lobby_id, skip_turn )
    if not ROOMS[lobby_id] then return end

    if not skip_turn then
        OnCasinoGameRouletteTurnMade( ROOMS[lobby_id].turn )
    else
        if UpdateState( lobby_id ) and ROOMS[lobby_id] then
            triggerClientEvent( GetPlayersList( lobby_id ), "OnCasinoGameRouletteTurnStarted", resourceRoot, ROOMS[ lobby_id ].turn )
            StartTurnTimer( lobby_id, 20 )
        end
    end
end
addEvent("onCasinoGameRouletteTurnServersideEnd", true)
addEventHandler("onCasinoGameRouletteTurnServersideEnd", root, onCasinoGameRouletteTurnServersideEnd_handler)

function FinishGame( lobby_id, pWinner, leave_reason )
    local pRoom = ROOMS[ lobby_id ]
    if not pRoom then return end

    local iReward =  math.floor( pRoom.bet * pRoom.total_count * 0.88 )
    pRoom.commision = (pRoom.bet * pRoom.total_count) - iReward

    if isElement( pWinner ) then
        triggerEvent( "onQuestCasinoComplete", pWinner, CASINO_GAME_ROULETTE, pRoom.bet, pRoom.bet_hard and "hard" or "soft", pWinner, pRoom.bet_hard and pWinner:GetDonate() or pWinner:GetMoney() )
    end

    if pRoom.bet_hard then
        pWinner:GiveDonate( iReward, "casino", "roulette_win" )
        pWinner:AddCasinoGameWinAmount( pRoom.casino_id, CASINO_GAME_ROULETTE, iReward * 1000 )
    else
        pWinner:GiveMoney( iReward, "casino", "roulette_win" )
        pWinner:AddCasinoGameWinAmount( pRoom.casino_id, CASINO_GAME_ROULETTE, iReward )
    end

    local player_data = pRoom.players[ pWinner ]
    if pRoom.started and player_data then
        player_data.reward_sum = iReward
        player_data.is_win = true
        player_data.is_create = pWinner == pRoom.owner
        onCasinoRusRouletteLeave( pWinner, #GetPlayersList( lobby_id ), pRoom, player_data, leave_reason )
    end

    setTimer(function( pRoom, pWinner, iReward )
        pWinner:ShowRewards( { type = pRoom.bet_hard and "hard" or "soft", value = iReward } )
        pWinner:MissionCompleted( "Ты победил" )
        triggerClientEvent(pWinner, "OnClientDicesWon", pWinner)
    end, 500, 1, pRoom, pWinner, iReward)

    --Money transfer detect
    triggerEvent( "onCasinoPlayerWon", pWinner, iReward, pRoom.players )

    LobbySet( lobby_id, "state", CASINO_STATE_ENDED )

    StopTurnTimer( lobby_id )  
    ROOMS[ lobby_id ] = nil
    LobbyDestroy( lobby_id )

    WriteLog( "casino_roulette", "[GAME_FINISHED][ lobby_id: %s ] Победитель %s, Выигрыш: %s", lobby_id, pWinner, iReward )
end

function onResourceStop_handler()
    for i, v in pairs( ROOMS ) do
        if v.players then
            LobbySet( i, "restarting", true )
            for player, _ in pairs( v.players ) do
                LobbyCall( i, "leave", player, false, false, false, "restart" ) 
                player:ShowError( "Русская рулетка отключена сервером, ставки возвращены" )
            end
        end
    end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )

function OnPlayerWasted_handler()
    local lobby_id = GetPlayerLobbyID( source )
    if ROOMS[lobby_id] then
        triggerEvent( "onRouletteTableLeaveRequest", source, lobby_id, false, "wasted" )
    end
end

function onCasinoLobbyPostDestroy_handler( lobby_id, lobby_conf ) 
    if not lobby_conf or lobby_conf.game ~= CASINO_GAME_ROULETTE then return end 
    ROOMS[ lobby_id ] = nil 
end 
addEvent( "onCasinoLobbyPostDestroy" ) 
addEventHandler( "onCasinoLobbyPostDestroy", root, onCasinoLobbyPostDestroy_handler )