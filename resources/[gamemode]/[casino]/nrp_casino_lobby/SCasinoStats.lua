
local CACHED_STATISTICS = {}

local CONST_SEND_CLIENT   = 20
local CONST_MAX_TOTAL     = 999
local CONST_DATABASE_NAME = "nrp_casino_statistics"

local CURRENT_SEASON = getRealTime().month
local UPDATE_TOP_LIST_MS = 5 * 60 * 1000

function onStart()
    DB:createTable( CONST_DATABASE_NAME, 
    { 
        { Field = "ckey",   Type = "varchar(128)", Null = "NO",  Key = "PRI", Default = ""	 };
        { Field = "cvalue", Type = "longtext",     Null = "YES", Key = "",    Default = NULL };
    } )
    
    InitTopList()
end
addEventHandler( "onResourceStart", resourceRoot, onStart )

function InitTopList()
    ResetCache()
    for k, v in pairs( CACHED_STATISTICS ) do
        DB:exec( "INSERT IGNORE INTO " .. CONST_DATABASE_NAME .. " (ckey, cvalue) VALUES (?,?)", k, "[[]]" )
    end

    DB:queryAsync( function( qh )
        if not qh then return end

        local result = qh:poll( 0 )
        if not result or #result == 0 then return end

        for k, v in pairs( result ) do
            local data = fromJSON( v.cvalue ) or {}
            if CURRENT_SEASON == data.season then 
                CACHED_STATISTICS[ v.ckey ] = data
            end
        end        
    end, {}, "SELECT ckey, cvalue FROM " .. CONST_DATABASE_NAME ) 
end

function ResetCache()
    CURRENT_SEASON = getRealTime().month
    CACHED_STATISTICS = {}
    for casino_id in pairs( CASIONO_STRING_ID ) do
        for game_id in pairs( CASINO_GAME_STRING_IDS ) do
            CACHED_STATISTICS[ casino_id .. "_" .. game_id ] = {
                season  = CURRENT_SEASON,
                players = {},
            }
        end
    end
end

function SaveTopList()
    if CURRENT_SEASON ~= getRealTime().month then
        ResetCache()
    else
        for k, v in pairs( CACHED_STATISTICS ) do
            DB:exec( "UPDATE " .. CONST_DATABASE_NAME .. " SET cvalue = ? WHERE ckey = ?", toJSON( v ), k )
        end
    end 
end
setTimer( SaveTopList, UPDATE_TOP_LIST_MS, 0 )

function UpdatePlayerStatisic( player, casino_id, game_id, sum )
    local data_id = casino_id .. "_" .. game_id
    local player_casino_stats = player:GetPermanentData( "casino_stat" )
    
    if not player_casino_stats or not player_casino_stats[ data_id ] then
        if not player_casino_stats then player_casino_stats = {} end

        player_casino_stats[ data_id ] = {
			season = CURRENT_SEASON,
			total_win = sum,
        }
    elseif player_casino_stats[ data_id ].season == CURRENT_SEASON then
        player_casino_stats[ data_id ].total_win = player_casino_stats[ data_id ].total_win + sum
    
    else
		player_casino_stats[ data_id ].season = CURRENT_SEASON
		player_casino_stats[ data_id ].total_win = sum
    end
    
    player:SetPermanentData( "casino_stat", player_casino_stats )

    local player_id   = player:GetID()
    local player_name = player:GetNickName()
    local total_win   = player_casino_stats[ data_id ].total_win

    local cache_data = CACHED_STATISTICS[ data_id ]
    local min_id, exists_id = 0, 0

    for k, v in ipairs( cache_data.players ) do
		if min_id == 0 and v.total_win < total_win then
            min_id = k
            if v.player_id == player_id then 
                exists_id = k 
                break
            end
        elseif exists_id == 0 and v.player_id == player_id then
            exists_id = k
            break
        end
    end

    if min_id ~= 0 and min_id == exists_id and cache_data.players[ min_id ] then
        cache_data.players[ min_id ].total_win = total_win
        cache_data.players[ min_id ].player_name = player_name
        return
    elseif exists_id ~= 0 then 
        table.remove( cache_data.players, exists_id ) 
    end
    
    local is_insert = false
    local count_rows = #cache_data.players
    if min_id ~= 0 then
        table.insert( cache_data.players, min_id, CollectPlayerWinAmountData( player_id, player_name, total_win ) )
        is_insert = true
    elseif count_rows < CONST_MAX_TOTAL then
        table.insert( cache_data.players, CollectPlayerWinAmountData( player_id, player_name, total_win ) )
        is_insert = true
    end
    
    if is_insert then 
        count_rows = #cache_data.players
        if count_rows > CONST_MAX_TOTAL then
            table.remove( cache_data.players, count_rows )
        end
    end
end
addEvent( "onAddCasinoGameWinAmount" )
addEventHandler( "onAddCasinoGameWinAmount", root, UpdatePlayerStatisic )

function CollectPlayerWinAmountData( player_id, player_name, total_win )
    return
    {
        player_id = player_id,
        nickname  = player_name,
        total_win = total_win,
    }
end

function GetCasinoTopStatRows( casino_id, game_id, count_rows )
    local result = {}
    local data_id = casino_id .. "_" .. game_id
    
    for k, v in ipairs( CACHED_STATISTICS[ data_id ].players ) do
        table.insert( result, v )
        if k == count_rows then break end
    end

    return result
end

function RequestCasinoGameTopStats( player, casino_id, game_id )
    local data_id = casino_id .. "_" .. game_id
    
    local cache_data = CACHED_STATISTICS[ data_id ]
    local cache_size = #cache_data.players

    local player_casino_stats = player:GetPermanentData( "casino_stat" ) or {}
    local player_total_win = player_casino_stats[ data_id ] and player_casino_stats[ data_id ].total_win or 0

    local top_data = {}
    if cache_size > 0 and player_total_win > cache_data.players[ cache_size ].total_win then
        local count_add = 0
        local is_player_add = false
        local player_id = player:GetNickName()

        for k, v in ipairs( cache_data.players ) do
            local is_current_player = player_id == v.player_id 
            if is_current_player and k > 10 then
                table.insert( top_data, 1, { k, v.nickname, v.total_win } )
                count_add = count_add + 1
            elseif count_add < CONST_SEND_CLIENT then
                table.insert( top_data, { k, v.nickname, v.total_win } )
                count_add = count_add + 1
            end

            if is_current_player then is_player_add = true end
            if is_player_add and count_add == CONST_SEND_CLIENT then break end
        end
    else
        for i = 1, math.min( cache_size, CONST_SEND_CLIENT ) do
            table.insert( top_data, { i, cache_data.players[ i ].nickname, cache_data.players[ i ].total_win } )
        end
    end

	return top_data
end

function onStop()
    SaveTopList()
end
addEventHandler( "onResourceStop", resourceRoot, onStop )