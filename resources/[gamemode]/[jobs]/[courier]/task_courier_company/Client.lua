loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")

addEventHandler("onClientResourceStart", resourceRoot, function()
	CQuest(QUEST_DATA)
end)

IGNORE_GPS_ROUTE = true