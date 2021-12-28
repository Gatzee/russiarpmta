loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")
Extend("SVehicle")

function UpdateAdminVehiclesFlag(vehicles_list)
	if not client then return end
	if not client:IsAdminMode() then return end

	for i, vehicle in ipairs(vehicles_list) do
		vehicles_list[i] = {
			vehicle, --vehicle:GetFlags()
		}
	end

	-- triggerClientEvent(client, "UpdateAdminVehiclesFlag", resourceRoot, vehicles_list)
end
addEvent("UpdateAdminVehiclesFlag", true)
addEventHandler("UpdateAdminVehiclesFlag", resourceRoot, UpdateAdminVehiclesFlag)