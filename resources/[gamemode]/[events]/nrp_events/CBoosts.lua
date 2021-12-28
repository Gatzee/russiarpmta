local BOOSTER_COOLDOWNS = {}
local EFFECT_TIMERS = {}
local GLOBAL_COOLDOWN = 0

function GetBoosterData( sBooster )
	for k,v in pairs(BOOSTS_LIST) do
		if v.id == sBooster then
			return v
		end
	end
end

function GetPlayerBoosters( sBooster )
	local pBoosters = localPlayer:getData("tmp_event_boosters") or {}
	return pBoosters[sBooster] or 0
end

function OnClientBoosterUsed( pPlayer, iBooster )
	if pPlayer == localPlayer then
		triggerEvent( "UdpateBoosterIcons", resourceRoot )
	end

	BOOSTS_LIST[iBooster].cl_effect( pPlayer )
end
addEvent("EVENTS:OnClientBoosterUsed", true)
addEventHandler("EVENTS:OnClientBoosterUsed", resourceRoot, OnClientBoosterUsed)

function ApplyBooster( iBooster )
	local iCooldown = BOOSTER_COOLDOWNS[iBooster]
	if iCooldown and getTickCount() - iCooldown < 0 then
		localPlayer:ShowError("Усиление ещё не готово")
		return false
	end

	if getTickCount() - GLOBAL_COOLDOWN < 0 then
		localPlayer:ShowError("Нельзя использовать эти усиления одновременно!")
		return false
	end

	triggerServerEvent( "EVENTS:OnPlayerBoosterUse", resourceRoot, localPlayer, iBooster )
end

function SetBoosterCooldown( iBooster, iTime, iGlobalTime )
	BOOSTER_COOLDOWNS[iBooster] = getTickCount() + iTime*1000

	triggerEvent( "ShowBoosterCooldown", resourceRoot, iBooster, iTime*1000 )

	if iGlobalTime then
		GLOBAL_COOLDOWN = getTickCount() + iGlobalTime*1000
	end
end

function RemoveEffects( pVehicle, iTime )
	if isTimer(EFFECT_TIMERS[pVehicle]) then
		killTimer(EFFECT_TIMERS[pVehicle])
		triggerEvent( "RC:RemoveAllEffects", localPlayer, pVehicle )
	end
	
	if not iTime or iTime < 50 then iTime = 50 end

	EFFECT_TIMERS[pVehicle] = setTimer(function( vehicle )
		triggerEvent( "RC:RemoveAllEffects", localPlayer, pVehicle )
	end, iTime, 1, pVehicle)
end