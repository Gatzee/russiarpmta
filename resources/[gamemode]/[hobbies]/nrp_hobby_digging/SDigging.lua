Extend("ShUtils")
Extend("Globals")
Extend("SPlayer")

local DIGGING_PLAYERS = {}
local DESTROY_TIMERS = {}

local MAP_DURATION = 12*60*60

function OnPlayerReadyToPlay( pPlayer )
	local pPlayer = pPlayer or source
	
	local iLastLocationID = pPlayer:GetPermanentData( "last_digging_location" )
	if iLastLocationID then
		local iStarted = pPlayer:GetPermanentData( "last_digging_location_created" )
		if iStarted then
			if getRealTime().timestamp - iStarted < MAP_DURATION then
				DESTROY_TIMERS[pPlayer] = setTimer(function( player )
					OnPlayerEndDigging( player, true )
				end, (getRealTime().timestamp - iStarted) * 1000, 1, pPlayer)

				triggerClientEvent( pPlayer, "OnDiggingLocationReceived", resourceRoot, iLastLocationID )
			else
				OnPlayerEndDigging( pPlayer, true )
			end
		else
			pPlayer:SetPermanentData( "last_digging_location_created", getRealTime().timestamp )
			triggerClientEvent( pPlayer, "OnDiggingLocationReceived", resourceRoot, iLastLocationID )
		end
	end
end
addEventHandler("onPlayerReadyToPlay", root, OnPlayerReadyToPlay)


function OnResourceStart()
	setTimer(function()
		for k,v in pairs( getElementsByType("player") ) do
			OnPlayerReadyToPlay( v )
		end
	end, 3000, 1)
end
addEventHandler("onResourceStart", resourceRoot, OnResourceStart)

function OnPlayerRequestDiggingLocation( player )
	local player = player or source

	local iLocationID = player:GetPermanentData( "last_digging_location" )
	if not TREASURE_LOCATIONS_LIST[ iLocationID ] then 
		local iPreviousLocationID = player:GetPermanentData("previous_digging_location") or 0
		repeat
			iLocationID = math.random( 1, #TREASURE_LOCATIONS_LIST )
		until
			iLocationID ~= iPreviousLocationID
	
			player:InventoryRemoveItem( IN_TREASURE_MAP, 1 )
	
		triggerClientEvent( player, "OnDiggingLocationReceived", resourceRoot, iLocationID )
	
		player:SetPermanentData( "last_digging_location", iLocationID )
		player:SetPermanentData( "last_digging_location_created", getRealTime().timestamp )
	
		DESTROY_TIMERS[player] = setTimer(function( player )
			OnPlayerEndDigging( player, true )
		end, MAP_DURATION*1000, 1, player)
	end

	triggerClientEvent( player, "ShowUI_DiggingMap", player, true, { map_id = iLocationID } )
end
addEvent( "OnPlayerRequestDiggingLocation" )
addEventHandler( "OnPlayerRequestDiggingLocation", root, OnPlayerRequestDiggingLocation )

function OnPlayerHitDiggingMarker( pPlayer )
	local pPlayer = pPlayer or client

	if DIGGING_PLAYERS[pPlayer] then
		OnPlayerEndDigging( pPlayer )
	else
		local pEquippedTool = exports.nrp_hobby_inventory:GetPlayerEquippedTool( pPlayer, HOBBY_DIGGING )

		if pPlayer:IsOnFactionDuty( ) then
			return false, "Ты на смене во фракции!"
		end

		if pPlayer:GetOnShift( ) then
			return false, "Закончи смену на работе!"
		end

		if pPlayer:IsOnUrgentMilitary( ) and not pPlayer:IsUrgentMilitaryVacation() then
			return false, "Ты на срочной службе!"
		end

		if pPlayer:getData( "current_quest" ) then
			return false, "Закончи текущую задачу!"
		end

		if not pEquippedTool then
			pPlayer:ShowError("Ты забыл взять лопату")
			return false
		end

		local iLevel = pPlayer:GetLevel()
		if iLevel < 6 then
			pPlayer:ShowError("Это хобби доступно с 6 уровня")
			return false
		end

		if isPedDead( pPlayer ) then
			return false
		end

		OnPlayerStartDigging( pPlayer, pEquippedTool )
	end
end
addEvent("OnPlayerHitDiggingMarker", true)
addEventHandler("OnPlayerHitDiggingMarker", root, OnPlayerHitDiggingMarker)

function OnPlayerStartDigging( pPlayer, pTool )
	local pToolData = HOBBY_EQUIPMENT[HOBBY_DIGGING][1].items[pTool.id]
	local pShovel = createObject( pToolData.model, pPlayer.position )
	setElementCollisionsEnabled( pShovel, false )

	addEventHandler("onPlayerVehicleEnter", pPlayer, OnPlayerVehicleEnter_handler)
	addEventHandler("onPlayerWasted", pPlayer, OnPlayerWasted_handler)

	DIGGING_PLAYERS[pPlayer] = 
	{
		shovel_element = pShovel,
		tool = pTool,
		tool_data = pToolData,
		item_uid = math.random( 999999 ),
	}
	exports.bone_attach:attachElementToBone(pShovel, pPlayer, 12, -0.3, 0.12, 0.1, 0, 90, -20)

	setElementData( pPlayer, "is_digging", true, false )

	triggerClientEvent( pPlayer, "OnPlayerStartDigging", resourceRoot, DIGGING_PLAYERS[pPlayer] )
end

function OnPlayerDigged( item_uid )
	local pPlayer = client

	if DIGGING_PLAYERS[pPlayer] and DIGGING_PLAYERS[pPlayer].item_uid == item_uid  then
		OnPlayerEndDigging( pPlayer, true )
		triggerEvent("OnPlayerTryObtainHobbyItem", pPlayer, HOBBY_DIGGING)
	end
end
addEvent("OnPlayerDigged", true)
addEventHandler("OnPlayerDigged", resourceRoot, OnPlayerDigged)

function OnPlayerEndDigging( pPlayer, bFinished )
	local pPlayer = pPlayer or client
	if DIGGING_PLAYERS[pPlayer] then
		if isElement( DIGGING_PLAYERS[pPlayer].shovel_element ) then
			destroyElement( DIGGING_PLAYERS[pPlayer].shovel_element )
		end

		DIGGING_PLAYERS[pPlayer] = nil
		setElementData( pPlayer, "is_digging", false, false )
		removeEventHandler("onPlayerVehicleEnter", pPlayer, OnPlayerVehicleEnter_handler)
		removeEventHandler("onPlayerWasted", pPlayer, OnPlayerWasted_handler)

		triggerClientEvent( pPlayer, "OnPlayerStopDigging", resourceRoot, bFinished )
	end

	if bFinished then
		local iLastLocationID = pPlayer:GetPermanentData( "last_digging_location" ) or 0
		pPlayer:SetPermanentData("previous_digging_location", iLastLocationID)

		pPlayer:SetPermanentData("last_digging_location", nil)
		pPlayer:SetPermanentData("last_digging_location_created", nil)

		if isTimer( DESTROY_TIMERS[pPlayer] ) then
			killTimer( DESTROY_TIMERS[pPlayer] )
		end

		DESTROY_TIMERS[pPlayer] = nil

		if not DIGGING_PLAYERS[pPlayer] then
			triggerClientEvent( pPlayer, "OnPlayerStopDigging", resourceRoot, bFinished )
		end
	end
end
addEvent("OnPlayerEndDigging", true)
addEventHandler("OnPlayerEndDigging", root, OnPlayerEndDigging)

function OnPlayerVehicleEnter_handler()
	OnPlayerEndDigging( source )
end

function OnPlayerWasted_handler()
	OnPlayerEndDigging( source )
end

function OnPlayerQuit()
	if DIGGING_PLAYERS[source] then
		OnPlayerEndDigging( source )
	end

	if isTimer( DESTROY_TIMERS[source] ) then
		killTimer( DESTROY_TIMERS[source] )
	end

	DESTROY_TIMERS[source] = nil
end
addEvent("onPlayerPreLogout", true)
addEventHandler("onPlayerPreLogout", root, OnPlayerQuit, true, "high+99999999999")

if SERVER_NUMBER > 100 then
	addCommandHandler( "set_digging_point", function( player, cmd, location_id )
		location_id = tonumber( location_id )
		
		player:SetPermanentData( "last_digging_location", location_id )
		player:SetPermanentData( "last_digging_location_created", getRealTimestamp() )

		triggerClientEvent( player, "ShowUI_DiggingMap", player, true, { map_id = location_id } )
		triggerClientEvent( player, "OnDiggingLocationReceived", resourceRoot, location_id )
	end )
end