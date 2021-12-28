loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShTimelib" )
Extend( "SDB" )

local pCurrentlyCuffedPlayers = { }
local preCuffedPlayers = { }

function OnPlayerTryPutHandcuffs( pTarget, bState )
	if not isElement( pTarget ) then return end

	if pTarget.dimension ~= source.dimension or pTarget.interior ~= source.interior then
		return
	end

	if not isElement( pCurrentlyCuffedPlayers[ source ] ) then
		pCurrentlyCuffedPlayers[ source ] = nil
	end

	if bState then
		if preCuffedPlayers[ pTarget ] or pCurrentlyCuffedPlayers[ pTarget ] then
			source:ShowError( "Нельзя надеть наручники на данного игрока" )
			return
		end

		if pCurrentlyCuffedPlayers[ source ] then
			source:ShowError( "У тебя всего одни наручники" )
			return
		end
	else
		if not pCurrentlyCuffedPlayers[ source ] or pCurrentlyCuffedPlayers[ source ] ~= pTarget then
			source:ShowError( "Нельзя снять наручники с данного игрока" )
			return
		end
	end

	preCuffedPlayers[ source ] = true
	setElementData( pTarget, "is_handcuffed", source )
	
	triggerClientEvent( getElementsWithinRange( source.position, 100, "player" ) , "OnPlayerTryPutHandcuffs", source, pTarget, bState )
end
addEvent( "OnPlayerTryPutHandcuffs", true )
addEventHandler( "OnPlayerTryPutHandcuffs", root, OnPlayerTryPutHandcuffs )

function OnPlayerSucessfullyHandcuffed( pTarget, bState )
	preCuffedPlayers[ source ] = nil

	if not isElement( pTarget ) then return end

	if pCurrentlyCuffedPlayers[ pTarget ] then
		ForceBreakHandcuffs( pTarget, pCurrentlyCuffedPlayers[ pTarget ] )
	end

	if bState then
		triggerEvent( "onPlayerGotHandcuffed", pTarget, source )

		local current_quest = pTarget:getData( "current_quest" )
		if current_quest and current_quest.is_company_quest then
			triggerEvent( "PlayerFailStopQuest", pTarget, { type = "quest_fail", fail_text = "Ты попал в КПЗ!" } )
		end

		pCurrentlyCuffedPlayers[ source ] = pTarget

		-- Отсоединяем от машины
		if isElementAttached( pTarget ) then
			detachElements( pTarget )
			return
		end
	elseif not bState then
		removeElementData( pTarget, "is_handcuffed" )
		pCurrentlyCuffedPlayers[ source ] = nil
	end
end
addEvent( "OnPlayerSucessfullyHandcuffed", true )
addEventHandler( "OnPlayerSucessfullyHandcuffed", root, OnPlayerSucessfullyHandcuffed )

function FollowTheLeaderVehicle( pVehicle, bState )
	if bState then
		local iSeat = pVehicle:GetFreeSeat()
		warpPedIntoVehicle( client, pVehicle, iSeat )
	else
		removePedFromVehicle( client )
		client.position = pVehicle.position
	end
end
addEvent( "FollowTheLeaderVehicle", true )
addEventHandler( "FollowTheLeaderVehicle", root, FollowTheLeaderVehicle )

function FollowTheLeaderInterior( pLeader )
	client.interior = pLeader.interior
	client.dimension = pLeader.dimension
	client.position = Vector3( pLeader.position.x + 0.5, pLeader.position.y + 0.5, pLeader.position.z )
end
addEvent("FollowTheLeaderInterior", true)
addEventHandler("FollowTheLeaderInterior", root, FollowTheLeaderInterior)

function ForceBreakHandcuffs( pSource, pTarget )
	pCurrentlyCuffedPlayers[ pSource ] = nil

	if isElement( pSource ) then
		triggerClientEvent( pSource, "ForceBreakHandcuffs", pSource )
	end

	if isElement( pTarget ) then
		removeElementData( pTarget, "is_handcuffed" )
		triggerClientEvent( pTarget, "ForceBreakHandcuffs", pTarget )
	end
end

addEvent( "OnPlayerJailed", true )
addEventHandler( "OnPlayerJailed", root, function( )
	if pCurrentlyCuffedPlayers[ source ] then
		ForceBreakHandcuffs( source, pCurrentlyCuffedPlayers[ source ] )
	end

	if source:getData("is_handcuffed") then
		ForceBreakHandcuffs( source:getData("is_handcuffed"), source )
	end
end)

addEvent( "OnPlayerJailedByFsin", true )
addEventHandler( "OnPlayerJailedByFsin", root, function( )
	if pCurrentlyCuffedPlayers[ source ] then
		ForceBreakHandcuffs( source, pCurrentlyCuffedPlayers[ source ] )
	end
	
	if source:getData("is_handcuffed") then
		ForceBreakHandcuffs( source:getData("is_handcuffed"), source )
	end
end)

addEvent("OnPlayerReleasedFromJail", true)
addEventHandler("OnPlayerReleasedFromJail", root, function( )
	if source:getData( "is_handcuffed" ) then
		ForceBreakHandcuffs( source:getData( "is_handcuffed" ), source )
	end
end)

addEventHandler("onPlayerWasted", root, function( )
	-- Умер мент
	if pCurrentlyCuffedPlayers[ source ] then
		ForceBreakHandcuffs( source, pCurrentlyCuffedPlayers[ source ] )
	end

	-- Умер заключенный
	if source:getData("is_handcuffed") then
		ForceBreakHandcuffs( source:getData("is_handcuffed"), source )
	end
end)

addEvent( "onPlayerFactionChange", false )
addEventHandler( "onPlayerFactionChange", root, function ( )
	ForceBreakHandcuffs( source, pCurrentlyCuffedPlayers[ source ] )
end )

addEvent( "onPlayerFactionEndDuty", true )
addEventHandler( "onPlayerFactionEndDuty", root, function( )
	-- Закончил смену мент
	if pCurrentlyCuffedPlayers[ source ] then
		ForceBreakHandcuffs( source, pCurrentlyCuffedPlayers[ source ] )
	end
end )

function OnPlayerQuit()
	preCuffedPlayers[ source ] = nil

	-- Вышел мент
	if pCurrentlyCuffedPlayers[ source ] then
		ForceBreakHandcuffs( source, pCurrentlyCuffedPlayers[source] )
	end

	-- Вышел в наручниках
	if source:getData( "is_handcuffed" ) then
		ForceBreakHandcuffs( source:getData( "is_handcuffed" ), source )

		-- Вышел будучу не заключенным
		if not source:getData( "jailed" ) then
			local iTime = #source:GetWantedData() <= 0 and 900 or nil
			source:Jail( source:getData( "is_handcuffed" ), _, iTime, "Выход при задержании" )
		end
	end
end
addEvent("onPlayerPreLogout", true)
addEventHandler("onPlayerPreLogout", root, OnPlayerQuit)

function ResetReleasePlayersCount( )
	DB:exec( "UPDATE nrp_players SET release_players=0" )
end

ExecAtTime( "00:00", function( )
	ResetReleasePlayersCount( )
	RELEASE_COUNT_TIMER = setTimer( ResetReleasePlayersCount, 24 * 60 * 60 * 1000, 0 )
end )