loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")
Extend("CUI")

addEventHandler( "onClientResourceStart", resourceRoot, function()
	CQuest( QUEST_DATA )
end )

--Если ресурс будет перезапущен во время заливки масла сбрасываем данные
function resetHcsSetting()
	localPlayer:setFrozen( false )
	localPlayer:setAnimation()
	GAME_STEP = nil
	CURRENT_GAME = nil
	if CURRENT_UI_ELEMENT then
		CURRENT_UI_ELEMENT:destroy()
		CURRENT_UI_ELEMENT = nil
	end
end
addEventHandler( "onClientResourceStop", resourceRoot, resetHcsSetting )

addEvent("onHcsCompany_2_EndShiftRequestReset", true)
addEventHandler( "onHcsCompany_2_EndShiftRequestReset", root, resetHcsSetting )