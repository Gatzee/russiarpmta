local pAnimalData = {}
local iLastPlayerCheck = 0

function CheckPosition( vecPosition )
	local lines = {}
	local gz = getGroundPosition( vecPosition )
	vecPosition.z = gz

	local line = { 
		vecPosition,
		vecPosition+Vector3( 0, 0, 10 )
	}

	table.insert(lines, line)

	local dist = 5
	local angle = 0

	for i = 1, 6 do
		local a = math.rad(90 - angle)
 
		local dx = math.cos(a) * dist
		local dy = math.sin(a) * dist

		local nextPosition = vecPosition + Vector3( dx, dy, 10 )
		local gz = getGroundPosition( nextPosition )
		nextPosition.z = gz

		local line = { 
			nextPosition,
			nextPosition+Vector3( 0, 0, 10 )
		}

		table.insert(lines, line)

		angle = angle + 360/6
	end

	local total_z = 0
	for k,v in pairs(lines) do
		total_z = total_z + v[1].z
	end

	local result = math.abs( total_z/7 - lines[1][1].z )

	return result <= 1
end

function PickAnimalPosition( iZoneID )
	local vecPlayerPosition = localPlayer.position
	local randVec

	repeat 
		local rand_angle = math.random(0, 360)
		local rand_dist = math.random( 60, 120 )

		local a = math.rad(90 - rand_angle)
 
		local dx = math.cos(a) * rand_dist
		local dy = math.sin(a) * rand_dist

		randVec = vecPlayerPosition + Vector3( dx, dy, 100 )
	until
		CheckPosition( randVec ) and isInsideColShape( HUNTING_ZONES_LIST[iZoneID].element, randVec )

	return randVec
end

function CreateAnimal( pAnimal, iZoneID )
	DestroyAnimal()

	local vecPosition = PickAnimalPosition( iZoneID )

	HUNTING_DATA.animal = createPed( pAnimal.model, vecPosition+Vector3( 0, 0, 1 ) )
	HUNTING_DATA.blip = createBlipAttachedTo( HUNTING_DATA.animal, 59 )

	HUNTING_DATA.animal.dimension = localPlayer.dimension
	HUNTING_DATA.blip.dimension = localPlayer.dimension

	pAnimalData = 
	{
		vecStartPosition = vecPosition,
		iLastSwitch = getTickCount(),
		iAction = 1,
		iAngle = 0,
		iNextSwitch = math.random( 3000, 8000 ),
		bScared = false,
		pZone = HUNTING_ZONES_LIST[iZoneID].element,
	}

	HUNTING_DATA.client_animal_data = pAnimalData

	addEventHandler("onClientPreRender", root, HandleAnimal)
	addEventHandler("onClientPedDamage", HUNTING_DATA.animal, OnAnimalDamage)
	triggerEvent("OnAnimalCreated", HUNTING_DATA.animal)
end

function DestroyAnimal()
	DestroyAnimalMarker()

	if isElement(HUNTING_DATA.animal) then
		removeEventHandler("onClientPedDamage", HUNTING_DATA.animal, OnAnimalDamage)
		destroyElement( HUNTING_DATA.animal )
	end

	if isElement(HUNTING_DATA.corpse_col) then
		destroyElement( HUNTING_DATA.corpse_col )
	end

	removeEventHandler("onClientPreRender", root, HandleAnimal)

	triggerEvent("OnAnimalDestroyed", root)
end

function DestroyAnimalMarker()
	if isElement(HUNTING_DATA.blip) then destroyElement( HUNTING_DATA.blip ) end
end

function HandleAnimal()
	if pAnimalData.bDead then return end

	local tick = getTickCount()

	if not isElementWithinColShape( HUNTING_DATA.animal, pAnimalData.pZone ) then
		UpdateAnimalAction( 3 )
	end

	if tick - iLastPlayerCheck >= 1000 then
		iLastPlayerCheck = tick

		local fDistance = ( localPlayer.position - HUNTING_DATA.animal.position ).length

		if fDistance <= 40 then
			local rand = math.random(0, 100) + 40 - fDistance
			if rand >= 50 then
				SetAnimalScared( true )
				return
			end
		end
	end

	if pAnimalData.iResetScared and tick >= pAnimalData.iResetScared then
		SetAnimalScared( false )
	end

	if tick - pAnimalData.iLastSwitch >= pAnimalData.iNextSwitch then
		UpdateAnimalAction()
	end

	--setElementRotation( HUNTING_DATA.animal, 0, 0, -pAnimalData.iAngle )
	--setPedCameraRotation( HUNTING_DATA.animal, -pAnimalData.iAngle )
end

function UpdateAnimalAction( iAction, is_killed )
	if pAnimalData.bDead then return end

	pAnimalData.iAction = iAction or pAnimalData.bScared and 3 or math.random(1,2)

	pAnimalData.iAngle = math.random(0,360)
	pAnimalData.iNextSwitch = math.random(3000, 8000)
	pAnimalData.iLastSwitch = getTickCount()

	local fDistance = ( HUNTING_DATA.animal.position - pAnimalData.vecStartPosition ).length

	if ( not pAnimalData.bScared and fDistance >= 15 ) or not isElementWithinColShape( HUNTING_DATA.animal, pAnimalData.pZone ) then
		local ax, ay = getElementPosition( HUNTING_DATA.animal )
		pAnimalData.iAngle = math.deg( math.atan2( pAnimalData.vecStartPosition.x - ax, pAnimalData.vecStartPosition.y - ay ) )
	else
		pAnimalData.iAngle = math.random(0,360)
	end

	-- idle
	if pAnimalData.iAction == 1 then
		setPedControlState( HUNTING_DATA.animal, "forwards", false )
		setPedControlState( HUNTING_DATA.animal, "sprint", false )
		setPedControlState( HUNTING_DATA.animal, "walk", false )
		if is_killed then
			KillAnimal()
		end
	-- move
	elseif pAnimalData.iAction == 2 then
		setElementRotation( HUNTING_DATA.animal, 0, 0, pAnimalData.iAngle )
		setPedCameraRotation( HUNTING_DATA.animal, pAnimalData.iAngle )
		setPedControlState( HUNTING_DATA.animal, "forwards", true )
		setPedControlState( HUNTING_DATA.animal, "walk", true )
		setPedControlState( HUNTING_DATA.animal, "sprint", false )
	-- run
	elseif pAnimalData.iAction == 3 then
		setElementRotation( HUNTING_DATA.animal, 0, 0, pAnimalData.iAngle )
		setPedCameraRotation( HUNTING_DATA.animal, pAnimalData.iAngle )
		setPedControlState( HUNTING_DATA.animal, "forwards", true )
		setPedControlState( HUNTING_DATA.animal, "sprint", true )
		setPedControlState( HUNTING_DATA.animal, "walk", false )
	end
end

function SetAnimalScared( state )
	pAnimalData.iResetScared = getTickCount() + 10000
	if pAnimalData.bScared == state then return end

	pAnimalData.bScared = state

	if state then
		UpdateAnimalAction( 3 )
	else
		UpdateAnimalAction( 1 )
		pAnimalData.iResetScared = nil
	end
end

local KILL_PHRASES_LIST = 
{
	"Прямо в яблочко!",
	"Отличный выстрел, забирай добычу!",
}

function KillAnimal()
	if pAnimalData.bDead == true then return end

	local ax, ay, az = getElementPosition( HUNTING_DATA.animal )
	local rx, _, rz = getElementRotation( HUNTING_DATA.animal )
	setElementRotation( HUNTING_DATA.animal, rx, 80, rz )
	setElementPosition( HUNTING_DATA.animal, ax, ay, az - 0.7 )
	setElementFrozen(HUNTING_DATA.animal, true)

	pAnimalData.bDead = true

	HUNTING_DATA.corpse_col = createColSphere( HUNTING_DATA.animal.position, 2 )
	HUNTING_DATA.corpse_col.dimension = localPlayer.dimension
	attachElements( HUNTING_DATA.corpse_col, HUNTING_DATA.animal )

	localPlayer:ShowSuccess(KILL_PHRASES_LIST[ math.random(#KILL_PHRASES_LIST) ])

	triggerEvent( "onPlayerKillAnimal", localPlayer )
end