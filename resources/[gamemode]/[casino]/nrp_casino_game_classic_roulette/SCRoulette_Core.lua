
-------------------------------------------------
-- Функционал итераций игры
-------------------------------------------------

function StartGame( player, room_id )
    LobbySet( room_id, "state", CASINO_STATE_PLAYING )
    SetCurrentIterationGame( room_id, CR_STATE_RATE )
end

function OnIterationComplete( room_id, state )
    local room_data = ROOMS[ room_id ]
    CheckAFKPlayers( room_id )
    if not isTimer( room_data.iteration.timer ) then return end
    
    -- Закончилось время вращения шарика
    if state == CR_STATE_ROTATE_DIAL then
        
        local player_list = GetPlayersList( room_id )
        for k, v in pairs( player_list ) do
            
            local winning_amount = v:ShowResultForRouletteRate( room_id )
            if winning_amount ~= 0 then
                local winner_player_nickanme = v:GetNickName()
                for _, player in pairs( player_list ) do
                    outputChatBox( "Игрок " .. winner_player_nickanme .. " выиграл " .. format_price( winning_amount ) .. "р.", player, 255, 100, 0 )
                end
            end

            room_data.players[ v ].rates = {}
        end
        
        if #room_data.last_win_fields == 5 then
            for i = 1, 4 do
                room_data.last_win_fields[ i ] = room_data.last_win_fields[ i + 1 ]
            end
            room_data.last_win_fields[ 5 ] = room_data.win_field
        else
            table.insert( room_data.last_win_fields, room_data.win_field )
        end
    -- Закончилось время ставок
    elseif state == CR_STATE_RATE then
        room_data.win_field = GenerateRandomWinField()
        triggerClientEvent( GetPlayersList( room_id ), "onClientChangeClassicRouletteState", resourceRoot, 
        {
            current_state = CR_STATE_ROTATE_DIAL,
            win_field = room_data.win_field,
            time_left_iteration = DURATION_STATE[ CR_STATE_ROTATE_DIAL ] * 1000,
        } )

        local player_list = GetPlayersList( room_id )
        for k, v in pairs( player_list ) do
            local player_data = room_data.players[ v ]
            local summ_rate = v:GetSummRate( player_data.rates )
            if summ_rate ~= 0 then
                for _, player in pairs( player_list ) do
                    if v ~= player then
                        outputChatBox( "Игрок " .. v:GetNickName() .. " поставил " .. format_price( summ_rate ) .. "р.", player, 255, 145, 0 )
                    end
                end
            end
        end
    elseif state == CR_STATE_SHOW_RESULTS then
        triggerClientEvent( GetPlayersList( room_id ), "onClientChangeClassicRouletteState", resourceRoot,
        {
            current_state = CR_STATE_RATE,
            win_list = exports.nrp_casino_lobby:GetCasinoTopStatRows( room_data.casino_id, room_data.game, 5 ),
            time_left_iteration = DURATION_STATE[ CR_STATE_RATE ] * 1000,
        } )
    end

end

function CheckAFKPlayers( room_id )
    local room_data = ROOMS[ room_id ]
    if not room_data then return end
    
    for k, v in pairs( GetPlayersList( room_id ) ) do
        local player_data = room_data.players[ v ]
        if player_data.afk_rounds >= 9 then
            triggerEvent( "onClassicRouletteTableLeaveRequest", v, room_id, false, "afk" )
            triggerEvent( "onCasinoPlayerBlockLobbyJoin", v )
            v:ShowError( "Вас выгнали из игры за бездействие" )
        end
    end
end

-------------------------------------------------
-- Функционал итераций игры
-------------------------------------------------

function SetNextIterationGame( room_id )
    local current_state = ROOMS[ room_id ].iteration.state
    local next_state = ROOMS[ room_id ].iteration.state + 1
    if not DURATION_STATE[ next_state ] then
        next_state = CR_STATE_RATE
    end
    SetCurrentIterationGame( room_id, next_state )
    OnIterationComplete( room_id, current_state )
end

function SetCurrentIterationGame( room_id, state )
    ROOMS[ room_id ].iteration.state = state
    ROOMS[ room_id ].iteration.timer = setTimer( SetNextIterationGame, DURATION_STATE[ state ] * 1000, 1, room_id )
end

function GetCurrentIterationGame( room_id )
    return ROOMS[ room_id ].iteration
end

function StopIterationGame( room_id )
    if isTimer( ROOMS[ room_id ].iteration.timer ) then
        killTimer( ROOMS[ room_id ].iteration.timer )
    end
    ROOMS[ room_id ].last_win_fields = {}
    ROOMS[ room_id ].iteration.state = CR_STATE_RATE
    ROOMS[ room_id ].win_field = nil
end

-------------------------------------------------
-- Функционал обработки ставок
-------------------------------------------------

addEvent( "onServerPlayerTryAddRate", true )
addEventHandler( "onServerPlayerTryAddRate", resourceRoot, function( field_id, chip )
    local room_id = GetPlayerLobbyID( client )
    local room_data = ROOMS[ room_id ]
    if not room_data then return end

    if room_data.iteration.state ~= CR_STATE_RATE then
        client:ShowError( "Время ставок закончено" )
        return
    end

    local cur_rate = RATES_VALUES[ room_data.casino_id ][ room_data.game ][ chip ]
    local new_sum_rate = client:GetSummRate( room_data.players[ client ].rates or {} ) + cur_rate
    if new_sum_rate > MAX_RATES[ room_data.casino_id ][ room_data.game ] then
        client:ShowError( "Максимальная ставка " .. format_price( MAX_RATES[ room_data.casino_id ][ room_data.game ] ) .. "р." )
        return
    end

    if not client:HasRateValue( room_data.bet_hard, cur_rate ) then
        client:ShowError( "У тебя недостаточно средств для ставки!" )
        return false
    end

    local number_used_cells, current_exist = client:GetUsedCells( field_id )
    if number_used_cells + current_exist > 15 then
        client:ShowError( "Ставку можно сделать только на 15 ячеек" )
        return
    end

    if client:TakeRateValue( room_data.bet_hard, RATES_VALUES[ room_data.casino_id ][ room_data.game ][ chip ] ) then
        local result = client:AddRate( field_id, chip )
        if not result then return end

        triggerClientEvent( client, "onClientSuccessAddRate", resourceRoot, field_id, chip )
    else
        client:ShowError( "У тебя недостаточно средств для ставки!" )
    end
end )

addEvent( "onServerPlayerTryRemoveRate", true )
addEventHandler( "onServerPlayerTryRemoveRate", resourceRoot, function( field_id, chip )
    local room_id = GetPlayerLobbyID( client )
    if not room_id then return end
    
    local room_data = ROOMS[ room_id ]
    if not room_data then return end

    if room_data.iteration.state ~= CR_STATE_RATE then
        client:ShowError( "Время ставок закончено" )
        return
    end

    local result = client:RemoveRate( field_id, chip )
    if result.success then
        client:ReturnRateValue( room_data.bet_hard, result.rate_value )
        triggerClientEvent( client, "onClientSuccessRemoveRate", resourceRoot, field_id, chip )
    else
        client:ShowError( "Ставка не найдена" )
    end
end )