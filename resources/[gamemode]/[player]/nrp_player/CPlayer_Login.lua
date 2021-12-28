local RESOURCES_LIST = {}
local RESOURCE_RECIVED = false
local SENT = false
local LAST_TIMESTAMP_RECEIVE_TICK, LAST_RECEIVE_TIMESTAMP

addEventHandler( "onClientResourceStart", root, function( )
	if SENT then return end

	if RESOURCE_RECIVED then
		CheckResourcesClientStarted( )
	end
end )

addEventHandler( "onClientResourceStart", resourceRoot, function ( )
	triggerServerEvent( "onRequestServerTimestamp", resourceRoot )
	triggerServerEvent( "onClientPlayerRequestResourcesList", resourceRoot )
end )

-- Запрашиваем таймстамп ещё раз после того, как клиент прогрузил все первоначальные данные, 
-- и нагрузка на его пк и сеть стала нормальной, 
-- чтобы задержка при получении таймстампа с сервера была минимальной
addEvent( "onClientPlayerNRPSpawn", true )
addEventHandler( "onClientPlayerNRPSpawn", root, function( spawn_mode )
	if spawn_mode == 3 then return end
	setTimer( function( )
		triggerServerEvent( "onRequestServerTimestamp", resourceRoot )
	end, 5000, 1 )
end )

addEvent( "onReciveResourceList", true )
addEventHandler( "onReciveResourceList", resourceRoot, function( list, url )
	RESOURCES_LIST = { }

	for _, resource_name in pairs( list ) do
		RESOURCES_LIST[ resource_name ] = true
	end

	RESOURCE_RECIVED = true

	CheckResourcesClientStarted()
	
	StartLoggingClientErrors( url )
end )

function CheckResourcesClientStarted()
	if SENT then return end

	for name, _ in pairs( RESOURCES_LIST ) do
		local resource = getResourceFromName( name )

		if not resource or getResourceState( resource ) == "running" then
			RESOURCES_LIST[ name ] = nil
		end
	end

	if not next( RESOURCES_LIST ) then
		SENT = true
		iprint( "All resources are ready! Starting up..." )
		HWID = getPlayerSerial(localPlayer)
        SESSIONID = getPlayerSerial(localPlayer)
        setTimer( triggerServerEvent, 2000, 1, "OnClientPlayerReady", resourceRoot, {HWID = HWID, SESSIONID = SESSIONID} )
	end
end

getClientACData = getClientACData or function( ) return { } end

addEvent( "onRecieveServerTimestamp", true )
addEventHandler( "onRecieveServerTimestamp", resourceRoot, function( server_timestamp )
	local timestamp_fake_diff = root:getData( "timestamp_fake_diff" )
	-- На случай, если данные пришли с задержкой (например, подскочил пинг)
	if LAST_RECEIVE_TIMESTAMP and not timestamp_fake_diff and ( localPlayer:getData( "timestamp_real" ) or 0 ) >= server_timestamp then
		return
	end

	if not LAST_RECEIVE_TIMESTAMP then
		setTimer( function( )
			local passed_secs = math.floor( ( getTickCount( ) - LAST_TIMESTAMP_RECEIVE_TICK ) / 1000 )
			localPlayer:setData( "timestamp_real", LAST_RECEIVE_TIMESTAMP + passed_secs, false )
		end, 1000, 0 )
	end

	LAST_TIMESTAMP_RECEIVE_TICK = getTickCount( )
	LAST_RECEIVE_TIMESTAMP = server_timestamp + ( timestamp_fake_diff or 0 )

	localPlayer:setData( "timestamp_real", LAST_RECEIVE_TIMESTAMP, false )
	localPlayer:setData( "timestamp_diff", getRealTime( ).timestamp - server_timestamp, false )
end )