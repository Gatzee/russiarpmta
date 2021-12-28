loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )
Extend( "Globals" )
Extend( "ShVehicleConfig" )
Extend( "SPlayer" )
Extend( "SVehicle" )

local ZONES = {}
local ZONES_REVERSE = {}

local TRACKED_VEHICLES = {}

function OnResourceStart()
	for k,v in pairs( ZONES_LIST ) do
		local pZone = CreateNoVehicleZone( v )
		table.insert(ZONES, pZone)
		ZONES_REVERSE[pZone.element] = pZone
	end
end
addEventHandler("onResourceStart", resourceRoot, OnResourceStart)

function CreateNoVehicleZone( conf )
	conf.element = createColPolygon( unpack( conf.polygon ) )
	
	local ignored_models_reverse = {}
	for i,v in pairs(conf.ignored_vehicle_models) do
		ignored_models_reverse[v] = true
	end

	local ignored_types_reverse = {}
	for i,v in pairs(conf.ignored_vehicle_types) do
		ignored_types_reverse[v] = true
	end

	conf.ignored_vehicle_types = ignored_types_reverse
	conf.ignored_vehicle_models = ignored_models_reverse

	addEventHandler("onColShapeHit", conf.element, OnZoneHit)

	return conf
end

function OnZoneHit( pElement, dim )
	if not dim then return end
	local element_type = getElementType( pElement )

	if ZONES_REVERSE[ source ].no_evacuation and element_type == "player" then
		pElement:setData( "no_evacuation", true, false )
		removeEventHandler("onElementColShapeLeave", pElement, OnZoneLeavePlayer )
		addEventHandler("onElementColShapeLeave", pElement, OnZoneLeavePlayer )
	end

	if element_type ~= "vehicle" then return end
	if pElement:getData( "quest_vehicle" ) then return end
	if pElement:getData( "ignore_removal" ) then return end

	local pZone = ZONES_REVERSE[ source ]
	local iModel = pElement.model
	local sType = pElement:GetSpecialType()

	if pZone.ignored_vehicle_types[sType] then return end
	if pZone.ignored_vehicle_models[iModel] then return end

	local iSeconds = math.floor(pZone.time_limit/1000)
	local iTimeLeft = iSeconds - (TRACKED_VEHICLES[pElement] and TRACKED_VEHICLES[pElement].time_inside or 0)

	local pPlayer = pElement.controller
	if pPlayer then
		pPlayer:ShowError("Сюда нельзя въезжать на транспорте,\nу тебя есть "..iTimeLeft.." секунд,\nчтобы покинуть эту территорию")
	end

	TRACKED_VEHICLES[pElement] = 
	{
		hit_in = getTickCount(),
		leave_in = 0,
		time_inside = 0,
	}

	if iTimeLeft >= 5 then
		TRACKED_VEHICLES[pElement].timer = setTimer(function( pVehicle, pZoneElement )
			if not isElement(pVehicle) then return end
			if not isElementWithinColShape( pVehicle, pZoneElement ) then return end
			RemoveTrackedVehicle( pVehicle )
		end, iTimeLeft*1000, 1, pElement, pZone.element)
	else
		RemoveTrackedVehicle( pElement )
 	end

	removeEventHandler( "onElementColShapeLeave", pElement, OnZoneLeave )
	addEventHandler("onElementColShapeLeave", pElement, OnZoneLeave)
end

function OnZoneLeavePlayer( zone )
	if not ZONES_REVERSE[ zone ] then return end

	removeEventHandler( "onElementColShapeLeave", source, OnZoneLeavePlayer )
	source:setData( "no_evacuation", false, false )
end

function OnZoneLeave( zone )
	local pZone = ZONES_REVERSE[ zone ]
	if not pZone then return end

	if TRACKED_VEHICLES[source] then
		TRACKED_VEHICLES[source].leave_in = getTickCount()
		TRACKED_VEHICLES[source].time_inside = TRACKED_VEHICLES[source].time_inside + math.floor( ( TRACKED_VEHICLES[source].leave_in - TRACKED_VEHICLES[source].hit_in )/1000 )
	end

	if source.controller then
		source.controller:ShowInfo("Ты покинул запретную зону")
	end

	removeEventHandler("onElementColShapeLeave", source, OnZoneLeave)

	setTimer(ResetTrackedVehicle, 10000, 1, source)
end

function RemoveTrackedVehicle( pVehicle )
	local pPlayer = pVehicle.controller

	local owner_id = pVehicle:GetOwnerID()
	if owner_id and not pPlayer then
		pPlayer = GetPlayer( owner_id )
	end

	if isElement(pPlayer) then
		pPlayer:ShowError("Ваш транспорт был эвакуирован с территории!")
	end

	for k,v in pairs( getVehicleOccupants( pVehicle ) ) do
		removePedFromVehicle( v )
	end

	setElementPosition( pVehicle, -20000, 0, 0 )

	ResetTrackedVehicle( pVehicle )
end

function ResetTrackedVehicle( pVehicle )
	TRACKED_VEHICLES[pVehicle] = nil
end