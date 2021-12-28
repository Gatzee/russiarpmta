ZONES_LIST = 
{
	-- Аэропорт кантрисайд
	{
		-3006.2839355469, 359.3046875;
		-2248.2648925781, 1674.8588867188;
		-1991.5, 1534.7351074219;
		-2454.8234863281, 802.8856201172;
		-2330.0849609375, 731.3114013672;
		-2407.5571289063, 585.9953613281;
		-2339.0391535156, 544.5881601563;
		-2573.7343203125, 152.3569975586;
		-2793.1870117188, 240.7884521484;
		-3006.2839355469, 359.3046875;
	},

	-- Аэропорт горки
	{
		2574.1218261719, -2173.2413330078;
		2527.046875, -2146.8464355469;
		2409.5959472656, -2257.9459228516;
		2361.8918457031, -2308.2342529297;
		2280.4362792969, -2478.5629882813;
		2268.5339355469, -2550.9892578125;
		2321.5187988281, -2574.5430908203;
		2366.6293945313, -2590.7661132813;
		2580.5068359375, -2191.541015625;
		2574.1218261719, -2173.2413330078;
	},
}

local is_in_zone = false
local vehicles_list = {}
local my_vehicles_list = {}

addEventHandler("onClientResourceStart", resourceRoot, function()
	for k,v in pairs(ZONES_LIST) do
		local pZone = createColPolygon( unpack( v ) )

		addEventHandler("onClientColShapeHit", pZone, OnZoneHit)
		addEventHandler("onClientColShapeLeave", pZone, OnZoneLeave)
	end
end)

function OnZoneHit( pElement, dim )
	if not dim then return end

	if pElement == localPlayer then OnPlayerZoneHit() end
	if getElementType(pElement) ~= "vehicle" then return end

	if is_in_zone then
		for i, pVehicle in pairs(my_vehicles_list) do
			if isElement( pVehicle ) then
				setElementCollidableWith( pVehicle, pElement, false )
			end
		end

		vehicles_list[pElement] = nil
	end
end

function OnZoneLeave( pElement, dim )
	if pElement == localPlayer then OnPlayerZoneLeave() end
	if not isElement( pElement ) or getElementType(pElement) ~= "vehicle" then return end

	if is_in_zone then
		for i, pVehicle in pairs(my_vehicles_list) do
			if isElement( pVehicle ) then
				setElementCollidableWith( pVehicle, pElement, true )
			end
		end

		vehicles_list[pElement] = nil
	end
end

function OnPlayerZoneHit()
	if not is_in_zone then
		is_in_zone = true

		for k,v in pairs( getElementsWithinColShape(source, "vehicle") ) do
			vehicles_list[v] = true
		end

		local pVehicle = localPlayer.vehicle

		if isElement(pVehicle) then
			for other_vehicle, state in pairs(vehicles_list) do
				if isElement(other_vehicle) then
					setElementCollidableWith( pVehicle, other_vehicle, false )
				else
					vehicles_list[other_vehicle] = nil
				end
			end

			table.insert(my_vehicles_list, pVehicle)
		end

		addEventHandler("onClientPlayerVehicleEnter", localPlayer, OnVehicleEnter)
	end
end

function OnPlayerZoneLeave()
	is_in_zone = false

	removeEventHandler("onClientPlayerVehicleEnter", localPlayer, OnVehicleEnter)

	for i, pVehicle in pairs(my_vehicles_list) do
		if isElement( pVehicle ) then
			for other_vehicle, state in pairs(vehicles_list) do
				if isElement(other_vehicle) then
					setElementCollidableWith( pVehicle, other_vehicle, true )
				end
			end
		end
	end

	my_vehicles_list = {}
	vehicles_list = {}
end

function OnVehicleEnter( pVehicle )
	for other_vehicle, state in pairs(vehicles_list) do
		if isElement(other_vehicle) then
			setElementCollidableWith( pVehicle, other_vehicle, false )
		else
			vehicles_list[other_vehicle] = nil
		end
	end

	table.insert(my_vehicles_list, pVehicle)
end