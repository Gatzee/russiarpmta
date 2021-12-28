local event_id = "new_year_king_mountain"

local CONST_TEXT_TO_START = {
	"Уворачивайся",
	"Толкай",
	"Спасайся от лавины",
}

local CONST_TIME_IN_MS_TO_TEXT_START = 1500
local CONST_TIME_TO_START_EVENT = 3
local CONST_TIME_TO_EVENT_END = 5 * 60
local CONST_TIME_TO_RESPAWN = 10
local CONST_TIME_TO_CHANGE_COLLISION = 3
local CONST_TIME_TO_NEXT_LEVEL = 60
local CONST_VEHICLE_HEALTH = 500
local CONST_MINIGUN_DAMAGE = 3 / CONST_VEHICLE_HEALTH * ( 1000 - 400 )
local CONST_ROCKET_DAMAGE = 250 / CONST_VEHICLE_HEALTH * ( 1000 - 400 )

local CONST_MINIGUN_AMMO = 100
local CONST_MINIGUN_TIME_TO_RELOAD = 15
local CONST_MINIGUN_TIME_TO_FIRE = 0.05

local CONST_ROCKET_AMMO = 2
local CONST_ROCKET_TIME_TO_RELOAD = 60
local CONST_ROCKET_TIME_TO_FIRE = 1

local CONST_LEVELS = 5
local CONST_POINTS = 1000
local CONST_RESPAWN_POINTS = 25

local CONST_VEHICLE_MODEL = 480
local CONST_MAP_MODEL = 3458

local CONST_HEIGHT_LEVELS = { 1, 11, 22, 32, 42 }

local CONST_SPAWN_POSITIONS = {
	-- 1 уровень
	[ 1 ] = {
		{ x = -2380.4831542969, y = -2869.8874511719, z = 2.2723367214203, rz = 90 },
		{ x = -2416.0852050781, y = -2870.12890625, z = 2.2720086574554, rz = - 90 },
		{ x = -2416.2619628906, y = -2920.0717773438, z = 2.2725219726563, rz = 270 },
		{ x = -2380.9833984375, y = -2920.0717773438, z = 2.2725386619568, rz = -270 },
		{ x = -2398.5268554688, y = -2894.8669433594, z = 2.2645494937897, rz = 90 },
	},	

	-- 2 уровень
	[ 2 ] = {
		{ x = -2416.2729492188, y = -3006.4243164063, z = 12.624798774719, rz = 270 },
		{ x = -2381.0419921875, y = -3006.4243164063, z = 12.624747276306, rz = -270 },
		{ x = -2380.66796875, y = -3045.4663085938, z = 12.624914169312, rz = 90 },
		{ x = -2416.3264160156, y = -3045.6833496094, z = 12.614954948425, rz = 270 },
		{ x = -2433.923828125, y = -3006.5583496094, z = 12.624914169312, rz = 270 },
	},
	
	-- 3 уровень
	[ 3 ] = {
		{ x = -2393.2487792969, y = -3135.8488769531, z = 23.042652130127, rz = 90 },
		{ x = -2393.5637207031, y = -3110.6667480469, z = 23.032831192017, rz = 180 },
		{ x = -2418.7980957031, y = -3135.9187011719, z = 23.042921066284, rz = 270 },
		{ x = -2393.4643554688, y = -3161.3459472656, z = 23.022583007813, rz = 0 },
		{ x = -2368.1572265625, y = -3135.8491210938, z = 23.022947311401, rz = 90 },
	},
	
	-- 4 уровень
	[ 4 ] = {
		{ x = -2410.8232421875, y = -3209.5295410156, z = 33.482532501221, rz = 180 },
		{ x = -2375.9079589844, y = -3209.6071777344, z = 33.482696533203, rz = 180 },
		{ x = -2375.9523925781, y = -3245.1623535156, z = 33.462215423584, rz = 0 },
		{ x = -2411.1818847656, y = -3245.0942382813, z = 33.472358703613, rz = 0 },
		{ x = -2393.546875, y = -3226.6098632813, z = 33.44397354126, rz = 0 },
	},

	-- 5 уровень
	[ 5 ] = {
		{ x = -2411.6647949219, y = -3288.8500976563, z = 43.902721405029, rz = 270 },
		{ x = -2375.255859375, y = -3288.7517089844, z = 43.902519226074, rz = 90 },
		{ x = -2375.291015625, y = -3299.3090820313, z = 43.902690887451, rz = 90 },
		{ x = -2411.7431640625, y = -3299.3081054688, z = 43.902206420898, rz = 270 },
		{ x = -2393.5705566406, y = -3293.8286132813, z = 43.89518737793, rz = 180 },
	},
}

local CONST_RESPAWN_CAMERA_MAXTRIX = { 
	{ -498.6572265625, -427.40496826172, 78.835151672363, -424.61749267578, -406.27590942383, 15.025424957275, 0, 70 },
	{ -470.76177978516, -549.48638916016, 78.181427001953, -401.8483581543, -530.85656738281, 8.1537942886353, 0, 70 },
	{ -461.19091796875, -660.78826904297, 74.645248413086, -387.22595214844, -641.06958007813, 10.299651145935, 0, 70 },
	{ -435.54528808594, -740.90521240234, 68.148849487305, -365.79046630859, -718.33868408203, 0.14138053357601, 0, 70 },
	{ -427.54006958008, -810.50823974609, 68.85075378418, -368.51931762695, -765.83331298828, 1.6145988702774, 0, 70 }
}

local CONST_WATER_POSITION = { -2388.614 + 2000, -2849 + 2500, 1 }
local CONST_WASTED_POSITIONS = {
	Vector3( -46.353, 312.038, 21 ),
	Vector3( -44.938, 318.979, 21 ),
	Vector3( -43.090, 326.953, 21 ),
	Vector3( -41.741, 333.919, 21 ),
	Vector3( -40.159, 340.896, 21 )
}

local CONST_WATER_HEIGHT = 700
local CONST_WATER_WIDTH = 700

local CONST_MAP_OBJECT_POSITIONS = {
	-- 1 уровень
	{ x  = -2398.4528808594, y = -2869.8659667969, z = 0.09, rz = 0, model = 642 },
	{ x  = -2416.1535644531, y = -2861.1652832031, z = 0.1, rz = 270, model = 642 },
	{ x  = -2380.8520507813, y = -2861.1652832031, z = 0.1, rz = 90, model = 642 },
	{ x  = -2429.7551269531, y = -2859.8620605469, z = 0.08, rz = 315, model = 642 },
	{ x  = -2367.2507324219, y = -2859.8620605469, z = 0.08, rz = 45, model = 642 },
	{ x  = -2371.3513183594, y = -2843.5676269531, z = 0.09, rz = 0, model = 642 },
	{ x  = -2425.6530761719, y = -2843.5676269531, z = 0.09, rz = 0, model = 642 },
	{ x  = -2398.4528808594, y = -2861.1652832031, z = 0.1, rz = 90, model = 642 },
	{ x  = -2398.4528808594, y = -2843.5776269531, z = 0.08, rz = 0, model = 642 },
	{ x  = -2443.3537597656, y = -2861.1652832031, z = 0.1, rz = 90, model = 642 },
	{ x  = -2353.6516113281, y = -2861.1652832031, z = 0.1, rz = 270, model = 642 },
	{ x  = -2416.1533203125, y = -2886.1723632813, z = 2.5899996757507, rz = 180, model = 643 },
	{ x  = -2380.8525390625, y = -2886.1723632813, z = 2.5899996757507, rz = 180, model = 643 },
	{ x  = -2398.4528808594, y = -2894.9760644531, z = 0.1, rz = 0, model = 642 },
	{ x  = -2371.3513183594, y = -2894.9660644531, z = 0.09, rz = 0, model = 642 },
	{ x  = -2425.6530761719, y = -2894.9660644531, z = 0.09, rz = 0, model = 642 },
	{ x  = -2398.4628808594, y = -2894.9660644531, z = 0.09, rz = 90, model = 642 },
	{ x  = -2443.3637597656, y = -2894.9660644531, z = 0.08, rz = 90, model = 642 },
	{ x  = -2353.6416113281, y = -2894.9660644531, z = 0.08, rz = 270, model = 642 },

	---------------------------------------------

	{ x  = -2398.4528808594, y = -2920.0661621093, z = 0.09, rz = 0, model = 642 },
	{ x  = -2416.1535644531, y = -2928.7668457031, z = 0.1, rz = 270, model = 642 },
	{ x  = -2380.8520507813, y = -2928.7668457031, z = 0.1, rz = 90, model = 642 },
	{ x  = -2429.7551269531, y = -2930.0700683593, z = 0.08, rz = -315, model = 642 },
	{ x  = -2367.2507324219, y = -2930.0700683593, z = 0.08, rz = -45, model = 642 },
	{ x  = -2371.3513183594, y = -2946.3645019531, z = 0.09, rz = 0, model = 642 },
	{ x  = -2425.6530761719, y = -2946.3645019531, z = 0.09, rz = 0, model = 642 },
	{ x  = -2398.4528808594, y = -2928.7668457031, z = 0.1, rz = 90, model = 642 },
	{ x  = -2398.4528808594, y = -2946.3545019531, z = 0.08, rz = 0, model = 642 },
	{ x  = -2443.3537597656, y = -2928.7668457031, z = 0.1, rz = 90, model = 642 },
	{ x  = -2353.6516113281, y = -2928.7668457031, z = 0.1, rz = 270, model = 642 },
	{ x  = -2416.1533203125, y = -2903.7597656249, z = 2.5899996757507, rz = 0, model = 643 },
	{ x  = -2380.8525390625, y = -2903.7597656249, z = 2.5899996757507, rz = 0, model = 643 },

	-- переход 1 - 2
	{ x  = -2380.8520507813, y = -2968.4650878906, z = 5.2900009155273, rz = 270, ry = -15, model = 642 },
	{ x  = -2416.1535644531, y = -2968.4650878906, z = 5.2900009155273, rz = 270, ry = -15, model = 642 },
	
	-- 2 уровень
	{ x  = -2415.6530761719, y = -3006.4659667969, z = 10.45, rz = 0, model = 642 },
	{ x  = -2381.3513183594, y = -3006.4759667969, z = 10.44, rz = 0, model = 642 },
	{ x  = -2416.1535644531, y = -3007.7652832031, z = 10.46, rz = 270, model = 642 },
	{ x  = -2380.8520507813, y = -3007.7652832031, z = 10.46, rz = 90, model = 642 },
	{ x  = -2381.3513183594, y = -2990.1776269531, z = 10.44, rz = 0, model = 642 },
	{ x  = -2415.6530761719, y = -2990.1676269531, z = 10.45, rz = 0, model = 642 },
	{ x  = -2433.3637597656, y = -3007.7652832031, z = 10.46, rz = 90, model = 642 },
	{ x  = -2363.6416113281, y = -3007.7652832031, z = 10.46, rz = 270, model = 642 },

	---------------------------------------------

	{ x  = -2381.3513183594, y = -3045.6761621093, z = 10.46, rz = 0, model = 642 },
	{ x  = -2415.6530761719, y = -3045.6661621093, z = 10.45, rz = 0, model = 642 },
	{ x  = -2416.1635644531, y = -3044.3668457031, z = 10.44, rz = 270, model = 642 },
	{ x  = -2380.8620507813, y = -3044.3668457031, z = 10.43, rz = 90, model = 642 },
	{ x  = -2381.3513183594, y = -3061.9545019531, z = 10.44, rz = 0, model = 642 },
	{ x  = -2415.6530761719, y = -3061.9645019531, z = 10.45, rz = 0, model = 642 },
	{ x  = -2433.3537597656, y = -3044.3668457031, z = 10.44, rz = 90, model = 642 },
	{ x  = -2363.6516113281, y = -3044.3668457031, z = 10.45, rz = 270, model = 642 },
	{ x  = -2398.4528808594, y = -2999.6659179688, z = 10.43, rz = 337, model = 642 },
	{ x  = -2398.4528808594, y = -3053.6686035156, z = 10.42, rz = 337, model = 642 },

	--переход 2 - 3
	{ x  = -2363.6516113281, y = -3084.3696289063, z = 15.71, rz = 270, ry = -15, model = 642 },
	{ x  = -2416.1635644531, y = -3084.3696289063, z = 15.71, rz = 270, ry = -15, model = 642 },

	-- 3 уровень
	{ x  = -2381.3513183594, y = -3106.0656738281, z = 20.85, rz = 0, model = 642 },
	{ x  = -2405.6530761719, y = -3106.0756738281, z = 20.87, rz = 0, model = 642 },
	{ x  = -2423.2859082031, y = -3123.7073339844, z = 20.86, rz = 90, model = 642 },
	{ x  = -2363.6516113281, y = -3123.7073339844, z = 20.86, rz = 90, model = 642 },
	{ x  = -2393.4848828124, y = -3123.7073339844, z = 20.86, rz = 90, model = 642 },
	{ x  = -2378.65234375, y = -3121.265625, z = 20.83, rz = 45, model = 642 },
	{ x  = -2407.65234375, y = -3121.265625, z = 20.83, rz = -45, model = 642 },

	---------------------------------------------

	{ x  = -2381.3513183594, y = -3165.6456738281, z = 20.85, rz = 0, model = 642 },
	{ x  = -2405.6530761719, y = -3165.6556738281, z = 20.87, rz = 0, model = 642 },
	{ x  = -2423.2959082031, y = -3148.0090917969, z = 20.88, rz = 90, model = 642 },
	{ x  = -2363.6616113281, y = -3148.0090917969, z = 20.88, rz = 90, model = 642 },
	{ x  = -2393.4948828125, y = -3148.0090917969, z = 20.85, rz = 90, model = 642 },
	{ x  = -2407.65234375, y = -3150.4658203125, z = 20.83, rz = 45, model = 642 },
	{ x  = -2378.65234375, y = -3150.4658203125, z = 20.83, rz = -45, model = 642 },
	{ x  = -2381.3513183594, y = -3135.8556738281, z = 20.85, rz = 0, model = 642 },
	{ x  = -2405.6530761719, y = -3135.8656738281, z = 20.87, rz = 0, model = 642 },

	-- рампы
	{ x  = -2423.2948828125, y = -3172.9556738281, z = 23.43, rz = 180, model = 643 },
	{ x  = -2363.6948828125, y = -3172.9556738281, z = 23.43, rz = 180, model = 643 },

	-- переход 3 - 4
	{ x  = -2393.4948828125, y = -3188.0668945313, z = 26.129999160767, rz = -90, ry = -15, model = 642 },

	-- 4 уровень
	{ x  = -2393.4948828125, y = -3209.72, z = 31.31, rz = 0, model = 642 },
	{ x  = -2411.13, y = -3227.3550878906, z = 31.299999465942, rz = 90, model = 642 },
	{ x  = -2393.4948828125, y = -3244.990234375, z = 31.29, rz = 0, model = 642 },
	{ x  = -2375.859765625, y = -3227.3550878906, z = 31.279999465942, rz = 90, model = 642 },
	{ x  = -2393.4948828125, y = -3227.3550878906, z = 31.279999465942, rz = 90, model = 642 },

	-- переход 4 - 5
	{ x  = -2393.4948730469, y = -3267.4201660156, z = 36.55, rz = 270, ry = -15, model = 642 },

	-- 5 уровень
	{ x  = -2393.4948730469, y = -3289.021484375, z = 41.73, rz = 0, model = 642 },
	{ x  = -2393.4948730469, y = -3294.146484375, z = 41.73, rz = 0, model = 642 },
	{ x  = -2393.4948730469, y = -3299.271484375, z = 41.73, rz = 0, model = 642 },
}

local CONST_MAP_OBJECTS = {
	642, 643,
}

local CLIENT_VAR_current_level = 1

local CLIENT_VAR_map_objects = { }
local CLIENT_VAR_is_vehicle_in_water_timer = nil
local CLIENT_VAR_delay_vehicle_damage_timer = nil
local CLIENT_VAR_respawn_timer = nil
local CLIENT_VAR_up_level_timer = nil
local CLIENT_VAR_up_snow_timer = nil
local CLIENT_VAR_respawn_data_timer = nil
local CLIENT_VAR_delay_wasted_respawn_timer = nil
local CLIENT_VAR_delay_start_fire_timer = nil

local CLIENT_VAR_tick_minigun_reload = 0
local CLIENT_VAR_tick_rocket_reload = 0
local CLIENT_VAR_tick_rocket_fire_timeout = 0
local CLIENT_VAR_minigun_ammo = 0
local CLIENT_VAR_rocket_ammo = 0

local CLIENT_VAR_snow = nil
local CLIENT_VAR_snow_object = nil

local CLIENT_VAR_disabled_keys = { p = true, q = true, tab = true, m = true, v = true }

local function SERVER_onPlayerPreWasted_handler(  )
	cancelEvent( )
	PlayerEndEvent( source, "Вы погибли", true )
end

local function SERVER_VehicleMinigunFire_handler( self, state )
	if not client.vehicle then return end

	if state == "down" then
		local players = { }
		for p in pairs( self.players ) do
			if p ~= client then
				table.insert( players, p )
			end
		end

		triggerClientEvent( players, event_id .."_VehicleMinigunStartFire", resourceRoot, client.vehicle )
	else
		local players = { }
		for p in pairs( self.players ) do
			if p ~= client then
				table.insert( players, p )
			end
		end

		triggerClientEvent( players, event_id .."_VehicleMinigunStopFire", resourceRoot, client.vehicle )
	end
end

local function SERVER_UpdatePoint_handler( self, atacker )
	local client = atacker or client
	local points = client:getData( "points" )

	points = atacker and points + CONST_RESPAWN_POINTS or points - CONST_RESPAWN_POINTS
	client:setData( "points", points, false )

	SyncEventScoreboard( self, event_id .."_UpdatePoint_handler", points, client )
end

local function SERVER_RespawnVehicle_handler( self, current_level )
	if not client.vehicle then return end
	local spawn = CONST_SPAWN_POSITIONS[ current_level ][ math.random( 1, #CONST_SPAWN_POSITIONS ) ]
	client.vehicle:spawn( spawn.x + 2000, spawn.y + 2500, spawn.z, 0, 0, spawn.rz )
	client.vehicle:setEngineState( true )

	for player in pairs( self.players ) do
		triggerClientEvent( player, event_id .."_RespawnVehicle_handler", resourceRoot, client, self.vehicles, points )
	end
end

local function CLIENT_SetupVehicles( vehicles )
	for player, vehicle in pairs( vehicles ) do
		local weapon = Weapon( "minigun", vehicle.position )
		weapon.dimension = vehicle.dimension
		attachElements( weapon, vehicle, 0, 1.1, 0.55, 0, 30, 90 )

		weapon.ammo = 0
		weapon.clipAmmo = player == localPlayer and CONST_MINIGUN_AMMO or 9999999
		weapon:setProperty( "fire_rotation", 0, -30, 0 )
		weapon:setProperty( "damage", CONST_MINIGUN_DAMAGE )

		vehicle:setData( "vehicle_weapon", weapon, false )
		weapon:setData( "owner", player, false )

		local veh_blip = createBlipAttachedTo( vehicle, 0, 1, 0, 255, 0 )

		addEventHandler( "onClientElementDestroy", vehicle, function( )
			local weapon = source:getData( "vehicle_weapon" )
			if isElement( weapon ) then
				destroyElement( weapon )
			end

			if isElement( veh_blip ) then
				destroyElement( veh_blip )
			end
		end )

		if player == localPlayer then
			addEventHandler( "onClientWeaponFire", weapon, function( )
				if not localPlayer.vehicle then return end
				local weapon = localPlayer.vehicle:getData( "vehicle_weapon" )
				if not isElement( weapon ) then return end

				CLIENT_VAR_minigun_ammo = CLIENT_VAR_minigun_ammo - 1

				--if isElement( UIe.minigun_count ) then
					--UIe.minigun_count:ibData( "text", CLIENT_VAR_minigun_ammo )
				--end

				if CLIENT_VAR_minigun_ammo <= 0 then
					weapon.state = "reloading"
					weapon.state = "ready"

					CLIENT_VAR_tick_minigun_reload = getTickCount( ) + CONST_MINIGUN_TIME_TO_RELOAD * 1000

					TriggerCustomServerEvent( "VehicleMinigunFire", "up" )

					UpdateUIWeapon( CONST_MINIGUN_AMMO, _, CONST_MINIGUN_TIME_TO_RELOAD )
				else
					UpdateUIWeapon( CLIENT_VAR_minigun_ammo )
				end
			end )
		end
	end
end

local function CLIENT_StartPlayWeaponFire( vehicle, weapon )
	local sound = playSound3D( "sounds/minigun_shot.wav", vehicle.position )
	sound.dimension = localPlayer.dimension
	sound.volume = 0.2
	Timer( function( )
		if isElement( vehicle ) and weapon.state == "firing" then
			local sound = playSound3D( "sounds/minigun_shot.wav", vehicle.position )
			sound.dimension = localPlayer.dimension
			sound.volume = 0.2
		else
			killTimer( sourceTimer )
		end
	end, 100, 0 )
end

local function CLIENT_LocalPlayerVehicleMinigunFire( key, state )
	if not localPlayer.vehicle then return end
	if localPlayer:getData( "event_respawn_vehicle" ) then return end
	if localPlayer:getData( "delay_start_fire" ) then return end

	if key == "mouse1" then
		local weapon = localPlayer.vehicle:getData( "vehicle_weapon" )
		if not isElement( weapon ) then return end

		if state == "down" then
			if CLIENT_VAR_tick_minigun_reload > getTickCount( ) then return end

			if CLIENT_VAR_minigun_ammo <= 0 then
				CLIENT_VAR_minigun_ammo = CONST_MINIGUN_AMMO
				weapon.clipAmmo = CLIENT_VAR_minigun_ammo
			end

			weapon.state = "reloading"
			weapon.state = "firing"

			CLIENT_StartPlayWeaponFire( localPlayer.vehicle, weapon )

			TriggerCustomServerEvent( "VehicleMinigunFire", "down" )
		else
			weapon.state = "reloading"
			weapon.state = "ready"

			TriggerCustomServerEvent( "VehicleMinigunFire", "up" )
		end

	elseif key == "mouse2" then
		if state == "down" then
			if CLIENT_VAR_tick_rocket_fire_timeout > getTickCount( ) then return end
			if CLIENT_VAR_tick_rocket_reload > getTickCount( ) then return end

			if CLIENT_VAR_rocket_ammo <= 0 then
				CLIENT_VAR_rocket_ammo = CONST_ROCKET_AMMO
			end

			CLIENT_VAR_tick_rocket_fire_timeout = getTickCount( ) + CONST_ROCKET_TIME_TO_FIRE * 1000

			createProjectile( localPlayer.vehicle, 19 )
			CLIENT_VAR_rocket_ammo = CLIENT_VAR_rocket_ammo - 1

			if CLIENT_VAR_rocket_ammo <= 0 then
				CLIENT_VAR_tick_rocket_reload = getTickCount( ) + CONST_ROCKET_TIME_TO_RELOAD * 1000

				UpdateUIWeapon( _, CONST_ROCKET_AMMO, _, CONST_ROCKET_TIME_TO_RELOAD )
			else
				UpdateUIWeapon( _, CLIENT_VAR_rocket_ammo )
			end

			--if isElement( UIe.rocket_count ) then
				--UIe.rocket_count:ibData( "text", localPlayer:getData( "rocket_ammo" ) )
			--end
		end
	end
end

local function CLIENT_VehicleMinigunStartFire_handler( vehicle )
	local weapon = vehicle:getData( "vehicle_weapon" )
	if not isElement( weapon ) then return end

	weapon.state = "reloading"
	weapon.state = "firing"

	CLIENT_StartPlayWeaponFire( vehicle, weapon )
end

local function CLIENT_VehicleMinigunStopFire_handler( vehicle )
	local weapon = vehicle:getData( "vehicle_weapon" )
	if not isElement( weapon ) then return end

	weapon.state = "reloading"
	weapon.state = "ready"
end

local function CLIENT_ReplaceModel( )
	for k, model_id in pairs( CONST_MAP_OBJECTS ) do
		local col = engineLoadCOL( "models/".. model_id ..".col" )
		engineReplaceCOL( col, model_id )

		local txd = engineLoadTXD( "models/".. model_id ..".txd" )
		engineImportTXD( txd, model_id )

		local dff = engineLoadDFF( "models/".. model_id ..".dff" )
		engineReplaceModel( dff, model_id )

		engineSetModelLODDistance ( model_id, 1000 ) 
	end
end

local function CLIENT_CreateMapObjects( )	
	for i, object in pairs( CONST_MAP_OBJECT_POSITIONS ) do
		CLIENT_VAR_map_objects[ i ] = Object( object.model, object.x + 2000, object.y + 2500, object.z, 0, object.ry or 0, object.rz )
		CLIENT_VAR_map_objects[ i ]:setDimension( localPlayer.dimension )
		CLIENT_VAR_map_objects[ i ]:setInterior( localPlayer.interior )
		CLIENT_VAR_map_objects[ i ]:setFrozen( true )

		addEventHandler("onClientObjectDamage", CLIENT_VAR_map_objects[ i ], function( )
			cancelEvent()
		end )
	end
end

if localPlayer then
	CLIENT_ReplaceModel( )
end

local function CLIENT_UpdateHudLevel( )
	localPlayer:setData( "hud_timer_data", false, false )
	if CLIENT_VAR_current_level == CONST_LEVELS then return end

	localPlayer:setData( "hud_timer_data", {
			text = "До начала лавины: (" .. CLIENT_VAR_current_level .. "/" .. CONST_LEVELS .. ")",
			timestamp = getRealTimestamp( ) + CONST_TIME_TO_NEXT_LEVEL
	}, false )
end

local function CLIENT_UpdateLevel( )
	if not CLIENT_VAR_snow_object then
		CLIENT_VAR_snow_object = Water(
			CONST_WATER_POSITION[ 1 ] - CONST_WATER_WIDTH, CONST_WATER_POSITION[ 2 ] - CONST_WATER_HEIGHT, CONST_WATER_POSITION[ 3 ],--нижний левый
			CONST_WATER_POSITION[ 1 ] + CONST_WATER_WIDTH, CONST_WATER_POSITION[ 2 ] - CONST_WATER_HEIGHT, CONST_WATER_POSITION[ 3 ],--нижний правый
			CONST_WATER_POSITION[ 1 ] - CONST_WATER_WIDTH, CONST_WATER_POSITION[ 2 ] + CONST_WATER_HEIGHT, CONST_WATER_POSITION[ 3 ],--верхний левый
			CONST_WATER_POSITION[ 1 ] + CONST_WATER_WIDTH, CONST_WATER_POSITION[ 2 ] + CONST_WATER_HEIGHT, CONST_WATER_POSITION[ 3 ],--верхний правый
			false
		)

		CLIENT_VAR_snow_object.dimension = localPlayer.dimension
	end

	local step = ( CONST_HEIGHT_LEVELS[ CLIENT_VAR_current_level ] - CONST_HEIGHT_LEVELS[ CLIENT_VAR_current_level - 1 ] ) / 80
	local level = step

	CLIENT_VAR_up_snow_timer = Timer( function( )
		setWaterLevel( CLIENT_VAR_snow_object, CONST_HEIGHT_LEVELS[ CLIENT_VAR_current_level - 1 ] + level  )
		level = level + step
	end, 125, 80 )
end

local function CLIENT_SetupHud_handler( players )
	CLIENT_UpdateHudLevel( )

	CLIENT_VAR_up_level_timer = Timer( function( )
		if CLIENT_VAR_current_level == CONST_LEVELS then
			localPlayer:setData( "hud_timer_data", false, false )
			return
		end

		CLIENT_VAR_current_level = CLIENT_VAR_current_level + 1

		CLIENT_UpdateHudLevel( )
		CLIENT_UpdateLevel( )
	end, CONST_TIME_TO_NEXT_LEVEL * 1000, CONST_LEVELS + 1 )

	for _, player in ipairs( players ) do
		UpdateScoreboard( player, CONST_POINTS )
	end
end

local function CLIENT_ChangeCollisionVehicle( player_respawn, data, state )
	local player_respawn_vehicle = player_respawn.vehicle

	if player_respawn_vehicle then
		player_respawn_vehicle:setAlpha( state and 255 or 130 )
	end

	for player, vehicle in pairs( data ) do
		if player ~= player_respawn and isElement( player ) then
			setElementCollidableWith( player_respawn, player, state )
			if player_respawn_vehicle and isElement( vehicle ) then
				setElementCollidableWith( player_respawn_vehicle, vehicle, state )
			end
		end
	end
end

local function CLIENT_onUpdatePoint_handler( player_respawn, points, place )
	if not isElement( player_respawn ) then return end
	UpdateScoreboard( player_respawn, points, place )
end

local function CLIENT_onRespawnVehicle_handler( player_respawn, data )
	if not isElement( player_respawn ) then return end
	
	if player_respawn == localPlayer then
		setCameraTarget( localPlayer )
	end

	CLIENT_ChangeCollisionVehicle( player_respawn, data, false )

	setVehicleHandling( player_respawn.vehicle, "percentSubmerged", 45 )
	player_respawn.vehicle:setFrozen( false )
	
	Timer( function( player_respawn, data )
		if not isElement( player_respawn ) then return end
		CLIENT_ChangeCollisionVehicle( player_respawn, data, true )
	end, CONST_TIME_TO_CHANGE_COLLISION * 1000, 1, player_respawn, data )
end

local function CLIENT_RaceKeyHandler( key, state )
	if CLIENT_VAR_disabled_keys[ key ] then
		cancelEvent( )
	end
end

local function CLIENT_onClientVehicleInWatter( )
	if localPlayer:getData( "event_respawn_vehicle" ) then return end

	localPlayer:setData( "event_respawn_vehicle", true, false )
	toggleControl( "accelerate", false )
	toggleControl( "brake_reverse", false )
	CreateUIRespawnTimer( CONST_TIME_TO_RESPAWN )
	setCameraMatrix( unpack( CONST_RESPAWN_CAMERA_MAXTRIX[ CLIENT_VAR_current_level ] ) )

	TriggerCustomServerEvent( "ClientUpdatePoint" )

	CLIENT_VAR_respawn_timer = Timer( function( )
		toggleControl( "accelerate", true )
		toggleControl( "brake_reverse", true )
		DeleteUIRespawnTimer( )
		setCameraTarget( localPlayer )
		TriggerCustomServerEvent( "ClientRespawnVehicle", CLIENT_VAR_current_level )

		CLIENT_VAR_respawn_data_timer = Timer( function( )
			localPlayer:setData( "event_respawn_vehicle", false, false )
		end, 2 * 1000, 1 )
	end, CONST_TIME_TO_RESPAWN * 1000, 1 )

	local attacker = localPlayer:getData( "attacker" )
	if isElement( attacker ) then
		triggerServerEvent( "BP:NYE:onPlayerPushOffOtherCar", attacker, event_id )
		localPlayer:setData( "attacker", false, false )
		TriggerCustomServerEvent( "ClientUpdatePoint", attacker )
	end
	triggerServerEvent( "BP:NYE:onPlayerWasted", localPlayer, event_id )
end

local function CLIENT_onClientVehicleDamage_handler( attacker )
	if not source then return end
	if weapon_id then cancelEvent( ) end

	local damage = false

	if weapon_id == 51 then
		damage = CONST_ROCKET_DAMAGE * ( loss / 1100 )

	elseif weapon_id == 38 then
		damage = CONST_MINIGUN_DAMAGE
	end

	if damage then
		local health = math.max( 399, source.health - damage )
		CLIENT_VAR_vehicle_health = health
		source.health = health

		if attacker and attacker.vehicle then
			CreateUIDamage( source.position, attacker.vehicle.position, source.rotation.z )
		end
	end

	if attacker and attacker.type == "vehicle" then
		localPlayer:setData( "attacker", attacker.controller, false )

		if isTimer( CLIENT_VAR_attacker_damage_timer ) then
			killTimer( CLIENT_VAR_attacker_damage_timer )
		end

		CLIENT_VAR_attacker_damage_timer = Timer( function( )
			localPlayer:setData( "attacker", false, false )
		end, 5 * 1000, 1 )
	end

	if source.health <= 400 then
		if localPlayer:getData( "event_respawn_vehicle" ) then return end

		attacker = attacker or localPlayer:getData( "attacker" )
		localPlayer:setData( "attacker", false, false )

		triggerServerEvent( "BP:NYE:onPlayerWasted", localPlayer, event_id )

		local random_point = nil
		local random_table = { 1, 2, 3, 4, 5 }
	
		while not random_point do
			if #random_table == 0 then
				random_point = CONST_WASTED_POSITIONS[ 1 ]
				break
			end
	
			local random_index = math.random( 1, #random_table )
			local position = CONST_WASTED_POSITIONS[ random_table[ random_index ] ]
	
			if #getElementsWithinRange( position, 1, "vehicle" ) == 0 then
				random_point = position
				break
			end
	
			table.remove( random_table, random_index )
		end
		removeEventHandler( "onClientVehicleDamage", localPlayer.vehicle, CLIENT_onClientVehicleDamage_handler )

		fadeCamera( false, 1 )

		CLIENT_VAR_delay_wasted_respawn_timer = Timer( function( )
			localPlayer.vehicle:setPosition( random_point )
			localPlayer.vehicle:setFrozen( true )
			setVehicleHandling( localPlayer.vehicle, "percentSubmerged", 45 )
			CLIENT_onClientVehicleInWatter( )
			fadeCamera( true, 1 )
		end, 1000, 1 )

		CLIENT_VAR_delay_vehicle_damage_timer = Timer( function( )
			addEventHandler( "onClientVehicleDamage", localPlayer.vehicle, CLIENT_onClientVehicleDamage_handler, true, "high+10000" )
		end, 2 * 1000, 1 )

		if not isElement( attacker ) then return end

		local attacker_type = attacker.type
		
		if attacker_type == "object" then
			return
		elseif attacker_type == "vehicle" then
			attacker = attacker.controller
		elseif attacker_type == "weapon" then
			attacker = attacker:getData( "owner" )
		end

		if attacker == localPlayer then return end
		TriggerCustomServerEvent( "ClientUpdatePoint", attacker )
	end
end

function CLIENT_SetSnowState( state )
	if state then
		setWaterColor( 255, 255, 255, 255 )
		CLIENT_VAR_snow = dxCreateShader( "fx/lava.fx" )
		local textura = dxCreateTexture( "img/snow.png" )
		dxSetShaderValue( CLIENT_VAR_snow, "TEXTURE", textura )
		engineApplyShaderToWorldTexture( CLIENT_VAR_snow, "waterclear256" )
	else
		setWaterColor( 93, 170, 170, 240 )
		CLIENT_VAR_snow:destroy( )
		CLIENT_VAR_snow = nil
	end
end

REGISTERED_EVENTS[ event_id ] = {
	name = "Царь горы";
	group = "new_year";
	count_players = 5;
	scoreboard_text_point = "Количество очков";
	start_count_point = 1000;

	coins_reward = {
		[ 1 ] = 45;
		[ 2 ] = 37;
		[ 3 ] = 30;
		[ 4 ] = 22;
		[ 5 ] = 15;
	},

	Setup_S_handler = function( self )
		self.vehicles = {}

		local counter = 0
		local level = 1
		for player in pairs( self.players ) do
			counter = counter + 1
			local spawn = CONST_SPAWN_POSITIONS[ level ][ counter ]

			local vehicle = Vehicle.CreateTemporary( CONST_VEHICLE_MODEL, spawn.x + 2000, spawn.y + 2500, spawn.z, 0, 0, spawn.rz )
			vehicle.dimension = self.dimension
			self.vehicles[ player ] = vehicle

			setTimer( function( )
				player.vehicle = vehicle
				vehicle.frozen = true
			end, 100, 1 )

			addEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler )
		end

		AddCustomServerEventHandler( self, "ClientRespawnVehicle", SERVER_RespawnVehicle_handler )
		AddCustomServerEventHandler( self, "ClientUpdatePoint", SERVER_UpdatePoint_handler )
		AddCustomServerEventHandler( self, "VehicleMinigunFire", SERVER_VehicleMinigunFire_handler )
	end;

	Setup_S_delay_handler = function( self, players )
		triggerClientEvent( players, event_id .."_SetupHud", resourceRoot, players )
		triggerClientEvent( players, event_id .."_SetupVehicles", resourceRoot, self.vehicles )

		self.start_timer = Timer( function( )
			for player in pairs( self.players ) do
				if isElement( player.vehicle ) then
					player:setData( "points", CONST_POINTS, false )
					player.vehicle.frozen = false
				else
					PlayerEndEvent( player, "Ошибка инициализации" )
				end
			end
		end, CONST_TIME_TO_START_EVENT * 1000, 1 )

		self.end_timer = Timer( function( )
			for k = #self.players_point, 1, -1 do
				PlayerEndEvent( self.players_point[ k ][ 1 ], "Вы заняли ".. k .." место", _, k, true )
			end
		end, CONST_TIME_TO_EVENT_END * 1000, 1 )
	end;

	Cleanup_S_handler = function( self )
		RemoveCustomServerEventHandler( self, "ClientRespawnVehicle" )
		RemoveCustomServerEventHandler( self, "ClientUpdatePoint" )
		RemoveCustomServerEventHandler( self, "VehicleMinigunFire" )

		if isTimer( self.start_timer ) then
			killTimer( self.start_timer )
		end

		if isTimer( self.end_timer ) then
			killTimer( self.end_timer )
		end
	end;


	CleanupPlayer_S_handler = function( self, player )
		removeEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler  )

		if isElement( self.vehicles[ player ] ) then
			destroyElement( self.vehicles[ player ] )
		end
	end;

	Setup_C_handler = function( players, vehicles )
		if isElement( vehicles[ localPlayer ] ) then
			addEventHandler( "onClientVehicleDamage", vehicles[ localPlayer ], CLIENT_onClientVehicleDamage_handler, true, "high+10000" )
			setVehicleHandling( vehicles[ localPlayer ], "percentSubmerged", 45 )
			setCameraViewMode( 2 )
		end

		bindKey( "mouse1", "both", CLIENT_LocalPlayerVehicleMinigunFire )
		bindKey( "mouse2", "both", CLIENT_LocalPlayerVehicleMinigunFire )

		addEvent( event_id .."_SetupVehicles", true )
		addEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles )

		addEvent( event_id .."_VehicleMinigunStartFire", true )
		addEventHandler( event_id .."_VehicleMinigunStartFire", resourceRoot, CLIENT_VehicleMinigunStartFire_handler )

		addEvent( event_id .."_VehicleMinigunStopFire", true )
		addEventHandler( event_id .."_VehicleMinigunStopFire", resourceRoot, CLIENT_VehicleMinigunStopFire_handler )

		localPlayer:setData( "hud_timer_data", false, false )
		localPlayer:setData( "event_respawn_vehicle", false, false )
		
		removeEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )
		addEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )

		addEvent( event_id .."_SetupHud", true )
		addEventHandler( event_id .."_SetupHud", resourceRoot, CLIENT_SetupHud_handler )

		addEvent( event_id .."_RespawnVehicle_handler", true )
		addEventHandler( event_id .."_RespawnVehicle_handler", resourceRoot, CLIENT_onRespawnVehicle_handler )

		addEvent( event_id .."_UpdatePoint_handler", true )
		addEventHandler( event_id .."_UpdatePoint_handler", resourceRoot, CLIENT_onUpdatePoint_handler )
		
		toggleControl( "enter_exit", false )

		CLIENT_CreateMapObjects( )
		CLIENT_VAR_current_level = 1

		CLIENT_VAR_tick_minigun_reload = 0
		CLIENT_VAR_tick_rocket_reload = 0
		CLIENT_VAR_tick_rocket_fire_timeout = 0
		CLIENT_VAR_minigun_ammo = CONST_MINIGUN_AMMO
		CLIENT_VAR_rocket_ammo = CONST_ROCKET_AMMO
		CLIENT_VAR_vehicle_health = nil

		CreateUIStartTimer( CONST_TEXT_TO_START, CONST_TIME_IN_MS_TO_TEXT_START )
		CreateUITimeout( CONST_TIME_TO_EVENT_END )
		CLIENT_SetSnowState( true )
		CreateUIWeapon( CLIENT_VAR_minigun_ammo, CLIENT_VAR_rocket_ammo )

		CLIENT_VAR_is_vehicle_in_water_timer = Timer( function( )
			if localPlayer.vehicle and isElementInWater( localPlayer.vehicle ) then
				CLIENT_onClientVehicleInWatter( )
			end
		end, 1000, 0 )

		localPlayer:setData( "delay_start_fire", true, false )
		CLIENT_VAR_delay_start_fire_timer = Timer( function( )
			localPlayer:setData( "delay_start_fire", false, false )
		end, 5000, 1 )
	end;

	
	Cleanup_C_handler = function( )
		removeEventHandler( event_id .."_RespawnVehicle_handler", resourceRoot, CLIENT_onRespawnVehicle_handler )
		removeEventHandler( event_id .."_SetupHud", resourceRoot, CLIENT_SetupHud_handler )
		removeEventHandler( event_id .."_UpdatePoint_handler", resourceRoot, CLIENT_onUpdatePoint_handler )
		removeEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )
		removeEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles )
		removeEventHandler( event_id .."_VehicleMinigunStartFire", resourceRoot, CLIENT_VehicleMinigunStartFire_handler )
		removeEventHandler( event_id .."_VehicleMinigunStopFire", resourceRoot, CLIENT_VehicleMinigunStopFire_handler )

		unbindKey( "mouse1", "both", CLIENT_LocalPlayerVehicleMinigunFire )
		unbindKey( "mouse2", "both", CLIENT_LocalPlayerVehicleMinigunFire )

		toggleControl( "enter_exit", true )

		if isTimer( CLIENT_VAR_is_vehicle_in_water_timer ) then
			killTimer( CLIENT_VAR_is_vehicle_in_water_timer )
		end

		if isTimer( CLIENT_VAR_respawn_timer ) then
			killTimer( CLIENT_VAR_respawn_timer )
		end

		if isTimer( CLIENT_VAR_delay_vehicle_damage_timer ) then
			killTimer( CLIENT_VAR_delay_vehicle_damage_timer )
		end

		if isTimer( CLIENT_VAR_up_level_timer ) then
			killTimer( CLIENT_VAR_up_level_timer )
		end

		if isTimer( CLIENT_VAR_up_snow_timer ) then
			killTimer( CLIENT_VAR_up_snow_timer )
		end

		if isTimer( CLIENT_VAR_respawn_data_timer ) then
			killTimer( CLIENT_VAR_respawn_data_timer )
		end

		if isTimer( CLIENT_VAR_delay_wasted_respawn_timer ) then
			killTimer( CLIENT_VAR_delay_wasted_respawn_timer )
		end

		if isTimer( CLIENT_VAR_delay_start_fire_timer ) then
			killTimer( CLIENT_VAR_delay_start_fire_timer )
		end

		if isTimer( CLIENT_VAR_attacker_damage_timer ) then
			killTimer( CLIENT_VAR_attacker_damage_timer )
			localPlayer:setData( "attacker", false, false )
		end

		for _, object in pairs( CLIENT_VAR_map_objects ) do
			object:destroy( )
		end

		if CLIENT_VAR_snow_object then
			CLIENT_VAR_snow_object:destroy( )
			CLIENT_VAR_snow_object = nil
		end

		CLIENT_SetSnowState( )
		localPlayer:setData( "event_respawn_vehicle", false, false )
		localPlayer:setData( "hud_timer_data", false, false )
		localPlayer:setData( "delay_start_fire", false, false )
		toggleControl( "accelerate", true )
		toggleControl( "brake_reverse", true )
	end;
}

-- Тестирование
if not localPlayer and SERVER_NUMBER > 100 then
	addCommandHandler( "new_year_king_mountain", function( player, cmd, count )
		if not count then player:ShowError( "Введите количество игроков" ) return end
		count = tonumber( count )
		if count > 5 or count < 1 then player:ShowError( "Введите количество 1-5" ) return end
		player:ShowInfo( "Количество игроков " .. count )
        REGISTERED_EVENTS[ event_id ].count_players = count
	end )
	
	addCommandHandler( "new_year_king_mountain_min_time", function( player )
        player:ShowInfo( "Время игры сокращено до 30 секунд" )
		CONST_TIME_TO_EVENT_END = 30
	end )

	addCommandHandler( "new_year_king_mountain_min_time_reset", function( player )
		player:ShowInfo( "Сброшено время игры" )
		CONST_TIME_TO_EVENT_END = 5 * 60
	end )
end