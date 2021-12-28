local ROTATIONS_LIST = 
{
	{ 0, 0 },
	{ 0, 180 },
	{ 0, 270 },
	{ 0, 90 },
	{ 270, 0 },
	{ 90, 0 },
}

local pDices = {}
local pResult = {}

local pCameraVectors = {}
local vecDefaultHitPosition = 
{
	[ CASINO_THREE_AXE ] = Vector3( -87.002, -470.934, 913.92 ),
	[ CASINO_MOSCOW ] = Vector3( 2370.441, -1323.368, 2799.9703 ),
}

local iAnimationStage = 0
local iStageStarted = 0

local hint_shown = false

local vecDirection, vecTargetPosition

function ThrowDices( data )
	DestroyDices()

	hint_shown = false

	local vecStartPosition = data.player.position+Vector3(0,0,0.3)

	pResult = data.result

	local vecLastPosition = vecStartPosition
	for i = 1, 2 do
		local dice = createObject(1339, vecLastPosition + GetRandomVecInRange( 0.1, 0.2 ) )
		dice.dimension = data.player.dimension
		dice.interior = data.player.interior
		dice.scale = 0.1
		dice.collisions = false

		pDices[i] = { element = dice, start_position = dice.position, target_rotation = ROTATIONS_LIST[ data.result[i] ], visual_spins = 2, duration = math.random( 600, 1200 ) }
		vecLastPosition = dice.position
	end

	for k,v in pairs(pDices) do
		v.target_rotation[3] = math.random(0,360)
	end

	vecTargetPosition = vecDefaultHitPosition[ pGameData.casino_id ]:AddRandomRange( 0.1 )

	vecDirection = ( vecTargetPosition - vecStartPosition )

	iAnimationStage = 0
	iStageStarted = getTickCount()

	addEventHandler("onClientPreRender", root, PreRenderDices)

	setPedAnimation(data.player, "GRENADE", "WEAPON_throwu", -1, false, false, true, false)
end

function PreRenderDices()
	if iAnimationStage == 0 then
		local fProgress = (getTickCount() - iStageStarted) / 1000

		for k,v in pairs(pDices) do
			v.element.position = v.start_position + vecDirection*fProgress

			local tx, ty, tz = interpolateBetween( 0,0,0, v.visual_spins*360 + v.target_rotation[1]-90, v.target_rotation[2]-90, v.target_rotation[3], fProgress, "Linear" )
			setElementRotation( v.element, tx, ty, tz )
		end

		if fProgress >= 1 then
			iAnimationStage = 1
			iStageStarted = getTickCount()

			for k,v in pairs(pDices) do
				v.start_position = v.element.position
				v.start_rotation = { getElementRotation(v.element) }
				v.target_rotation = { v.start_rotation[1] + 90, v.start_rotation[2] + 90, v.start_rotation[3] + math.random(45, 180) }
			end

			local sfx_id = math.random(1,2)
			playSound( "sfx/hit"..sfx_id..".wav" )
		end
	elseif iAnimationStage == 1 then
		local fGProgress = (getTickCount() - iStageStarted) / 1300

		vecDirection.z = 0
		vecDirection:normalize()
		vecDirection = vecDirection * 0.3
		for k,v in pairs(pDices) do
			local fProgress = (getTickCount() - iStageStarted) / v.duration
			local fMovementProgress = interpolateBetween( 0, 0, 0, 1, 0, 0, fProgress, "OutQuad" )

			local tx, ty, tz = interpolateBetween( v.start_rotation[1], v.start_rotation[2], v.start_rotation[3], v.target_rotation[1], v.target_rotation[2], v.target_rotation[3], fProgress, "OutBounce" )
			setElementRotation( v.element, tx, ty, tz )
			v.element.position = v.start_position + vecDirection*fMovementProgress
		end

		if fGProgress >= 1 then
			iAnimationStage = 2
			iStageStarted = getTickCount()

			local cx, cy, cz, tx, ty, tz = getCameraMatrix()

			pCameraVectors.start_position = { cx, cy, cz, tx, ty, tz }

			local vecNewPosition = ( pDices[1].element.position + pDices[2].element.position ) / 2 + Vector3( 0, 0, 1 )

			pCameraVectors.target_position = { vecNewPosition.x, vecNewPosition.y, vecNewPosition.z - 1 }

			local vecDirection = vecNewPosition - localPlayer.position
			vecDirection:normalize()
			vecNewPosition = vecNewPosition - vecDirection

			pCameraVectors.end_position = { vecNewPosition.x, vecNewPosition.y, vecNewPosition.z }
		end
	elseif iAnimationStage == 2 then -- Наезд на кубики
		local fProgress = (getTickCount() - iStageStarted) / 1500

		local cx, cy, cz = interpolateBetween( pCameraVectors.start_position[1], pCameraVectors.start_position[2], pCameraVectors.start_position[3], pCameraVectors.end_position[1], pCameraVectors.end_position[2], pCameraVectors.end_position[3], fProgress, "InOutQuad" )
		local tx, ty, tz = interpolateBetween( pCameraVectors.start_position[4], pCameraVectors.start_position[5], pCameraVectors.start_position[6], pCameraVectors.target_position[1], pCameraVectors.target_position[2], pCameraVectors.target_position[3], fProgress, "InOutQuad" )
		setCameraMatrix( cx, cy, cz, tx, ty, tz )

		if getTickCount() - iStageStarted >= 3000 then
			iAnimationStage = 3
			iStageStarted = getTickCount()
		end

		if fProgress >= 1 and not hint_shown then
			ShowHint("Выпало "..pResult[1].." | "..pResult[2])
		end
	elseif iAnimationStage == 3 then -- Возврат камеры
		local fProgress = (getTickCount() - iStageStarted) / 1500

		local cx, cy, cz = interpolateBetween( pCameraVectors.end_position[1], pCameraVectors.end_position[2], pCameraVectors.end_position[3], pGameData.camera_default_position[1], pGameData.camera_default_position[2], pGameData.camera_default_position[3], fProgress, "InOutQuad" )
		local tx, ty, tz = interpolateBetween( pCameraVectors.target_position[1], pCameraVectors.target_position[2], pCameraVectors.target_position[3], pGameData.camera_default_position[4], pGameData.camera_default_position[5], pGameData.camera_default_position[6], fProgress, "InOutQuad" )
		setCameraMatrix( cx, cy, cz, tx, ty, tz )


		if getTickCount() - iStageStarted >= 1500 then
			DestroyDices()
			setCameraTarget( localPlayer )
		end
	end
end

function DestroyDices()
	for k,v in pairs(pDices) do
		if isElement(v.element) then
			destroyElement( v.element )
		end
	end

	pDices = {}

	removeEventHandler("onClientPreRender", root, PreRenderDices)
end

function GetRandomVecInRange( min, max )
	local result = {}

	for i = 1, 2 do
		local is_negative = math.random(1,2) == 2

		local rand = math.random(min*10, max*10)/10
		if is_negative then
			rand = -rand
		end

		table.insert(result, rand)
	end

	return Vector3( result[1], result[2], 0 )
end