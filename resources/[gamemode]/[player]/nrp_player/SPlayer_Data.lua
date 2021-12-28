local setElementData = setElementData
local triggerClientEvent = triggerClientEvent

-- Таблица измененных значений для сохранения данных игроков
CHANGED_VALUES = { }

function GetAllPermanentData( player )
	return PLAYER_DATA[ player ]
end

function SetPermanentData_handler( key, value )
	local pdata = PLAYER_DATA[ source ]
	if pdata then
		if not CHANGED_VALUES[ source ] then
			CHANGED_VALUES[ source ] = { }
		end
		if COLUMNS_REVERSE[ key ] then
			if pdata[ key ] ~= value then
				CHANGED_VALUES[ source ][ key ] = true
			end
			pdata[ key ] = value
		else
			if pdata[ LOCKED_KEY ][ key ] ~= value then
				CHANGED_VALUES[ source ][ LOCKED_KEY ] = true
			end
			pdata[ LOCKED_KEY ][ key ] = value
		end
	end
end
addEvent( "SetPermanentData" )
addEventHandler( "SetPermanentData", root, SetPermanentData_handler )

function SetBatchPermanentData_handler( list )
	local pdata = PLAYER_DATA[ source ]
	if pdata then
		if not CHANGED_VALUES[ source ] then
			CHANGED_VALUES[ source ] = { }
		end
		for key, value in pairs( list ) do
			if COLUMNS_REVERSE[ key ] then
				if pdata[ key ] ~= value then
					CHANGED_VALUES[ source ][ key ] = true
				end
				pdata[ key ] = value
			else
				if pdata[ LOCKED_KEY ][ key ] ~= value then
					CHANGED_VALUES[ source ][ LOCKED_KEY ] = true
				end
				pdata[ LOCKED_KEY ][ key ] = value
			end
		end
	end
end
addEvent( "SetBatchPermanentData" )
addEventHandler( "SetBatchPermanentData", root, SetBatchPermanentData_handler )

-- Обычный метод взятия перменент даты
function GetPermanentData( player, key )
	local pdata = PLAYER_DATA[ player ]
	if pdata then
		if COLUMNS_REVERSE[ key ] then
			return pdata[ key ]
		else
			return pdata[ LOCKED_KEY ][ key ]
		end
	end
end

-- Взятие сразу нескольких данных
function GetBatchPermanentData( player, ... )
	local pdata = PLAYER_DATA[ player ]
	if pdata then
		local values = { }
		for i, key in pairs( { ... } ) do
			if COLUMNS_REVERSE[ key ] then
				values[ key ] = pdata[ key ]
			else
				values[ key ] = pdata[ LOCKED_KEY ][ key ]
			end
		end
		return values
	end
	return { }
end

-- На callback'е, оч скоростной
function GetAsyncPermanentData_handler( key, callback_event, ... )
	local result
	local pdata = PLAYER_DATA[ source ]
	if pdata then
		if COLUMNS_REVERSE[ key ] then
			result = pdata[ key ]
		else
			result = pdata[ LOCKED_KEY ][ key ]
		end
	end
	triggerEvent( callback_event, source, result, ... )
end
addEvent( "GetAsyncPermanentData" )
addEventHandler( "GetAsyncPermanentData", root, GetAsyncPermanentData_handler )

-- SetPrivateData, синхронит только одному клиенту
local ELEMENT_DATA = { }
function SetPrivateData_handler( key, value )
	setElementData( source, key, value, false )
	if PLAYER_DATA[ source ] then
		triggerClientEvent( source, "_sdata", resourceRoot, key, value )
	else
		if not ELEMENT_DATA[ source ] then ELEMENT_DATA[ source ] = { } end
		ELEMENT_DATA[ source ][ key ] = value
	end
end
addEvent( "SetPrivateData" )
addEventHandler( "SetPrivateData", root, SetPrivateData_handler )

function SetBatchPrivateData_handler( list )
	if next( list ) then
		for i, v in pairs( list ) do
			setElementData( source, i, v, false )
		end
		triggerClientEvent( source, "_bdata", resourceRoot, list )
	end
end
addEvent( "SetBatchPrivateData", true )
addEventHandler( "SetBatchPrivateData", root, SetBatchPrivateData_handler )

function onPlayerCompleteLogin_PrivateDataHandler()
	if ELEMENT_DATA[ source ] then
		triggerClientEvent( source, "_bdata", resourceRoot, ELEMENT_DATA[ source ] )
		ELEMENT_DATA[ source ] = nil
	end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_PrivateDataHandler, true, "high+1000000" )

function onPlayerQuit_PrivateDataHandler()
	ELEMENT_DATA[ source ] = nil
end
addEventHandler( "onPlayerQuit", root, onPlayerQuit_PrivateDataHandler )