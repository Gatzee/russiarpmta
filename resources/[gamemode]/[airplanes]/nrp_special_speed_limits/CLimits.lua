local LIMITS_LIST = 
{
	[476] = { 180 },
	[469] = { 190, 50 },
}

local iLastTick = 0

function OnClientVehicleEnter( pVehicle, seat )
	if seat == 0 then
		if LIMITS_LIST[pVehicle.model] then
			iLastTick = getTickCount()
			addEventHandler("onClientPreRender", root, PreRenderVelocityHandler)
		end
	end
end
addEventHandler("onClientPlayerVehicleEnter", localPlayer, OnClientVehicleEnter)

function PreRenderVelocityHandler()
	local pVehicle = localPlayer.vehicle

	if not isElement(pVehicle) then
		removeEventHandler("onClientPreRender", root, PreRenderVelocityHandler)
		return false
	end

	local conf = LIMITS_LIST[ pVehicle.model ]

	local vecVelocity = pVehicle.velocity
	local kmh = vecVelocity.length * 180

	local fProgress = (getTickCount() - iLastTick) / 1000

	if conf[2] and getControlState("accelerate") then
		if kmh >= conf[2] then
			vecVelocity:normalize()
			vecVelocity.z = 0
			pVehicle.velocity = pVehicle.velocity + vecVelocity * fProgress * 0.1
		end
	end

	local fMul = kmh/conf[1] - 1

	if fMul > 0 then
		pVehicle.velocity = pVehicle.velocity - pVehicle.velocity * fMul
	end

	iLastTick = getTickCount()
end