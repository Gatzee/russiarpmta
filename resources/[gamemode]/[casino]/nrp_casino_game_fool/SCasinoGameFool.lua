loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SInterior" )
Extend( "SCasino" )

ROOMS = { }

-- Позиции игроков в комнатах
ROOMS_POSITIONS = {
    Vector3( -86.994, -473.728, 913.977 ),
    Vector3( -88.329, -471.815, 913.977 ),
    Vector3( -88.258, -469.516, 913.977 ),
    Vector3( -86.913, -468.408, 913.977 ),
    Vector3( -85.699, -469.821, 913.977 ),
    Vector3( -85.729, -472.192, 913.977 ),
}

-- Центр комнаты - точка взгляда
LOOKAT = Vector3( -87.009, -470.814, 913.977 )

-- Раскидывание игроков по точкам в интерфейсе
POSITION_CONVERT = {
    [ 1 ] = 1,
    [ 2 ] = 3,
    [ 3 ] = 5,
    [ 4 ] = 2,
    [ 5 ] = 4,
}

function onCasinoLobbyJoin_handler( lobby_id, lobby_conf )
    if not lobby_conf or lobby_conf.game ~= CASINO_GAME_FOOL then return end
    local player = client or source

    -- TEST
    -- lobby_conf.players_count_required = 2

    local players_count = #lobby_conf.players_list
    local max_players_count = lobby_conf.players_count_required

    local function leave( text )
        if text then player:ErrorWindow( text ) end
        LobbyCall( lobby_id, "leave", player ) 
    end

    if lobby_conf.state and lobby_conf.state ~= CASINO_STATE_WAITING then
        return leave( "В этой комнате уже играют!" )
    end

    if players_count > max_players_count then
        return leave( "Все места уже заняты!" )
    end

    local money = lobby_conf.hard and player:GetDonate() or player:GetMoney()
    if money < lobby_conf.bet then
        return leave( "Недостаточно средств для ставки!" )
    end

    player:SetPrivateData( "in_casino", true )

    local player_conf = {
        --position    = POSITION_CONVERT[ players_count ],
        position    = players_count,
        bet         = lobby_conf.bet,
        state       = CASINO_PLAYER_STATE_WAITING,
    }

    if not ROOMS[ lobby_id ] then 
        ROOMS[ lobby_id ] = {
            players = { 
                [ player ] = player_conf
            },
            hands       = { },
            deck        = { },
            table       = { },
            winners     = { },
            trump       = false,
            turn        = false,
            turn_target = false,
            turn_timer  = false,
            loser       = false,
            total_count = max_players_count,
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
        end
        
        StartGame( lobby_id )

    end
end
addEvent( "onCasinoLobbyJoin" )
addEventHandler( "onCasinoLobbyJoin", root, onCasinoLobbyJoin_handler )

function StartGame( lobby_id )
    LobbySet( lobby_id, "invisible", true )
	LobbySet( lobby_id, "state", CASINO_STATE_RUNNING )
	local players_list = GetPlayersList( lobby_id )
    triggerClientEvent( players_list, "onClientShowUICasinoGame", root, false )

    triggerEvent( "onCasinoGameFoolStart", root, lobby_id )
    triggerEvent( "onCasinoPlayersGame", root, CASINO_GAME_FOOL, players_list )
end

function ResetLobby( lobby_id )
    if not ROOMS[ lobby_id ] then return end
    local players = GetPlayersList( lobby_id )

    local max_players_count = ROOMS[ lobby_id ].total_count
    local lobby_state = LobbyGet( lobby_id, "state" )
    if #players < max_players_count and lobby_state ~= CASINO_STATE_RUNNING then

        local old_players_conf = table.copy( ROOMS[ lobby_id ].players )
        local old_bet = ROOMS[ lobby_id ].bet

        ROOMS[ lobby_id ] = {
            players     = { },
            hands       = { },
            deck        = { },
            table       = { },
            winners     = { },
            trump       = false,
            turn        = false,
            turn_target = false,
            turn_timer  = false,
            loser       = false,
            total_count = max_players_count,
        }

        for i, v in pairs( players ) do
            local player_conf = {
                position    = old_players_conf[ v ].position,
                bet         = old_bet,
                state       = CASINO_PLAYER_STATE_WAITING,
            }
            ROOMS[ lobby_id ].players[ player ] = player_conf
        end

    end

    if #players == max_players_count then
        if lobby_state ~= CASINO_STATE_RUNNING then
            StartGame( lobby_id )
        end
    else
        LobbySet( lobby_id, "state", CASINO_STATE_WAITING )
        LobbySet( lobby_id, "invisible", false )
    end

end

function onCasinoLobbyLeave_handler( lobby_id, lobby_conf, from_destroy )
    if lobby_conf.game ~= CASINO_GAME_FOOL then return end
    local player = client or source  

    triggerClientEvent( player, "ShowTableUI", resourceRoot, false )
    triggerEvent( "onFoolTableLeaveRequest", player, lobby_id, from_destroy )

    if ROOMS[ lobby_id ] then
        ROOMS[ lobby_id ].players[ player ] = nil
        if not next( ROOMS[ lobby_id ].players ) then
            StopTurnTimer( lobby_id )
            ROOMS[ lobby_id ] = nil
            
            LobbyDestroy( lobby_id )
        end
    end

    player:SetPrivateData( "in_casino", false )
end
addEvent( "onCasinoLobbyLeave" )
addEventHandler( "onCasinoLobbyLeave", root, onCasinoLobbyLeave_handler )

function onResourceStop_handler()
    for i, v in pairs( ROOMS ) do
        if v.players then
            LobbySet( i, "restarting", true )
            for player, _ in pairs( v.players ) do
                LobbyCall( i, "leave", player ) 
                player:ShowError( "Игра в дурака отключена сервером, ставки возвращены" )
            end
        end
    end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )