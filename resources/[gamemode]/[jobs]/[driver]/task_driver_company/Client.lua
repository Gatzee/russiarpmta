loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CQuest")

addEventHandler("onClientResourceStart", resourceRoot, function()
	CQuest(QUEST_DATA)
end)

----------------------------
-- Двери ебучего автобуса --
----------------------------

local BUS_DOORS_INTERFACE = nil

CreateBusDoorsInterface = function ( data )
	local self = {
		doors_state = 0;
		move_time   = 1000; --maybe divide lerp pos/rot
		is_moving   = false;
		vehicle     = data.vehicle;
		
		key_interaction = data.key_interaction;
		open_doors_callback = data.open_doors_callback;
		close_doors_callback = data.close_doors_callback;
		
		components_doors_data = 
		{
			mechanism_2_r = 
			{
				x1 = 0,    y1 = 0,    z1 = 0,
				x2 = -0.5, y2 = -0.1, z2 = 0,
			
				rx1 = 0, ry1 = 0, rz1 = 0,
				rx2 = 0, ry2 = 0, rz2 = 90,

			};
			mechanism_2_l = 
			{
				x1 = 0,    y1 = 0,   z1 = 0,
				x2 = -0.5, y2 = 0.1, z2 = 0,

				rx1 = 0, ry1 = 0, rz1 = 0,
				rx2 = 0, ry2 = 0, rz2 = -90,
			};
		};
	}
	
	for k, v in pairs( self.components_doors_data ) do
		v.x1, v.y1, v.z1 = getVehicleComponentPosition( self.vehicle, k )
		v.x2, v.y2, v.z2 = v.x1 + v.x2, v.y1 + v.y2, v.z1 + v.z2

		v.rx1, v.ry1, v.rz1 = getVehicleComponentRotation( self.vehicle, k )
		v.rx2, v.ry2, v.rz2 = v.rx1 + v.rx2, v.ry1 + v.ry2, v.rz1 + v.rz2
	end

	self.on_client_render_handler = function()
		if not isElement( self.vehicle ) then return end

		for k, v in pairs( self.components_doors_data ) do
			local progress = (getTickCount() - self.start_move_tick) / 1000
			if progress <= 1.1 then
				local start_index = 2 - self.doors_state
				local finish_index = 1 + self.doors_state
				local x1, y1, z1 = v[ "x" .. start_index ], v[ "y" .. start_index ], v[ "z" .. start_index ]
				local x2, y2, z2 = v[ "x" .. finish_index ], v[ "y" .. finish_index ], v[ "z" .. finish_index ]
	
				local x, y, z = interpolateBetween( x1, y1, z1, x2, y2, z2, progress, "Linear" )
				setVehicleComponentPosition( self.vehicle, k, x, y, z, v.base )
				
				local rx1, ry1, rz1 = v[ "rx" .. start_index ], v[ "ry" .. start_index ], v[ "rz" .. start_index ]
				local rx2, ry2, rz2 = v[ "rx" .. finish_index ], v[ "ry" .. finish_index ], v[ "rz" .. finish_index ]
				
				local rx, ry, rz = interpolateBetween( rx1, ry1, rz1, rx2, ry2, rz2, progress, "Linear" )
				setVehicleComponentRotation( self.vehicle, k, rx, ry, rz, v.base )
			else
				if self.doors_state == 1 and self.open_doors_callback then
					self:open_doors_callback()
				elseif self.doors_state == 0 and self.close_doors_callback then
					self:close_doors_callback()
				end
				removeEventHandler( "onClientRender", root, self.on_client_render_handler )
				self.is_moving = false
			end
		end
	end

	self.open_doors = function( self )
		self.is_moving = true
		self.start_move_tick = getTickCount()
		self.doors_state = self.doors_state == 0 and 1 or 0

		removeEventHandler( "onClientRender", root, self.on_client_render_handler )
		addEventHandler( "onClientRender", root, self.on_client_render_handler )
	end

	self.bind_open_doors_handler = function()
		if self.is_moving then return end
		self:open_doors()
	end
	bindKey( self.key_interaction, "down", self.bind_open_doors_handler )

	self.on_client_vehicle_enter = function( ped )
		if ped ~= localPlayer then return end
		unbindKey( self.key_interaction, "down", self.bind_open_doors_handler )
		bindKey( self.key_interaction, "down", self.bind_open_doors_handler )
	end
	addEventHandler( "onClientVehicleEnter", self.vehicle, self.on_client_vehicle_enter )

	self.on_client_vehicle_exit = function( ped )
		if ped ~= localPlayer then return end
		unbindKey( self.key_interaction, "down", self.bind_open_doors_handler )
	end
	addEventHandler( "onClientVehicleStartExit", self.vehicle, self.on_client_vehicle_exit )

	self.destroy = function()
		unbindKey( self.key_interaction, "down", self.bind_open_doors_handler )
		removeEventHandler( "onClientRender", root, self.on_client_render_handler )
		removeEventHandler( "onClientVehicleEnter", self.vehicle, self.on_client_vehicle_enter )
		removeEventHandler( "onClientVehicleStartExit", self.vehicle, self.on_client_vehicle_exit )

		if isElement( self.vehicle) then
			for k, v in pairs( self.components_doors_data ) do
				setVehicleComponentPosition( self.vehicle, k, v.x1, v.y1, v.z1, v.base )
				setVehicleComponentRotation( self.vehicle, k, v.rx1, v.ry1, v.rz1, v.base )
			end
		end

		setmetatable( self, nil )
	end

	return self
end

---------------
-- Пассажиры --
---------------

PASSENGERS_SKINS = { 118, 120, 117, 156, 139, 141, 145, 157 }
PASSENGERS_MONEY = { 55, 60, 100, 200, 500, 1000 }

GenerateRandomPassengers = function  ( )
	local passengeres = { }
	local engagedSkins = { }
	local count = math.random( 3, 5 )
	for i = 1, count do
		local skin
		repeat skin = PASSENGERS_SKINS[ math.random( 1, #PASSENGERS_SKINS ) ] until not engagedSkins[ skin ]
		engagedSkins[ skin ] = true

		local money = PASSENGERS_MONEY[ math.random( 1, #PASSENGERS_MONEY ) ]
		table.insert( passengeres, { skin = skin, money = money } )
	end
	return passengeres
end

local CURRENT_PEDS_ALPHA = 0
local PEDS_PASSANGERES = { }

CreatePassangeresPeds = function ( data, action, end_callback )
	if not localPlayer.vehicle then return end

	DestroyPassangeresPeds( )

	for i, v in pairs ( data ) do
		local offset = action == "enter" and math.random( 4, 6 ) or math.random( 0, 1 )
		local pos = Vector3( getPositionFromMatrixOffset( localPlayer.vehicle, offset, 0, 0 ) )
		local x, y, z = pos.x + ( math.random( ) - 0.5 ) * 2.5, pos.y + ( math.random( ) - 0.5 ) * 2.5, pos.z
		PEDS_PASSANGERES[ i ] = createPed( v.skin, x, y, z, 0 )

		setElementAlpha( PEDS_PASSANGERES[ i ], CURRENT_PEDS_ALPHA )

		addEventHandler( "onClientPedDamage", PEDS_PASSANGERES[ i ], cancelEvent )
		setElementCollidableWith( PEDS_PASSANGERES[ i ], localPlayer, false )
		setElementCollidableWith( PEDS_PASSANGERES[ i ], localPlayer.vehicle, false )
	end

	SetPassangeresPedsAlpha( 255, function ( )
		StartPassangeresWalk( localPlayer.vehicle, action)
		SetPassangeresPedsAlpha( 0, function( )
			DestroyPassangeresPeds( )
			if end_callback then
				end_callback( )
			end
		end )
	end )
end

StartPassangeresWalk = function ( vehicle, action )
	local _, _, rot = getElementRotation( vehicle )

	for i, v in pairs( PEDS_PASSANGERES ) do
		setPedAnimation( v )
		setPedAnalogControlState( v, "forwards", 0.5 )

		setElementRotation( v, 0, 0, action == "enter" and (rot + 90) or rot + 270, "default", true )
	end
end

DestroyPassangeresPeds = function ( )
	for i, v in pairs( PEDS_PASSANGERES ) do
		if isElement( v ) then
			destroyElement( v )
		end
	end
	PEDS_PASSANGERES = { }
	CURRENT_PEDS_ALPHA = 0
end

SetPassangeresPedsAlpha = function ( value, end_callback )
	local duration = 1500
	local start = getTickCount( )
	local from, to = CURRENT_PEDS_ALPHA, value

	render_passangeres = function ( )
		local now = getTickCount( )
		local alpha = interpolateBetween( from, 0, 0, to, 0, 0, ( now - start ) / duration, "Linear" )
		
		for i,v in pairs( PEDS_PASSANGERES ) do
			setElementAlpha( v, alpha )
		end

		if now >= start + duration then
			removeEventHandler( "onClientRender", root, render_passangeres )

			if end_callback then
				end_callback( )
			end
		end
	end

	CURRENT_PEDS_ALPHA = value

	addEventHandler( "onClientRender", root, render_passangeres )
end

--------------
-- Маршруты --
--------------

-- getPositionFromMatrixOffset

local CURRENT_STOPS = { }
local CURRENT_STOP = 1
local CURRENT_STOP_MARKER = nil
local CURRENT_STOP_MARKER_ELEMENT = nil
local CURRENT_PASSENGERES = { }
local CHECK_TIMER = nil
local WARNING_TIMERS = { }
local SERVICED_PASSANGERES = 0 -- количетство обслуженных ботов
local FAIL_STOPS = 0 -- пропущеные остановки


destroyDriverTimers = function ( )
	if isTimer( CHECK_TIMER ) then
		killTimer( CHECK_TIMER )
	end
	for i, v in pairs ( WARNING_TIMERS ) do
		if isTimer( v ) then
			killTimer( v )
		end
	end
	CHECK_TIMER = nil
	WARNING_TIMERS = { }
end

updateDriverTimers = function ( )
	destroyDriverTimers( )

	local min = 15
	local warningMins = { 3, 1 }

	CHECK_TIMER = setTimer( function ( )
		triggerServerEvent( "onDriverRouteFail", localPlayer )
	end, min * 1000 * 60, 1 )

	for i = 1, #warningMins do
		local cMins = min - warningMins[ i ]
		local minsText = plural( cMins, "минуту", "минуты", "минут" )
		WARNING_TIMERS[ i ] = setTimer( function ( )
			localPlayer:ShowError( "Смена будет завершена, через ".. cMins.." "..minsText..", если не продолжить работу!" )
		end, cMins * 1000 * 60, 1 )
	end
end

createStops = function ( list )
	destroyStops( )

	CURRENT_STOPS = list
	CURRENT_STOP = 1

	REQUIRED_VEHICLE = localPlayer:getData( "job_vehicle" )

	createNextMarker( )
	updateDriverTimers( )
end

createNextMarker = function ( id )
	local id = id or CURRENT_STOP

	local marker_position = Vector3( CURRENT_STOPS[ id ].x, CURRENT_STOPS[ id ].y, CURRENT_STOPS[ id ].z )
	local marker_text = false

	if id == 1 then
		marker_text = "Начало маршрута"
	end

	CURRENT_STOP_MARKER, CURRENT_STOP_MARKER_ELEMENT = CreateStopMarker({
		x = marker_position.x,
		y = marker_position.y,
		z = marker_position.z,
		marker_text = marker_text,
	})

	addEventHandler("onClientMarkerHit", CURRENT_STOP_MARKER_ELEMENT, function ( element )
		if element ~= localPlayer then return end

		CHECK_SPEED_TIMER = Timer(function( )
			if localPlayer.vehicle ~= REQUIRED_VEHICLE then return localPlayer:ShowError("Неверный транспорт") end


			updateDriverTimers( )

			---delayControls( true )


			enterPassangers = function ( )

				-- Выпускаем педов из автобуса, если они есть
				if #CURRENT_PASSENGERES >= 1 then 
					CreatePassangeresPeds( CURRENT_PASSENGERES, "exit", enterPassangers )
					CURRENT_PASSENGERES = { }
					return
				end

				-- Генрим новых и напрвляем в автик

				CURRENT_PASSENGERES = GenerateRandomPassengers( )

				CreatePassangeresPeds( CURRENT_PASSENGERES, "enter", function ( )
					localPlayer:ShowInfo( "Закройте двери, нажав клавишу H" )
					toggleMiniGame( true, {
						passengers = CURRENT_PASSENGERES,
						callback_func = function( result )
							if result == "success" then
								SERVICED_PASSANGERES = SERVICED_PASSANGERES + #CURRENT_PASSENGERES
							elseif result == "fail" then
								FAIL_STOPS = FAIL_STOPS + 1
							end
							delayControls( false )

							if CURRENT_STOP >= #CURRENT_STOPS then
								triggerServerEvent( "onDriverRoutePass", resourceRoot, SERVICED_PASSANGERES, FAIL_STOPS )
								triggerServerEvent( "PlayerAction_Task_Driver_1_step_2", localPlayer, SERVICED_PASSANGERES, FAIL_STOPS )
							else
								CURRENT_STOP = CURRENT_STOP + 1
								createNextMarker( )
							end
					    end,
					} )

				end )
			end

			localPlayer:ShowInfo( "Откройте двери, нажав клавишу H" )

			enterPassangers( )

			BUS_DOORS_INTERFACE = CreateBusDoorsInterface( { 
				vehicle = localPlayer.vehicle,
				key_interaction = "h",

				open_doors_callback = function ()
					-- enterPassangers() бля я хуй знает чо делать педы багаютса ... АААААААААААААААААААААААААААААА
				end,

				close_doors_callback = function( self )
					if BUS_DOORS_INTERFACE then
						BUS_DOORS_INTERFACE:destroy()
						BUS_DOORS_INTERFACE = nil
					end
				end,
			} )

			if localPlayer.vehicle then localPlayer.vehicle:ping( ) end

			CHECK_SPEED_TIMER:destroy()
			CURRENT_STOP_MARKER:destroy()
		end, 1000, 1)
	end)

	addEventHandler("onClientMarkerLeave", CURRENT_STOP_MARKER_ELEMENT, function( element )
		if element ~= localPlayer then return end
		if isTimer( CHECK_SPEED_TIMER ) then
			killTimer( CHECK_SPEED_TIMER ) 
			localPlayer:ShowError( "Внимание! Вы проехали мимо остановки! Вернитесь и выполните полную остановку" )
		end
	end)
end

destroyStops = function ( )
	CURRENT_STOPS = { }

	if isElement( CURRENT_STOP_MARKER) then
		CURRENT_STOP_MARKER:destroy()
	end
	CURRENT_STOP_MARKER = nil
	CURRENT_STOP_MARKER_ELEMENT = nil
	CURRENT_PASSENGERES = { }

	if isTimer( CHECK_SPEED_TIMER ) then
		killTimer( CHECK_SPEED_TIMER ) 
	end

	destroyDriverTimers( )

	SUCCESSFULL_STOPS = 0
	FAIL_STOPS = 0

	localPlayer:setData( "current_route", false, false )
end
addEventHandler( "onClientResourceStop", resourceRoot, destroyStops )

CreateStopMarker = function ( data )
	local config = data

	config.elements = { }
	config.radius = 8
	config.gps = true

	tpoint = TeleportPoint( config )
    tpoint.text = false
    tpoint.keypress = false
	tpoint.marker:setColor( 255, 0, 0, 30 )

	tpoint:SetImage( "img/marker.png" )
	tpoint.element:setData( "material", true, false )
	tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 2.3 } )
	
	return tpoint, tpoint.marker
end

-- Обработка задержки движения
DISABLING_CONTROLS = {
	"forwards", "backwards", "left", "right", "jump", "crouch", "walk", "sprint", -- управление игроком
	"accelerate", "brake_reverse", "enter_exit", -- управление автомобилем
}

delayControls = function ( state )
	if state then
		localPlayer.vehicle.frozen = true
		for i, control in pairs( DISABLING_CONTROLS ) do
			toggleControl( control, false )
		end
	else
		if localPlayer.vehicle then
			localPlayer.vehicle.frozen = false
		end
		for i, control in pairs( DISABLING_CONTROLS ) do
			toggleControl( control, true )
		end
		if CURRENT_STOP and type( CURRENT_STOPS ) == "table" and CURRENT_STOP < #CURRENT_STOPS then
			localPlayer:ShowInfo( "Продолжайте движение" )
		end
	end
end

--Получение позиции снаружи машины
getPositionFromMatrixOffset = function ( element, offX, offY, offZ )
	return element:getMatrix():transformPosition( offX, offY, offZ )
end