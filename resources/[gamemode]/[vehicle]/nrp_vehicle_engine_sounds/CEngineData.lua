loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "ShAsync" )
Extend( "CVehicle" )
Extend( "ShVehicleConfig" )
Extend( "Globals" )

-- Минимизируем длительность обращения к math
math_min = math.min
math_max = math.max
math_floor = math.floor
math_abs = math.abs

-- Функция обработки звуков транспорта
function UpdateAutoEngine( time_slice, vehicle, sound_data, vehicle_data )
	if vehicle.gear >= 1 then
		
		local max_rpm = math.floor( ( sound_data.max_velocity / ( vehicle_data.handling.numberOfGears or 5) ) * 180 + 0.5 )

		local rpm = vehicle:GetVehicleRPM() / max_rpm
		local low_rpm = rpm / math_abs(vehicle_data.low_rpm - vehicle_data.acc_low)
		local high_rpm = rpm / math_abs	(vehicle_data.high_rpm)
		
		local speed = vehicle:GetSpeed() / ( vehicle_data.max_speed / 2 )
		sound_data.sound[ VEHICLE_IDLE ].volume = math_max( 0, vehicle_data.def_volume - speed * 3 ) * CURRENT_MULTIPLY_VOLUME
		
		sound_data.sound[ VEHICLE_LOW ].volume = math_min( 0.5, low_rpm ) * CURRENT_MULTIPLY_VOLUME
		sound_data.sound[ VEHICLE_LOW ].speed  = math_min( vehicle_data.max_speedl_sound or 2, low_rpm )
		
		sound_data.sound[ VEHICLE_HIGH ].volume = math_min( 1.2, high_rpm ) * CURRENT_MULTIPLY_VOLUME
		sound_data.sound[ VEHICLE_HIGH ].speed  = math_min( vehicle_data.max_speedh_sound, high_rpm )
	elseif vehicle.gear == 0 then
		sound_data.sound[ VEHICLE_IDLE ].volume = vehicle_data.def_volume * CURRENT_MULTIPLY_VOLUME
	end
end

local keys_f = getBoundKeys( "forwards" )
function UpdateDragSound( time_slice, vehicle, sound_data, vehicle_data )
	if sound_data.custom_gear == 0 then
		local forward = false
		for k, v in pairs( keys_f ) do
			if getKeyState( k ) then 
				forward = true
				break
			end
		end
		
		if forward then
			ENGINE_SOUNDS[ vehicle ].custom_rpm = math_min( ENGINE_SOUNDS[ vehicle ].custom_rpm + time_slice, sound_data.custom_max_rpm )
		else
			ENGINE_SOUNDS[ vehicle ].custom_rpm = math_max( 0, ENGINE_SOUNDS[ vehicle ].custom_rpm - time_slice )
		end

		local rpm = ENGINE_SOUNDS[ vehicle ].custom_rpm / sound_data.custom_max_rpm
		local low_rpm = rpm / math_abs(vehicle_data.low_rpm + sound_data.tuning_coeff - vehicle_data.acc_low)
		local high_rpm = rpm / math_abs	(vehicle_data.high_rpm + sound_data.tuning_coeff)

		sound_data.sound[ VEHICLE_IDLE ].volume = math_max( 0, vehicle_data.def_volume ) * CURRENT_MULTIPLY_VOLUME
		
		sound_data.sound[ VEHICLE_LOW ].volume = math_min( 0.5, low_rpm ) * CURRENT_MULTIPLY_VOLUME
		sound_data.sound[ VEHICLE_LOW ].speed  = math_min( vehicle_data.max_speedl_sound or 2, low_rpm )
			
		sound_data.sound[ VEHICLE_HIGH ].volume = math_min( 1.2, high_rpm ) * CURRENT_MULTIPLY_VOLUME
		sound_data.sound[ VEHICLE_HIGH ].speed  = math_min( vehicle_data.max_speedh_sound, high_rpm )


	else
		local rpm = vehicle:GetVehicleRPM() / sound_data.custom_max_rpm
		local low_rpm = rpm / math_abs(vehicle_data.low_rpm + sound_data.tuning_coeff - vehicle_data.acc_low)
		local high_rpm = rpm / math_abs	(vehicle_data.high_rpm + sound_data.tuning_coeff)
		
		local speed = vehicle:GetSpeed() / ( vehicle_data.max_speed / 2 )
		sound_data.sound[ VEHICLE_IDLE ].volume = math_max( 0, vehicle_data.def_volume - speed * 3 ) * CURRENT_MULTIPLY_VOLUME
		
		sound_data.sound[ VEHICLE_LOW ].volume = math_min( 0.5, low_rpm ) * CURRENT_MULTIPLY_VOLUME
		sound_data.sound[ VEHICLE_LOW ].speed  = math_min( vehicle_data.max_speedl_sound or 2, low_rpm )
			
		sound_data.sound[ VEHICLE_HIGH ].volume = math_min( 1.2, high_rpm ) * CURRENT_MULTIPLY_VOLUME
		sound_data.sound[ VEHICLE_HIGH ].speed  = math_min( vehicle_data.max_speedh_sound, high_rpm )
	end
end

function UpdateBuggyEngine( time_slice, vehicle, sound_data, vehicle_data )
	local max_rpm = math.floor( ( sound_data.max_velocity / ( vehicle_data.handling.numberOfGears or 5) ) * 180 + 0.5 )

	local rpm = vehicle:GetVehicleRPM() / max_rpm
	local low_rpm = rpm / math_abs(vehicle_data.low_rpm + sound_data.tuning_coeff - vehicle_data.acc_low)
	
	local speed = vehicle:GetSpeed() / ( vehicle_data.max_speed / 5 )

	if vehicle.gear >= 1 then

		if vehicle.health < 400 then
			low_rpm = low_rpm * 3
		end

		sound_data.sound[ VEHICLE_IDLE ].volume = math_max( 0, vehicle_data.def_volume - speed ) * CURRENT_MULTIPLY_VOLUME

		sound_data.sound[ VEHICLE_DRIVE ].volume = math_min( 0.5, low_rpm ) * CURRENT_MULTIPLY_VOLUME
		sound_data.sound[ VEHICLE_DRIVE	 ].speed  = low_rpm
	elseif vehicle.gear == 0 then
		sound_data.sound[ VEHICLE_IDLE ].volume = vehicle_data.def_volume * CURRENT_MULTIPLY_VOLUME
	end
end

function Update2TactcsEngine( time_slice, vehicle, sound_data, vehicle_data )
	local speed_drive = (vehicle:GetSpeed() / ( vehicle_data.max_speed )) * vehicle_data.acc_low

	sound_data.sound[ VEHICLE_DRIVE ].volume = math_min( vehicle_data.def_volume, speed_drive ) * CURRENT_MULTIPLY_VOLUME
	sound_data.sound[ VEHICLE_DRIVE ].speed  = math_min( 0.7, speed_drive * 1.5 )

	local speed = vehicle:GetSpeed() / ( vehicle_data.max_speed / 2 ) * vehicle_data.acc_low
	sound_data.sound[ VEHICLE_IDLE ].volume = math_max( 0, vehicle_data.def_volume - speed * 1.5 ) * CURRENT_MULTIPLY_VOLUME
end

function UpdateHelicopterEngine( time_slice, vehicle, sound_data, vehicle_data )
	local speed_drive = math_round( vehicle:GetSpeed() / ( vehicle_data.max_speed ), 3 )
	if vehicle.controller then
		local volume = speed_drive == 0 and math_min( 1, sound_data.sound[ VEHICLE_IDLE ].volume + 0.3 ) or 1 * ( 1 + speed_drive )
		sound_data.sound[ VEHICLE_IDLE ].volume = math_min( 1.5, volume ) * CURRENT_MULTIPLY_VOLUME
		sound_data.sound[ VEHICLE_IDLE ].speed  = math_min( 1, sound_data.sound[ VEHICLE_IDLE ].speed + time_slice / 3000 )
	else
		sound_data.sound[ VEHICLE_IDLE ].volume = math_min( 1, sound_data.sound[ VEHICLE_IDLE ].volume - 0.4 ) * CURRENT_MULTIPLY_VOLUME
		sound_data.sound[ VEHICLE_IDLE ].speed  = math_min( 1, sound_data.sound[ VEHICLE_IDLE ].speed - time_slice / 5000 )
	end
end

function UpdateAeroplaneEngine( time_slice, vehicle, sound_data, vehicle_data )
	if vehicle.controller then
		local speed_drive = (vehicle:GetSpeed() / vehicle_data.max_speed) * 3
		sound_data.sound[ VEHICLE_IDLE ].volume = math_min( 1, math_max( 0.5, speed_drive ) ) * CURRENT_MULTIPLY_VOLUME
		sound_data.sound[ VEHICLE_IDLE ].speed  = math_min( 1, 0.4 + speed_drive )
	else
		sound_data.sound[ VEHICLE_IDLE ].volume = math_min( 1, sound_data.sound[ VEHICLE_IDLE ].volume - 0.4 ) * CURRENT_MULTIPLY_VOLUME
		sound_data.sound[ VEHICLE_IDLE ].speed  = math_min( 1, sound_data.sound[ VEHICLE_IDLE ].speed - time_slice / 5000 )
	end
end

function UpdateBoatSoundEngine( time_slice, vehicle, sound_data, vehicle_data )
	local max_rpm = math.floor( ( sound_data.max_velocity / ( vehicle_data.handling.numberOfGears or 5) ) * 180 + 0.5 ) / 3

	local rpm = vehicle:GetVehicleRPM() / max_rpm
	sound_data.sound[ VEHICLE_IDLE ].volume = math_max( 0, vehicle_data.def_volume - rpm ) * CURRENT_MULTIPLY_VOLUME

	sound_data.sound[ VEHICLE_DRIVE ].volume = math_min( 1, rpm ) * CURRENT_MULTIPLY_VOLUME
	sound_data.sound[ VEHICLE_DRIVE ].speed  = math_min( 1, rpm )
end

function UpdateIndustrialFishSoundEngine( time_slice, vehicle, sound_data, vehicle_data ) 
	sound_data.sound[ VEHICLE_IDLE ].volume = 1 * CURRENT_MULTIPLY_VOLUME
end

function UpdateElectricSoundEngine( time_slice, vehicle, sound_data, vehicle_data )
	local max_rpm = math.floor( ( sound_data.max_velocity / ( vehicle_data.handling.numberOfGears or 5) ) * 180 + 0.5 ) / 3
	local speed = vehicle:GetSpeed() / ( vehicle_data.max_speed / 5 )

	local rpm = speed * 2
	local low_rpm = rpm / math_abs(vehicle_data.low_rpm + sound_data.tuning_coeff - vehicle_data.acc_low)

	if vehicle.gear >= 1 then
		if vehicle.health < 400 then
			low_rpm = low_rpm * 3
		end
		sound_data.sound[ VEHICLE_IDLE ].volume = math_max( 0, vehicle_data.def_volume - speed )

		sound_data.sound[ VEHICLE_DRIVE ].volume = math_min( 0.5, low_rpm )
		sound_data.sound[ VEHICLE_DRIVE	 ].speed  = low_rpm
	elseif vehicle.gear == 0 then
		sound_data.sound[ VEHICLE_IDLE ].volume = vehicle_data.def_volume
	end
end

-- Возможные состояния перемещения транспорта
enum "eVehicleState" {
	"VEHICLE_IDLE",
	"VEHICLE_LOW",
	"VEHICLE_HIGH",
	"VEHICLE_DRIVE"
}

-- Количество звуков транспорта
enum "eVehicleCountSounds" {
	"VEHICLE_ILH",
	"VEHICLE_ID",
	"VEHICLE_I",
}

VEHICLE_GROUP_SOUND =
{
	[ VEHICLE_I ] =
	{
		[ VEHICLE_IDLE ] = "idle",
	},
	[ VEHICLE_ID ] =
	{
		[ VEHICLE_IDLE  ] = "idle",
		[ VEHICLE_DRIVE ] = "drive",
	},
	[ VEHICLE_ILH ] =
	{
		[ VEHICLE_IDLE ] = "idle",
		[ VEHICLE_LOW ]  = "low",
		[ VEHICLE_HIGH ] = "high",
	},
}

-- Сеттинг для каждого класса
VEHICLE_CLASS_DATA =
{
	[ "rus" ] = 
	{
		[ "transmission"] = "econom",
		[ "setting" ] 	  = { acc_low = 0.2, low_rpm = 0.45, high_rpm = 0.7, def_volume = 0.4, transmission_volume = 0.2, max_speedh_sound = 1.2 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ILH ],
		[ "updateSound" ] = UpdateAutoEngine,
		[ "distance" ] = 30,
		[ "burnout_coeff" ] = 0.15,
	},
	[ "regular" ] = 
	{
		[ "transmission"] = "regular",
		[ "setting" ] = { acc_low = 0.3, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.4, transmission_volume = 0.15, max_speedl_sound = 2, max_speedh_sound = 1.3 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ILH ],
		[ "updateSound" ] = UpdateAutoEngine,
		[ "distance" ] = 30,
		[ "burnout_coeff" ] = 0.3,
	},
	[ "muscles" ] = 
	{
		[ "transmission"] = "econom",
		[ "setting" ] = { acc_low = 0.3, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.4, transmission_volume = 0.2, max_speedh_sound = 1.2 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ILH ],
		[ "updateSound" ] = UpdateAutoEngine,
		[ "distance" ] = 30,
		[ "burnout_coeff" ] = 0.4,
	},
	[ "sport" ]	= 
	{
		[ "transmission"] = "sport",
		[ "setting" ] = { acc_low = 0.2, low_rpm = 0.5, high_rpm = 0.6, def_volume = 0.4, transmission_volume = 0.2, max_speedh_sound = 1.6 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ILH ],
		[ "updateSound" ] = UpdateAutoEngine,
		[ "distance" ] = 30,
		[ "burnout_coeff" ] = 0.3,	
	},
	[ "fast" ] 	= 
	{
		[ "transmission"] = "econom",
		[ "setting" ] = { acc_low = 0.3, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.3, transmission_volume = 0.1, max_speedh_sound = 1.2 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ILH ],
		[ "updateSound" ] = UpdateAutoEngine,
		[ "distance" ] = 30,
		[ "burnout_coeff" ] = 0.3,
	},
	[ "offroad_1" ] = 
	{
		[ "transmission"] = "econom",
		[ "setting" ] = { acc_low = 0.25, low_rpm = 0.8, high_rpm = 0.85, def_volume = 0.3, transmission_volume = 0.075, max_speedh_sound = 1.6 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ILH ],
		[ "updateSound" ] = UpdateAutoEngine,
		[ "distance" ] = 40,
		[ "burnout_coeff" ] = 0.3,
	},
	[ "offroad_2" ] = 
	{
		[ "transmission"] = "econom",
		[ "setting" ] = { acc_low = 0.25, low_rpm = 0.8, high_rpm = 0.85, def_volume = 0.3, transmission_volume = 0.075, max_speedh_sound = 1.6 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ILH ],
		[ "updateSound" ] = UpdateAutoEngine,
		[ "distance" ] = 40,
		[ "burnout_coeff" ] = 0.3,
	},
	[ "buggy" ] 	= 
	{
		[ "transmission"] = "econom",
		[ "setting" ] = { acc_low = 0.1, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.3, transmission_volume = 0.1 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ID ],
		[ "updateSound" ] = UpdateBuggyEngine,
		[ "distance" ] = 27,
		[ "burnout_coeff" ] = 0.3,
	},
	[ "kamaz" ] 	= 
	{
		[ "transmission"] = "econom",
		[ "setting" ] = { acc_low = 0.3, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.4, transmission_volume = 0.2, max_speedh_sound = 1.3 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ILH ],
		[ "updateSound" ] = UpdateAutoEngine,
		[ "distance" ] = 45,
		[ "burnout_coeff" ] = 0.3,
	},
	[ "motosport" ] = 
	{
		[ "setting" ] = { max_speedh_sound = 1.3, acc_low = 0.1, low_rpm = 0.3, high_rpm = 0.55, def_volume = 0.4 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ILH ],
		[ "updateSound" ] = UpdateAutoEngine,
		[ "distance" ] = 35,
		[ "burnout_coeff" ] = 0.3,
	},
	[ "motochopper" ] = 
	{
		[ "transmission"] = "econom",
		[ "setting" ] = { acc_low = 0.3, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.4, transmission_volume = 0.2, max_speedh_sound = 1.3 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ILH ],
		[ "updateSound" ] = UpdateAutoEngine,
		[ "distance" ] = 35,
		[ "burnout_coeff" ] = 0.3,
	},
	[ "2tacts" ] = 
	{
		[ "setting" ] = { acc_low = 1.4, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.4 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ID ],
		[ "updateSound" ] = Update2TactcsEngine,
		[ "distance" ] = 25,
	},
	[ "motorboat" ] =
	{
		[ "setting" ] = { low_rpm = 0.5, def_volume = 0.5, transmission_volume = 0.2 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ID ],
		[ "updateSound" ] = UpdateBoatSoundEngine,
		[ "distance" ] = 30,
	},
	[ "industrial_fish" ] = 
	{
		[ "transmission"] = "econom",
		[ "setting" ] = { low_rpm = 0.5, def_volume = 0.5, transmission_volume = 0.2 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_I ],
		[ "updateSound" ] = UpdateIndustrialFishSoundEngine,
		[ "distance" ] = 350,
	},
	[ "turboboat" ] = 
	{
		[ "transmission"] = "econom",
		[ "setting" ] = { low_rpm = 0.5, def_volume = 0.5, transmission_volume = 0.2 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ID ],
		[ "updateSound" ] = UpdateBoatSoundEngine,
		[ "distance" ] = 30,
	},
	[ "helicopter" ] = 
	{
		[ "setting" ] = { def_speed = 0, def_volume = 0.55 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_I ],
		[ "updateSound" ] = UpdateHelicopterEngine,
		[ "distance" ] = 60,
	},
	[ "aeroplane" ] = 
	{
		[ "setting" ] = { def_speed = 0.2, def_volume = 0 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_I ],
		[ "updateSound" ] = UpdateAeroplaneEngine,
		[ "distance" ] = 80,
	},
	[ "aeroplane_rotor" ] = 
	{
		[ "setting" ] = { def_speed = 0.2, def_volume = 0 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_I ],
		[ "updateSound" ] = UpdateAeroplaneEngine,
		[ "distance" ] = 100,
	},
	[ "electric" ] 	= 
	{
		[ "transmission"] = "econom",
		[ "setting" ] = { acc_low = 0.0, low_rpm = 13.0, high_rpm = 0.0, def_volume = 0.1, transmission_volume = 0.1 },
		[ "sounds" ] = VEHICLE_GROUP_SOUND[ VEHICLE_ID ],
		[ "updateSound" ] = UpdateElectricSoundEngine,
		[ "distance" ] = 27,
	},
}

INDIVIDUAL_VEHICLE_SETTING =
{
	[ 415 ]  = { setting = { acc_low = 0.2, low_rpm = 0.6, high_rpm = 0.8, def_volume = 0.5, transmission_volume = 0.2, max_speedh_sound = 1.6 }, },
	[ 480 ]  = { setting = { acc_low = 0.15, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.3, transmission_volume = 0.1, max_speedh_sound = 1.2 }, },
	[ 439 ]  = { setting = { acc_low = 0.15, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.3, transmission_volume = 0.1, max_speedh_sound = 1.2 }, },
	[ 572 ]  = { setting = { acc_low = 0.3, low_rpm = 0.8, high_rpm = 0.9, def_volume = 0.4, transmission_volume = 0.15, max_speedl_sound = 1.2, max_speedh_sound = 1 }, },
	[ 6532 ] = { setting = { acc_low = 0.3, low_rpm = 0.7, high_rpm = 0.8, def_volume = 0.3, transmission_volume = 0.1, max_speedh_sound = 1.2 }, },
	[ 571 ]  = { setting = { acc_low = 2.3, def_volume = 0.4 }, },
	[ 6561 ] = { transmission = "sport", },
	[ 474 ]  = { transmission = "sport", },
	[ 6563 ] = { setting = { acc_low = 0.3, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.4, transmission_volume = 0.08, max_speedl_sound = 2, max_speedh_sound = 1.3 }, transmission = "regular", },
	[ 6564 ] = { setting = { acc_low = 0.3, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.4, transmission_volume = 0.1, max_speedl_sound = 2, max_speedh_sound = 1.3 },transmission = "regular", },
	[ 6566 ] = { transmission = "econom", },
	[ 6565 ] = { transmission = "regular", },
	[ 494 ]  = { transmission = "sport", },
	[ 505 ]  = { setting = { acc_low = 0.3, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.4, transmission_volume = 0.07, max_speedl_sound = 2, max_speedh_sound = 1.3 }, transmission = "regular", },
	[ 559 ]  = { setting = { acc_low = 0.3, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.4, transmission_volume = 0.07, max_speedl_sound = 2, max_speedh_sound = 1.3 }, transmission = "regular", },
	[ 6562 ] = { setting = { acc_low = 0.3, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.4, transmission_volume = 0.07, max_speedl_sound = 2, max_speedh_sound = 1.3 }, transmission = "regular", },
	[ 6567 ] = { setting = { acc_low = 0.3, low_rpm = 0.6, high_rpm = 0.7, def_volume = 0.4, transmission_volume = 0.07, max_speedl_sound = 2, max_speedh_sound = 1.3 }, transmission = "regular", },
	[ 6567 ] = { setting = { acc_low = 0.3, low_rpm = 0.7, high_rpm = 0.8, def_volume = 0.3, transmission_volume = 0.1, max_speedh_sound = 1.2, max_speedh_sound = 1.32 }, },
}

DISABLE_GEARS = {
	[ 6538 ] = true,
	[ 572 ] = true,
	[ 6611 ] = true,
}

for vehicle_id, vehicle_data in pairs( VEHICLE_CONFIG ) do
	for vehicle_variant, vehicle_variant_data in pairs( vehicle_data.variants ) do
		for k, v in pairs( INDIVIDUAL_VEHICLE_SETTING[ vehicle_id ] and INDIVIDUAL_VEHICLE_SETTING[ vehicle_id ].setting or VEHICLE_CLASS_DATA["rus" ].setting ) do
			vehicle_variant_data[ k ] = v
		end
	end
end

DEFAULT_VEHICLE_DATA = VEHICLE_CONFIG[ 482 ].variants[ 1 ]

function math_round( num,  idp )
	local mult = 10^(idp or 0)
	return math_floor(num * mult + 0.5) / mult
end