local rootElement = getRootElement()

loadstring(exports.interfacer:extend("Interfacer"))()
Extend("Globals")
Extend("ShUtils")
Extend("SPlayer")
Extend("SVehicle")
Extend("SInterior")

CONSOLE_MSGS = { }
function onDebugMessage( str, lvl, file, line, r, g, b )
	if #CONSOLE_MSGS > 256 then
		table.remove( CONSOLE_MSGS, 1 )
	end
	table.insert( CONSOLE_MSGS, { str, lvl, file and ( file .. ":" ) or "", line and ( line .. ": " ) or " ", r, g, b } )
end
addEventHandler( "onDebugMessage", root, onDebugMessage )

function httpGetConsole()
	local info_tbl = { }
	for i, v in pairs( CONSOLE_MSGS ) do
		local str, lvl, file, line, r, g, b = unpack( v )
		local line = ( "<span style='color: rgb(%s,%s,%s)'>%s%s%s</span></br>" ):format( r, g, b, file, line, str )
		table.insert( info_tbl, line )
	end
	return table.concat( info_tbl, '' )
end

function iexe(resname, ...)
	local args = table.concat({...}, " ")
	local resource = resname and getResourceFromName(resname)
	if not resource or getResourceState(resource) ~= "running" then 
		return ("Данный ресурс (%s) не запущен"):format(tostring(resname))
	end
	return triggerEvent("onExtensionUpdate", resource.rootElement, args, "execute", "Console")
end

function refresh( )
	return refreshResources()
end

function refreshall( )
	return refreshResources( true )
end

function restart( resname )
	local resource = resname and getResourceFromName( resname )
	if resource and getResourceState( resource ) == "running" then
		return restartResource( resource, true )
	end
end

function stop( resname )
	local resource = resname and getResourceFromName( resname )
	if resource and getResourceState( resource ) == "running" then
		return stopResource( resource )
	end
end

function start( resname )
	local resource = resname and getResourceFromName( resname )
	if resource and getResourceState( resource ) == "loaded" then
		return startResource( resource, true )
	end
end

function isrunning( resname )
	local resource = resname and getResourceFromName( resname )
	return resource and getResourceState( resource ) == "running"
end

function alarm( ... )
	local arg_str = {}
	for i, v in pairs({...}) do
		arg_str[i] = type(v) == "number" and v or ("'%s'"):format(v:gsub("'", "\\'"))
	end
	local command = "onAlarmRequest( _, 'alarm', "..table.concat(arg_str,", ").." )"
	return iexe( "nrp_alarm", command )
end
announce = alarm

function runString (commandstring, outputTo, source)
	me = source
	local sourceName = source and getPlayerName(source) or "Console"

	outputChatBoxR(sourceName.." executed command: "..commandstring, outputTo, true)
	local notReturned
	--First we test with return
	local commandFunction,errorMsg = loadstring("return "..commandstring)
	if errorMsg then
		--It failed.  Lets try without "return"
		commandFunction, errorMsg = loadstring(commandstring)
	end
	if errorMsg then
		--It still failed.  Print the error message and stop the function
		outputChatBoxR("Error: "..errorMsg, outputTo)
		return
	end
	--Finally, lets execute our function
	local results = { pcall(commandFunction) }
	if not results[1] then
		--It failed.
		outputChatBoxR("Error: "..results[2], outputTo)
		return
	end

	local resultsString = ""
	local first = true
	for i = 2, #results do
		if first then
			first = false
		else
			resultsString = resultsString..", "
		end

		local resultType = type(results[i])
		if resultType ~= "string" and resultType ~= "number" and resultType ~= "boolean" then
			resultType = tostring( results[i] )
		end

		local str = inspect( results[i], {newline="\n   "} )
		if utf8.find( str, "\n" ) then
			resultsString = resultsString.."\n  "
		end
		resultsString = resultsString..str.." ["..resultType.."]"
	end

	if #results > 1 then
		outputConsole("Command results: " ..resultsString, outputTo)
		return
	end

	outputChatBoxR("Command executed!", outputTo)
end

-- run command
addCommandHandler("run",
	function (player, command, ...)
		local commandstring = table.concat({...}, " ")
		return runString(commandstring, rootElement, player)
	end
)

-- silent run command
addCommandHandler("srun",
	function (player, command, ...)
		local commandstring = table.concat({...}, " ")
		return runString(commandstring, player, player)
	end
)

-- clientside run command
addCommandHandler("crun",
	function (player, command, ...)
		local commandstring = table.concat({...}, " ")
		if player then
			return triggerClientEvent(player, "doCrun", rootElement, commandstring)
		else
			return runString(commandstring, false, false)
		end
	end
)

-- http interface run export
function httpRun(commandstring)
	if not user then outputDebugString ( "httpRun can only be called via http", 2 ) return end
	local notReturned
	--First we test with return
	local commandFunction,errorMsg = loadstring("return "..commandstring)
	if errorMsg then
		--It failed.  Lets try without "return"
		notReturned = true
		commandFunction, errorMsg = loadstring(commandstring)
	end
	if errorMsg then
		--It still failed.  Print the error message and stop the function
		iprint( "Error", errorMsg )
		return "Error: "..errorMsg
	end
	--Finally, lets execute our function
	results = { pcall(commandFunction) }
	if not results[1] then
		--It failed.
		iprint( "Error", results[ 2 ] )
		return "Error: "..results[2]
	end
	if not notReturned then
		local resultsString = ""
		local first = true
		for i = 2, #results do
			if first then
				first = false
			else
				resultsString = resultsString..", "
			end
			local resultType = type(results[i])
			if isElement(results[i]) then
				resultType = "element:"..getElementType(results[i])
			end
			resultsString = resultsString..tostring(results[i]).." ["..resultType.."]"
		end
		iprint( "Execution result", resultsString, "for command", commandstring )
		return "Command results: "..resultsString
	end
	iprint( "Executed command with no result", commandstring )
	return "Command executed!"
end