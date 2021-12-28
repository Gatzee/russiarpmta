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
	localPlayer:setFrozen( false )
end )

--[[
	--Для генерации новых точек
	addEventHandler("onClientResourceStart", resourceRoot, function()
	for i = 0, 19 do
		local vec = Vector3( -2602.4904, 2829.2819, 14.1313 ) + Vector3( i * 2.02, i * -0.275, 0 )
		--CreateQuestPoint( vec, "task_jail_2_end_step_1", _, 1, 0, 0, false, _, _, "cylinder", 0, 255, 0, 20 )
		--outputChatBox( "Vector3( " .. vec.x .. ", " .. vec.y .. ", " .. vec.z .. " )," )
	end
	iprint(localPlayer:getRotation())
	--triggerServerEvent( "PlayeStartQuest_task_jail_2", localPlayer )
end)]]
