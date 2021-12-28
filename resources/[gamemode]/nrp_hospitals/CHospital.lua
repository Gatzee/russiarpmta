loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "ShUtils" )
Extend( "CPlayer" )

local HEALING_PLAYERS_LIST = {}
local pHealingTimer
local bIsInBed = false

function OnClientPlayerUseHospitalBed( pPlayer, state, data )
	if state then
		HEALING_PLAYERS_LIST[pPlayer] = true

		pPlayer:setAnimation( "CRACK", "crckdeth2",  - 1, true, true, false, false )
		if pPlayer == localPlayer then
			bIsInBed = true
			pHealingTimer = setTimer( HealingTick, 3000, 0 )
		end
	else
		HEALING_PLAYERS_LIST[pPlayer] = nil
		pPlayer:setAnimation( nil )

		if pPlayer == localPlayer then
			bIsInBed = false
			if isTimer(pHealingTimer) then killTimer(pHealingTimer) end
		end
	end
end
addEvent("OnClientPlayerUseHospitalBed", true)
addEventHandler("OnClientPlayerUseHospitalBed", root, OnClientPlayerUseHospitalBed)

function OnClientPlayerHospitalLeave( )
	for k,v in pairs(HEALING_PLAYERS_LIST) do
		OnClientPlayerUseHospitalBed( k, false )
	end

	HEALING_PLAYERS_LIST = {}
end
addEvent("OnClientPlayerHospitalLeave", true)
addEventHandler("OnClientPlayerHospitalLeave", root, OnClientPlayerHospitalLeave)

function OnClientPlayerHospitalEnter( data )
	for k,v in pairs(data) do
		OnClientPlayerUseHospitalBed( v.owner, true, v )
	end
end
addEvent("OnClientPlayerHospitalEnter", true)
addEventHandler("OnClientPlayerHospitalEnter", root, OnClientPlayerHospitalEnter)

function HealingTick()
	if bIsInBed then
		if isPedOnFire( localPlayer ) then
			setPedOnFire( localPlayer, false )
		end

		if localPlayer.health < 60 then
			local hp = 60 / ( 2 * 60 * 1000 ) * 3000
			localPlayer:SetHP( math.min( localPlayer.health + hp, 60 ) )
		end

		if localPlayer.health >= 60 then
			localPlayer:ShowInfo("Ты уже здоров!")
			triggerServerEvent("OnPlayerHospitalBedLeave", localPlayer)
		end
	else
		killTimer(pHealingTimer)
	end
end