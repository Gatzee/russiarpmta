loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShUtils" )

local cameraHeight = 1.4
local cameraOffset = Vector3( 0, -6.5, 0 )
local lookAtOffset = Vector3( 0, 3, 0 )

local targetRotation = 0
local currentRotation = 0
local rotationMul = 0.05

local currentCameraPosition = Vector3( cameraOffset ) + Vector3( 0, 0, cameraHeight )
local currentLookOffset = Vector3( lookAtOffset )
local currentCameraRoll = 0
local currentCameraFOV = 70
local currentCameraZ = 0
local currentCameraRotation = math.pi

local function getDriftAngle()
	local vehicle = localPlayer.vehicle
	if vehicle.velocity.length < 0.2 then
		return 0, false
	end

	local direction = vehicle.matrix.forward
	local velocity = vehicle.velocity.normalized

	local dot = direction.x * velocity.x + direction.y * velocity.y
	local det = direction.x * velocity.y - direction.y * velocity.x

	local angle = math.atan2(det, dot)
	return angle
end

function differenceBetweenAngles(firstAngle, secondAngle)
	local difference = secondAngle - firstAngle
	while difference < -180 do
		difference = difference + 360
	end
	while difference > 180 do
		difference = difference - 360
	end
	return difference
end

local _getKeyState = getKeyState
local function getKeyState(...)
	return _getKeyState(...) and not isMTAWindowActive()
end

function RenderCamera(deltaTime)
	if not localPlayer.vehicle then return end
    
    local is_left = getKeyState("a")
    local is_right = getKeyState("d")
    if is_left or is_right then
        deltaTime = deltaTime / 7000
    else
        deltaTime = deltaTime / 3000
    end

	local driftAngle = -getDriftAngle()
	local targetCameraRotation = driftAngle + math.pi
	currentCameraRotation = currentCameraRotation + (targetCameraRotation - currentCameraRotation) * deltaTime * 5

	local len = #cameraOffset
	local targetCameraPosition = Vector3(math.sin(currentCameraRotation) * len, math.cos(currentCameraRotation) * len, cameraHeight)
	local targetLookOffset = lookAtOffset + Vector3(driftAngle * 3.1, 0, 0)

	local targetCameraRoll = driftAngle * 5
	currentCameraRoll = currentCameraRoll + (targetCameraRoll - currentCameraRoll) * deltaTime * 2

	local targetCameraFOV = 70 + math.abs(driftAngle) * 20
	currentCameraFOV = currentCameraFOV + (targetCameraFOV - currentCameraFOV) * deltaTime * 3	

	if is_right then
        local lookRotation = -math.pi / 1.1
        targetCameraPosition = Vector3(math.sin(lookRotation) * len, math.cos(lookRotation) * len, cameraHeight)
        currentCameraFOV = 70
        currentCameraRoll = 0					
    elseif is_left then
        local lookRotation = math.pi / 1.1
        targetCameraPosition = Vector3(math.sin(lookRotation) * len, math.cos(lookRotation) * len, cameraHeight)
        currentCameraFOV = 70
        currentCameraRoll = 0				
    end	

	currentCameraPosition = currentCameraPosition + (targetCameraPosition - currentCameraPosition) * deltaTime * 5
	currentLookOffset = currentLookOffset + (targetLookOffset - currentLookOffset) * deltaTime * 4

	setCameraMatrix(
		localPlayer.vehicle.matrix:transformPosition( currentCameraPosition ), 
		localPlayer.vehicle.matrix:transformPosition( currentLookOffset ), 
		currentCameraRoll, 
		currentCameraFOV
	)
end

function SetDriftCameraState_handler( state )
    removeEventHandler( "onClientPreRender", root, RenderCamera )

    if state then
        addEventHandler( "onClientPreRender", root, RenderCamera )
    else
        setCameraTarget( localPlayer )
    end
end
addEvent( "SetDriftCameraState", true )
addEventHandler( "SetDriftCameraState", root, SetDriftCameraState_handler )