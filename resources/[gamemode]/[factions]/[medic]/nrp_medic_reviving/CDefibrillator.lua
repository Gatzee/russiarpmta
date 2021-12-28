loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "ShUtils" )

local scx, scy = guiGetScreenSize(  )
local sizeX, sizeY = 190, 190
local posX, posY = (scx-sizeX)/2, (scy-sizeY)/2

local iHealTime = 5000
local iProcessStarted = 0
local pHealer, pPatient = nil, nil

local pBoundKeys = {}
for k,v in pairs(getBoundKeys("fire")) do
	pBoundKeys[k] = true
end

function OnPlayerWeaponSwitch_handler( prev_slot, current_slot )
	if current_slot == 10 and getPedWeapon( localPlayer ) == 10 then
		toggleControl("fire", false)
	end

	if prev_slot == 10 and getPedWeapon( localPlayer, 10) == 10 then
		toggleControl("fire", true)
	end
end
addEventHandler("onClientPlayerWeaponSwitch", root, OnPlayerWeaponSwitch_handler)

function OnPlayerStartReviving( pTarget )
	if not isElement(pTarget) then return end
	destroyColshapeReviving( pTarget )

	if localPlayer == source then
		pPatient = pTarget
		iProcessStarted = getTickCount()
		addEventHandler("onClientRender", root, DrawProcess)
	elseif localPlayer == pTarget then
		pHealer = source
		iProcessStarted = getTickCount()
		addEventHandler("onClientRender", root, DrawProcess)
		setCameraTarget( localPlayer )
	end

	setPedAnimation( source, "MEDIC", "CPR", iHealTime, false, true, false, false )

	setTimer(function( pPlayer )
		if isElement(pPlayer) then
			setPedAnimation( pPlayer, nil )
		end
	end, iHealTime, 1, source)
end
addEvent("OnPlayerStartReviving", true)
addEventHandler("OnPlayerStartReviving", root, OnPlayerStartReviving) 

function DrawProcess()
	local fProgress = (getTickCount() - iProcessStarted) / iHealTime

	if fProgress <= 1 then
		dxDrawImage( posX-30*fProgress, posY-30*fProgress, sizeX+60*fProgress, sizeY+60*fProgress, "files/img/defibrillator.png", 20*fProgress)

		dxDrawRectangle( posX-20, posY+sizeX+30, sizeX+40, 25, tocolor(0,0,0,200) )
		dxDrawRectangle( posX-20, posY+sizeX+30, (sizeX+40)*fProgress, 25, tocolor(200-150*fProgress,50+150*fProgress,0,200) )

		dxDrawText("Реанимация...", posX-20, posY+sizeX+30, posX+sizeX+40, posY+sizeX+55, tocolor(255,255,255), 1, "default-bold", "center", "center" )

		if pHealer and (not isElement(pHealer) or isPedDead(pHealer)) then
			localPlayer:ShowError("Реанимация не удалась")
			pHealer = nil
			pPatient = nil
			removeEventHandler("onClientRender", root, DrawProcess)
			triggerEvent( "ShowDeathCountdown", localPlayer, 20 )
		end

		if pPatient and (not isElement(pPatient) or isPedDead(localPlayer)) then
			localPlayer:ShowError("Реанимация не удалась")
			pHealer = nil
			pPatient = nil
			removeEventHandler("onClientRender", root, DrawProcess)
		end
	else
		if pPatient and isElement(pPatient) then
			triggerServerEvent( "OnPlayerFinishedReviving", localPlayer, pPatient )
		end

		pHealer = nil
		pPatient = nil
		removeEventHandler("onClientRender", root, DrawProcess)
	end
end