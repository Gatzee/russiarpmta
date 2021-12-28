Extend( "SPlayer" )
Extend( "SDB" )
Extend( "SInterior" )
Extend( "SCasino" )
Extend( "ShTimelib" )

ROOMS = { }
ROOMS_POSITIONS = 
{
    [ CASINO_THREE_AXE ] = 
    {
        Vector3( -67.8103, -499.2047, 913.9765 ),
        Vector3( -67.0000, -499.8910, 913.9765 ),
        Vector3( -67.3643, -499.8954, 913.9765 ),
        Vector3( -67.9690, -499.8820, 913.9765 ),
    },
    [ CASINO_MOSCOW ] = 
    {
        Vector3( 2436.2128, -1318.2816, 2800.0732 ),
        Vector3( 2434.9306, -1318.7543, 2800.0732 ),
        Vector3( 2434.6887, -1319.5156, 2800.0732 ),
        Vector3( 2437.7204, -1319.3486, 2800.0732 ),
    },
}

LOOKAT = 
{
    [ CASINO_THREE_AXE ] = Vector3( CAMERA_POSITION[ CASINO_THREE_AXE ][ 4 ], CAMERA_POSITION[ CASINO_THREE_AXE ][ 5 ], CAMERA_POSITION[ CASINO_THREE_AXE ][ 6 ] ),
    [ CASINO_MOSCOW ]    = Vector3( CAMERA_POSITION[ CASINO_MOSCOW ][ 4 ], CAMERA_POSITION[ CASINO_MOSCOW ][ 5 ], CAMERA_POSITION[ CASINO_MOSCOW ][ 6 ] ),
}

-------------------------------------------------
-- Функционал входа/выхода из игры
-------------------------------------------------

function onCasinoLobbyJoin_handler( lobby_id, lobby_conf )
    if not lobby_conf or lobby_conf.game ~= CASINO_GAME_BLACK_JACK then return end

    local player            = source
    local players_count     = lobby_conf.players_list and #lobby_conf.players_list or 0
    local max_players_count = lobby_conf.players_count_required
    
    local function leave( text )
        if text then player:ErrorWindow( text ) end
        LobbyCall( lobby_id, "leave", player, false, true, true )
        return false
    end

    if players_count > max_players_count then
        return leave( "Все места уже заняты!" )
    end

    local money = lobby_conf.bet_hard and player:GetDonate() or player:GetMoney()
    if money < lobby_conf.bet then
        return leave( "У Вас недостаточно средств для минимальной ставки!" )
    end

    local player_conf = {
        position       = ROOMS_POSITIONS[ lobby_conf.casino_id ][ players_count ],
        state          = CASINO_PLAYER_STATE_WAITING,
        start_time     = getRealTimestamp(),
        afk_rounds     = 0,
        cards          = {},
        rates          = {},

        reward_sum     = 0,
        bet_sum        = 0,
        round_count    = 0,
        win_count_bet  = 0,
        lost_count_bet = 0,
    }

    local need_start_game = false
    if not ROOMS[ lobby_id ] then 
        ROOMS[ lobby_id ] = {
            players = { 
                [ player ] = player_conf
            },
            iteration = {
                number = CR_STATE_RATE,
                timer  = nil,
            },
            game          = lobby_conf.game,
            total_count   = max_players_count,
            bet           = lobby_conf.bet,
            bet_hard      = lobby_conf.bet_hard,
            dealer_cards  = {},
            used_cards    = {},
            
            cur_player_id = 0,
            cur_player    = nil,

            casino_id = lobby_conf.casino_id,
            casino_name = lobby_conf.casino_name,
            unic_game_id = lobby_conf.unic_game_id,
        }
        need_start_game = true
    elseif not ROOMS[ lobby_id ].players then
        ROOMS[ lobby_id ].unic_game_id = lobby_conf.unic_game_id

        ROOMS[ lobby_id ].players = {}
        ROOMS[ lobby_id ].cur_player_id = 0
        ROOMS[ lobby_id ].cur_player = nil
        ROOMS[ lobby_id ].dealer_cards = {}
        ROOMS[ lobby_id ].used_cards = {}
        need_start_game = true
    end
    ROOMS[ lobby_id ].players[ player ] = player_conf
    ROOMS[ lobby_id ].players[ player ].place_id = GetFreePlaceForPlayer( lobby_id )
    
    player:SpawnPlayerOnTable( lobby_id, player_conf.position, lobby_conf.casino_id, need_start_game )

    if need_start_game then
        StopIterationGame( lobby_id )
        StartGame( player, lobby_id )
    end

    onCasinoBlackJackStart( player, ROOMS[ lobby_id ].casino_name, ROOMS[ lobby_id ].unic_game_id, ROOMS[ lobby_id ].game )
end
addEvent( "onCasinoLobbyJoin" )
addEventHandler( "onCasinoLobbyJoin", root, onCasinoLobbyJoin_handler )

function onBlackJackTableLeaveRequest_handler( lobby_id, from_destroy, leave_reason )
    local lobby_id = lobby_id or GetPlayerLobbyID( source )
    if lobby_id and ROOMS[ lobby_id ] and GetPlayerLobbyID( source ) == lobby_id then 
        -- Retention task "blackjack10"
        triggerEvent( "onBlackJackPlay", source, true )
        
        LobbyCall( lobby_id, "leave", source, false, false, false, leave_reason )
    end
end
addEvent( "onBlackJackTableLeaveRequest", true )
addEventHandler( "onBlackJackTableLeaveRequest", root, onBlackJackTableLeaveRequest_handler )

function onCasinoLobbyLeave_handler( lobby_id, lobby_conf, from_destroy, ignore_refund, leave_reason )
    if lobby_conf.game ~= CASINO_GAME_BLACK_JACK then return end
    source:RemovePlayerFromTable( lobby_id, lobby_conf, from_destroy, leave_reason )
end
addEvent( "onCasinoLobbyLeave" )
addEventHandler( "onCasinoLobbyLeave", root, onCasinoLobbyLeave_handler )

function onResourceStop_handler()
    for i, v in pairs( ROOMS ) do
        if v.players then
            LobbySet( i, "restarting", true )
            for player, _ in pairs( v.players ) do
                LobbyCall( i, "leave", player, false, false, false, "restart" ) 
                player:ShowError( "Блек джек отключен сервером, ставки возвращены" )
            end
        end
        LobbySet( i, "restarting", false )
    end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )