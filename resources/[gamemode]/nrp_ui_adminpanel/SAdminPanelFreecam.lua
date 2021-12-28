local freecam = {}

function setPlayerFreecamEnabled(player)
	triggerClientEvent(player,"doSetFreecamEnabled",player)
end

function setPlayerFreecamDisabled(player)
	triggerClientEvent(player,"doSetFreecamDisabled",player)
end

function setPlayerFreecamOption(player, theOption, value)
	return triggerClientEvent(player,"doSetFreecamOption",player,theOption,value)
end

function isPlayerFreecamEnabled(player)
	return freecam[player]
end