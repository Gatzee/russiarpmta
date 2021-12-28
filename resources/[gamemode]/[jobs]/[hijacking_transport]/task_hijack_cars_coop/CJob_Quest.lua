Extend( "CQuestCoop" )
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "CInterior" )
Extend( "ib" )

ibUseRealFonts( true )

addEventHandler( "onClientResourceStart", resourceRoot, function()
	CQuestCoop( QUEST_DATA )
end )

function AddInteractionVehicleHandlers( target_vehicle, time, warning_text, fail_text )
	local self = {}

	self._vehicle_exit_handler = target_vehicle
	self.time = time
	self.warning_text = warning_text
	self.fail_text = fail_text

	self.func_create_fail_timer = function( self )
		if isTimer( self.fail_tmr ) then return end

		self.fail_tmr = setTimer( function()
			triggerServerEvent( "onServerPlayerFailCoopQuest", localPlayer, self.fail_text, "fail_exit_hijack_car" )
			self:destroy()
		end, self.time, 1 )

		self.fail_text_area = ibCreateArea( 0, 0, 0, 0 ):center( 0, _SCREEN_Y / 3 )
		ibCreateLabel( 0, -40, 0, 0, self.warning_text, self.fail_text_area, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_24 ):ibData( "outline", 1 )

		local func_interpolate = function( self )
			self:ibInterpolate( function( self )
				if not isElement( self.element ) then return end
				self.easing_value = 1 + 0.2 * self.easing_value
				self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
			end, 350, "SineCurve" )
		end

		local time_in_sec = self.time / 1000
		ibCreateLabel( 0, 0, 0, 0, time_in_sec .. " сек", self.fail_text_area, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_36 )
			:ibData( "timestamp", getRealTimestamp() + time_in_sec )
			:ibData( "outline", 1 )
			:ibTimer( func_interpolate, 100, 1 )
			:ibTimer( function( self )
				func_interpolate( self )
				local timestamp = self:ibData( "timestamp" )
				if timestamp then
					self:ibData( "text", (timestamp - getRealTimestamp()) .. " сек" )
				end
			end, 1000, 0 )
	end

	self.func_destroy_timer = function( self )
		if isTimer( self.fail_tmr ) then killTimer( self.fail_tmr ) end
		if isElement( self.fail_text_area ) then destroyElement( self.fail_text_area ) end
	end

	self._func_vehicle_enter_handler = function( player )
		if player ~= localPlayer then return end
		self:func_destroy_timer()
	end
	
	self._func_vehicle_exit_handler = function( player )
		if player ~= localPlayer then return end
		self:func_create_fail_timer()
	end

	self.destroy = function( self )
		self:func_destroy_timer()
		if isElement( self._vehicle_exit_handler ) then
			removeEventHandler( "onClientVehicleEnter", self._vehicle_exit_handler, self._func_vehicle_enter_handler )
			removeEventHandler( "onClientVehicleExit", self._vehicle_exit_handler, self._func_vehicle_exit_handler )
		end
		setmetatable( self, nil )
	end

	addEventHandler( "onClientVehicleEnter", self._vehicle_exit_handler , self._func_vehicle_enter_handler )
	addEventHandler( "onClientVehicleExit", self._vehicle_exit_handler, self._func_vehicle_exit_handler )

	CEs.interface_interaction_car = self
end

function SetEnabledCheckDistanceTimer( state, position, max_distance, fail_time, warning_text, fail_text )
	if state then
		local self = {}
		self.position = position
		self.max_distance = max_distance
		self.fail_time = fail_time
		self.warning_text = warning_text
		self.fail_text = fail_text
		self.is_fail_timer_enabled = false

		self.start_fail_timer = function( self )
			if self.is_fail_timer_enabled then return end
			
			self.is_fail_timer_enabled = true
			
			self.fail_tmr = setTimer( function()
				triggerServerEvent( "onServerPlayerFailCoopQuest", localPlayer, self.fail_text, "fail_distance_hijack_car" )
				self:destroy()
			end, self.fail_time, 1 )
	
			self.fail_text_area = ibCreateArea( 0, 0, 0, 0 ):center( 0, _SCREEN_Y / 3 )
			ibCreateLabel( 0, -40, 0, 0, self.warning_text, self.fail_text_area, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_24 ):ibData( "outline", 1 )
	
			local func_interpolate = function( self )
				self:ibInterpolate( function( self )
					if not isElement( self.element ) then return end
					self.easing_value = 1 + 0.2 * self.easing_value
					self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
				end, 350, "SineCurve" )
			end
	
			ibCreateLabel( 0, 0, 0, 0, self.fail_time / 1000  .. " сек", self.fail_text_area, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_36 )
				:ibData( "timestamp", getRealTimestamp() + self.fail_time / 1000 )
				:ibData( "outline", 1 )
				:ibTimer( func_interpolate, 100, 1 )
				:ibTimer( function( self )
					func_interpolate( self )
					local timestamp = self:ibData( "timestamp" )
					if timestamp then
						self:ibData( "text", (timestamp - getRealTimestamp()) .. " сек" )
					end
				end, 1000, 0 )
		end

		self.stop_fail_timer = function( self )
			if isTimer( self.fail_tmr ) then killTimer( self.fail_tmr ) end
			if isElement( self.fail_text_area ) then destroyElement( self.fail_text_area ) end
			self.is_fail_timer_enabled = false
		end

		self._check_distance_tmr = setTimer( function()
			if (localPlayer.position - self.position ).length > self.max_distance then
				self:start_fail_timer()
			elseif self.is_fail_timer_enabled then
				self:stop_fail_timer()
			end
		end, 1000, 0 )

		self.destroy = function( self )
			if isTimer( self._check_distance_tmr ) then killTimer( self._check_distance_tmr ) end
			self:stop_fail_timer()
			setmetatable( self, nil )
		end

		GEs.interface_check_distance = self
	elseif GEs.interface_check_distance then
		GEs.interface_check_distance:destroy()
		GEs.interface_check_distance = nil
	end
end

function AddCheckDistanceBetweenElements( element_1, element_2, max_distance, fail_time, warning_text, fail_text )
	local self = {
		element_1 = element_1,
		element_2 = element_2,

		max_distance = max_distance,
		fail_time 	 = fail_time,
		warning_text = warning_text,
		fail_text 	 = fail_text,
		is_fail_timer_enabled = false,
	}

	self.start_fail_timer = function( self )
		if self.is_fail_timer_enabled then return end
		
		self.is_fail_timer_enabled = true
		
		self.fail_tmr = setTimer( function()
			triggerServerEvent( "onServerPlayerFailCoopQuest", localPlayer, self.fail_text, "fail_distance_hijack_car" )
			self:destroy()
		end, self.fail_time, 1 )

		self.fail_text_area = ibCreateArea( 0, 0, 0, 0 ):center( 0, _SCREEN_Y / 3 )
		ibCreateLabel( 0, -40, 0, 0, self.warning_text, self.fail_text_area, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_24 ):ibData( "outline", 1 )

		local func_interpolate = function( self )
			self:ibInterpolate( function( self )
				if not isElement( self.element ) then return end
				self.easing_value = 1 + 0.2 * self.easing_value
				self.element:ibBatchData( { scale_x = ( 1 * self.easing_value ), scale_y = ( 1 * self.easing_value ) } )
			end, 350, "SineCurve" )
		end

		ibCreateLabel( 0, 0, 0, 0, self.fail_time / 1000  .. " сек", self.fail_text_area, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_36 )
			:ibData( "timestamp", getRealTimestamp() + self.fail_time / 1000 )
			:ibData( "outline", 1 )
			:ibTimer( func_interpolate, 100, 1 )
			:ibTimer( function( self )
				func_interpolate( self )
				local timestamp = self:ibData( "timestamp" )
				if timestamp then
					self:ibData( "text", (timestamp - getRealTimestamp()) .. " сек" )
				end
			end, 1000, 0 )
	end

	self.stop_fail_timer = function( self )
		if isTimer( self.fail_tmr ) then killTimer( self.fail_tmr ) end
		if isElement( self.fail_text_area ) then destroyElement( self.fail_text_area ) end
		self.is_fail_timer_enabled = false
	end

	self._check_distance_tmr = setTimer( function()
		if (self.element_1.position - self.element_2.position ).length > self.max_distance then
			self:start_fail_timer()
		elseif self.is_fail_timer_enabled then
			self:stop_fail_timer()
		end
	end, 1000, 0 )

	self.destroy = function( self )
		if isTimer( self._check_distance_tmr ) then killTimer( self._check_distance_tmr ) end
		self:stop_fail_timer()
		setmetatable( self, nil )
	end

	GEs.interface_check_distance_between_players = self
end

function WatchVehicleHealth( target_vehicle )
	CEs._pulse_tmr = setTimer( function()
		if isElement( target_vehicle ) and (isElementInWater( target_vehicle ) or target_vehicle.health < 390) then
			triggerServerEvent( "onServerPlayerFailCoopQuest", localPlayer, "разбил угоняемое авто", "destroy_hijack_car" )
		end
	end, 1000, 0 )
end

function CheckAllPlayersInVehicle( lobby_data )
	for k, v in pairs( lobby_data.participants ) do
		if isElement( v.player ) and v.player.vehicle ~= lobby_data.job_vehicle then
			return false
		end
	end
	return true
end

function CheckPlayerQuestVehicle()
	if not isElement( localPlayer.vehicle ) or localPlayer.vehicle ~= localPlayer:getData( "job_vehicle" ) then
		localPlayer:ShowError( "Ты не в автомобиле братвы" )
		return false
	end

	if localPlayer.vehicleSeat ~= 0 then
		localPlayer:ShowError( "Ты не водитель автомобиля братвы" )
		return false
	end

	return true
end

function SetWaitingControlsState( state )
	for k, v in pairs( { "enter_exit", "accelerate", "brake_reverse", "vehicle_left", "vehicle_right", "vehicle_fire", "vehicle_secondary_fire", "handbrake" } ) do
		toggleControl( v, not state )
	end
end