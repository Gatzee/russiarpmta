local event_id = "new_year_gift_delivery"

local CONST_TEXT_TO_START = {
	"Забери подарок",
	"Маневрируй",
	"Доставь подарок",
}
local CONST_TIME_IN_MS_TO_TEXT_START = 1500

local CONST_TIME_TO_START_EVENT = 3
local CONST_TIME_TO_EVENT_END = 5 * 60
local CONST_TIME_TO_GIFT_RESPAWN = 20
local CONST_TIME_TO_PLAYER_RESPAWN = 10
local CONST_TIME_TO_PLAYER_GM = 2
local CONST_TIME_TO_ZONE_EXIT = 5

local CONST_GIFT_MODEL = 910
local CONST_VEHICLE_MODEL = 480

local CONST_VEHICLE_HEALTH = 500
local CONST_MINIGUN_DAMAGE = 3 / CONST_VEHICLE_HEALTH * ( 1000 - 400 )
local CONST_ROCKET_DAMAGE = 250 / CONST_VEHICLE_HEALTH * ( 1000 - 400 )

local CONST_MINIGUN_AMMO = 100
local CONST_MINIGUN_TIME_TO_RELOAD = 15
local CONST_MINIGUN_TIME_TO_FIRE = 0.05

local CONST_ROCKET_AMMO = 3
local CONST_ROCKET_TIME_TO_RELOAD = 60
local CONST_ROCKET_TIME_TO_FIRE = 1

local CONST_SPAWN_POSITIONS = {
	Vector3( 738.024, 541.497, 20.309 );
	Vector3( 738.024, 531.497, 20.309 );
	Vector3( 738.024, 521.497, 20.309 );
	Vector3( 738.024, 511.497, 20.309 );
	Vector3( 738.024, 501.497, 20.309 );
}

local CONST_GIFT_SPAWN_POSITION = Vector3( 709.359, 736.861, 20.700 )

local CONST_GIFT_DELIVERY_POSITIONS = {
	Vector3( 709.561, 340.080, 20.569 );
	Vector3( 641.174, 340.275, 20.536 );
	Vector3( 553.409, 340.143, 20.521 );
	Vector3( 490.701, 340.135, 20.543 );
	Vector3( 488.408, 261.699, 20.549 );
	Vector3( 577.498, 261.781, 20.469 );
	Vector3( 653.171, 260.976, 20.505 );
	Vector3( 742.025, 260.881, 20.451 );
	Vector3( 741.835, 173.925, 20.550 );
	Vector3( 652.467, 172.500, 20.479 );
	Vector3( 577.435, 173.490, 20.498 );
	Vector3( 488.650, 174.652, 20.489 );
}

local CONST_RESPAWN_CAMERA_MAXTRIX = { 801.47869873047, 783.93804931641, 138.73431396484, 745.71130371094, 718.85131835938, 87.220123291016 }
local CONST_RESPAWN_PLAYER_TMP_POSITION = Vector3( 732.859, 512.155, 6.158 )

local CONST_GAME_ZONE = {
	505.052, 845.404,
	503.015, 681.302,
	531.784, 496.343,
	532.704, 364.530,
	460.195, 364.323,
	461.435, 146.928,
	771.197, 147.541,
	814.857, 223.956,
	814.708, 357.250,
	779.240, 407.250,
	781.047, 711.931,
	735.278, 712.167,
	735.443, 767.709,
	691.432, 803.331,
	630.713, 844.035,
	505.052, 845.404,
}


local CLIENT_VAR_wait_respawn_timer = false
local CLIENT_VAR_respawn_gm_tick = 0
local CLIENT_VAR_loaded_gift_box = nil
local CLIENT_VAR_delivery_point = nil
local CLIENT_VAR_gift_box_owner = nil
local CLIENT_VAR_gift_box_object = nil
local CLIENT_VAR_gift_box_blip = nil
local CLIENT_VAR_tick_minigun_reload = 0
local CLIENT_VAR_tick_rocket_reload = 0
local CLIENT_VAR_tick_rocket_fire_timeout = 0
local CLIENT_VAR_minigun_ammo = 0
local CLIENT_VAR_rocket_ammo = 0
local CLIENT_VAR_exit_zone_texture = nil
local CLIENT_VAR_exit_zone_colshape = nil
local CLIENT_VAR_shader = nil
local CLIENT_VAR_game_zone_exit_timer = false
local CLIENT_VAR_rotate_vehicle_tick = 0


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

local function SERVER_ClientPickupGiftBox_handler( self )
	if not client then return end
	if isElement( self.gift_box_owner ) then return end

	self.gift_box_owner = client

	for player in pairs( self.players ) do
		triggerClientEvent( player, event_id .."_PlayerPickupGiftBox", resourceRoot, client )
	end
end

local function SERVER_CreateGiftBox_impl( self, player, pos_x, pos_y, pos_z )
	if self.gift_box_owner ~= player then return end

	self.gift_box_owner = false

	for player_in_event in pairs( self.players ) do
		triggerClientEvent( player_in_event, event_id .."_CreateGiftBox", resourceRoot, pos_x, pos_y, pos_z )
	end
end

local function SERVER_ClientDeadAndNeedCreateGiftBox_handler( self, pos_x, pos_y, pos_z )
	if not client then return end

	SERVER_CreateGiftBox_impl( self, client, pos_x, pos_y, pos_z )
end

local function SERVER_ClientDeliveryGiftBox_handler( self )
	if not client then return end
	if self.gift_box_owner ~= client then return end

	self.gift_box_owner = false

	local gift_box_count = ( client:getData( "gift_box_count" ) or 0 ) + 1
	client:SetPrivateData( "gift_box_count", gift_box_count )

	local i = math.random( 1, #CONST_GIFT_DELIVERY_POSITIONS )
	for player in pairs( self.players ) do
		triggerClientEvent( player, event_id .."_PlayerDeliveryGiftBox", resourceRoot, client, i, gift_box_count )
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

		addEventHandler( "onClientElementDestroy", vehicle, function( )
			local weapon = source:getData( "vehicle_weapon" )
			if isElement( weapon ) then
				destroyElement( weapon )
			end

			if CLIENT_VAR_gift_box_owner == player then
				CLIENT_VAR_gift_box_owner = false
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
	if CLIENT_VAR_wait_respawn_timer then return end

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

local function CLIENT_StartRespawnPlayer(  )
	if CLIENT_VAR_wait_respawn_timer then return end

	TriggerCustomServerEvent( "VehicleMinigunFire", "up" )

	if CLIENT_VAR_gift_box_owner == localPlayer then
		TriggerCustomServerEvent( "ClientDeadAndNeedCreateGiftBox", localPlayer.vehicle.position.x, localPlayer.vehicle.position.y, localPlayer.vehicle.position.z + 1 )
		CLIENT_VAR_gift_box_owner = false
	end

	localPlayer.vehicle.position = CONST_RESPAWN_PLAYER_TMP_POSITION
	localPlayer.vehicle.frozen = true

	DeleteUIWeapon( )

	CLIENT_VAR_wait_respawn_timer = Timer( function( )
		localPlayer.vehicle.position = CONST_SPAWN_POSITIONS[ math.random( 1, #CONST_SPAWN_POSITIONS ) ]
		localPlayer.vehicle.rotation = Vector3( 0, 0, math.random( 0, 360 ) )
		localPlayer.vehicle.health = 1000
		localPlayer.vehicle.frozen = false

		setCameraTarget( localPlayer )

		CLIENT_VAR_tick_minigun_reload = 0
		CLIENT_VAR_tick_rocket_reload = 0
		CLIENT_VAR_tick_rocket_fire_timeout = 0
		CLIENT_VAR_minigun_ammo = CONST_MINIGUN_AMMO
		CLIENT_VAR_rocket_ammo = CONST_ROCKET_AMMO

		CreateUIWeapon( CLIENT_VAR_minigun_ammo, CLIENT_VAR_rocket_ammo )

		local weapon = localPlayer.vehicle:getData( "vehicle_weapon" )
		if isElement( weapon ) then
			weapon.clipAmmo = CLIENT_VAR_minigun_ammo
		end

		CLIENT_VAR_wait_respawn_timer = false
		CLIENT_VAR_respawn_gm_tick = getTickCount( ) + CONST_TIME_TO_PLAYER_GM * 1000

		RemoveEffects( localPlayer.vehicle, CONST_TIME_TO_PLAYER_GM * 1000 )
		triggerEvent( "RC:ApplyEffect", localPlayer, 2, localPlayer.vehicle )

		DeleteUIRespawnTimer( )
	end, CONST_TIME_TO_PLAYER_RESPAWN * 1000, 1 )

	CreateUIRespawnTimer( CONST_TIME_TO_PLAYER_RESPAWN )

	setCameraMatrix( unpack( CONST_RESPAWN_CAMERA_MAXTRIX ) )
end

local function CLIENT_onClientVehicleDamage_handler( attacker, weapon_id, loss )
	if not source then return end
	cancelEvent( )

	if CLIENT_VAR_respawn_gm_tick > getTickCount( ) then return end

	local damage = false

	if weapon_id == 51 then
		damage = CONST_ROCKET_DAMAGE * ( loss / 1100 )

	elseif weapon_id == 38 then
		damage = CONST_MINIGUN_DAMAGE
	end

	if damage then
		source.health = math.max( 399, source.health - damage )

		if attacker then
			if attacker.vehicle then
				CreateUIDamage( source.position, attacker.vehicle.position, source.rotation.z )
			else
				CreateUIDamage( source.position, attacker.position, source.rotation.z )
			end
		end
	end

	if source.health <= 400 then
		Timer( CLIENT_StartRespawnPlayer, 50, 1 )
	end
end

local function CLIENT_CreateGiftBox_impl( pos_x, pos_y, pos_z )
	if CLIENT_VAR_loaded_gift_box then
		CLIENT_VAR_loaded_gift_box:destroy( )
	end

	local gift_box = TeleportPoint( {
		x = pos_x, y = pos_y, z = pos_z;
		radius = 6;
		dimension = localPlayer.dimension;
		keypress = false;
		accepted_elements = { player = true, vehicle = true };
	} )

	gift_box.marker:setColor( 255, 0, 0, 10 )
	setMarkerType( gift_box.marker, "checkpoint" )
	gift_box.slowdown_coefficient = nil

	gift_box.elements = {}
	gift_box.elements.pickup = Pickup( pos_x, pos_y, pos_z, 3, CONST_GIFT_MODEL )
	gift_box.elements.pickup.dimension = gift_box.dimension

	gift_box.elements.blip = createBlipAttachedTo( gift_box.marker, 0, 2 )

	gift_box.PreJoin = function( gift_box )
		return true
	end

	gift_box.PostJoin = function( gift_box, player )
		if CLIENT_VAR_wait_respawn_timer then return end
		if CLIENT_VAR_game_zone_exit_timer then return end

		CLIENT_VAR_loaded_gift_box = nil

		TriggerCustomServerEvent( "ClientPickupGiftBox" )
		gift_box:destroy( )
	end

	CLIENT_VAR_loaded_gift_box = gift_box

	if isElement( CLIENT_VAR_gift_box_object ) then
		destroyElement( CLIENT_VAR_gift_box_object )
		destroyElement( CLIENT_VAR_gift_box_blip )
	end
end

local function CLIENT_CreateGiftBox_handler( pos_x, pos_y, pos_z )
	if pos_x then
		CLIENT_CreateGiftBox_impl( pos_x, pos_y, pos_z )
		CLIENT_VAR_gift_box_owner = false
	else
		CLIENT_CreateGiftBox_impl( CONST_GIFT_SPAWN_POSITION.x, CONST_GIFT_SPAWN_POSITION.y, CONST_GIFT_SPAWN_POSITION.z )
		CLIENT_VAR_gift_box_owner = nil
	end
end

local function CLIENT_SetupDeliveryPoint_handler( i )
	CLIENT_VAR_delivery_point_index = i
	CLIENT_CreateGiftBox_handler( )
end

local function CLIENT_CreateDeliveryPoint( )
	if CLIENT_VAR_delivery_point then
		CLIENT_VAR_delivery_point:destroy( )
	end

	local pos = CONST_GIFT_DELIVERY_POSITIONS[ CLIENT_VAR_delivery_point_index ]
	local pos_x, pos_y, pos_z = pos.x, pos.y, pos.z

	local delivery_point = TeleportPoint( {
		x = pos_x, y = pos_y, z = pos_z;
		radius = 6;
		gps = true;
		dimension = localPlayer.dimension;
		keypress = false;
		accepted_elements = { player = true, vehicle = true };
	} )

	delivery_point.marker:setColor( 0, 255, 0, 10 )
	setMarkerType( delivery_point.marker, "checkpoint" )
	setMarkerIcon ( delivery_point.marker, "finish" )
	delivery_point.slowdown_coefficient = nil

	delivery_point.elements = {}
	delivery_point.elements.blip = createBlipAttachedTo( delivery_point.marker, 0, 2, 0, 255, 0 )

	delivery_point.PreJoin = function( delivery_point )
		return true
	end

	delivery_point.PostJoin = function( delivery_point, player )
		if CLIENT_VAR_wait_respawn_timer then return end
		if CLIENT_VAR_game_zone_exit_timer then return end
		if CLIENT_VAR_gift_box_owner ~= localPlayer then return end

		CLIENT_VAR_delivery_point = nil

		TriggerCustomServerEvent( "ClientDeliveryGiftBox" )
		delivery_point:destroy( )

		CLIENT_CreateGiftBox_handler( )
	end

	CLIENT_VAR_delivery_point = delivery_point
end

local function CLIENT_PlayerPickupGiftBox_handler( player )
	if not isElement( CLIENT_VAR_gift_box_object ) then
		CLIENT_VAR_gift_box_object = createObject( CONST_GIFT_MODEL, 0, 0, 0 )
		CLIENT_VAR_gift_box_object.scale = 0.5
		CLIENT_VAR_gift_box_object.dimension = localPlayer.dimension
		CLIENT_VAR_gift_box_object.collisions = false

		CLIENT_VAR_gift_box_blip = createBlipAttachedTo( CLIENT_VAR_gift_box_object, 0, 2 )
	end

	if CLIENT_VAR_gift_box_owner == nil then
		CLIENT_CreateDeliveryPoint( )
	end

	attachElements( CLIENT_VAR_gift_box_object, player.vehicle, 0, -1.4, 0.78, 5, 0, 0 )
	CLIENT_VAR_gift_box_owner = player

	if player ~= localPlayer then
		if CLIENT_VAR_loaded_gift_box then
			CLIENT_VAR_loaded_gift_box:destroy( )
			CLIENT_VAR_loaded_gift_box = nil
		end

		return
	end

	localPlayer:ShowInfo( "Доставь подарок" )

	playSound( "sounds/ammo_box_pickup.wav" ).volume = 0.2
end

local function CLIENT_PlayerDeliveryGiftBox_handler( player, i, gift_box_count )
	CLIENT_VAR_delivery_point_index = i

	CLIENT_CreateGiftBox_handler( )

	UpdateScoreboard( player, gift_box_count )

	localPlayer:ShowInfo( "Забери подарок" )

	if player ~= localPlayer then
		player:setData( "gift_box_count", gift_box_count, false )

		if CLIENT_VAR_delivery_point then
			CLIENT_VAR_delivery_point:destroy( )
			CLIENT_VAR_delivery_point = nil
		end

		return
	end
end

local function CLIENT_render_handler( )
	for i = 1, #CONST_GAME_ZONE, 2 do
        local x, y = CONST_GAME_ZONE[ i ], CONST_GAME_ZONE[ i + 1 ]

        local i_next = ( i + 2 ) >= #CONST_GAME_ZONE and 1 or ( i + 2 )
        local x_next, y_next = CONST_GAME_ZONE[ i_next ], CONST_GAME_ZONE[ i_next + 1 ]

        local _, _, z = getElementPosition( localPlayer )
        z = z - 10

        dxDrawMaterialLine3D( x, y, z, x_next, y_next, z, CLIENT_VAR_exit_zone_texture, 75, tocolor( 255, 128, 128, math.floor( 0.7 * 128 ) ), x_next + 1, y_next + 1, z )
	end

	if localPlayer.vehicle then
		local rx, _, rz = getElementRotation( localPlayer.vehicle )
		if rx >= 120 and rx <= 220 then
			CLIENT_VAR_rotate_vehicle_tick = CLIENT_VAR_rotate_vehicle_tick + 1
		else
			CLIENT_VAR_rotate_vehicle_tick = 0
		end

		if CLIENT_VAR_rotate_vehicle_tick >= 50 then
			localPlayer.vehicle.position = localPlayer.vehicle.position + Vector3( 0, 0, 0.2 )
			localPlayer.vehicle.rotation = Vector3( 0, 0, rz )
		end

		local r, g, b = calculateRGB( )
		dxSetShaderValue( CLIENT_VAR_shader, "rgba", r, g, b, 0.25 )
	end
end

local function CLIENT_PlayerExitFromGameZone( element, dim )
	if not dim then return end

	if element == localPlayer then
		if isTimer( CLIENT_VAR_game_zone_exit_timer ) then
			killTimer( CLIENT_VAR_game_zone_exit_timer )
		end

		if CLIENT_VAR_gift_box_owner == localPlayer then
			TriggerCustomServerEvent( "ClientDeadAndNeedCreateGiftBox", CONST_GIFT_SPAWN_POSITION.x, CONST_GIFT_SPAWN_POSITION.y, CONST_GIFT_SPAWN_POSITION.z )
			CLIENT_VAR_gift_box_owner = false
		end

		CLIENT_VAR_game_zone_exit_timer = Timer( function( )
			localPlayer.health = 0
			CLIENT_VAR_game_zone_exit_timer = false
		end, CONST_TIME_TO_ZONE_EXIT * 1000, 1 )

		CreateUIZoneExit( CONST_TIME_TO_ZONE_EXIT )
	end
end

local function CLIENT_PlayerEnterToGameZone( element, dim )
	if not dim then return end

	if element == localPlayer then
		if isTimer( CLIENT_VAR_game_zone_exit_timer ) then
			killTimer( CLIENT_VAR_game_zone_exit_timer )
			CLIENT_VAR_game_zone_exit_timer = false
		end

		DeleteUIZoneExit( )
	end
end

REGISTERED_EVENTS[ event_id ] = {
	name = "Доставка подарков";
	group = "new_year";
	count_players = 2;
	scoreboard_text_point = "Количество подарков";
	
	coins_reward = {
		[ 1 ] = 80;
		[ 2 ] = 66;
		[ 3 ] = 53;
		[ 4 ] = 40;
		[ 5 ] = 27;
	},

	Setup_S_handler = function( self )
		self.vehicles = {}

		local counter = 0
		local players = { }
		for player in pairs( self.players ) do
			counter = counter + 1

			local vehicle = Vehicle.CreateTemporary( CONST_VEHICLE_MODEL, CONST_SPAWN_POSITIONS[ counter ].x, CONST_SPAWN_POSITIONS[ counter ].y, CONST_SPAWN_POSITIONS[ counter ].z, 0, 0, math.random( 0, 360 ) )
			vehicle.dimension = self.dimension
			vehicle:setColor( 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0 )
			player.vehicle = vehicle
			vehicle.frozen = true

			self.vehicles[ player ] = vehicle

			player:SetPrivateData( "gift_box_count", 0 )
			player:SetPrivateData( "gift_box_last_pickup", 0 )

			addEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler )

			table.insert( players, player )
		end

		AddCustomServerEventHandler( self, "VehicleMinigunFire", SERVER_VehicleMinigunFire_handler )
		AddCustomServerEventHandler( self, "ClientPickupGiftBox", SERVER_ClientPickupGiftBox_handler )
		AddCustomServerEventHandler( self, "ClientDeliveryGiftBox", SERVER_ClientDeliveryGiftBox_handler )
		AddCustomServerEventHandler( self, "ClientDeadAndNeedCreateGiftBox", SERVER_ClientDeadAndNeedCreateGiftBox_handler )

		self.gift_box_owner = nil
	end;

	Setup_S_delay_handler = function( self, players )
		triggerClientEvent( players, event_id .."_SetupVehicles", resourceRoot, self.vehicles )

		self.start_timer = Timer( function( )
			for player in pairs( self.players ) do
				player.vehicle.frozen = false
			end
		end, CONST_TIME_TO_START_EVENT * 1000, 1 )

		self.end_timer = Timer( function( )
			local sorted_players = { }
			for player in pairs( self.players ) do
				table.insert( sorted_players, {
					player = player,
					count = player:getData( "gift_box_count" ) or 0,
					last_pickup = player:getData( "gift_box_last_pickup" ) or 0,
				} )
			end

			table.sort( sorted_players, function( a, b )
				if a.count == b.count then
					return a.last_pickup < b.last_pickup
				else
					return a.count < b.count
				end
			end )

			for _, data in pairs( sorted_players ) do
				PlayerEndEvent( data.player )
			end
		end, CONST_TIME_TO_EVENT_END * 1000, 1 )

		triggerClientEvent( players, event_id .."_SetupDeliveryPoint", resourceRoot, math.random( 1, #CONST_GIFT_DELIVERY_POSITIONS ) )
	end;

	Cleanup_S_handler = function( self )
		RemoveCustomServerEventHandler( self, "VehicleMinigunFire" )
		RemoveCustomServerEventHandler( self, "ClientPickupGiftBox" )
		RemoveCustomServerEventHandler( self, "ClientDeliveryGiftBox" )
		RemoveCustomServerEventHandler( self, "ClientDeadAndNeedCreateGiftBox" )

		if isTimer( self.start_timer ) then
			killTimer( self.start_timer )
		end

		if isTimer( self.end_timer ) then
			killTimer( self.end_timer )
		end
	end;

	CleanupPlayer_S_handler = function( self, player )
		removeEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler )

		if isElement( self.vehicles[ player ] ) then
			destroyElement( self.vehicles[ player ] )
		end

		SERVER_CreateGiftBox_impl( self, player, CONST_GIFT_SPAWN_POSITION.x, CONST_GIFT_SPAWN_POSITION.y, CONST_GIFT_SPAWN_POSITION.z )
	end;

	Setup_C_handler = function( players )
		addEventHandler( "onClientVehicleDamage", localPlayer.vehicle, CLIENT_onClientVehicleDamage_handler, true, "high+10000" )

		bindKey( "mouse1", "both", CLIENT_LocalPlayerVehicleMinigunFire )
		bindKey( "mouse2", "both", CLIENT_LocalPlayerVehicleMinigunFire )

		toggleControl( "enter_exit", false )

		addEvent( event_id .."_SetupVehicles", true )
		addEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles )

		addEvent( event_id .."_VehicleMinigunStartFire", true )
		addEventHandler( event_id .."_VehicleMinigunStartFire", resourceRoot, CLIENT_VehicleMinigunStartFire_handler )
		addEvent( event_id .."_VehicleMinigunStopFire", true )
		addEventHandler( event_id .."_VehicleMinigunStopFire", resourceRoot, CLIENT_VehicleMinigunStopFire_handler )

		addEvent( event_id .."_CreateGiftBox", true )
		addEventHandler( event_id .."_CreateGiftBox", resourceRoot, CLIENT_CreateGiftBox_handler )

		addEvent( event_id .."_SetupDeliveryPoint", true )
		addEventHandler( event_id .."_SetupDeliveryPoint", resourceRoot, CLIENT_SetupDeliveryPoint_handler )

		addEvent( event_id .."_PlayerPickupGiftBox", true )
		addEventHandler( event_id .."_PlayerPickupGiftBox", resourceRoot, CLIENT_PlayerPickupGiftBox_handler )

		addEvent( event_id .."_PlayerDeliveryGiftBox", true )
		addEventHandler( event_id .."_PlayerDeliveryGiftBox", resourceRoot, CLIENT_PlayerDeliveryGiftBox_handler )

		CLIENT_VAR_exit_zone_texture = dxCreateRenderTarget( 1, 1 )
		dxSetRenderTarget( CLIENT_VAR_exit_zone_texture, true )
		dxDrawRectangle( 0, 0, 1, 1, 0xffffffff )
		dxSetRenderTarget( )
		addEventHandler( "onClientRender", root, CLIENT_render_handler )

		CLIENT_VAR_exit_zone_colshape = ColShape.Polygon( unpack( CONST_GAME_ZONE ) )
		CLIENT_VAR_exit_zone_colshape.dimension = localPlayer.dimension
		addEventHandler( "onClientColShapeLeave", CLIENT_VAR_exit_zone_colshape, CLIENT_PlayerExitFromGameZone )
		addEventHandler( "onClientColShapeHit", CLIENT_VAR_exit_zone_colshape, CLIENT_PlayerEnterToGameZone )

		CLIENT_VAR_shader = dxCreateShader( "fx/tint.fx" )
		engineApplyShaderToWorldTexture( CLIENT_VAR_shader, "gift_white" )

		CLIENT_VAR_wait_respawn_timer = false
		CLIENT_VAR_game_zone_exit_timer = false
		CLIENT_VAR_respawn_gm_tick = 0
		CLIENT_VAR_loaded_gift_box = nil
		CLIENT_VAR_delivery_point = nil
		CLIENT_VAR_gift_box_owner = nil
		CLIENT_VAR_gift_box_object = nil
		CLIENT_VAR_gift_box_blip = nil
		CLIENT_VAR_tick_minigun_reload = 0
		CLIENT_VAR_tick_rocket_reload = 0
		CLIENT_VAR_tick_rocket_fire_timeout = 0
		CLIENT_VAR_minigun_ammo = CONST_MINIGUN_AMMO
		CLIENT_VAR_rocket_ammo = CONST_ROCKET_AMMO

		for player in pairs( players ) do
			player:setData( "gift_box_count", 0, false )
		end

		CreateUIStartTimer( CONST_TEXT_TO_START, CONST_TIME_IN_MS_TO_TEXT_START )
		CreateUITimeout( CONST_TIME_TO_EVENT_END )
		CreateUIWeapon( CLIENT_VAR_minigun_ammo, CLIENT_VAR_rocket_ammo )
	end;

	Cleanup_C_handler = function( )
		unbindKey( "mouse1", "both", CLIENT_LocalPlayerVehicleMinigunFire )
		unbindKey( "mouse2", "both", CLIENT_LocalPlayerVehicleMinigunFire )

		toggleControl( "enter_exit", true )

		removeEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles )

		removeEventHandler( event_id .."_VehicleMinigunStartFire", resourceRoot, CLIENT_VehicleMinigunStartFire_handler )
		removeEventHandler( event_id .."_VehicleMinigunStopFire", resourceRoot, CLIENT_VehicleMinigunStopFire_handler )

		removeEventHandler( event_id .."_CreateGiftBox", resourceRoot, CLIENT_CreateGiftBox_handler )
		removeEventHandler( event_id .."_SetupDeliveryPoint", resourceRoot, CLIENT_SetupDeliveryPoint_handler )
		removeEventHandler( event_id .."_PlayerPickupGiftBox", resourceRoot, CLIENT_PlayerPickupGiftBox_handler )
		removeEventHandler( event_id .."_PlayerDeliveryGiftBox", resourceRoot, CLIENT_PlayerDeliveryGiftBox_handler )

		removeEventHandler( "onClientRender", root, CLIENT_render_handler )
		if isElement( CLIENT_VAR_exit_zone_texture ) then
			destroyElement( CLIENT_VAR_exit_zone_texture )
		end

		if isElement( CLIENT_VAR_exit_zone_colshape ) then
			destroyElement( CLIENT_VAR_exit_zone_colshape )
		end

		if isElement( CLIENT_VAR_gift_box_object ) then
			destroyElement( CLIENT_VAR_gift_box_object )
			destroyElement( CLIENT_VAR_gift_box_blip )
		end

		if isElement( CLIENT_VAR_shader ) then
			destroyElement( CLIENT_VAR_shader )
		end

		if isTimer( CLIENT_VAR_wait_respawn_timer ) then
			killTimer( CLIENT_VAR_wait_respawn_timer )
		end

		if isTimer( CLIENT_VAR_game_zone_exit_timer ) then
			killTimer( CLIENT_VAR_game_zone_exit_timer )
		end

		if CLIENT_VAR_delivery_point then
			CLIENT_VAR_delivery_point:destroy( )
		end

		if CLIENT_VAR_loaded_gift_box then
			CLIENT_VAR_loaded_gift_box:destroy( )
		end
	end;
}