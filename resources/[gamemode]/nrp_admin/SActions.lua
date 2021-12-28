function OnPlayerActionApply( action, pTarget, ... )
	if not isElement( pTarget ) then return end
	ADMIN_ACTIONS_LIST[action]:fOnTriggered( pTarget, ... )
end
addEvent("AP:OnPlayerActionApply", true)
addEventHandler("AP:OnPlayerActionApply", root, OnPlayerActionApply)

function OnPlayerSwitchClansChat()
	client:SetPrivateData("band_chat_enabled", not client:getData("band_chat_enabled"))
end
addEvent("AP:OnPlayerSwitchClansChat", true)
addEventHandler("AP:OnPlayerSwitchClansChat", root, OnPlayerSwitchClansChat)