function GetPlayerBoosters( pPlayer, sBooster )
	local pBoosters = pPlayer:getData("tmp_event_boosters") or {}
	return pBoosters[sBooster] or 0
end

function SetPlayerBoosters( pPlayer, sBooster, iAmount )
	local pBoosters = pPlayer:getData("tmp_event_boosters") or {}
	pBoosters[sBooster] = iAmount

	pPlayer:SetPrivateData("tmp_event_boosters", pBoosters)
	return true
end

function GivePlayerBoosters( pPlayer, sBooster, iAmount )
	local pBoosters = pPlayer:getData("tmp_event_boosters") or {}
	pBoosters[sBooster] = (pBoosters[sBooster] or 0) + iAmount

	pPlayer:SetPrivateData("tmp_event_boosters", pBoosters)
	return true
end

function TakePlayerBoosters( pPlayer, sBooster, iAmount )
	local iAmount = iAmount or 1
	if GetPlayerBoosters(pPlayer, sBooster) >= iAmount then
		local pBoosters = pPlayer:getData("tmp_event_boosters") or {}
		pBoosters[sBooster] = pBoosters[sBooster] - iAmount

		pPlayer:SetPrivateData("tmp_event_boosters", pBoosters)
		return true
	end
end

function OnPlayerBoosterUse( pPlayer, iBooster )
	if TakePlayerBoosters(pPlayer, BOOSTS_LIST[iBooster].id) then
		local pElementsAround = getElementsWithinRange( pPlayer.position, 75, "player" )
		for k,v in pairs(pElementsAround) do
			if v.dimension ~= pPlayer.dimension then
				pElementsAround[k] = nil
			end
		end
		triggerClientEvent( pElementsAround, "EVENTS:OnClientBoosterUsed", resourceRoot, pPlayer, iBooster )
	end
end
addEvent("EVENTS:OnPlayerBoosterUse", true)
addEventHandler("EVENTS:OnPlayerBoosterUse", resourceRoot, OnPlayerBoosterUse)