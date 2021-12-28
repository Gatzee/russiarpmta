
function onCasinoBoneStart( player, casino_name, unic_game_id, game_id )
    SendElasticGameEvent( player:GetClientID( ), "casino_bone_start", {
        casino_name  = tostring( casino_name ),
        unic_game_id = tostring( unic_game_id ),
        current_lvl  = tonumber( player:GetLevel() ),
        game_type    = tostring( CASINO_GAME_STRING_IDS[ game_id ] ),
    } )
end

function onCasinoBoneLeave( player, player_quantity, room_data, player_data, leave_reason )
    local game_duration = getRealTimestamp() - player_data.start_time
    SendElasticGameEvent( player:GetClientID( ), "casino_bone_leave", {
        unic_game_id    = tostring( room_data.unic_game_id ),
        current_lvl     = tonumber( player:GetLevel() ),
        player_quantity = tonumber( player_quantity ),
        commision_sum   = tonumber( room_data.commision or 0 ),
        bet_sum         = tonumber( player_data.bet ),
        reward_sum      = tonumber( player_data.reward_sum ),
        currency        = "soft",
        is_create       = tostring( player_data.is_create ),
        is_win          = tostring( player_data.is_win ),
        game_duration   = tonumber( game_duration ),
        leave_reason    = tostring( leave_reason ),
    } )
end