loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CVehicle")
Extend("CQuest")

addEventHandler("onClientResourceStart", resourceRoot, function()
	CQuest(QUEST_DATA)
end)