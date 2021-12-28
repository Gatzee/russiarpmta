loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CVehicle")
Extend("ShVehicleConfig")

local HANDLED_VEHICLES = {}

addEventHandler("OnClientVehiclePropertiesChanged", root, function( pData )
	if pData.br_vehicle then
		if not HANDLED_VEHICLES[source] then
			HANDLED_VEHICLES[source] = true
			addEventHandler("onClientVehicleDamage", source, OnVehicleDamage_handler)
			addEventHandler("onClientElementDestroy", source, OnVehicleDestroy_handler)
		end
	end
end)

function OnVehicleStreamedIn()
	if getElementType(source) == "vehicle" then
		if source:GetProperty("br_vehicle") then
			if not HANDLED_VEHICLES[source] then
				HANDLED_VEHICLES[source] = true
				addEventHandler("onClientVehicleDamage", source, OnVehicleDamage_handler)
				addEventHandler("onClientElementDestroy", source, OnVehicleDestroy_handler)
			end
		else
			triggerServerEvent("OnRequestVehicleProperties", localPlayer, source)
		end
	end
end

function OnVehicleDestroy_handler()
	HANDLED_VEHICLES[source] = nil
	removeEventHandler("onClientVehicleDamage", source, OnVehicleDamage_handler)
	removeEventHandler("onClientVehicleDestroy", source, OnVehicleDestroy_handler)
end

function OnVehicleDamage_handler( attacker, weapon, loss, x, y, z, tire )
	if not tire then
		local mul = source:GetProperty("damage_mul")
		if mul then
			source.health = source.health - (loss*mul-loss)
		end
	end
end

function ToggleClientVehiclesHandler( state )
	removeEventHandler("onClientElementStreamIn", root, OnVehicleStreamedIn)

	if state then
		addEventHandler("onClientElementStreamIn", root, OnVehicleStreamedIn)
	end
end