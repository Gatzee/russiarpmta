function GetWeaponsTable( pPlayer )
	local pWeapons = {}

	for slot = 0, 12 do
		local iWeaponID = getPedWeapon( pPlayer, slot )
		local iAmmo = getPedTotalAmmo( pPlayer, slot )

		pWeapons[slot] = { iWeaponID, iAmmo }
	end

	return pWeapons
end

function GiveWeaponsFromTable( pPlayer, pWeapons )
	for k,v in pairs( pWeapons ) do
		if v[1] and v[2] > 0 then
			pPlayer:GiveWeapon( v[1], v[2], false )
		end
	end
end