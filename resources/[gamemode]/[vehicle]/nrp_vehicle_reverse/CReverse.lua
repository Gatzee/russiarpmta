local MAX_VELOCITY = 0.1
local MAX_BROKEN_VELOCITY = 0.05
local LAST_LENGTH = 0

function ParseVelocity()
	local vehicle = localPlayer.vehicle
	if not vehicle then return end

	if vehicle.occupants[ 0 ] ~= localPlayer then return end

	local side_vector = Vector2( vehicle.velocity.x, vehicle.velocity.y )

	local fake_vector = vehicle.velocity

	local veh_vector = vehicle.matrix.forward
	veh_vector.z = 0

	local angle = ( fake_vector:getLength() * veh_vector:getLength() ) / fake_vector:dot( veh_vector )

	-- Ограничение для поломаной машины
	if getElementHealth( vehicle ) <= 360 then
		if side_vector:getLength( ) > MAX_BROKEN_VELOCITY then
			side_vector = side_vector:getNormalized() * MAX_BROKEN_VELOCITY
			vehicle.velocity = Vector3( side_vector.x, side_vector.y, vehicle.velocity.z )
			return
		end
	end

	-- Ограничение заднего хода
	if angle <= 0.9 and side_vector:getLength() > MAX_VELOCITY and vehicle.velocity.z > -0.1 then
		if LAST_LENGTH <= MAX_VELOCITY then
			LAST_LENGTH = MAX_VELOCITY
			side_vector = side_vector:getNormalized() * MAX_VELOCITY
			vehicle.velocity = Vector3( side_vector.x, side_vector.y, vehicle.velocity.z )
		end
	else
		LAST_LENGTH = side_vector:getLength()
	end
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