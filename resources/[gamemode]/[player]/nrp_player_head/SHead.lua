function head_handler( data )
	local send_to_players = { }
	for i, v in pairs( getElementsByType( "player" ) ) do
		if source ~= v and getDistanceBetweenPoints3D( client.position, v.position ) <= 30 and source.interior == v.interior and source.dimension == v.dimension then
			table.insert( send_to_players, v )
		end
	end
	if #send_to_players > 0 then
		triggerClientEvent( send_to_players, "head_c", client, data )
	end
end
addEvent( "head", true )
addEventHandler( "head", root, head_handler )