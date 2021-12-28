-- Открытие/закрытие кузова
addEvent( "onPlayerTryChangeTrashTruckOpenState", true )
addEventHandler( "onPlayerTryChangeTrashTruckOpenState", resourceRoot, function( state )
	local player = client
	local job_vehicle = player:getData( "job_vehicle" )
	if not isElement( job_vehicle ) then return end

	triggerClientEvent( GetPlayersInGame( ), "onClientTrashTruckOpenStateChange", job_vehicle, state )
end )

-- Опускание/поднятие кузова
addEvent( "onPlayerTryChangeTrashTruckLiftState", true )
addEventHandler( "onPlayerTryChangeTrashTruckLiftState", resourceRoot, function( state )
	local player = client
	local job_vehicle = player:getData( "job_vehicle" )
	if not isElement( job_vehicle ) then return end

	triggerClientEvent( GetPlayersInGame( ), "onClientTrashTruckLiftStateChange", job_vehicle, state )
end )