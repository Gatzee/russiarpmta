function onResourceStart_handler( )
    DB:createTable( "nrp_clans_new",
        {
            { Field = "id",     Type = "int(11) unsigned",  Null = "NO",	Key = "PRI",    Default = NULL,     Extra = "auto_increment" };
            { Field = "data",   Type = "longtext",          Null = "NO",	Key = "" };
        }
    )

    -- Данные системы кланов
    DB:createTable("nrp_clans_data_new",
        {
            { Field = "ckey",		Type = "varchar(128)",		Null = "NO",    Key = "PRI",	Default = ""	},
            { Field = "cvalue",		Type = "json",				Null = "YES",	Key = ""                        },
        }
    )

    local query = DB:query( "SELECT cvalue FROM nrp_clans_data_new WHERE ckey='season_data' LIMIT 1" )
    local result = query:poll( -1 )

    if result and result[ 1 ] then
        local season_data = FixTableKeys( fromJSON( result[ 1 ].cvalue ), true )
        CURRENT_SEASON_ID = season_data.id
        SEASON_START_DATE = season_data.start_date
        SEASON_END_DATE = season_data.end_date
        LOCKED_SEASON = season_data.locked
        LOCKED_SEASON_LEADEBOARD = season_data.locked_season_leadeboard_data
        LOCKED_SEASON_CARTELS = season_data.locked_season_cartels_data
        SEASON_DATA = season_data.data or { }
    end
    CalculateSeasonPeriodDates( )

    LoadClans( )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler, true, "high+9999999" )

function LoadClans( )
    local query = DB:query( "SELECT id, data FROM nrp_clans_new" )
    local result = query:poll( -1 )
    if #result == 0 then
        local query = DB:query( "SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'nrp_clans_new'", get( "mysql.dbname" ) )
        local result = query:poll( -1 )
        if result[ 1 ].AUTO_INCREMENT == 1 then
            DB:exec( "ALTER TABLE nrp_clans_new AUTO_INCREMENT = ?;", SERVER_NUMBER * 10000 + 1 )
        end
    else
        for i, row_data in pairs( result ) do
            local data = FixTableKeys( fromJSON( row_data.data ), true )
            if data then
                data.id = row_data.id
                local clan = Clan( data )
                OnClanLoaded( clan )
            end
        end
    end
    
    for i, v in pairs( GetPlayersInGame( ) ) do
        onPlayerCompleteLogin_handler( v )
        onPlayerReadyToPlay_handler( v )
    end
    addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler, true, "high+9999999" )
    addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )
end

function SaveClans( async )
    for i, clan in pairs( CLANS_LIST ) do
        if clan.need_save then
            local query_str = DB:prepare( "UPDATE nrp_clans_new SET data = ? WHERE id = ?", toJSON( clan.permanent_data, true ), clan.id )
            if async then
                DB:exec( query_str )
            else
                DB:query( query_str ):poll( -1 )
            end
            clan.need_save = false
        end
    end
end
setTimer( SaveClans, 60 * 1000, 0, true )

function onResourceStop_handler( )
    SaveClans( )
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop_handler )

function SaveSeasonData( )
    local season_data = {
        id = CURRENT_SEASON_ID,
        start_date = SEASON_START_DATE,
        end_date = SEASON_END_DATE,
        locked = LOCKED_SEASON,
        locked_season_leadeboard_data = LOCKED_SEASON_LEADEBOARD,
        locked_season_cartels_data = LOCKED_SEASON_CARTELS,
        data = SEASON_DATA,
    }
    DB:exec( "REPLACE INTO nrp_clans_data_new ( ckey, cvalue ) VALUES ( ?, ? )", "season_data", toJSON( season_data, true ) ) 
end