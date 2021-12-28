
-------------------------------------------------
-- Общий вспомогательный функционал
-------------------------------------------------

function GetPlayersList( room_id )
    local players = GetPlayers( room_id )
    
    local players_list = { }
    for player, v in pairs( players ) do
        if isElement( player ) and GetPlayerLobbyID( player ) == room_id then
            table.insert( players_list, player )
        end
    end

    return players_list
end

function GetPlayers( room_id )
    return table.copy( ROOMS[ room_id ] and ROOMS[ room_id ].players or { } )
end

function GenerateRandomWinField()
    return math.random( 1, 37 )
end

function CheckForStopGame( room_id )
    local pRoom = ROOMS[ room_id ]
    if not pRoom then return end

    if #GetPlayersList( room_id ) == 0 then
        ROOMS[ room_id ].players = nil
        StopIterationGame( room_id )
    end
end

-------------------------------------------------
-- Вспомогательный функционал для игроков
-------------------------------------------------

Player.SpawnPlayerOnTable = function( self, room_id, position, casino_id, max_players_count )
    fadeCamera( self, false, 0 )
    setTimer( fadeCamera, 300, 1, self, true, 1 )
    
    local casino_interior =
    {
        [ CASINO_THREE_AXE ] = 1,
        [ CASINO_MOSCOW ] = 4,
    }

    self.dimension = 660 * casino_interior[ casino_id ] + room_id
    self.interior  = casino_interior[ casino_id ]
    self.position  = position
    
    local new_rotation_vector = LOOKAT[ casino_id ] - position
    
    local dd_rotation_vector = Vector2( new_rotation_vector.x, new_rotation_vector.y ):getNormalized()
    local rotation_angle = -math.deg( math.atan2( dd_rotation_vector.x, dd_rotation_vector.y ) )    
    setElementRotation( self, 0, 0, rotation_angle )

    self:SetPrivateData( "in_casino", true )
    if max_players_count == 40 then
        self:setData( "cr_big_room", true, false )
        self:SetPrivateData( "cr_big_room", true )
    end
    addEventHandler("onPlayerWasted", self, OnPlayerWasted_handler)

    self:CompleteDailyQuest( "play_casino" )

    -- Инициализация интерфейса на клиенте
    local room_data = ROOMS[ room_id ]
    local time_left_iteration = getTimerDetails( room_data.iteration.timer )
    triggerClientEvent( self, "OnCasinoGameClassicRouletteStarted", resourceRoot, 
    {
        current_state = room_data.iteration.state,
        time_left_iteration = time_left_iteration,
        win_list = exports.nrp_casino_lobby:GetCasinoTopStatRows( room_data.casino_id, room_data.game, 5 ),
        win_field = room_data.win_field or false,
        casino_id = room_data.casino_id,
        game = room_data.game,
    })
end

Player.RemovePlayerFromTable = function( self, room_id, lobby_conf, from_destroy, leave_reason )
    self:SetPrivateData( "in_casino", false )
    local room_data = ROOMS[ room_id ] 
    if room_data then

        onCasinoRouletteLeave( self, #GetPlayersList( room_id ), room_data, room_data.players[ self ], leave_reason, room_data.bet_hard )
        room_data.players[ self ] = nil
        self:setData( "cr_big_room", nil, false )
        self:SetPrivateData( "cr_big_room", false )

        removeEventHandler( "onPlayerWasted", self, OnPlayerWasted_handler)
        CheckForStopGame( room_id )
        
        -- Уничтожение интерфейса на клиенте
        local is_restarting = lobby_conf.restarting
        triggerClientEvent( self, "OnCasinoGameClassicRouletteLeaved", resourceRoot, is_restarting )
    end
end

Player.AddRate = function( self, field_id, chip )
    local room_id = GetPlayerLobbyID( self )
    local room_data = ROOMS[ room_id ]
    if not room_data or not ROULETTE_FIELDS[ field_id ] or not chip then return false end

    local roulette_field = table.copy( ROULETTE_FIELDS[ field_id ] )
    roulette_field.chip = chip
    roulette_field.rate_value = RATES_VALUES[ room_data.casino_id ][ room_data.game ][ chip ]
    table.insert( room_data.players[ self ].rates, roulette_field )

    return true
end

Player.RemoveRate = function( self, field_id, chip )
    if not ROULETTE_FIELDS[ field_id ] or not chip then return false end

    local result = {}
    local room_id = GetPlayerLobbyID( self )
    for k, v in pairs( ROOMS[ room_id ].players[ self ].rates ) do
        if v.id == field_id and v.chip == chip then
            result = table.copy( ROOMS[ room_id ].players[ self ].rates[ k ] )
            result.success = true
            table.remove( ROOMS[ room_id ].players[ self ].rates, k )
            break
        end
    end
    return result
end

Player.TakeRateValue = function( self, is_bet_hard, rate_value )
    if is_bet_hard then
        return self:TakeDonate( rate_value, "casino", "hard_classic_roulette_participate" )
    else
        return self:TakeMoney( rate_value, "casino", "classic_roulette_participate" )
    end
    return false
end

Player.HasRateValue = function( self, is_bet_hard, rate_value )
    if is_bet_hard then
        return self:HasDonate( rate_value )
    else
        return self:HasMoney( rate_value )
    end
    return false
end

Player.ReturnRateValue = function( self, is_bet_hard, rate_value )
    if is_bet_hard then
        return self:GiveDonate( rate_value, "casino", "hard_classic_roulette_participate" )
    else
        return self:GiveMoney( rate_value, "casino", "classic_roulette_participate" )
    end
    return false
end

Player.GetWinningAmount = function( self, rate_data )
    local amount = 0
    local room_id = GetPlayerLobbyID( self )
    for k, v in pairs( rate_data ) do
        local field_data = ROULETTE_FIELDS[ ROOMS[ room_id ].win_field ]
        if (v.type == CR_RED_ALL and field_data.type == CR_RED) or (v.type == CR_BLACK_ALL and field_data.type == CR_BLACK) then
            amount = amount + v.rate_value * 2
        elseif v.id == ROOMS[ room_id ].win_field then
            amount = amount + v.rate_value * 35
        end
    end
    return amount
end

Player.GetLoseAmount = function( self, rate_data )
    local amount = 0
    local room_id = GetPlayerLobbyID( self )
    for k, v in pairs( rate_data ) do
        local field_data = ROULETTE_FIELDS[ ROOMS[ room_id ].win_field ]
        if (v.type == CR_RED_ALL and field_data.type ~= CR_RED) or (v.type == CR_BLACK_ALL and field_data.type ~= CR_BLACK) then
            amount = amount + v.rate_value
        elseif v.id ~= ROOMS[ room_id ].win_field then
            amount = amount + v.rate_value
        end
    end
    return amount
end

Player.GetSummRate = function( self, rate_data )
    local amount = 0
    for k, v in pairs( rate_data ) do
        amount = amount + v.rate_value
    end
    return amount
end

Player.GetUsedCells = function( self, field_id )
    local hash = {}
    local number_used_cells = 0
    local current_exist = 1
    local room_id = GetPlayerLobbyID( self )
    for k, v in pairs( ROOMS[ room_id ].players[ self ].rates ) do
        if not hash[ v.id ] then
            if field_id == v.id then
                current_exist = 0
            end
            hash[ v.id ] = true
            number_used_cells = number_used_cells + 1
        end
    end
    return number_used_cells, current_exist
end

Player.ShowResultForRouletteRate = function( self, room_id )
    local room_data = ROOMS[ room_id ]
    local player_data = room_data.players[ self ]
    local player_rate = self:GetSummRate( player_data.rates )
    player_data.bet_sum = (player_data.bet_sum or 0) + player_rate

    local lose_amount = self:GetLoseAmount( player_data.rates )
    local winning_amount = math.floor( self:GetWinningAmount( player_data.rates ) )
    
    local is_win = false
    local win_amount = false
    
    if winning_amount > 0 then
        if room_data.bet_hard then
            self:GiveDonate( winning_amount, "casino", "hard_classic_roulette_participate" )
        else
            self:GiveMoney( winning_amount, "casino", "classic_roulette_participate" )
        end

        self:AddCasinoGameWinAmount( room_data.casino_id, room_data.game, winning_amount )

        local real_win = winning_amount - lose_amount
        if real_win > 0 then
            
            player_data.reward_sum = (player_data.reward_sum or 0) + winning_amount
            player_data.win_count_bet = (player_data.win_count_bet or 0) + 1
        else
            player_data.lost_count_bet = (player_data.lost_count_bet or 0) + 1
        end

        is_win = true
        win_amount = winning_amount

        
    elseif lose_amount > 0 then
        player_data.lost_count_bet = (player_data.lost_count_bet or 0) + 1

        self:AddCasinoGameLoseAmount( lose_amount )
    else
        player_data.afk_rounds = player_data.afk_rounds + 1
    end

    if lose_amount > 0 or winning_amount > 0 then
        triggerEvent( "onCasinoPlayersGame", root, room_data.game, { self } )
        player_data.afk_rounds = 0

        if player_rate == MAX_RATES[ room_data.casino_id ][ room_data.game ] then
            triggerEvent( "onCasinoPlayerMaxBet", self, room_data.casino_id, room_data.game )
        end
        
        -- Retention task "roulette10"
        triggerEvent( "onRoulettePlay", self )
    end

    triggerClientEvent( self, "onClientPlayerShowResultRate", resourceRoot,
    {
        is_win          = is_win,
        win_amount      = win_amount, 
        win_field       = room_data.win_field,
        last_win_fields = room_data.last_win_fields,
        game            = room_data.game,
    } )

    return winning_amount
end

function OnPlayerWasted_handler()
    local room_id = GetPlayerLobbyID( source )
    if ROOMS[ room_id ] then
        triggerEvent( "onClassicRouletteTableLeaveRequest", source, room_id, false, "wasted" )
    end
end
