-----------------------------
-- Оффлайн работа с донатом
--[[string.SetDonate = function( self, amount, source, source_type )
	local method = "GiveDonate:" .. tostring( source ) .. ":" .. tostring( source_type )
    DB:exec( "UPDATE nrp_players SET donate=? WHERE client_id=? LIMIT 1", value, self )
    return true
end]]

string.GiveDonate = function( self, amount, source, source_type )
    if amount <= 0 then return end
    local self, amount, source, source_type = self, amount, source, source_type
    DB:queryAsync( function( query )
        local result = query:poll( 0 )
        local balance = result[ 1 ].donate + amount
        SendElasticGameEvent( self, "in_game_income", { source_class = source, source_class_type = source_type, currency = "hard", sum = amount, balance = balance, current_lvl = ( result[ 1 ].level or 1 ) } )
        DB:exec( "UPDATE nrp_players SET donate=`donate`+? WHERE client_id=? LIMIT 1", amount, self )
    end, { }, "SELECT donate, level FROM nrp_players WHERE client_id=? LIMIT 1", self )
    return true
end

string.TakeDonate = function( self, amount, source, source_type )
    if amount <= 0 then return end
    local self, amount, source, source_type = self, amount, source, source_type
    DB:queryAsync( function( query )
        local result = query:poll( 0 )
        local balance = result[ 1 ].donate - amount
        SendElasticGameEvent( self, "in_game_outcome", { source_class = source, source_class_type = source_type, currency = "hard", sum = amount, balance = balance, current_lvl = ( result[ 1 ].level or 1 ) } )
        DB:exec( "UPDATE nrp_players SET donate=`donate`-? WHERE client_id=? LIMIT 1", amount, self )
    end, { }, "SELECT donate, level FROM nrp_players WHERE client_id=? LIMIT 1", self )
    return true
end

-----------------------------
-- Оффлайн работа с деньгами
--[[string.SetMoney = function( self, value, method )
	local method = method and tostring( method ) or "UNKNOWN:" .. THIS_RESOURCE_NAME
    WriteLog( "money/set", "[Server.SPlayerOffline.SetMoney] %s. Стало: %s. Вызов: %s", self, value, method )
    DB:exec( "UPDATE nrp_players SET money=? WHERE client_id=? LIMIT 1", value, self )
    return true
end]]

string.GiveMoney = function( self, amount, source, source_type )
    if amount <= 0 then return end
    local self, amount, source, source_type = self, amount, source, source_type
    DB:queryAsync( function( query )
        local result = query:poll( 0 )
        local balance = result[ 1 ].money + amount
        SendElasticGameEvent( self, "in_game_income", { source_class = source, source_class_type = source_type, currency = "soft", sum = amount, balance = balance, current_lvl = ( result[ 1 ].level or 1 ) } )
        DB:exec( "UPDATE nrp_players SET money=`money`+? WHERE client_id=? LIMIT 1", amount, self )
    end, { }, "SELECT money, level FROM nrp_players WHERE client_id=? LIMIT 1", self )
    return true
end

string.TakeMoney = function( self, amount, source, source_type )
    if amount <= 0 then return end
    local self, amount, source, source_type = self, amount, source, source_type
    DB:queryAsync( function( query )
        local result = query:poll( 0 )
        local balance = result[ 1 ].money - amount
        SendElasticGameEvent( self, "in_game_outcome", { source_class = source, source_class_type = source_type, currency = "soft", sum = amount, balance = balance, current_lvl = ( result[ 1 ].level or 1 ) } )
        DB:exec( "UPDATE nrp_players SET money=`money`-? WHERE client_id=? LIMIT 1", amount, self )
    end, { }, "SELECT money, level FROM nrp_players WHERE client_id=? LIMIT 1", self )
    return true
end

------------------------
-- Оффлайн уведомления
function _OFFLINE_PhoneNotification_Callback( query, client_id, notification )
    local result = query:poll( -1 )
    if not result[ 1 ] then return end

    local tbl = fromJSON( result[ 1 ].offline_notifications or "[[]]" ) or { }
    table.insert( tbl, notification )

    DB:exec( "UPDATE nrp_players SET offline_notifications=? WHERE client_id=? LIMIT 1", toJSON( tbl, true ), client_id )
end

string.PhoneNotification = function( self, notification )
    DB:queryAsync( _OFFLINE_PhoneNotification_Callback, { self, notification }, "SELECT offline_notifications FROM nrp_players WHERE client_id=? LIMIT 1", self )
end

-------------------
-- Чтение данных
string.GetNickName = function ( self )
    return exports.nrp_player_offline:GetOfflineDataFromClientID( self, "nickname" )
end

string.GetLevel = function ( self )
    return exports.nrp_player_offline:GetOfflineDataFromClientID( self, "level" )
end

string.GetID = function ( self )
    return exports.nrp_player_offline:GetOfflineDataFromClientID( self, "id" )
end

------------
-- Premium
string.GivePremiumExpirationTime = function( self, days )
    local function getPremiumTime( premium_time_left, duration )
        local timestamp = getRealTimestamp( )
        if premium_time_left < timestamp then
            premium_time_left = timestamp + duration * 24 * 60 * 60
        else
            premium_time_left = premium_time_left + duration * 24 * 60 * 60
        end
        return premium_time_left
    end
    
    local days = days
    DB:queryAsync( function( query )
        local result = query:poll( -1 )
        local value = result[ 1 ]
        local premium_time_left = getPremiumTime( value.premium_time_left, days )
        DB:exec( "UPDATE nrp_players SET premium_time_left=?, premium_total=`premium_total`+?, premium_transactions=`premium_transactions`+1, premium_last_date=? WHERE client_id=? LIMIT 1", 
            premium_time_left, days, getRealTimestamp( ), self )
        WriteLog( "premium", "OFFLINE: %s премиум на %s д., client_id: %s", value.nickname, days, self )
    end, { }, "SELECT id, level, nickname, premium_time_left FROM nrp_players WHERE client_id=? LIMIT 1", self )
end