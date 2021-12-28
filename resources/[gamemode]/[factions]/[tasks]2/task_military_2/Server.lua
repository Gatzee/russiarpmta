loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SVehicle")
Extend("SQuest")

addEventHandler("onResourceStart", resourceRoot, function()
	SQuest(QUEST_DATA)
end)

addEvent ( "Task_Militaty_2_Remove_Vehicle", true )
addEventHandler ( "Task_Militaty_2_Remove_Vehicle", root,
	function()
		if source.vehicle then
			removePedFromVehicle( source )
		end
	end
)