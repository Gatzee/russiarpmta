local is_disabled = false
local CONST_VEH_LIST = {
	[ 520 ] = true,
	[ 425 ] = true,
	[ 476 ] = true,
}

local OFF_CONTROLS = { "vehicle_fire", "vehicle_secondary_fire" }

function onClientKey_handler( key, state )
	if not state then return end

	for k, v in pairs( OFF_CONTROLS ) do
		toggleControl( v, false )

		local keys = getBoundKeys( v )
		for key_name, key_state in pairs( keys ) do
			if key_name == key then
				cancelEvent()
				return
			end
		end
	end
end

function DisableVehicleFire()
	is_disabled = true

	for k, v in pairs( OFF_CONTROLS ) do
		toggleControl( v, false )
	end

	removeEventHandler( "onClientKey", root, onClientKey_handler )
	addEventHandler( "onClientKey", root, onClientKey_handler )
end

function EnableVehicleFire( )
	is_disabled = false

	removeEventHandler( "onClientKey", root, onClientKey_handler )

	for k, v in pairs( OFF_CONTROLS ) do
		toggleControl( v, true )
	end
end

addEventHandler( "onClientPlayerVehicleEnter", localPlayer, function( vehicle )
	if not is_disabled or CONST_VEH_LIST[ vehicle.model ] then return end

	EnableVehicleFire( )
end )

addEventHandler( "onClientVehicleStartEnter", root, function( ped )
	if ped ~= localPlayer or not CONST_VEH_LIST[ source.model ] then return end

	DisableVehicleFire( )
end )

addEventHandler( "onClientPlayerVehicleExit", localPlayer, function( vehicle )
	if not vehicle or not isElement( vehicle ) or not CONST_VEH_LIST[ vehicle.model ] then return end

	EnableVehicleFire( )
end )