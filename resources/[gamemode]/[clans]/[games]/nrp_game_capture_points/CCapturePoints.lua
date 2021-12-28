loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "CUI" )
Extend( "ib" )

scx, scy = guiGetScreenSize()

function OnClientPlayerLobbyJoin()
	addEventHandler("onClientPlayerDamage", localPlayer, PreparationDamageHandler)
end
addEvent("CEV:OnClientPlayerLobbyJoin", true)
addEventHandler("CEV:OnClientPlayerLobbyJoin", resourceRoot, OnClientPlayerLobbyJoin)

function OnClientPlayerLobbyLeave()
	removeEventHandler("onClientPlayerDamage", localPlayer, PreparationDamageHandler)
	removeEventHandler("onClientPlayerWasted", localPlayer, OnClientPlayerWasted_handler)
	ShowUI_Main(false)
	ShowUI_Wasted(false)
	ToggleClientVehiclesHandler( false )
end
addEvent("CEV:OnClientPlayerLobbyLeave", true)
addEventHandler("CEV:OnClientPlayerLobbyLeave", resourceRoot, OnClientPlayerLobbyLeave)

function OnClientGameStarted( data )
	removeEventHandler("onClientPlayerDamage", localPlayer, PreparationDamageHandler)
	addEventHandler("onClientPlayerWasted", localPlayer, OnClientPlayerWasted_handler)
	ToggleClientVehiclesHandler( true )

	ShowUI_Main( true, data )
end
addEvent("CEV:OnClientGameStarted", true)
addEventHandler("CEV:OnClientGameStarted", resourceRoot, OnClientGameStarted)

function OnClientGameFinished( data )
	ShowUI_Wasted(false)
end
addEvent("CEV:OnClientGameFinished", true)
addEventHandler("CEV:OnClientGameFinished", resourceRoot, OnClientGameFinished)

function PreparationDamageHandler()
	cancelEvent()
end

function OnClientPlayerWasted_handler()
	ShowUI_Wasted( 30 )
end