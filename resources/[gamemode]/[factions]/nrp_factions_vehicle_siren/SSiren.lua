function SetupVehicleSiren( pVehicle )
	if not isElement(pVehicle) then return end
	local conf = VEHICLE_SIREN_CONFIG[pVehicle.model]

	if conf and conf.no_by_faction and conf.no_by_faction[ pVehicle:GetFaction( ) ] then
		return
	end

	if conf and conf.by_faction and conf.by_faction[ pVehicle:GetFaction( ) ] then
		conf = conf.by_faction[ pVehicle:GetFaction( ) ]
	end

	if conf then
		addVehicleSirens( pVehicle, #conf.points, 4, false, true, true, true )
		for i, point in pairs(conf.points) do
			setVehicleSirens( pVehicle, i, point.x, point.y, point.z, point.r, point.g, point.b )
		end

		setElementData( pVehicle, "sirens", false )
	end
end
addEvent("SetupVehicleSirens", true)
addEventHandler("SetupVehicleSirens", root, SetupVehicleSiren)

--[[addEventHandler("onResourceStart", resourceRoot, function()
	for k,v in pairs(getElementsByType("vehicle")) do
		SetupVehicleSiren( v )
	end
end)]]

addEventHandler("onResourceStop", resourceRoot, function()
	for k,v in pairs(getElementsByType("vehicle")) do
		if VEHICLE_SIREN_CONFIG[v.model] then
			removeVehicleSirens( v )
		end
	end
end)