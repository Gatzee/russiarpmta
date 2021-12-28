loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("SClans")
Extend("SQuest")

addEventHandler("onResourceStart", resourceRoot, function()
	SQuest(QUEST_DATA)
end)