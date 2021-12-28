local event_id = "new_year_gift_collection"

local CONST_TEXT_TO_START = {
	"Собирай подарки",
	"Уничтожай врагов",
	"Забирай их подарки",
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

local CONST_ROCKET_AMMO = 2
local CONST_ROCKET_TIME_TO_RELOAD = 60
local CONST_ROCKET_TIME_TO_FIRE = 1

local CONST_SPAWN_POSITIONS = {
	Vector3( 596.052, 832.797, 28.246);
	Vector3( 539.409, 913.103, 20.819);
	Vector3( 596.068, 997.962, 21.185);
	Vector3( 771.398, 974.437, 20.961);
	Vector3( 948.684, 891.488, 36.575);
	Vector3( 792.843, 871.076, 25.753);
}

local CONST_GIFT_SPAWN_POSITIONS = {
	Vector3( 647.732, 882.622, 21.964);
	Vector3( 743.718, 909.101, 36.458);
	Vector3( 867.827, 949.154, 21.914);
}

local CONST_RESPAWN_CAMERA_MAXTRIX = { 599.85882568359, 834.2609863281, 114.06836700439, 679.29840087891, 879.181640625, 73.184623718262 }
local CONST_RESPAWN_PLAYER_TMP_POSITION = Vector3( 742.991, 919.177, 9.609 )

local CONST_GAME_ZONE = {
	970, 790,
	970, 1026,
	470, 1026,
	470, 790,
	970, 790,
}


local CLIENT_VAR_wait_respawn_timer = false
local CLIENT_VAR_respawn_gm_tick = 0
local CLIENT_VAR_loaded_gift_boxes = { }
local CLIENT_VAR_tick_minigun_reload = 0
local CLIENT_VAR_tick_rocket_reload = 0
local CLIENT_VAR_tick_rocket_fire_timeout = 0
local CLIENT_VAR_minigun_ammo = 0
local CLIENT_VAR_rocket_ammo = 0
local CLIENT_VAR_exit_zone_texture = nil
local CLIENT_VAR_exit_zone_texture = nil
local CLIENT_VAR_game_zone_exit_timer = false
local CLIENT_VAR_rotate_vehicle_tick = 0
local CLIENT_VAR_vehicle_health = nil

local CLIENT_VAR_disabled_keys = { p = true, q = true, tab = true, m = true, y = true, u = true }

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

local function SERVER_ClientPickupGiftBox_handler( self, i )
	if not client then return end
	if not self.gift_box[ i ] then return end

	local count = self.gift_box[ i ]
	self.gift_box[ i ] = nil

	if i <= #CONST_GIFT_SPAWN_POSITIONS then
		self.gift_box_respawn_timer[ i ] = Timer( function( )
			self.gift_box[ i ] = 1
			local pos_x, pos_y, pos_z = CONST_GIFT_SPAWN_POSITIONS[ i ].x, CONST_GIFT_SPAWN_POSITIONS[ i ].y, CONST_GIFT_SPAWN_POSITIONS[ i ].z

			for player in pairs( self.players ) do
				triggerClientEvent( player, event_id .."_CreateGiftBox", resourceRoot, i, pos_x, pos_y, pos_z, 1 )
			end
		end, CONST_TIME_TO_GIFT_RESPAWN * 1000, 1 )
	end

	local gift_box_count = ( client:getData( "gift_box_count" ) or 0 ) + count
	client:SetPrivateData( "gift_box_count", gift_box_count )
	client:SetPrivateData( "gift_box_last_pickup", getTickCount( ) )

	SyncEventScoreboard( self, event_id .. "_UpdatePoint_handler", gift_box_count, client )

	for player in pairs( self.players ) do
		triggerClientEvent( player, event_id .."_PlayerPickupGiftBox", resourceRoot, client, i, count, gift_box_count )
	end

	triggerEvent( "BP:NYE:onPlayerPickupGiftBox", client )
end

local function SERVER_ClientDeadAndNeedCreateGiftBox_handler( self, pos_x, pos_y, pos_z )
	if not client then return end

	local gift_box_count = client:getData( "gift_box_count" ) or 0
	if gift_box_count > 0 then
		client:SetPrivateData( "gift_box_count", 0 )
		SyncEventScoreboard( self, event_id .. "_UpdatePoint_handler", 0, client )

		local i = math.max( 4, #self.gift_box + 1 )
		self.gift_box[ i ] = gift_box_count

		for player in pairs( self.players ) do
			triggerClientEvent( player, event_id .."_PlayerDeadAndNeedCreateGiftBox", resourceRoot, client, i, pos_x, pos_y, pos_z, gift_box_count )
		end
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
		weapon:setData( "owner", player, false )

		vehicle:setData( "vehicle_weapon", weapon, false )

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

local function CLIENT_StartRespawnPlayer( killer )
	if CLIENT_VAR_wait_respawn_timer then return end

	triggerServerEvent( "BP:NYE:onPlayerWasted", localPlayer, event_id )
	if isElement( killer ) then
		if killer.type == "vehicle" then
			killer = killer.controller
		end
		if killer and killer.type == "player" then
			triggerServerEvent( "BP:NYE:onPlayerKill", killer )
		end
	end

	TriggerCustomServerEvent( "VehicleMinigunFire", "up" )

	if not isTimer( CLIENT_VAR_game_zone_exit_timer ) then
		local gift_box_count = localPlayer:getData( "gift_box_count" ) or 0
		if gift_box_count > 0 then
			TriggerCustomServerEvent( "ClientDeadAndNeedCreateGiftBox", localPlayer.vehicle.position.x, localPlayer.vehicle.position.y, localPlayer.vehicle.position.z + 1 )
		end
	end

	localPlayer.vehicle.position = CONST_RESPAWN_PLAYER_TMP_POSITION
	localPlayer.vehicle.frozen = true

	DeleteUIWeapon( )

	CLIENT_VAR_wait_respawn_timer = Timer( function( )
		local random_point = nil
		local random_table = { 1, 2, 3, 4, 5, 6 }

		while not random_point do
			if #random_table == 0 then
				random_point = CONST_SPAWN_POSITIONS[ 1 ]
				break
			end

			local random_index = math.random( 1, #random_table )
			local position = CONST_SPAWN_POSITIONS[ random_table[ random_index ] ]

			if #getElementsWithinRange( position, 2, "vehicle" ) == 0 then
				random_point = position
				break
			end

			table.remove( random_table, random_index )
		end

		localPlayer.vehicle.position = random_point
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
		local health = math.max( 399, source.health - damage )
		CLIENT_VAR_vehicle_health = health
		source.health = health

		if attacker then
			if attacker.type == "weapon" then
				attacker = attacker:getData( "owner" )
			elseif attacker.type == "vehicle" then
				attacker = attacker.controller
			end
		end

		if isElement( attacker ) and attacker.vehicle then
			CreateUIDamage( source.position, attacker.vehicle.position, source.rotation.z )
		
			localPlayer:setData( "attacker", attacker, false )
			if isTimer( CLIENT_VAR_attacker_damage_timer ) then
				killTimer( CLIENT_VAR_attacker_damage_timer )
			end
			CLIENT_VAR_attacker_damage_timer = Timer( function( )
				localPlayer:setData( "attacker", false, false )
			end, 3 * 1000, 1 )
		end
	end

	if source.health <= 400 then
		CLIENT_VAR_vehicle_health = nil
		Timer( CLIENT_StartRespawnPlayer, 50, 1, localPlayer:getData( "attacker" ) )
	end
end

local function CLIENT_RaceKeyHandler( key, state )
	if CLIENT_VAR_disabled_keys[ key ] then
		cancelEvent( )
	end
end

local function CLIENT_CreateGiftBox_impl( i, pos_x, pos_y, pos_z, count )
	if CLIENT_VAR_loaded_gift_boxes[ i ] then
		CLIENT_VAR_loaded_gift_boxes[ i ]:destroy( )
	end

	local gift_box = TeleportPoint( {
		x = pos_x, y = pos_y, z = pos_z;
		radius = 6;
		dimension = localPlayer.dimension;
		keypress = false;
		accepted_elements = { player = true, vehicle = true };
	} )

	gift_box.count = count

	gift_box.marker:setColor( 255, 0, 0, 10 )
	gift_box.slowdown_coefficient = nil

	gift_box.elements = {}
	gift_box.elements.object = Object( CONST_GIFT_MODEL, pos_x, pos_y, pos_z )
	gift_box.elements.object.dimension = gift_box.dimension

	gift_box.elements.shader = dxCreateShader( "fx/tint.fx" )
	engineApplyShaderToWorldTexture( gift_box.elements.shader, "gift_white", gift_box.elements.object )

	if count <= 10 then
		gift_box.elements.object.scale = 1
		dxSetShaderValue( gift_box.elements.shader, "rgba", 1, 0, 0, 1 )

	elseif count <= 20 then
		gift_box.elements.object.scale = 1.5
		gift_box.elements.object.position = Vector3( pos_x, pos_y, pos_z + 0.5 )
		dxSetShaderValue( gift_box.elements.shader, "rgba", 0, 0, 1, 1 )

	else
		gift_box.elements.object.scale = 2
		gift_box.elements.object.position = Vector3( pos_x, pos_y, pos_z + 1 )
		dxSetShaderValue( gift_box.elements.shader, "rgba", 0.5, 0, 1, 1 )
	end

	gift_box.elements.blip = createBlipAttachedTo( gift_box.marker, 0, 1 + math.floor( 3 * ( count / 20 ) ) )

	gift_box.PreJoin = function( gift_box )
		return true
	end

	gift_box.PostJoin = function( gift_box, player )
		CLIENT_VAR_loaded_gift_boxes[ i ] = nil

		TriggerCustomServerEvent( "ClientPickupGiftBox", i )
		gift_box:destroy( )
	end

	CLIENT_VAR_loaded_gift_boxes[ i ] = gift_box
end

local function CLIENT_CreateGiftBox_handler( i, pos_x, pos_y, pos_z, count )
	if i then
		CLIENT_CreateGiftBox_impl( i, pos_x, pos_y, pos_z, count )
	else
		for i, position in pairs( CONST_GIFT_SPAWN_POSITIONS ) do
			CLIENT_CreateGiftBox_impl( i, position.x, position.y, position.z, 1 )
		end
	end
end


local function CLIENT_onUpdatePoint_handler( player, count_marker, place )
	UpdateScoreboard( player, count_marker, place )
end

local function CLIENT_PlayerPickupGiftBox_handler( player, i, count, gift_box_count )
	if player ~= localPlayer then
		player:setData( "gift_box_count", gift_box_count, false )

		if CLIENT_VAR_loaded_gift_boxes[ i ] then
			CLIENT_VAR_loaded_gift_boxes[ i ]:destroy( )
			CLIENT_VAR_loaded_gift_boxes[ i ] = nil
		end

		return
	end

	if not localPlayer.vehicle then return end

	playSound( "sounds/ammo_box_pickup.wav" ).volume = 0.2
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
			if CLIENT_VAR_rotate_vehicle_tick == 0 then	CLIENT_VAR_vehicle_health = localPlayer.vehicle.health end
			if CLIENT_VAR_vehicle_health then localPlayer.vehicle.health = CLIENT_VAR_vehicle_health end

			CLIENT_VAR_rotate_vehicle_tick = CLIENT_VAR_rotate_vehicle_tick + 1
		else
			CLIENT_VAR_rotate_vehicle_tick = 0
			CLIENT_VAR_vehicle_health = nil
		end

		if CLIENT_VAR_rotate_vehicle_tick >= 500 then
			localPlayer.vehicle.position = localPlayer.vehicle.position + Vector3( 0, 0, 0.2 )
			localPlayer.vehicle.rotation = Vector3( 0, 0, rz )

			if CLIENT_VAR_vehicle_health then localPlayer.vehicle.health = CLIENT_VAR_vehicle_health end 
			CLIENT_VAR_vehicle_health = nil
		end


		local players = getElementsWithinRange( localPlayer.vehicle.position, 30, "player" )
		for _, player in pairs( players ) do
			if player ~= localPlayer and player.dimension == localPlayer.dimension and player.vehicle then
				local gift_box_count = player:getData( "gift_box_count" )
				if gift_box_count then
					local sx, sy = getScreenFromWorldPosition( player.vehicle.position.x, player.vehicle.position.y, player.vehicle.position.z + 1, 0, false )
					if sx then
						local scale = math.max( 0.2, 1 - math.min( 1, ( player.vehicle.position - localPlayer.vehicle.position ).length / 25 ) )

						local i_sx, i_sy = math.floor( 83 * scale ), math.floor( 86 * scale )
						local i_px, i_py = sx - math.floor( i_sx / 2 ), sy - math.floor( i_sy / 2 )
						dxDrawImage( i_px, i_py, i_sx, i_sy, "img/gift_icon.png" )

						local t_px, t_py = sx, sy + math.floor( 17 * scale )
						dxDrawText( gift_box_count, t_px, t_py, t_px, t_py, COLOR_WHITE, scale, scale, ibFonts.bold_32, "center", "center" )
					end
				end
			end
		end
	end
end

local function CLIENT_PlayerExitFromGameZone( element, dim )
	if not dim then return end

	if element == localPlayer then
		if isTimer( CLIENT_VAR_game_zone_exit_timer ) then
			killTimer( CLIENT_VAR_game_zone_exit_timer )
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
		end

		DeleteUIZoneExit( )
	end
end

local function CLIENT_PlayerDeadAndNeedCreateGiftBox_handler( player, i, pos_x, pos_y, pos_z, gift_box_count )
	CLIENT_CreateGiftBox_handler( i, pos_x, pos_y, pos_z, gift_box_count )
end

REGISTERED_EVENTS[ event_id ] = {
	name = "Сбор подарков";
	group = "new_year";
	count_players = 6;
	scoreboard_text_point = "Количество подарков";

	coins_reward = {
		[ 1 ] = 47;
		[ 2 ] = 39;
		[ 3 ] = 32;
		[ 4 ] = 27;
		[ 5 ] = 21;
		[ 6 ] = 13;
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
			self.vehicles[ player ] = vehicle
			player:SetPrivateData( "gift_box_count", 0 )
			player:SetPrivateData( "gift_box_last_pickup", 0 )

			setTimer( function( )
				player.vehicle = vehicle
				vehicle.frozen = true
			end, 100, 1 )

			addEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler )

			table.insert( players, player )
		end

		AddCustomServerEventHandler( self, "VehicleMinigunFire", SERVER_VehicleMinigunFire_handler )
		AddCustomServerEventHandler( self, "ClientPickupGiftBox", SERVER_ClientPickupGiftBox_handler )
		AddCustomServerEventHandler( self, "ClientDeadAndNeedCreateGiftBox", SERVER_ClientDeadAndNeedCreateGiftBox_handler )

		self.gift_box = { }
		for i in pairs( CONST_GIFT_SPAWN_POSITIONS ) do
			self.gift_box[ i ] = 1
		end

		self.gift_box_respawn_timer = { }
	end;

	Setup_S_delay_handler = function( self, players )
		triggerClientEvent( players, event_id .."_CreateGiftBox", resourceRoot )
		triggerClientEvent( players, event_id .."_SetupVehicles", resourceRoot, self.vehicles )

		self.start_timer = Timer( function( )
			for player in pairs( self.players ) do
				player.vehicle.frozen = false
			end
		end, CONST_TIME_TO_START_EVENT * 1000, 1 )

		self.end_timer = Timer( function( )
			for k = #self.players_point, 1, -1 do
				PlayerEndEvent( self.players_point[ k ][ 1 ], "Вы заняли ".. k .." место", _, k, true )
			end
		end, CONST_TIME_TO_EVENT_END * 1000, 1 )
	end;

	Cleanup_S_handler = function( self )
		RemoveCustomServerEventHandler( self, "VehicleMinigunFire" )
		RemoveCustomServerEventHandler( self, "ClientPickupGiftBox" )
		RemoveCustomServerEventHandler( self, "ClientDeadAndNeedCreateGiftBox" )

		for i, timer in pairs( self.gift_box_respawn_timer ) do
			if isTimer( timer ) then
				killTimer( timer )
			end
		end

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
	end;

	Setup_C_handler = function( players, vehicles )
		if isElement( vehicles[ localPlayer ] ) then
			addEventHandler( "onClientVehicleDamage", vehicles[ localPlayer ], CLIENT_onClientVehicleDamage_handler, true, "high+10000" )
		end

		removeEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )
		addEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )

		bindKey( "mouse1", "both", CLIENT_LocalPlayerVehicleMinigunFire )
		bindKey( "mouse2", "both", CLIENT_LocalPlayerVehicleMinigunFire )

		toggleControl( "enter_exit", false )

		addEvent( event_id .."_UpdatePoint_handler", true )
		addEventHandler( event_id .."_UpdatePoint_handler", resourceRoot, CLIENT_onUpdatePoint_handler )

		addEvent( event_id .."_SetupVehicles", true )
		addEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles )

		addEvent( event_id .."_VehicleMinigunStartFire", true )
		addEventHandler( event_id .."_VehicleMinigunStartFire", resourceRoot, CLIENT_VehicleMinigunStartFire_handler )
		addEvent( event_id .."_VehicleMinigunStopFire", true )
		addEventHandler( event_id .."_VehicleMinigunStopFire", resourceRoot, CLIENT_VehicleMinigunStopFire_handler )

		addEvent( event_id .."_CreateGiftBox", true )
		addEventHandler( event_id .."_CreateGiftBox", resourceRoot, CLIENT_CreateGiftBox_handler )

		addEvent( event_id .."_PlayerPickupGiftBox", true )
		addEventHandler( event_id .."_PlayerPickupGiftBox", resourceRoot, CLIENT_PlayerPickupGiftBox_handler )

		addEvent( event_id .."_PlayerDeadAndNeedCreateGiftBox", true )
		addEventHandler( event_id .."_PlayerDeadAndNeedCreateGiftBox", resourceRoot, CLIENT_PlayerDeadAndNeedCreateGiftBox_handler )

		CLIENT_VAR_exit_zone_texture = dxCreateRenderTarget( 1, 1 )
		dxSetRenderTarget( CLIENT_VAR_exit_zone_texture, true )
		dxDrawRectangle( 0, 0, 1, 1, 0xffffffff )
		dxSetRenderTarget( )
		addEventHandler( "onClientRender", root, CLIENT_render_handler )

		CLIENT_VAR_exit_zone_colshape = ColShape.Polygon( unpack( CONST_GAME_ZONE ) )
		CLIENT_VAR_exit_zone_colshape.dimension = localPlayer.dimension
		addEventHandler( "onClientColShapeLeave", CLIENT_VAR_exit_zone_colshape, CLIENT_PlayerExitFromGameZone )
		addEventHandler( "onClientColShapeHit", CLIENT_VAR_exit_zone_colshape, CLIENT_PlayerEnterToGameZone )

		CLIENT_VAR_wait_respawn_timer = false
		CLIENT_VAR_respawn_gm_tick = 0
		CLIENT_VAR_loaded_gift_boxes = { }
		CLIENT_VAR_tick_minigun_reload = 0
		CLIENT_VAR_tick_rocket_reload = 0
		CLIENT_VAR_tick_rocket_fire_timeout = 0
		CLIENT_VAR_minigun_ammo = CONST_MINIGUN_AMMO
		CLIENT_VAR_rocket_ammo = CONST_ROCKET_AMMO
		CLIENT_VAR_vehicle_health = nil

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

		removeEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )
		removeEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles )
		removeEventHandler( event_id .."_VehicleMinigunStartFire", resourceRoot, CLIENT_VehicleMinigunStartFire_handler )
		removeEventHandler( event_id .."_VehicleMinigunStopFire", resourceRoot, CLIENT_VehicleMinigunStopFire_handler )
		removeEventHandler( event_id .."_CreateGiftBox", resourceRoot, CLIENT_CreateGiftBox_handler )
		removeEventHandler( event_id .."_PlayerPickupGiftBox", resourceRoot, CLIENT_PlayerPickupGiftBox_handler )
		removeEventHandler( event_id .."_PlayerDeadAndNeedCreateGiftBox", resourceRoot, CLIENT_PlayerDeadAndNeedCreateGiftBox_handler )
		removeEventHandler( event_id .."_UpdatePoint_handler", resourceRoot, CLIENT_onUpdatePoint_handler )
		removeEventHandler( "onClientRender", root, CLIENT_render_handler )

		if isElement( CLIENT_VAR_exit_zone_texture ) then
			destroyElement( CLIENT_VAR_exit_zone_texture )
		end

		if isElement( CLIENT_VAR_exit_zone_colshape ) then
			destroyElement( CLIENT_VAR_exit_zone_colshape )
		end

		if isTimer( CLIENT_VAR_wait_respawn_timer ) then
			killTimer( CLIENT_VAR_wait_respawn_timer )
		end

		if isTimer( CLIENT_VAR_game_zone_exit_timer ) then
			killTimer( CLIENT_VAR_game_zone_exit_timer )
		end

		if isTimer( CLIENT_VAR_attacker_damage_timer ) then
			killTimer( CLIENT_VAR_attacker_damage_timer )
			localPlayer:setData( "attacker", false, false )
		end

		for _, gift_box in pairs( CLIENT_VAR_loaded_gift_boxes ) do
			gift_box:destroy( )
		end
	end;
}

-- Тестирование
if not localPlayer and SERVER_NUMBER > 100 then
	addCommandHandler( "new_year_gift_collection", function( player, cmd, count )
		if not count then player:ShowError( "Введите количество игроков" ) return end
		count = tonumber( count )
		if count > 6 or count < 1 then player:ShowError( "Введите количество 1-6" ) return end
		player:ShowInfo( "Количество игроков " .. count )
        REGISTERED_EVENTS[ event_id ].count_players = count
	end )
	
	addCommandHandler( "new_year_gift_collection_min_time", function( player )
        player:ShowInfo( "Время игры сокращено до 30 секунд" )
		CONST_TIME_TO_EVENT_END = 30
	end )

	addCommandHandler( "new_year_gift_collection_min_time_reset", function( player )
		player:ShowInfo( "Сброшено время игры" )
		CONST_TIME_TO_EVENT_END = 5 * 60
	end )
end