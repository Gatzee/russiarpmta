loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")
Extend("CUI")

addEventHandler( "onClientResourceStart", resourceRoot, function()
	CQuest( QUEST_DATA )
end )

--Если ресурс будет перезапущен во время заливки масла сбрасываем данные
function resetHcsSetting()
	GAME_STEP = nil
	CURRENT_GAME = nil
	if CURRENT_UI_ELEMENT then
		CURRENT_UI_ELEMENT:destroy()
		CURRENT_UI_ELEMENT = nil
	end
	if CURRENT_UI_DESK then
		CURRENT_UI_DESK:destroy()
		CURRENT_UI_DESK = nil
	end
end
addEventHandler( "onClientResourceStop", resourceRoot, resetHcsSetting )

addEvent("onHcsCompany_3_EndShiftRequestReset", true)
addEventHandler( "onHcsCompany_3_EndShiftRequestReset", root, resetHcsSetting )