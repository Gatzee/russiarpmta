loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CPlayer")

addEvent( "onClientResourceStart", true )
addEventHandler( "onClientResourceStart", resourceRoot, function()
	Timer( ProceeCheckSubscription, 2500, 0 )
end )

local premium_state = false

function ProceeCheckSubscription()
	if not localPlayer:IsInGame() then return end

	local current_premium_state = localPlayer:IsPremiumActive()

	if premium_state and not current_premium_state then
		triggerServerEvent( "onSubscriptionExpired", resourceRoot )
	end

	premium_state = current_premium_state
end