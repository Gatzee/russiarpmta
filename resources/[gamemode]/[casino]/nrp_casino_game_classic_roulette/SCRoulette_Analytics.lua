
function onCasinoRouletteStart( player, casino_name, unic_game_id, game_id, is_vip )
    SendElasticGameEvent( player:GetClientID( ), "casino_roulette_start", {
        casino_name  = tostring( casino_name ),
        unic_game_id = tostring( unic_game_id ),
        current_lvl  = tonumber( player:GetLevel() ),
        game_type    = tostring( CASINO_GAME_STRING_IDS[ game_id ] ),
        type         = is_vip and "VIP" or "Common",
        currency     = is_vip and "hard" or "soft",
    } )
end

function onCasinoRouletteLeave( player, player_quantity, room_data, player_data, leave_reason, is_vip )
    local game_duration = getRealTimestamp() - player_data.start_time
    local lost_sum = player_data.bet_sum - player_data.reward_sum
    SendElasticGameEvent( player:GetClientID( ), "casino_roulette_leave", {
        unic_game_id    = tostring( room_data.unic_game_id ),
        current_lvl     = tonumber( player:GetLevel() ),
        player_quantity = tonumber( player_quantity ),
        bet_sum         = tonumber( player_data.bet_sum ),
        reward_sum      = tonumber( player_data.reward_sum ),
        lost_sum        = tonumber( lost_sum > 0 and lost_sum or 0 ),
        lost_count_bet  = tonumber( player_data.lost_count_bet ),
        win_count_bet   = tonumber( player_data.win_count_bet ),
        currency        = is_vip and "hard" or "soft",
        game_duration   = tonumber( game_duration ),
        leave_reason    = tostring( leave_reason ),
        type            = is_vip and "VIP" or "Common",
    } )
end