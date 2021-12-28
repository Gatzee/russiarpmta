loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")

addEventHandler("onClientResourceStart", resourceRoot, function()
	CQuest(QUEST_DATA)
end)

IGNORE_GPS_ROUTE = true

local iMinigameStarted = 0
local fZonePosition = 0

function StartDropMinigame()
	removeEventHandler("onClientPreRender", root, PreRenderMinigame)
	if isElement(CEs.hint) then destroyElement(CEs.hint) end
	if isElement(CEs.bar_bg) then destroyElement(CEs.bar_bg) end

	iMinigameStarted = getTickCount()
	localPlayer.vehicle.velocity = Vector3( 0, 0, 0 )

	fZonePosition = math.random(0, 80)/100

	local scx, scy = guiGetScreenSize()

	CEs.hint = ibCreateImage( scx/2-330/2, scy/2-200, 330, 71, ":nrp_job_controller/img/pilot/hint_drop.png" )
	CEs.bar_bg = ibCreateImage( scx/2-125, scy/2-300, 250, 16, nil, false, 0x80212b36)
	CEs.bar_zone = ibCreateImage( 250*fZonePosition, 1, 50, 14, nil, CEs.bar_bg, 0xFF309430 )
	CEs.bar_line = ibCreateImage( 0, 1, 3, 14, nil, CEs.bar_bg, 0xFFFFFFFF )
	addEventHandler("onClientPreRender", root, PreRenderMinigame)
end

function PreRenderMinigame()
	local fProgress = ( getTickCount() - iMinigameStarted ) / 2000

	local px = interpolateBetween( 10, 0, 0, 245, 0, 0, fProgress%1, "SineCurve" )
	CEs.bar_line:ibData("px", px)

	-- dxDrawText( inspect( px >= 250*fZonePosition and px <= 250*fZonePosition+50 ), 400, 350 )

	if fProgress >= 4 or getKeyState("h") then
		local is_good = px >= 250*fZonePosition and px <= 250*fZonePosition+50
		DropCargo( is_good )
	end
end

function DropCargo( is_good )
	removeEventHandler("onClientPreRender", root, PreRenderMinigame)
	if isElement(CEs.hint) then destroyElement(CEs.hint) end
	if isElement(CEs.bar_bg) then destroyElement(CEs.bar_bg) end
	
	CEs.func_refresh_number_dropped_cargo()
	CreateDropPoint()

	if is_good then
		localPlayer:ShowSuccess("Твой доход увеличен")
	end

	triggerServerEvent( "onPilotMarkerPass", resourceRoot, nil, false, DISTANCE_MUL, is_good )
	triggerServerEvent( "PilotDaily_AddDelivery", localPlayer )

	if localPlayer.vehicle then localPlayer.vehicle:ping( ) end
end