function PlayerWantAttachToVehicle_handler( vehicle, offset )
	if not client then return end

	if isElementAttached( client ) then
		detachElements( client )
		return
	end

	if not isElement( vehicle )	then return end
	if client:getData( "is_handcuffed" ) then return end
	
	local vehicle_matrix = vehicle.matrix:transformPosition( VEHICLE_ATTACH_CONFIG[ vehicle.model ].position )
	if ( client.position - vehicle_matrix ).length > VEHICLE_ATTACH_CONFIG[ vehicle.model ].radius then return end

	client:attach( vehicle, offset[1], offset[2], offset[3] )
end
addEvent( "PlayerWantAttachToVehicle", true )
addEventHandler( "PlayerWantAttachToVehicle", resourceRoot, PlayerWantAttachToVehicle_handler )