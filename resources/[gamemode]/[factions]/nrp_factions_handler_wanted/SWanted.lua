loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SPlayerOffline" )
Extend( "SDB" )

WANTED_RESET_DELAY = 5 * 60 * 60  -- 5 часов
WANTED_UPDATE_TIME = 2 * 60


-- Принудительный сбор и высылки в клиент информации о розысках всех игроков
-- Можно периодически вызывать во время патрулей
function OnPlayerCollectAllWantedData( pPlayer )
	local pPlayer = pPlayer or client
	local pToSend = {}
	for i, player in pairs(getElementsByType("player")) do
		if player:IsInGame() then
			local pWantedData = player:GetWantedData()
			if pWantedData and #pWantedData >= 1 then
				pToSend[player] = pWantedData
			end
		end
	end

	triggerClientEvent( pPlayer, "OnPlayerReceiveAllWantedData", pPlayer, pToSend )
end
addEvent("OnPlayerCollectAllWantedData", true)
addEventHandler("OnPlayerCollectAllWantedData", root, OnPlayerCollectAllWantedData)

-- Высылка актуальных розысков конкретного игрока
function OnPlayerRequestWantedData( pTarget )
	if isElement(pTarget) and pTarget:IsInGame() then
		local pWantedData = pTarget:GetWantedData( true )
		triggerClientEvent( client, "OnPlayerReceiveWantedData", pTarget, pWantedData )
	end
end
addEvent("OnPlayerRequestWantedData", true)
addEventHandler("OnPlayerRequestWantedData", root, OnPlayerRequestWantedData)

function OnClientPlayerAddWanted_handler( ... )
	client:AddWanted( ... )
end
addEvent("OnClientPlayerAddWanted", true)
addEventHandler("OnClientPlayerAddWanted", root, OnClientPlayerAddWanted_handler)

function UpdateWantedLists()
	for i, player in pairs( GetPlayersInGame( ) ) do
		local pWantedData = player:GetWantedData( true )

		if pWantedData and #pWantedData > 0 then
			local pRemove = { }

			for k,v in pairs( pWantedData ) do
				v[ 2 ] = v[ 2 ] + WANTED_UPDATE_TIME

				if v[ 2 ] >= WANTED_RESET_DELAY then
					pRemove[ v[ 1 ] ] = ( pRemove[ v[ 1 ] ] or 0 ) + 1
				end
			end

			player:SetWantedData( pWantedData )

			if next( pRemove ) then
				for k,v in pairs( pRemove ) do
					player:RemoveWanted( k, v )
					outputChatBox( "Розыск по статье #22dd22"..k.."#ffffff истёк", player, 255, 255, 255, true )
				end
			end
		end
	end
end
setTimer( UpdateWantedLists, WANTED_UPDATE_TIME * 1000, 0 )