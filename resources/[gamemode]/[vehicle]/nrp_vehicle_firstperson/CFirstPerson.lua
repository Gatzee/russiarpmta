loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ShUtils" )
Extend( "CVehicle" )
Extend( "ShVehicleConfig" )

--[[local camera_changed_file_name = "camera.nrp"
if not fileExists( camera_changed_file_name ) then
	setCameraViewMode( 1 )
	fileClose( fileCreate( camera_changed_file_name ) )
end]]

addEvent( "onClientFirstPersonStateChange" )

setCameraClip( true, true )

local bFirstPersonEnabled = false
local bFirstPersonWasEnabled = false

local bPhoteMode = false
local bFrozenRotation = false
local scX, scY = guiGetScreenSize ()
local save_cursor_x, save_cursor_y = nil, nil

local pAdditionalRotation = { 0, 0, 0 }

local sSteeringWheelName = "rpb_sw"
local iLastSteerPush = 0
local fLastSteerLimit = 0
local fSteerLimit = 0
local sSpeedometerName = "rpb_sm"
local sFuelName = "rpb_sf"
local sTachometerName = "rpb_so"

local enter = false

local DASHBOARD_FACTORS = {
	[ 475 ] = 0.66,
	[ 602 ] = 0.45,
	[ 558 ] = 0.48,
	[ 559 ] = 0.45,
	[ 506 ] = 0.8,
	[ 402 ] = 0.4,
    [ 400 ] = 0.87,
    [ 404 ] = 0.375,
    [ 424 ] = 0.85,
	[ 426 ] = 0.7, -- do not see
	[ 438 ] = 0.62,
	[ 467 ] = 0.67,
	[ 471 ] = 0.55,
	[ 490 ] = 0.65,
	[ 492 ] = 1, -- do not see
	[ 516 ] = 1, -- ?
	[ 517 ] = 0.32,
	[ 540 ] = 0.48,
	[ 543 ] = 0.7,
	[ 566 ] = 0.8,
	[ 571 ] = 1, -- ?
	[ 585 ] = 1, -- ?
	[ 405 ] = 0.57,
	[ 458 ] = 0.57,
	[ 529 ] = 0.65,
	[ 491 ] = 0.49,
	[ 475 ] = 1,
	[ 546 ] = 0.6,
	[ 579 ] = 0.65,
	[ 587 ] = 0.425,
	[ 412 ] = 0.54,
	[ 439 ] = 0.4,
	[ 445 ] = 0.7,
	[ 562 ] = 0.38,
	[ 567 ] = 0.53,
	[ 589 ] = 0.41,
	[ 600 ] = 0.65,
	[ 496 ] = 0.35,
	[ 535 ] = 0.25,
	[ 541 ] = 0.55,
	[ 533 ] = 0.62,
	[ 402 ] = 0.4,
	[ 409 ] = 0.5,
	[ 550 ] = 0.6,
	[ 541 ] = 0.55,
	[ 402 ] = 0.4,
}

local DASHBOARD_SPEEDOMETER_LIMITS = {
}

local ADDITIONAL_OFFSETS = {
	[ 445 ] = { -0.1, -0.2, -0.1 }, -- Крузак
	[ 404 ] = { 0, 0, 0 },--   Ваз 2101 +
	[ 585 ] = { 0, 0, 0 },-- 	Ваз 2106 +
	[ 492 ] = { 0, -0.15, -0.1 },--  	Ваз 2107 +
	[ 426 ] = { 0, -0.25, 0 },-- 	Ваз 2114 +
	[ 517 ] = { 0.06, 0, 0 },-- 	Ока +
	[ 516 ] = { 0, 0, 0 },--	Ваз 2109 +
	[ 540 ] = { 0, 0, 0 },--	Приора +
	[ 467 ] = { 0, 0, 0 },--	Волга +
	[ 400 ] = { -0.07, 0, 0 },--	UAZ Hunter +
	[ 436 ] = { 0, -0.4, 0.2 },--	Honda Civic +
	[ 529 ] = { 0, -0.2, 0 },--	Golf 1.6 AT GT +
	[ 420 ] = { 0.07, -0.1, 0 },--	Toyota Camry +
	[ 405 ] = { 0, -0.2, 0 },--	Mitsubishi lancer Evolution X +
	[ 546 ] = { 0, 0, -0.14 },--	Honda Accord +
	[ 459 ] = { -0.05, -0.25, 0.015 }, -- Ford Transit
	[ 562 ] = { 0.01, 0, -0.05 },--	Merc SL65 5.5 AT  / 6.0 AT +
	[ 551 ] = { 0, -0.15, 0 },--	Lexus LX  +
	[ 603 ] = { 0, 0, 0 },--	Mercedes C63AMG 6.3AT / 6.8AT  +
	[ 567 ] = { 0, 0, 0 },--	BMW 5 (E60) +
	[ 549 ] = { 0, 0, 0 },--	Mustang +
	[ 411 ] = { 0, 0.8, 0.2 },--	Audi R8 +
	[ 415 ] = { 0, 0.2, 0.03 },--	Huracan +
	[ 451 ] = { 0.05, -0.2, 0 },--	Ferrari 458 +
	[ 527 ] = { -0.05, -0.3, 0 },--	Aventodor +
	[ 579 ] = { -0.05, -0.2, 0 },--		Mercedes G 500 \  g65 amg +
	[ 507 ] = { 0.01, -0.1, 0}, --		S560
	[ 482 ] = { -0.17, 0, 0}, --		ГАЗ 3221
	[ 498 ] = { -0.1, -0.2, 0}, --		Mercedes Sprinter
	[ 437 ] = { -0.4, -0.2, -0.2 }, -- Bus
	[ 526 ] = { 0, 0.2, 0.12 }, -- Chiron
	[ 580 ] = { 0, 0, -0.025 }, -- Panamera
	[ 458 ] = { 0, 0, 0.05 }, -- G63 6x6
	[ 468 ] = { 0.35, 0, 1 }, -- Scooter
	[ 506 ] = { 0.05, 0.45, 0.3 }, -- Nissan GTR
	[ 554 ] = { -0.13, 0.05, 0.22 }, -- Ford Raptor
	[ 596 ] = { -0.02, -0.1, 0.03 }, -- Lamborghini Urus
	[ 477 ] = { -0.02, -0.1, 0.04 }, -- Toyota Corolla
	[ 560 ] = { 0, -0.2, 0.2 }, -- Subaru Impreza
	[ 455 ] = { -0.2, 3.8, 1.2 }, -- MAN
	[ 515 ] = { -0.25, 4, 1.7 }, -- Mercedes
	[ 490 ] = { -0.07, 0, 0 }, -- Patriot
	[ 421 ] = { -0.04, 0.1, -0.15}, -- X5M
	[ 518 ] = { 0, -0.05, 0.07 }, -- Camaro
	[ 412 ] = { 0, -0.1, 0.05 }, -- Challenger SRT8
	[ 479 ] = { -0.04, 0.8, 0.735 }, -- GL
	[ 470 ] = { -0.04, -0.17, 0.05 }, -- Cayenne
	[ 589 ] = { 0, 0, 0.08 }, -- C63s
	[ 545 ] = { 0.1, -0.15, 0.05 }, -- McLaren P1
	[ 496 ] = { 0.06, -0.15, 0.04 }, -- Agera
	[ 401 ] = { -0.06, 0.07, -0.1 }, -- i8
	[ 602 ] = { -0.07, -0.25, 0.05 }, -- AMG GT
	[ 471 ] = { 0.4, 0.4, 0.85 }, -- Квадроцикл
	[ 424 ] = { 0.15, 0, 0.6 }, -- Багги
	[ 575 ] = { 0, 0.4, 0.12 }, -- Делореан
	[ 520 ] = { 0.4, 5, 0.8 }, -- Делореан
	[ 541 ] = { -0.025, -0.4, 0.07 }, -- Gallardo
	[ 576 ] = { -0.01, -0.05, 0.02 }, -- GTO
	[ 534 ] = { -0.01, -0.15, -0.01 }, -- DB11
	[ 535 ] = { 0.02, -0.15, 0 }, -- 911 Turbo S
	[ 429 ] = { -0.05, -0.2, 0.03 }, -- Continental GT
	[ 410 ] = { -0.035, 0.35, 0.2 }, -- Astra J
	[ 536 ] = { -0.035, -0.35, 0.02 }, -- Impala
	[ 439 ] = { -0.035, -0.15, 0.02 }, -- M4
	[ 571 ] = { 0.38, 0.35, 0.55 },
	[ 573 ] = { -0.4, 0, 0.1 },
	[ 453 ] = { 2.5, -0.2, 3.4 },
	[ 454 ] = { -0.8, -1.1, 3.9 },
	[ 472 ] = { 1.2, 1, 1.5 },
	[ 473 ] = { 0.4, 1, 1.7 },
	[ 484 ] = { 0.6, 5.3, 3.6 },
	[ 493 ] = { -0.2, 2.4, 2.33 },
	[ 446 ] = { -0.1, 1.8, 2.3 },
	[ 581 ] = { 0.4, 0.7, 0.8 },
	[ 521 ] = { 0.4, 0.7, 0.8 },
	[ 462 ] = { 0.4, 0.4, 1.1 },
	[ 448 ] = { 0.4, 0.3, 1.1 },
	[ 586 ] = { 0.4, 0.05, 1.1 },
	[ 463 ] = { 0.4, 0.4, 1.1 },
	[ 522 ] = { 0.4, 0.55, 0.8 },
	[ 461 ] = { 0.4, 0.7, 0.8 },
	[ 408 ] = { -0.47, -0.6, 0 },
	[ 572 ] = { 0.4, 0, 1.2 },
	[ 480 ] = { 0.08, 0.1, -0.05 },
	[ 402 ] = { 0.03, -0.2, 0.05 },
	[ 409 ] = { 0, -0.12, -0.07 },
	[ 502 ] = { 0.07, 0, -0.05 },
	[ 503 ] = { -0.02, -0.17, -0.02 },
	[ 533 ] = { 0.01, 0, 0 },
	[ 542 ] = { 0, -0.1, 0 },
	[ 550 ] = { 0, -0.05, -0.02 },
	[ 555 ] = { 0, 0, -0.07 },
	[ 558 ] = { 0.08, 0.01, -0.02 },
	[ 582 ] = { -0.19, 0, -0.02 },
	[ 474 ] = { 0.015, 0.01, 0.02 },
	[ 494 ] = { 0.05, -0.15, 0.01 },
	[ 505 ] = { 0.01, -0.2, 0.02 },
	[ 559 ] = { 0.05, 0, 0.03 },
	[ 587 ] = { 0, -0.05, 0, -0.05 },
	[ 438 ] = { 0, 0, 0.04 },
	[ 418 ] = { -0.1, -0.15, 0 },
	[ 456 ] = { 0, -0.1, 0 },
	[ 416 ] = { 0, -0.25, 0 },
	[ 433 ] = { -0.1, -0.25, 0.1 },
	[ 530 ] = { 0.39, -0.21, 1.0 },
	[ 524 ] = { -0.385, -0.15, 0 },
	[ 508 ] = { -0.08, -0.25, 0 },
	[ 432 ] = { 0, 0, 1.7 },
	[ 413 ] = { -0.3, 0.75, 0.8 },
	[ 439 ] = { 0.05, 0, -0.02, -0.03 },
	[ 499 ] = { -0.1, 0.18, 0.1 }, -- Газель курьера
}

local pOldWindowsColor

local camera = createObject(1338,0,0,0)
setElementCollisionsEnabled( camera, false )
setObjectScale( camera, 0 )
setElementAlpha( camera, 0 )

local rpmValue = 0

Vehicle.GetVehicleRPM = function( self )
	local vehicle_rpm = 0
	if not getVehicleEngineState( self ) then return vehicle_rpm end

	local speed = (Vector3(getElementVelocity(self)) * 111.84681456).length
	local gear = getVehicleCurrentGear( self )
	local gear_coef = gear > 0 and gear or 1
	local cruise_state = localPlayer:getData( "cruise_state" )

	vehicle_rpm = math.floor( (speed / gear_coef ) * 180 + 0.5 )
	vehicle_rpm = ( vehicle_rpm + ( self.engineState and 1500 or 0 ) ) / ( cruise_state and 6800 or 9500 )

	return vehicle_rpm
end

function UpdateCamera()
	if bPhoteMode then return end

	local veh = getPedOccupiedVehicle( localPlayer )
	if veh then
		local pCamera = getCamera()

		if veh.controller ~= localPlayer then
			local bx, by, bz = getPedBonePosition( localPlayer, 8 )
			local cx, cy, cz = bx, by, bz + (ADDITIONAL_OFFSETS[ veh.model ] and ADDITIONAL_OFFSETS[ veh.model ][ 4 ] or 0.1)
			local vrx, vry, vrz = getElementRotation( veh )
			local crx, cry, crz = vrx+pAdditionalRotation[1]-10, vry+pAdditionalRotation[2], vrz+pAdditionalRotation[3]
			setElementPosition( pCamera, cx, cy, cz )
			if not bFrozenRotation then setElementRotation( pCamera, crx, cry, crz ) end
		else
			-- Камера

			local vrx, vry, vrz = getElementRotation( veh )
			local crx, cry, crz = vrx+pAdditionalRotation[1], vry+pAdditionalRotation[2], vrz+pAdditionalRotation[3]

			if enter then
				local wx, wy, wz = 0,0,0
				if getVehicleComponents( veh )[ "windscreen_dummy" ] then
					wx, wy, wz = getVehicleComponentPosition( veh, "windscreen_dummy" )
				end
				local pOffset = ADDITIONAL_OFFSETS[ veh.model ] or { 0, 0, 0 }
				local ox, oy, oz = wx - 0.4 + pOffset[1], wy - 0.7 + pOffset[2], wz + pOffset[3]
				setElementDimension( camera, localPlayer.dimension )
				attachElements( camera, veh, ox, oy, oz )
				setElementCollisionsEnabled( camera, false )
			end

			setElementPosition( pCamera, getElementPosition( camera ) )
			if not bFrozenRotation then setElementRotation( pCamera, crx-10, cry, crz ) end
		end

		camera.interior = veh.interior
		camera.dimension = veh.dimension
		if bFrozenRotation then return end
		
		if veh.controller == localPlayer then
			-- Руль
			local steer_rotation = interpolateBetween( fLastSteerLimit, 0, 0, fSteerLimit, 0, 0, (getTickCount()-iLastSteerPush) / 1000, "OutQuad" )
			setVehicleComponentRotation( veh, sSteeringWheelName, 0, steer_rotation or 0, 0 )

			local left_state = getControlState("vehicle_left")
			local right_state = getControlState( "vehicle_right")
			local changed = false

			if left_state and not right_state then
				fLastSteerLimit = steer_rotation
				iLastSteerPush = getTickCount()
				fSteerLimit = -280
				changed = true
			end
			if right_state and not left_state then
				fLastSteerLimit = steer_rotation
				iLastSteerPush = getTickCount()
				fSteerLimit = 280
				changed = true
			end

			if not left_state and not right_state and not changed then
				fLastSteerLimit = steer_rotation
				iLastSteerPush = getTickCount()
				fSteerLimit = 0
			end
		end

		-- Спидометр
		local speed_factor = DASHBOARD_FACTORS[veh.model] and DASHBOARD_FACTORS[veh.model] or 1
		local speedomoter_limit = DASHBOARD_SPEEDOMETER_LIMITS[veh.model] and DASHBOARD_SPEEDOMETER_LIMITS[veh.model] or 240
		local kmh = veh.velocity.length * 180 * speed_factor
		local speedometer_rotation = interpolateBetween( 0, 0, 0, speedomoter_limit, 0, 0, kmh / 200, "OutQuad" )
		setVehicleComponentRotation( veh, sSpeedometerName, 0, speedometer_rotation or 0, 0 )

		-- Топливо
		local fFuel = veh:GetFuel()/veh:GetMaxFuel()
		local fuel_rotation = interpolateBetween( 0, 0, 0, -80, 0, 0, fFuel, "OutQuad" )
		setVehicleComponentRotation( veh, sFuelName, 0, fuel_rotation or 0, 0 )

		-- Тахометр
		local rpm = veh:GetVehicleRPM( )

		if rpmValue < rpm then
			rpmValue = rpmValue + 0.02
			if rpmValue > rpm then rpmValue = rpm end
		elseif rpmValue > rpm then
			rpmValue = rpmValue - 0.02
			if rpmValue < rpm then rpmValue = rpm end
		end

		local tachometer_rotation = interpolateBetween( 0, 0, 0, 240, 0, 0, rpmValue, "InQuad" )
		setVehicleComponentRotation( veh, sTachometerName, 0, tachometer_rotation or 0, 0 )

		if not isCursorShowing() then return end

		local cx, cy = getCursorPosition()
		pAdditionalRotation[ 3 ] = interpolateBetween( 120, 90, 90, -150, -90, -90, cx, "Linear" )
		pAdditionalRotation[ 1 ] = interpolateBetween( 10, 0, 0, -30, 0, 0, cy, "Linear" )
	else
		ToggleFirstPerson( false )
	end
end

function ToggleFirstPerson( state )
	if isTimer( SHOW_CURSOR_TMR ) then killTimer( SHOW_CURSOR_TMR ) end

	if state then
		local pVehicle = getPedOccupiedVehicle( localPlayer )
		if not pVehicle then return end

		local no_fisrt = {
			helicopter = true;
			airplane = true;
		}

		local veh_model = pVehicle.model
		if no_fisrt[ pVehicle:GetSpecialType() ] or (VEHICLE_CONFIG[ veh_model ] and VEHICLE_CONFIG[ veh_model ].ignore_fp_camera) then return end
		
		local wx, wy, wz = 0,0,0
		if getVehicleComponents( pVehicle )["windscreen_dummy"] then
			wx,wy,wz = getVehicleComponentPosition( pVehicle, "windscreen_dummy" )
		end
		
		if pVehicle.controller == localPlayer then
			local pOffset = ADDITIONAL_OFFSETS[ pVehicle.model ] or { 0, 0, 0 }
			local ox, oy, oz = wx-0.4+pOffset[1], wy-0.7+pOffset[2], wz+pOffset[3]
			setElementDimension( camera, localPlayer.dimension )
			attachElements(camera, pVehicle, ox, oy, oz)
			setElementCollisionsEnabled( camera, false )
		end

		pOldWindowsColor = pVehicle:GetWindowsColor()

		if pOldWindowsColor then
			pVehicle:SetWindowsColor( pOldWindowsColor[1], pOldWindowsColor[2], pOldWindowsColor[3], 60 )
		end

		bFirstPersonEnabled = state
		setElementData( localPlayer, "bFirstPerson", state, false )

		pAdditionalRotation = { 0, 0, 0 }

		local scX, scY = guiGetScreenSize ()
		setCursorPosition( scX / 2.2, scY / 3.5 )

		local vrx, vry, vrz = getElementRotation( pVehicle )
		setElementRotation( getCamera(), vrx - 10, vry, vrz )

		localPlayer.alpha = 0
		removeEventHandler("onClientPreRender", root, UpdateCamera)
		addEventHandler("onClientPreRender", root, UpdateCamera)
		
		showCursor( true, false )

		local count_open_back = localPlayer:getData( "open_back" ) or 0
		setCursorAlpha( count_open_back > 0 and 255 or 0 )
		bFrozenRotation = count_open_back > 0 and true or false
		setNearClipDistance( 0.1 )
	else
		local pVehicle = getPedOccupiedVehicle( localPlayer )
		if pVehicle and pOldWindowsColor then
			pVehicle:SetWindowsColor(unpack(pOldWindowsColor))
		end
		removeEventHandler("onClientPreRender", root, UpdateCamera)
		setCameraTarget(localPlayer)
		showCursor( false, false )
		setCursorAlpha( 255 )

		localPlayer.alpha = 255
		bFirstPersonEnabled = state
		setElementData( localPlayer, "bFirstPerson", state, false )
		resetNearClipDistance( )
	end
	triggerEvent( "onClientFirstPersonStateChange", localPlayer, state )
	return true
end


local CAMERA_CAROUSELL = {
	[ 1 ] = 1,
	[ 2 ] = 2,
	[ 3 ] = "FP",
}
CURRENT_CAMERA = 0
function SwitchCameraMode( force )
	if isTimer( SHOW_CURSOR_TMR ) then killTimer( SHOW_CURSOR_TMR ) end
	
	local player_vehicle = localPlayer.vehicle
	if ( force ~= true and ( not player_vehicle ) ) or localPlayer:getData( "blocked_change_camera" ) then return end
	
	local camera_mode_previous = CAMERA_CAROUSELL[ CURRENT_CAMERA ]
	CURRENT_CAMERA = CAMERA_CAROUSELL[ CURRENT_CAMERA + 1 ] and CURRENT_CAMERA + 1 or 1
	local camera_mode = CAMERA_CAROUSELL[ CURRENT_CAMERA ]
	
	local veh_model = player_vehicle and player_vehicle.model
	if veh_model and camera_mode == "FP" and VEHICLE_CONFIG[ veh_model ] and VEHICLE_CONFIG[ veh_model ].ignore_fp_camera then
		CURRENT_CAMERA = CAMERA_CAROUSELL[ CURRENT_CAMERA + 1 ] and CURRENT_CAMERA + 1 or 1
		camera_mode = CAMERA_CAROUSELL[ CURRENT_CAMERA ]
	end

	if camera_mode == "FP" and getCameraTarget( ) and getCameraTarget( ) == player_vehicle then
		ToggleFirstPerson( true )
	else
		if camera_mode_previous == "FP" then
			ToggleFirstPerson( false )
		end
		if camera_mode == "FP" then
			CURRENT_CAMERA = 1
			camera_mode = CAMERA_CAROUSELL[ CURRENT_CAMERA ]
		end
		setCameraViewMode( camera_mode )
	end
end
SwitchCameraMode( true )

local pBoundKeys = getBoundKeys("change_camera")
if pBoundKeys then
	for k,v in pairs(pBoundKeys) do
		bindKey(k, "down", SwitchCameraMode)
	end
end
toggleControl("change_camera", false)

addEventHandler("onClientVehicleStartExit", root, function( pPlayer, iSeat )
	enter = false
	if pPlayer == localPlayer and iSeat == 0 then
		if bFirstPersonEnabled then
			ToggleFirstPerson( false )
			bFirstPersonWasEnabled = true
		end

		toggleControl("change_camera", false)
	end
end)

addEventHandler("onClientVehicleEnter", root, function( pPlayer, iSeat )
	enter = true
	if pPlayer == localPlayer and iSeat == 0 then
		if bFirstPersonWasEnabled then
			ToggleFirstPerson( true )
			bFirstPersonWasEnabled = false
		end

		toggleControl("change_camera", false)
	end
end)

function ToggleDisableFirstPerson( )
	if CAMERA_CAROUSELL[ CURRENT_CAMERA ] == "FP" then
		SwitchCameraMode( true )
	end
end
addEvent( "ToggleDisableFirstPerson", true )
addEventHandler( "ToggleDisableFirstPerson", root, ToggleDisableFirstPerson )

function SetCursor( state, data )
	if state then
		if not isCursorShowing() then return end
		save_cursor_x, save_cursor_y = getCursorPosition()
		setCursorPosition( math.floor( save_cursor_x * scX ), math.floor( save_cursor_y * scY ) )
	elseif save_cursor_x and save_cursor_y then
		setCursorPosition( math.floor( save_cursor_x * scX ), math.floor( save_cursor_y * scY ) )
		save_cursor_x, save_cursor_y = nil, nil
	end
end

function onClientChangeInterfaceState_handler( state, data )
	if not bFirstPersonEnabled then
		if isTimer( SHOW_CURSOR_TMR ) then killTimer( SHOW_CURSOR_TMR ) end
		bFrozenRotation = false
		bPhoteMode = false
		showCursor( false )
		return 
	end
	
	if data.photo_mode then
		if isTimer( SHOW_CURSOR_TMR ) then killTimer( SHOW_CURSOR_TMR ) end
		
		bPhoteMode = state
		bFrozenRotation = state
		localPlayer.alpha = state and 255 or 0
		showCursor( not state, false )
		
		return
	end
	if bPhoteMode then return end

	SetCursor( state, data )
	
	local count_open_back = localPlayer:getData( "open_back" ) or 0
	if not state then
		save_cursor_x, save_cursor_y = getCursorPosition()
		showCursor( count_open_back > 0 and true or false, false )
		SHOW_CURSOR_TMR = setTimer( showCursor, 100, 1, true, false )
	end

	setCursorAlpha( (count_open_back > 0 or state) and 255 or 0 )
	bFrozenRotation = count_open_back > 0 and true or state
end
addEvent( "onClientChangeInterfaceState", true )
addEventHandler( "onClientChangeInterfaceState", root, onClientChangeInterfaceState_handler )

addEventHandler( "onClientResourceStop", resourceRoot, function ( )
	ToggleFirstPerson( false )
end )