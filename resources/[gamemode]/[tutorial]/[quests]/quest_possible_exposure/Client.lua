loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

function CreateStaticBots( bots_data, off_dmg, health, stats )
	local result = {}
	for k, v in pairs( bots_data ) do
		local bot = CreateAIPed( v.skin_id, v.pos, v.rot.z )
		bot.health = health or 100
		givePedWeapon( bot, 29, 1000, true )
		setPedStat( bot, 76, stats or 1000 )
		setPedStat( bot, 22, stats or 1000 )
		LocalizeQuestElement( bot )
		SetUndamagable( bot, off_dmg )
		table.insert( result, bot )
	end
	return result
end

function CreateQuestVehicle( data )
	local vehicle = createVehicle( data.vehicle_id, data.pos, data.rot )
	vehicle:SetNumberPlate( "1:м" .. math.random( 111, 999 ) .. "кр178" )
	vehicle:SetWindowsColor( 0, 0, 0, 255 )
	LocalizeQuestElement( vehicle )
	vehicle:SetColor( 0, 0, 0 )
	return vehicle
end

function CreateStaticElements()
	GEs.static_vehs = {}
	for k, v in pairs( QUEST_CONF.positions.static_vehs ) do
		GEs.static_vehs[ k ] = CreateQuestVehicle( v )
	end

	GEs.east_cartel_static_bots = CreateStaticBots( QUEST_CONF.positions.east_cartel_static_bots, true )
	GEs.west_cartel_static_bots = CreateStaticBots( QUEST_CONF.positions.west_cartel_static_bots, true )
	GEs.countryside_static_bots = CreateStaticBots( QUEST_CONF.positions.countryside_static_bots, true )

	GEs.attack_interface_1 = CreateAttackBotsInterface( table.copy( GEs.east_cartel_static_bots ), table.copy( GEs.west_cartel_static_bots ), 30 )
	GEs.attack_interface_2 = CreateAttackBotsInterface( table.copy( GEs.west_cartel_static_bots ), table.copy( GEs.east_cartel_static_bots ), 30 )
	GEs.attack_interface_3 = CreateAttackBotsInterface( table.copy( GEs.countryside_static_bots ), { }, 0 )

	GEs.func_refresh_1 = function()
		if not GEs.attack_interface_1 then return end
		GEs.attack_interface_1:refresh_targets()
		GEs.refresh_targets_i2_tmr = setTimer( GEs.func_refresh_2, 500, 1 )
	end

	GEs.func_refresh_2 = function()
		if not GEs.attack_interface_2 then return end
		GEs.attack_interface_2:refresh_targets()
		GEs.refresh_targets_i3_tmr = setTimer( GEs.func_refresh_3, 500, 1 )
	end

	GEs.func_refresh_3 = function()
		if not GEs.attack_interface_3 then return end
		GEs.attack_interface_3:refresh_targets()
	end
	GEs.refresh_targets_i1_tmr = setTimer( GEs.func_refresh_1, 500, 0 )

	GEs.effects = {}
	for k, v in pairs( QUEST_CONF.positions.effects ) do
		GEs.effects[ k ] = createEffect( v.effect_id, v.pos, v.rot, 1000, true )
	end
end

function CreateAttackBotsInterface( source_bots, enemy_bots, distance_no_spread, ignore_player )
	local self = {}

	self.targets = {}
	self.source_bots = source_bots
	self.enemy_bots = enemy_bots
	if not ignore_player then
		table.insert( self.enemy_bots, localPlayer )
	end

	self.spread = 0
	self.speed_spread = { 2.5, 4 }
	self.distance_no_spread = distance_no_spread or 10

	self.init = function( self )
		self:refresh_targets( true )
	end

	self.get_target = function( self, source_bot )
		local bot_position = source_bot.position
		local target_ped, min_distance = nil, math.huge
		
		for _, enemy_bot in pairs( self.enemy_bots ) do
			if not enemy_bot.dead then
				local c_distnace = (bot_position - enemy_bot.position).length
				if c_distnace < min_distance then
					target_ped, min_distance = enemy_bot, c_distnace
				end
			end
		end

		return target_ped
	end
	
	self.set_attack = function( self, source_bot, state )
		if isElement( source_bot ) then
			setPedControlState( source_bot, "fire", state )
		end
	end

	self.refresh_targets = function( self, is_init )
		for k, v in pairs( self.source_bots  ) do
			if isElement( v ) and not v.dead then
				local target_bot = self:get_target( v )
				if isElement( target_bot ) and self.targets[ v ] ~= target_bot or target_bot == localPlayer then
					self.targets[ v ] = target_bot

					local spread = self.spread
					if self.speed_spread then
						spread = self.targets[ v ].velocity.length <= 0.02 and self.speed_spread[ 1 ] or self.speed_spread[ 2 ]
					end

					local target_position = self.targets[ v ].position
					local shoot_vec = target_position - v.position

					local cross
					local is_line_clear = isLineOfSightClear( v.position, localPlayer.position, true, false, true, true, true, false, false, localPlayer )
					if self.targets[ v ] == localPlayer and ( target_position - v.position ).length <= self.distance_no_spread and is_line_clear then
						cross = Vector3( )
						self.targets[ v ].health = math.max( 0, self.targets[ v ].health - 10 )
					else
						local precision = 100
						cross = shoot_vec:getNormalized( ):cross( Vector3(
							math.random( -spread * precision, spread * precision ) / precision,
							math.random( -spread * precision, spread * precision ) / precision,
							math.random( -spread * precision, spread * precision ) / precision
						) )
					end

					local dx, dy = target_position.x - v.position.x, target_position.y - v.position.y
					v.rotation = Vector3( 0, 0, math.deg( math.atan2( dy, dx ) ) - 90 )
					
					local func = function()
						if isElement( v ) then
							setPedAimTarget( v, target_position + cross )
							setPedControlState( v, "fire", true )
						end
					end

					if is_init then
						self.anim_tmr = setTimer( func, math.random( 50, 10000 ), 1 )
					else
						func()
					end
				end
			else
				self.source_bots[ k ] = nil
			end
		end
	end

	self.destroy = function( self )
		for k, v in pairs( self.source_bots ) do
			if isElement( v ) and not v.dead then
				setPedControlState( v, "fire", false )
			end
		end
		if isTimer( self.anim_tmr ) then killTimer( self.anim_tmr ) end
		setmetatable( self, nil )
	end

	self:init()

	return self
end

function CreateFollowInterface()
	local self = {}

	self.follows = {}
	self.init = function( self )
		addEventHandler( "onClientPlayerVehicleEnter", localPlayer, self.on_player_veh_enter )
		addEventHandler( "onClientPlayerVehicleExit", localPlayer, self.on_player_veh_exit )
	end

	self.on_player_veh_enter = function( vehicle )
		local seat = 1
		for k, v in pairs( self.follows ) do
			if isElement( k ) then
				self:stop_follow( k )
				AddAIPedPatternInQueue( k, AI_PED_PATTERN_VEHICLE_ENTER, {
					vehicle = vehicle;
					seat = seat;
				} )
				seat = seat + 1
			end
		end
	end

	self.on_player_veh_exit = function()
		for k, v in pairs( self.follows ) do
			AddAIPedPatternInQueue( k, AI_PED_PATTERN_VEHICLE_EXIT, {
				end_callback = {
					func = function()
						self:follow( k )
					end,
					args = { },
				}
			} )
		end
	end

	self.follow = function( self, ped, distance )
		self:stop_follow( ped )
		
		self.follows[ ped ] = CreatePedFollow( ped )
		self.follows[ ped ].distance = distance or 5
		self.follows[ ped ]:start( localPlayer )
	end

	self.stop_follow = function( self, ped )
		if self.follows[ ped ] then
			self.follows[ ped ]:destroy()
			self.follows[ ped ] = nil
		end
	end

	self.destroy = function()
		DestroyTableElements( self.follows or {} )
		removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, self.on_player_veh_enter )
		removeEventHandler( "onClientPlayerVehicleExit", localPlayer, self.on_player_veh_exit )
		setmetatable( self, nil )
	end

	self:init()

	return self
end

function WatchToElementInterface( element )
	local self = {}

	self.watch = function( self, element )
		self:stop_watch()
		self._obeservedElement = element

		local x, y, z = getCameraMatrix()
		self.camera_position = Vector3( x, y, z )
		setCameraMatrix( self.camera_position, self._obeservedElement.position )

		addEventHandler( "onClientPreRender", root, self.render_handler )
	end

	self.stop_watch = function( self )
		removeEventHandler( "onClientPreRender", root, self.render_handler  )
	end

	self.change_camera_position = function( self, new_position )
		local change_time = 0.5
		fadeCamera( false, change_time )
		if isTimer( self.change_tmr ) then killTimer( self.change_tmr ) end
		self.change_tmr = setTimer( function()
			self:stop_watch()

			self.camera_position = new_position
			setCameraMatrix( self.camera_position, self._obeservedElement.position )
			
			self:watch( self._obeservedElement )
			fadeCamera( true, change_time )
		end, (change_time * 1000) + 10, 1 )
	end

	self.change_camera_target = function( self, element, new_position )
		local change_time = 0.5
		fadeCamera( false, change_time )
		if isTimer( self.change_tmr ) then killTimer( self.change_tmr ) end
		self.change_tmr = setTimer( function()
			self:stop_watch()

			self._obeservedElement = element
			if new_position then
				self.camera_position = new_position
			end
			setCameraMatrix( self.camera_position, self._obeservedElement.position )
			
			self:watch( self._obeservedElement )
			fadeCamera( true, change_time )
		end, (change_time * 1000) + 10, 1 )
	end

	self.render_handler = function()
		setCameraMatrix( self.camera_position, self._obeservedElement.position )
	end

	self.destroy = function( self )
		if isTimer( self.change_tmr ) then killTimer( self.change_tmr ) end
		self:stop_watch()
		setmetatable( self, nil )
	end
	
	if isElement( element ) then
		self:watch( element )
	end

	return self
end

function MoveCameraAndWatchElement( from, to, duration, element )
    local self = { }

    local from = from or { getCameraMatrix( ) }

    local easing = "Linear"
    local start = getTickCount( )

    self.draw = function( )
        local progress = math.min( 1, ( getTickCount( ) - start ) / duration )
        local cx, cy, cz = interpolateBetween( from[ 1 ], from[ 2 ], from[ 3 ], to.x, to.y, to.z, progress, easing )
		
		local e_position = element.position
        setCameraMatrix( cx, cy, cz, e_position.x, e_position.y, e_position.z )

        if progress >= 1 then
            self:destroy( )
        end
    end
    
    self.destroy = function( self )
        removeEventHandler( "onClientRender", root, self.draw )
        setmetatable( self, nil )
    end

    addEventHandler( "onClientRender", root, self.draw )

    return self
end

function ToggleMoveControls( state )
	for k, v in pairs( { "jump", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right", "sprint", "crouch", "enter_exit", "enter_passenger", "walk" } ) do
		toggleControl( v, state )
	end
end