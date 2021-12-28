local ACTIVITY_ZONES = 
{
	Vector3( 492.92, -2866.807, 20.595 ),
	Vector3( -1267.833, -1258.938, 21.5 ),
	Vector3( -766.049, -1246.378, 15.785 ),
	Vector3( -8.241, -1694.879, 20.813 ),
	Vector3( 491.452, -2362.762, 20.58 ),
}
local VEHICLES = {}

function EventVehicle_Create( config )

	local pVehicle = Vehicle.CreateTemporary( config.model, config.x, config.y, config.z, config.rx or 0, config.ry or 0, config.rz or 0)
	pVehicle:SetProperty("br_vehicle", true)
	pVehicle:SetProperty("damage_mul", 1)
	pVehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_AUTO ) )
	pVehicle:SetFuel( pVehicle:GetMaxFuel() )

	setVehicleUseBrokenEngineBehavior( pVehicle, false )

	addEventHandler("onVehicleExplode", pVehicle, OnVehicleExplode)
	addEventHandler("onVehicleEnter", pVehicle, OnVehicleEnter)
	addEventHandler("onVehicleExit", pVehicle, OnVehicleExit)

	VEHICLES[pVehicle] = { config = config }

	return pVehicle
end

function CreateEventVehicles( dimension )
	for k,v in pairs( VEHICLE_POSITIONS ) do
		local pVehicle = EventVehicle_Create( v )
		pVehicle.dimension = dimension
	end
end

function DestroyEventVehicles()
	if not VEHICLES then return end

	for vehicle, data in pairs(VEHICLES) do
		if isElement(vehicle) then
			vehicle:DestroyTemporary()
		end

		if isTimer(data.timer) then
			killTimer(data.timer)
		end
	end

	VEHICLES = {}
end

function RespawnVehicle( pVehicle )
	if isElement(pVehicle) then
		if not isVehicleBlown(pVehicle) and IsVehicleWithinActivityZones( pVehicle ) then return end
		if pVehicle.controller then return end

		for k,v in pairs(pVehicle.occupants) do
			removePedFromVehicle( v )
		end

		pVehicle.position = Vector3( VEHICLES[pVehicle].config.x, VEHICLES[pVehicle].config.y, VEHICLES[pVehicle].config.z )
		pVehicle.rotation = Vector3( VEHICLES[pVehicle].config.rx or 0, VEHICLES[pVehicle].config.ry or 0, VEHICLES[pVehicle].config.rz or 0 )
		pVehicle:Fix()
	end
end

function StartVehicleRespawnTimer( pVehicle )
	if isTimer(VEHICLES[pVehicle].timer) then
		killTimer(VEHICLES[pVehicle].timer)
	end

	VEHICLES[pVehicle].timer = setTimer(RespawnVehicle, 30000, 0, pVehicle)
end

function IsVehicleWithinActivityZones( vehicle )
	for i, zone in pairs(ACTIVITY_ZONES) do
		if ( vehicle.position - zone ).length <= 40 then
			return true
		end
	end
end

function OnVehicleEnter( pPlayer, seat )
	if seat == 0 then
		setVehicleEngineState(source, true)

		if isTimer(VEHICLES[source].timer) then
			killTimer(VEHICLES[source].timer)
		end
	else
		toggleControl( pPlayer, "vehicle_fire", true )
	end
end

function OnVehicleExit( pPlayer, seat )
	StartVehicleRespawnTimer( source )
end

function OnVehicleExplode()
	setTimer(function( pVehicle )
		RespawnVehicle(pVehicle)
	end, 3000, 1, source )
end