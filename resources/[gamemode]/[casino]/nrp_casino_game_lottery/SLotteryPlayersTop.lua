Extend( "SDB" )

MAX_TOP_PLAYERS_COUNT = 10

TOP_PLAYERS = { }

function onResourceStart_handler( )
    for lottery_id in pairs( LOTTERIES_INFO ) do
        TOP_PLAYERS[ lottery_id ] = { }
    end
    
    DB:createTable( "nrp_casino_lottery",
        {
            { Field = "ckey",		Type = "varchar(128)",		Null = "NO",    Key = "PRI",	Default = ""	},
            { Field = "cvalue",		Type = "longtext",			Null = "YES",	Key = ""                        },
        }
    )

    DB:queryAsync( function( query )
        local result = dbPoll( query, -1 )
        if type( result ) == "table" and #result > 0 then
            for i, data in pairs( result ) do
                local lottery_id = data.ckey:match( "top_(.*)" )
                if lottery_id and LOTTERIES_INFO[ lottery_id ] then
                    TOP_PLAYERS[ lottery_id ] = FixTableKeys( fromJSON( data.cvalue ), true ) or { }
                end
            end
        end
    end, {}, "SELECT ckey, cvalue FROM nrp_casino_lottery" )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler, true, "high+9999999" )

function RefreshPlayersTop( player, reward )
    if not reward.lottery_id then return end

    local lottery_top_players = TOP_PLAYERS[ reward.lottery_id ]
    local insert_to_i = false
    local remove_i = false
    local top_players_count = #lottery_top_players
    local user_id = player:GetUserID( )

    for i = top_players_count, 1, -1 do
        local other_player_data = lottery_top_players[ i ]
        if reward.cost >= other_player_data[ LTP_REWARD_COST ] then
            insert_to_i = i
        end
        if other_player_data[ LTP_PLAYER_ID ] == user_id then
            remove_i = i
        end
    end

    if not insert_to_i and not remove_i and top_players_count < MAX_TOP_PLAYERS_COUNT then
        insert_to_i = top_players_count + 1
    end

    if insert_to_i and ( not remove_i or remove_i >= insert_to_i ) then
        -- Сначала удаляем, потом добавляем, иначе при insert_to_i == remove_i удалятся новые данные
        if remove_i then
            table.remove( lottery_top_players, remove_i )
        elseif top_players_count + 1 > MAX_TOP_PLAYERS_COUNT then
            lottery_top_players[ MAX_TOP_PLAYERS_COUNT ] = nil
        end

        local player_data = { }
        player_data[ LTP_PLAYER_ID ] = user_id
        player_data[ LTP_PLAYER_NAME ] = player:GetNickName( )
        player_data[ LTP_REWARD_TYPE ] = reward.type
        player_data[ LTP_REWARD_COST ] = reward.cost
        player_data[ LTP_REWARD_PARAMS ] = reward.params
        table.insert( lottery_top_players, insert_to_i, player_data )
        
        DB:exec( "REPLACE INTO nrp_casino_lottery ( ckey, cvalue ) VALUES ( ?, ? )", "top_" .. reward.lottery_id, toJSON( lottery_top_players, true ) )

        return true
    end

    return false
end

function onPlayerRequestLotteryPlayersTop_handler( lottery_id )
    local player = client
    triggerClientEvent( player, "onClientUpdateLotteryPlayersTop", resourceRoot, TOP_PLAYERS[ lottery_id ] )
end
addEvent( "onPlayerRequestLotteryPlayersTop", true )
addEventHandler( "onPlayerRequestLotteryPlayersTop", resourceRoot, onPlayerRequestLotteryPlayersTop_handler )