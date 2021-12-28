
function onChristmasAuctionShowfirst( player )
    SendElasticGameEvent( player:GetClientID( ), "christmas_auction_showfirst" )
end

function onChristmasAuctionBet( player )
    SendElasticGameEvent( player:GetClientID( ), "christmas_auction_bet", 
    { 
        bet_sum  = tonumber( player:GetPlayerRate() ),
        bet_num  = tonumber( player:GetRateNum() ),
        bet_paid = tonumber( player:GetDonateSumToDrop() ),
        currency = "hard"
    } )
end

function onChristmasAuctionFinish( client_id, bet_sum, is_bet_won )
    SendElasticGameEvent( client_id, "christmas_auction_finish", 
    { 
        bet_sum    = tonumber( bet_sum ),
        is_bet_won = tostring( is_bet_won ),
        currency   = "hard"
    } )
end