loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )

local COOLDOWN_DELAY = 30000
local REVIVE_DELAY = 120000
local MEDIC_HEAL_COOLDOWN = 15000
local PLAYER_HEAL_COOLDOWN = 120000

local COOLDOWN = {}
local NEXT_REVIVE = {}
local NEXT_HEAL = {}

function OnPlayerTryRevive( pTarget )
	if not isPedDead(pTarget) then return end

	if pTarget:getData( "jailed" ) then
		source:ShowError( "Нельзя реанимировать заключенного" )
		return
	end

	if not REVIVE_CALL_PLAYER_BY_MEDIC[ source ] and COOLDOWN[source] and COOLDOWN[source] >= getTickCount() then
		source:ShowError("Дефибриллятор ещё перезаряжается")
		return
	end

	if NEXT_REVIVE[pTarget] and NEXT_REVIVE[pTarget] >= getTickCount() then
		source:ShowError("Нельзя так часто производить дефибрилляцию!")
		return
	end

	NEXT_REVIVE[pTarget] = getTickCount() + REVIVE_DELAY
	COOLDOWN[source] = getTickCount() + COOLDOWN_DELAY

	triggerClientEvent( pTarget, "ShowDeathCountdown", pTarget )

	local sync_to = getElementsWithinRange( source.position, 75, "player" )
	local dimension = source.dimension
	for k, v in pairs( sync_to ) do
		if v.dimension ~= dimension then
			sync_to[ k ] = nil
		end
	end
	triggerClientEvent( sync_to, "OnPlayerStartReviving", source, pTarget )
end
addEvent( "OnPlayerTryRevive" )
addEventHandler( "OnPlayerTryRevive", root, OnPlayerTryRevive )

function OnPlayerTryHeal( pTarget )
	if pTarget.health >= ( pTarget:getData( "max_health" ) or 100 ) then
		source:ShowError( pTarget:GetNickName() .. " в лечении не нуждается" )
		return
	end

	if NEXT_HEAL[pTarget] and NEXT_HEAL[pTarget] >= getTickCount() then
		source:ShowError( pTarget:GetNickName() .. " пока не может принять лечение" )
		return
	end

	if NEXT_HEAL[source] and NEXT_HEAL[source] >= getTickCount() then
		source:ShowError("Отдохни хоть немного...")
		return
	end

	NEXT_HEAL[source] = getTickCount() + MEDIC_HEAL_COOLDOWN
	NEXT_HEAL[pTarget] = getTickCount() + PLAYER_HEAL_COOLDOWN
	pTarget:SetHP( pTarget:getData( "max_health" ) or 100 )
	pTarget:ShowInfo( source:GetNickName().." полностью вылечил Вас" )
	source:ShowInfo( "Вы вылечили "..pTarget:GetNickName() )

	triggerClientEvent( source, "PlayerAction_HealSuccess", root, pTarget:GetFaction() )
end
addEvent( "OnPlayerTryHeal" )
addEventHandler( "OnPlayerTryHeal", root, OnPlayerTryHeal )

function OnPlayerFinishedReviving( pTarget )
	if not FACTION_RIGHTS.REANIMATION[ source:GetFaction( ) ] then return end
	if not isElement( pTarget ) or not isElement( source ) then return end

	spawnPlayer( pTarget, pTarget.position, pTarget.rotation.z, pTarget.model, pTarget.interior, pTarget.dimension )
	pTarget:SetCalories( 60 )
	pTarget:SetHP( 20 )

	pTarget:ShowInfo("Вас успешно реанимировали")
	source:ShowInfo("Вы успешно произвели реанимацию")
	if pTarget:GetFaction() then
		if pTarget:IsOnFactionDuty() then
			triggerEvent( "OnPlayerFactionDutyWeaponReturn", pTarget )
		end
	end

	triggerEvent( "onServerCompleteShiftPlan", source, source, "reviving" )
end
addEvent( "OnPlayerFinishedReviving", true )
addEventHandler( "OnPlayerFinishedReviving", root, OnPlayerFinishedReviving )