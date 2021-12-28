SEASON_WINNERS_DATA = { }

SEASON_STARTED = 1586041200 -- 05.04.20 - 02:00:00
SEASON_DURATION = 2 * 7 * 24 * 60 * 60 -- 2 недели
SEASON_NUMBER = 1

SEASON_MAX_NUMBER = 4

function InitWinners()
    DB:createTable( "nrp_race_season_winners", {
        { Field = "season_number",  Type = "int(11) unsigned", Null = "NO",	  }, -- последние победители сезона: --номер сезона
        { Field = "season_started", Type = "int(11) unsigned", Null = "NO",	  }, -- начало сезона
		{ Field = "season_data",    Type = "text",			   Null = "NO",	  }, --  client_id, place, race_type, veh_class_id
    } )

    LoadWinnersList()
end

function LoadWinnersList()
    DB:queryAsync( function( qh )
        local result = dbPoll( qh, -1 )
        if type( result ) == "table" and #result > 0 then
            result = result[ 1 ]
            SEASON_NUMBER  = result.season_number
            SEASON_STARTED = result.season_started
            for k, v in pairs( fromJSON( result.season_data ) or {} ) do
                table.insert( SEASON_WINNERS_DATA, {
                    client_id     = v.client_id,
                    user_id       = v.client_id:GetID( ),
                    nickname      = v.nickname,
                    place         = v.place,
                    points        = v.points,
                    race_type     = v.race_type,
                    veh_class_id  = v.veh_class_id,
                    season_number = v.season_number,
                } )
            end

            triggerClientEvent( GetPlayersInGame(), "OnClientRefreshWinnersData", root, SEASON_WINNERS_DATA )
        end
        
        SEASON_END = SEASON_STARTED + SEASON_DURATION
        StartSeasonTimer()
    end, {}, "SELECT * FROM nrp_race_season_winners ORDER BY season_started DESC LIMIT 1" )
end

function StartSeasonTimer()
    local timestamp = getRealTimestamp()
    local time_left = SEASON_END - timestamp
    if time_left > 0 then
        SEASON_TIMER = setTimer( OnSeasonEnd, time_left * 1000, 1 )
    else
        OnSeasonEnd()
    end
end

function OnSeasonEnd( )
    RefreshRecordsData( )
    
    SEASON_WINNERS_DATA = { }
    MERGED_REWARD_DATA = { }

    for race_type in pairs( SEASON_RACE_TYPES ) do
        for class_id, class_name in pairs( RACE_VEHICLE_CLASSES_NAMES ) do
            for i = 1, 3 do
                if RECORDS_DATA[ race_type ][ class_id ][ i ] then
                    local record = RECORDS_DATA[ race_type ][ class_id ][ i ]
                    table.insert( SEASON_WINNERS_DATA, {
                        client_id     = record.client_id,
                        nickname      = record.client_id:GetNickName(),
                        user_id       = record.client_id:GetID(),
                        place         = i,
                        points        = record[ "race_" .. RACE_TYPES_DATA[ race_type ].type .. "_points" ],
                        race_type     = race_type,
                        veh_class_id  = class_id,
                        season_number = SEASON_NUMBER,
                    } )

                    if not MERGED_REWARD_DATA[ record.client_id ] then
                        MERGED_REWARD_DATA[ record.client_id ] = {}
                    end
                    
                    table.insert( MERGED_REWARD_DATA[ record.client_id ], {
                        place         = i,
                        race_type     = race_type,
                        season_number = SEASON_NUMBER,
                        car_id        = record.model,
                        variant       = record.variant,
                    } )
                else
                    break
                end
            end
        end
    end

    local next_season_number = SEASON_NUMBER + 1
    SEASON_NUMBER  = next_season_number > SEASON_MAX_NUMBER and 1 or next_season_number
    SEASON_STARTED = SEASON_STARTED + SEASON_DURATION
    SEASON_END = SEASON_STARTED + SEASON_DURATION

    DB:queryAsync( function( qh )
		dbFree( qh )
	end, {}, "INSERT INTO nrp_race_season_winners ( season_number, season_started, season_data ) VALUES( ?, ?, ? )", SEASON_NUMBER, SEASON_STARTED, toJSON( SEASON_WINNERS_DATA ) )
    
    for k, v in pairs( MERGED_REWARD_DATA ) do
        DB:queryAsync( function( qh, client_id, reward_data )
            dbFree( qh )
            
            local player = GetPlayerFromClientID( client_id )
            if isElement( player ) and player:IsInGame() then
                triggerClientEvent( player, "ShowRaceSeasonRewardUI", resourceRoot, reward_data[ 1 ] )
            end
        end, { k, v }, "UPDATE nrp_players SET race_prizes = ? WHERE client_id = ?", toJSON( v ), k )
    end

    triggerClientEvent( GetPlayersInGame(), "OnClientRefreshWinnersData", root, SEASON_WINNERS_DATA )
    StartSeasonTimer()
    ResetStats()
end

function ResetStats()
    for k, v in pairs( getElementsByType( "vehicle" ) ) do
        v:SetPermanentData( "race_circle_count", 0 )
        v:SetPermanentData( "race_circle_points", 0 )

        v:SetPermanentData( "race_drift_count", 0 )
        v:SetPermanentData( "race_drift_points", 0 )

        v:SetPermanentData( "race_drag_count", 0 )
        v:SetPermanentData( "race_drag_points", 0 )
    end
    DB:exec( "UPDATE nrp_vehicles SET race_circle_count = 0, race_circle_points = 0, race_drift_count = 0, race_drift_points = 0, race_drag_count = 0, race_drag_points = 0" )
    LoadRecordsData()
end

function onPlayerShowReward_callback( qh, player )
    if not qh then return end
    
    if not isElement( player ) then
        dbFree( qh )
        return
    end

    local result = qh:poll( -1 )
    if type( result ) == "table" and #result > 0 then
        result = result[ 1 ]
        if not result or not result.race_prizes then return end

        local rewards = fromJSON( result.race_prizes ) or {}
        if rewards and #rewards > 0 then
            if #rewards > 1 then table.sort( rewards, function( a, b ) return a.place > b.place end ) end
            triggerClientEvent( player, "ShowRaceSeasonRewardUI", resourceRoot, rewards[ 1 ] )
        end
    end
end

function GivePlayerRewards( player, data )
    local reward_data = data[ 1 ]
    if not reward_data then return end
    
    for _, reward in pairs( SEASON_REWARD[ reward_data.season_number ][ reward_data.race_type ][ reward_data.place ] ) do
        local reward_value = reward.value
        local vehicle_class = tostring( reward_data.car_id ):GetTier( reward_data.variant )
        
        if reward.type == "vinil_case" then
            reward_value = string.format( "VINYL_CASE_%s_%s", reward_value, vehicle_class )
            player:GiveVinylCase( VINYL_CASE_TIERS_STR_CONVERT[ reward_value ], 1 )
        
        elseif reward.type == "tuning_case" then
            local subtypeOfCase = reward_data.race_type == RACE_TYPE_CIRCLE_TIME and INTERNAL_PART_TYPE_R or INTERNAL_PART_TYPE_F
            player:GiveTuningCase( reward_value, vehicle_class, subtypeOfCase, 1 )
        
        elseif reward.type == "vinil" then
            for i = 1, reward.count do
                player:GiveVinyl({ 
                    [ P_PRICE_TYPE ] = "race",
                    [ P_IMAGE ]      = reward_value,
                    [ P_CLASS ]      = vehicle_class,
                    [ P_NAME ]       = reward_value,
                    [ P_PRICE ]      = reward.cost,
                })
            end
        
        elseif reward.type == "accessories" then
            player:AddOwnedAccessory( reward_value )
        end
        
        SendElasticGameEvent( player:GetClientID(), "sessons_race_win", 
        { 
            id          = tonumber( player:GetUserID() ), 
            name        = tostring( player:GetNickName() ), 
            reward_id   = tostring( reward_value ),
            reward_cost = tonumber( reward.cost ) or 0,
            currency    = "soft",
            car_id      = tonumber( reward_data.car_id ),
            car_name    = tostring( VEHICLE_CONFIG[ reward_data.car_id ].model ),
            car_class   = tonumber( vehicle_class ),
            race_type   = tostring( RACE_TYPES_DATA[ reward_data.race_type ].type ),
        })
    end
    
    table.remove( data, 1 )

    DB:exec( "UPDATE nrp_players SET race_prizes = ? WHERE id = ?", toJSON( data ), player:GetUserID() )
    SendToLogserver( "Игрок " .. player:GetNickName() .. " забрал награду за сезон гонок", { rewards = "race_type: " .. reward_data.race_type .. ", place: " .. reward_data.place .. ", season_number: " .. reward_data.season_number .. ",\n" } )

    onPlayerReadyToPlay_handler( player )
end

function onPlayerTryTakeRaceReward_handler()
    DB:queryAsync( onPlayerTakeReward_callback, { client }, "SELECT race_prizes FROM nrp_players WHERE id = ? LIMIT 1", client:GetUserID() )
end
addEvent( "onPlayerTryTakeRaceReward", true )
addEventHandler( "onPlayerTryTakeRaceReward", root, onPlayerTryTakeRaceReward_handler )

function onPlayerTakeReward_callback( qh, player )
    local result = qh:poll( -1 )
    if type( result ) == "table" and #result > 0 then
        result = result[ 1 ]
        if #result.race_prizes > 0 then
            GivePlayerRewards( player, fromJSON( result.race_prizes ) )
        end
    end
end

function onPlayerReadyToPlay_handler( player )
    local player = isElement( player ) and player or source
    DB:queryAsync( onPlayerShowReward_callback, { player }, "SELECT race_prizes FROM nrp_players WHERE id = ? LIMIT 1", player:GetUserID() )

    triggerClientEvent( player, "OnClientRefreshWinnersData", root, SEASON_WINNERS_DATA )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler, true, "low-1000000000" )


addCommandHandler( "end_race_season", function( player )
	if player:GetAccessLevel( ) < ACCESS_LEVEL_DEVELOPER then return end
    OnSeasonEnd()
end )