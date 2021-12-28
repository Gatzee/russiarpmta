Extend( "CVehicle" )
Extend( "ShPlayer" )

local FALLING_OF_BIKE_MULTIPLIER = 5

function onPlayerDamage( attacker, damage_causing, _, loss )
	if not attacker or attacker.type ~= "vehicle" then return end

	if attacker.vehicleType == "Bike" then
		local occupants = getVehicleOccupants( attacker )

		for _, occupant in pairs( occupants ) do
			if occupant == localPlayer then
				cancelEvent( )

				local correctedLoss = loss * FALLING_OF_BIKE_MULTIPLIER * ( localPlayer:HasHelmet( ) and HELMET_DEF_COEFFICIENT or 1 )
				correctedLoss = correctedLoss < 0 and localPlayer.health or correctedLoss
				
				localPlayer.health = localPlayer.health - correctedLoss
				break
			end
		end

	elseif damage_causing == 50 then -- turn off damage from ranover/helicopter blades
		localPlayer.position = localPlayer.position -- micro freeze
		cancelEvent( )
	end
end
addEventHandler( "onClientPlayerDamage", localPlayer, onPlayerDamage )

function onVehicleDamage( pAttacker, iWeapon, fLoss, _, _, _, iTire )
	FixVisualDamages( source )

	if not next( source.occupants ) then
		cancelEvent( ) -- vehicle has not occupants
		return
	end

	if iWeapon or pAttacker or iTire or fLoss <= 50 then return end
	if source ~= localPlayer.vehicle or localPlayer:getData( "in_race" ) then return end

	triggerServerEvent( "onVehicleDamageByCollision", resourceRoot, source, fLoss )
end
addEventHandler( "onClientVehicleDamage", root, onVehicleDamage )

function FixVisualDamages( vehicle )
	for i = 0, 3 do
		setVehicleLightState( vehicle, i, 0 )
	end

	for i = 0, 6 do
		setVehiclePanelState( vehicle, i, 0 )
	end

	for i = 0, 5 do
		local ratio = getVehicleDoorOpenRatio( vehicle, i )
		local state = getVehicleDoorState( vehicle, i )
		if state > 0 then
			ratio = 0
		end
		setVehicleDoorState( vehicle, i, 0 )
		setVehicleDoorOpenRatio( vehicle, i, ratio )
	end
end