enum "eManipulatorActions" 
{
	"MANIPULATION_RETRACT",
	"MANIPULATION_ROTATE",
	"MANIPULATION_CABLE",
	"MANIPULATION_DIVING",
	"MANIPULATION_OBJECT",
}

enum "eMoveType"
{
	"MOVE_TYPE_FORWARD",
	"MOVE_TYPE_BACKWARD",
	"MOVE_TYPE_LEFT",
	"MOVE_TYPE_RIGHT",
	"MOVE_TYPE_UP",
	"MOVE_TYPE_DOWN",
}

local MANIPULATOR_KEYS = 
{
	[ "h" ] = true,
	
	[ "arrow_u" ] = MOVE_TYPE_FORWARD,
	[ "arrow_d" ] = MOVE_TYPE_BACKWARD,
	[ "arrow_l" ] = MOVE_TYPE_LEFT,
	[ "arrow_r" ] = MOVE_TYPE_RIGHT,
	[ "mouse1" ]  = MOVE_TYPE_UP,
	[ "mouse2" ]  = MOVE_TYPE_DOWN,

	[ "w" ] = MOVE_TYPE_FORWARD,
	[ "s" ] = MOVE_TYPE_BACKWARD,
	[ "a" ] = MOVE_TYPE_LEFT,
	[ "d" ] = MOVE_TYPE_RIGHT,
}

local MANIPULATOR_KEYS_REVERSE = {}
for k, v in pairs( MANIPULATOR_KEYS ) do table.insert( MANIPULATOR_KEYS_REVERSE, k ) end


MANIPULATOR_SIDE = nil
MANIPULATION_DEPTH_INDEX = 0

MANIPULATOR_TIMEOUT = 0
CONST_TIMEOUT_MANIPULATOR_TIME = 3000

IGNORE_SYNC = {}

MANIPULATOR_LIMITS = 
{
	[ MOVE_TYPE_FORWARD ]  = { type = MANIPULATION_RETRACT, value = -0.01, default = 0.2, },
	[ MOVE_TYPE_BACKWARD ] = { type = MANIPULATION_RETRACT, value = 0.01,  default = 0.2, },
	[ MOVE_TYPE_LEFT ] 	   = { type = MANIPULATION_ROTATE,  value = 0.2,   default = 0,   },
	[ MOVE_TYPE_RIGHT ]    = { type = MANIPULATION_ROTATE,  value = -0.2,  default = 0,   },
	[ MOVE_TYPE_UP ]       = { type = MANIPULATION_CABLE,   value = 0.2,   default = 0,   },
	[ MOVE_TYPE_DOWN ]     = { type = MANIPULATION_CABLE,   value = -0.2,  default = 0,   },
}

MANIPULATOR_OFFSET_LIMITS = 
{
	[ MANIPULATION_RETRACT ] = { min = 1.8, max = 9.5 },
	[ MANIPULATION_ROTATE ]  = { min = -25, max = 120, z = -2, rz = 30 },
	[ MANIPULATION_CABLE ]   = { min = 1,   max = 13,  z = -2, rz = 30 },
	[ MANIPULATION_DIVING ]  = { min = -1,  max = 0 },
}

MANIPULATOR_OBJECT_OPERATION = 
{
	[ MANIPULATION_FISH_EMPTY ] 	  = { id = 845, pos = Vector3( 0, -0.45, -1.7  ), rot = { [ LEFT_BOAT_SIDE ] = Vector3( 0, 0, 0 ), [ RIGHT_BOAT_SIDE ] = Vector3( 0, 0, 0 ) }, },
	[ MANIPULATION_FISH_FULL ]  	  = { id = 841, pos = Vector3( 0, -0.25, -1.72 ), rot = { [ LEFT_BOAT_SIDE ] = Vector3( 0, 0, 0 ), [ RIGHT_BOAT_SIDE ] = Vector3( 0, 0, 0 ) }, },
	
	[ MANIPULATION_CONTAINER_CREATE ] = { id = CONTAINER_ID, pos = Vector3( 0, 0, -1.75 ), rot = { [ LEFT_BOAT_SIDE ] = Vector3( 0, 0, 15 ), [ RIGHT_BOAT_SIDE ] = Vector3( 0, 0, -15 ) }, },
	[ MANIPULATION_CONTAINER_LOADED ] = { id = CONTAINER_ID, pos = Vector3( 0, 0, -1.75 ), rot = { [ LEFT_BOAT_SIDE ] = Vector3( 0, 0, 15 ), [ RIGHT_BOAT_SIDE ] = Vector3( 0, 0, -15 ) }, alpha = true },
}


local OBJECTS_MANIPULATOR = 
{
	[ LEFT_BOAT_SIDE ] = {
		{
			id = 844,
			type = MANIPULATION_ROTATE,
			type_attach = nil,
			pos = Vector3( -4.272, -13.33, 1.2 ),
		},
	
		{
			id = 842,
			type = "stuff",
			type_attach = MANIPULATION_ROTATE,
			pos = Vector3( 0, 0, 5.35 ),
		},
		
		{
			id = 847,
			type = MANIPULATION_RETRACT,
			type_attach = "stuff",
			pos = Vector3( 0, 1.8, 0.02 ),
		},
		
		{
			id = 846,
			type = MANIPULATION_CABLE,
			type_attach = MANIPULATION_RETRACT,
			pos = Vector3( 0, 8.32, 0 ),
		},

		{
			id = 843,
			type = MANIPULATION_DIVING,
			type_attach = MANIPULATION_CABLE,
			pos = Vector3( 0, 0, -0.67 ),
		},
	},

	[ RIGHT_BOAT_SIDE ] = {
		{
			id = 844,
			type = MANIPULATION_ROTATE,
			type_attach = nil,
			pos = Vector3( 4.272, -13.33, 1.2 ),
		},
	
		{
			id = 842,
			type = "stuff",
			type_attach = MANIPULATION_ROTATE,
			pos = Vector3( 0, 0, 5.35 ),
		},
		
		{
			id = 847,
			type = MANIPULATION_RETRACT,
			type_attach = "stuff",
			pos = Vector3( 0, 1.8, 0.02 ),
		},
	
		{
			id = 846,
			type = MANIPULATION_CABLE,
			type_attach = MANIPULATION_RETRACT,
			pos = Vector3( 0, 8.32, 0 ),
		},

		{
			id = 843,
			type = MANIPULATION_DIVING,
			type_attach = MANIPULATION_CABLE,
			pos = Vector3( 0, 0, -0.67 ),
		},
	}
}

local MANIPULATOR_MOVING = { }
local MANIPULATOR_OBJECTS = {}

local MOVING_CONDITION = 
{
	[ MANIPULATION_ROTATE ]  = function( vehicle, mode, operation, side, new_value )
		local _, y = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_RETRACT ][ side ]:getAttachedOffsets( )
		local _, _, _, _, _, rz = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_ROTATE ][ side ]:getAttachedOffsets( )
		local _, _, z = getObjectScale( MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_CABLE ][ side ] )

		local object_side = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_OBJECT ][ side ]
		local object_model = object_side and object_side.model or -1

		local max_y_container = 2.27
		local max_y_fish = 6
		local max_rz_retract = 10

		if object_model == CONTAINER_ID and operation == MOVE_TYPE_LEFT and side == RIGHT_BOAT_SIDE and y > max_y_container and rz > 360 - max_rz_retract then
			return false
		elseif object_model == CONTAINER_ID and operation == MOVE_TYPE_RIGHT and side == LEFT_BOAT_SIDE and y > max_y_container and rz < max_rz_retract then
			return false
		elseif (object_model == 841 or object_model == 845) and operation == MOVE_TYPE_LEFT and side == RIGHT_BOAT_SIDE and y > max_y_fish and rz > 360 - max_rz_retract then
			return false
		elseif (object_model == 841 or object_model == 845) and operation == MOVE_TYPE_RIGHT and side == LEFT_BOAT_SIDE and y > max_y_fish and rz < max_rz_retract then
			return false
		end

		local max_z = 2.2
		local max_rz_cable_in = 19
		local max_rz_cable_out = 24 - y * 0.4

		if operation == MOVE_TYPE_RIGHT and side == RIGHT_BOAT_SIDE and z > max_z and rz < max_rz_cable_in then
			return false
		elseif operation == MOVE_TYPE_LEFT and side == RIGHT_BOAT_SIDE and z > max_z and rz > max_rz_cable_out and rz > 360 - max_rz_cable_out then
			return false
		elseif operation == MOVE_TYPE_RIGHT and side == LEFT_BOAT_SIDE and z > max_z and rz < max_rz_cable_out then
			return false
		elseif operation == MOVE_TYPE_LEFT and side == LEFT_BOAT_SIDE and z > max_z and rz > 360 - max_rz_cable_in then
			return false
		end

		return new_value > MANIPULATOR_OFFSET_LIMITS[ mode ].min and new_value < MANIPULATOR_OFFSET_LIMITS[ mode ].max
	end,
	[ MANIPULATION_RETRACT ] = function( vehicle, mode, operation, side, new_value )	
		local _, y = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_RETRACT ][ side ]:getAttachedOffsets( )
		local _, _, _, _, _, rz = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_ROTATE ][ side ]:getAttachedOffsets( )
		local object_side = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_OBJECT ][ side ]
		local object_model = object_side and object_side.model or -1

		if object_model == CONTAINER_ID and y > 1 and operation == MOVE_TYPE_FORWARD and side == LEFT_BOAT_SIDE and (rz < 10 or rz > 340) then
			return false
		elseif object_model == CONTAINER_ID and y > 1 and operation == MOVE_TYPE_FORWARD and side == RIGHT_BOAT_SIDE and (rz < 25 or rz > 350.5) then
			return false
		elseif (object_model == 841 or object_model == 845) and y > 5 and operation == MOVE_TYPE_FORWARD and side == LEFT_BOAT_SIDE and (rz < 10 or rz > 340) then
			return false
		elseif (object_model == 841 or object_model == 845) and y > 5 and operation == MOVE_TYPE_FORWARD and side == RIGHT_BOAT_SIDE and (rz < 25 or rz > 350.5) then
			return false
		end

		return new_value > MANIPULATOR_OFFSET_LIMITS[ mode ].min and new_value < MANIPULATOR_OFFSET_LIMITS[ mode ].max
	end,
	[ MANIPULATION_CABLE ] = function( vehicle, mode, operation, side, new_value )
		local _, _, z = getObjectScale( MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_CABLE ][ side ] )
		local object_side = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_OBJECT ][ side ]
		local object_model = object_side and object_side.model or -1

		if object_model == CONTAINER_ID and object_side.alpha > 5 then
			local _, _, _, _, _, rz = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_ROTATE ][ side ]:getAttachedOffsets( )
			if operation == MOVE_TYPE_UP and side == LEFT_BOAT_SIDE and z > 5.85 and rz > 60 and rz < 125 then 
				return false 
			elseif operation == MOVE_TYPE_UP and side == RIGHT_BOAT_SIDE and z > 5.85 and rz > 211 and rz < 322 then
				return false
			end

			local max_z = 1.8
			local rz_1, rz_2 = 21, 339
			if operation == MOVE_TYPE_UP and side == RIGHT_BOAT_SIDE and z > max_z and (rz < rz_1 or (rz > rz_2 and rz < 360)) then
				return false
			elseif operation == MOVE_TYPE_UP and side == LEFT_BOAT_SIDE and z > max_z and (rz < rz_1) then
				return false
			end

			return not ((new_value < MANIPULATOR_OFFSET_LIMITS[ mode ].min and operation == MOVE_TYPE_DOWN) or (new_value > MANIPULATOR_OFFSET_LIMITS[ mode ].max and operation == MOVE_TYPE_UP))
		elseif object_model == 841 or object_model == 845 then
			local _, _, _, _, _, rz = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_ROTATE ][ side ]:getAttachedOffsets( )
			if operation == MOVE_TYPE_UP and side == RIGHT_BOAT_SIDE and ((z > 1.8 and (rz < 14 or (rz > 345 and rz < 360))) or (rz > 12 and rz < 25 and new_value > 12.8)) then
				return false
			elseif operation == MOVE_TYPE_UP and side == LEFT_BOAT_SIDE and ((z > 1.8 and (rz < 21 or (rz > 348 and rz < 360))) or (rz > 335 and rz < 360 and new_value > 12.8)) then
				return false
			end
			return not ((new_value < MANIPULATOR_OFFSET_LIMITS[ mode ].min and operation == MOVE_TYPE_DOWN) or (new_value > 43 and operation == MOVE_TYPE_UP))
		end

		return true
	end,
}

CONTAINERS_STATIC_OBJECTS = {}
local OBJECT_HANDLERS = 
{
	[ MANIPULATION_CONTAINER_LOADED ] = function( side_index )
		local vehicle = MANIPULATOR_DATA.job_vehicle
		local side_containers_count = CONTAINERS_STATIC_OBJECTS[ side_index .. "count" ] or 0
		
		local container_position = vehicle.position + CONTAINER_PORT_POSITION[ side_index ].position + Vector3( 0, side_containers_count * 5, 4.8 )

		local object = Object( CONTAINER_ID, container_position, Vector3( 0, 0, 90 ) )		
		
		CONTAINERS_STATIC_OBJECTS[ side_index .. "count" ] = side_containers_count + 1
		table.insert( CONTAINERS_STATIC_OBJECTS, object )
	end,

	[ MANIPULATION_FISH_FULL ] = function( side_index )
		if localPlayer:getData( "fisherman_index" ) ~= side_index then return end
		
		local vehicle = MANIPULATOR_DATA.job_vehicle
		CEs.load_point_fish_shape = createColSphere( vehicle.position, CONTAINER_SHAPE_RADIUS / 2 )
        CEs.load_point_fish_shape:attach( MANIPULATOR_DATA.job_vehicle )
		CEs.load_point_fish_shape:setAttachedOffsets( Vector3( 0, -4, 0 ), 0, 0, 0 )

        CEs.load_point_fish_marker = createMarker( CEs.load_point_fish_shape.position, "cylinder", CONTAINER_SHAPE_RADIUS, 100, 250, 100, 150 )
        CEs.load_point_fish_marker:attach( CEs.load_point_fish_shape )
        
		local object = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_OBJECT ][ side_index ]
        addEventHandler( "onClientColShapeHit", CEs.load_point_fish_shape, function( element )
			if element ~= object or getElementType( element ) ~= "object" or element:getData( "boat_side" ) ~= side_index then return end

			CEs.load_point_fish_shape:destroy()
			CEs.load_point_fish_marker:destroy()
			triggerServerEvent( "onServerFishermanLoadedFish", resourceRoot)
		end )

		localPlayer:ShowInfo( "Сеть заполнена, загрузи рыбу в трюм" )
	end,
}

local SYNC_DATA = nil
local SYNC_CONST_TIME = 500
local SYNC_START_TICKS = nil

local math_abs, math_max = math.abs, math.max

local SHIP_VEHICLE_ID = 595

function CreateManipulator( vehicle )
	local vehicle = vehicle or source 
	if getElementType( vehicle ) ~= "vehicle" or vehicle.model ~= SHIP_VEHICLE_ID then return end

	local position_veh, rotation_veh = vehicle.position, vehicle.rotation
	rotation_veh.x, rotation_veh.y = 0, 0

	local data =
	{
		state = nil,
		stuff = {},
		diving = {},
		cable = {},
		[ MANIPULATION_ROTATE ] = {},
		[ MANIPULATION_RETRACT ] = {},
		[ MANIPULATION_CABLE ] = {},
		[ MANIPULATION_DIVING ] = {},
		[ MANIPULATION_OBJECT ] = {},
	}

	for k, objects in pairs( OBJECTS_MANIPULATOR ) do
		for _, v in ipairs( objects ) do
			data[ v.type ][ k ] = Object( v.id, position_veh, rotation_veh )
			data[ v.type ][ k ]:setCollisionsEnabled( false )

			if v.type_attach then
				data[ v.type ][ k ]:attach( data[ v.type_attach ][ k ], v.pos )
			else
				data[ v.type ][ k ]:attach( vehicle, v.pos )
			end
		end
	end

	MANIPULATOR_OBJECTS[ vehicle ] = data

	addEventHandler( "onClientElementDestroy", vehicle, onClientElementStreamOut_handler )
	addEventHandler( "onClientElementStreamOut", vehicle, onClientElementStreamOut_handler )
end
addEventHandler( "onClientElementStreamIn", root, CreateManipulator )

function onStart()
	for k, v in pairs( getElementsByType( "vehicle" ) ) do
		if isElementStreamedIn( v ) and v == localPlayer.vehicle then
			CreateManipulator( v )
		end
	end
end
addEventHandler( "onClientResourceStart", resourceRoot, onStart )

function onClientElementStreamOut_handler()
	removeEventHandler( "onClientElementDestroy", source, onClientElementStreamOut_handler )
	removeEventHandler( "onClientElementStreamOut", source, onClientElementStreamOut_handler )

	if not MANIPULATOR_OBJECTS[ source ] then return end
	DestroyTableElements( MANIPULATOR_OBJECTS[ source ] )
	MANIPULATOR_OBJECTS[ source ] = nil

	if MANIPULATOR_DATA and MANIPULATOR_DATA.job_vehicle == source then
		removeEventHandler( "onClientRender", root, onSyncManipulatorRender )

		MANIPULATOR_MOVING[ source ] = nil
		SetManipulatorSoundState( false )
	end
end

function CreateManipulatorObject( operation, side )
	local vehicle = MANIPULATOR_DATA and MANIPULATOR_DATA.job_vehicle
	local diving = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_DIVING ][ side ]
	local object = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_OBJECT ][ side ]
	local object_operation = MANIPULATOR_OBJECT_OPERATION[ operation ]

	if object then object:destroy( ) end

	local object = Object( object_operation.id, vehicle.position )
	object:setCollisionsEnabled( false )
	object:attach( diving, object_operation.pos, object_operation.rot[ side ] )
	object:setData( "boat_side", side, false )

	MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_OBJECT ][ side ] = object

	if object_operation.alpha then object:setAlpha( 0 ) end
	if OBJECT_HANDLERS[ operation ] then OBJECT_HANDLERS[ operation ]( side ) end
end

function onClientFisherManManipulatorObject_handler( operation, target_side, is_off_manipulator )
	for k, v in pairs( target_side and { target_side } or { LEFT_BOAT_SIDE, RIGHT_BOAT_SIDE } ) do
		CreateManipulatorObject( operation, v )
	end
	
	if is_off_manipulator then
		if localPlayer:getData( "fisherman_index" ) and MANIPULATOR_SIDE == target_side then
			GEs.action_controller:toggle_controls( false, MANIPULATOR_DATA.job_vehicle )
		end

		for k, v in pairs( target_side and { target_side } or { LEFT_BOAT_SIDE, RIGHT_BOAT_SIDE } ) do
			onClientSyncManipulator_handler( 1.8, 0, 1, v )
			IGNORE_SYNC[ v ] = true
			setTimer( function() IGNORE_SYNC[ v ] = false end, 5000, 1 )
		end
	end
end
addEvent( "onClientFisherManManipulatorObject", true )
addEventHandler( "onClientFisherManManipulatorObject", resourceRoot, onClientFisherManManipulatorObject_handler )

function ResetManipulator( state, job_vehicle )
	if isTimer( GEs.reset_ignore_tmr ) then killTimer( GEs.reset_ignore_tmr ) end
	IGNORE_SYNC = {}

	MANIPULATOR_DATA = { job_vehicle = job_vehicle, state = state }
	CEs.init_tmr = setTimer( onClientFisherManManipulatorObject_handler, 2000, 1, MANIPULATION_FISH_EMPTY )

	removeEventHandler( "onClientRender", root, onSyncManipulatorRender )
	addEventHandler( "onClientRender", root, onSyncManipulatorRender )
end

function SetManipulatorActionsState( state, vehicle )
	ChangeBindsState( MANIPULATOR_KEYS_REVERSE, state, ManipulatorKeyHandler )
	SetSyncManipulator( state, vehicle )
	if not state then
		MANIPULATOR_MOVING[ vehicle ] = nil
	end
end

function SetManipulatorSoundState( state )
	if isElement( GEs.manipulator_sound ) then destroyElement( GEs.manipulator_sound ) end
	if state then
		GEs.manipulator_sound = playSound( "sfx/move_manipulator.ogg", true )
		setSoundVolume( GEs.manipulator_sound, 0.6 )
	end
end

function IsManipulatorTimeOut()
	local ticks = getTickCount()
	if MANIPULATOR_TIMEOUT > ticks then 
		return false
	end
	
	MANIPULATOR_TIMEOUT = ticks + CONST_TIMEOUT_MANIPULATOR_TIME
	return true
end

function ManipulatorKeyHandler( key, state )
	local vehicle = MANIPULATOR_DATA and MANIPULATOR_DATA.job_vehicle

	if key == "h" and state == "down" then
		if not IsManipulatorTimeOut() then return end

		MANIPULATOR_DATA.state = not MANIPULATOR_DATA.state

		SetManipulatorSoundState( MANIPULATOR_DATA.state )
		SetSyncManipulator( MANIPULATOR_DATA.state, vehicle )

		localPlayer:ShowInfo( MANIPULATOR_DATA.state and "Манипулятор активирован" or "Манипулятор деактивирован" )
	elseif MANIPULATOR_DATA.state then
		local operation = MANIPULATOR_KEYS[ key ]
		if not MANIPULATOR_LIMITS[ operation ] then return end

		if state == "down" then
			if not MANIPULATOR_MOVING[ vehicle ] then MANIPULATOR_MOVING[ vehicle ] = {} end
	
			MANIPULATOR_MOVING[ vehicle ].operation = operation
			MANIPULATOR_MOVING[ vehicle ].mode = MANIPULATOR_LIMITS[ operation ].type
			MANIPULATOR_MOVING[ vehicle ].object = MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATOR_LIMITS[ operation ].type ]
			MANIPULATOR_MOVING[ vehicle ].side = MANIPULATOR_SIDE

			SetManipulatorSoundState( true )
		else
			SetManipulatorSoundState( false )
			MANIPULATOR_MOVING[ vehicle ] = nil
		end
	end
end

function onClientPreRender_handler( slice )
	for k, v in pairs( MANIPULATOR_MOVING ) do		
		local new_value
		local x, y, z, rx, ry, rz = v.object[ v.side ]:getAttachedOffsets( )
		local manipulator_objects = MANIPULATOR_OBJECTS[ k ]

		if v.mode == MANIPULATION_RETRACT then
			local offset = ( slice / 3000 ) * MANIPULATOR_OFFSET_LIMITS[ v.mode ].max
			if v.operation == MOVE_TYPE_BACKWARD then offset = 0 - offset end
			
			new_value = y + offset
		elseif v.mode == MANIPULATION_ROTATE then
			local offset = ( slice / 5000 ) * 90
			if rz > MANIPULATOR_OFFSET_LIMITS[ v.mode ].max then rz = rz - 360 end
			if v.operation == MOVE_TYPE_RIGHT then offset = 0 - offset end
			
			new_value = rz + offset
		elseif v.mode == MANIPULATION_CABLE then
			local offset = ( slice / 2500 ) * MANIPULATOR_OFFSET_LIMITS[ v.mode ].max
			if v.operation == MOVE_TYPE_DOWN then offset = 0 - offset end
			
			local _, _, z = getObjectScale( manipulator_objects[ MANIPULATION_CABLE ][ v.side ] )
			new_value = z + offset
		end

		if MOVING_CONDITION[ v.mode ]( k, v.mode, v.operation, v.side, new_value ) then
			if v.mode == MANIPULATION_RETRACT then
				local position = OBJECTS_MANIPULATOR[ v.side ][ 3 ].pos
				position.y = new_value
				v.object[ v.side ]:setAttachedOffsets( position, 0, 0, 0  )
			elseif v.mode == MANIPULATION_ROTATE then
				local _, _, z, _, _, _ = getElementAttachedOffsets( manipulator_objects[ MANIPULATION_CABLE ][ v.side ] )
				local rz = math_max( MANIPULATOR_OFFSET_LIMITS[ MANIPULATION_ROTATE ].rz, math_abs( new_value ) )
				if v.side == LEFT_BOAT_SIDE then rz = 0 - rz end

				new_value = z < MANIPULATOR_OFFSET_LIMITS[ MANIPULATION_ROTATE ].z and rz or new_value
				v.object[ v.side ]:setAttachedOffsets( OBJECTS_MANIPULATOR[ v.side ][ 1 ].pos, 0, 0, new_value )
			elseif v.mode == MANIPULATION_CABLE then
				local _, _, _, _, _, rz = getElementAttachedOffsets( manipulator_objects[ MANIPULATION_ROTATE ][ v.side ] )
				if rz > 90 then rz = math_abs( rz - 360 ) end

				new_value = rz < MANIPULATOR_OFFSET_LIMITS[ MANIPULATION_CABLE ].rz and math_max( MANIPULATOR_OFFSET_LIMITS[ MANIPULATION_CABLE ].z, new_value ) or new_value
				
				manipulator_objects[ MANIPULATION_CABLE ][ v.side ]:setScale( 1, 1, math_max( 1, 1, new_value ) )
				manipulator_objects[ MANIPULATION_DIVING ][ v.side ]:setAttachedOffsets( Vector3( 0, 0, OBJECTS_MANIPULATOR[ v.side ][ 5 ].pos.z * new_value ), 0, 0, 0 )

				SetDepthHud( manipulator_objects[ MANIPULATION_OBJECT ][ v.side ].position.z )
			end
		else
			MANIPULATOR_MOVING[ v ] = nil
		end
	end
end
addEventHandler( "onClientPreRender", root, onClientPreRender_handler )



function SetSyncManipulator( state, vehicle )
	if state then
		if isTimer( SYNC_TMR ) then return false end
		
		SYNC_TMR = setTimer( function()
			if not isElement( vehicle ) then killTimer( SYNC_TMR ) end
			local manipulator_objects = MANIPULATOR_OBJECTS[ vehicle ]
			if manipulator_objects then
				local _, y, _, _, _, _ = getElementAttachedOffsets( manipulator_objects[ MANIPULATION_RETRACT ][ MANIPULATOR_SIDE ] )
				local _, _, _, _, _, rz = getElementAttachedOffsets( manipulator_objects[ MANIPULATION_ROTATE ][ MANIPULATOR_SIDE ] )
				local _, _, scale_z = getObjectScale( manipulator_objects[ MANIPULATION_CABLE ][ MANIPULATOR_SIDE ] )
				
				triggerServerEvent( "onServerSyncFishingManipulator", localPlayer, y, rz, scale_z, MANIPULATOR_SIDE )
			end
		end, SYNC_CONST_TIME, 0 )
	
	elseif isTimer( SYNC_TMR ) then 
		killTimer( SYNC_TMR )
	end
end

function onSyncManipulatorRender()
	local vehicle = MANIPULATOR_DATA.job_vehicle
	local finished_sides = 0
	for side, ticks_data in pairs( SYNC_START_TICKS or {} ) do
		local alpha = (getTickCount() - ticks_data.ticks) / ticks_data.time 
		if alpha <= 1 then
			for k, v in pairs( SYNC_DATA[ side ] ) do
				local new_value = interpolateBetween( v.start_pos, 0, 0, v.end_pos, 0, 0, alpha, "Linear" )
				if k == MANIPULATION_RETRACT then
					local position = OBJECTS_MANIPULATOR[ side ][ 3 ].pos
					position.y = new_value
					MANIPULATOR_OBJECTS[ vehicle ][ k ][ side ]:setAttachedOffsets( position, 0, 0, 0 )
				elseif k == MANIPULATION_ROTATE then
					MANIPULATOR_OBJECTS[ vehicle ][ k ][ side ]:setAttachedOffsets( OBJECTS_MANIPULATOR[ side ][ 1 ].pos, 0, 0, new_value )
				elseif k == MANIPULATION_CABLE then
					MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_CABLE ][ side ]:setScale( 1, 1, math_max( 1, 1, new_value ) )
					MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_DIVING ][ side ]:setAttachedOffsets( Vector3( 0, 0, OBJECTS_MANIPULATOR[ side ][ 5 ].pos.z * new_value ), 0, 0, 0 )
				end
			end
		else
			finished_sides = finished_sides + 1
		end
	end
end

function onClientSyncManipulator_handler( target_y, target_rz, target_scale_z, target_side, time )
	local vehicle = MANIPULATOR_DATA and MANIPULATOR_DATA.job_vehicle
	if not vehicle or IGNORE_SYNC[ target_side ] then return end

	local _, y, _, _, _, _ = getElementAttachedOffsets( MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_RETRACT ][ target_side ] )
	local _, _, _, _, _, rz = getElementAttachedOffsets( MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_ROTATE ][ target_side ] )
	local _, _, scale_z = getObjectScale( MANIPULATOR_OBJECTS[ vehicle ][ MANIPULATION_CABLE ][ target_side ] )

	if not SYNC_DATA then
		SYNC_DATA = {}
		if not SYNC_START_TICKS then SYNC_START_TICKS = {} end
		SYNC_START_TICKS[ target_side ] = {}
	end

	SYNC_DATA[ target_side ] = 
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

		[ MANIPULATION_CABLE ] = 
		{
			start_pos = scale_z,
			end_pos = target_scale_z,
		},
	}

	local manipulator_rot = SYNC_DATA[ target_side ][ MANIPULATION_ROTATE ]
	if manipulator_rot.start_pos > 180 and manipulator_rot.end_pos < 180 then
		manipulator_rot.end_pos = 360 + manipulator_rot.end_pos
	elseif manipulator_rot.start_pos < 180 and manipulator_rot.end_pos > 180 then
		manipulator_rot.end_pos = manipulator_rot.end_pos - 360
	end
	
	SYNC_START_TICKS[ target_side ] = { ticks = getTickCount(), time = time or SYNC_CONST_TIME }
end
addEvent( "onClientSyncManipulator", true )
addEventHandler( "onClientSyncManipulator", resourceRoot, onClientSyncManipulator_handler )

--[[
setTimer( function()
    localPlayer:setData( "coop_job_role_id", 2, false )
	
	local target_side = LEFT_BOAT_SIDE 
	localPlayer:setData( "fisherman_index", target_side, false )
    
    
    MANIPULATOR_SIDE = target_side
    ResetManipulator( false, localPlayer.vehicle )
    CreateFishermanActionController( target_side, localPlayer.vehicle )
    GEs.action_controller:toggle_controls( true, localPlayer.vehicle )

    setTimer( function()

		local lobby_data = {
			job_vehicle = localPlayer.vehicle,
			port_index = math.random( 1, #PORT_POINTS )
		}

		local port = PORT_POINTS[ lobby_data.port_index ]

		lobby_data.job_vehicle:setPosition( port.position )
		lobby_data.job_vehicle:setRotation( port.rotation + Vector3( 0, 0, 180 ) )
			
		lobby_data.job_vehicle.frozen = true
		lobby_data.job_vehicle.engineState = false
        onClientFisherManManipulatorObject_handler( MANIPULATION_FISH_FULL, target_side )
		--OnStartFisherManGame( lobby_data )
	end, 2050, 1 )
end, 1000, 1 )
--]]