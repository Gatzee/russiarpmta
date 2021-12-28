loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "ShVehicleConfig" )
Extend( "Globals" )

local pWarnData = 
{
	pDamageDone = { 0, 0 },
	pFactionDamageDone = { 0, 0 },
	pVehicleDamageDone = { 0, 0 },
	pFactionVehicleDamageDone = { 0, 0 },
	iLastFireWarn = 0,
}

local pAllowedWeaponsList = { 
	[0] = true,
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
	[7] = true,
	[8] = true,
	[9] = true,
	[10] = true,
	[11] = true,
	[12] = true,
	[14] = true,
	[15] = true,
	[41] = true,
	[42] = true,
	[43] = true,
	[46] = true,
}

--[[
function onClientPlayerDamage_handler( pAttacker, iWeapon, iBodypart, fLoss )
	if not isElement(pAttacker) or not isElement(source) then return end
	if source == pAttacker then return end
	if getElementType(pAttacker) == "player" then
		if pAttacker ~= localPlayer then 
			return false
		end
	elseif getElementType(pAttacker) == "vehicle" then
		if pAttacker.controller ~= localPlayer then
			return false
		end
	else
		return
	end

	if localPlayer:IsInFaction() then return end
	if localPlayer:getData("fc_fighting") then return end

	local bIsTargetInFaction = source:IsInFaction()
	local data = bIsTargetInFaction and pWarnData.pFactionDamageDone or pWarnData.pDamageDone

	if getTickCount() - data[2] <= 5000 then
		data[1] = ( data[1] or 0 ) + fLoss
	else
		data[1] = fLoss
	end
	data[2] = getTickCount()

	if data[1] >= 20 then
		if bIsTargetInFaction then
			localPlayer:AddWanted( "1.3", _, true )
		else
			localPlayer:AddWanted( "1.4", _, true )
		end
		data[1] = 0
		data[2] = getTickCount() + 10000
	end
end
addEventHandler("onClientPlayerDamage", root, onClientPlayerDamage_handler)
]]

function onClientVehicleDamage_handler( pAttacker, iWeapon, fLoss )
	if not isElement(pAttacker) or not isElement(source) then return end

	if getElementType(pAttacker) == "player" then
		if pAttacker ~= localPlayer then 
			return false
		end

		if source == localPlayer.vehicle then
			return false
		end

		if source:GetSpecialType() then
			return false -- Не выдаём за воздушный транспорт
		end

		if iWeapon == 51 then
			return false -- Ебанина со взрывами
		end
	else
		return false
	end

	if pAttacker:IsInFaction( ) then return end

	local bIsTargetInFaction = source:IsInFaction()
	local data = bIsTargetInFaction and pWarnData.pFactionVehicleDamageDone or pWarnData.pVehicleDamageDone

	if getTickCount( ) - data[2] <= 10000 then
		data[1] = ( data[1] or 0 ) + fLoss
	else
		data[1] = fLoss
	end

	data[2] = getTickCount( )

	if data[1] >= 200 then
		if bIsTargetInFaction then
			localPlayer:AddWanted( "1.6", nil, true )
		elseif localPlayer:AddWanted( "1.5", nil, true ) then
			localPlayer:AddFine( 16 )
		end
	end

end
addEventHandler("onClientVehicleDamage", root, onClientVehicleDamage_handler)

--[[ перенос в ручной режим
function onClientPlayerWeaponFire_handler( iWeaponID )
	if pAllowedWeaponsList[iWeaponID] then return end

	if localPlayer:IsInFaction() then return end -- Не вешаем, если игрок во фракции

	if getTickCount() - pWarnData.iLastFireWarn >= 30000 then
		localPlayer:AddWanted( "1.2", _, true )
		pWarnData.iLastFireWarn = getTickCount()
	end
end
addEventHandler("onClientPlayerWeaponFire", localPlayer, onClientPlayerWeaponFire_handler)
]]

function onClientPlayerWasted_handler( pKiller, iWeapon )
	if not isElement( pKiller ) or source == pKiller or localPlayer ~= pKiller or pKiller:IsInFaction( )
	or localPlayer:getData( "current_event" ) or localPlayer:getData( "is_on_event" ) then return end

	if not iWeapon or iWeapon == 51 or iWeapon == 55 or iWeapon == 63 then
		return
	end

	localPlayer:AddWanted( "1.1", nil, true )
end
addEventHandler("onClientPlayerWasted", root, onClientPlayerWasted_handler)

function OnPlayerReceiveAllWantedData( data )
	for k,v in pairs(data) do
		if isElement(k) then
			setElementData( k, "wanted_data", v, false )
			setElementData( k, "wanted_data_timeout", getRealTime().timestamp, false )
		end
	end
end
addEvent("OnPlayerReceiveAllWantedData", true)
addEventHandler("OnPlayerReceiveAllWantedData", root, OnPlayerReceiveAllWantedData)

function OnPlayerReceiveWantedData( data )
	if isElement(source) then
		if data and #data > 0 then
			setElementData( source, "wanted_data", data, false )
			setElementData( source, "wanted_data_timeout", getRealTime().timestamp, false )
		else
			setElementData( source, "wanted_data", nil, false )
			setElementData( source, "wanted_data_timeout", nil, false )
		end
	end
end
addEvent("OnPlayerReceiveWantedData", true)
addEventHandler("OnPlayerReceiveWantedData", root, OnPlayerReceiveWantedData)

Timer(function()
	if not ( localPlayer:IsInGame() and FACTION_RIGHTS.WANTED_KNOW[ localPlayer:GetFaction() ] and localPlayer:IsOnFactionDuty() ) then return end

	local players = getElementsByType("player")
	for i, player in pairs( players ) do
		if player:IsInGame() and player ~= localPlayer then
			local wanted_data = player:getData( "wanted_data" )

			if wanted_data and #wanted_data > 0 then
				local wanted_data_timeout = player:getData( "wanted_data_timeout" )

				if wanted_data_timeout + WANTED_KNOW_TIMEOUT < getRealTime().timestamp or ( player.position - localPlayer.position ).length > ( WANTED_KNOW_DISTANCE * 2 ) then
					player:setData( "wanted_data", nil, false )
					player:setData( "wanted_data_timeout", nil, false )
				end
			end
		end
	end
end, 5000, 0)