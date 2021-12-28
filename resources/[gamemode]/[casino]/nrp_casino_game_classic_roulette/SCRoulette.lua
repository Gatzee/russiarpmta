loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SDB" )
Extend( "SInterior" )
Extend( "SCasino" )

ROOMS = { }
ROOMS_POSITIONS = {
    [ CASINO_THREE_AXE ] =
    {
        Vector3( -85.8103, -472.5230, 913.9765 ),
        Vector3( -85.6527, -470.1420, 913.9765 ),
        Vector3( -88.3510, -470.2269, 913.9765 ),
        Vector3( -88.1183, -472.7688, 913.9765 ),
        Vector3( -86.3833, -473.4341, 913.9765 ),
        Vector3( -85.6206, -471.4915, 913.9765 ),
        Vector3( -88.3315, -471.7922, 913.9765 ),
        Vector3( -85.8679, -469.0321, 913.9765 ),
        Vector3( -88.1671, -469.2789, 913.9765 ),
        Vector3( -87.5617, -473.4402, 913.9765 ),
    },
    [ CASINO_MOSCOW ] =
    {
        Vector3( 2425.2209, -1320.8984, 2800.0705 ),
        Vector3( 2425.2209, -1320.7984, 2800.0705 ),
        Vector3( 2425.2209, -1320.6984, 2800.0705 ),
        Vector3( 2425.2209, -1320.5984, 2800.0705 ),
        Vector3( 2425.2209, -1320.4984, 2800.0705 ),
        Vector3( 2425.2209, -1320.3984, 2800.0705 ),
        Vector3( 2425.2209, -1320.2984, 2800.0705 ),
        Vector3( 2425.2209, -1320.1984, 2800.0705 ),
        Vector3( 2425.2209, -1320.0984, 2800.0705 ),
        Vector3( 2425.2209, -1320.0, 2800.0705 ),
    }
}

DEFAULT_POSITION = 
{
    [ CASINO_THREE_AXE ] = Vector3( -84.6423, -466.9638, 913.9765 ),
    [ CASINO_MOSCOW ] = Vector3( 2425.2209, -1320.8984, 2800.0705 ),
}
LOOKAT = 
{
    [ CASINO_THREE_AXE ] = Vector3( -87.009, -470.814, 913.977 ),
    [ CASINO_MOSCOW ] = Vector3( -87.009, -470.814, 913.977 ),
}


-------------------------------------------------
-- Функционал входа/выхода из игры
-------------------------------------------------

function onCasinoLobbyJoin_handler( room_id, lobby_conf )
    if not lobby_conf or lobby_conf.game ~= CASINO_GAME_CLASSIC_ROULETTE_VIP and lobby_conf.game ~= CASINO_GAME_CLASSIC_ROULETTE then return end

    local player = client or source
    local players_count = lobby_conf.players_list and #lobby_conf.players_list or 0
    local max_players_count = lobby_conf.players_count_required
    
    local function leave( text )
        if text then player:ErrorWindow( text ) end
        LobbyCall( room_id, "leave", player, false, true, true )
        return false
    end

    if players_count > max_players_count then
        return leave( "Все места уже заняты!" )
    end

    local player_balance = lobby_conf.bet_hard and player:GetDonate() or player:GetMoney()
    if player_balance < lobby_conf.bet then
        return leave( "У Вас недостаточно средств для минимальной ставки!" )
    end

    local player_conf = {
        position   = max_players_count == 10 and ROOMS_POSITIONS[ lobby_conf.casino_id ][ players_count ] or DEFAULT_POSITION[ lobby_conf.casino_id ],
        rates      = {},
        state      = CASINO_PLAYER_STATE_WAITING,
        start_time = getRealTimestamp(),
        afk_rounds = 0,
        bet_sum    = 0,
        reward_sum = 0,
        lost_sum   = 0,
        lost_count_bet = 0,
        win_count_bet  = 0,
    }

    local need_start_game = false
    if not ROOMS[ room_id ] then 
        ROOMS[ room_id ] = {
            players = { 
                [ player ] = player_conf
            },
            iteration = {
                number = CR_STATE_RATE,
                timer  = nil,
            },
            game = lobby_conf.game,
            total_count = max_players_count,
            bet = lobby_conf.bet,
            bet_hard = lobby_conf.bet_hard,
            last_win_fields = {},

            casino_id = lobby_conf.casino_id,
            casino_name = lobby_conf.casino_name,
            unic_game_id = lobby_conf.unic_game_id,
        }
        need_start_game = true
    else
        if not ROOMS[ room_id ].players then
            ROOMS[ room_id ].unic_game_id = lobby_conf.unic_game_id

            ROOMS[ room_id ].players = {}
            need_start_game = true
        end
        ROOMS[ room_id ].players[ player ] = player_conf
    end

    if need_start_game then
        StopIterationGame( room_id )
        StartGame( player, room_id )
    end

    player:SpawnPlayerOnTable( room_id, player_conf.position, lobby_conf.casino_id, max_players_count )

    onCasinoRouletteStart( player, ROOMS[ room_id ].casino_name, ROOMS[ room_id ].unic_game_id, ROOMS[ room_id ].game, ROOMS[ room_id ].bet_hard )
end
addEvent( "onCasinoLobbyJoin" )
addEventHandler( "onCasinoLobbyJoin", root, onCasinoLobbyJoin_handler )

function onClassicRouletteTableLeaveRequest_handler( room_id, from_destroy, leave_reason )
    local room_id = room_id or GetPlayerLobbyID( source )
	if room_id and ROOMS[ room_id ] and GetPlayerLobbyID( source ) == room_id then 
		LobbyCall( room_id, "leave", source, false, false, false, leave_reason )
    end
end
addEvent( "onClassicRouletteTableLeaveRequest", true )
addEventHandler( "onClassicRouletteTableLeaveRequest", root, onClassicRouletteTableLeaveRequest_handler )

function onCasinoLobbyLeave_handler( room_id, lobby_conf, from_destroy, ignore_refund, leave_reason )
    source:RemovePlayerFromTable( room_id, lobby_conf, from_destroy, leave_reason )
end
addEvent( "onCasinoLobbyLeave" )
addEventHandler( "onCasinoLobbyLeave", root, onCasinoLobbyLeave_handler )

function onResourceStop_handler()
    for i, v in pairs( ROOMS ) do
        if v.players then
            LobbySet( i, "restarting", true )
            for player, _ in pairs( v.players ) do
                LobbyCall( i, "leave", player, false, false, false, "restart" ) 
                player:ShowError( "Классическая рулетка отключена сервером, ставки возвращены" )
                player:SetPrivateData( "cr_big_room", false )
            end
        end
        LobbySet( i, "restarting", false )
    end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )