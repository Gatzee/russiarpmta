Extend( "ShUtils" )
Extend( "SPlayer" )
Extend( "SInterior" )

FISHING_PLAYERS = {}
FISHING_ZONES = {}

function OnPlayerHitFishingMarker( pPlayer )
	local pPlayer = pPlayer or client
	if FISHING_PLAYERS[pPlayer] then
		OnPlayerEndFishing( pPlayer )
	else
		local pEquipment = pPlayer:GetHobbyEquipment( )

		local pEquippedTool, pFoundBait
		for k,v in pairs( pEquipment ) do
			if v.class == "fishing:rod" and v.equipped then
				pEquippedTool = v
			elseif v.class == "fishing:bait" and v.amount >= 1 then
				pFoundBait = v
			end

			if pEquippedTool and pFoundBait then break end
		end

		if pPlayer:IsOnFactionDuty( ) then
			return false, "Ты на смене во фракции!"
		end

		if pPlayer:GetOnShift( ) then
			return false, "Закончи смену на работе!"
		end

		if pPlayer:IsOnUrgentMilitary( ) and not pPlayer:IsUrgentMilitaryVacation( ) then
			return false, "Ты на срочной службе!"
		end

		if pPlayer:getData( "current_quest" ) then
			return false, "Закончи текущую задачу!"
		end

		if not pEquippedTool then
			pPlayer:ShowError( "Ты забыл взять удочку" )
			return false
		end

		if not pFoundBait then
			pPlayer:ShowError( "Для ловли рыбы нужна наживка" )
			return false
		end

		local iLevel = pPlayer:GetLevel( )
		if iLevel < 4 then
			pPlayer:ShowError( "Это хобби доступно с 4 уровня" )
			return false
		end

		if isPedDead( pPlayer ) then
			return false
		end

		OnPlayerStartFishing( pPlayer, pEquippedTool, pZone )
	end
end
addEvent("OnPlayerHitFishingMarker", true)
addEventHandler("OnPlayerHitFishingMarker", root, OnPlayerHitFishingMarker)

function OnPlayerStartFishing( pPlayer, pTool )
	local pToolData = HOBBY_EQUIPMENT[HOBBY_FISHING][1].items[pTool.id]
	local pFishingRod = createObject( pToolData.model, pPlayer.position )
	setObjectScale( pFishingRod, 0.8 )
	setElementCollisionsEnabled( pFishingRod, false )

	addEventHandler("onPlayerVehicleEnter", pPlayer, OnPlayerVehicleEnter_handler)
	addEventHandler("onPlayerWasted", pPlayer, OnPlayerWasted_handler)

	FISHING_PLAYERS[pPlayer] = 
	{
		rod_element = pFishingRod,
		tool = pTool,
		tool_data = pToolData,
		item_uid = math.random( 999999 ),
	}
	exports.bone_attach:attachElementToBone(pFishingRod, pPlayer, 12, -0.1, 0.05, 0.08, 0, 180, 160)

	setElementData( pPlayer, "is_fishing", true, false )

	triggerClientEvent( pPlayer, "OnPlayerStartFishing", resourceRoot, FISHING_PLAYERS[pPlayer] )
end

function OnPlayerCatchedFish( item_uid )
	local pPlayer = client

	if item_uid and FISHING_PLAYERS[pPlayer] and FISHING_PLAYERS[pPlayer].item_uid == item_uid then
		FISHING_PLAYERS[pPlayer].item_uid = math.random( 999999 )
		triggerClientEvent( pPlayer, "OnPlayerUpdateFishing", resourceRoot, FISHING_PLAYERS[pPlayer].item_uid )
		triggerEvent("OnPlayerTryObtainHobbyItem", pPlayer, HOBBY_FISHING)
	end
end
addEvent("OnPlayerCatchedFish", true)
addEventHandler("OnPlayerCatchedFish", resourceRoot, OnPlayerCatchedFish)

function OnPlayerEndFishing( pPlayer )
	local pPlayer = pPlayer or client
	if FISHING_PLAYERS[pPlayer] then
		
		if isElement( FISHING_PLAYERS[pPlayer].rod_element ) then
			destroyElement( FISHING_PLAYERS[pPlayer].rod_element )
		end

		FISHING_PLAYERS[pPlayer] = nil
		setElementData( pPlayer, "is_fishing", false, false )
		removeEventHandler("onPlayerVehicleEnter", pPlayer, OnPlayerVehicleEnter_handler)
		removeEventHandler("onPlayerWasted", pPlayer, OnPlayerWasted_handler)

		triggerClientEvent( pPlayer, "OnPlayerStopFishing", resourceRoot )
	end
end
addEvent("OnPlayerEndFishing", true)
addEventHandler("OnPlayerEndFishing", root, OnPlayerEndFishing)

function OnPlayerVehicleEnter_handler()
	OnPlayerEndFishing( source )
end

function OnPlayerWasted_handler()
	OnPlayerEndFishing( source )
end

function OnPlayerQuit()
	if FISHING_PLAYERS[source] then
		OnPlayerEndFishing( source )
	end
end
addEvent("onPlayerPreLogout", true)
addEventHandler("onPlayerPreLogout", root, OnPlayerQuit, true, "high+99999999999")