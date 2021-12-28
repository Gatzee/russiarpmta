loadstring(exports.interfacer:extend("Interfacer"))()
Extend("ShUtils")

CAMCONF_DEFAULT = {
	m_aCenterDefault = {0, 0, 5},
	m_fDistanceDefault = 6,
	m_fDistanceMax = 6,
	m_fDistanceMin = 4,
	m_fDistance	= 6,

	m_fHeightDefault = 2,
	m_fHeight = 2,
	m_fHeightCurrent = 2,

	m_bRotationXChanged = false,
	m_fRotationX = 0,
	m_fRotationY = -0.7,
	m_bRotationFrozen = false,
	m_fRotationXSpeed = 0,
	m_fRotationYSpeed = 0,
	m_fAutoRotationSpeed = 0.003,
	m_fRotationXSpeedMul = 0.8,
	m_fRotationYSpeedMul = 0.8,

	m_fZoomValue = 0.5,
	m_fZoomMul = 0.15,

	m_fMousePosXPrev = 0,
	m_bMouseXPrevState = false,
	m_bMouseYPrevState = false,

	m_bControlEnabled = true,

	m_fFovDefault = 70,
	m_fFov = 70,
	m_fRoll = 0,

	m_fMovementSpeed = 0.04,
	m_fRotationTarget = 45,
	m_fHeightTarget	= 2,
	m_fDistanceTarget = 6,
	m_fFovTarget = 70,

	m_fCenterTargetX = 0,
	m_fCenterTargetY = 0,
	m_fCenterTargetZ = 0,
}

function onClientElementDataChange_handler( key )
	if key ~= "cam_target" then return end

	unbindKey("mouse_wheel_up", "down", OnZoomIn)
	unbindKey("mouse_wheel_down", "down", OnZoomOut)
	removeEventHandler( "onClientRender", root, RenderCamera, false, "low-1" )

	if localPlayer:getData( "cam_target" ) then
		addEventHandler( "onClientRender", root, RenderCamera, false, "low-1" )
		bindKey("mouse_wheel_up", "down", OnZoomIn)
		bindKey("mouse_wheel_down", "down", OnZoomOut)
	end
end
addEventHandler( "onClientElementDataChange", localPlayer, onClientElementDataChange_handler )

function RenderCamera()
	local target = localPlayer:getData("cam_target")
	if not target then
		CAMCONF = nil
		return
	end
	if not CAMCONF then
		CAMCONF = table.copy(CAMCONF_DEFAULT)
	end


	local is_target_table = type(target) == "table"

	DISTANCE = is_target_table and target[4] or 1

	local vecPosition = type(target) == "table" and Vector3(unpack(target)) or isElement( target ) and target.position
	if not vecPosition then return end

	local fCamX, fCamY, fCamZ = vecPosition.x, vecPosition.y, vecPosition.z
	local fDistanceX
	fDistanceX = math.cos(CAMCONF.m_fRotationX) * CAMCONF.m_fDistance * DISTANCE;
	fDistanceY = math.sin(CAMCONF.m_fRotationX) * CAMCONF.m_fDistance * DISTANCE;
	fDistanceZ = -math.sin(CAMCONF.m_fRotationY) * CAMCONF.m_fDistance/2 * DISTANCE;
	setCameraMatrix(
		fCamX + fDistanceX,
		fCamY + fDistanceY,
		math.max(fCamZ + fDistanceZ, fCamZ),
		fCamX, fCamY, fCamZ,
		CAMCONF.m_fRoll,
		CAMCONF.m_fFov
	)
	CAMCONF.m_fRotationXSpeed 	= CAMCONF.m_fRotationXSpeed * CAMCONF.m_fRotationXSpeedMul;
	CAMCONF.m_fRotationYSpeed 	= CAMCONF.m_fRotationYSpeed * CAMCONF.m_fRotationYSpeedMul;

	CAMCONF.m_fTargetDistance 	= CAMCONF.m_fTargetDistance or CAMCONF.m_fDistanceDefault
	CAMCONF.m_fDistance 		= CAMCONF.m_fDistance + ( CAMCONF.m_fTargetDistance - CAMCONF.m_fDistance ) * CAMCONF.m_fZoomMul;

	if CAMCONF.m_bRotationFrozen then
		CAMCONF.m_fRotationXSpeed = 0;
		CAMCONF.m_fRotationYSpeed = 0;
	else
		CAMCONF.m_fRotationX = CAMCONF.m_fRotationX + CAMCONF.m_fRotationXSpeed;
		CAMCONF.m_fRotationY = math.max(math.min(CAMCONF.m_fRotationY + CAMCONF.m_fRotationYSpeed, 1), -1)
		if not CAMCONF.m_bRotationXChanged then
			CAMCONF.m_fRotationX = CAMCONF.m_fRotationX + CAMCONF.m_fAutoRotationSpeed;
		end
		if isCursorShowing() then
			local bIsMouseKey = getKeyState("mouse2")
			if CAMCONF.m_bControlEnabled and not localPlayer:getData("mouse_blocked") then
				local fMousePosX, fMousePosY = getCursorPosition()
				if bIsMouseKey and CAMCONF.m_bMouseXPrevState then
					CAMCONF.m_fRotationXSpeed 	= CAMCONF.m_fRotationXSpeed - ( fMousePosX - CAMCONF.m_fMousePosXPrev );
					CAMCONF.m_fMousePosXPrev 	= fMousePosX;
					CAMCONF.m_bMouseXPrevState 	= true;
				elseif bIsMouseKey and not CAMCONF.m_bMouseXPrevState then
					CAMCONF.m_fMousePosXPrev 	= fMousePosX;
					CAMCONF.m_bMouseXPrevState 	= true;
					CAMCONF.m_bRotationXChanged = true;
				end

				if bIsMouseKey and CAMCONF.m_bMouseYPrevState then
					CAMCONF.m_fRotationYSpeed 	= CAMCONF.m_fRotationYSpeed - ( fMousePosY - CAMCONF.m_fMousePosYPrev );
					CAMCONF.m_fMousePosYPrev 	= fMousePosY;
					CAMCONF.m_bMouseYPrevState 	= true;
				elseif bIsMouseKey and not CAMCONF.m_bMouseYPrevState then
					CAMCONF.m_fMousePosYPrev 	= fMousePosY;
					CAMCONF.m_bMouseYPrevState 	= true;
					CAMCONF.m_bRotationYChanged = true;
				end
			end
			if not bIsMouseKey then
				CAMCONF.m_bMouseXPrevState = false;
				CAMCONF.m_bMouseYPrevState = false;
			end
		end
	end
end

function SetZoomIn()
	CAMCONF.m_fTargetDistance = math.max(CAMCONF.m_fTargetDistance - CAMCONF.m_fZoomValue, CAMCONF.m_fDistanceMin)
end

function SetZoomOut()
	CAMCONF.m_fTargetDistance = math.min(CAMCONF.m_fTargetDistance + CAMCONF.m_fZoomValue, CAMCONF.m_fDistanceMax)
end

function OnZoomIn()
	if not CAMCONF then return end
	if exports.nrp_ib:ibGetHoveredElement( ) then return end
	SetZoomIn()
end

function OnZoomOut()
	if not CAMCONF then return end
	if exports.nrp_ib:ibGetHoveredElement( ) then return end
	SetZoomOut()
end
