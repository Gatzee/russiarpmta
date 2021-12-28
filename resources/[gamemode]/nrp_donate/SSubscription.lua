function getSubscriptionTime( subscription_time_left, duration )
    local timestamp = getRealTime().timestamp
    if subscription_time_left < timestamp then
        subscription_time_left = timestamp + duration * 24 * 60 * 60
    else
        subscription_time_left = subscription_time_left + duration * 24 * 60 * 60
    end
    return subscription_time_left
end

function onSubscriptionRecieve( client_id, duration, transaction, profit, is_game_purchase, sum )
    if not tonumber( duration ) or tonumber( duration ) <= 0 then return false end
    
    if TRANSACTIONS_CACHE[ transaction ] then
		WriteLog( "subscription", "TRANSACTION_DUPLICATE: Ошибка принятия подписки %s, client_id: %s", tostring( duration ), tostring( client_id ) )
		return false
	end

    local player = GetPlayerFromClientID( client_id )

    local level, uid, nickname
    
    if isElement( player ) and player:IsInGame() then
        player:GiveSubscription( duration )
        player:ShowSuccess( "Спасибо за покупку!\nПодписка успешно куплена!" )
        level, uid, nickname = player:GetLevel( ), player:GetUserID( ), player:GetNickName( )
        
        WriteLog( "subscription", "%s подписка на %s д., client_id: %s", player, duration, client_id )
    else
        local result = dbPoll( DB:query( "SELECT id, level, nickname, subscription_time_left FROM nrp_players WHERE client_id=? LIMIT 1", client_id ), -1 )
        local subscription_time_left = getSubscriptionTime( result[ 1 ].subscription_time_left, duration )
        level, uid, nickname = tonumber( result[ 1 ].level ), tonumber( result[ 1 ].id ), result[ 1 ].nickname
        
        DB:exec( "UPDATE nrp_players SET subscription_time_left=?, subscription_total=`subscription_total`+?, subscription_transactions=`subscription_transactions`+1, subscription_last_date=? WHERE client_id=? LIMIT 1", 
            subscription_time_left, duration, getRealTime().timestamp, client_id )
        
        WriteLog( "subscription", "OFFLINE: %s подписка на %s д., client_id: %s", result[ 1 ].nickname, duration, client_id )
    end
    
    TRANSACTIONS_CACHE[ transaction ] = true

    -- Любой платеж
	triggerEvent( "onPlayerPayment", root, client_id, level, profit, transaction, uid, nickname, "subscription_purchase_" .. ( tonumber( is_game_purchase ) == 1 and "web" or "game" ) )

	return true
end