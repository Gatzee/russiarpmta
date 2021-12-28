function onClientVehicleDamage_handler( attacker )
	if not attacker or attacker.type ~= "player" or attacker == localPlayer then return end

	if source ~= localPlayer.vehicle then
		removeEventHandler( "onClientVehicleDamage", source, onClientVehicleDamage_handler )
		return
	end

	triggerServerEvent( "onPlayerFixatePreWanted", attacker, attacker, true )
end

addEventHandler( "onClientPlayerVehicleEnter", localPlayer, function( vehicle )
	if FACTION_RIGHTS.WANTED_KNOW[ localPlayer:GetFaction( ) ] and localPlayer:IsOnFactionDuty( ) then
		addEventHandler( "onClientVehicleDamage", vehicle, onClientVehicleDamage_handler )
	end
end )

addEventHandler( "onClientPlayerVehicleExit", localPlayer, function( vehicle )
	if isElement( vehicle ) then
		removeEventHandler( "onClientVehicleDamage", vehicle, onClientVehicleDamage_handler )
	end
end )

addEventHandler( "onClientPlayerWeaponFire", localPlayer, function( weapon, _, _, _, _, _, hitElement )
	if not hitElement or not isElement( hitElement ) or hitElement.type ~= "vehicle" then return end

	local controller = hitElement.controller
	if not controller then return end

	if not ( weapon and weapon >= 22 and weapon <= 34 ) then return end

	if FACTION_RIGHTS.WANTED_KNOW[ localPlayer:GetFaction( ) ] and localPlayer:IsOnFactionDuty( ) then
		triggerServerEvent( "onPlayerFixatePreWanted", controller, controller, true )
	end
end )