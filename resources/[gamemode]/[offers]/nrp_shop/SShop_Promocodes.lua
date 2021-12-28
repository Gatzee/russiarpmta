PROMOCODE_USES_COUNTS_ON_SERVER = { }
BRUTEFORCE_BANS = { }
IS_PLAYER_WAITING_PROMOCODE_RESPONSE = { }

function onResourceStart_handler( )
    CommonDB:createTable( "nrp_promocodes_uses_count", 
        {
            { Field = "ckey"      , Type = "varchar(128)"     , Null = "NO", Key = "PRI" , };
            { Field = "count"     , Type = "int(11) unsigned" , Null = "NO", Key = ""    , };
            { Field = "server_id" , Type = "smallint(3)"      , Null = "NO", Key = "PRI" , };
        } 
    )

    CommonDB:queryAsync( function( query )
        local result = query:poll( -1 )
        if not result then return end
        for i, data in pairs( result ) do
            PROMOCODE_USES_COUNTS_ON_SERVER[ data.ckey ] = data.count
        end
    end, { }, "SELECT * FROM nrp_promocodes_uses_count WHERE server_id = ?", SERVER_NUMBER )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function onClientPromocodeApplyRequest_handler( ckey )
    local player = client
    if not player then return end

    if IS_PLAYER_WAITING_PROMOCODE_RESPONSE[ player ] then return end
    
    local timestamp = getRealTimestamp()
    local ban_data = BRUTEFORCE_BANS[ player ] or { }
    BRUTEFORCE_BANS[ player ] = ban_data

    if ban_data.time_end and timestamp < ban_data.time_end then 
        ban_data.time_end = timestamp + 60
        
        triggerClientEvent( player, "onPromocodeApplyCallback", player, "Bruteforce ban" )
        return false

    elseif ban_data.time_end then
        ban_data.time_end = nil
    end

    -- Проверка на заюзанность промокода
    local activated_codes = player:GetGlobalData( "activated_codes" ) or { }
    if activated_codes[ ckey ] then
        triggerClientEvent( player, "onPromocodeApplyCallback", player, "Used code" )
        return false
	end
	
	CommonDB:queryAsync( function( query )
        local result = query:poll( -1 )
		if not isElement( player ) then return end

		if not result or #result == 0 then
			ban_data.invalid_count = ( ban_data.invalid_count or 0 ) + 1
			if ban_data.invalid_count >= 3 then 
				ban_data.time_end = timestamp + 60
				triggerClientEvent( player, "onPromocodeApplyCallback", player, "Bruteforce ban" )
				return
			end

			triggerClientEvent( player, "onPromocodeApplyCallback", player, "Incorrect code" )
			return
		end

		local promocode = result[ 1 ]
		if promocode.is_blocked == 1 then 
			triggerClientEvent( player, "onPromocodeApplyCallback", player, "Incorrect code" )
			return false
		end

		-- Проверка срока действия
		if ( promocode.start_date or 0 ) > timestamp or ( promocode.end_date and promocode.end_date < timestamp ) then
			triggerClientEvent( player, "onPromocodeApplyCallback", player, "Incorrect code" )
			return false
		end
	
		-- Проверка на нового юзера
		local install_date = tonumber( player:GetGlobalData( "install_date" ) ) or 0
		if promocode.for_new_users == 1 and install_date + 48 * 60 * 60 < timestamp  then
			triggerClientEvent( player, "onPromocodeApplyCallback", player, "Incorrect code" )
			return false
		end
	
		-- Проверка на определенного игрока
		local client_ids = promocode.client_ids and fromJSON( promocode.client_ids )
		if client_ids and not client_ids[ player:GetClientID( ) ] then
			triggerClientEvent( player, "onPromocodeApplyCallback", player, "Incorrect code" )
			return false
		end
	
		-- Проверка на количество использований на сервер
		if promocode.max_server_uses_count and promocode.max_server_uses_count <= ( PROMOCODE_USES_COUNTS_ON_SERVER[ ckey ] or 0 ) then
			triggerClientEvent( player, "onPromocodeApplyCallback", player, "Incorrect code" )
			return false
		end
	
		-- Проверка на общее количество использований
		if promocode.max_uses_count then
			CommonDB:queryAsync( UpdatePromocodeUsesCount_callback, { player, promocode }, [[
				INSERT INTO nrp_promocodes_uses_count (ckey, count, server_id) VALUES (?, 1, ?)
					ON DUPLICATE KEY UPDATE count = CASE WHEN count >= ? THEN count ELSE count + 1 END;
			]], promocode.ckey, 0, promocode.max_uses_count )
	
			IS_PLAYER_WAITING_PROMOCODE_RESPONSE[ player ] = true
		else
			GivePromocodeRewards( player, promocode )
		end
    end, { }, "SELECT * FROM nrp_promocodes WHERE ckey = BINARY ? LIMIT 1", ckey )
end
addEvent( "onClientPromocodeApplyRequest", true )
addEventHandler( "onClientPromocodeApplyRequest", root, onClientPromocodeApplyRequest_handler )

function UpdatePromocodeUsesCount_callback( query, player, promocode )
    IS_PLAYER_WAITING_PROMOCODE_RESPONSE[ player ] = nil

    local result, num_affected_rows, last_insert_id = query:poll( -1 )
    if not result then return end

    if not isElement( player ) then
        if num_affected_rows > 0 then
            CommonDB:exec( "UPDATE nrp_promocodes_uses_count SET count = count - 1 WHERE ckey = ?", promocode.ckey )
        end
        return false
    end

    if num_affected_rows == 0 then
        triggerClientEvent( player, "onPromocodeApplyCallback", player, "Incorrect code" )
        return false
    end

    GivePromocodeRewards( player, promocode )
end

function GivePromocodeRewards( player, promocode )
    local rewards_info = MariaGet( "nrp_promocode_rewards" ) or { }
    
    if not rewards_info then
        player:ShowOverlay( OVERLAY_ERROR, { text = "Обратитесь в службу поддержки" } )
        return false
    end
    
    if promocode.max_server_uses_count then
        PROMOCODE_USES_COUNTS_ON_SERVER[ promocode.ckey ] = ( PROMOCODE_USES_COUNTS_ON_SERVER[ promocode.ckey ] or 0 ) + 1
        CommonDB:exec( [[
            INSERT INTO nrp_promocodes_uses_count (ckey, count, server_id) VALUES (?, 1, ?)
                ON DUPLICATE KEY UPDATE count = count + 1;
        ]], promocode.ckey, SERVER_NUMBER )
    end

    local rewards_cost = 0
    local rewards = fromJSON( promocode.rewards )
    local reward_func_args = { source = "promocode", source_type = promocode.ckey }
    for i, reward in pairs( rewards ) do
        local reward_info = rewards_info[ reward.id ]
        local reward_data = fromJSON( reward_info.data )
        local item = REGISTERED_ITEMS[ reward_data.id ]
        if item then
            if reward.count and reward_data.params.count then
                reward_data.params.count = reward.count
            end
            triggerClientEvent( player, "ShowPromocodeReward", player, reward_data )
            item.rewardPlayer_func( player, reward_data.params, reward_func_args )
        else
            outputDebugString( "Item config not found in ".. reward.id .. " -> " ..inspect( v ), 1 )
        end
        -- Для аналитики
        reward.name = reward_info.name
        rewards_cost = rewards_cost + ( reward_data.cost or 0 ) * ( reward_data.params.count or 1 )
    end
    
    -- Активация
    local activated_codes = player:GetGlobalData( "activated_codes" ) or { }
    activated_codes[ promocode.ckey ] = true
    player:SetGlobalData( "activated_codes", activated_codes )

    -- Аналитика:
    SendElasticGameEvent( player:GetClientID( ), "promocode_enter", 
	{ 
        promocode_id   = tostring( promocode.ckey ) ,
        promocode_type = tostring( promocode.type ) ,
        reward_id      = toJSON( rewards )          ,
        receive_sum    = math.floor( rewards_cost ) ,
        currency       = "hard"                     ,
    } )
end

function onPlayerQuit_handler()
    if not BRUTEFORCE_BANS[ source ] then return end

    BRUTEFORCE_BANS[ source ] = nil 
end
addEventHandler( "onPlayerQuit", root, onPlayerQuit_handler )