loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "ib" )

scx, scy = guiGetScreenSize()

LAST_RESPAWN = 0

TEAM_ID_BY_CLAN_ID = { }

function OnClientPlayerLobbyJoin()
	OnClientPlayerLobbyLeave()
	CreateLobbyZones( )
	addEventHandler("onClientPlayerDamage", localPlayer, PreparationDamageHandler)
	addEventHandler("onClientPlayerWasted", localPlayer, OnClientPlayerWasted_handler)
end
addEvent("CEV:OnClientPlayerLobbyJoin", true)
addEventHandler("CEV:OnClientPlayerLobbyJoin", resourceRoot, OnClientPlayerLobbyJoin)

function OnClientPlayerLobbyLeave()
	removeEventHandler("onClientPlayerDamage", localPlayer, PreparationDamageHandler)
	removeEventHandler("onClientPlayerWasted", localPlayer, OnClientPlayerWasted_handler)
	removeEventHandler("onClientPlayerDamage", localPlayer, OnClientPlayerDamage_handler)
	removeEventHandler("onClientPlayerSpawn", localPlayer, OnClientPlayerSpawn_handler)

	ShowUI_Wasted(false)

	DestroyGameZone()
	DestroyLobbyZones()
end
addEvent("CEV:OnClientPlayerLobbyLeave", true)
addEventHandler("CEV:OnClientPlayerLobbyLeave", root, OnClientPlayerLobbyLeave)

function OnClientGameStarted( data )
	removeEventHandler("onClientPlayerDamage", localPlayer, PreparationDamageHandler)
	addEventHandler("onClientPlayerDamage", localPlayer, OnClientPlayerDamage_handler)
	addEventHandler("onClientPlayerSpawn", localPlayer, OnClientPlayerSpawn_handler)

	DestroyLobbyZones()
	CreateGameZone()
	TEAM_ID_BY_CLAN_ID = data.teams
end
addEvent("CEV:OnClientGameStarted", true)
addEventHandler("CEV:OnClientGameStarted", resourceRoot, OnClientGameStarted)

function OnClientGameFinished( data )
	ShowUI_Wasted(false)

	DestroyGameZone()
end
addEvent("CEV:OnClientGameFinished", true)
addEventHandler("CEV:OnClientGameFinished", resourceRoot, OnClientGameFinished)

function PreparationDamageHandler()
	cancelEvent()
end

function OnClientPlayerSpawn_handler()
	LAST_RESPAWN = getTickCount()
end

function OnClientPlayerDamage_handler()
	if getTickCount() - LAST_RESPAWN <= 5000 then
		cancelEvent()
		return 
	end
end

function OnClientPlayerWasted_handler()
	ShowUI_Wasted( 15 )
end