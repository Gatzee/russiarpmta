function OnClientSpecialVehicleCreated( pVehicle )
	if isElement(pVehicle) then
		localPlayer:ShowSuccess( "Твой транспорт доставлен" )
		triggerEvent( "ToggleGPS", localPlayer, pVehicle.position )
	end
end
addEvent("OnClientSpecialVehicleCreated", true)
addEventHandler("OnClientSpecialVehicleCreated", root, OnClientSpecialVehicleCreated)