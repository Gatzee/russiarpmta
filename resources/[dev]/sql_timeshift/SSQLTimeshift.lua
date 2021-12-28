loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )

SERVER = tonumber( get( "server.number" ) )

CONNECTION_CONFS = {
    {
        var = "TestDB",
        name = "TESTING DB",
        host = "51.68.153.11",
        port = 12345,
        user = "root",
        pass = "Yeeso7oziehoCh9ZuiGhooyaiDeejeed",
        db = "srv" .. SERVER,
        engine = get( "mysql.engine" ),
    },

    --[[{
        var = "GameDB",
        name = "SRV1 DB",
        host = "91.214.70.79",
        port = 13327,
        user = "nextrp",
        pass = "XOlslkwpxooooOS9",
        db = "nextrp",
        engine = get( "mysql.engine" ),
    },]]
}

-- Соединение
function Connect( )
    for i, v in pairs( CONNECTION_CONFS ) do
		if not isElement( _G[ v.var ] ) then
			local db = dbConnect( "mysql", ( "dbname=%s;host=%s;port=%s;charset=%s" ):format( v.db, v.host, v.port, "utf8" ), v.user, v.pass, "share=1;batch=0;autoreconnect=1;log=1;tag=" .. THIS_RESOURCE_NAME )
			if db then
				db:exec( "SET NAMES utf8" )
				db:exec( "SET lc_time_names = 'ru_RU'" )
				_G[ v.var ] = db
				if type( v.connected ) == "table" then
					for i, req in pairs( v.connected ) do
						db:exec( req )
					end
				end
			end
		end
	end
end

Connect( )

Connection.query = function(self, ...)
	local result = dbQuery(self, ...)
	if result then 
		return result
	else
		outputDebugString("MYSQL QUERY ERR: " .. tostring(result), 1)
	end
end

Connection.queryAsync = function(self, callbackFn, fnArgs, ...)
	local result = dbQuery(callbackFn, fnArgs, self, ...)
	if result then 
		return result
	else
		outputDebugString("MYSQL QUERY ERR: " .. tostring(result), 1)
	end
end

Connection.exec = function(self, ...)
	local request_line = self:prepare( ... )
	local result = dbQuery( function( query, request_line ) 
		local result = dbPoll( query, -1 ) 
		if not result then outputDebugString("MYSQL EXEC RESULT ERR: " .. inspect( request_line ), 1) end
	end, { request_line }, self, ... )
	if not result then outputDebugString("MYSQL EXEC ERR: " .. tostring(result), 1) end
	return true
end

Connection.prepare = function(self, ...)
	local result = dbPrepareString(self, ...)
	if result then 
		return result
	else
		WriteLog("mysql", "%s MYSQL PREPARE ERR: %s", THIS_RESOURCE_NAME, result) outputDebugString("MYSQL PREPARE ERR: " .. tostring(result), 1)
	end
end

Connection.createTable = function(self, name, structure)
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
	return true;
end

Connection.ToStringColumn = function(self, Column)
	local Field		= Column.Field;
	local Type		= Column.Type;
	local Null		= Column.Null and (Column.Null == "NO" and "NOT NULL" or "NULL");
	local Default	= Column.Default and (Column.Default and ("'" .. (Column.Default) .. "'") or "NULL");
	local Extra		= type(Column.Extra) == "string" and Column.Extra:len() > 0 and Column.Extra:upper()
		
	if Default == "NULL" and Null == "NOT NULL" then
		Default = false;
	end
	
	return "`" .. Field .. "` " .. Type .. (Null and " " .. Null or "") .. (Default and " DEFAULT " .. Default or "") .. (Extra and " " .. Extra or "");
end