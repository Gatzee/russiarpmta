loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")

addEventHandler("onClientResourceStart", resourceRoot, function()
	CQuest(QUEST_DATA)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
	local quest_data = localPlayer:getData("current_quest")
	local data = localPlayer:getData("jailed")
	if data == "is_prison" and quest_data and quest_data.id == QUEST_DATA.id then
		triggerEvent( "onClientCreateJobMarkers", localPlayer )
	end
end )

