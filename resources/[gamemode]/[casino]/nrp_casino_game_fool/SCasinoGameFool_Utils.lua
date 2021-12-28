TAKECARD_NO_CARDS = 1

function GetDeck( lobby_id ) 
    return table.copy( ROOMS[ lobby_id ].deck )
end

function SetDeck( lobby_id, deck )
    ROOMS[ lobby_id ].deck = deck
end

function RefreshDeck( lobby_id )
    triggerClientEvent( GetPlayersList( lobby_id ), "onCasinoGameFoolDeckRefresh", resourceRoot, #ROOMS[ lobby_id ].deck )
end

function GetRandomizedDeck( deck_id )
    local deck_sorted = table.copy( DECKS_LISTS[ deck_id ] )
    local deck_randomized = { }
    
    for i = 1, #deck_sorted do
        local random_pos = math.random( 1, #deck_sorted )
        local random_value = deck_sorted[ random_pos ]
        table.remove( deck_sorted, random_pos )
        table.insert( deck_randomized, random_value )
    end

    return deck_randomized
end

function GetTrump( lobby_id )
    return ROOMS[ lobby_id ].trump
end

function SetTrump( lobby_id, trump )
    ROOMS[ lobby_id ].trump = trump
end

function SetRandomTrump( lobby_id )
    local trump = AVAILABLE_TRUMPS_LIST[ math.random( 1, #AVAILABLE_TRUMPS_LIST ) ]
    SetTrump( lobby_id, trump )
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
 
function GetPlayers( lobby_id )
    return table.copy( ROOMS[ lobby_id ] and ROOMS[ lobby_id ].players or { } )
end

function GetPlayersList( lobby_id )
    local players_list = { }
    local players = GetPlayers( lobby_id )
    for player, v in pairs( players ) do
        table.insert( players_list, player )
    end
    table.sort( players_list, 
        function( a, b )  
            return players[ a ].position < players[ b ].position
        end 
    )
    return players_list
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

function GetPreviousPlayerBefore( lobby_id, player )
    local players_list = GetActivePlayersList( lobby_id )

    local player_position = 0

    for i, v in pairs( players_list ) do
        if v == player then
            player_position = i
            break
        end
    end

    return players_list[ player_position - 1 ] or players_list[ #players_list ]
end

function GetFirstPlayer( lobby_id )
    return GetNextPlayerAfter( lobby_id, 0 )
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
                                                "onCasinoGameFoolTurnServersideEnd", root, lobby_id 
                                            )
    triggerClientEvent( GetPlayersList( lobby_id ), "onCasinoGameFoolTimerStart", resourceRoot, duration )
end

function StopTurnTimer( lobby_id )
    if isTimer( ROOMS[ lobby_id ].turn_timer ) then
        killTimer( ROOMS[ lobby_id ].turn_timer )
        triggerClientEvent( GetPlayersList( lobby_id ), "onCasinoGameFoolTimerStop", resourceRoot )
    end
end

function ResetTurnTimer( lobby_id )
    if isTimer( ROOMS[ lobby_id ].turn_timer ) then
        resetTimer( ROOMS[ lobby_id ].turn_timer )
        local duration = math.ceil( getTimerDetails( ROOMS[ lobby_id ].turn_timer ) / 1000 )
        triggerClientEvent( GetPlayersList( lobby_id ), "onCasinoGameFoolTimerReset", resourceRoot, duration )
    end
end

function SetPlayerGameTask( lobby_id, player, task )
    ROOMS[ lobby_id ].players[ player ].task = task
end
Player.SetGameTask = function( self, lobby_id, ... ) return SetPlayerGameTask( lobby_id, self, ... ) end

function GetPlayerGameTask( lobby_id, player )
    return ROOMS[ lobby_id ].players[ player ].task
end
Player.GetGameTask = function( self, lobby_id, ... ) return GetPlayerGameTask( lobby_id, self, ... ) end

function SetTurnPlayer( lobby_id, player, player_target )
    ROOMS[ lobby_id ].turn = player
    ROOMS[ lobby_id ].turn_target = player_target

    triggerClientEvent( GetPlayersList( lobby_id ), "onCasinoGameFoolTurnChange", resourceRoot, player, player_target )
end

function GetTurnPlayer( lobby_id )
    return ROOMS[ lobby_id ].turn
end

function GetTurnTarget( lobby_id )
    return ROOMS[ lobby_id ].turn_target
end

function GetPlayerHand( lobby_id, player )
    ROOMS[ lobby_id ].hands = ROOMS[ lobby_id ].hands or { }
    ROOMS[ lobby_id ].hands[ player ] = ROOMS[ lobby_id ].hands[ player ] or { }
    return table.copy( ROOMS[ lobby_id ].hands[ player ] )
end
Player.GetHand = function( self, lobby_id, ... ) return GetPlayerHand( lobby_id, self, ... ) end

function SetPlayerHand( lobby_id, player, hand )
    ROOMS[ lobby_id ].hands[ player ] = hand
    SyncPlayerHand( lobby_id, player )
end
Player.SetHand = function( self, lobby_id, ... ) return SetPlayerHand( lobby_id, self, ... ) end

function SyncPlayerHand( lobby_id, player )
    triggerClientEvent( player, "onCasinoGameFoolHandSet", player, GetPlayerHand( lobby_id, player ) )
end
Player.SyncHand = function( self, lobby_id, ... ) return SyncPlayerHand( lobby_id, self, ... ) end

function AddCardToHand( lobby_id, player, card, animate )
    if not ROOMS[ lobby_id ].hands[ player ] then ROOMS[ lobby_id ].hands[ player ] = { } end
    
    table.insert( ROOMS[ lobby_id ].hands[ player ], card )

    if animate then
        triggerClientEvent( GetPlayersList( lobby_id ), "onCasinoGameFoolAddToHand", player, animate )
    end

    return true
end
Player.AddCardToHand = function( self, lobby_id, ... ) return AddCardToHand( lobby_id, self, ... ) end

function RemoveCardFromHand( lobby_id, player, card )
    local hand = GetPlayerHand( lobby_id, player )

    if type( card ) == "table" then
        for i, v in pairs( hand ) do
            if v[ 1 ] == card[ 1 ] and v[ 2 ] == card[ 2 ] then
                table.remove( ROOMS[ lobby_id ].hands[ player ], i )
                return true
            end
        end
    else
        table.remove( ROOMS[ lobby_id ].hands[ player ], card )
        return true
    end

end
Player.RemoveCardFromHand = function( self, lobby_id, ... ) return RemoveCardFromHand( lobby_id, self, ... ) end

function TakeTable( lobby_id, player, animate )
    local tbl = GetTable( lobby_id )
    for i, card_list in pairs( tbl ) do
        local card_original = card_list.card
        local card_beat     = card_list.beat
        if card_original then
            AddCardToHand( lobby_id, player, card_original, animate and "table" )
        end
        if card_beat then
            AddCardToHand( lobby_id, player, card_beat, animate and "table" )
        end
    end
    ClearTable( lobby_id, player )
end
Player.TakeTable = function( self, lobby_id, ... ) return TakeTable( lobby_id, self, ... ) end

function TakeCardFromDeck( lobby_id, player, animate )
    local deck = ROOMS[ lobby_id ].deck
    if #deck > 0 then
        local card_number = isElement( player ) and 1 or player 
        local card = deck[ card_number ] 
        table.remove( deck, card_number ) 
        if isElement( player ) then AddCardToHand( lobby_id, player, card, animate and "deck" ) end
        return card
    else
        return TAKECARD_NO_CARDS
    end
end
Player.TakeCardFromDeck = function( self, lobby_id, ... ) return TakeCardFromDeck( lobby_id, self, ... ) end

function GetTable( lobby_id )
    return table.copy( ROOMS[ lobby_id ].table or { } )
end

function SetTable( lobby_id, game_table )
    ROOMS[ lobby_id ].table = game_table or { }

    triggerClientEvent( GetPlayersList( lobby_id ), "onCasinoGameFoolTableSet", resourceRoot, GetTable( lobby_id ) )
end

function ClearTable( lobby_id, target )
    ROOMS[ lobby_id ].table = { }

    triggerClientEvent( GetPlayersList( lobby_id ), "onCasinoGameFoolTableClear", resourceRoot, target )
end

function GetUnbeatenCards( lobby_id )
    local unbeaten_cards = { }
    for i, v in pairs( ROOMS[ lobby_id ].table or { } ) do
        if not v.beat then table.insert( unbeaten_cards, v ) end
    end
    return unbeaten_cards
end

function RefreshPlayersInRoom( lobby_id, only_update )
    local players_conf = GetPlayersDataInRoom( lobby_id )
    if next( players_conf ) then
        triggerClientEvent( GetPlayersList( lobby_id ), "onCasinoFoolCreatePlayersRequest", resourceRoot, players_conf, only_update )
    end
end

function GetPlayersDataInRoom( lobby_id )
    local players_conf = { }
    for player, conf in pairs( ROOMS[ lobby_id ] and ROOMS[ lobby_id ].players or { } ) do
        local is_playing = conf.state == CASINO_PLAYER_STATE_PLAYING
        players_conf[ conf.position ] = {
            name        = player:GetNickName(),
            position    = conf.position,
            hand_amount = is_playing and #player:GetHand( lobby_id ) or 0,
            task        = conf.task or CASINO_TASK_WAITING,
            player      = player,
            state       = conf.state,
        }
    end
    return players_conf
end