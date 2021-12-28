local DECELERATION = 0.015

function ParseVelocity()
	local vehicle = localPlayer.vehicle
	if not vehicle then return end

	if vehicle.occupants[ 0 ] ~= localPlayer then return end
	if vehicle.onGround or isOnGround( vehicle ) or vehicle.vehicleType ~= "Automobile" then return end

	vehicle.velocity = Vector3( vehicle.velocity.x, vehicle.velocity.y, vehicle.velocity.z - DECELERATION )
end

function onClientVehicleEnter_handler( player )
	if player ~= localPlayer then return end
	onClientVehicleExit_handler( player )
	VELOCITY_TIMER = Timer( ParseVelocity, 50, 0 )
	addEventHandler( "onClientVehicleExit", root, onClientVehicleExit_handler )
end
addEventHandler( "onClientVehicleEnter", root, onClientVehicleEnter_handler )

function onClientVehicleExit_handler( player )
	if player ~= localPlayer then return end
	if isTimer( VELOCITY_TIMER ) then killTimer( VELOCITY_TIMER ) end
	removeEventHandler( "onClientVehicleExit", root, onClientVehicleExit_handler )
end

if localPlayer.vehicle then onClientVehicleEnter_handler( localPlayer ) end

function isOnGround( vehicle )
	return isVehicleWheelOnGround( vehicle, 0 ) and isVehicleWheelOnGround( vehicle, 1 ) and isVehicleWheelOnGround( vehicle, 2 ) and isVehicleWheelOnGround( vehicle, 3 )
end