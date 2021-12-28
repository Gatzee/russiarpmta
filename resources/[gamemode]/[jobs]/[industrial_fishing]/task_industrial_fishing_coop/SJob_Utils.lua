
function SetPlayerStartPositon( lobby_data )
	local vehicle_position = lobby_data.job_vehicle.position
	local driver = GetLobbyPlayersByRole( lobby_data.lobby_id, DRIVER, true )
	for k, v in pairs( lobby_data.participants ) do
		if v.role ~= DRIVER then
			removePedFromVehicle( v.player )
			v.player.position = vehicle_position
			attachElements( v.player, lobby_data.job_vehicle, (v.role == FISHERMAN and SHIP_SPAWN[ v.role ][ v.player:getData( "fisherman_index" ) ] or SHIP_SPAWN[ v.role ]) )
			if isElement( driver ) then setCameraTarget( v.player, driver ) end
		end
		v.player:setData( "no_evacuation", true, false )
	end
end

function OnServerAnyFinish( lobby_id )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	for k, v in pairs( lobby_data.participants ) do
		removePedFromVehicle( v.player )
		detachElements( v.player )
		v.player.position = RESPAWN_POSITIONS[ math.random(1, #RESPAWN_POSITIONS) ]:AddRandomRange( 5 )
		v.player.rotation = Vector3( 0, 0, 180 )
	end
end