local speed = 0
local strafespeed = 0
local rotX, rotY = 0, 0
local velocityX, velocityY, velocityZ

local options = 
{
	invertMouseLook = false,
	normalMaxSpeed = 0.07,
	slowMaxSpeed = 0.03,
	smoothMovement = true,
	acceleration = 0.25,
	decceleration = 0.15,
	mouseSensitivity = 0.2,
	key_forward = "w",
	key_backward = "s",
	key_left = "a",
    key_right = "d",
    key_rot_l = "q",
	key_rot_r = "e",
	key_slowMove = "lalt",
	camera_roll = 0,
}

local prevX, prevY, prevZ = nil, nil, nil
local center_position = nil
local CONST_MAX_DISTANCE = 20
local mouseFrameDelay = 0

function getCameraRotation ()
    local px, py, pz, lx, ly, lz = getCameraMatrix()
    return math.atan2( (lx - px),(ly - py) ), math.atan2( lz - pz, getDistanceBetweenPoints2D( lx, ly, px, py ) )
end

function freecamFrame()
	local mspeed = options.normalMaxSpeed
	if getKeyState ( options.key_slowMove ) then
		mspeed = options.slowMaxSpeed
	end
	
	if options.smoothMovement then
		local acceleration = options.acceleration
		local decceleration = options.decceleration
	    local speedKeyPressed = false
	    if getKeyState ( options.key_forward ) then
			speed = speed + acceleration 
	        speedKeyPressed = true
		end
		
		if getKeyState ( options.key_backward ) then
			speed = speed - acceleration 
	        speedKeyPressed = true
        end
        
	    local strafeSpeedKeyPressed = false
		if getKeyState ( options.key_left ) then
	        if strafespeed > 0 then
	            strafespeed = 0
	        end
	        strafespeed = strafespeed - acceleration / 2
	        strafeSpeedKeyPressed = true
        end
        
		if getKeyState ( options.key_right ) then
	        if strafespeed < 0 then
	            strafespeed = 0
	        end
	        strafespeed = strafespeed + acceleration / 2
	        strafeSpeedKeyPressed = true
		end 

        if getKeyState ( options.key_rot_r ) then
			options.camera_roll = options.camera_roll - 1
        elseif getKeyState ( options.key_rot_l ) then
			options.camera_roll = options.camera_roll + 1
        end 

	    if speedKeyPressed ~= true then
			if speed > 0 then
				speed = speed - decceleration
			elseif speed < 0 then
				speed = speed + decceleration
			end
        end
        
	    if strafeSpeedKeyPressed ~= true then
			if strafespeed > 0 then
				strafespeed = strafespeed - decceleration
			elseif strafespeed < 0 then
				strafespeed = strafespeed + decceleration
			end
        end
        
	    if speed > -decceleration and speed < decceleration then
	        speed = 0
	    elseif speed > mspeed then
	        speed = mspeed
	    elseif speed < -mspeed then
	        speed = -mspeed
        end
        
	    if strafespeed > -(acceleration / 2) and strafespeed < (acceleration / 2) then
	        strafespeed = 0
	    elseif strafespeed > mspeed then
	        strafespeed = mspeed
	    elseif strafespeed < -mspeed then
	        strafespeed = -mspeed
	    end
	else
		speed = 0
		strafespeed = 0
		if getKeyState ( options.key_forward )  then speed = mspeed end
		if getKeyState ( options.key_backward ) then speed = -mspeed end
		if getKeyState ( options.key_left )     then strafespeed = mspeed end
		if getKeyState ( options.key_right )    then strafespeed = -mspeed end
	end
	
	local camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ = getCameraMatrix()
	if not options.frozen then

		local cameraAngleX, cameraAngleY = rotX, rotY

		local freeModeAngleZ = math.sin( cameraAngleY )
    	local freeModeAngleY = math.cos( cameraAngleY ) * math.cos( cameraAngleX )
    	local freeModeAngleX = math.cos( cameraAngleY ) * math.sin( cameraAngleX )

    	local camAngleX = camPosX - camPosX + freeModeAngleX * 100
    	local camAngleY = camPosY - camPosY + freeModeAngleY * 100
    	local camAngleZ = 0
		
    	local angleLength = math.sqrt( camAngleX * camAngleX + camAngleY * camAngleY + camAngleZ * camAngleZ )
    	local camNormalizedAngleX = camAngleX / angleLength
    	local camNormalizedAngleY = camAngleY / angleLength
    	local camNormalizedAngleZ = 0
		
    	local normalAngleX, normalAngleY, normalAngleZ = 0, 0, 1
    	local normalX = ( camNormalizedAngleY * normalAngleZ - camNormalizedAngleZ * normalAngleY )
    	local normalY = ( camNormalizedAngleZ * normalAngleX - camNormalizedAngleX * normalAngleZ )
    	local normalZ = ( camNormalizedAngleX * normalAngleY - camNormalizedAngleY * normalAngleX )
		
    	camPosX = camPosX + normalX * strafespeed + freeModeAngleX * speed
    	camPosY = camPosY + normalY * strafespeed + freeModeAngleY * speed
    	camPosZ = camPosZ + normalZ * strafespeed + freeModeAngleZ * speed

    	velocityX = (freeModeAngleX * speed) + (normalX * strafespeed)
		velocityY = (freeModeAngleY * speed) + (normalY * strafespeed)
		velocityZ = (freeModeAngleZ * speed) + (normalZ * strafespeed)
		
		local hit = processLineOfSight( center_position.x, center_position.y, center_position.z + 1, camPosX, camPosY, camPosZ, true, false, false, true )
		if getDistanceBetweenPoints3D( camPosX, camPosY, camPosZ, center_position.x, center_position.y, center_position.z ) > CONST_MAX_DISTANCE or hit then
			return
		end

		camTargetX = camPosX + freeModeAngleX * 100
    	camTargetY = camPosY + freeModeAngleY * 100
		camTargetZ = camPosZ + freeModeAngleZ * 100

		prevX, prevY, prevZ = camPosX, camPosY, camPosZ
	end

    setCameraMatrix( prevX, prevY, prevZ, camTargetX, camTargetY, camTargetZ, options.camera_roll )
    prev_speed = speed
end

function matrixMultiply(mat1, mat2)
	local matOut = {}
	for i = 1,#mat1 do
		matOut[i] = {}
		for j = 1,#mat2[1] do
			local num = mat1[i][1] * mat2[1][j]
			for n = 2,#mat1[1] do
				num = num + mat1[i][n] * mat2[n][j]
			end
			matOut[i][j] = num
		end
	end
	return matOut
end

--[[
		local sinn =
	{ 
		x = math.sin( Camera.rotation.x ),
		y = math.sin( Camera.rotation.y ),
		z = math.sin( Camera.rotation.z ),
	}

	local coss =
	{
		x = math.cos( Camera.rotation.x ),
		y = math.cos( Camera.rotation.y ),
		z = math.cos( Camera.rotation.z ),
	}

	local matrix_x = 
	{
		{ coss.x,  0.0, sinn.x }, 
		{ 0.0,     1.0, 0.0    },
		{ -sinn.x, 0.0, coss.x },
	}

	local matrix_y = 
	{
		{ 1.0, 0.0,    0.0     },
		{ 0.0, coss.y, -sinn.y },
		{ 0.0, sinn.y, coss.y  }
	}

	local matrix_z = 
	{
		{ coss.z, -sinn.z, 0.0 },
		{ sinn.z, coss.z,  0.0 },
		{ 0.0,    0.0,     1.0 },
	}

	local delta_rotation_relative = matrixMultiply( matrix_y, matrixMultiply( matrix_x, Vector() ) )
]]

function freecamMouse( cX, cY, aX, aY )
	if options.frozen then return end

    if isCursorShowing() or isMTAWindowActive() then
		mouseFrameDelay = 5
		return
	elseif mouseFrameDelay > 0 then
		mouseFrameDelay = mouseFrameDelay - 1
		return
	end
    
    aX = aX - _SCREEN_X / 2 
    aY = aY - _SCREEN_Y / 2
    
    if options.invertMouseLook then
		aY = -aY
	end
    
    rotX = rotX + aX * options.mouseSensitivity * 0.01745
    rotY = rotY - aY * options.mouseSensitivity * 0.01745
    
    local PI = math.pi
	if rotX > PI then
		rotX = rotX - 2 * PI
	elseif rotX < -PI then
		rotX = rotX + 2 * PI
	end
    
    if rotY > PI then
		rotY = rotY - 2 * PI
	elseif rotY < -PI then
		rotY = rotY + 2 * PI
	end
    
    if rotY < -PI / 2.05 then
       rotY = -PI / 2.05
    elseif rotY > PI / 2.05 then
        rotY = PI / 2.05
    end
end

function getFreecamVelocity()
	return velocityX, velocityY, velocityZ
end

function setFreecamEnabled( player_position )
    if isFreecamEnabled() then return end
	
	options.camera_roll = 0
	center_position = player_position

	rotX,rotY = getCameraRotation()
	
	local x, y, z = getCameraMatrix()
	prevX, prevY, prevZ = x, y, z
	setCameraMatrix( x, y, z )
    freecam_enabled = true	

    addEventHandler( "onClientRender", root, freecamFrame )
	addEventHandler( "onClientCursorMove", root, freecamMouse )

    return true
end

function setFreecamFrozen( frozen_state )
	options.frozen = frozen_state
end

function setFreecamDisabled()
	if not isFreecamEnabled() then return end
    
    velocityX, velocityY, velocityZ = 0, 0, 0
	speed = 0
	strafespeed = 0
    freecam_enabled = false

	setCameraTarget( localPlayer )
    removeEventHandler( "onClientRender", root, freecamFrame )
	removeEventHandler( "onClientCursorMove", root, freecamMouse )
	
    return true
end

function isFreecamEnabled()
	return freecam_enabled
end

function getFreecamOption( theOption, value )
	return options[ theOption ]
end

function setFreecamOption( theOption, value )
	if options[ theOption ] ~= nil then
		options[ theOption ] = value
		return true
    end
    return false
end