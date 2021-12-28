
-------------------------------------------------
-- Общий вспомогательный функционал игры
-------------------------------------------------

function GetPlayersList( lobby_id )
    local players = GetPlayers( lobby_id )
    
    local players_list = { }
    for player, v in pairs( players ) do
        if not ROOMS[ lobby_id ].players[ player ].leave then
            table.insert( players_list, player )
        end
    end

    return players_list
end

function GetPlayers( lobby_id )
    return table.copy( ROOMS[ lobby_id ] and ROOMS[ lobby_id ].players or { } )
end

function CheckForStopGame( lobby_id )
    local pRoom = ROOMS[ lobby_id ]
    if not pRoom then return end

    if not ROOMS[ lobby_id ].players or not next( ROOMS[ lobby_id ].players ) then
        StopIterationGame( lobby_id )
        ROOMS[ lobby_id ].players = nil
        return true
    end

    return false
end

function GetDealerCardSumm( lobby_id )
    local pRoom = ROOMS[ lobby_id ]
    if not pRoom then return end
    return CalculateCardSumm( pRoom.dealer_cards )
end

function CheckAFKPlayers( lobby_id )
    local lobby_conf = LobbyGetAll( lobby_id )
    for k, v in pairs( ROOMS[ lobby_id ].players or {} ) do
        if v.afk_rounds >= MAX_AFK_ROUNDS then
            triggerEvent( "onBlackJackTableLeaveRequest", k, lobby_id, false, "afk" )
            k:ShowError( "Вас выгнали из игры за бездействие" )
        end
    end
end

function GetNextGamePlayer( lobby_id )
    local next_place = ROOMS[ lobby_id ].cur_player_id
    local next_player = ROOMS[ lobby_id ].cur_player

    local player_places = {}
    for k, v in pairs( ROOMS[ lobby_id ].players ) do
        if #v.rates > 0 and k:GetCardSumm() < 21 then
            table.insert( player_places, { place_id = v.place_id, player = k } )
        end
    end

    table.sort( player_places, function( a, b )
        return a.place_id < b.place_id
    end )

    for k, v in ipairs( player_places ) do
        if v.place_id > ROOMS[ lobby_id ].cur_player_id then
            next_place = v.place_id
            next_player = v.player
            break
        end
    end

    return next_place, next_player
end

function GetFreePlaceForPlayer( lobby_id )
    local place = false
    local occupied_places = 
    {
        [ 1 ] = false,
        [ 2 ] = false,
        [ 3 ] = false,
        [ 4 ] = false,
    }
    
    for k, v in pairs( ROOMS[ lobby_id ].players ) do
        if v.place_id then
            occupied_places[ v.place_id ] = true
        end
    end

    for k, v in ipairs( occupied_places ) do
        if not v then
            return k
        end
    end
end

function CollectPlayerDataCards( lobby_id )
    local cards_data = {}
    for k, v in pairs( ROOMS[ lobby_id ].players ) do
        cards_data[ v.place_id ] = 
        {
            player = k,
            cards  = v.cards,
            rate   = k:GetPlayerRateSumm(),
        }
    end
    return cards_data
end

function GenerateDealerCards( lobby_id )
    repeat
        local card_id = math.random( 2, 14 )
        local card_suit = math.random( 1,  4 )
        if not ROOMS[ lobby_id ].used_cards[ card_id .. card_suit ] then
            ROOMS[ lobby_id ].used_cards[ card_id .. card_suit ] = true
            table.insert( ROOMS[ lobby_id ].dealer_cards, { card_id, card_suit } )
        end
    until CalculateCardSumm( ROOMS[ lobby_id ].dealer_cards ) > 16
end

function GetShowDealerCards( lobby_id )
    local result = { { -1, 0 } }
    for i = 2, 2 do
        table.insert( result, ROOMS[ lobby_id ].dealer_cards[ i ] )
    end
    return result
end

function IsBlackJack( cards_summ, cards_count )
    return cards_summ == 21 and cards_count == 2
end

-------------------------------------------------
-- Вспомогательный функционал для игроков
-------------------------------------------------

function OnPlayerWasted_handler()
    local lobby_id = GetPlayerLobbyID( source )
    if ROOMS[ lobby_id ] then
        triggerEvent( "onBlackJackTableLeaveRequest", source, lobby_id, false, "wasted" )
    end
end

Player.SpawnPlayerOnTable = function( self, lobby_id, position, casino_id, is_start )
    fadeCamera( self, false, 0 )
    setTimer( fadeCamera, 300, 1, self, true, 1 )
    

    local casino_interior =
    {
        [ CASINO_THREE_AXE ] = 1,
        [ CASINO_MOSCOW ] = 4,
    }

    self.dimension = 660 * casino_interior[ casino_id ] + lobby_id
    self.interior  = casino_interior[ casino_id ]
    self.position  = position
    
    local new_rotation_vector = LOOKAT[ casino_id ] - position
    
    local dd_rotation_vector = Vector2( new_rotation_vector.x, new_rotation_vector.y ):getNormalized()
    local rotation_angle = -math.deg( math.atan2( dd_rotation_vector.x, dd_rotation_vector.y ) )    
    setElementRotation( self, 0, 0, rotation_angle )

    self:SetPrivateData( "in_casino", true )
    self:CompleteDailyQuest( "play_casino" )
    addEventHandler("onPlayerWasted", self, OnPlayerWasted_handler)
    
    local lobby_data = ROOMS[ lobby_id ]
    local remaining_time = 0
    if isTimer( lobby_data.iteration.timer ) then
        local time = getTimerDetails( lobby_data.iteration.timer )
        remaining_time = time
    end
    
    triggerClientEvent( self, "OnCasinoGameBlackJackStarted", resourceRoot, 
    {
        casino_id         = lobby_data.casino_id,
        remaining_time    = remaining_time,
        current_state     = lobby_data.iteration.state,
        winners_list      = exports.nrp_casino_lobby:GetCasinoTopStatRows( lobby_data.casino_id, lobby_data.game, 5 ),
        dealer_cards      = (lobby_data.iteration.state == BLACK_JACK_STATE_RATE or is_start) and {} or GetShowDealerCards( lobby_id ),
        player_data_cards = CollectPlayerDataCards( lobby_id ),
    } )

    if not is_start then
        local players = GetPlayersList( lobby_id )
        if #players > 1 then
            local target_players = {}
            for k, v in pairs( players ) do
                if v ~= self then
                    table.insert( target_players, v )
                end
            end
        
            triggerClientEvent( target_players, "onClientPlayerJoinGame", resourceRoot, {
                place_id = lobby_data.players[ self ].place_id,
                player = self,
                cards  = lobby_data.players[ self ].cards,
                rate   = self:GetPlayerRateSumm(),
            } )
        end
    end
end

Player.RemovePlayerFromTable = function( self, lobby_id, lobby_conf, from_destroy, leave_reason )
    self:SetPrivateData( "in_casino", false )
    local room_data = ROOMS[ lobby_id ] 
    if room_data then        
        onCasinoBlackJackLeave( self, #GetPlayersList( lobby_id ), room_data, room_data.players[ self ], leave_reason )

        removeEventHandler( "onPlayerWasted", self, OnPlayerWasted_handler)
        
        -- Уничтожение интерфейса на клиенте
        triggerClientEvent( self, "OnCasinoGameBlackJackLeaved", resourceRoot, lobby_conf.restarting )

        local player_data = table.copy( room_data.players[ self ] )
        room_data.players[ self ] = nil
        local stop_game = CheckForStopGame( lobby_id )
        if not stop_game then
            if self == room_data.cur_player and room_data.iteration.game then
                if isTimer( room_data.iteration.timer ) then
                    killTimer( room_data.iteration.timer )
                end
                OnIterationComplete( lobby_id, BLACK_JACK_STATE_ACTION_CARD )
            end

            local players = GetPlayersList( lobby_id )
            local target_players = {}
            for k, v in pairs( players ) do
                if v ~= self then
                    table.insert( target_players, v )
                end
            end

            triggerClientEvent( target_players, "onClientPlayerLeaveGame", resourceRoot, {
                place_id = player_data.place_id,
            })
        end
    end
end

Player.GenerateCards = function( self, lobby_id, need_count )
    local count = 0
    repeat
        local card_id = math.random( 2, 14 )
        local card_suit = math.random( 1,  4 )
        if not ROOMS[ lobby_id ].used_cards[ card_id .. card_suit ] then
            ROOMS[ lobby_id ].used_cards[ card_id .. card_suit ] = true
            table.insert( ROOMS[ lobby_id ].players[ self ].cards, { card_id, card_suit } )
            count = count + 1
        end
    until count == need_count
end

-------------------------------------------------
-- Ставки
-------------------------------------------------

Player.AddRate = function( self, chip )
    if not tonumber( chip ) then return false end

    local lobby_id = GetPlayerLobbyID( self )
    local lobby_data = ROOMS[ lobby_id ]
    if not lobby_data then return end

    if not RATES_VALUES[ lobby_data.casino_id ][ chip ] then return false end

    table.insert( lobby_data.players[ self ].rates, chip )

    return true
end

Player.RemoveRate = function( self, chip )
    if not tonumber( chip ) then return false end

    local lobby_id = GetPlayerLobbyID( self )
    local lobby_data = ROOMS[ lobby_id ]
    if not lobby_data then return end

    for k, v in pairs( ROOMS[ lobby_id ].players[ self ].rates ) do
        if v == chip then
            table.remove( ROOMS[ lobby_id ].players[ self ].rates, k )
            return RATES_VALUES[ lobby_data.casino_id ][ chip ]
        end
    end

    return false
end

Player.TakeRateValue = function( self, price )
    return self:TakeMoney( price, "casino", "blackjack_participate" )
end

Player.ReturnRateValue = function( self, price )
    return self:GiveMoney( price, "casino", "blackjack_participate" )
end

Player.GetCardSumm = function( self )
    local lobby_id = GetPlayerLobbyID( self )
    local pRoom = ROOMS[ lobby_id ]
    if not pRoom or not pRoom.players[ self ] then return false end
    return CalculateCardSumm( pRoom.players[ self ].cards )
end

Player.GetPlayerRateSumm = function( self )
    local rate_summ = 0
    local lobby_id = GetPlayerLobbyID( self )
    local lobby_data = ROOMS[ lobby_id ]
    if not lobby_data then return end

    for k, v in pairs( ROOMS[ lobby_id ].players[ self ].rates ) do
        rate_summ = rate_summ + RATES_VALUES[ lobby_data.casino_id ][ v ]
    end
    return rate_summ
end

Player.GetCountCard = function( self, lobby_id )
    local count = 0
    local lobby_id = GetPlayerLobbyID( self )
    for k, v in pairs( ROOMS[ lobby_id ].players[ self ].cards ) do
        count = count + 1
    end
    return count
end

-------------------------------------------------
-- Результат ставки
-------------------------------------------------

Player.GetBlackJackResult = function( self, dealer_card_summ )
    local result_amount = 0
    local lobby_id = GetPlayerLobbyID( self )
    local game_result = BLACK_JACK_RESULT_AFK
    local player_rate = self:GetPlayerRateSumm()
    local player_card_summ = self:GetCardSumm()
    
    local is_black_jack = IsBlackJack( self:GetCardSumm(), self:GetCountCard() )
    if player_rate > 0 then
        if IsBlackJack( dealer_card_summ, #ROOMS[ lobby_id ].dealer_cards ) or ((player_card_summ < dealer_card_summ and dealer_card_summ < MAX_WIN_CARD_SUMM) or player_card_summ > MAX_WIN_CARD_SUMM) then
            result_amount = -player_rate
            game_result = BLACK_JACK_RESULT_LOSE
        elseif player_card_summ > dealer_card_summ or is_black_jack or dealer_card_summ > MAX_WIN_CARD_SUMM then
            if is_black_jack then
                result_amount = player_rate * 2.5
            else
                result_amount = player_rate * 2
            end
            game_result = BLACK_JACK_RESULT_WIN
        elseif dealer_card_summ == player_card_summ then
            result_amount = player_rate
            game_result = BLACK_JACK_RESULT_DRAW
        end
    end

    return result_amount, game_result, is_black_jack
end

Player.ShowResultForRouletteRate = function( self, lobby_id, dealer_card_summ )
    local player_result_amount, game_result, is_black_jack = self:GetBlackJackResult( dealer_card_summ )

    local player_data = ROOMS[ lobby_id ].players[ self ]
    
    local player_rate = self:GetPlayerRateSumm()
    player_data.bet_sum = player_data.bet_sum + player_rate

    if game_result == BLACK_JACK_RESULT_DRAW then
        player_data.afk_rounds = 0
        self:GiveMoney( player_result_amount, "casino", "blackjack_participate" )    
    elseif game_result == BLACK_JACK_RESULT_WIN then
        player_data.afk_rounds = 0
        self:GiveMoney( player_result_amount, "casino", "blackjack_participate" )

        local real_win_amount = player_result_amount - player_rate
        self:AddCasinoGameWinAmount( ROOMS[ lobby_id ].casino_id, CASINO_GAME_BLACK_JACK, real_win_amount )

        player_data.win_count_bet = player_data.win_count_bet + 1
        player_data.reward_sum = player_data.reward_sum + real_win_amount
    elseif game_result == BLACK_JACK_RESULT_LOSE then
        player_data.afk_rounds = 0
        player_data.lost_count_bet = player_data.lost_count_bet + 1

        self:AddCasinoGameLoseAmount( player_rate )
    end

    if game_result ~= BLACK_JACK_RESULT_AFK then
        triggerClientEvent( self, "onClientPlayerShowResultRate", resourceRoot, 
        {
            game_result      = game_result,
            game_rate_result = math.abs( player_result_amount ),
            is_black_jack    = is_black_jack,
        } )

        player_data.round_count = player_data.round_count + 1
    
        triggerEvent( "onCasinoPlayersGame", root, CASINO_GAME_BLACK_JACK, { self } )
        if player_rate == MAX_RATES[ ROOMS[ lobby_id ].casino_id ] then
            triggerEvent( "onCasinoPlayerMaxBet", self, ROOMS[ lobby_id ].casino_id, CASINO_GAME_BLACK_JACK )
        end

        -- Retention task "blackjack10"
	    triggerEvent( "onBlackJackPlay", self )
    else
        player_data.afk_rounds = player_data.afk_rounds + 1
    end
    
    return player_result_amount, game_result
end