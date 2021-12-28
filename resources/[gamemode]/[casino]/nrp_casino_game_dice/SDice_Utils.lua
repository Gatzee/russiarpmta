function GetPlayerState( lobby_id, player )
    return ROOMS[ lobby_id ] and ROOMS[ lobby_id ].players[ player ] and ROOMS[ lobby_id ].players[ player ].state
end
Player.GetState = function( self, lobby_id, ... ) return GetPlayerState( lobby_id, self, ... ) end
 
function GetPlayers( lobby_id )
    return table.copy( ROOMS[ lobby_id ] and ROOMS[ lobby_id ].players or { } )
end

function SetPlayerState( lobby_id, player, state )
    if ROOMS[ lobby_id ] then
        ROOMS[ lobby_id ].players[ player ].state = state
    end
end
Player.SetState = function( self, lobby_id, ... ) return SetPlayerState( lobby_id, self, ... ) end

function GetPlayerState( lobby_id, player )
    return ROOMS[ lobby_id ] and ROOMS[ lobby_id ].players[ player ] and ROOMS[ lobby_id ].players[ player ].state
end
Player.GetState = function( self, lobby_id, ... ) return GetPlayerState( lobby_id, self, ... ) end

function GetPlayersList( lobby_id )
    local players_list = { }
    local players = GetPlayers( lobby_id )
    for player, v in pairs( players ) do
        if GetPlayerLobbyID( player ) == lobby_id then
            table.insert( players_list, player )
        end
    end
    table.sort( players_list, 
        function( a, b )  
            return players[ a ].position < players[ b ].position
        end 
    )
    return players_list
end

function GetPlayerWhoClosingEveryRound( lobby_id )
    local players_list = GetActivePlayersList( lobby_id )
    return players_list[ #players_list ]
end

function GetNextPlayerAfter( lobby_id, player )
    local players_list = GetActivePlayersList( lobby_id )

    local player_position = 0

    for i, v in pairs( players_list ) do
        if v == player then
            player_position = i
            break
        end
    end

    return players_list[ player_position + 1 ] or players_list[ 1 ]
end

function GetActivePlayers( lobby_id )
    local players = { }
    for player, v in pairs( GetPlayers( lobby_id ) ) do
        if v.state == CASINO_PLAYER_STATE_PLAYING then
            players[ player ] = v
        end
    end
    return players
end

function GetActivePlayersList( lobby_id )
    local players_list = { }
    local players = GetPlayers( lobby_id )
    for player, v in pairs( players ) do
        if v.state == CASINO_PLAYER_STATE_PLAYING then
            table.insert( players_list, player )
        end
    end
    table.sort( players_list, 
        function( a, b )  
            return players[ a ].position < players[ b ].position
        end 
    )
    return players_list
end

function StartTurnTimer( lobby_id, duration )
    StopTurnTimer( lobby_id )
    ROOMS[ lobby_id ].turn_timer = setTimer(    triggerEvent, duration * 1000, 1, 
                                                "onCasinoGameDiceTurnServersideEnd", root, lobby_id 
                                            )
end

function StopTurnTimer( lobby_id )
    if isTimer( ROOMS[ lobby_id ].turn_timer ) then
        killTimer( ROOMS[ lobby_id ].turn_timer )
    end
end

function ResetTurnTimer( lobby_id )
    if isTimer( ROOMS[ lobby_id ].turn_timer ) then
        resetTimer( ROOMS[ lobby_id ].turn_timer )
    end
end

function GetFirstPlayer( lobby_id )
    return GetNextPlayerAfter( lobby_id, 0 )
end

function GetPlayersDataInRoom( lobby_id )
    local players_conf = { }
    for player, conf in pairs( ROOMS[ lobby_id ] and ROOMS[ lobby_id ].players or { } ) do
        local is_playing = conf.state == CASINO_PLAYER_STATE_PLAYING
        players_conf[ conf.position ] = {
            name        = player:GetNickName(),
            position    = conf.position,
            hand_amount = is_playing,
            task        = conf.task or CASINO_TASK_WAITING,
            player      = player,
            state       = conf.state,
        }
    end
    return players_conf
end

function SetTurnPlayer( lobby_id, player )
    if not ROOMS[lobby_id] then return end
    
    ROOMS[ lobby_id ].turn = player
end

function GetTurnPlayer( lobby_id )
    return ROOMS[ lobby_id ].turn
end

function AddPlayerScore( pPlayer, score )
    local lobby_id = GetPlayerLobbyID( pPlayer )
    if ROOMS[lobby_id].scores[pPlayer] then
        table.insert( ROOMS[lobby_id].scores[pPlayer], score )
    else
        ROOMS[lobby_id].scores[pPlayer] = { score }
    end

    return ROOMS[lobby_id].scores[pPlayer]
end

function UpdateRound( lobby_id )
    local pRoom = ROOMS[lobby_id]

    local iTurnsMade, iPlayersLeft = 0, 0

    for k,v in pairs(pRoom.players) do
        iPlayersLeft = iPlayersLeft + 1
        if v.turn_made then
            iTurnsMade = iTurnsMade + 1
        end
    end

    if iTurnsMade >= iPlayersLeft then
        pRoom.round_started = getTickCount()
        pRoom.round = pRoom.round + 1

        for k,v in pairs(pRoom.players) do
            v.turn_made = false
        end

        triggerClientEvent(GetActivePlayersList(lobby_id), "OnCasinoGameDiceRoundStarted", resourceRoot, pRoom.round)

        local pCurrentRoundScores = {}

        for k,v in pairs(pRoom.scores) do
            if isElement(k) then
                table.insert(pCurrentRoundScores, k:GetNickName().."(ID: "..k:GetID()..") - "..( v[pRoom.round-1] or "-" ) )
            end
        end

        WriteLog( "casino_dices", "[ROUND_FINISHED][ lobby_id: %s ] Раунд %s окончен. Результаты игроков: %s", lobby_id, pRoom.round-1, pCurrentRoundScores )

        if pRoom.round >= 4 then
            FinishGame( lobby_id, false, false, "finish" )
            return false
        end
    end

    return true
end