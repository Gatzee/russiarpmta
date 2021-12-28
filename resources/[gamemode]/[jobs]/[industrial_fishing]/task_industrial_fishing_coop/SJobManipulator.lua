
function onServerSyncFishingManipulator_handler( target_y, target_rz, target_z, side )
	local lobby_data = GetLobbyDataByPlayer( client )
	if not lobby_data then return end
	
	local target_players = {}
	for k, v in pairs( lobby_data.participants ) do
		if v.player ~= client then table.insert( target_players, v.player ) end
	end
	triggerClientEvent( target_players, "onClientSyncManipulator", resourceRoot, target_y, target_rz, target_z, side )
end
addEvent( "onServerSyncFishingManipulator", true )
addEventHandler( "onServerSyncFishingManipulator", root, onServerSyncFishingManipulator_handler )