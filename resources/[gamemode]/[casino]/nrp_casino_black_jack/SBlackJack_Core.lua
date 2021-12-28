
-------------------------------------------------
-- Функционал итераций игры
-------------------------------------------------

function StartGame( player, lobby_id )
    LobbySet( lobby_id, "state", CASINO_STATE_PLAYING )
    SetCurrentIterationGame( lobby_id, BLACK_JACK_STATE_RATE )
end

function OnIterationStart( lobby_id, start_iteration )
    if start_iteration == BLACK_JACK_STATE_RATE then
        triggerClientEvent( GetPlayersList( lobby_id ), "onClientShowPlayerRateMenu", resourceRoot, {
            type = start_iteration,
            remaining_time = DURATION_ACTION[ start_iteration ] * 1000,
        } )
    elseif start_iteration == BLACK_JACK_STATE_ACTION_CARD then
        triggerClientEvent( GetPlayersList( lobby_id ), "onClientShowPlayerCardActionMenu", resourceRoot, {
            type      = start_iteration,
            remaining_time = DURATION_ACTION[ start_iteration ] * 1000,
            place_id  = ROOMS[ lobby_id ].players[ ROOMS[ lobby_id ].cur_player ].place_id,
            player    = ROOMS[ lobby_id ].cur_player,
        } )
    end
end

function OnIterationComplete( lobby_id, complete_iteration )
    if complete_iteration == BLACK_JACK_STATE_ACTION_CARD then
        local next_player_id, next_player = GetNextGamePlayer( lobby_id )
        if next_player_id == ROOMS[ lobby_id ].cur_player_id then

            if isTimer( ROOMS[ lobby_id ].iteration.sub_timer_action_1 ) then
                killTimer( ROOMS[ lobby_id ].iteration.sub_timer_action_1 )
            end

            ROOMS[ lobby_id ].iteration.sub_timer_action_1 = setTimer( function()
                triggerClientEvent( GetPlayersList( lobby_id ), "onClientDealerOpenCard", resourceRoot, ROOMS[ lobby_id ].dealer_cards )
                
                if isTimer( ROOMS[ lobby_id ].iteration.sub_timer_action_2 ) then
                    killTimer( ROOMS[ lobby_id ].iteration.sub_timer_action_2 )
                end

                ROOMS[ lobby_id ].iteration.sub_timer_action_2 = setTimer( OnGameRoundEnd, 2500, 1, lobby_id )
            end, 1000, 1 )
        else
            if ROOMS[ lobby_id ].cur_player and ROOMS[ lobby_id ].players[ ROOMS[ lobby_id ].cur_player ] then
                ROOMS[ lobby_id ].players[ ROOMS[ lobby_id ].cur_player ].state_game = -1
            end

            ROOMS[ lobby_id ].cur_player_id, ROOMS[ lobby_id ].cur_player = next_player_id, next_player
            ROOMS[ lobby_id ].players[ ROOMS[ lobby_id ].cur_player ].state_game = BLACK_JACK_STATE_ACTION_CARD
            SetCurrentIterationGame( lobby_id, BLACK_JACK_STATE_ACTION_CARD )
        end
    elseif complete_iteration == BLACK_JACK_STATE_RATE then
        GenerateDealerCards( lobby_id )

        for k, v in pairs( ROOMS[ lobby_id ].players ) do
            if k:GetPlayerRateSumm() > 0 then
                k:GenerateCards( lobby_id, 2 )
            end
        end
        OnIterationComplete( lobby_id, BLACK_JACK_STATE_ACTION_CARD )

        triggerClientEvent( GetPlayersList( lobby_id ), "onClientEndRateIteration", resourceRoot, 
        {
            dealer_cards      = GetShowDealerCards( lobby_id ),
            player_data_cards = CollectPlayerDataCards( lobby_id ),
        } )
    end
end

function SetNextIterationGame( lobby_id )
    local current_state = ROOMS[ lobby_id ].iteration.state
    local next_state = ROOMS[ lobby_id ].iteration.state + 1
    if not DURATION_ACTION[ next_state ] then
        next_state = BLACK_JACK_STATE_RATE
    end
    OnIterationComplete( lobby_id, current_state )
end

function SetCurrentIterationGame( lobby_id, state )
    ROOMS[ lobby_id ].iteration.state = state

    if isTimer( ROOMS[ lobby_id ].iteration.timer ) then
        killTimer( ROOMS[ lobby_id ].iteration.timer )
    end

    ROOMS[ lobby_id ].iteration.timer = setTimer( SetNextIterationGame, DURATION_ACTION[ state ] * 1000, 1, lobby_id )
    OnIterationStart( lobby_id, state )
end

function StopIterationGame( lobby_id )
    for i = 1, 3 do
        local id = "sub_timer_action_" .. i
        if isTimer( ROOMS[ lobby_id ].iteration[ id ] ) then
            killTimer( ROOMS[ lobby_id ].iteration[ id ] )
        end
    end

    if isTimer( ROOMS[ lobby_id ].iteration.timer ) then
        killTimer( ROOMS[ lobby_id ].iteration.timer )
    end
    ROOMS[ lobby_id ].iteration.state = nil
end

function StartNewRound( lobby_id )
    if not ROOMS[ lobby_id ] then return end
    local players = GetPlayersList( lobby_id )
    if #players == 0 then return end

    ROOMS[ lobby_id ].dealer_cards  = {}
    ROOMS[ lobby_id ].used_cards    = {}
    
    for k, v in pairs( ROOMS[ lobby_id ].players ) do
        v.rates = {}
        v.cards = {}
    end
        
    triggerClientEvent( players, "onClientStartNewRound", resourceRoot, 
    {
        player_data_cards = CollectPlayerDataCards( lobby_id ),
        winners_list      = exports.nrp_casino_lobby:GetCasinoTopStatRows( ROOMS[ lobby_id ].casino_id, ROOMS[ lobby_id ].game, 5 )
    } )
    
    ROOMS[ lobby_id ].cur_player_id, ROOMS[ lobby_id ].cur_player = 0, nil

    SetCurrentIterationGame( lobby_id, BLACK_JACK_STATE_RATE )
end

function OnGameRoundEnd( lobby_id )
    if not ROOMS[ lobby_id ].players then return end

    local result_variants =
    {
        [ BLACK_JACK_RESULT_WIN ]  = " выиграл ",
        [ BLACK_JACK_RESULT_LOSE ] = " проиграл ",
        [ BLACK_JACK_RESULT_DRAW ] = " выиграл ",
    }

    local dealer_card_summ = GetDealerCardSumm( lobby_id )
    for player, player_data in pairs( ROOMS[ lobby_id ].players ) do
        local winning_amount, game_result = player:ShowResultForRouletteRate( lobby_id, dealer_card_summ )
        if winning_amount > 0 then
            local player_nick = player:GetNickName()
            for plr in pairs( ROOMS[ lobby_id ].players ) do
                if plr ~= player then
                    outputChatBox( "Игрок " .. player_nick .. result_variants[ game_result ] .. format_price( winning_amount ) .. "р.", plr, 255, 100, 0 )
                end
            end
        end
    end
    CheckAFKPlayers( lobby_id )

    if isTimer( ROOMS[ lobby_id ].iteration.sub_timer_action_3 ) then
        killTimer( ROOMS[ lobby_id ].iteration.sub_timer_action_3 )
    end

    ROOMS[ lobby_id ].iteration.sub_timer_action_3 = setTimer( StartNewRound, 2000, 1, lobby_id )
end

function onServerPlayerTryAddRateBlackJack_handler( chip )
    local lobby_id = GetPlayerLobbyID( client )
    local lobby_data = ROOMS[ lobby_id ]
    if not lobby_data or not lobby_data.players[ client ] then return false end

    if lobby_data.iteration.state ~= BLACK_JACK_STATE_RATE then
        client:ShowError( "Время ставок закончено" )
        return
    end

    local rate_value = RATES_VALUES[ lobby_data.casino_id ][ chip ]
    local cur_sum = client:GetPlayerRateSumm() + rate_value
    if cur_sum > MAX_RATES[ lobby_data.casino_id ] then
        client:ShowError( "Максимальная ставка " .. MAX_RATES[ lobby_data.casino_id ] .. "р." )
        return
    end
    
    if client:TakeRateValue( rate_value ) then
        local result = client:AddRate( chip )
        triggerClientEvent( GetPlayersList( lobby_id ), "onClientSuccessAddRate", resourceRoot, 
        {
            player   = client,
            chip     = chip,
            place_id = lobby_data.players[ client ].place_id,
            rate     = cur_sum,
        } )
    else
        client:ShowError( "У Вас недостаточно средств для ставки!" )
    end
end
addEvent( "onServerPlayerTryAddRateBlackJack", true )
addEventHandler( "onServerPlayerTryAddRateBlackJack", resourceRoot, onServerPlayerTryAddRateBlackJack_handler )

function onServerPlayerTryRemoveRateBlackJack_handler( chip )
    local lobby_id = GetPlayerLobbyID( client )
    if not ROOMS[ lobby_id ].players[ client ] then return false end

    if ROOMS[ lobby_id ].iteration.state ~= BLACK_JACK_STATE_RATE then
        client:ShowError( "Время ставок закончено" )
        return
    end

    local return_rate = client:RemoveRate( chip )
    if return_rate then
        client:ReturnRateValue( return_rate )
        triggerClientEvent( GetPlayersList( lobby_id ), "onClientSuccessRemoveRate", resourceRoot, 
        {
            player   = client,
            chip     = chip,
            place_id = ROOMS[ lobby_id ].players[ client ].place_id,
            rate     = client:GetPlayerRateSumm(),
        } )
    else
        client:ShowError( "Ставка не найдена" )
    end
end
addEvent( "onServerPlayerTryRemoveRateBlackJack", true )
addEventHandler( "onServerPlayerTryRemoveRateBlackJack", resourceRoot, onServerPlayerTryRemoveRateBlackJack_handler )

function onServerPlayerActionCard_handler( action_id )
    local lobby_id = GetPlayerLobbyID( client )
    if not ROOMS[ lobby_id ] or not ROOMS[ lobby_id ].players[ client ] then return false end

    if ROOMS[ lobby_id ].cur_player ~= client or ROOMS[ lobby_id ].players[ client ].state_game ~= BLACK_JACK_STATE_ACTION_CARD then
        client:ShowError( "Время выбора закончено" )
        return
    end

    local suf_summ = false 
    if action_id == BLACK_JACK_ACTION_CARD_TAKE then
        client:GenerateCards( lobby_id, 1 )
        suf_summ = client:GetCardSumm() >= MAX_WIN_CARD_SUMM and true or false

        triggerClientEvent( GetPlayersList( lobby_id ), "onClientPlayerTakeCard", resourceRoot, {
            player   = client,
            place_id = ROOMS[ lobby_id ].players[ client ].place_id,
            cards    = ROOMS[ lobby_id ].players[ client ].cards,
            suf_summ = suf_summ,
        } )
    end

    if action_id == BLACK_JACK_ACTION_CARD_PASS or suf_summ then
        ROOMS[ lobby_id ].players[ client ].state_game = -1
        if isTimer( ROOMS[ lobby_id ].iteration.timer ) then
            killTimer( ROOMS[ lobby_id ].iteration.timer )
        end

        local next_player_id, next_player = GetNextGamePlayer( lobby_id )
        if next_player_id == ROOMS[ lobby_id ].cur_player_id then
            OnIterationComplete( lobby_id, BLACK_JACK_STATE_ACTION_CARD )
        else
            SetNextIterationGame( lobby_id )
        end
    end
end
addEvent( "onServerPlayerActionCard", true )
addEventHandler( "onServerPlayerActionCard", resourceRoot, onServerPlayerActionCard_handler )