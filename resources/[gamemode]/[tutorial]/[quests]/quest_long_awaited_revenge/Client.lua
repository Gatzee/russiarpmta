loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CQuest" )
Extend( "CActionTasksUtils" )
Extend( "CUI" )
Extend( "CAI" )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
	CQuest( QUEST_DATA )
end )

function CreateEnemyBots( bots_data )
	local result = {}
	for k, v in ipairs( bots_data ) do
		local bot = CreateAIPed( v.skin_id, v.pos, v.rot.z )
		givePedWeapon( bot, 29, 1000, true )
		setPedStat( bot, 76, 600 )
		setPedStat( bot, 22, 600 )
		LocalizeQuestElement( bot )
		table.insert( result, bot )
	end
	return result
end

function CreateAttackBotsInterface( bots, target )
	local self = {}
	self.bots = bots
	self.shots = {}
	self.check = function( self )
		for k, v in pairs( self.bots ) do
			if not v.dead then
				if (v.position - localPlayer.position).length < 80 and isLineOfSightClear( v.position, localPlayer.position, true, false, true, true, true, false, false, localPlayer ) then
					if not self.shots[ v ] then self.shots[ v ] = CreatePedShoot( v ) end
					self.shots[ v ]:start( localPlayer )
				elseif self.shots[ v ] then
					self.shots[ v ]:stop()
				end
			else
				if self.shots[ v ] then self.shots[ v ]:destroy() end
				self.bots[ k ] = nil
			end
		end
	end

	self.destroy = function( self )
		DestroyTableElements( self.shots or {})
		if isTimer( self.check_tmr ) then killTimer( self.check_tmr ) end
		setmetatable( self, nil )
	end
	
	self.check_tmr = setTimer( function()
		self:check()
	end, 250, 0 )

	return self
end

function CreateStaticVehicle( data )
	local vehicle = createVehicle( data.vehicle_id, data.pos, data.rot )
	vehicle:SetNumberPlate( "1:м" .. math.random( 111, 999 ) .. "кр178" )
	vehicle:SetWindowsColor( 0, 0, 0, 255 )
	LocalizeQuestElement( vehicle )
	vehicle:SetColor( 0, 0, 0 )
	if data.frozen then
		vehicle.frozen = true
		vehicle.health = 400
	end
	return vehicle
end

function CreateQuestVehicles( vehs_data )
	local result = {}
	for k, v in ipairs( vehs_data ) do
		table.insert( result, CreateStaticVehicle( v ) )
	end
	return result
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

function CreateStaticObjects( objects_data )
	local result = {}
	for k, v in pairs( objects_data ) do
		local obj = createObject( v.id, v.pos, v.rot )
		LocalizeQuestElement( obj )
		table.insert( result, obj )
	end
	return result
end