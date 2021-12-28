loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SInterior" )
Extend( "SCasino" )

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
        Vector3( 2371.875, -1324.738, 2800.0703 ),
        Vector3( 2371.875, -1322.109, 2800.0703 ),
        Vector3( 2369.339, -1322.034, 2800.0703 ),
        Vector3( 2369.198, -1324.837, 2800.0703 ),
        Vector3( 2370.555, -1325.012, 2800.0703 ),
        Vector3( 2370.474, -1321.934, 2800.0703 ),
    }
}

-- Центр комнаты - точка взгляда
LOOKAT = 
{
    [ CASINO_THREE_AXE ] = Vector3( -87.009, -470.814, 913.977 ),
    [ CASINO_MOSCOW ] = Vector3( 2370.530, -1323.460, 2800.5 ),
}


POSITION_CONVERT = {
    [ 1 ] = 1,
    [ 2 ] = 3,
    [ 3 ] = 5,
    [ 4 ] = 2,
    [ 5 ] = 4,
}

COMMISION_PERCENT = 
{
    soft = 
    {
        [1] = 0.03,
        [2] = 0.03,
        [3] = 0.03,
        [4] = 0.06,
        [5] = 0.1,
    },

    hard = 
    {
        [1] = 0.05,
        [2] = 0.05,
    }
}

function onCasinoLobbyJoin_handler( lobby_id, lobby_conf )

    if not lobby_conf or lobby_conf.game ~= CASINO_GAME_DICE and lobby_conf.game ~= CASINO_GAME_DICE_VIP then return end
    local player = client or source

    -- TEST
    --lobby_conf.players_count_required = 1

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
        player:TakeDonate( lobby_conf.bet, "casino", "dice_participate" )
    else
        player:TakeMoney( lobby_conf.bet, "casino", "dice_participate" )
    end

    player:SetPrivateData( "in_casino", true )

    local player_conf = {
        --position    = POSITION_CONVERT[ players_count ],
        position    = players_count,
        bet         = lobby_conf.bet,
        reward_sum  = 0,
        state       = CASINO_PLAYER_STATE_WAITING,
        turn_made   = false,
        start_time  = getRealTimestamp(),
    }

    if not ROOMS[ lobby_id ] then 
        ROOMS[ lobby_id ] = {
            players = { 
                [ player ] = player_conf
            },
            scores = {},
            participants_left = {},
            round = 1,
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

            onCasinoBoneStart( i, ROOMS[ lobby_id ].casino_name, ROOMS[ lobby_id ].unic_game_id, ROOMS[ lobby_id ].game )
        end
        
        ROOMS[ lobby_id ].started = true
        StartGame( lobby_id )
    end

    removeEventHandler( "onPlayerWasted", player, OnPlayerWasted_handler )
    addEventHandler( "onPlayerWasted", player, OnPlayerWasted_handler )
end
addEvent( "onCasinoLobbyJoin" )
addEventHandler( "onCasinoLobbyJoin", root, onCasinoLobbyJoin_handler )

function StartGame( lobby_id )
    LobbySet( lobby_id, "invisible", true )
    LobbySet( lobby_id, "state", CASINO_STATE_PLAYING )
	local players_list = GetPlayersList( lobby_id )
    triggerClientEvent( players_list, "onClientShowUICasinoGame", root, false )

    triggerEvent( "onCasinoGameDiceStart", root, lobby_id )
    triggerEvent( "onCasinoPlayersGame", root, CASINO_GAME_DICE, players_list, true )
end

function onCasinoLobbyLeave_handler( lobby_id, lobby_conf, from_destroy, ignore_refund, leave_reason )
    if lobby_conf.game ~= CASINO_GAME_DICE and lobby_conf.game ~= CASINO_GAME_DICE_VIP then return end
    local player = client or source  

    triggerEvent( "onDiceTableLeaveRequest", player, lobby_id, from_destroy, false, leave_reason )

    local is_restarting = lobby_conf.restarting

    if lobby_conf.state ~= CASINO_STATE_WAITING then
        triggerClientEvent( player, "OnCasinoGameDiceFinished", resourceRoot, is_restarting )
    end

    if ( is_restarting or lobby_conf.state == CASINO_STATE_WAITING ) and not ignore_refund then
        if lobby_conf.bet_hard then
            player:GiveDonate( lobby_conf.bet, "casino", "dice_restart_refund" )
        else
            player:GiveMoney( lobby_conf.bet, "casino", "dice_restart_refund" )
        end
    end

    if ROOMS[ lobby_id ] then
        ROOMS[ lobby_id ].players[ player ] = nil
        ROOMS[ lobby_id ].scores[ player ] = nil

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

function OnCasinoGameDiceTurnMade( pPlayer )
    local pPlayer = pPlayer or client

    local cube1, cube2 = math.random(1,6), math.random(1,6)
    local lobby_id = GetPlayerLobbyID( pPlayer )
    if not lobby_id then return end

    local pRoom = ROOMS[lobby_id]
    if not pRoom then return end


    if not ROOMS[lobby_id].players[pPlayer] then return end

    if ROOMS[lobby_id].players[pPlayer].turn_made then return end
    if getTickCount() - ROOMS[lobby_id].round_started < 1500 then return end

    -- фикс двойного перехода
    if GetPlayerWhoClosingEveryRound( lobby_id ) == pPlayer and getTickCount() - ROOMS[lobby_id].round_started < 20000 then return end

    AddPlayerScore( pPlayer, cube1+cube2 )
    SetTurnPlayer( lobby_id, GetNextPlayerAfter( lobby_id, pPlayer ) )

    ROOMS[lobby_id].players[pPlayer].turn_made = true

    triggerClientEvent( GetPlayersList( lobby_id ), "OnCasinoGameDiceTurnFinished", resourceRoot, { result = {cube1, cube2}, round = pRoom.round, player = pPlayer } )

    setTimer(function( lobby_id )
        if not ROOMS[lobby_id] then return end

        if UpdateRound( lobby_id ) then
            triggerClientEvent( GetPlayersList( lobby_id ), "OnCasinoGameDiceTurnStarted", resourceRoot, ROOMS[ lobby_id ].turn )
        end
    end, 6500, 1, lobby_id)

    StartTurnTimer( lobby_id, 20 )

    WriteLog( "casino_dices", "[THROW_DICES] Игрок %s бросил кости на %s. (LOBBY ID: %s, ROUND: %s )", pPlayer, cube1+cube2, lobby_id, ROOMS[lobby_id].round )
end
addEvent("OnCasinoGameDiceTurnMade", true)
addEventHandler("OnCasinoGameDiceTurnMade", root, OnCasinoGameDiceTurnMade)

function onCasinoGameDiceTurnServersideEnd_handler( lobby_id, skip_turn )
    local pRoom = ROOMS[lobby_id]
    if not pRoom then return end

    if not skip_turn then
        OnCasinoGameDiceTurnMade( pRoom.turn )
    else
        if ROOMS[lobby_id] then
            if UpdateRound( lobby_id ) then
                local players_list = GetPlayersList( lobby_id )
                triggerClientEvent( players_list, "OnCasinoGameDiceTurnStarted", resourceRoot, ROOMS[ lobby_id ].turn )

                StartTurnTimer( lobby_id, 20 )
            end
        end
    end
end
addEvent("onCasinoGameDiceTurnServersideEnd", true)
addEventHandler("onCasinoGameDiceTurnServersideEnd", root, onCasinoGameDiceTurnServersideEnd_handler)

function FinishGame( lobby_id, pWinner, is_alone, leave_reason )
    local pRoom = ROOMS[lobby_id]
    if not pRoom then return end

    local iHighestScore, pWinner, pWinners = 0, pWinner, {}

    if not pWinner then
        for player, scores in pairs(pRoom.scores) do
            local iTotalScore = 0
            for i, value in pairs(scores) do
                iTotalScore = iTotalScore + value
            end

            if iTotalScore > iHighestScore then
                iHighestScore = iTotalScore
                pWinner = player
                pWinners = { player }
            elseif iTotalScore == iHighestScore then
                table.insert(pWinners, player)
            end
        end
    else
        pWinners = { pWinner }
    end
    
    iprint( pRoom.bet, pRoom.bet_hard, pRoom.total_count )

    local iReward = pRoom.bet * pRoom.total_count * (1 - (COMMISION_PERCENT[ pRoom.bet_hard and "hard" or "soft" ][ pRoom.total_count ] or 0.05) )
    pRoom.commision = pRoom.bet * pRoom.total_count - iReward

    for player, data in pairs( pRoom.players ) do
        if isElement(player) then
            if #pWinners == 1 then
                player:ShowInfo( "Игра окончена, победил " .. pWinner:GetNickName( ) )
            else
                player:ShowInfo( "Игра окончена, победителей: " .. #pWinners )
            end

            if not pRoom.participants_left[player] then
                pRoom.participants_left[player] = { name = player:GetNickName(), uid = player:GetID() }
            end

            data.is_win = false
            for i, winner in pairs( pWinners ) do
                if winner == player then
                    data.is_win = true
                    data.reward_sum = math.floor( iReward / #pWinners ) * ( pRoom.bet_hard and 1000 or 1 )
                end
            end

            data.is_create = player == pRoom.owner
            
            onCasinoBoneLeave( player, pRoom.total_count, pRoom, data, leave_reason )

            triggerEvent( "onQuestCasinoComplete", player, pRoom.bet_hard and CASINO_GAME_DICE_VIP or CASINO_GAME_DICE, pRoom.bet, pRoom.bet_hard and "hard" or "soft", player == pWinner, pRoom.bet_hard and player:GetDonate() or player:GetMoney() )
        end
    end


    if pRoom.bet_hard then
        for i, winner in pairs(pWinners) do
            local reward = math.floor( iReward / #pWinners )
            winner:GiveDonate( reward, "casino", "dice_win" )
            winner:AddCasinoGameWinAmount( pRoom.casino_id, CASINO_GAME_DICE_VIP, reward * 1000 )
        end
    else
        for i, winner in pairs( pWinners ) do
            local reward = math.floor( iReward / #pWinners )
            winner:GiveMoney( reward, "casino", "dice_win" )
            winner:AddCasinoGameWinAmount( pRoom.casino_id, CASINO_GAME_DICE, reward )
        end

        for player, data in pairs( pRoom.players ) do
            if not data.is_win then
                player:AddCasinoGameLoseAmount( data.bet )
            end
        end
    end

    setTimer(function( pRoom, pWinners, iReward )
        for i, winner in pairs(pWinners) do
            if not isElement(winner) then return end

            winner:ShowRewards( { type = pRoom.bet_hard and "hard" or "soft", value = math.floor(iReward/#pWinners) } )
            winner:MissionCompleted( "Ты победил" )
            triggerClientEvent(winner, "OnClientDicesWon", pWinner)

            if not pRoom.bet_hard then 
                triggerEvent( "onCasinoPlayerWon", winner, math.floor( iReward/ #pWinners ), pRoom.players )
            end
        end
    end, 500, 1, pRoom, pWinners, iReward)

    LobbySet( lobby_id, "state", CASINO_STATE_ENDED )

    local pReadableWinners = {}
    for k,v in pairs(pWinners) do
        table.insert(pReadableWinners, v:GetNickName().."(ID: "..v:GetID()..")" )
    end

    WriteLog( "casino_dices", "[GAME_FINISHED][ lobby_id: %s ] Выигрыш: %s Победители: %s", lobby_id, math.floor(iReward/#pWinners), pReadableWinners )

    triggerEvent("OnCasinoDonateGameFinished", root, "VIP_DICES", pRoom.bet, pRoom.total_count, pWinners, is_alone and "Игрок покинул игру" or "Игра завершена", pRoom.participants_left)

    StopTurnTimer( lobby_id )  
    ROOMS[ lobby_id ] = nil
    LobbyDestroy( lobby_id )
end

function onResourceStop_handler()
    for i, v in pairs( ROOMS ) do
        if v.players then
            LobbySet( i, "restarting", true )
            for player, _ in pairs( v.players ) do
                LobbyCall( i, "leave", player, false, false, false, false, "restart" )  
                player:ShowError( "Игра в кости отключена сервером, ставки возвращены" )
            end
        end
    end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )

function OnPlayerWasted_handler()
    local lobby_id = GetPlayerLobbyID( source )
    if ROOMS[lobby_id] then
        triggerEvent("onDiceTableLeaveRequest", source, lobby_id, _, true, "wasted" )
    end
end

-- Зачистка таблицы лобби при удалении
function onCasinoLobbyPostDestroy_handler( lobby_id, lobby_conf )
    if not lobby_conf or lobby_conf.game ~= CASINO_GAME_DICE and lobby_conf.game ~= CASINO_GAME_DICE_VIP then return end
    ROOMS[ lobby_id ] = nil
end
addEvent( "onCasinoLobbyPostDestroy" )
addEventHandler( "onCasinoLobbyPostDestroy", root, onCasinoLobbyPostDestroy_handler )