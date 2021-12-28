Extend( "SVehicle" )
Extend( "SPlayer" )
Extend( "SQuestCoop" )

addEventHandler( "onResourceStart", resourceRoot, function()
	SQuestCoop( QUEST_DATA )
end )

-- Начало смены
function onServerHijackCarsStartWork_handler( lobby )
	lobby_data = CreateLobbyData( lobby.lobby_id, lobby )
end
addEvent( "onServerHijackCarsStartWork" )
addEventHandler( "onServerHijackCarsStartWork", root, onServerHijackCarsStartWork_handler )

-- Окончание смены
function onServerHijackCarsEndWork_handler( lobby_id, reason_data )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	for k, v in pairs( lobby_data.participants ) do
		onHijackCarsJobFinish( v.player, lobby_data, reason_data )
	end
end
addEvent( "onServerHijackCarsEndWork" )
addEventHandler( "onServerHijackCarsEndWork", root, onServerHijackCarsEndWork_handler )

-- Награда
function onCoopJobCompletedLap_handler( player, lobby_id, receive_sum, exp_sum )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	onHijackCarsJobVoyage( player, lobby_data, receive_sum, exp_sum )
end
addEvent( "onCoopJobCompletedLap" )
addEventHandler( "onCoopJobCompletedLap", resourceRoot, onCoopJobCompletedLap_handler )

if SERVER_NUMBER > 100 then
	addCommandHandler( "hijack_car_point_id", function( player, cmd, point_id )
		point_id = tonumber( point_id )
		local count_points = #POSITIONS_HIJACKED_CARS
		if not point_id or point_id < 0 or point_id > count_points then
			player:ShowInfo( "syntax: /hijack_car_point_id id<1-" .. count_points .. ">" )
			return 
		end
		TARGET_POINT_ID = point_id
	end )

	addCommandHandler( "test_hijack_point", function( player, cmd, point_id )
		if isElement( TEST_VEHICLE ) then destroyElement( TEST_VEHICLE ) end

		point_id = tonumber( point_id )
		local count_points = #POSITIONS_HIJACKED_CARS
		if not point_id or point_id < 0 or point_id > count_points then
			player:ShowInfo( "syntax: /test_hijack_point id<1-" .. count_points .. ">" )
			return 
		end

		local point_data = POSITIONS_HIJACKED_CARS[ point_id ]
		TEST_VEHICLE = createVehicle( 415, point_data.vehicle.pos + Vector3( 0, 0, 1 ), point_data.vehicle.rot )
		player.position = point_data.vehicle.pos + Vector3( 0, 0, 5 )
		warpPedIntoVehicle( player, TEST_VEHICLE )
	end )
end