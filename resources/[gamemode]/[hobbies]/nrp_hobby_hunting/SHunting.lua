Extend( "ShUtils" )
Extend( "SPlayer" )
Extend( "SInterior" )

local ANIMALS_LIST = 
{
	{
		class = "deer",
		chance = 0.3,
		model = 150,
	},
	{
		class = "boar",
		chance = 0.3,
		model = 104,
	},
	{
		class = "bear",
		chance = 0.3,
		model = 88,
	},
	{
		class = "white_deer",
		chance = 0.01,
		model = 38,

		f_available = function( player )
			local last_drop = player:GetPermanentData( "last_animal3_drop" )
			if last_drop and getRealTime( ).timestamp - last_drop <= 60 * 60 then
				return false
			end

			local pTime = getRealTime()

			if pTime.hour >= 13 and pTime.hour < 14 or pTime.hour >= 23 then
				return true
			end
		end
	}
}

HUNTING_PLAYERS = {}

function OnPlayerHitHuntingMarker( iZone )
	local pPlayer = client
	if HUNTING_PLAYERS[pPlayer] then
		OnPlayerEndHunting( pPlayer )
	else
		local pEquipment = pPlayer:GetHobbyEquipment()
		local pEquippedTool = exports.nrp_hobby_inventory:GetPlayerEquippedTool( pPlayer, HOBBY_HUNTING )
		local iTotalAmmo = 0

		for k,v in pairs(pEquipment) do
			if v.class == "hunting:ammo" then
				iTotalAmmo = iTotalAmmo + v.amount
			end
		end

		if iTotalAmmo <= 0 then
			pPlayer:ShowError("Ты не купил боеприпасы")
			return false
		end

		if pPlayer:IsOnFactionDuty( ) then
			return false, "Ты на смене во фракции!"
		end

		if pPlayer:GetOnShift( ) then
			return false, "Закончи смену на работе!"
		end

		if pPlayer:IsOnUrgentMilitary( ) and not pPlayer:IsUrgentMilitaryVacation() then
			return false, "Ты на срочной службе!"
		end

		if pPlayer:getData( "is_handcuffed" ) then
			return false, "Ты в наручниках!"
		end

		if pPlayer:getData( "current_quest" ) then
			return false, "Закончи текущую задачу!"
		end

		if pPlayer:getData( "registered_in_clan_event" ) then
			return false, "Отмени участие в войне кланов!"
		end

		if not pEquippedTool then
			pPlayer:ShowError("Ты забыл взять ружьё")
			return false
		end

		local iLevel = pPlayer:GetLevel()
		if iLevel < 5 then
			pPlayer:ShowError("Это хобби доступно с 5 уровня")
			return false
		end

		if isPedDead( pPlayer ) then
			return false
		end

		OnPlayerStartHunting( pPlayer, pEquippedTool, iTotalAmmo, iZone )
	end
end
addEvent("OnPlayerHitHuntingMarker", true)
addEventHandler("OnPlayerHitHuntingMarker", root, OnPlayerHitHuntingMarker)

function OnPlayerStartHunting( pPlayer, pTool, iAmmo, iZone )
	local pToolData = HOBBY_EQUIPMENT[HOBBY_HUNTING][1].items[pTool.id]

	addEventHandler("onPlayerVehicleEnter", pPlayer, OnPlayerVehicleEnter_handler)
	addEventHandler("onPlayerWasted", pPlayer, OnPlayerWasted_handler)
	addEventHandler("onPlayerWeaponFire", pPlayer, OnPlayerWeaponFire_handler)

	HUNTING_PLAYERS[pPlayer] = 
	{
		tool = pTool,
		tool_data = pToolData,
		stored_weapons = pPlayer:GetPermanentWeapons( ),
		zone_id = iZone or 1,
		animal_data = GetRandomAnimalClass( pPlayer ),
		start_position = pPlayer.position,
		item_uid = math.random( 999999 ),
	}

	pPlayer:TakeAllWeapons()
	pPlayer:GiveWeapon(34, iAmmo, true, true)
	pPlayer:SetPrivateData("is_hunting", true)
	pPlayer:Teleport( nil, pPlayer:GetUniqueDimension( ) )
	pPlayer:CompleteDailyQuest( "start_hunting" )

	triggerClientEvent( pPlayer, "OnPlayerStartHunting", resourceRoot, HUNTING_PLAYERS[pPlayer] )
	triggerEvent( "onPlayerStartHunting", pPlayer )
end

function OnPlayerHarvested( item_uid )
	local pPlayer = client

	if item_uid and HUNTING_PLAYERS[pPlayer] and HUNTING_PLAYERS[pPlayer].item_uid == item_uid then
		HUNTING_PLAYERS[pPlayer].item_uid = nil
		-- OnPlayerEndDigging( pPlayer, true )
		triggerEvent("OnPlayerTryObtainHobbyItem", pPlayer, HOBBY_HUNTING, { animal_type = HUNTING_PLAYERS[pPlayer].animal_data.class })
	end
end
addEvent("OnPlayerHarvested", true)
addEventHandler("OnPlayerHarvested", resourceRoot, OnPlayerHarvested)

function OnPlayerRequestNextAnimal()
	local pPlayer = source
	HUNTING_PLAYERS[pPlayer].animal_data = GetRandomAnimalClass( pPlayer )
	HUNTING_PLAYERS[pPlayer].item_uid = math.random( 999999 )
	triggerClientEvent( pPlayer, "OnNextAnimalRequested", pPlayer, HUNTING_PLAYERS[pPlayer].animal_data, HUNTING_PLAYERS[pPlayer].item_uid )
end
addEvent("OnPlayerRequestNextAnimal")
addEventHandler("OnPlayerRequestNextAnimal", root, OnPlayerRequestNextAnimal)

function OnPlayerEndHunting( pPlayer )
	local pPlayer = pPlayer or client
	if HUNTING_PLAYERS[pPlayer] then
		pPlayer:TakeAllWeapons()
		pPlayer:Teleport( HUNTING_PLAYERS[pPlayer].start_position, 0 )

		if HUNTING_PLAYERS[pPlayer].stored_weapons then
			GiveWeaponsFromTable( pPlayer, HUNTING_PLAYERS[pPlayer].stored_weapons )
		end

		HUNTING_PLAYERS[pPlayer] = nil
		pPlayer:SetPrivateData("is_hunting", false)

		removeEventHandler("onPlayerVehicleEnter", pPlayer, OnPlayerVehicleEnter_handler)
		removeEventHandler("onPlayerWasted", pPlayer, OnPlayerWasted_handler)
		removeEventHandler("onPlayerWeaponFire", pPlayer, OnPlayerWeaponFire_handler)

		triggerClientEvent( pPlayer, "OnPlayerStopHunting", resourceRoot )

		triggerEvent( "onPlayerStopHunting", pPlayer )
	end
end
addEvent("OnPlayerEndHunting", true)
addEventHandler("OnPlayerEndHunting", root, OnPlayerEndHunting)

function OnPlayerVehicleEnter_handler()
	OnPlayerEndHunting( source )
end

function OnPlayerWasted_handler()
	OnPlayerEndHunting( source )
end

function OnPlayerWeaponFire_handler()
	triggerEvent("OnPlayerHuntingRifleFire", source)
end

function OnPlayerQuit( pPlayer )
	local pPlayer = isElement( pPlayer ) and pPlayer or source

	if HUNTING_PLAYERS[pPlayer] then
		OnPlayerEndHunting( pPlayer )
	end
end
addEvent("onPlayerPreLogout", true)
addEventHandler("onPlayerPreLogout", root, OnPlayerQuit)

function OnResourceStop()
	for player, data in pairs(HUNTING_PLAYERS) do
		if isElement( player ) then
			OnPlayerEndHunting( player )
		end
	end
end
addEventHandler("onResourceStop", resourceRoot, OnResourceStop)


function GetWeaponsTable( pPlayer )
	local pWeapons = {}

	for slot = 0, 12 do
		local iWeaponID = getPedWeapon( pPlayer, slot )
		local iAmmo = getPedTotalAmmo( pPlayer, slot )

		pWeapons[slot] = { iWeaponID, iAmmo }
	end

	return pWeapons
end

function GiveWeaponsFromTable( pPlayer, pWeapons )
	for k,v in pairs( pWeapons ) do
		if v[1] and v[2] > 0 then
			pPlayer:GiveWeapon( v[1], v[2], false )
		end
	end
end

function GetRandomAnimalClass( pPlayer )
	local pItemsPool = ANIMALS_LIST
	local pIgnoredItems = {}
	local pItem
	local iRange = 0

	for k,v in pairs(pItemsPool) do
		if v.f_available and not v.f_available( pPlayer ) then
			pIgnoredItems[k] = true
		end
	end

	for k,v in pairs(pItemsPool) do
		if not pIgnoredItems[k] then
			iRange = iRange + v.chance * 100
		end
	end

	iRange = math.ceil(iRange)

	local iRandom = math.random(0, iRange)
	local iTop = 0

	for k,v in pairs(pItemsPool) do
		if not pIgnoredItems[k] then
				iTop = iTop + v.chance * 100
			if iRandom <= math.ceil( iTop ) then
				pItem = v
				break
			end
		end
	end

	return pItem
end