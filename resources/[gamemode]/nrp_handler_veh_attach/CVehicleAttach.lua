local timeout = 0

bindKey( "lalt", "up", function()
	if isElementAttached( localPlayer ) then
		triggerServerEvent( "PlayerWantAttachToVehicle", resourceRoot, nil )
		return
	end

	local vehicle = localPlayer:getContactElement()
	if not isElement( vehicle ) or not VEHICLE_ATTACH_CONFIG[ vehicle.model ] then return end

	local transform_position = vehicle.matrix:transformPosition( VEHICLE_ATTACH_CONFIG[ vehicle.model ].position )
	if ( localPlayer.position - transform_position ).length > VEHICLE_ATTACH_CONFIG[ vehicle.model ].radius then return end

	if timeout > getTickCount() then return end
	timeout = getTickCount() + 1000

	triggerServerEvent( "PlayerWantAttachToVehicle", resourceRoot, vehicle, getOffsetToAttach( vehicle, localPlayer ) )
end )

function getOffsetToAttach( vehicle, player )
	local vX, vY, vZ = getElementPosition( vehicle )
	local pX, pY, pZ = getElementPosition( player )

	local vrZ = math.rad(360 - vehicle.rotation.z)
	local offsetX = math.cos(vrZ)*(pX-vX) - math.sin(vrZ)*(pY-vY)
	local offsetY = math.sin(vrZ)*(pX-vX) + math.cos(vrZ)*(pY-vY)
	local offsetZ = pZ-vZ

    return { offsetX, offsetY, offsetZ }
end