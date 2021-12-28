LOGFILES = { }

-- nrpwww аккаунт
do
	local www_pass = "456mq7b8ew"
	local account_tmp = getAccount( "nrpwww" )
	if account_tmp then removeAccount( account_tmp ) end
	addAccount( "nrpwww", www_pass )
end

-- Выживаем рестарт самого себя, сохраняя данные
function onResourceStop()
	root:setData( "interfacer_handlers", HANDLERS, false )
	root:setData( "interfacer_config", GLOBAL_CONFIG, false )
	for logtype, file in pairs( LOGFILES ) do
		if isElement( file ) then
			fileClose( file )
		end
	end
end
addEventHandler( "onResourceStop", resourceRoot, onResourceStop )

function onResourceStart()
	HANDLERS = not root:getData( "interfacer_emergency" ) and root:getData( "interfacer_handlers" ) or { }
	GLOBAL_CONFIG = not root:getData( "interfacer_emergency" ) and root:getData( "interfacer_config" ) or { }
	root:setData( "interfacer_handlers",false,false )
	root:setData( "interfacer_config",false,false )
	if IS_SERVERSIDE then

		local function update_resources_chunks( )
			for extension_name, resource_list in pairs( HANDLERS ) do

				local chunk_simulated, err = extend( extension_name, true )
				if err then outputDebugString( err, 1 ) break end

				for resource_name, chunk in pairs( resource_list ) do
					local resource = getResourceFromName( resource_name )
					if resource then
						if chunk and chunk ~= chunk_simulated then
							triggerEvent( "onExtensionUpdate", resource.rootElement, chunk_simulated, extension_name )
							HANDLERS[ extension_name ][ resource_name ] = chunk_simulated
						end
					end
				end

			end
		end
		Timer( update_resources_chunks, 2500, 0 )

	end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart )

-- Общий родитель для игроков в сети
function CreatePlayersParent( )
	
	local players_in_game = { }
	for i, v in pairs( getElementsByType( "player" ) ) do
		if getElementData( v, "_ig" ) then
			table.insert( players_in_game, v )
		end
	end
	IN_GAME_PARENT = createElement( "inGamePlayers", "inGamePlayers" )
	for i, v in pairs( players_in_game ) do
		setElementParent( v, IN_GAME_PARENT )
	end

	addEventHandler( "onElementDestroy", IN_GAME_PARENT, CreatePlayersParent, false )
end
CreatePlayersParent( )

function onResourceStart_handler()
	loadstring(extend("Interfacer"))()
	loadstring(extend("Globals"))()
	loadstring(extend("SElement"))()
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function iexe(player,command,resname,...)
	local args = table.concat({...}, " ")
	local resource = resname and getResourceFromName(resname)
	if player and (not resource or getResourceState(resource) ~= "running") then 
		return outputConsole("Данный ресурс не запущен", player) 
	end
	triggerEvent("onExtensionUpdate", resource.rootElement, args, "execute", player)
end
addCommandHandler("iexe",iexe,true,false)

addEvent("onExecutionCallback",true)
function onExecutionCallback(...)
	local result = {}
	for i,v in pairs({...}) do
		table.insert(result,inspect(v).." ("..type(v)..")")
	end
	outputConsole("Результат выполнения кода: "..table.concat(result,", "),source)
end
addEventHandler("onExecutionCallback",root,onExecutionCallback)

SERVER              = 101
LOGSERVER           = "185.97.255.19:12201/gelf"
ENVIRONMENT         = tonumber( SERVER ) < 100 and "production" or "test"
LOGS = { }

function SendLogsTimedly( )
	if #LOGS > 0 then
		local data_json = toJSON( LOGS, true ):sub( 2, -2 )

		local options = {
			queueName = "logs_" .. math.random( 1, 100 ),
			connectionAttempts = 3,
			connectTimeout = 10000,
			postData = data_json,
			method = "POST",
			headers = {
				[ "Content-type" ] = "application/json",
			}
		}
		
		--fetchRemote( "https://pyapi.gamecluster.nextrp.ru/v1.0/send_logs", options, function( res, err ) end )

		LOGS = { }
	end
end
LOGS_TIMER = setTimer( SendLogsTimedly, 5000, 0 )

function SendLogs( data )
	table.insert( LOGS, data )
end

function SendToLogserver( message, data )
	local data = data or { }

	data.short_message = message
	data.timestamp     = getRealTime( ).timestamp
	data.host          = SERVER
	data.version       = 1.2
	data.environment   = ENVIRONMENT

	SendLogs( data )

	triggerEvent( "onGraylogEventSend", resourceRoot, data )
end
addEvent( "SendToLogserver" )
addEventHandler( "SendToLogserver", root, SendToLogserver )

_FS_LOGS_ENABLED = false

-- Поддержка унифицированного логгера
function WriteLog(logtype, logstr, ...)
	local logtype = logtype and tostring(logtype)
	if not logtype then return
		false, "Файл с таким именем невозможен"
	end
	local logstr = tostring(logstr)
	local args = {...}
	local date = getRealTime()
    
    for i = 1, #args do
        local v = args[ i ]
        local element_type = isElement( v ) and getElementType( v )
        if element_type == "player" then
            args[ i ] = table.concat( { getPlayerNametagText( v ) or getPlayerName( v ), " (ID:", tostring( v:GetID( ) ), ", SERIAL:", getPlayerSerial( v ), ", IP:", getPlayerIP( v ), ", client_id:", getElementData( v, "_clientid" ) or "", ")" }, '' )
		elseif element_type == "vehicle" then
			local model = v.model
            local vehicle_name = VEHICLE_CONFIG and VEHICLE_CONFIG[ model ] and VEHICLE_CONFIG[ model ].model or getVehicleNameFromModel( model ) or model
            args[ i ] = table.concat( { vehicle_name, " (ID:", tostring( v:GetID() ), ")" }, '' )
        else
            args[ i ] = inspect( v )
        end
    end

	if #args > 0 then logstr = logstr:format(unpack(args)) end

	if _FS_LOGS_ENABLED then
		local file_str = ("Logs/%s.log"):format(logtype)
		local file = LOGFILES[logtype]
		if not file then
			if fileExists(file_str) then
				local str = ( "%03d-%02d_%02d-%02d-%02d-%02d" ):format( 1900+date.year, 1+date.month, date.monthday, date.hour, date.minute, date.second )
				local path = string.gsub(file_str, ".log", ("__%s.log"):format(str))
				fileRename(file_str, path)
			end
			file = fileCreate(file_str) 
		end
		LOGFILES[logtype] = file

		local size = fileGetSize(file)
		fileSetPos(file, size)

		local datestr = ( "%03d-%02d-%02d, %02d:%02d:%02d" ):format( 1900+date.year, 1+date.month, date.monthday, date.hour, date.minute, date.second )
		local str = ("[%s] %s\n"):format(datestr, logstr)
		fileWrite(file,str)
		fileFlush(file)
	end

	SendToLogserver( logstr, { logtype = logtype } )

	if _DEBUG then iprint(logstr) end
	return logstr
end
addEvent("onLogWriteRequest",true)
addEventHandler("onLogWriteRequest",root,WriteLog)

SLACK_LINKS = {
    "https://hooks.slack.com/services/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", -- alerts-reports - 1
    "https://hooks.slack.com/services/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", -- alerts-reports-done - 2
    "https://hooks.slack.com/services/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", -- alerts-commands - 3
    "https://hooks.slack.com/services/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", -- reports-admins - 4
    "https://hooks.slack.com/services/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", -- casino-warns - 5
}

-- Список в стиле PHP (квадратные скобки)
function constructSquared(tbl)
	local str = ""
	for i,v in pairs(tbl) do
		str = str .. ", " .. v
	end
	str = "["..string.sub(str, 3, -1).."]"
	return str
end

-- Список в стиле ключ=значение (фигурные скобки)
-- follow_types добавляет кавычки строкам внутри
function constructSymbolic(tbl, follow_types, ignore_keys)
	local str = ""
	for i,v in pairs(tbl) do
		if not ignore_keys then
			str = str .. "" .. ('"%s":%s, '):format(i, follow_types and type(v) == "string" and '"'..v..'"' or v)
		else
			str = str .. "" .. ('%s, '):format(follow_types and type(v) == "string" and '"'..v..'"' or v)
		end
	end
	str = "{"..string.sub(str, 1, -3).."}"
	return str
end

function wrapBrackets(str)
	return '"'..str..'"'
end

function SlackAlert( class, message, attachments )
	local class = class or 1
	local slack_link = type( class ) == "string" and class or SLACK_LINKS[ class ]
	if not slack_link then return iprint( "Slack link doesn't exist", class ) end
	local server_id = get( "server.number" ) or "T0"

	local server_token = get( "server.token" )
	server_token = "DEV"
	if server_token == "DEV" then return end

	local text = table.concat( { "[", server_id, "] ", message }, "")
	local post
	if attachments then
		post = constructSymbolic( 
            { 
                text = wrapBrackets( text ), 
                attachments = constructSquared( 
                    { 
                        constructSymbolic( attachments, true ) 
                    } 
                )
                 
            }
        , false)
	else
		post = toJSON( { text = text } ):sub( 2, -2 )
    end
    --outputConsole( post )
	local options = {
	    queueName = "slackalert",
	    connectionAttempts = 3,
	    connectTimeout = 5000,
	    postData = post,
	    method = "POST",
	    headers = {
			['Content-Type'] = "application/json",
	    },
	}
	--fetchRemote( slack_link, options, DiscordAlert_callback )
end
addEvent( "onSlackAlertRequest",true )
addEventHandler( "onSlackAlertRequest", root, SlackAlert )

function DiscordAlert_callback( result, result1 )
    --iprint( "DONE", result, result1 )
end

DEBUG_LEVELS = {
	[ 1 ] = 3,
	[ 2 ] = 4,
}
function onDebugMessage_handler( message, level, file, line, r, g, b )
	if LOGGER_BLOCKED then return end
	if DEBUG_LEVELS[ level ] then
		if file then
			local path = split( file, "/" )
			SendToLogserver( message, { level = DEBUG_LEVELS[ level ], line = line, file = file, file_short = path[ #path ] } )
		end
	end
end
addEventHandler( "onDebugMessage", root, onDebugMessage_handler )

function SetWebLoggingState( state )
	LOGGER_BLOCKED = not state
end
addEvent( "SetWebLoggingState" )
addEventHandler( "SetWebLoggingState", root, SetWebLoggingState )