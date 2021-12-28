-- SInterior

Import( "SPlayer" )

if not _GARAGES then
	_GARAGES = { }
end

addEvent( "onGarageToggleRequest", true )

function GarageInteractive( conf )
	local door      = Door( conf )

	conf.ignore_marker = true
    local tpoint    = TeleportPoint( conf )

	conf.tpoint 	= tpoint
	conf.door 		= door
	conf.childs 	= { }

    tpoint.door 	= door
	door.tpoint 	= marker

	tpoint.colshape:setData( "garage", true )
    tpoint.accepted_elements = { player = true, vehicle = true }
    tpoint.slowdown_coefficient = nil
    tpoint.text = nil
	tpoint.keypress = "ignore"

	function door.OnToggleRequest( player )
		local colshape = source
		local garage = _GARAGES[ colshape ]
		if garage then
			if garage.CheckAccess then
				local result, err = garage:CheckAccess( player )
				if not result then
					if err then player:ShowError( err ) end
					return
				end
			end
			garage.door:Toggle( )
			colshape:setData( "state", garage.door.state )

			for k, v in pairs( garage.childs ) do
				v:Toggle( )
			end

		end
	end
	addEventHandler( "onGarageToggleRequest", tpoint.colshape, door.OnToggleRequest )

	conf.destroy = function( self )
		if conf.door then conf.door:destroy( ) end
		if conf.tpoint then conf.tpoint:destroy( ) end
	end

	_GARAGES[ tpoint.colshape ] = conf

	return conf
end

function DoorInteractive( conf )
	local door      = Door( conf )
    door.open_text  = door.open_text or "ALT Взаимодействие"
    door.close_text = door.close_text or "ALT Взаимодействие"

	conf.radius 	= conf.radius or 3
	conf.ignore_marker = true
    local tpoint    = TeleportPoint( conf )

	conf.tpoint 	= tpoint
	conf.door 		= door

    tpoint.door 	= door
	door.tpoint 	= marker

    tpoint.PreJoin = function( self, player )
		if self.CheckAccess then
			local result, err = self:CheckAccess( player )
			if not result then return result, err end
		end
        self.text = self.door.state and self.door.open_text or self.door.close_text
        return true
	end

	tpoint.PostJoin = function( self, player )
		if self.CheckAccess then
			local result, err = self:CheckAccess( player )
			if not result then return result, err end
		end
        self.door:Toggle( )
        self.OnLeave ( player )
        self.OnHit( player, true )
	end

	conf.destroy = function( self )
		if conf.door then conf.door:destroy( ) end
		if conf.tpoint then conf.tpoint:destroy( ) end
	end

	return conf
end

function Door( config )
	local self = config
	if not self then return end
	if not self.x or not self.y or not self.z then return end

	if not self.move or next( self.move ) == nil then
		self.move = { rz = 90 }
	end

	self.rx, self.ry, self.rz 				= self.rx or 0, self.ry or 0, self.rz or 0

	self.model								= self.model or 17289
	self.duration 							= self.duration or 300

	self.object 							= Object( self.model, Vector3( self.x, self.y, self.z ), Vector3( self.rx, self.ry, self.rz ) )
	self.object.breakable					= false
	self.object.interior 					= self.interior or 0
	self.object.dimension					= self.dimension or 0
	self.object.frozen 						= true
	self.object.damageProof 				= true
	self.interconnected						= false

	self.state = false
	self.duration_lock = 0

	self.Open = function( self )
		if self.duration_lock + self.duration >= getTickCount( ) then return end
		if not self.state then
			local position = Vector3( self.x, self.y, self.z )
			local rotation = Vector3( self.rx, self.ry, self.rz )

			self.rotation_delta = Vector3( self.move.rx or 0, self.move.ry or 0, self.move.rz or 0 )
			self.target_rotation = rotation + self.rotation_delta

			position = position + Vector3( self.move.x or 0, self.move.y or 0, self.move.z or 0 )

			self.object:move( self.duration, position, self.rotation_delta, "OutQuad" )
			self.state = true
			self.duration_lock = getTickCount( )

			if self.interconnected then
				if not self.interconnected.state then
					self.interconnected:Open( )
				end
			end

			return true, "Opened"
		end
	end

	self.Close = function ( self )
		if self.duration_lock + self.duration >= getTickCount( ) then return end
		if self.state then
			local position = Vector3( self.x, self.y, self.z )
			local rotation = - self.rotation_delta

			--self.object.rotation = self.target_rotation
			self.object:move( self.duration, position, rotation, "OutQuad" )

			self.state = false
			self.duration_lock = getTickCount( )

			self.rotation_delta = nil
			self.target_rotation = nil

			if self.interconnected then
				if self.interconnected.state then
					self.interconnected:Close( )
				end
			end

			return true, "Closed"
		end
	end

	self.Toggle = function( self )
		if self.state then
			return self:Close( )
		else
			return self:Open( )
		end
	end

	self.destroy = function( self )
		if isElement( self.object ) then self.object:destroy( ) end
	end

	return self
end

TPOINT_FNS = {
	SetGPS = function( self, state )
		self.gps = state
		self.element:setData( "gps", state )
	end, 

	SetText = function( self, text )
		self.marker_text = text
		self.element:setData( "text", text )
	end, 

	GetText = function( self )
		return self.element:getData( "text" )
	end, 

	SetImage = function( self, image )
		local is_table = type( image ) == "table"
		local image_file = is_table and image[ 1 ] or image
		image_file = image_file:sub( 1, 1 ) == ":" and image_file or ":"..THIS_RESOURCE_NAME .. "/" .. image_file

		if is_table then
			image[ 1 ] = image_file
		else
			image = image_file
		end
		self.marker_image = image
		self.element:setData( "image", image )
	end, 

	GetImage = function( self )
		return self.element:getData( "image" )
	end, 

	SetDropImage = function( self, image )
		local is_table = type( image ) == "table"
		local image_file = is_table and image[ 1 ] or image
		image_file = image_file:sub( 1, 1 ) == ":" and image_file or ":"..THIS_RESOURCE_NAME .. "/" .. image_file

		if is_table then
			image[ 1 ] = image_file
		else
			image = image_file
		end

		self.dropimage = image
		self.element:setData( "dropimage", image )
	end, 

	GetDropImage = function( self )
		return self.element:getData( "dropimage" )
	end, 

	StartLookingForVehicleActions = function( self, player )
		if self.handled_events[ player ] == nil then
			addEventHandler( "onPlayerVehicleEnter", player, self.OnVehicleActionEnter )
			addEventHandler( "onPlayerVehicleExit", player, self.OnVehicleActionExit )
			self.handled_events[ player ] = true
		end
	end, 

	StopLookingForVehicleActions = function( self, player )
		if self.handled_events[ player ] ~= nil then
			removeEventHandler( "onPlayerVehicleEnter", player, self.OnVehicleActionEnter )
			removeEventHandler( "onPlayerVehicleExit", player, self.OnVehicleActionExit )
			self.handled_events[ player ] = nil
		end
	end, 

	destroy = function( self )
		if type( self.elements ) == "table" then
			for i, element in pairs( self.elements ) do

				if isTimer( i ) then killTimer( i ) end
				if isTimer( element ) then killTimer( element ) end

				if isElement( i ) then destroyElement( i ) end
				if isElement( element ) then destroyElement( element ) end

			end

			self.elements = { }
		end
		if isElement( self.element ) then destroyElement( self.element ) end
		if isElement( self.colshape ) then destroyElement( self.colshape ) end
		if isElement( self.marker ) then destroyElement( self.marker ) end

		for i, v in pairs( self.handled_events ) do
			self.OnLeave( i )
		end

		setmetatable( self, nil )
		return true
	end, 
}

function TeleportPoint( config )
	local self = config
	if not self then return end
	if not self.x or not self.y or not self.z then return end
	local teleport_points   = getElementsByType( "teleport_points" )
	local teleport_point_id = self.id or ( "teleport_point_%s" ):format( #teleport_points )
	local teleport_element  = Element( "teleport_points", teleport_point_id )

	setmetatable( self, { __index = TPOINT_FNS } )

	self.id                   = teleport_point_id
	self.element_id           = teleport_point_id
	self.element              = teleport_element
	self.radius               = self.radius or 1
	self.name                 = self.name or self.id
	self.ignore               = { }
	self.slowdown_coefficient = self.slowdown_coefficient or 5

	self.handled_events = { }
	self.element:setData( "name", self.name )

	self.interior  = self.interior or 0
	self.dimension = self.dimension or 0

	self.element.position = Vector3( self.x, self.y, self.z )
	self.element.interior = self.interior
	self.element.dimension = self.dimension

	self.accepted_elements = self.accepted_elements or { player = true }
	if self.keypress == nil then self.keypress = "lalt" end
	if self.text == nil and self.keypress then self.text = ( "Нажмите %s" ):format( utf8.upper( self.keypress ) ) end

	-- Точка входа игрока
	if self.polygon then
		self.colshape = ColShape.Polygon( unpack( self.polygon ) )
	elseif self.cuboid then
		self.colshape = ColShape.Cuboid( unpack( self.cuboid ) )
	else
		self.colshape = ColShape.Sphere( self.element.position, self.radius )
	end

	self.colshape.interior = self.element.interior
	self.colshape.dimension = self.element.dimension
	self.colshape:setParent( self.element )

	self.OnVehicleActionEnter = function( vehicle )
		self.OnLeave( vehicle )
		if vehicle:isWithinColShape( self.colshape ) then
			self.OnHit( vehicle, self.colshape.dimension == vehicle.dimension )
		end
	end

	self.OnVehicleActionExit = function( vehicle )
		if self.accepted_elements.vehicle and not self.accepted_elements.player then
			self.OnLeave( vehicle, true, source )
		else
			self.OnLeave( source )
			if source:isWithinColShape( self.colshape ) then
				self.OnHit( source, self.colshape.dimension == source.dimension )
			end
		end
	end

	if not self.ignore_marker then
		local px, py, pz = getElementPosition( self.colshape )
		local r,  g,  b, a  = 255, 0, 0, 255
		if self.color then
			r, g, b, a = unpack( self.color )
			if not a then a = 255 end
		end
		self.marker           = createMarker( px, py, pz - 1 , "cylinder", self.radius, r, g, b, a )
		self.marker.interior  = self.interior
		self.marker.dimension = self.dimension
		self.marker: setParent( self.element )
	end

	if self.marker_text then self:SetText( self.marker_text ) end
	if self.marker_image then self:SetImage( self.marker_image ) end
	if self.gps then self:SetGPS( self.gps ) end

	self.OnHit = function( element, dimension_match )
		if not dimension_match or self.element.interior ~= element.interior then return end
		local element_type = getElementType( element )
		if not self.accepted_elements[ element_type ] then return end
		local player = element
		if element_type == "vehicle" then
			player = getVehicleOccupant( element )
		end
		if player and not self.accepted_elements.vehicle and player.vehicle then return end
		if self.ignore[ element ] then return end
		if not isElement( player ) or not self.accepted_elements[ element_type ] then return end
		if self.locked then return end
		if self.PreJoin then
			local success, err = self:PreJoin( player )
			if not success then
				if err then player:ShowError( err )  end
				return
			end
		end
		if element_type == "vehicle" and self.slowdown_coefficient then
			element.velocity = element.velocity/self.slowdown_coefficient
		end
		if self.vehicle_text and element_type == "vehicle" then
			player:ShowInfo( self.vehicle_text )
		elseif self.text then 
			player:ShowInfo( self.text ) 
		end
		
		self:StartLookingForVehicleActions( player )

		if self.keypress == "ignore" then
			return true
		elseif self.keypress then
			bindKey( player, self.keypress, "down", self.OnJoin )
		else
			self.OnJoin( player )
		end
	end
	addEventHandler( "onColShapeHit", self.colshape, self.OnHit )

	self.OnLeave = function( element, dimension_match, on_vehicle_exit_player )
		local element_type = getElementType( element )
		local player = element
		self.ignore[ player ] = nil
		if element_type == "vehicle" then
			player = on_vehicle_exit_player or getVehicleOccupant( element )
		end
		if not player or not self.accepted_elements[ element_type ] then return end
		if self.PostLeave then self:PostLeave( player ) end

		if self.keypress then unbindKey( player, self.keypress, "down", self.OnJoin ) end

		self:StopLookingForVehicleActions( player )
	end
	addEventHandler( "onColShapeLeave", self.colshape, self.OnLeave )

	self.OnJoin = function( player, key, state )
		if self.locked then return end
		if not player:isWithinColShape( self.colshape ) then
			self.OnLeave( player, true )
			return
		end
		if player:getData( "registered_in_clan_event" ) then
			player:ShowError( "Вы не можете это сделать, пока вы зарегистрированы в войне кланов!" )
			return
		end
		if self.PreJoin then
			local success, err = self:PreJoin( player )
			if not success then
				if err then player:ShowError( err )  end
				return
			end
		end
		local old_interior = player.interior
		local old_dimension = player.dimension
		if self.teleport then
			local vehicle = getPedOccupiedVehicle( player )
			if isElement( vehicle ) then
				self.teleport.ignore[ vehicle ] = true
				vehicle:TeleportToColshape( self.teleport.colshape )
				self.teleport.OnHit( vehicle, true )
			else
				self.teleport.ignore[ player ] = true
				player:TeleportToColshape( self.teleport.colshape )
				self.teleport.OnHit( player, true )
			end
		end
		if self.PostJoin then
			self:PostJoin( player )
		end
		if self.teleport or self.PostJoin then
			local old_position = { x = self.x, y = self.y, z = self.z }
			--triggerEvent( "onPlayerUseTeleportPoint", player, old_position, old_interior, old_dimension )
		end
	end

	if self.OnLoad then
		self:OnLoad( unpack( self.args or { } ) )
	end

	return self
end

function TCircleSafeZone( config )
	local self = config

	self.colshape = ColShape.Sphere( self.position, self.radius or 5 )
	self.colshape.dimension = self.dimension or 0
	self.colshape.interior = self.interior or 0
	self.players = { }

	if self.text == nil then self.text = "Вы вошли в безопасную зону" end
	if self.exit_text == nil then self.exit_text = "Вы вышли из безопасной зоны" end

	self.onSafeZoneHit = function( element, dimension_match )
		if not dimension_match then return end
		if getElementType( element ) ~= "player" then return end
		toggleControl( element, "fire", false )
		toggleControl( element, "aim_weapon", false )
		toggleControl( element, "next_weapon", false )
		toggleControl( element, "previous_weapon", false )
		self.players[ element ] = true
		if self.text then element:ShowInfo( self.text ) end
	end
	addEventHandler( "onColShapeHit", self.colshape, self.onSafeZoneHit )

	self.onSafeZoneLeave = function( element )
		if not self.players[ element ] then return end
		if getElementType( element ) ~= "player" then return end
		toggleControl( element, "fire", true )
		toggleControl( element, "aim_weapon", true )
		toggleControl( element, "next_weapon", true )
		toggleControl( element, "previous_weapon", true )
		if self.exit_text then element:ShowInfo( self.exit_text ) end
	end
	addEventHandler( "onColShapeLeave", self.colshape, self.onSafeZoneLeave )

	for i, v in ipairs( getElementsByType( "player" ) ) do
		if isElementWithinColShape( v, self.colshape ) then
			self.onSafeZoneHit( v )
		end
	end

	return self
end
