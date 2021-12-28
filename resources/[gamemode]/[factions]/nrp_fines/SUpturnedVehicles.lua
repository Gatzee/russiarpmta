local UPTURNED_VEHICLES = {}

function CheckVehicles()
	for k,v in pairs( getElementsByType("vehicle") ) do
		local veh_id = v:GetID()
		if type( veh_id ) ~= "string" and veh_id > 0 and not v:GetParked() then
			local rx, ry, rz = getElementRotation(v)
			if (ry >= 150 and ry <= 250) or (rx >= 150 and rx <= 250)  then
				if UPTURNED_VEHICLES[v] then
					UPTURNED_VEHICLES[v] = UPTURNED_VEHICLES[v] + 30

					if UPTURNED_VEHICLES[v] >= 120 then
						UPTURNED_VEHICLES[v] = nil

						setElementRotation( v, 0, 0, rz )

						local pOwner = GetPlayer( v:GetOwnerID() )
						if isElement(pOwner) then
							pOwner:AddFine( 3 )
						end
					end
				else
					UPTURNED_VEHICLES[v] = 0
				end
			else
				if UPTURNED_VEHICLES[v] then
					UPTURNED_VEHICLES[v] = nil
				end
			end
		end
	end
end
setTimer(CheckVehicles, 30000, 0)