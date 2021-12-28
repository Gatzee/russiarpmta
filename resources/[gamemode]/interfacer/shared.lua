local fileOpen 			= fileOpen
local fileRead 			= fileRead
local fileClose 		= fileClose
local loadstring 		= loadstring
local getResourceName 	= getResourceName
local getThisResource 	= getThisResource

local IS_SERVERSIDE = not localPlayer
local THIS_RESOURCE = getThisResource( )

GLOBAL_CONFIG  	= { }
HANDLERS       	= { }
LAST_CHUNKS    	= { }
CLEANUP_TIMERS 	= { }

local function ClearChunk( name )
	LAST_CHUNKS[ name ] = nil
	CLEANUP_TIMERS[ name ]  = nil
end

function extend( name, resourceName, simulate )
	local chunk = LAST_CHUNKS[ name ]

	if chunk == nil then
		if _G[ name ] and type( _G[ name ] ) == "string" then
			chunk = _G[ name ]
		else
			local file_name = table.concat( { "Extend/", name, ".lua" }, '' )

			if not fileExists( file_name ) then
				return false, "Расширение " .. file_name .. " не существует"
			end

			local file = fileOpen( file_name, true )
			local size = fileGetSize( file )
			if size <= 0 then
				fileClose( file )
				return false, "Модуль " .. name .. " пустой"
			end

			chunk = fileRead( file, size )
			fileClose( file )
		end

		local chunk_test, err = loadstring( chunk )
		if not chunk_test then
			return false, ( "Расширение %s сломано: %s" ):format( name, tostring( err ) )
		end
	end

	if isTimer( CLEANUP_TIMERS[ name ] ) then
		resetTimer( CLEANUP_TIMERS[ name ] )
	else
		LAST_CHUNKS[ name ] = chunk
		CLEANUP_TIMERS[ name ] = setTimer( ClearChunk, 5000, 1, name )
	end

	if simulate then return chunk end

	if IS_SERVERSIDE then
		local resname = getResourceName( sourceResource or THIS_RESOURCE )
		if HANDLERS[ name ] == nil then HANDLERS[ name ] = { } end

		HANDLERS[ name ][ resname ] = chunk
	end

	return chunk
end

local function onAnyResourceStop( restarted_resource )
	if restarted_resource == THIS_RESOURCE then return end

	local restarted_resource_name = getResourceName( restarted_resource )
	for extension_name, resource_list in pairs( HANDLERS ) do
		for resource_name, chunk in pairs( resource_list ) do
			HANDLERS[ extension_name ][ restarted_resource_name ] = nil
		end
	end
end
addEventHandler( IS_SERVERSIDE and "onResourceStop" or "onClientResourceStop", root, onAnyResourceStop )

function getConfig( name )
	return GLOBAL_CONFIG[ name ]
end

function setConfig( name, value )
	GLOBAL_CONFIG[ name ] = value
end