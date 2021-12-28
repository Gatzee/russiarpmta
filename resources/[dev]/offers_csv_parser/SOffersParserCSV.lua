loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "csv" )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SDB" )
Extend( "ShTimelib" )
Extend( "ShAccessories" )
Extend( "ShSkin" )
Extend( "ShVinyls" )
Extend( "ShPhone" )

function UpdateSpecialOffers( callback_fn )
	print( "\n\n\n\n\n\t\tUpdateCasesInfo\n" )

	-- Подгружаем текущие данные для бэкапа напрямую из БД, т.к. MariaGet может вернуть старые данные
	CommonDB:queryAsync( function( query )
		local result = query:poll( -1 )
		if result then
			local cases_info = { }
			for i, v in pairs( result ) do
				cases_info[ v.id ] = v
			end

			-- Бэкапим текущие данные
			local file = fileCreate( "backups/" .. os.date( "%Y%m%d_%H%M%S" ) .. ".json" )
			fileWrite( file, toJSON( cases_info, true ) )
			fileClose( file )

            local new_data
			-- Если хотим, подгружаем данные из бэкапа
			if LOAD_FROM_BACKUP then
				local file = fileOpen( LOAD_FROM_BACKUP )
				local data = fileRead( file, fileGetSize( file ) )
				fileClose( file )
                new_data = data and fromJSON( data ) or { }
            else
                new_data = ParseDataFromCSV( cases_info, callback_fn )
			end

            if callback_fn then
                callback_fn( new_data )
            end

		else
			error( "Какая-то залупа с бд" )
		end
	end, { }, "SELECT * FROM special_offers" )
end

function ParseDataFromCSV( )
    local file = fileOpen( CSV_FILE_PATH )
    local data = fileRead( file, fileGetSize( file ) )
    fileClose( file )

    local csv_reader = csv.openstring( data , { separator = ",", header =false } )
    local csv_table = { }
    for fields in csv_reader:lines() do
        table.insert( csv_table, fields )
    end

    local parsed_data = { }

    local all_segments = exports.nrp_shop:GetAllSegments( )
    local filter_start_date = getTimestampFromString( FILTER_START_DATE )

    local function ParseDataFromCSVLine( line_i )
        local id, name, limit_count, cost_soft, cost, cost_original, start_date, finish_date, segment, class, real_start_date, comment = unpack( ( csv_table[ line_i ] ) )

        if id == "" and name == "" or start_date:find( "1900$" ) or finish_date:find( "1900$" ) 
        or utf8.find( utf8.lower( comment ), "удален" ) or utf8.find( utf8.lower( class ), "удален" ) 
        or utf8.lower( comment ) == "в салон"
        then
            return
        end

        cost = tonumber( cost:gsub( "[^%d]+", "" ), 10 )
        cost_original = tonumber( cost_original:gsub( "[^%d]+", "" ), 10 )
        limit_count = tonumber( limit_count:gsub( "[^%d]+", "" ), 10 )

        _result, start_date = pcall( getTimestampFromString, start_date )
        if not _result then
            iprint( csv_table[ line_i ] )
            Debug( "no start_date, line " .. line_i, 1 )
            error( start_date )
        end

        if real_start_date ~= "" then
            _result, real_start_date = pcall( getTimestampFromString, real_start_date )
            if not _result then
                iprint( csv_table[ line_i ] )
                Debug( "no real_start_date, line " .. line_i, 1 )
                error( real_start_date )
            end
        end

        _result, finish_date = pcall( getTimestampFromString, finish_date )
        if not _result then
            iprint( csv_table[ line_i ] )
            Debug( "no finish_date, line " .. line_i, 1 )
            error( finish_date )
        end

        segment = segment ~= "" and split( segment:gsub( "/", "\\" ):gsub( "[^%d\\]", "" ), "\\" )
        if segment ~= "" then
            for k,v in pairs( segment ) do
                if not tonumber(v) or not all_segments[ tonumber(v) ] then
                    iprint( csv_table[ line_i ] )
                    error( "malformed segment '" .. v .. "', line " .. line_i )
                end
                segment[k] = tonumber(v)
            end
            -- Ничего не записываем, если доступно для всех сегментов
            if #segment == table.size( all_segments ) then
                segment = nil
            end
        end

        if ( real_start_date == "" and finish_date <= getRealTime().timestamp ) or start_date > filter_start_date then
            return
        end

        TYPE_CONVERSION = {
            [ "транспорт" ] = "vehicle",
            [ "скин" ] = "skin",
            [ "аксессуар" ] = "accessory",
            [ "номер" ] = "numberplate",
            [ "номера" ] = "numberplate",
            [ "винил" ] = "vinyl",
            [ "неон" ] = "neon",
            [ "пак" ] = "pack",
            [ "пак_лимит" ] = "pack_limit",
        }

        local item_class = TYPE_CONVERSION[ class and utf8.lower( class ) ]

        if not item_class then
            iprint( csv_table[ line_i ] )
            error( "no item_class of '" .. class .. "', line " .. line_i )
        end

        if item_class ~= "pack_limit" and not id then
            iprint( csv_table[ line_i ] )
            error( "no id, line " .. line_i )
        end

        if not cost then
            iprint( csv_table[ line_i ] )
            error( "no cost, line " .. line_i )
        end

        -- Лимитированные спешлы без даты окончания
        if real_start_date ~= "" then
            start_date = real_start_date
            finish_date = nil
        end

        local item = {
            [ "class"         ] = item_class,
            [ "model"         ] = id,
            [ "name"          ] = name,
            [ "cost"          ] = cost,
            [ "cost_original" ] = cost_original,
            [ "start_date"    ] = start_date,
            [ "finish_date"   ] = finish_date,
            [ "limit_count"   ] = limit_count,
            [ "segment"       ] = segment,
        }

        local name_str = utf8.lower( name )
        local data = { }

        if item_class == "pack_limit" then
            if utf8.find( name_str, "жетон" ) then
                item.model = "wof_coin"
                data.params = {
                    count = tonumber( ({ name:gsub( "[^%d]+", "" ) })[ 1 ] or 1 ) or 1,
                    type = utf8.find( name_str, "vip" ) and "gold" or "default",
                }
            
            elseif utf8.find( name_str, "рем" ) and utf8.find( name_str, "комплект" ) then
                item.model = "repairbox"
                data.params = {
                    count = tonumber( ({ name_str:gsub( "[^%d]+", "" ) })[ 1 ] or 1 ) or 1,
                }
            else
                iprint( csv_table[ line_i ] )
                error( "undefined item of pack_limit, line " .. line_i )
            end

        elseif item_class == "vehicle" then
            local config = VEHICLE_CONFIG[ tonumber( item.model ) ]
            if not config then
                iprint( csv_table[ line_i ] )
                error( "no VEHICLE_CONFIG of '" .. item.model .. "', line " .. line_i )
            end

            if IsSpecialVehicle( tonumber( item.model ) ) then
                return
            end
            
            if config.variants[ 2 ] then
                local name_str = name_str:gsub( "([0-9])%.([0-9])AT$", "%1.%2 AT" )
                local mod = utf8.lower( config.variants[ 2 ].mod:gsub( "([0-9])%.([0-9])AT$", "%1.%2 AT" ) )
                if mod ~= "" and utf8.find( name_str, mod .. "$" ) then
                    data.variant = 2
                end
                print( "check variant of ", name, id, "defined as " ..( data.variant or 1 ) )
            end

        elseif item_class == "accessory" then
            item.model = utf8.gsub( item.model, "^%d+ ?- ?", "" )

        elseif item_class == "numberplate" then
            data.region = "RU"
            -- if utf8.find( utf8.lower( comment ), "рф" ) then
            --     data.region = "RU"
            -- elseif tonumber( comment ) then
            --     data.region = tonumber( comment )
            -- elseif comment ~= "" then
            --     iprint( csv_table[ line_i ] )
            --     error( "undefined numberplate's region '" .. comment .. "', line " .. line_i )
            -- else
            --     data.region = 1
            -- end
        
        elseif item_class == "neon" then
            item.model = tonumber( id:gsub( "[^%d]+", "" ), 10 )
        
        elseif item_class == "pack" then
            item.model = tonumber( id:gsub( "[^%d]+", "" ), 10 )
            item.name = utf8.match( item.name, 'Пак "(.*)"' ) or item.name
            data = ParseSpecialPackItems( item.model )
        end

        if next( data ) then
            item.data = data
        end

        table.insert( parsed_data, item ) 
    end


    for i = 2, #csv_table do
        if ParseDataFromCSVLine( i ) == "break" then
            break
        end
    end

    table.sort( parsed_data, function( a,b )
        return a.start_date < b.start_date 
            or a.start_date == b.start_date and a.class < b.class
    end )
    
    return parsed_data
end

function UpdateDataInCommonDB( new_data )
	CommonDB:exec( "TRUNCATE special_offers" )

	local COLUMNS = {
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
	}
	
	local COLUMNS_REVERSE = { }
	for i, v in pairs( COLUMNS ) do
		COLUMNS_REVERSE[ v.Field ] = v
	end

	for i, item in ipairs( new_data ) do
		local insert_query_keys_table = LOAD_FROM_BACKUP and {} or { "id" }
		local insert_query_values_table == LOAD_FROM_BACKUP and {} or { i }
		for k, v in pairs( item ) do
			local col_info = COLUMNS_REVERSE[ k ] or { }
			if ( col_info.Type == "json" or col_info.Type == "longtext" ) and type( v ) == "table" then
                v = toJSON( v or { }, true )
            elseif col_info.Type == "datetime" and type( v ) == "number" then
                v = os.date( "%Y-%m-%d %H:%M:%S", v )
			end
			table.insert( insert_query_keys_table, dbPrepareString( DB, "`??`", k ) )
			table.insert( insert_query_values_table, dbPrepareString( DB, "?", v ) )
		end

		CommonDB:exec(
			"INSERT INTO special_offers (" .. table.concat( insert_query_keys_table, "," )  .. ")"
			.. " VALUES (" .. table.concat( insert_query_values_table, "," ) .. ")"
		)
	end

	print( "Special offers succesfully updated" )
end