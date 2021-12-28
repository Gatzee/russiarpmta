loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )

VARIABLE_VEHICLE_DETAILS = {
	[1] = { "bonnet_dummy", "windscreen_dummy", "wheel_rf_dummy", "wheel_rb_dummy", "wheel_lb_dummy", "wheel_lf_dummy", },
	[2] = { "bonnet_dummy", "windscreen_dummy", "wheel_lb_dummy", "wheel_lf_dummy", "wheel_rf_dummy", "wheel_rb_dummy", },
}

VEHICLES = {
	[ F_POLICE_PPS_GORKI ] = { model = 400, x = 1922.789, y = -721.559 + 860, z = 60.811, rz = 62.721, tuning = { TUNING_SIREN, 2 }, paintjob = 0, },
	[ F_POLICE_PPS_NSK ] = { model = 400, x = -396.580, y = -1659.537 + 860, z = 20.639, rz = 93, tuning = { TUNING_SIREN, 2 }, paintjob = 0, },
	[ F_POLICE_PPS_MSK ] = { model = 400, x = 1174.098, y = 2173.742 + 860, z = 8.802, rz = 269, tuning = { TUNING_SIREN, 2 }, paintjob = 0, },
}

function getPositionsFromVehicleDetail( vehicle, detail_name )
	if detail_name == "bonnet_dummy" then
		local vx, vy, vz = vehicle:getComponentPosition( detail_name, "world" )
		local x, y, z = GetForwardBackwardElementPosition( vehicle, 0, 2.5 )

		return Vector3( vx, vy, vz ), Vector3( x, y, z ) -- return detail's position & marker's position
	else
		local add_x = {
			windscreen_dummy = 0,
			door_lf_dummy = 1.5,
		}

		local add_y = {
			windscreen_dummy = -4,
			door_lf_dummy = -0.25,
		}

		local x, y, z = vehicle:getComponentPosition( detail_name, "world" )
		local r_com_x, r_com_y = vehicle:getComponentPosition( detail_name, "root" )
		local component = getPositionFromMatrixOffset( vehicle, r_com_x * ( add_x[ detail_name ] or 2.15 ), r_com_y * ( add_y[ detail_name ] or 1 ), 0 )

		return Vector3( x, y, z ), Vector3( component.x, component.y, component.z ) -- return detail's position & marker's position
	end
end

function setRotationToTarget( self, target )
	local x, y = getElementPosition( self )
	setElementRotation( localPlayer, 0,  0, FindRotation( x, y, target.x, target.y ) )
end

function GetForwardBackwardElementPosition( self, direction, distance )
	if direction == 1 then distance = distance * -1 end
	local x, y, z  = getElementPosition( self )
	local _, _, rz = getElementRotation( self )

	x = x - math.sin( math.rad( rz ) ) * distance
	y = y + math.cos( math.rad( rz ) ) * distance

	return x, y, z
end

function getPositionFromMatrixOffset( element, offX, offY, offZ )
	return element:getMatrix( ):transformPosition( offX, offY, offZ )
end

addEventHandler( "onClientResourceStart", resourceRoot, function ( )
	CQuest( QUEST_DATA )

	for i, v in pairs( VEHICLES ) do
		local vehicle = Vehicle( v.model, v.x, v.y, v.z )
		vehicle.rotation = Vector3( 0, 0, v.rz )
		vehicle.frozen = true
		vehicle:SetColor( 255, 255, 255 )
		vehicle:SetNumberPlate( "6:а".. math.random( 0, 9 ) .. math.random( 0, 9 ) .. math.random( 0, 9 ) .. math.random( 1, 9 ) .. "99" )

		if v.tuning then
			vehicle:SetExternalTuningValue( v.tuning[ 1 ], v.tuning[ 2 ] )
		end

		if v.paintjob then
			vehicle.paintjob = v.paintjob
		end

		v.element = vehicle
	end
end )