local curDrawCharacter = {}

local scx, scy = guiGetScreenSize ()
local fov = ({getCameraMatrix()})[8]

function createObjectPreview(element,rotX,rotY,rotZ,projPosX,projPosY,projSizeX,projSizeY,isRelative)
	 if isElement(curDrawCharacter.element) then return end

	local posX,posY,posZ = getCameraMatrix()

	if isRelative == false then
		projPosX, projPosY, projSizeX, projSizeY = projPosX / scx, projPosY / scy, projSizeX / scx, projSizeY / scy
	end

    curDrawCharacter = {
		element = element,
		alpha = 255,
		elementRadius = 0,
		elementPosition = {posX, posY, posZ},
		elementRotation = {rotX, rotY, rotZ},
		elementRotationOffsets = {0, 0, 0},
		elementPositionOffsets = {0, 0, 0},
		zDistanceSpread = -1.0,
		projection = {projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative},
		shader = nil
	}

	setElementAlpha(curDrawCharacter.element, 254)
	setElementStreamable(curDrawCharacter.element, false)
	setElementFrozen(curDrawCharacter.element, true)
	setElementCollisionsEnabled(curDrawCharacter.element, false)

	curDrawCharacter.elementRadius = math.max(returnMaxValue({getElementBoundingBox(curDrawCharacter.element)}), 1)

	local tempRadius = getElementRadius(curDrawCharacter.element)
	if tempRadius > curDrawCharacter.elementRadius then curDrawCharacter.elementRadius = tempRadius end

	curDrawCharacter.shader = dxCreateShader("fx/fx_pre_ped_noMRT.fx", 0, 0, false, "all")
	
	if not curDrawCharacter.shader then return end
	
	dxSetShaderValue(curDrawCharacter.shader, "sFov", math.rad(fov))
	dxSetShaderValue(curDrawCharacter.shader, "sAspect", (scy / scx))
	engineApplyShaderToWorldTexture (curDrawCharacter.shader, "*", curDrawCharacter.element)

	addEventHandler("onClientPreRender", root, onPreRender, true, "low-5")
end

function destroyObjectPreview()
	removeEventHandler("onClientPreRender", root, onPreRender)

	if isElement(curDrawCharacter.element) and curDrawCharacter.shader then
		engineRemoveShaderFromWorldTexture(curDrawCharacter.shader, "*", curDrawCharacter.element)
		destroyElement(curDrawCharacter.shader)
		curDrawCharacter.shader = nil
	end

	curDrawCharacter = {}
end

function onPreRender()
	-- Check if element exists
    if not isElement(curDrawCharacter.element) then return end

	-- Calculate position and size of the projector
	local projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative = unpack(curDrawCharacter.projection)
	projSizeX, projSizeY = projSizeX / 2, projSizeY / 2
	projPosX, projPosY = projPosX + projSizeX - 0.5, -(projPosY + projSizeY - 0.5)
	projPosX, projPosY = 2 * projPosX, 2 * projPosY
	
	-- Calculate position and rotation of the element
	local cameraMatrix = getElementMatrix(getCamera())
	local rotationMatrix = createElementMatrix({0,0,0}, curDrawCharacter.elementRotation)
	local positionMatrix = createElementMatrix(curDrawCharacter.elementRotationOffsets, {0,0,0})
	local transformMatrix = matrixMultiply(positionMatrix, rotationMatrix)
		
	local multipliedMatrix = matrixMultiply(transformMatrix, cameraMatrix)
	local distTemp = curDrawCharacter.zDistanceSpread

	local posTemp = curDrawCharacter.elementPositionOffsets
	local posX, posY, posZ = getPositionFromMatrixOffset(cameraMatrix, {posTemp[1], 1.6 * curDrawCharacter.elementRadius + distTemp + posTemp[2], posTemp[3]})
	local rotX, rotY, rotZ = getEulerAnglesFromMatrix(multipliedMatrix)

	local velX, velY, velZ = getCamVelocity()
	local vecLen = math.sqrt(math.pow(velX, 2) + math.pow(velY, 2) + math.pow(velZ, 2))
	local camCom = {cameraMatrix[2][1] * vecLen, cameraMatrix[2][2] * vecLen, cameraMatrix[2][3] * vecLen}
	velX, velY, velZ =	(velX + camCom[1]), (velY + camCom[2]), (velZ + camCom[3])
	setElementPosition(curDrawCharacter.element, posX + velX, posY + velY, posZ + velZ)
	setElementRotation(curDrawCharacter.element, rotX, rotY, rotZ, "ZXY")
	
	-- Set shader values
	if curDrawCharacter.shader then
		dxSetShaderValue(curDrawCharacter.shader, "sCameraPosition", cameraMatrix[4])
		dxSetShaderValue(curDrawCharacter.shader, "sCameraForward", cameraMatrix[2])
		dxSetShaderValue(curDrawCharacter.shader, "sCameraUp", cameraMatrix[3])
		dxSetShaderValue(curDrawCharacter.shader, "sElementOffset", 0, -distTemp, 0)
		dxSetShaderValue(curDrawCharacter.shader, "sWorldOffset", -velX, -velY, -velZ)
		dxSetShaderValue(curDrawCharacter.shader, "sMoveObject2D", projPosX, projPosY)
		dxSetShaderValue(curDrawCharacter.shader, "sScaleObject2D", 2 * math.min(projSizeX, projSizeY), 2 * math.min(projSizeX, projSizeY))
		dxSetShaderValue(curDrawCharacter.shader, "sProjZMult", 2)
	end
end

local getLastTick = getTickCount() local lastCamVelocity  = {0, 0, 0}
local currentCamPos = {0, 0, 0} local lastCamPos = {0, 0, 0}

function getCamVelocity()
	if getTickCount() - getLastTick  < 100 then 
		return lastCamVelocity[1], lastCamVelocity[2], lastCamVelocity[3] 
	end
	local currentCamPos = {getElementPosition(getCamera())}
	lastCamVelocity = {currentCamPos[1] - lastCamPos[1], currentCamPos[2] - lastCamPos[2], currentCamPos[3] - lastCamPos[3]}
	lastCamPos = {currentCamPos[1], currentCamPos[2], currentCamPos[3]}
	return lastCamVelocity[1], lastCamVelocity[2], lastCamVelocity[3]
end