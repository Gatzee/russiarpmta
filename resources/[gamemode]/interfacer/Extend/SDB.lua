-- SDB

CONST_QUEUE_SIZE_TO_CREATE_NEW_CONNECTION = 100

CONNECTIONS_POOL = CONNECTIONS_POOL or { }
CONNECTIONS_POOL_REVERSE_ALIASES = CONNECTIONS_POOL_REVERSE_ALIASES or { }

function CheckAndCreateNewConnectionToPool( data )
	local min_queue_size = CONST_QUEUE_SIZE_TO_CREATE_NEW_CONNECTION
	local db_with_min_queue_size = nil

	for i, db in pairs( CONNECTIONS_POOL[ data.alias ] ) do
		if isElement( db ) then
			local queue_size = 1
			if queue_size < min_queue_size then
				min_queue_size = queue_size
				db_with_min_queue_size = db
			end
		end
	end

	if not db_with_min_queue_size then
		db_with_min_queue_size = CreateNewConnection( data )
	end

	return db_with_min_queue_size
end

function AddConnectionToPool( alias, db )
	if not CONNECTIONS_POOL[ alias ] then
		CONNECTIONS_POOL[ alias ] = { }
	end

	table.insert( CONNECTIONS_POOL[ alias ], db )

	CONNECTIONS_POOL_REVERSE_ALIASES[ db ] = alias
end

function CreateNewConnection( data )
	local db = dbConnect( "mysql", ( "dbname=%s;host=%s;port=%s;charset=%s" ):format( data.db, data.host, data.port, "utf8" ), data.user, data.pass, "share=0;batch=0;autoreconnect=1;log=1;tag=" .. THIS_RESOURCE_NAME .. ";multi_statements=" .. ( data.multi_statements and "1" or "0" ) )
	if db then
		db:exec( "SET NAMES utf8" )
		db:exec( "SET lc_time_names = 'ru_RU'" )
		if type( data.connected ) == "table" then
			for i, req in pairs( data.connected ) do
				db:exec( req )
			end
		end

		AddConnectionToPool( data.alias, db )
	end

	return db
end

-- Новое подключение к базе данных
function SDBKeepConnection()
	local THIS_RESOURCE_NAME = getResourceName( getThisResource() )
	local connection_confs = {
		-- MariaDB
		{
			name = "БД сервера",
			alias = "DB",
			host = '127.0.0.1',
			port = 3306,
			user = 'nextrp',
			pass = 'Jkds7779821389',
			db = 'nextrp',
			engine = 'InnoDB',
			multi_statements = true,
		},

		-- Общая MariaDB
		{
			name = "БД общая",
			alias = "CommonDB",
			host = '127.0.0.1',
			port = 3306,
			user = 'nextrp',
			pass = 'Jkds7779821389',
			db = 'nextrp',
			engine = 'InnoDB',
			multi_statements = true,
		},

		-- API
		{
			name = "БД АПИ",
			alias = "APIDB",
			host = "127.0.0.1",
			port = "3306",
			user = "nextrp",
			pass = "Jkds7779821389",
			db = "nextrp",
			engine = 'InnoDB',
			multi_statements = true,
		},
	}

	MYSQL_ENGINE = 'InnoDB'
	
	for i, v in pairs( connection_confs ) do
		local db = nil
		if not v.only_when_required or MARIADB_INCLUDE and MARIADB_INCLUDE[ v.alias ] then
			if not isElement( _G[ v.alias ] ) then
				db = CreateNewConnection( v )
			else
				db = CheckAndCreateNewConnectionToPool( v )
			end
		end

		if db then
			_G[ v.alias ] = db
		end
	end

	-- Самостоятельный пинг каждые 5 секунд
	_SDB_TIMER = Timer(SDBKeepConnection, GET("mysql_ping_frequency") or 5000, 1)
end

if resource.name ~= "interfacer" then
	if not isTimer(_SDB_TIMER) then SDBKeepConnection() end
end

IGNORE_DB_DEPRECATION_WARNINGS = true
Connection.query = function(self, ...)
	if IGNORE_DB_DEPRECATION_WARNINGS == nil then
		outputDebugString( "DEPRECATED: Использование синхронных запросов запрещено (" .. THIS_RESOURCE_NAME .. ")", 2 )
		outputDebugString( inspect( { ... } ), 2 )
	end
	local result = dbQuery(self, ...)
	
	IncrementConnectionCounter( self )
	if result then	
		return result
	else
		outputDebugString("MYSQL QUERY ERR: " .. tostring(result), 1)
	end
end

Connection.queryAsync = function(self, callbackFn, fnArgs, ...)
	local result = dbQuery(callbackFn, fnArgs, self, ...)
	IncrementConnectionCounter( self )
	if result then 
		return result
	else
		outputDebugString("MYSQL QUERY ERR: " .. tostring(result), 1)
	end
end

Connection.exec = function(self, ...)
	local debug_info = debug.getinfo( 2, "Sl" )
	local request_line = self:prepare( ... )
	IncrementConnectionCounter( self )
	local result = dbQuery( function( query, request_line, debug_file, debug_line ) 
		local result, error_code, error_msg  = dbPoll( query, -1 ) 
		if not result then
			local query_str = inspect( request_line )
			outputDebugString( "MYSQL EXEC RESULT ERR: " .. query_str, 1 )

			-- outputDebugString не пишется в грейлог, т.к. из-за того, что он был вызван в колбеке dbQuery, в onDebugMessage приходит file = nil
			local msg = "DB.exec failed; " .. error_msg .. "\n" .. query_str:sub( 1, 512 )
			triggerEvent( "onDebugMessage", resourceRoot, msg, 1, debug_file, debug_line )
		end
	end, { request_line, debug_info.short_src, debug_info.currentline }, self, ... )
	if not result then outputDebugString("MYSQL EXEC ERR: " .. tostring(result), 1) end
	return true
end

Connection.prepare = function(self, ...)
	local result = dbPrepareString(self, ...)
	if result then 
		return result
	else
		--iprint("mysql", "%s MYSQL PREPARE ERR: %s", THIS_RESOURCE_NAME, result) outputDebugString("MYSQL PREPARE ERR: " .. tostring(result), 1)
	end
end

Connection.createTable = function(self, name, structure)
	IGNORE_DB_DEPRECATION_WARNINGS = true

	local test = self:query("SHOW TABLES LIKE ?", name)
	local result = test:poll(-1)

	local rows = result and #result
	if not result then return end

	if rows == 0 then
		local fields = {}
		local Keys = { PRI = {}, SEC = {}, UNI = {}, }
		for i, Row in ipairs(structure) do
			if Row.Key then
				if Keys[Row.Key] then
					table.insert(Keys[Row.Key], Row.Field)
				end
			end
			
			table.insert(fields, self:ToStringColumn(Row))
		end
		local sPrimary
		if #Keys.PRI > 0 then
			sPrimary = "PRIMARY KEY (`" .. table.concat(Keys.PRI, '`,`') .. "`)"
		end
		local sSecondary
		for i, key in ipairs(Keys.SEC) do
			if i == 1 then
				sSecondary = "UNIQUE "
			end
			if i > 2 then
				sSecondary = sSecondary .. ",\n"
			end
			sSecondary = sSecondary .. "KEY `SECONDARY` (`" .. key .. "`)"
		end
		local sUnique
		for i, key in ipairs(Keys.UNI) do
			if i == 1 then
				sUnique = "UNIQUE "
			end	
			if i > 2 then
				sUnique = sUnique .. ",\n"
			end
			
			sUnique = sUnique .. "KEY `" .. key .. "` (`" .. key .. "`)"
		end
		table.insert(fields, sPrimary)
		table.insert(fields, sSecondary)
		table.insert(fields, sUnique)
	
		local sQuery = "CREATE TABLE `" .. name .. "`(\n  " .. table.concat(fields, ",\n  ") .. "\n) ENGINE=" .. MYSQL_ENGINE .. " DEFAULT CHARSET=utf8"

		return self:exec(sQuery)
	end

	local pResult = self:query("DESCRIBE " ..name)
	if not pResult then return end
	local pRows = pResult:poll(-1) or {}
		
	local fields 			= {};
	local AddKeys 			= { PRI = {}; UNI = {}; };
	local DropKeys			= {};
	local HaveKeys 			= { PRI = {}; UNI = {}; };
		
	for i, pRow in ipairs(pRows) do
		fields[pRow.Field] = pRow;
	end
		
	for i, pRow in ipairs(structure) do
		structure[pRow.Field] = pRow;
		if HaveKeys[pRow.Key] then
			table.insert(HaveKeys[pRow.Key], pRow.Field);
		end
	end
		
	for i, pRow in ipairs(structure) do repeat
		if fields[pRow.Field] then
			local sField		= self:ToStringColumn(pRow);
			local sCurrentField	= self:ToStringColumn(fields[pRow.Field]);
			if sCurrentField ~= sField then
				if not self:exec("ALTER TABLE `??` MODIFY COLUMN " .. sField, name) then
					iprint("MySQL - Changing field " .. name .. "." .. pRow.Field .. " failed", 2);
				end	
				iprint("Changed field " .. name .. "." .. pRow.Field);
				iprint(sCurrentField .. " => " .. sField);
			end
			if fields[pRow.Field].Key ~= pRow.Key then
				if fields[pRow.Field].Key and fields[pRow.Field].Key:len() > 0 then
					table.insert(DropKeys, pRow.Field);
				end	
				if AddKeys[pRow.Key] then
					table.insert(AddKeys[pRow.Key], pRow.Field);
				end
			end	
			break
		end
			
		local sQuery = ("ALTER TABLE `%s` ADD " .. self:ToStringColumn(pRow) .. (pRow.Extra == "auto_increment" and " PRIMARY KEY" or "") .. " " .. (structure[i - 1] and ("AFTER `" .. structure[i - 1].Field .. "`") or "FIRST")):format(name)
			
		if not self:exec(sQuery) then
			iprint("Add field " .. name .. "." .. pRow.Field .. "\n\n" .. sQuery, 2);
		end
			
		if AddKeys[pRow.Key] and pRow.Extra ~= "auto_increment" then
			table.insert(AddKeys[pRow.Key], pRow.Field);
		end
			
		iprint("Added field " .. name .. "." .. pRow.Field);
	until true end
		
	for i, pRow in ipairs(pRows) do
		if not structure[pRow.Field] then
			iprint("Removing field " .. name .. "." .. pRow.Field);
			if not self:exec("ALTER TABLE `??` DROP `??`", name, pRow.Field) then
				iprint("Error altering table");
			end
		end
	end
		
	for i, sKey in ipairs(DropKeys) do
		iprint("Removing index " .. name .. "." .. sKey);
		if not self:exec("ALTER TABLE `??` DROP INDEX " .. sKey, name) then
			iprint("MySQL - Unable to drop " .. sKey .. " key\n", 2);
		end
	end
		
	if #AddKeys.PRI > 0 then
		if not self:exec("ALTER TABLE `" .. name .. "` DROP PRIMARY KEY, ADD PRIMARY KEY (`" .. table.concat(HaveKeys.PRI, "`, `") .. "`)") then
			iprint(sQuery);
				
			iprint("MySQL - Unable to add primary keys\n\n", 2);
		end
	end
		
	if #AddKeys.UNI > 0 then
		local sQuery	= ""
		for i, k in ipairs(AddKeys.UNI) do
			if i > 1 then
				sQuery = sQuery .. ", ";
			end
			sQuery = sQuery .. "ADD UNIQUE KEY `" .. k .. "` (`" .. k .. "`)"
		end
			
		if not self:exec("ALTER TABLE `??` " .. sQuery, name) then
			iprint(sQuery)
			iprint("MySQL - Unable to add unique key\n\n", 2);
		end
	end

	IGNORE_DB_DEPRECATION_WARNINGS = true
	return true;
end

Connection.ToStringColumn = function(self, Column)
	local Field		= Column.Field;
	local Type		= Column.Type;
	local Null		= Column.Null and (Column.Null == "NO" and "NOT NULL" or "NULL");
	local Default	= Column.Default and (Column.Default == "current_timestamp()" and Column.Default or ("'" .. (Column.Default) .. "'") or "NULL");
	local Extra		= type(Column.Extra) == "string" and Column.Extra:len() > 0 and Column.Extra:upper()
		
	if Default == "NULL" and Null == "NOT NULL" then
		Default = false;
	end
	
	return "`" .. Field .. "` " .. Type .. (Null and " " .. Null or "") .. (Default and " DEFAULT " .. Default or "") .. (Extra and " " .. Extra or "");
end

-- START: Connection stats for Prometheus
addEvent( "onSDBSendConnectionPoolCounter" )

CONNECTIONS_POOL_REQUESTS_COUNTERS = { }

function IncrementConnectionCounter( connection )
	local alias = CONNECTIONS_POOL_REVERSE_ALIASES[ connection ]
	if alias then
		CONNECTIONS_POOL_REQUESTS_COUNTERS[ alias ] = ( CONNECTIONS_POOL_REQUESTS_COUNTERS[ alias ] or 0 ) + 1
	end
end

function GetConnectionPoolQueueCounter( )
	local alias_counter = { }
	for alias, connection_list in pairs( CONNECTIONS_POOL ) do
		for _, connection in pairs( connection_list ) do
			alias_counter[ alias ] = ( alias_counter[ alias ] or 0 ) + ( 0)
		end
	end
	return alias_counter
end

function SendConnectionPoolQueueCounter( )
	triggerEvent( "onSDBSendConnectionPoolCounter", resourceRoot, GetConnectionPoolQueueCounter( ), CONNECTIONS_POOL_REQUESTS_COUNTERS )
end

if SDB_SEND_CONNECTIONS_STATS then
	if isTimer( CONNECTION_STATS_TIMER ) then killTimer( CONNECTION_STATS_TIMER ) end

	local poll_rate = tonumber( SDB_SEND_CONNECTIONS_STATS ) or 500
	CONNECTION_STATS_TIMER = setTimer( SendConnectionPoolQueueCounter, poll_rate, 0 )
end
-- END: Connection stats for Prometheus