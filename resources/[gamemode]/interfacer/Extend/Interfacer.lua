-- Interfacer.lua. Необходимая часть для работы интерфейсера в других ресурсах.

local getElementData    = getElementData
local getElementsByType = getElementsByType
local getElementByID    = getElementByID
local setElementID      = setElementID
local getElementType    = getElementType
local tonumber          = tonumber
local type              = type
local pairs             = pairs
local string_sub        = string.sub

API_URL            = "https://api.nextrp.ru"
THIS_RESOURCE_NAME = THIS_RESOURCE_NAME or getResourceName( getThisResource( ) )

addEvent( "onExtensionUpdate", true )
if _G.handle_extension_updates then
	removeEventHandler( "onExtensionUpdate", resourceRoot, _G.handle_extension_updates )
end

function handle_extension_updates( chunk, name, player )
	if client then return end
	if not chunk then
		outputDebugString( "Module load error: " .. inspect( chunk ) .. " // " .. inspect( name ), 2 )
		return 
	end

	local is_returnable = name == "execute" and isElement( player )
	local result, err

	if is_returnable then
		result, err = loadstring( "return " .. chunk )
	end

	if not result or err then
		result, err = loadstring( chunk )
	end

	if not result or err then 
		result = err
	else
		result = { result( ) }
	end 

	if is_returnable then
		triggerEvent( "onExecutionCallback", player, unpack( result ) )
	end
end
addEventHandler( "onExtensionUpdate", resourceRoot, handle_extension_updates )

local LOADED = { }

function Extendexe( name, ... )
	if LOADED[ name ] then return false, "Модуль " .. name .. " уже подключен" end
	if getResourceState( getResourceFromName( "interfacer" ) ) ~= "running" then return false, "Interfacer не запущен" end

	local str, err = exports.interfacer:extend( name, THIS_RESOURCE_NAME, ... )

	if str and not err then
		local chunk = type( str ) == "string" and loadstring( str )
		if chunk then
			local result, err = pcall( chunk )
			if not result then
				err = err and err:gsub( "%[string \".*%.%.%.\"%]:(%d+):" , "[" .. name .. ".lua:%1]" ) or "magic error"
				return false, err
			else
				LOADED[ name ] = true
				return true
			end
		end
	else
		return false, err
	end
end

function Import( name, ... )
	Extendexe( name, ... )
end

function Extend( name, ... )
	local result, err = Extendexe( name, ... )
	if not result and err then
		outputDebugString( err, 1 )
	end
end

function GetPlayer( id )
	if type( id ) == "number" then
		return getElementByID( "p" .. id )
	end
end

function GetVehicle( id )
	if type( id ) == "number" then
		return getElementByID( "v" .. id )
	end
end

function GetPlayersInGame( )
	return getElementsByType( "player", getElementByID( "inGamePlayers" ) )
end

function GetPlayerByClientID( sClientID )
	for _, player in pairs( getElementsByType( "player" ) ) do
		if getElementData( player, "_clientid" ) == sClientID then
			return player
		end
	end
end

function enum( name )
	return function( array )
		for i,v in ipairs( array ) do
			_G[v] = i
		end
	end
end

function getRealTimestamp( )
    if localPlayer then
        return localPlayer:getData( "timestamp_real" ) or 0
    end

    return getRealTime( ).timestamp + ( root:getData( "timestamp_fake_diff" ) or 0 )
end

function SET( ... )
	return exports.interfacer:setConfig( ... )
end

function GET( ... )
	return exports.interfacer:getConfig( ... )
end

Debug = outputDebugString

Element.SetID = function( self, id )
	local element_type = string_sub( getElementType( self ), 1, 1 )
	return setElementID( self, element_type .. id )
end

Element.GetID = function( self )
	local element_id = getElementID( self )
	return element_id and tonumber( string_sub( element_id, 2, -1 ) ) or element_id
end

-- Подгрузка только серверных функций
if not localPlayer then
	Import( "SInterfacer" )
else
	local client_id = getPlayerSerial(localPlayer)
	function SendElasticGameEvent( name, data )
		triggerEvent( "SendElasticGameEvent", localPlayer, client_id, name, data )
	end

	local _toggleControl = toggleControl
	toggleControl = function( control, state )
		local states = getElementData( localPlayer, "controls_disabled_by" ) or {}
	
		if not states[ control ] then states[ control ] = {} end
		states[ control ][THIS_RESOURCE_NAME] = not state or nil
		if not next( states[ control ] ) then states[ control ] = nil end
	
		_toggleControl( control, not states[ control ] )
	
		return setElementData( localPlayer, "controls_disabled_by", states, false )
	end
	
	local _toggleAllControls = toggleAllControls
	toggleAllControls = function( state, ... )
		_toggleAllControls( state, ... )
	
		if state then
			for control in pairs( getElementData( localPlayer, "controls_disabled_by" ) or {} ) do
				toggleControl( control, true )
			end
		end
	end
end