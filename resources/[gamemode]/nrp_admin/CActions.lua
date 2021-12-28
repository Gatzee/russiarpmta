addEventHandler("onClientPlayerDamage", localPlayer, function()
	if localPlayer:IsImmortal() then
		cancelEvent()
	end
end)

addEventHandler("onClientPedDamage", root, function()
	if source:getData("bImmortal") then
		cancelEvent()
	end
end)

bPlayerBlipsEnabled = false
local pUpdateBlipsTimer = nil
local pPlayerBlips = {}

function SwitchPlayerBlips()
	bPlayerBlipsEnabled = not bPlayerBlipsEnabled
	if bPlayerBlipsEnabled then
		UpdatePlayerBlips()
		pUpdateBlipsTimer = setTimer(UpdatePlayerBlips, 10000, 0)
	else
		if isTimer(pUpdateBlipsTimer) then killTimer(pUpdateBlipsTimer) end
		for k,v in pairs(pPlayerBlips) do
			destroyElement( v )
		end
		pPlayerBlips = {}
	end
end

function UpdatePlayerBlips()
	for k,v in pairs(getElementsByType("player")) do
		if not isElement(pPlayerBlips[v]) then
			pPlayerBlips[v] = createBlipAttachedTo( v, 0, 1, 50, 200, 50 )
		end
	end

	for k,v in pairs(pPlayerBlips) do
		if not isElement(k) and isElement(v) then 
			destroyElement( v ) 
		end
	end
end