function getPremiumTime( premium_time_left, duration )
    local timestamp = getRealTimestamp( )
    if premium_time_left < timestamp then
        premium_time_left = timestamp + duration * 24 * 60 * 60
    else
        premium_time_left = premium_time_left + duration * 24 * 60 * 60
    end
    return premium_time_left
end

function onPremiumRecieve( client_id, duration, transaction, profit, is_game_purchase, sum )
    if not tonumber( duration ) or tonumber( duration ) <= 0 then return false end
    
    if TRANSACTIONS_CACHE[ transaction ] then
		WriteLog( "premium", "TRANSACTION_DUPLICATE: Ошибка принятия подписки %s, client_id: %s", tostring( duration ), tostring( client_id ) )
		return false
	end

    local player = GetPlayerFromClientID( client_id )

    local level, uid, nickname
    
    if isElement( player ) and player:IsInGame() then
        local premium_time_left = getPremiumTime( player:GetPermanentData( "premium_time_left" ) or 0, duration )
        player:SetPremiumExpirationTime( premium_time_left )
        player:ShowSuccess( "Спасибо за покупку!\nПремиум успешно куплен!" )
        level, uid, nickname = player:GetLevel( ), player:GetUserID( ), player:GetNickName( )
        
        WriteLog( "premium", "%s премиум на %s д., client_id: %s", player, duration, client_id )
    else
        local result = dbPoll( DB:query( "SELECT id, level, nickname, premium_time_left FROM nrp_players WHERE client_id=? LIMIT 1", client_id ), -1 )
        local premium_time_left = getPremiumTime( result[ 1 ].premium_time_left, duration )
        level, uid, nickname = tonumber( result[ 1 ].level ), tonumber( result[ 1 ].id ), result[ 1 ].nickname
        
        DB:exec( "UPDATE nrp_players SET premium_time_left=?, premium_total=`premium_total`+?, premium_transactions=`premium_transactions`+1, premium_last_date=? WHERE client_id=? LIMIT 1", 
            premium_time_left, duration, getRealTimestamp( ), client_id )
        
        WriteLog( "premium", "OFFLINE: %s премиум на %s д., client_id: %s", result[ 1 ].nickname, duration, client_id )
    end
    
    TRANSACTIONS_CACHE[ transaction ] = true

    -- Любой платеж
    local sum = sum or PREMIUM_SETTINGS.cost_by_duration[ duration ]
	triggerEvent( "onPlayerPayment", root, client_id, level, sum, transaction, uid, nickname, "premium_purchase_" .. ( tonumber( is_game_purchase ) == 1 and "web" or "game" ) )

	return true
end