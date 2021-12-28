function CreateAssemblyVehicle( player, params )
	local vehicles = player:GetVehicles()
	if params.temp_days then
		for _, vehicle in pairs( vehicles ) do
			if params.model == vehicle.model then
				local temp_timeout = vehicle:GetPermanentData( "temp_timeout" )
				if temp_timeout and temp_timeout >= getRealTime().timestamp then
					vehicle:SetPermanentData( "temp_timeout", temp_timeout + params.temp_days * 24 * 60 * 60 )
					triggerEvent( "CheckTemporaryVehicle", vehicle )
					return
				end
			end
		end
	else
		for _, vehicle in pairs( vehicles ) do
			local temp_timeout = vehicle:GetPermanentData( "temp_timeout" )
			if params.model == vehicle.model and temp_timeout and temp_timeout > 0 then
				exports.nrp_vehicle:DestroyForever( vehicle:GetID( ) )
			end
		end
	end

	local sOwnerPID = "p:" .. player:GetUserID()

	local pRow	= {
		model 		= params.model;
		variant		= params.variant or 1;
		x			= 0;
		y			= 0;
		z			= 0;
		rx			= 0;
		ry			= 0;
		rz			= 0;
		owner_pid	= sOwnerPID;
		color		= { 255, 255, 255 };
		temp_timeout = ( params.temp_days and ( getRealTimestamp( ) + params.temp_days * 24 * 60 * 60 ) )
	}

	exports.nrp_vehicle:AddVehicle( pRow, true, "AssemblyVehicleAdded", { player = player, cost = VEHICLE_CONFIG[ params.model ].variants[ params.variant or 1 ].cost, temp_days = params.temp_days, temp_timeout = pRow.temp_timeout } )
end;

function AssemblyVehicleAdded_handler( vehicle, data )
	if isElement( vehicle ) and isElement( data.player ) then
		local sOwnerPID = "p:" .. data.player:GetUserID( )
		local player = data.player

		vehicle:SetOwnerPID( sOwnerPID )
		vehicle:SetFuel( "full" )
		vehicle:SetColor( 255, 255, 255 )

		vehicle:SetPermanentData( "showroom_cost", data.cost )
		vehicle:SetPermanentData( "showroom_date", getRealTime( ).timestamp )
		vehicle:SetPermanentData( "first_owner", sOwnerPID )
		vehicle:SetPermanentData( "temp_timeout", data.temp_timeout )
		triggerEvent( "CheckTemporaryVehicle", vehicle )

		local dimension = player:GetUniqueDimension( )
		local free_point = GetFreePlaceAssemblyVehicle( )


		player:SetPrivateData( "give_assembly_vehicle", true )
		setVehicleOverrideLights( vehicle, 2 )

		vehicle:SetParked( false, OFFER_CONFIG.vehicle_position, OFFER_CONFIG.vehicle_rotation )
		player:setDimension( dimension )
		vehicle:setDimension( dimension )
		player:warpIntoVehicle( vehicle, 0 )

		triggerClientEvent( player, "StartSceneGiveActiveAssemblyVehicle", resourceRoot, vehicle )

		setTimer( function( player, vehicle, free_point )
			vehicle:setPosition( free_point.x, free_point.y, free_point.z )
			player:warpIntoVehicle( vehicle, 0 )
			player:setDimension( 0 )
			vehicle:setDimension( 0 )
			player:SetPrivateData( "give_assembly_vehicle", false )
			triggerEvent( "CheckPlayerVehiclesSlots", player )
		end, 5000, 1, player, vehicle, free_point )
	end
end
addEvent( "AssemblyVehicleAdded", true )
addEventHandler( "AssemblyVehicleAdded", resourceRoot, AssemblyVehicleAdded_handler )