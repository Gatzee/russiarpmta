-- CAI.lua
Import( "Globals" )

--[[
	setPedVehicleEnter( Ped, TargetVehicle, seat = 0 )
	setPedVehicleExit( Ped, seat = 0xFF )
	setPedVehicleDriveTo( Ped, TargetVehicle, px, py, pz, speed_limit = -1.0, hz = 0, hz = -1, distance = -1.0, hz = 0 )
	setKillPedOnFoot( Ped, TargetPed, time_in_mc = -1, hz = 0, hz = 0, hz = 0, hz = 1 )
	setPedMoveToPoint( Ped, move_type = 6, px, py, pz, distance = 0.5, hz = false, hz = false )
	removePedTask( Ped )
]]

local _removePedFromVehicle = removePedFromVehicle
local function removePedFromVehicle( ped )
	if ped ~= localPlayer then
		return _removePedFromVehicle( ped )
	end
end

enum "eAIPatterns" {
	"AI_PED_PATTERN_DEAD",
	"AI_PED_PATTERN_IDLE",
	"AI_PED_PATTERN_VEHICLE_ENTER",
	"AI_PED_PATTERN_IDLE_IN_VEHICLE",
	"AI_PED_PATTERN_VEHICLE_EXIT",
	"AI_PED_PATTERN_ATTACK_PED",
	"AI_PED_PATTERN_MOVE_TO_POINT",
}

CONST_PROCESSING_TIMES = 100

PROCESSING_TIMER = nil
AI_PEDS = AI_PEDS or { }
QUEUE_PATTERNS = QUEUE_PATTERNS or { }

local CONST_BLOCKED_PATTERNS = {
	[ AI_PED_PATTERN_DEAD ] = function( )
		return false
	end;

	[ AI_PED_PATTERN_VEHICLE_ENTER ] = function( ai_ped, new_pattern )
		if new_pattern == AI_PED_PATTERN_IDLE_IN_VEHICLE then
			return true
		end

		if ai_ped.vehicle then
			return true
		end
	end;

	[ AI_PED_PATTERN_VEHICLE_EXIT ] = function( ai_ped, new_pattern )
		if new_pattern == AI_PED_PATTERN_IDLE then
			return true
		end

		if not isPedInVehicle( ai_ped ) and not ai_ped.vehicle then
			return true
		end
	end;
}

local PATTERNS_HANDLER = {
	[ AI_PED_PATTERN_IDLE ] = function( ai_ped, ai_data )
		if isPedInVehicle( ai_ped ) then
			return
		end

		if not ai_data.pattern_init then
			ai_data.pattern_init = true
			ai_data.pattern_init_tick = getTickCount( );
		end

		ai_data.pattern_tick = getTickCount( );

		return _, true
	end;

	[ AI_PED_PATTERN_IDLE_IN_VEHICLE ] = function( ai_ped, ai_data )
		if not isPedInVehicle( ai_ped ) then return end

		if not ai_data.pattern_init then
			ai_data.pattern_init = true
			ai_data.pattern_init_tick = getTickCount( );
		end

		ai_data.pattern_tick = getTickCount( );

		return _, true
	end;

	[ AI_PED_PATTERN_VEHICLE_ENTER ] = function( ai_ped, ai_data )
		local pattern_data = ai_data.pattern_data
		if not pattern_data then return end

		if not isElement( pattern_data.vehicle ) or localPlayer.vehicle == pattern_data.vehicle and localPlayer.vehicleSeat == ( pattern_data.seat or 0 ) then
			removePedFromVehicle( ai_ped )
			return
		end

		if not ai_data.pattern_init then
			ai_data.pattern_init = true
			ai_data.pattern_init_tick = getTickCount( );
			setPedVehicleEnter( ai_ped, pattern_data.vehicle, pattern_data.seat or 0 )
		end

		if isPedInVehicle( ai_ped ) then
			warpPedIntoVehicle( ai_ped, pattern_data.vehicle, pattern_data.seat or 0 )
			return _, true
		end

		ai_data.pattern_tick = getTickCount( );

		return true
	end;

	[ AI_PED_PATTERN_VEHICLE_EXIT ] = function( ai_ped, ai_data )
		if not isPedInVehicle( ai_ped ) then
			removePedFromVehicle( ai_ped )
			return _, true
		end

		if not ai_data.pattern_init then
			ai_data.pattern_init = true
			ai_data.pattern_init_tick = getTickCount( );
			setPedVehicleExit( ai_ped )
		end

		ai_data.pattern_tick = getTickCount( );

		return true
	end;

	[ AI_PED_PATTERN_ATTACK_PED ] = function( ai_ped, ai_data )
		local pattern_data = ai_data.pattern_data
		if not pattern_data then return end

		if not isElement( pattern_data.target_ped ) or isPedDead( ai_ped ) or isPedDead( pattern_data.target_ped ) then
			return _, true
		end

		if not ai_data.pattern_init then
			ai_data.pattern_init = true
			ai_data.pattern_init_tick = getTickCount( );
			setKillPedOnFoot( ai_ped, pattern_data.target_ped, pattern_data.time_in_mc )
		end

		ai_data.pattern_tick = getTickCount( );
		setPedAimTarget( ai_ped, pattern_data.target_ped.position.x, pattern_data.target_ped.position.y, pattern_data.target_ped.position.z )

		return true
	end;

	[ AI_PED_PATTERN_MOVE_TO_POINT ] = function( ai_ped, ai_data )
		local pattern_data = ai_data.pattern_data
		if not pattern_data then return end

		if pattern_data.in_vehicle then
			if not isPedInVehicle( ai_ped ) then
				pattern_data.in_vehicle = nil
				removePedTask( ai_ped )
				setPedMoveToPoint( ai_ped, pattern_data.move_type, pattern_data.x, pattern_data.y, pattern_data.z, pattern_data.distance )
			end
		else
			if isPedInVehicle( ai_ped ) and ai_ped.vehicleSeat == 0 then
				pattern_data.in_vehicle = true
				removePedTask( ai_ped )
				setPedVehicleDriveTo( ai_ped, ai_ped.vehicle, pattern_data.x, pattern_data.y, pattern_data.z, pattern_data.speed_limit, _, _, 0 )
			end
		end

		if not ai_data.pattern_init then
			ai_data.pattern_init = true
			ai_data.pattern_init_tick = getTickCount( );

			if isPedInVehicle( ai_ped ) and isElement( ai_ped.vehicle ) then
				if ai_ped.vehicleSeat ~= 0 then
					AddAIPedPatternInQueue( ai_ped, AI_PED_PATTERN_VEHICLE_EXIT )
					AddAIPedPatternInQueue( ai_ped, AI_PED_PATTERN_MOVE_TO_POINT, pattern_data )
					return _, true
				else
					pattern_data.in_vehicle = true
					setPedVehicleDriveTo( ai_ped, ai_ped.vehicle, pattern_data.x, pattern_data.y, pattern_data.z, pattern_data.speed_limit, _, _, pattern_data.distance )
				end
			else
				setPedMoveToPoint( ai_ped, pattern_data.move_type, pattern_data.x, pattern_data.y, pattern_data.z, pattern_data.distance or 1 )
			end
		end

		ai_data.pattern_tick = getTickCount( );

		if ( ( ai_ped.vehicle or ai_ped ).position - Vector3( pattern_data.x, pattern_data.y, pattern_data.z ) ).length <= ( pattern_data.distance or 1 ) then
			return _, true
		end

		if not isPedDoingTask( ai_ped, "TASK_SIMPLE_GO_TO_POINT" ) and not isPedDoingTask( ai_ped, "TASK_COMPLEX_CAR_DRIVE_TO_POINT" ) then
			return _, true
		end

		return true
	end;
}

function ProcessingAIElements( )
	for ai_ped, ai_data in pairs( AI_PEDS ) do
		if isElement( ai_ped ) then
			if isElementStreamedIn( ai_ped ) then
				if PATTERNS_HANDLER[ ai_data.pattern ] then
					local continue, success = PATTERNS_HANDLER[ ai_data.pattern ]( ai_ped, ai_data )
					if not continue then
						local pattern_data = ai_data.pattern_data

						if success and pattern_data and pattern_data.end_callback then
							pattern_data.end_callback.func( ai_ped, pattern_data.end_callback.args and unpack( pattern_data.end_callback.args ) )
						end

						ResetAIPedPattern( ai_ped )

						local queue_data = QUEUE_PATTERNS[ ai_ped ] and QUEUE_PATTERNS[ ai_ped ][ 1 ]
						if success and queue_data then
							if queue_data.wait_time then
								queue_data.wait_time = queue_data.wait_time - CONST_PROCESSING_TIMES

								if queue_data.wait_time <= 0 then
									queue_data.wait_time = nil
								end
							else
								local pattern_data = queue_data.pattern_data
								local is_setup = SetAIPedPattern( ai_ped, queue_data.pattern, pattern_data )
								if is_setup then
									if pattern_data and pattern_data.start_callback then
										pattern_data.start_callback.func( ai_ped, unpack( pattern_data.start_callback.args ) )
									end
									table.remove( QUEUE_PATTERNS[ ai_ped ], 1 )

									if not QUEUE_PATTERNS[ ai_ped ][ 1 ] then
										QUEUE_PATTERNS[ ai_ped ] = nil
									end
								end
							end
						end
					end
				else
					QUEUE_PATTERNS[ ai_ped ] = nil
				end
			end
		else
			AI_PEDS[ ai_ped ] = nil
			QUEUE_PATTERNS[ ai_ped ] = nil
		end
	end

	if not next( AI_PEDS ) then
		killTimer( sourceTimer )
	end
end

function CreateAIPed( model, position, rotation )
	if not isTimer( PROCESSING_TIMER ) then
		PROCESSING_TIMER = setTimer( ProcessingAIElements, CONST_PROCESSING_TIMES, 0 )
	end

	local ai_ped = isElement( model ) and model or createPed( model, position, rotation )

	AI_PEDS[ ai_ped ] = {
		ai_init_tick = getTickCount( );

		pattern = AI_PED_PATTERN_IDLE;
		pattern_data = { };
		pattern_tick = getTickCount( );
	}

	return ai_ped
end

function ClearAIPed( ai_ped )
	CleanupAIPedPatternQueue( ai_ped )
	AI_PEDS[ ai_ped ] = nil
end

function SetAIPedPattern( ai_ped, pattern, pattern_data )
	if not isElement( ai_ped ) or not isElementStreamedIn( ai_ped ) then return end

	local ai_data = AI_PEDS[ ai_ped ]
	if not ai_data then return end

	if CONST_BLOCKED_PATTERNS[ ai_data.pattern ] and not CONST_BLOCKED_PATTERNS[ ai_data.pattern ]( ai_ped, pattern ) then
		return false
	end

	ai_data.pattern_init = nil
	ai_data.pattern = pattern
	ai_data.pattern_data = pattern_data
	ai_data.pattern_tick = getTickCount( );

	return true
end

function AddAIPedPatternInQueue( ai_ped, pattern, pattern_data, wait_time )
	if not AI_PEDS[ ai_ped ] then return end

	if not QUEUE_PATTERNS[ ai_ped ] then
		QUEUE_PATTERNS[ ai_ped ] = { }
	end

	table.insert( QUEUE_PATTERNS[ ai_ped ], {
		pattern = pattern;
		pattern_data = pattern_data;
		wait_time = wait_time;
	} )
end

function CleanupAIPedPatternQueue( ai_ped )
	if not AI_PEDS[ ai_ped ] then return end

	QUEUE_PATTERNS[ ai_ped ] = nil
	ResetAIPedPattern( ai_ped )
end

function ResetAIPedPattern( ai_ped )
	if not isElement( ai_ped ) then return end
	if isPedInVehicle( ai_ped ) then
		SetAIPedPattern( ai_ped, AI_PED_PATTERN_IDLE_IN_VEHICLE )
	else
		SetAIPedPattern( ai_ped, AI_PED_PATTERN_IDLE )
	end
end

addEventHandler( "onClientPedWasted", root, function( )
	if not AI_PEDS[ source ] then return end

	SetAIPedPattern( source, AI_PED_PATTERN_DEAD )
end )

function SetAIPedMoveByRoute( ai_ped, route, vehicle, callback, ... )
	if vehicle then
		AddAIPedPatternInQueue( ai_ped, AI_PED_PATTERN_VEHICLE_ENTER, {
			vehicle = vehicle;
			seat = 0;
		} )
	end

	for i, route_data in pairs( route ) do
		local pattern_data = {
			x = route_data.x;
			y = route_data.y;
			z = route_data.z;
			distance = route_data.distance;
			speed_limit = route_data.speed_limit;
			move_type = route_data.move_type;
		}

		if i == #route and callback then
			pattern_data.end_callback = {
				func = callback,
				args = { ... },
			}
		end

		AddAIPedPatternInQueue( ai_ped, AI_PED_PATTERN_MOVE_TO_POINT, pattern_data, route_data.wait_time )
	end

	ResetAIPedPattern( ai_ped )
end

function TestUseRoute( ai_ped, vehicle )
	CleanupAIPedPatternQueue( ai_ped )
	AddAIPedPatternInQueue( ai_ped, AI_PED_PATTERN_MOVE_TO_POINT, {
		x = -2375.657, y = 842.335, z = 20.103;

		end_callback = {
			func = function( ai_ped, weapon, ammo )
				givePedWeapon( ai_ped, weapon, ammo, true )
			end;
			args = { 31, 200 }
		}
	} )
	AddAIPedPatternInQueue( ai_ped, AI_PED_PATTERN_ATTACK_PED, {
		target_ped = localPlayer;
	} )
end

function CreatePedFollow( ped )
	local self = { }

	self.destroy = function( )
		self:stop( )
		DestroyTableElements( self )
		setmetatable( self, nil )
	end

	self.start = function( self, ped_b )
		self.follow_ped = ped_b
	end

	self.stop = function( self )
		self.follow_ped = nil

		if isElement( ped ) then
			removePedTask( ped )
		end
	end

	self.check_follow = function( )
		if not isElement( ped ) then
			self:destroy( )
			return
		end

		if isElement( self.follow_ped ) then
			ped.dimension = self.follow_ped.dimension
			ped.interior = self.follow_ped.interior

			local position = self.follow_ped.position
			local px, py, pz = position.x, position.y, position.z

			if self.same_vehicle then
				local follow_ped_in_vehicle = isPedInVehicle( self.follow_ped )
				local ped_in_vehicle = isPedInVehicle( ped )
				if follow_ped_in_vehicle and not ped_in_vehicle then
					local free_seat
					for i = 1, math.max( getVehicleMaxPassengers( self.follow_ped.vehicle ), 1 ) do
						if not getVehicleOccupant( self.follow_ped.vehicle, i ) then
							free_seat = i
							break
						end
					end
					warpPedIntoVehicle( ped, self.follow_ped.vehicle, free_seat )
				elseif follow_ped_in_vehicle and ped_in_vehicle then
					return
				elseif not follow_ped_in_vehicle and ped_in_vehicle then
					removePedFromVehicle( ped )
					local vector = ( self.follow_ped.position - ped.position )
					ped.position = self.follow_ped.position + vector * 0.4
				end
			end

			if isPedInVehicle( self.follow_ped ) then
				if getPedOccupiedVehicleSeat( ped ) == 0 then
					setPedVehicleDriveTo( ped, ped.vehicle, px, py, pz, self.speed_limit or -1, 0, -1, self.distance or 1, 0 )
				end
			else
				if isElementStreamedIn( ped ) then
					setPedMoveToPoint( ped, self.move_type or 6, px, py, pz, self.distance or 1, false, false )
				end
			end
		end
	end
	self.timer = setTimer( self.check_follow, 500, 0 )

	return self
end

function CreatePedShoot( ped, ignore_remove_ped_b )
	local self = { }

	self.destroy = function( )
		if ignore_remove_ped_b then self.shoot_ped = nil end
		self.stop( )
		DestroyTableElements( self )
		setmetatable( self, nil )
	end

	self.start = function( self, ped_b )
		self.shoot_ped = ped_b
		setPedControlState( ped, "fire", true )
	end

	self.stop = function( self )
		if isElement( ped ) then
			setPedControlState( ped, "fire", false )
		end
	end

	self.shoot_check = function( )
		if not isElement( ped ) then
			self:destroy( )
			return
		end

		if isElement( self.shoot_ped ) then
			local spread = self.spread or 0
			if self.speed_spread then
				if self.shoot_ped.velocity.length <= 0.02 then
					spread = self.speed_spread[ 1 ]
				else
					spread = self.speed_spread[ 2 ]
				end
			end

			local target_position = self.shoot_ped.position
			local shoot_vec = target_position - ped.position

			local cross
			if ( target_position - ped.position ).length <= ( self.distance_no_spread or 0 ) then
				cross = Vector3( )
				self.shoot_ped.health = self.shoot_ped.health - 5
			else
				local precision = 100
				cross = shoot_vec:getNormalized( ):cross( Vector3(
					math.random( -spread * precision, spread * precision ) / precision,
					math.random( -spread * precision, spread * precision ) / precision,
					math.random( -spread * precision, spread * precision ) / precision
				) )
			end

			local dx, dy = target_position.x - ped.position.x, target_position.y - ped.position.y
			ped.rotation = Vector3( 0, 0, math.deg( math.atan2( dy, dx ) ) - 90 )
			setPedAimTarget( ped, target_position + cross )
		end
	end
	self.timer = setTimer( self.shoot_check, 100, 0 )

	return self
end