loadstring(exports.interfacer:extend("Interfacer"))()
Extend("SPlayer")

local PLAYER_WEAPONS = {}
local PLAYER_TEMP_WEAPONS = {}
local PLAYER_LAST_SHOT = {}
local PLAYER_WARNINGS = {}

local MELEE_SLOTS = 
{
	[0] = true,
	[1] = true,
	[9] = true,
	[10] = true,
	[11] = true,
	[12] = true,
}

addEventHandler("onResourceStart", resourceRoot, function()
	for i, player in pairs(getElementsByType("player")) do
		if player:IsInGame() then
			CreateWeaponsTableIfNotExists( player )
		end
	end
end)

function GiveWeapon( pPlayer, iWeaponID, iAmmo, bCurrent, bTemporary, sReason )
	if not isElement( pPlayer ) then return end

	iWeaponID = tonumber( iWeaponID )
	if not iWeaponID then
		return false, "Не указан ID оружия"
	end

	iAmmo = tonumber( iAmmo )
	if not iAmmo then
		return false, "Не указано количество патронов"
	end

	if iWeaponID <= 0 or iWeaponID > 46 then
		return false, "Неверный ID оружия"
	end

	local slot = getSlotFromWeapon( iWeaponID )
	if not slot then
		return false, "Неверный ID оружия"
	end

	CreateWeaponsTableIfNotExists( pPlayer )

	local weapons = PLAYER_WEAPONS[pPlayer]
	local temp_weapons = PLAYER_TEMP_WEAPONS[pPlayer]

	if bTemporary then
		local iPrevAmmo = temp_weapons[slot] and temp_weapons[slot][1] and temp_weapons[slot][2] or 0
		temp_weapons[slot] = { iWeaponID, iPrevAmmo + iAmmo }

		-- Если у игрока уже есть на этом слоте перманентное оружие с другим айди (например, было ak47(30), выдали m4(31))
		-- забираем его и возвращаем при удалении временного оружия в TakeAllWeapons
		local permanent_weapon_id = weapons[slot] and weapons[slot][1] or 0
		local permanent_weapon_ammo = permanent_weapon_id > 0 and weapons[slot][2] or 0
		if permanent_weapon_id ~= iWeaponID and permanent_weapon_ammo > 0 then
			takeWeapon( pPlayer, permanent_weapon_id, permanent_weapon_ammo )
		end
	else
		local iPrevAmmo = weapons[slot] and weapons[slot][1] == iWeaponID and weapons[slot][2] or 0
		weapons[slot] = { iWeaponID, iPrevAmmo + iAmmo }
	end

	giveWeapon( pPlayer, iWeaponID, iAmmo, bCurrent )

	WriteLog( "weapon/debug", "[GIVE] %s WeaponID: %s Ammo: %s Temporary: %s \n RESULT: %s", 
		pPlayer, iWeaponID, iAmmo, bTemporary, bTemporary and temp_weapons[slot] or weapons[slot] )

	return true
end

function TakeWeapon( pPlayer, iWeaponID, iAmmo )
	if not isElement(pPlayer) then return end

	CreateWeaponsTableIfNotExists( pPlayer )

	takeWeapon( pPlayer, iWeaponID, iAmmo )
	UpdateWeaponsList( pPlayer )

	WriteLog( "weapon/debug", "[TAKE] %s WeaponID: %s Ammo: %s \n RESULT: %s", 
		pPlayer, iWeaponID, iAmmo, GetMixedWeaponsTable(pPlayer) )

	return true
end

function TakeAllWeapons( pPlayer, bOnlyTemporary )
	if not isElement(pPlayer) then return end

	CreateWeaponsTableIfNotExists( pPlayer )
	
	if bOnlyTemporary then
		local weapons = PLAYER_WEAPONS[pPlayer]
		local temp_weapons = PLAYER_TEMP_WEAPONS[pPlayer]
		for slot = 1, 12 do
			-- Учитываем, если у игрока на этом слоте было перманентное оружие с другим айди (например, было ak47(30), выдали m4(31))
			local temp_weapon_id = temp_weapons[slot] and temp_weapons[slot][1] or 0
			local permanent_weapon_id = weapons[slot] and weapons[slot][1] or 0
			local permanent_weapon_ammo = permanent_weapon_id > 0 and weapons[slot][2] or 0
			if MELEE_SLOTS[slot] then
				if temp_weapon_id ~= permanent_weapon_id then
					takeWeapon( pPlayer, temp_weapon_id )
				end
			elseif getPedTotalAmmo( pPlayer, slot ) ~= permanent_weapon_ammo then
				local weapon_id = permanent_weapon_id > 0 and permanent_weapon_id or temp_weapon_id
				setWeaponAmmo( pPlayer, weapon_id, permanent_weapon_ammo )
			end
			if getPedWeapon( pPlayer, slot ) ~= permanent_weapon_id and permanent_weapon_ammo > 0 then
				giveWeapon( pPlayer, permanent_weapon_id, MELEE_SLOTS[slot] and 1 or 0 )
			end

			temp_weapons[slot] = {0, 0}
		end
		UpdateWeaponsList( pPlayer )
	else
		takeAllWeapons( pPlayer )
		local weapons = { }
		local temp_weapons = { }
		for slot = 1, 12 do
			weapons[slot] = { 0, 0 }
			temp_weapons[slot] = { 0, 0 }
		end
		PLAYER_WEAPONS[pPlayer] = weapons
		PLAYER_TEMP_WEAPONS[pPlayer] = temp_weapons
	end

	WriteLog( "weapon/debug", "[TAKE_ALL] %s OnlyTemp - %s\n RESULT: %s", 
		pPlayer, bOnlyTemporary, GetMixedWeaponsTable(pPlayer) )
end

function GetPermanentWeapons( pPlayer )
	local weapons_with_ammo = { }
	local weapons = PLAYER_WEAPONS[pPlayer]
	for slot = 1, 12 do
		local slot_data = weapons[slot]
		if slot_data[2] > 0 then
			--OnPlayerWeaponFire не триггерит если оружие выделяет частицы, поэтому принудительно берём пт
			if slot_data[1] == 41 then slot_data[2] = getPedTotalAmmo(pPlayer, slot) end
			table.insert( weapons_with_ammo, slot_data )
		end
	end
	return weapons_with_ammo
end

function UpdateWeaponsList( pPlayer, bForced )
	local pCurrentData = GetWeaponsTable( pPlayer )

	if bForced then
		PLAYER_WEAPONS[ pPlayer ] = pCurrentData
		return true
	end

	local pDelta = {}
	local pMixed = GetMixedWeaponsTable( pPlayer )
	
	for slot, data in pairs( pCurrentData ) do
		if not MELEE_SLOTS[slot] then
			local delta = pMixed[slot][2] - data[2]
			if delta < 0 then
				WarnPlayer( pPlayer, "Бесконечные патроны (SLOT: "..slot..", EXPECTED: "..data[2]..", GOT: "..pMixed[slot][2] )
			else
				pDelta[slot] = delta
			end
		end
	end
	
	-- Removing from temporary
	local temp_weapons = PLAYER_TEMP_WEAPONS[pPlayer]
	if temp_weapons then
		for slot, ammo in pairs(pDelta) do
			if not MELEE_SLOTS[slot] then
				if temp_weapons[slot] and temp_weapons[slot][2] > 0 then
					local iRemoved = math.min( temp_weapons[slot][2], ammo )
					temp_weapons[slot][2] = temp_weapons[slot][2] - iRemoved
					pDelta[slot] = ammo - iRemoved
				end
			end
		end
	end

	-- Removing from permanent
	local weapons = PLAYER_WEAPONS[pPlayer]
	if weapons then
		for slot, ammo in pairs(pDelta) do
			if not MELEE_SLOTS[slot] and ammo > 0 then
				if weapons[slot] then
					if weapons[slot][2] >= ammo then
						weapons[slot][2] = weapons[slot][2] - ammo
					else
						WarnPlayer( pPlayer, "Бесконечные патроны (SLOT: "..slot..", EXPECTED: "..ammo..", GOT: "..weapons[slot][2]..")" )
						weapons[slot][2] = 0
					end
				end
			end
		end
	end

	return true
end

function WarnPlayer( pPlayer, sReason )
	local sName = pPlayer:GetNickName()
	PLAYER_WARNINGS[pPlayer] = ( PLAYER_WARNINGS[pPlayer] or 0 ) + 1

	WriteLog("weapon/warns", "#22dd22[WEAPONS] #dd2222"..sName.." #ffffff "..PLAYER_WARNINGS[pPlayer].." предупреждение: "..sReason)

	if PLAYER_WARNINGS[pPlayer] >= 3 then
		pPlayer:kick( "Использование читов на оружие" )

		for i, player in pairs(getElementsByType("player")) do
			if player:IsAdmin() then
				outputChatBox( "#22dd22[WEAPONS] #ffffffИгрок #dd2222"..sName.." #ffffff кикнут с сервера за использование читов на оружие", player, 255, 255, 255, true )
			end
		end
	end
end

function OnPlayerWeaponFire_handler( iWeaponID )
	if not PLAYER_WEAPONS[source] then return end
	
	local slot = getSlotFromWeapon( iWeaponID )
	local slot_data = PLAYER_WEAPONS[source][slot]
	local temp_slot_data = PLAYER_TEMP_WEAPONS[source][slot]
	if temp_slot_data[2] > 0 then
		temp_slot_data[2] = temp_slot_data[2] - 1
	elseif slot_data[2] > 0 then
		slot_data[2] = slot_data[2] - 1
	end
end
addEventHandler("onPlayerWeaponFire", root, OnPlayerWeaponFire_handler)

function OnPlayerWasted_handler()
	TakeAllWeapons( source )
end
addEventHandler("onPlayerWasted", root, OnPlayerWasted_handler)

function OnPlayerLogin_handler()
	CreateWeaponsTableIfNotExists( source )
end
addEventHandler("onPlayerCompleteLogin", root, OnPlayerLogin_handler, true, "high+1000000")

function OnPlayerLogout_handler()
	TakeAllWeapons( source, true )
end
addEventHandler("onPlayerPreLogout", root, OnPlayerLogout_handler)

function onPlayerQuit_handler()
	PLAYER_WARNINGS[source] = nil
	PLAYER_WEAPONS[source] = nil
	PLAYER_TEMP_WEAPONS[source] = nil
	PLAYER_LAST_SHOT[source] = nil
end
addEventHandler( "onPlayerQuit", root, onPlayerQuit_handler, true, "low-1000000" )

-- Utils
function GetWeaponsTable( pPlayer )
	local pWeapons = {}

	for slot = 0, 12 do
		local iWeaponID = getPedWeapon( pPlayer, slot ) or 0
		local iAmmo = iWeaponID > 0 and getPedTotalAmmo( pPlayer, slot ) or 0

		pWeapons[slot] = { iWeaponID, iAmmo }
	end

	return pWeapons
end

function GiveWeaponsFromTable( pPlayer, pWeapons )
	for k,v in pairs( pWeapons ) do
		if v[1] and v[2] > 0 then
			GiveWeapon( pPlayer, v[1], v[2] )
		end
	end

	UpdateWeaponsList( pPlayer, true )
end

function GetMixedWeaponsTable( pPlayer )
	local pResult = {}

	local weapons = PLAYER_WEAPONS[pPlayer]
	local temp_weapons = PLAYER_TEMP_WEAPONS[pPlayer]
	for slot = 0, 12 do
		local pPermanent = weapons and weapons[slot] or {0, 0}
		local pTemporary = temp_weapons and temp_weapons[slot] or {0, 0}

		local iWeapon = math.max(pPermanent[1], pTemporary[1])
		pResult[slot] = { iWeapon, pPermanent[2] + pTemporary[2] }
	end

	return pResult
end

function CreateWeaponsTableIfNotExists( pPlayer )
	if not PLAYER_WEAPONS[pPlayer] then
		UpdateWeaponsList( pPlayer, true )
	end

	if not PLAYER_TEMP_WEAPONS[pPlayer] then
		local temp_weapons = {}
		for slot = 0, 12 do
			temp_weapons[slot] = {0, 0}
		end
		PLAYER_TEMP_WEAPONS[pPlayer] = temp_weapons
	end
end