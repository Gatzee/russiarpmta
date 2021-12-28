loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SDB" )

--Данные из global_config
MARIA_CONF = { }
--Данные из кастомных таблиц из COMMON_DB_LIST
CUSTOM_MARIA_CONF = { }

function MariaGet( key )
    return MARIA_CONF[ key ] or CUSTOM_MARIA_CONF[ key ]
end

COMMON_DB_LIST = {
	{
		name = "f4_cases",
        fields = {
            { Field = "id",					Type = "varchar(128)",			Null = "NO",    Key = "PRI",	},
            { Field = "name",				Type = "varchar(128)",			Null = "YES",					},
            { Field = "cost",				Type = "float",					Null = "YES",					},
            { Field = "position",			Type = "tinyint",				Null = "YES",					},
            { Field = "temp_start",			Type = "datetime",				Null = "YES",					},
            { Field = "temp_end",			Type = "datetime",				Null = "YES",					},
            { Field = "temp_start_count", 	Type = "int(11) unsigned",		Null = "YES",					},
            { Field = "is_hit", 			Type = "boolean",				Null = "YES",					},--boolean = tinyshort
            { Field = "is_new", 			Type = "boolean",				Null = "YES",					},--Поэтому у нас будут результаты в виде 1 или 0 
            { Field = "versus", 		    Type = "varchar(128)",			Null = "YES",					},
            { Field = "items",				Type = "json",					Null = "YES",	Key = "",		},
        },
        options = {
            update_interval = 15 * 60 * 1000,
            trigger_notify_event = true,
        },
    },

	{
		name = "f4_cases_schedule",
        fields = {
            { Field = "id",					Type = "varchar(128)",			Null = "NO",                	},
            { Field = "temp_start",			Type = "datetime",				Null = "YES",					},
            { Field = "temp_end",			Type = "datetime",				Null = "YES",					},
            { Field = "temp_start_count", 	Type = "int(11) unsigned",		Null = "YES",					},
            { Field = "is_hit", 			Type = "boolean",				Null = "YES",					},--boolean = tinyshort
            { Field = "is_new", 			Type = "boolean",				Null = "YES",					},--Поэтому у нас будут результаты в виде 1 или 0 
            { Field = "versus", 		    Type = "varchar(128)",			Null = "YES",					},
        },
        options = {
            update_interval = 15 * 60 * 1000,
            trigger_notify_event = true,
            ignore_key_indexing = true,
        },
    },

	{
		name = "special_offers",
        fields = {
            { Field = "id"            , Type = "int(11) unsigned" , Null = "NO"  , Key = "PRI", Default = NULL, Extra = "auto_increment" };
            { Field = "class"         , Type = "varchar(128)"     , Null = "NO"  , },
            { Field = "model"         , Type = "varchar(128)"     , Null = "NO"  , },
            { Field = "name"          , Type = "varchar(128)"     , Null = "YES" , },
            { Field = "cost"          , Type = "int(11) unsigned" , Null = "NO"  , },
            { Field = "cost_original" , Type = "int(11) unsigned" , Null = "YES" , },
            { Field = "start_date"    , Type = "datetime"         , Null = "YES" , },
            { Field = "finish_date"   , Type = "datetime"         , Null = "YES" , },
            { Field = "limit_count"   , Type = "int(11) unsigned" , Null = "YES" , },
            { Field = "segment"       , Type = "longtext"         , Null = "YES" , },
            { Field = "data"          , Type = "longtext"         , Null = "YES" , },
        },
        options = {
            update_interval = 15 * 60 * 1000,
            trigger_notify_event = true,
        },
    },
    
    {
		name = "nrp_promocodes",
        fields = {
            { Field = "ckey"                  , Type = "varchar(128)"     , Null = "NO"  , Key = "PRI"                                   };
            { Field = "type"                  , Type = "varchar(128)"     , Null = "YES" , Key = ""    , Default = ""                    };
            { Field = "rewards"               , Type = "longtext"         , Null = "NO"  , Key = ""                                      };
            { Field = "for_new_users"         , Type = "boolean"          , Null = "YES" , Key = ""                                      };
            { Field = "create_date"           , Type = "datetime"         , Null = "NO"  , Key = ""    , Default = "current_timestamp()" };
            { Field = "start_date"            , Type = "int(11) unsigned" , Null = "YES" , Key = ""                                      };
            { Field = "end_date"              , Type = "int(11) unsigned" , Null = "YES" , Key = ""                                      };
            { Field = "client_ids"            , Type = "longtext"         , Null = "YES" , Key = ""                                      };
            { Field = "max_server_uses_count" , Type = "int(11) unsigned" , Null = "YES" , Key = ""                                      };
            { Field = "max_uses_count"        , Type = "int(11) unsigned" , Null = "YES" , Key = ""                                      };
            { Field = "is_blocked"            , Type = "boolean"          , Null = "YES" , Key = ""                                      };
            { Field = "is_generated"          , Type = "boolean"          , Null = "YES" , Key = ""                                      };
        },
        options = {
            update_interval = 0,
        },
    },
    
    {
		name = "nrp_promocode_rewards",
        fields = {
            { Field = "id"   , Type = "varchar(128)" , Null = "NO" , Key = "PRI" };
            { Field = "name" , Type = "text"         , Null = "NO" , Key = ""    };
            { Field = "data" , Type = "json"         , Null = "NO" , Key = ""    };
        },
        options = {
            update_interval = 15 * 60 * 1000,
        },
    },

	{
		name = "custdev",
        fields = {
            { Field = "id"            , Type = "int(11) unsigned"    , Null = "NO", Key = "PRI", Default = NULL, Extra = "auto_increment" };
            { Field = "start_date"    , Type = "datetime"            , Null = "YES" },
            { Field = "finish_date"   , Type = "datetime"            , Null = "YES" },
            { Field = "title"         , Type = "varchar(128)"        , Null = "NO"  },
            { Field = "url"           , Type = "varchar(128)"        , Null = "NO"  },
            { Field = "reward"        , Type = "int(11) unsigned"    , Null = "NO"  },
            { Field = "reward_type"   , Type = "varchar(128)"        , Null = "NO"  },
            { Field = "min_level"     , Type = "int(11) unsigned"    , Null = "YES" },
            { Field = "max_level"     , Type = "int(11) unsigned"    , Null = "YES" },
            { Field = "donate_total"  , Type = "bigint(20) unsigned" , Null = "YES" },
            { Field = "faction_id"    , Type = "int(11) unsigned"    , Null = "YES" },
            { Field = "is_active"     , Type = "boolean"             , Null = "YES" };
            { Field = "for_all_users" , Type = "boolean"             , Null = "YES" };
            { Field = "client_ids"    , Type = "longtext"            , Null = "YES" },
        },
        options = {
            update_interval = 60 * 1000,
            trigger_notify_event = true,
        },
    },
}

COMMON_DB_TABLES = {} for k, v in pairs( COMMON_DB_LIST ) do COMMON_DB_TABLES[ v.name ] = v end

function saveMariaConf( table_conf, filename )
    local new_conf = { }
    for i, v in pairs( table_conf ) do
        new_conf[ i ] = type( v ) == "string" and fromJSON( v ) or v
    end
    local file = fileCreate( filename )
    fileWrite( file, toJSON( new_conf, true ) )
    fileClose( file )
end

function getConfFromFile( filename, is_global_config )
    local file = fileExists( filename ) and fileOpen( filename )
    local tempTable = { }
    if file then
        local file_content = fileRead( file, fileGetSize( file ) )
        fileClose( file )
        local new_conf = file_content and fromJSON( file_content ) or { }
        if is_global_config then
            for i, v in pairs( new_conf ) do
                tempTable[ i ] = type( v ) == "table" and toJSON( v ) or v
            end
        else
            tempTable = new_conf
        end
    end
    return tempTable
end

function onResourceStop( )
    saveMariaConf( MARIA_CONF, "local_conf.nrp" )
    saveMariaConf( CUSTOM_MARIA_CONF, "local_custom_conf.nrp" )
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop )

function onResourceStart( )
    MARIA_CONF = getConfFromFile( "local_conf.nrp", true )
    CUSTOM_MARIA_CONF = getConfFromFile( "local_custom_conf.nrp" )

    CommonDB:createTable( "global_config",
		{
			{ Field = "ckey",				Type = "text",			        Null = "NO",    Default = ""	};
            { Field = "cvalue",				Type = "longtext",			    Null = "NO",	Key = "" };
            { Field = "server",				Type = "smallint(3)",			Null = "NO",	Key = "" };
            { Field = "comment",			Type = "text",					Null = "NO",	Key = "" };
		}
    )

    for i, table_data in pairs( COMMON_DB_LIST ) do 
        local table_name = table_data.name
		CommonDB:createTable( table_name, table_data.fields )
		if not table_data.options.update_interval or table_data.options.update_interval > 0 then
			setTimer( UpdateMaria, table_data.options.update_interval or 5000, 0, table_name )
		end
        UpdateMaria( table_name )
    end

    setTimer( UpdateMaria, 5000, 0 )
    UpdateMaria()  
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart )

function UpdateMaria( table_name )
    if table_name then
        CommonDB:queryAsync( UpdateMaria_Callback, { table_name }, "SELECT * FROM " .. table_name )
    else
        CommonDB:queryAsync( UpdateMaria_Callback, { }, "SELECT * FROM global_config WHERE server=? OR server=0", tonumber( get( "server.number" ) ) )
    end
end

function UpdateMaria_Callback( query, table_name )
    local result = query:poll( -1 )
    if result and #result > 0 then

        if table_name then 
            CUSTOM_MARIA_CONF[ table_name ] = {} 
        else
            MARIA_CONF = { }
        end

        if table_name and COMMON_DB_TABLES[ table_name ].options.ignore_key_indexing then
            CUSTOM_MARIA_CONF[ table_name ] = result
        else
            for i, v in pairs( result ) do
                if table_name then
                    CUSTOM_MARIA_CONF[ table_name ][ v.id or v.key or v.ckey or i ] = v
                else
                    MARIA_CONF[ v.ckey ] = tonumber( v.cvalue ) or v.cvalue 
                end
            end
        end

        if table_name and COMMON_DB_TABLES[ table_name ].options.trigger_notify_event then 
            triggerEvent( "onMariaDBUpdate", resourceRoot, table_name, CUSTOM_MARIA_CONF[ table_name ] )
        end
    end
end