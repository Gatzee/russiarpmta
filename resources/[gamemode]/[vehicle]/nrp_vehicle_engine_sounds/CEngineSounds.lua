
ENGINE_SOUNDS = { }
STREAMED_VEHICLES = { }

-- Настройки внутри/снаружи тачки
OUT_OF_VEHICLE_VOLUME = 0.25
IN_VEHICLE_VOLUME = OUT_OF_VEHICLE_VOLUME / 1.5

CURRENT_MULTIPLY_VOLUME = OUT_OF_VEHICLE_VOLUME

RADIO_ON_COEFFICIENT = 0.35
RADIO_OFF_COEFFICIENT = 1

CURRENT_RADIO_COEFF = RADIO_OFF_COEFFICIENT
PREV_RADIO_COEFF = 0

Vehicle.GetVehicleRPM = function( self )
	local vehicle_rpm = 0
	if not getVehicleEngineState( self ) then return vehicle_rpm end
	
	if localPlayer:getData( "drag_race" ) then
		local speed = math.max( 0.01, ( Vector3( getElementVelocity( self ) ) * 180 ).length )
		return math.floor( speed * 180 + 0.5 )
	end

	local gear = getVehicleCurrentGear( self )
	local gear_coef = gear > 0 and gear or 1
	vehicle_rpm = math.floor( (self:GetSpeed() / gear_coef ) * 180 + 0.5 )
	
	return vehicle_rpm
end

Vehicle.GetSpeed = function( self )
	if not VEHICLE_CONFIG[ self.model ] then return 0 end

	if self == localPlayer.vehicle and BURNOUT_VEHICLES[ localPlayer.vehicle ] then
		local value = 0
		local vehicle_class = VEHICLE_CONFIG[ self.model ].variants[ self:GetVariant() ].class
		if BURNOUT_VEHICLES[ localPlayer.vehicle ].state then
			BURNOUT_VEHICLES[ localPlayer.vehicle ].diff = (getTickCount() - BURNOUT_VEHICLES[ localPlayer.vehicle ].ticks)
			local fProgress = math.min( 1, BURNOUT_VEHICLES[ localPlayer.vehicle ].diff / 1000 )
			value = interpolateBetween( 0, 0, 0, VEHICLE_CLASS_DATA[ vehicle_class ].burnout_coeff, 0, 0, fProgress, "Linear" )
		else
			BURNOUT_VEHICLES[ localPlayer.vehicle ].diff = (getTickCount() - BURNOUT_VEHICLES[ localPlayer.vehicle ].ticks)
			local fProgress = math.min( 1, BURNOUT_VEHICLES[ localPlayer.vehicle ].diff / 500 )
			value = interpolateBetween( VEHICLE_CLASS_DATA[ vehicle_class ].burnout_coeff, 0, 0, 0, 0, 0, fProgress, "Linear" )
			if fProgress == 1 then
				BURNOUT_VEHICLES[ localPlayer.vehicle ] = nil
			end
		end
		return (Vector3(Vector3(value, 0, 0)) * 111.84681456).length
	elseif self == localPlayer.vehicle and AFTER_BURNOUT[ self ] then
		local vehicle_class = VEHICLE_CONFIG[ self.model ].variants[ self:GetVariant() ].class
		AFTER_BURNOUT[ self ].diff = (getTickCount() - AFTER_BURNOUT[ self ].ticks)
		local fProgress = math.min( 1, AFTER_BURNOUT[ self ].diff / 2500 )
		local value = interpolateBetween( VEHICLE_CLASS_DATA[ vehicle_class ].burnout_coeff * 70, 0, 0, 0.05, 0, 0, fProgress, "Linear" )
		if fProgress == 1 then
			AFTER_BURNOUT[ self ] = nil
		end
		return (Vector3(getElementVelocity(self)) * 111.84681456).length + value
	end

	return (Vector3(getElementVelocity(self)) * 111.84681456).length
end

-- Обработка транспорта
function vsOnResourceStart( )
	for i, v in pairs( getElementsByType( "vehicle", root, true ) ) do
		STREAMED_VEHICLES[ v ] = true
		addEventHandler( "onClientElementStreamOut", v, vsOnStreamOut )
		addEventHandler( "onClientElementDestroy", v, vsOnStreamOut )
	end
	addEventHandler( "onClientElementStreamIn", root, vsOnStreamIn )
	addEventHandler( "onClientPreRender", root, vsRenderSounds )
end
addEventHandler( "onClientResourceStart", resourceRoot, vsOnResourceStart )

function vsOnStreamIn( )
	if getElementType( source ) ~= "vehicle" then return end
	if STREAMED_VEHICLES[ source ] then return end
	STREAMED_VEHICLES[ source ] = true
	addEventHandler( "onClientElementStreamOut", source, vsOnStreamOut )
	addEventHandler( "onClientElementDestroy", source, vsOnStreamOut )
end

function vsOnStreamOut( )
	STREAMED_VEHICLES[ source ] = nil
	vsUnloadSoundsForVehicle( source )
	removeEventHandler( "onClientElementStreamOut", source, vsOnStreamOut )
	removeEventHandler( "onClientElementDestroy", source, vsOnStreamOut )
end

function vsLoadSoundsForVehicle( vehicle, vehicle_data )
	if localPlayer.vehicle == vehicle then
		onClientVehicleEnter_handler( localPlayer )
	end
	
	local vehicle_sounds = {}
	for k, v in pairs( VEHICLE_CLASS_DATA[ vehicle_data.class ].sounds ) do
		local sound = playSound3D( "files/sfx/transport_" .. vehicle_data.class .. "_" .. v .. ".ogg", vehicle.position, true )
		
		setElementDimension( sound, vehicle.dimension )
		attachElements( sound, vehicle )
		
		sound.maxDistance = VEHICLE_CLASS_DATA[ vehicle_data.class ].distance
		sound.volume = k == VEHICLE_IDLE and vehicle_data.def_volume * CURRENT_MULTIPLY_VOLUME or 0
		sound.speed = vehicle_data.def_speed or 1

		vehicle_sounds[ k ] = sound
	end
	ENGINE_SOUNDS[ vehicle ] = { sound = vehicle_sounds }
end

function vsUnloadSoundsForVehicle( vehicle )
	if not ENGINE_SOUNDS[ vehicle ] then return end

	for k, v in pairs( ENGINE_SOUNDS[ vehicle ].sound ) do
		if isElement( v ) then 
			destroyElement( v )
		end
	end
	
	ENGINE_SOUNDS[ vehicle ] = nil
end

function CheckRequiredVehicles()
	local cx, cy, cz = getCameraMatrix( )
	Async:foreach( STREAMED_VEHICLES, function( _, v )
		local vehicle_data = VEHICLE_CONFIG[ v.model ] and VEHICLE_CONFIG[ v.model ].variants[ v:GetVariant() ] or DEFAULT_VEHICLE_DATA
		if v.engineState and vehicle_data.class and not ENGINE_SOUNDS[ v ] and getDistanceBetweenPoints3D( cx, cy, cz, v.position ) <= VEHICLE_CLASS_DATA[ vehicle_data.class ].distance then
			vsLoadSoundsForVehicle( v, vehicle_data )
		elseif v.engineState and ENGINE_SOUNDS[ v ] and getElementVelocity(v) == 0 then
			for k, v in pairs( ENGINE_SOUNDS[ v ].sound ) do
				if k ~= VEHICLE_IDLE then
					v.volume = 0
					v.speed = 0
				end
			end
		end
		-- Чек тюнинга
		if ENGINE_SOUNDS[ v ] and (not localPlayer:getData( "drag_race" ) or not ENGINE_SOUNDS[ v ].max_velocity) then
			ENGINE_SOUNDS[ v ].max_velocity = getVehicleHandling( v )[ "maxVelocity" ]
			--ENGINE_SOUNDS[ v ].tuning_coeff = isVehicleUseSpeedLimit( v ) and 0.4 or math_abs(ENGINE_SOUNDS[ v ].max_velocity - (vehicle_data.handling.maxVelocity or ENGINE_SOUNDS[ v ].max_velocity)) / 250
		end
	end )
	
	local radio_on = getElementData( localPlayer, "radio.channel" )
	if radio_on and radio_on.state == true then
		CURRENT_RADIO_COEFF = RADIO_ON_COEFFICIENT
	else
		CURRENT_RADIO_COEFF = RADIO_OFF_COEFFICIENT
	end
	if PREV_RADIO_COEFF ~= CURRENT_RADIO_COEFF then
		CURRENT_MULTIPLY_VOLUME = CURRENT_MULTIPLY_VOLUME / PREV_RADIO_COEFF
		PREV_RADIO_COEFF = CURRENT_RADIO_COEFF
		CURRENT_MULTIPLY_VOLUME = math_min( 1, CURRENT_MULTIPLY_VOLUME * CURRENT_RADIO_COEFF )
	end
end
Timer( CheckRequiredVehicles, 500, 0 )

function onClientDragChangeGear_handler( vehicle, data )
	if not ENGINE_SOUNDS[ vehicle ] then return end

	ENGINE_SOUNDS[ vehicle ].custom_max_rpm = data.max_rpm
	ENGINE_SOUNDS[ vehicle ].custom_gear = data.gear
	if ENGINE_SOUNDS[ vehicle ].custom_gear == 0 then
		ENGINE_SOUNDS[ vehicle ].custom_rpm = 0
	end
	
	local vehicle_data = VEHICLE_CONFIG[ vehicle.model ] and VEHICLE_CONFIG[ vehicle.model ].variants[ vehicle:GetVariant() ] or DEFAULT_VEHICLE_DATA
	local individual_transmission = (INDIVIDUAL_VEHICLE_SETTING[ vehicle.model ] and INDIVIDUAL_VEHICLE_SETTING[ vehicle.model ].transmission) and INDIVIDUAL_VEHICLE_SETTING[ vehicle.model ].transmission
	local transmission_type = individual_transmission and individual_transmission or vehicle_data.class_transmission or VEHICLE_CLASS_DATA[ vehicle_data.class ].transmission or nil
	
	local sound = playSound( "files/sfx/transport_transmission_" .. transmission_type .. ".ogg" )
	sound.volume = vehicle_data.transmission_volume * CURRENT_MULTIPLY_VOLUME
	setElementDimension( sound, localPlayer.dimension )
end
addEvent( "onClientDragChangeGear" )
addEventHandler( "onClientDragChangeGear", root, onClientDragChangeGear_handler )

-- Управляем звуком и всем подряд
function vsRenderSounds( time_slice )	
	local cx, cy, cz = getCameraMatrix( )
	for vehicle, sound_data in pairs( ENGINE_SOUNDS ) do
		
		local px, py, pz = getElementPosition( vehicle )
		local engine_state = getVehicleEngineState( vehicle )
		local vehicle_data = VEHICLE_CONFIG[ vehicle.model ] and VEHICLE_CONFIG[ vehicle.model ].variants[ vehicle:GetVariant() ] or DEFAULT_VEHICLE_DATA
		local v_class = vehicle_data.class or "regular"

		if vehicle_data.class ~= "helicopter" and (not engine_state or getDistanceBetweenPoints3D( cx, cy, cz, px, py, pz ) > VEHICLE_CLASS_DATA[ v_class ].distance ) then
			vsUnloadSoundsForVehicle( vehicle )
		else
			local veh_dimension = getElementDimension( vehicle )
			for k, v in pairs( sound_data.sound ) do
				if getElementDimension( v ) ~= veh_dimension then
					setElementDimension( v, veh_dimension )
				end
			end

			if localPlayer:getData( "drag_race" ) and localPlayer.vehicle == vehicle and sound_data.custom_max_rpm then
				UpdateDragSound( time_slice, vehicle, sound_data, vehicle_data )
			else
				VEHICLE_CLASS_DATA[ v_class ].updateSound( time_slice, vehicle, sound_data, vehicle_data )
			end

			-- Переключение передач
			if localPlayer.vehicle == vehicle and vehicle.health > 400 and not DISABLE_GEARS[ vehicle.model ] and not localPlayer:getData( "drag_race" ) then
				local individual_transmission = (INDIVIDUAL_VEHICLE_SETTING[ vehicle.model ] and INDIVIDUAL_VEHICLE_SETTING[ vehicle.model ].transmission) and INDIVIDUAL_VEHICLE_SETTING[ vehicle.model ].transmission
				local transmission_type = individual_transmission and individual_transmission or vehicle_data.class_transmission or VEHICLE_CLASS_DATA[ v_class ].transmission or nil
				if transmission_type then
					local gear = getVehicleCurrentGear( vehicle )
					if sound_data.gear and gear > 0 and gear > sound_data.gear  then
						local sound = playSound( "files/sfx/transport_transmission_" .. transmission_type .. ".ogg" )
						sound.volume = vehicle_data.transmission_volume * CURRENT_MULTIPLY_VOLUME
						setElementDimension( sound, localPlayer.dimension )
					end
					sound_data.gear = gear
				end
			end
		end
	end
end

function onClientVehicleEnter_handler( player )
	if player ~= localPlayer then return end 
	CURRENT_MULTIPLY_VOLUME = math_min( 1, IN_VEHICLE_VOLUME * CURRENT_RADIO_COEFF ) 
end
addEventHandler( "onClientVehicleEnter", root, onClientVehicleEnter_handler )

function onClientVehicleExit_handler( player )
	if player ~= localPlayer then return end 
	CURRENT_MULTIPLY_VOLUME = math_min( 1, OUT_OF_VEHICLE_VOLUME * CURRENT_RADIO_COEFF ) 
end
addEventHandler( "onClientVehicleStartExit", root, onClientVehicleExit_handler )

function onSettingsChange_handler( changed, values )
	local change = false
	if values.vehicle_engine then
		IN_VEHICLE_VOLUME = values.vehicle_engine / 1.5
		OUT_OF_VEHICLE_VOLUME = values.vehicle_engine
		change = true
	end
	
	if not change then return end
	if localPlayer.vehicle then
		onClientVehicleEnter_handler( localPlayer )
	else
		onClientVehicleExit_handler( localPlayer )
	end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

triggerEvent( "onSettingsUpdateRequest", localPlayer, "engine" )


local keys_f = getBoundKeys( "forwards" )
local keys_b = getBoundKeys( "backwards" )
local keys_h = getBoundKeys( "handbrake" )

BURNOUT_VEHICLES = {}
AFTER_BURNOUT = {}

function onClientKey_handler( key, state )
	local vehicle = localPlayer.vehicle
	if vehicle then
		local vehicle_class = "regular"

		if VEHICLE_CONFIG[ vehicle.model ] then
			vehicle_class = VEHICLE_CONFIG[ vehicle.model ].variants[ vehicle:GetVariant( ) ].class or "regular"
		end
		if not VEHICLE_CLASS_DATA[ vehicle_class ].burnout_coeff then return end

		local forward = false
		local brake = false
		for k, v in pairs( keys_f ) do
			if getKeyState( k ) then 
				forward = true
				break
			end
		end
		for k, v in pairs( keys_b ) do
			if getKeyState( k ) then 
				brake = true
				break
			end
		end
		for k, v in pairs( keys_h ) do
			if getKeyState( k ) then 
				brake = true
				break
			end
		end
		if forward and brake and vehicle.gear <= 1 then
			if not BURNOUT_VEHICLES[ vehicle ] then
				BURNOUT_VEHICLES[ vehicle ] = 
				{
					ticks = getTickCount(),
					state = true,
				}
			end
			BURNOUT_VEHICLES[ vehicle ].state = true
		elseif forward and BURNOUT_VEHICLES[ vehicle ] then
			AFTER_BURNOUT[ vehicle ] = 
			{
				burnount_value = BURNOUT_VEHICLES[ vehicle ].diff,
				ticks = getTickCount(),
			}
			BURNOUT_VEHICLES[ vehicle ] = nil
		elseif not forward and BURNOUT_VEHICLES[ vehicle ] then
			BURNOUT_VEHICLES[ vehicle ].state = false
			BURNOUT_VEHICLES[ vehicle ].ticks = getTickCount()
		end
	end
end
addEventHandler( "onClientKey", root, onClientKey_handler )