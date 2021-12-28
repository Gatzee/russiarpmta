loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("SQuest")

addEventHandler("onResourceStart", resourceRoot, function()
	SQuest(QUEST_DATA)
end)


function OnPlayerFailedQuest_handler()
	local current_quest = source:getData( "current_quest" )
	if current_quest and current_quest.id == QUEST_DATA.id then
		source:TakeWeapon( 41 )
	end
end
addEventHandler( "OnPlayerFailedQuest", root, OnPlayerFailedQuest_handler )