loadstring( exports.interfacer:extend("Interfacer") )()
Extend( "CUI" )
Extend( "CQuest" )

addEventHandler("onClientResourceStart", resourceRoot, function()
	CQuest(QUEST_DATA)
end)