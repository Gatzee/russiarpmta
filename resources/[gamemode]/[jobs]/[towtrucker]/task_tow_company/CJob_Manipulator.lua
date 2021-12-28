enum "eTowVehicleState" 
{
	"TOW_VEHICLE_MOVING",
	"TOW_VEHICLE_LOADED",
}

enum "eManipulatorActions" 
{
	"MANIPULATION_RETRACT",
	"MANIPULATION_ROTATE",
}

local MANIPULATOR_KEYS = 
{
	[ "h" ] = true,
	[ "arrow_u" ] = "forward",
	[ "arrow_l" ] = "left",
	[ "arrow_d" ] = "backward",
	[ "arrow_r" ] = "right",
	[ "mouse1" ] = true,
}

local MANIPULATOR_SOUND = nil

local CONST_TIMEOUT_MANIPULATOR_TIME = 3000
local MANIPULATOR_TIMEOUT = 0
local MANIPULATOR_LIMITS = 
{
	[ "forward" ]  = { type = MANIPULATION_RETRACT, value = -0.01, default = 0.2, },
	[ "backward" ] = { type = MANIPULATION_RETRACT, value = 0.01,  default = 0.2, },
	[ "left" ] 	   = { type = MANIPULATION_ROTATE,  value = 0.2,   default = 0,   },
	[ "right" ]    = { type = MANIPULATION_ROTATE,  value = -0.2,  default = 0,   },
}

local MANIPULATOR_OFFSET_LIMITS = 
{
	[ MANIPULATION_RETRACT ] = { min = -1.9, max = 0.2 },
	[ MANIPULATION_ROTATE ]  = { min = -90,  max = 90  },
}

local OBJECTS_MANIPULATOR = 
{
	{
		id = 849,
		type = MANIPULATION_ROTATE,
		type_attach = nil,
		attach_position = Vector3( 0, 1.5, 0 ),
	},

	{
		id = 850,
		type = "stuff",
		type_attach = MANIPULATION_ROTATE,
		attach_position = Vector3( 0, 0, 2.2 ),
	},

	{
		id = 851,
		type = MANIPULATION_RETRACT,
		type_attach = "stuff",
		attach_position = Vector3( -0.2, 0.2, -0.04 ),
	},

	{
		id = 852,
		type = "taker",
		type_attach = MANIPULATION_RETRACT,
		attach_position = Vector3( 0.2, -6.53, -0.6 ),
	},
}

local MANIPULATOR_MOVING = { }
local MANIPULATOR_OBJECTS = {}

local SYNC_DATA = nil
local SYNC_CONST_TIME = 500
local SYNC_START_TICKS = nil

local TOWTRUCKER_VEHICLE_ID = 408

function onClientElementStreamIn_handler()
	if getElementType( source ) ~= "vehicle" or source.model ~= TOWTRUCKER_VEHICLE_ID then return end

	local vehicle = source
	local position_veh, rotation_veh = vehicle.position, vehicle.rotation
	rotation_veh.x, rotation_veh.y = 0, 0

	local data =
	{
		state = nil,
		stuff = {},
		taker = {},
		[ MANIPULATION_ROTATE ] = {},
		[ MANIPULATION_RETRACT ] = {},
	}

	for k, v in ipairs( OBJECTS_MANIPULATOR ) do
		data[ v.type ] = Object( v.id, position_veh, rotation_veh )
		data[ v.type ]:setCollisionsEnabled( false )

		if v.type_attach then
			data[ v.type ]:attach( data[ v.type_attach ], v.attach_position )
		else
			data[ v.type ]:attach( vehicle, v.attach_position )
		end
	end

	MANIPULATOR_OBJECTS[ vehicle ] = data

	addEventHandler( "onClientElementDestroy", vehicle, onClientElementStreamOut_handler )
	addEventHandler( "onClientElementStreamOut", vehicle, onClientElementStreamOut_handler )
end
addEventHandler( "onClientElementStreamIn", root, onClientElementStreamIn_handler )

function onClientElementStreamOut_handler()
	if getElementType( source ) ~= "vehicle" or source.model ~= TOWTRUCKER_VEHICLE_ID then return end
	
	SetManipulatorSoundState( false )
	StopSyncManipulator()

	local vehicle = source
	if MANIPULATOR_OBJECTS[ vehicle ] then
		removeEventHandler( "onClientElementDestroy", vehicle, onClientElementStreamOut_handler )
		removeEventHandler( "onClientElementStreamOut", vehicle, onClientElementStreamOut_handler )

		DestroyTableElements( MANIPULATOR_OBJECTS[ vehicle ] )
		MANIPULATOR_OBJECTS[ vehicle ] = nil

		if MANIPULATOR_DATA and MANIPULATOR_DATA.job_vehicle == vehicle then
			removeEventHandler( "onClientRender", root, onSyncManipulatorRender )

			MANIPULATOR_MOVING[ vehicle ] = nil
			SetManipulatorSoundState( false )
			SetManipulatorActionsState( false )
			MANIPULATOR_DATA = nil
		end
	end
end

function onClientManipulatorReset_handler( job_vehicle, target_vehicle, success )
	removeEventHandler( "onClientRender", root, onSyncManipulatorRender )
	
	if MANIPULATOR_DATA then
		detachElements( target_vehicle, MANIPULATOR_OBJECTS[ job_vehicle ][ "taker" ] )
		
		SetManipulatorSoundState( false )
		SetManipulatorActionsState( false )

		for k, v in pairs( OBJECTS_MANIPULATOR ) do
			setElementAttachedOffsets( MANIPULATOR_OBJECTS[ job_vehicle ][ v.type ], v.attach_position )
		end
		onClientManipulatorControlEnabled_handler( false, job_vehicle, target_vehicle )
		MANIPULATOR_DATA = nil
	end
end
addEvent( "onClientManipulatorReset", true )
addEventHandler( "onClientManipulatorReset", resourceRoot, onClientManipulatorReset_handler )

function onClientAttachVehicleToManipulator_handler( job_vehicle, target_vehicle )
	if not MANIPULATOR_OBJECTS[ job_vehicle ] then return end

	setElementCollidableWith( target_vehicle, job_vehicle, false )
	target_vehicle:attach( MANIPULATOR_OBJECTS[ job_vehicle ][ "taker" ], 0, 0, -1 )
end
addEvent( "onClientAttachVehicleToManipulator", true )
addEventHandler( "onClientAttachVehicleToManipulator", resourceRoot, onClientAttachVehicleToManipulator_handler )

function onClientVehicleEnter_handler( player, seat )
	if player ~= localPlayer or seat ~= 1 then return end

	SetManipulatorActionsState( true )
end

function onClientVehicleStartExit_handler( player, seat )
	if player ~= localPlayer or seat ~= 1 then return end

	MANIPULATOR_MOVING[ source ] = nil
	SetManipulatorSoundState( false )
	SetManipulatorActionsState( false )
end

function onClientManipulatorControlEnabled_handler( state, job_vehicle, target_vehicle )
	MANIPULATOR_DATA = nil
	removeEventHandler( "onClientVehicleEnter", job_vehicle, onClientVehicleEnter_handler )
	removeEventHandler( "onClientVehicleStartExit", job_vehicle, onClientVehicleStartExit_handler )

	if state then
		MANIPULATOR_DATA = { target_vehicle = target_vehicle, job_vehicle = job_vehicle, state = false }

		addEventHandler( "onClientVehicleEnter", job_vehicle, onClientVehicleEnter_handler )
		addEventHandler( "onClientVehicleStartExit", job_vehicle, onClientVehicleStartExit_handler )

		SetManipulatorActionsState( localPlayer:getOccupiedVehicleSeat() == 1 )
	end
end
addEvent( "onClientManipulatorControlEnabled", true )
addEventHandler( "onClientManipulatorControlEnabled", resourceRoot, onClientManipulatorControlEnabled_handler )

function SetManipulatorActionsState( state )
	setHintState( state )
	StopSyncManipulator()
	for k, v in pairs( MANIPULATOR_KEYS ) do
		unbindKey( k, "both", ManipulatorKeyTriggered )
	end

	if state then
		for k, v in pairs( MANIPULATOR_KEYS ) do
			bindKey( k, "both", ManipulatorKeyTriggered )
		end
	end
end

function CreateManipulatorHint()
	CEs.manipulator_hint = ibCreateImage( 0, _SCREEN_Y - 105, 0, 0, "img/info_controls_manipulator.png" )
		:ibSetRealSize()
		:center_x()
		:ibBatchData( { priority = -1, alpha = 0 } )
end

function setHintState( state )
	if not isElement( CEs.manipulator_hint ) then return end

	CEs.manipulator_hint:ibAlphaTo( state and 255 or 0, 250 )
end

function SetManipulatorSoundState( state )
	if isElement( MANIPULATOR_SOUND ) then
		destroyElement( MANIPULATOR_SOUND )
	end
	
	if state then
		MANIPULATOR_SOUND = playSound( "sfx/move_manipulator.ogg", true )
		setSoundVolume( MANIPULATOR_SOUND, 0.6 )
	end
end

function onSyncManipulatorRender()
	local vehicle = MANIPULATOR_DATA.job_vehicle
	local alpha = (getTickCount() - SYNC_START_TICKS) / SYNC_CONST_TIME
	for k, v in pairs( SYNC_DATA ) do
		local new_value = interpolateBetween( v.start_pos, 0, 0, v.end_pos, 0, 0, alpha, "Linear" )
		if k == MANIPULATION_RETRACT then
			MANIPULATOR_OBJECTS[ vehicle ][ k ]:setAttachedOffsets( -0.2, new_value, -0.04, 0, 0, 0  )
		elseif k == MANIPULATION_ROTATE then
			MANIPULATOR_OBJECTS[ vehicle ][ k ]:setAttachedOffsets( 0, 1.5, 0, 0, 0, new_value )
		end
	end

	if alpha > 1 then
		SetManipulatorSoundState( false )
		removeEventHandler( "onClientRender", root, onSyncManipulatorRender )
	end
end

function onClientSyncManipulator_handler( target_y, target_rz )
	local vehicle = MANIPULATOR_DATA.job_vehicle
	if not vehicle then return end
	removeEventHandler( "onClientRender", root, onSyncManipulatorRender )
	
	local _, y, _, _, _, _ = getElementAttachedOffsets( MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_RETRACT ] )
	local _, _, _, _, _, rz = getElementAttachedOffsets( MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_ROTATE ] )
	
	SYNC_DATA = 
	{
		[ MANIPULATION_RETRACT ] =
		{
			start_pos = y,
			end_pos = target_y,
		},

		[ MANIPULATION_ROTATE ] = 
		{
			start_pos = rz,
			end_pos = target_rz,
		},
	}

	local manipulator_rot = SYNC_DATA[ MANIPULATION_ROTATE ]
	if manipulator_rot.start_pos > 180 and manipulator_rot.end_pos < 180 then
		manipulator_rot.end_pos = 360 + manipulator_rot.end_pos
	elseif manipulator_rot.start_pos < 180 and manipulator_rot.end_pos > 180 then
		manipulator_rot.end_pos = manipulator_rot.end_pos - 360
	end
	
	SYNC_START_TICKS = getTickCount()
	addEventHandler( "onClientRender", root, onSyncManipulatorRender )
end
addEvent( "onClientSyncManipulator", true )
addEventHandler( "onClientSyncManipulator", resourceRoot, onClientSyncManipulator_handler )

function IsManipulatorTimeOut()
	local ticks = getTickCount()
	if MANIPULATOR_TIMEOUT > ticks then 
		return false
	end
	
	MANIPULATOR_TIMEOUT = ticks + CONST_TIMEOUT_MANIPULATOR_TIME
	return true
end

function ManipulatorKeyTriggered( key, state )
	if MANIPULATOR_DATA and MANIPULATOR_DATA.state == TOW_VEHICLE_LOADED then
		return false
	end

	local vehicle = MANIPULATOR_DATA and MANIPULATOR_DATA.job_vehicle
	if not vehicle then 
		return 
	end

	if key == "mouse1" and state == "down" then
		if not IsManipulatorTimeOut() then return end
		SetManipulatorSoundState( false )

		if MANIPULATOR_DATA.state == TOW_VEHICLE_MOVING and not MANIPULATOR_DATA.attached then
			TryLoadToManpulator( vehicle )
		elseif MANIPULATOR_DATA.attached then
			TryLoadToTowTrucker( vehicle )
		end
	elseif key == "h" and state == "down" then
		if not IsManipulatorTimeOut() then return end

		if MANIPULATOR_DATA.state == TOW_VEHICLE_MOVING then
			DeactivateManipulator()
			return
		end

		TryActivateManipulator( vehicle )
	elseif MANIPULATOR_DATA.state == TOW_VEHICLE_MOVING then
		local operation = MANIPULATOR_KEYS[ key ]
		if not MANIPULATOR_LIMITS[ operation ] then return end

		if state == "down" then
			if not MANIPULATOR_MOVING[ vehicle ] then MANIPULATOR_MOVING[ vehicle ] = {} end
	
			MANIPULATOR_MOVING[ vehicle ].operation = operation
			MANIPULATOR_MOVING[ vehicle ].mode = MANIPULATOR_LIMITS[ operation ].type
			MANIPULATOR_MOVING[ vehicle ].object = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATOR_LIMITS[ operation ].type ]

			SetManipulatorSoundState( true )
		else
			SetManipulatorSoundState( false )
			MANIPULATOR_MOVING[ vehicle ] = nil
		end
	end
end

function TryActivateManipulator( vehicle )
	local speedx, speedy, speedz = getElementVelocity( vehicle )
	local actual = math.sqrt( speedx ^ 2 + speedy ^ 2 + speedz ^ 2 )
	local kmh = actual * 180
	if kmh < 3 then
		MANIPULATOR_DATA.state = TOW_VEHICLE_MOVING
		triggerServerEvent( "onServerManipulatorChangeState", resourceRoot, true )

		StartSyncManipulator( vehicle )
	else
		localPlayer:ShowInfo( "Эвакуатор должен стоять на месте" )
	end
end

function DeactivateManipulator()
	StopSyncManipulator()
	SetManipulatorSoundState( false )

	MANIPULATOR_DATA.state = false
	triggerServerEvent( "onServerManipulatorChangeState", resourceRoot, false )
end

function TryLoadToManpulator( vehicle )
	if CheckToLoadVehicleToManipulator( vehicle ) then
		MANIPULATOR_DATA.attached = true
		triggerServerEvent( "onServerAttachVehicleToManipulator", localPlayer )
	else
		localPlayer:ShowInfo( "Невозможно подцепить автомобиль" )
	end
end

function CheckToLoadVehicleToManipulator( vehicle )
	local offset1 = { getPositionFromElementOffset( MANIPULATOR_OBJECTS[ vehicle ].taker, 0.1, -0.1, 0 ) }
	local offset2 = { getPositionFromElementOffset( MANIPULATOR_OBJECTS[ vehicle ].taker, 0.1, 0.1,  0 ) }
	
	local cx = 0.5 * ( offset1[ 1 ] + offset2[ 1 ] )
	local cy = 0.5 * ( offset1[ 2 ] + offset2[ 2 ] )

	for k, v in pairs( getElementsWithinRange( cx, cy, offset1[ 3 ] - 3, 0.5, "vehicle" ) ) do
		if v == MANIPULATOR_DATA.target_vehicle then
			return true
		end
	end

	return false
end


function TryLoadToTowTrucker( vehicle )
	if CheckToLoadVehicleToTowturcker( vehicle ) then
		MANIPULATOR_DATA.state = TOW_VEHICLE_LOADED
		
		StopSyncManipulator()
		MANIPULATOR_MOVING[ vehicle ] = nil

		triggerServerEvent( "onServerAttachVehicleToTowtucker", localPlayer )
	else
		localPlayer:ShowInfo( "Невозможно погрузить автомобиль" )
	end
end

function CheckToLoadVehicleToTowturcker( vehicle )
	local rotate = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_ROTATE ]
	local retract = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_RETRACT ]
	
	local _, _, _, _, _, rz = getElementAttachedOffsets( rotate )
	local _, y = getElementAttachedOffsets( retract )
	
	if rz < 5 or rz > 355 then
		return true
	end
	
	return false
end

function StartSyncManipulator( vehicle )
	if isTimer( SYNC_TMR ) then
		return false
	end

	SYNC_TMR = setTimer( function()
		if isElement( vehicle ) then
			local _, y, _, _, _, _ = getElementAttachedOffsets( MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_RETRACT ] )
			local _, _, _, _, _, rz = getElementAttachedOffsets( MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_ROTATE ] )
			triggerServerEvent( "onServerSyncManipulator", localPlayer, y, rz )
		end
	end, SYNC_CONST_TIME, 0 )
end

function StopSyncManipulator()
	if isTimer( SYNC_TMR ) then 
		killTimer( SYNC_TMR ) 
	end
end

function onClientPreRender_handler( slice )
	for k, v in pairs( MANIPULATOR_MOVING ) do		
		local new_value
		local x, y, z, rx, ry, rz = v.object:getAttachedOffsets( )

		if v.mode == MANIPULATION_RETRACT then
			local offset = ( slice / 150 ) * MANIPULATOR_OFFSET_LIMITS[ v.mode ].max
			if v.operation == "forward" then offset = 0 - offset end
			new_value = y + offset
		elseif v.mode == MANIPULATION_ROTATE then
			local offset = ( slice / 5000 ) * MANIPULATOR_OFFSET_LIMITS[ v.mode ].max
			if rz > MANIPULATOR_OFFSET_LIMITS[ v.mode ].max then rz = rz - 360 end
			if v.operation == "right" then offset = 0 - offset end
			new_value = rz + offset
		end

		if new_value > MANIPULATOR_OFFSET_LIMITS[ v.mode ].min and new_value < MANIPULATOR_OFFSET_LIMITS[ v.mode ].max then
			if v.mode == MANIPULATION_RETRACT then
				v.object:setAttachedOffsets( -0.2, new_value, -0.04, 0, 0, 0  )
			elseif v.mode == MANIPULATION_ROTATE then
				v.object:setAttachedOffsets( 0, 1.5, 0, 0, 0, new_value )
			end
		else
			MANIPULATOR_MOVING[ v ] = nil
		end
	end
end
addEventHandler( "onClientPreRender", root, onClientPreRender_handler )

function getPositionFromElementOffset( element, offX, offY, offZ ) 
    local m = getElementMatrix ( element )
    local x = offX * m[ 1 ][ 1 ] + offY * m[ 2 ][ 1 ] + offZ * m[ 3 ][ 1 ] + m[ 4 ][ 1 ]
    local y = offX * m[ 1 ][ 2 ] + offY * m[ 2 ][ 2 ] + offZ * m[ 3 ][ 2 ] + m[ 4 ][ 2 ] 
    local z = offX * m[ 1 ][ 3 ] + offY * m[ 2 ][ 3 ] + offZ * m[ 3 ][ 3 ] + m[ 4 ][ 3 ] 
    return x, y, z
end

function onSettingsChange_handler( changed, values )
	if not changed.vehdrawdistance or not values.vehdrawdistance then
		return false
	end

	local min_vehdistance, max_vehdistance = 30, 250
	local new_distance = math.floor( min_vehdistance + ( max_vehdistance - min_vehdistance ) * values.vehdrawdistance )
	for k, v in pairs( { 849, 850, 851, 852 } ) do
		engineSetModelLODDistance( v, new_distance / 2 )
	end
end
addEvent( "onSettingsChange", true )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )
