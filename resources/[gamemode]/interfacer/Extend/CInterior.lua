-- CInterior
Import( "Globals" )

function TeleportPoint(config)
	local self = config
	if not self then return end
	if ( not self.x or not self.y or not self.z ) and not self.attach_to then return end
	local teleport_points = getElementsByType("teleport_points")
	local teleport_point_id = self.id or ("teleport_point_%s"):format(#teleport_points)
	local teleport_element = Element("teleport_points",teleport_point_id)

	self.id = teleport_point_id
	self.element_id = teleport_point_id
	self.element = teleport_element
	self.radius = self.radius or 1
	self.name = self.name or self.id
	self.ignore = {}
	self.slowdown_coefficient = self.slowdown_coefficient or 5

	self.element:setData( "name", self.name, false )
	self.element:setData( "type", self.element_id, false )
	self.element:setData( "quest_state", self.quest_state, false )

	self.interior = self.interior or 0
	self.dimension = self.dimension or 0
	if self.attach_to then
		self.interior = self.attach_to.interior
		self.dimension = self.attach_to.dimension
	end

	self.element.position = Vector3(self.x,self.y,self.z)
	self.element.interior = self.interior
	self.element.dimension = self.dimension

	self.accepted_elements = self.accepted_elements or { player = true }
	if self.keypress == nil then self.keypress = "lalt" end
	if self.text == nil and self.keypress then self.text = ("Нажмите %s"):format(utf8.upper(self.keypress)) end
	-- Точка входа игрока
	self.colshape = ColShape.Sphere(self.element.position,self.radius)
	self.colshape.interior = self.element.interior
	self.colshape.dimension = self.element.dimension
	self.colshape:setParent(self.element)

	self.marker_type = self.marker_type or "cylinder"
	self.marker = Marker(Vector3(self.colshape.position.x,self.colshape.position.y,self.colshape.position.z-1),self.marker_type,self.radius,255,0,0,255)
	self.marker.interior = self.colshape.interior
	self.marker.dimension = self.colshape.dimension
	self.marker:setParent(self.element)

	if self.blip then
		if self.blip == true then
			self.blip = createBlipAttachedTo( self.marker, 41, 5, 250, 100, 100 )
		else
			self.blip = createBlipAttachedTo( self.marker, self.blip.id, self.blip.size or 2, unpack( self.blip.color or { } ) )
		end
		self.blip.parent = self.element
	end

	if self.attach_to then
		self.element.position = self.attach_to.position
		self.element:attach( self.attach_to, self.attach_offset )
		self.colshape:attach( self.attach_to, self.attach_offset )
		if self.attach_offset then
			self.marker:attach( self.attach_to, self.attach_offset + Vector3( 0, 0, -1 ) )
		else
			self.marker:attach( self.attach_to, 0, 0, -1 )
		end

		addEventHandler( "onClientElementDestroy", self.attach_to, function( )
			self:destroy( )
		end )
	end

	self.timers = { }

	if self.color then
		self.marker:setColor( unpack( self.color ) )
	end

	self.SetGPS = function(self, state)
		self.gps = state
		self.element:setData("gps", state, false)

		if self.interior == 0 and not self.ignore_gps_route then
			self:SetGPSRouteActive( true )
		end
	end

	self.SetGPSRouteActive = function( self, state )
		self.route_active = state
		if state then
			triggerEvent( "onClientTryGenerateGPSPath", root, {
				x = self.x, y = self.y, z = self.z, route_id = self.id
			} )
		else
			triggerEvent( "onClientTryDestroyGPSPath", root, self.id )
		end
	end

	self.SetText = function(self,text)
		self.marker_text = text
		self.element:setData("text", text, false)
	end

	self.GetText = function(self)
		return self.element:getData("text")
	end

	self.SetImage = function(self, image)
		local is_table = type( image ) == "table"
		local image_file = is_table and image[ 1 ] or image
		image_file = image_file:sub(1, 1) == ":" and image_file or ":"..THIS_RESOURCE_NAME .. "/" .. image_file

		if is_table then
			image[ 1 ] = image_file
		else
			image = image_file
		end
		self.marker_image = image
		self.element:setData("image", image)
	end

	self.GetImage = function(self)
		return self.element:getData("image")
	end

	self.SetDropImage = function(self, image)
		local is_table = type( image ) == "table"
		local image_file = is_table and image[ 1 ] or image
		image_file = image_file:sub(1, 1) == ":" and image_file or ":"..THIS_RESOURCE_NAME .. "/" .. image_file

		if is_table then
			image[ 1 ] = image_file
		else
			image = image_file
		end

		self.dropimage = image
		self.element:setData( "dropimage", image, false )
	end

	self.GetDropImage = function(self)
		return self.element:getData( "dropimage" )
	end

	if self.marker_text then self:SetText(self.marker_text) end
	if self.marker_image then self:SetImage(self.marker_image) end
	if self.gps then self:SetGPS(self.gps) end

	self.OnHit = function( element, dimension_match, ignore_slowdown )
		if element ~= localPlayer and element ~= localPlayer.vehicle or not dimension_match then return end
		if element == localPlayer and localPlayer.vehicle then return end

		local element_real = element
		local element_type = getElementType( element )

		if element_type == "player" then
			-- Если нельзя игроком
			if not ( self.accepted_elements and self.accepted_elements.player ) then return end

		elseif element_type == "vehicle" then
			-- Если нельзя на машине
			if not ( self.accepted_elements and self.accepted_elements.vehicle ) then return end

			-- Если не водитель машины
			if localPlayer.vehicle and not self.allow_passenger and localPlayer.vehicle.occupants[ 0 ] ~= localPlayer then return end

			-- Замедление машины
			if not ignore_slowdown and self.slowdown_coefficient then
				element.velocity = element.velocity / self.slowdown_coefficient
			end

			element = localPlayer
		end

		-- Совпадение интерьера
		if self.element.interior ~= element.interior then return end

		-- Не в списке игнора
		if self.ignore[ element ] then return end

		-- Маркер не заблокирован
		if self.locked then return end

		-- Постоянное предпроверка входа
		if self.PreJoinContinuous then
			if isTimer( self.timers.continuous ) then killTimer( self.timers.continuous ) end

			local success, err = self:PreJoinContinuous( element )
			if not success then
				if err then element:ShowError( err ) end
				self.timers.continuous = setTimer( 
					function( ) 
						self.OnHit( element_real, element_real.dimension == self.dimension, true )
					end,
				500, 1 )
				return
			end
		end

		-- Предпроверка входа
		if self.PreJoin then
			local success, err = self:PreJoin( element )
			if not success then 
				if err then element:ShowError( err ) end
				return
			end
		end

		-- Текст при входе в маркер
		if self.vehicle_text and element_type == "vehicle" then
			localPlayer:ShowInfo( self.vehicle_text )
		elseif self.text then
			localPlayer:ShowInfo( self.text )
		end

		-- Если нужно нажимать кнопку
		if self.keypress then
			bindKey( self.keypress, "down", self.OnJoin )
		
		-- Иначе сразу вызываем действие маркера
		else
			self.OnJoin( element )

		end

		return true
	end
	addEventHandler( "onClientColShapeHit", self.colshape, self.OnHit )

	self.OnVehicleExit = function( vehicle, seat )
		local player = source
		if player ~= localPlayer or not self or not self.colshape then return end
		local hit_succes = false
		if player:isWithinColShape(self.colshape) then
			self.OnLeave(player, true)
			hit_succes = self.OnHit(player, player.dimension == self.dimension)
		end
		if not hit_succes and ( self.allow_passenger or seat == 0 ) and (not isElement( vehicle ) or vehicle:isWithinColShape(self.colshape)) then
			self.OnLeave(vehicle, true, player)
		end
	end
	addEventHandler( "onClientPlayerVehicleExit", localPlayer, self.OnVehicleExit )

	self.OnVehicleEnter = function( vehicle )
		local player = source
		if player ~= localPlayer or not self or not self.colshape then return end
		if player:isWithinColShape(self.colshape) then
			self.OnLeave(player, true)
			self.OnHit(player, player.dimension == self.dimension)
		end
	end
	addEventHandler( "onClientPlayerVehicleEnter", localPlayer, self.OnVehicleEnter )

	self.OnLeave = function(element,dimension_match,on_vehicle_exit_player)
		if not isElement(element) then return end
		local element_type = getElementType(element)
		local player = element
		self.ignore[player] = nil
		if element_type == "vehicle" then
			player = on_vehicle_exit_player or getVehicleOccupant(element)
		end
		if player ~= localPlayer then return end
		for i, v in pairs( self.timers ) do
			if isTimer( v ) then killTimer( v ) end
			self.timers = { }
		end
		if not self.accepted_elements[element_type] then return end
		if self.PostLeave then self:PostLeave(player) end
		if self.keypress then unbindKey(self.keypress,"down",self.OnJoin) end
	end
	addEventHandler("onClientColShapeLeave",self.colshape,self.OnLeave)

	self.OnJoin = function(key,state)
		local player = localPlayer
		if not self or self.locked then return end
		if player:getData( "registered_in_clan_event" ) then
			player:ShowError( "Вы не можете это сделать, пока вы зарегистрированы в войне кланов!" )
			return
		end
		if self.PreJoin then
			local success,err = self:PreJoin(player)
			if not success then if err then player:ShowError(err) end return end
		end
		if self.keypress then unbindKey( self.keypress, "down", self.OnJoin ) end
		local position = self.element.position
		local old_position = { x = position.x, y = position.y, z = position.z }
		local old_interior = player.interior
		local old_dimension = player.dimension
		if self.teleport then
			local vehicle = getPedOccupiedVehicle(player)
			if vehicle then
				self.teleport.ignore[vehicle] = true
				vehicle:TeleportToColshape(self.teleport.colshape)
				self.teleport.OnHit(vehicle,true)
			else
				self.teleport.ignore[player] = true
				player:TeleportToColshape(self.teleport.colshape)
				self.teleport.OnHit(player,true)
			end
		end
		if self.PostJoin then
			self:PostJoin(player)
		end
		if self.teleport or self.PostJoin then
			--triggerServerEvent( "onPlayerUseTeleportPoint", localPlayer, old_position, old_interior, old_dimension )
		end
	end

	self.OnElementDestroy = function()
		self.destroy( )
	end
	addEventHandler( "onClientElementDestroy", self.element, self.OnElementDestroy )

	self.destroy = function()
		if self.route_active then self:SetGPSRouteActive( false ) end

		if self.keypress then unbindKey(self.keypress,"down",self.OnJoin) end
		removeEventHandler( "onClientPlayerVehicleExit", localPlayer, self.OnVehicleExit )
		removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, self.OnVehicleEnter )
		if type(self.elements) == "table" then
			for i, element in pairs(self.elements) do
				if isElement(element) then destroyElement(element) end
				if isElement(i) then destroyElement(i) end
			end
		end
		for i, v in pairs( self.timers ) do
			if isTimer( v ) then killTimer( v ) end
		end
		if isElement(self.element) then
			removeEventHandler( "onClientElementDestroy", self.element, self.OnElementDestroy )
			destroyElement(self.element) 
		end
		if isElement(self.colshape) then destroyElement(self.colshape) end
		if isElement(self.marker) then destroyElement(self.marker) end
		if isElement(self.blip) then destroyElement(self.blip) end
		--self = nil

		return true
	end

	self.SetPosition = function( self, vec_pos )
		self.marker.position = vec_pos
		self.colshape.position = vec_pos
		self.element.position = vec_pos
	end

	self.GetPosition = function( self )
		return self.element.position
	end

	if self.OnLoad then
		self:OnLoad( unpack( self.args or { } ) )
	end

	return self
end

Element.SetGPSMarker = function( self, tpoint_config )
	local gps_marker_element = self:getData( "gps_marker_element" )
	if tpoint_config or tpoint_config == nil then
		if isElement( gps_marker_element ) then gps_marker_element:destroy( ) end

		tpoint_config = type( tpoint_config ) == "table" and tpoint_config or { }
		tpoint_config.attach_to = self
		tpoint_config.radius = tpoint_config.radius or 3
		tpoint_config.marker_type = tpoint_config.marker_type or "checkpoint"
		tpoint_config.color = tpoint_config.color or { 250, 100, 100, 150 }
		tpoint_config.gps = true
		tpoint_config.blip = tpoint_config.blip or true
		tpoint_config.accepted_elements = tpoint_config.accepted_elements or { player = true, vehicle = true }
		tpoint_config.keypress = tpoint_config.keypress or false

		local gps_marker = TeleportPoint( tpoint_config )
		gps_marker.PostJoin = gps_marker.PostJoin or gps_marker.destroy

		self:setData( "gps_marker_element", gps_marker.element, false )

		return gps_marker
	else
		return isElement( gps_marker_element ) and gps_marker_element:destroy( )
	end
end