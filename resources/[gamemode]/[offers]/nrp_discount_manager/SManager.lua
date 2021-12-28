loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "Globals" )
Extend( "SDB" )
Extend( "ShUtils" )

CAMPAIGNS = { }
UPDATE_FREQUENCY = 60 * 1000
DATABASE = CommonDB

function CreateTimer()
	if isTimer( UPDATE_TIMER ) then UPDATE_TIMER:destroy( ) end
	UPDATE_TIMER = setTimer( CheckForUpdates, UPDATE_FREQUENCY, 1 )
end

function onResourceStart( )
    DATABASE:createTable( "nrp_discount_manager", {
		{ Field = "key",		Type = "char(36)",		Null = "NO",	Key = "PRI", 	Default = ""									};
		{ Field = "value",		Type = "longtext",		Null = "NO",    Key = "",		options = { json = true }	};
	} )

	-- fill data
	CheckForUpdates( )
	CreateTimer( )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart )

--Если инфа которую мы перебираем ещё не записана, отсылаем её в ивент
--Если инфа которая у нас есть в памяти отличается от той которая нам пришла, отсылаем её в ивент
function CheckForUpdates( )
    DATABASE:queryAsync( function( query )
		CreateTimer( )

        local result = query:poll( -1 )
		if not result then return end

		local timestamp = getRealTimestamp( )

		for idx, v in pairs( result ) do
			local parsedValue = fromJSON( v.value )
			if v.value and v.key and parsedValue then
				local temporaryContainer = { }

				--Перебор внутренних элементов
				for j, jsonValue in pairs ( parsedValue ) do 
					local isAllowed = false
					local endTime   = jsonValue.endTime   or jsonValue.finish_date or jsonValue.finish_ts or jsonValue.time_finish
					local startTime = jsonValue.startTime or jsonValue.start_date  or jsonValue.start_ts  or jsonValue.time_start

					if getTimestampFromString( endTime ) > timestamp and getTimestampFromString( startTime ) <= timestamp then isAllowed = true end
					if isAllowed then
						table.insert( temporaryContainer, jsonValue )
					end
				end

				if not CAMPAIGNS[ v.key ] or toJSON( CAMPAIGNS[ v.key ] ) ~= toJSON( temporaryContainer ) then
					outputDebugString( "[nrp_discount_manager] Found difference in " .. v.key .. ", sending update" )
					CAMPAIGNS[ v.key ] = temporaryContainer

					triggerEvent( "onSpecialDataUpdate", root, v.key, temporaryContainer )
				end
			end
		end
    end, { }, "SELECT * FROM nrp_discount_manager" )
end

addEvent( "onSpecialDataUpdate", false )
addEvent( "onSpecialDataRequest", false )

--Для принудительного получения данных о нужной акции
addEventHandler( "onSpecialDataRequest", root, function( key )
	local data = CAMPAIGNS[ key ]
	if data then
		triggerEvent( "onSpecialDataUpdate", source, key, data )
	end
end )

addEvent( "onFakeTimestampChange" )
addEventHandler( "onFakeTimestampChange", root, CheckForUpdates )