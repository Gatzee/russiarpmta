

function onFightClubWin( player, commision_sum, reward_sum )
    SendElasticGameEvent( player:GetClientID(), "fc_win", { 
        commision_sum  = tonumber( commision_sum ),
        reward_sum = tonumber( reward_sum ),
        currency   = "soft",
    } )
end

function onFightClubTournamentWin( client_id, reward_sum )
    SendElasticGameEvent( client_id, "fc_tournament_win", { 
        reward_sum = reward_sum,
        currency   = "soft",
    } )
end

function onFightClubBet( client_id, bet_sum, fighter_id, is_win, reward_sum )
    SendElasticGameEvent( client_id, "fc_bet", { 
        bet_sum    = tonumber( bet_sum ),
        fighter_id = tostring( fighter_id ),
        is_win     = tostring( is_win ),
        reward_sum = tonumber( reward_sum ),
        currency   = "soft",
    } )
end