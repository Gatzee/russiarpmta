local event_id = "halloween_derbi"

local CONST_SPAWN_POSITIONS = {
	Vector3( -780.277, -1423.5, 15.531 );
	Vector3( -866.727, -1380.322, 15.533 );
	Vector3( -866.998, -1151.383, 15.761 );
	Vector3( -788.281, -1122.225, 15.764 );
	Vector3( -701.785, -1169.89, 15.749 );
	Vector3( -701.735, -1394.104, 15.531 );
}

local CONST_AMMO_BOX_SPAWN_POSITIONS = {
	Vector3( -843.358, -1413.282, 15.611 );
	Vector3( -840.261, -1349.397, 15.611 );
	Vector3( -837.345, -1297.683, 15.611 );
	Vector3( -835.759, -1250.16, 15.903 );
	Vector3( -837.144, -1167.494, 15.903 );
	Vector3( -813.056, -1168.462, 15.903 );
	Vector3( -787.622, -1284.28, 15.611 );
	Vector3( -784.453, -1327.647, 15.611 );
	Vector3( -746.407, -1363.122, 15.611 );
	Vector3( -757.854, -1241.384, 15.903 );
	Vector3( -759.672, -1199.323, 15.903 );
	Vector3( -724.079, -1144.272, 15.903 );
	Vector3( -726.082, -1219.562, 15.903 );
	Vector3( -723.242, -1260.225, 15.903 );
	Vector3( -723.979, -1323.567, 15.611 );
	Vector3( -724.673, -1384.372, 15.611 );
}

local CONST_BOUNDS = {
	-875.83, -1095.448,
	-692.523, -1095.448,
	-692.523, -1440.924,
	-875.83, -1440.924,
	-875.83, -1095.448,
}

local CONST_BARREL_MODEL = 1222

local CONST_VEHICLE_MODEL = 6552

local CONST_VEHICLE_HEALTH = 500
local CONST_MINIGAN_DAMAGE = 5 / CONST_VEHICLE_HEALTH * ( 1000 - 360 )
local CONST_ROCKET_DAMAGE = 25 / CONST_VEHICLE_HEALTH * ( 1000 - 360 )

local CONST_TIME_TO_START_EVENT = 3
local CONST_TIME_TO_EVENT_END = 5 * 60
local CONST_TIME_TO_AMMOBOX_RESPAWN = 30

local CLIENT_VAR_ui = { }
local CLIENT_VAR_rocket_timeout = 0
local CLIENT_VAR_loaded_ammo_box = { }
local CLIENT_VAR_colshape
local CLIENT_VAR_texture

local function SERVER_onPlayerPreWasted_handler( )
	cancelEvent( )
	PlayerEndEvent( source, "Вы погибли" )
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

local function SERVER_ClientPickupAmmoBox_handler( self, i )
	if not self.ammo_box[ i ] then return end

	self.ammo_box[ i ] = nil
	for player in pairs( self.players ) do
		triggerClientEvent( player, event_id .."_PlayerPickupAmmo", resourceRoot, client, i )
	end
end

local function CLIENT_onClientVehicleDestroy_handler( )
	local weapon = source:getData( "vehicle_weapon" )
	if isElement( weapon ) then
		destroyElement( weapon )
	end
end

local function CLIENT_SetupVehicles_handler( vehicles )
	localPlayer:setData( "hud_timer_data", {
		text = "Конец раунда через:",
		timestamp = getRealTime( ).timestamp + CONST_TIME_TO_EVENT_END
	}, false )

	for player, vehicle in pairs( vehicles ) do
		local weapon = Weapon( "minigun", vehicle.position )
		weapon.dimension = vehicle.dimension
		attachElements( weapon, vehicle, 0, 1.3, 0.7, 0, 30, 90 )

		weapon.ammo = 0
		weapon.clipAmmo = player == localPlayer and 0 or 9999999
		weapon:setProperty( "fire_rotation", 0, -30, 0 )
		weapon:setProperty( "damage", CONST_MINIGAN_DAMAGE )

		vehicle:setData( "vehicle_weapon", weapon, false )

		addEventHandler( "onClientElementDestroy", vehicle, CLIENT_onClientVehicleDestroy_handler )

		if player == localPlayer then
			addEventHandler( "onClientWeaponFire", weapon, function( )
				if not localPlayer.vehicle then return end
				local weapon = localPlayer.vehicle:getData( "vehicle_weapon" )
				if not isElement( weapon ) then return end

				if isElement( CLIENT_VAR_ui.minigun_count ) then
					CLIENT_VAR_ui.minigun_count:ibData( "text", weapon.clipAmmo - 1 )
				end

				if weapon.clipAmmo <= 1 then
					weapon.state = "reloading"
					weapon.state = "ready"

					TriggerCustomServerEvent( "VehicleMinigunFire", "up" )
				end
			end )
		end
	end
end

local function CLIENT_onClientVehicleDamage_handler( attacker, weapon_id )
	if not source then return end
	cancelEvent( )

	if weapon_id == 51 then
		source.health = source.health - CONST_ROCKET_DAMAGE

	elseif weapon_id == 38 then
		source.health = source.health - CONST_MINIGAN_DAMAGE
	end

	if source.health <= 360 then
		localPlayer.health = 0
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

local function CLIENT_ClientLocalPlayerVehicleMinigunFire( key, state )
	if not localPlayer.vehicle then return end

	if key == "mouse1" then
		local weapon = localPlayer.vehicle:getData( "vehicle_weapon" )
		if not isElement( weapon ) then return end
		if weapon.clipAmmo == 0 then return end

		if state == "down" then
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
		if state == "down" and ( localPlayer:getData( "rocket_ammo" ) or 0 ) > 0 then
			if CLIENT_VAR_rocket_timeout > getTickCount( ) then return end

			CLIENT_VAR_rocket_timeout = getTickCount( ) + 1000

			createProjectile( localPlayer.vehicle, 19 )
			localPlayer:setData( "rocket_ammo", ( localPlayer:getData( "rocket_ammo" ) or 0 ) - 1, false )

			if isElement( CLIENT_VAR_ui.rocket_count ) then
				CLIENT_VAR_ui.rocket_count:ibData( "text", localPlayer:getData( "rocket_ammo" ) )
			end
		end
	end
end

local function CLIENT_ClientCreateAmmoBox_handler( )
	for i, position in pairs( CONST_AMMO_BOX_SPAWN_POSITIONS ) do
		if not CLIENT_VAR_loaded_ammo_box[ i ] then
			local ammo_box = TeleportPoint( {
				x = position.x, y = position.y, z = position.z;
				radius = 6;
				marker_text = ( i % 2 ) == 1 and "Миниган" or "Ракеты";
				dimension = localPlayer.dimension;
				keypress = false;
				accepted_elements = { player = true, vehicle = true }
			} )

			ammo_box.marker:setColor( 0, 0, 0, 25 )
			ammo_box.slowdown_coefficient = nil

			ammo_box.elements = {}
			ammo_box.elements.object = Object( CONST_BARREL_MODEL, position )
			ammo_box.elements.object.dimension = ammo_box.dimension
			ammo_box.elements.object.frozen = true
			ammo_box.elements.object.collisions = false

			ammo_box.PreJoin = function( ammo_box )
				return true
			end

			ammo_box.PostJoin = function( ammo_box, player )
				CLIENT_VAR_loaded_ammo_box[ i ] = nil

				TriggerCustomServerEvent( "ClientPickupAmmoBox", i )
				ammo_box:destroy( )
			end

			CLIENT_VAR_loaded_ammo_box[ i ] = ammo_box
		end
	end
end

local function CLIENT_PlayerPickupAmmo_handler( player, i )
	if player ~= localPlayer then
		if CLIENT_VAR_loaded_ammo_box[ i ] then
			CLIENT_VAR_loaded_ammo_box[ i ]:destroy( )
			CLIENT_VAR_loaded_ammo_box[ i ] = nil
		end

		return
	end

	if not localPlayer.vehicle then return end

	playSound( "sounds/ammo_box_pickup.wav" ).volume = 0.2

	if ( i % 2 ) == 1 then
		local weapon = localPlayer.vehicle:getData( "vehicle_weapon" )
		if not isElement( weapon ) then return end
		weapon.clipAmmo = weapon.clipAmmo + 50

		if isElement( CLIENT_VAR_ui.minigun_count ) then
			CLIENT_VAR_ui.minigun_count:ibData( "text", weapon.clipAmmo )
		end

	else
		localPlayer:setData( "rocket_ammo", ( localPlayer:getData( "rocket_ammo" ) or 0 ) + 5, false )

		if isElement( CLIENT_VAR_ui.rocket_count ) then
			CLIENT_VAR_ui.rocket_count:ibData( "text", localPlayer:getData( "rocket_ammo" ) )
		end
	end
end

local function CLIENT_RenderBounds( )
    for i = 1, #CONST_BOUNDS, 2 do
        local x, y = CONST_BOUNDS[ i ], CONST_BOUNDS[ i + 1 ]

        local i_next = ( i + 2 ) >= #CONST_BOUNDS and 1 or ( i + 2 )
        local x_next, y_next = CONST_BOUNDS[ i_next ], CONST_BOUNDS[ i_next + 1 ]

        local _, _, z = getElementPosition( localPlayer )
        z = z - 10

        dxDrawMaterialLine3D( x, y, z, x_next, y_next, z, CLIENT_VAR_texture, 75, tocolor( 255, 128, 128, math.floor( 0.7 * 128 ) ), x_next + 1, y_next + 1, z )
    end
end

local function CLIENT_RaceKeyHandler( key, state )
	local disabled_keys = { p = true, q = true, tab = true, m = true }
	if disabled_keys[key] then
		cancelEvent()
	elseif tonumber(key) and not bFinished then
		cancelEvent()
		if state and BOOSTS_LIST[tonumber(key)] then
			ApplyBooster(tonumber(key))
		end
	end
end

local function CLIENT_UdpateBoosterIcons( )
	for k,v in pairs( BOOSTS_LIST ) do
		if GetPlayerBoosters( v.id ) > 0 then
			CLIENT_VAR_ui[ "count".. k ]:ibData( "text", GetPlayerBoosters( v.id ) )
			CLIENT_VAR_ui[ "boost".. k ]:ibData( "color", 0xFFFFFFFF )
		else
			CLIENT_VAR_ui[ "count".. k ]:ibData( "text", "" )
			CLIENT_VAR_ui[ "boost".. k ]:ibData( "color", 0xFFAAAAAA )
		end
	end
end
addEvent( "UdpateBoosterIcons" )

local function CLIENT_ShowBoosterCooldown( iBooster, iTime )
	if isElement( CLIENT_VAR_ui[ "boost".. iBooster ] ) then
		CLIENT_VAR_ui[ "boost".. iBooster ]:ibData( "alpha", 50 )
		ibAlphaTo( CLIENT_VAR_ui[ "boost".. iBooster ], 255, iTime )
	end
end
addEvent( "ShowBoosterCooldown" )

local function CLIENT_onClientPlayerDamage_handler( )
	cancelEvent()
end

REGISTERED_EVENTS[ event_id ] = {
	name = "Дерби на выживание";
	group = "halloween";
	count_players = 6;
	timeout = 10 * 60;
	scoreboard_text_point = false;

	coins_reward = {
		[ 1 ] = 16;
		[ 2 ] = 14;
		[ 3 ] = 11;
		[ 4 ] = 9;
		[ 5 ] = 7;
		[ 6 ] = 4;
	},

	Setup_S_handler = function( self )
		self.vehicles = {}

		local counter = 0
		for player in pairs( self.players ) do
			counter = counter + 1

			local vehicle = Vehicle.CreateTemporary( CONST_VEHICLE_MODEL, CONST_SPAWN_POSITIONS[ counter ].x, CONST_SPAWN_POSITIONS[ counter ].y, CONST_SPAWN_POSITIONS[ counter ].z )
			vehicle.dimension = self.dimension
			self.vehicles[ player ] = vehicle

			setTimer( function( )
				player.vehicle = vehicle
				vehicle.frozen = true
			end, 100, 1 )

			addEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler )

			for i, info in pairs( BOOSTS_LIST ) do
				SetPlayerBoosters( player, info.id, 5 )
			end
		end

		AddCustomServerEventHandler( self, "VehicleMinigunFire", SERVER_VehicleMinigunFire_handler )
		AddCustomServerEventHandler( self, "ClientPickupAmmoBox", SERVER_ClientPickupAmmoBox_handler )
	end;

	Setup_S_delay_handler = function( self, players )
		self.start_timer = Timer( function( )
			local players = { }
			for player in pairs( self.players ) do
				if isElement( player.vehicle ) then
					table.insert( players, player )
					player.vehicle.frozen = false
				else
					PlayerEndEvent( player, "Ошибка инициализации" )
					--iprint( "EVENT_ERROR_INIT_PLAYER", player )
				end
			end

			self.ammo_box = { }
			for i in pairs( CONST_AMMO_BOX_SPAWN_POSITIONS ) do
				self.ammo_box[ i ] = true
			end
			triggerClientEvent( players, event_id .."_ClientCreateAmmoBox", resourceRoot )

			triggerClientEvent( players, event_id .."_SetupVehicles", resourceRoot, self.vehicles )

			self.end_timer = Timer( function( )
				local players_by_health = { }
				for player in pairs( self.players ) do
					table.insert( players_by_health, { player = player, health = player.vehicle.health } )
				end

				table.sort( players_by_health, function( a, b )
					return a.health < b.health
				end )

				for _, data in pairs( players_by_health ) do
					PlayerEndEvent( data.player, "Время вышло" )
				end
			end, CONST_TIME_TO_EVENT_END * 1000, 1 )

			self.ammo_box_respawn = Timer( function( )
				self.ammo_box = { }
				for i in pairs( CONST_AMMO_BOX_SPAWN_POSITIONS ) do
					self.ammo_box[ i ] = true
				end

				for player in pairs( self.players ) do
					triggerClientEvent( player, event_id .."_ClientCreateAmmoBox", resourceRoot )
				end
			end, CONST_TIME_TO_AMMOBOX_RESPAWN * 1000, 0 )
		end, CONST_TIME_TO_START_EVENT * 1000, 1 )
	end;

	Setup_C_handler = function( players, vehicles )
		if isElement( vehicles[ localPlayer ] ) then
			addEventHandler( "onClientVehicleDamage", vehicles[ localPlayer ], CLIENT_onClientVehicleDamage_handler, true, "high+10000" )
		end

		addEvent( event_id .."_SetupVehicles", true )
		addEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles_handler )

		addEvent( event_id .."_VehicleMinigunStartFire", true )
		addEventHandler( event_id .."_VehicleMinigunStartFire", resourceRoot, CLIENT_VehicleMinigunStartFire_handler )
		addEvent( event_id .."_VehicleMinigunStopFire", true )
		addEventHandler( event_id .."_VehicleMinigunStopFire", resourceRoot, CLIENT_VehicleMinigunStopFire_handler )

		addEvent( event_id .."_PlayerPickupAmmo", true )
		addEventHandler( event_id .."_PlayerPickupAmmo", resourceRoot, CLIENT_PlayerPickupAmmo_handler )

		CLIENT_VAR_loaded_ammo_box = { }
		addEvent( event_id .."_ClientCreateAmmoBox", true )
		addEventHandler( event_id .."_ClientCreateAmmoBox", resourceRoot, CLIENT_ClientCreateAmmoBox_handler )

		toggleControl( "enter_exit", false )

		bindKey( "mouse1", "both", CLIENT_ClientLocalPlayerVehicleMinigunFire )
		bindKey( "mouse2", "both", CLIENT_ClientLocalPlayerVehicleMinigunFire )

		CLIENT_VAR_ui.rocket = ibCreateImage( _SCREEN_X - 112, _SCREEN_Y - 450, 82, 70, "img/rocket_bg.png" )
		CLIENT_VAR_ui.minigun = ibCreateImage( _SCREEN_X - 197, _SCREEN_Y - 450, 82, 70, "img/minigun_bg.png" )

		CLIENT_VAR_ui.minigun_count = ibCreateLabel( 70, 9, 0, 0, "0", CLIENT_VAR_ui.minigun, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData( "font", ibFonts.bold_14 ):ibData( "outline", true )
		CLIENT_VAR_ui.rocket_count = ibCreateLabel( 70, 9, 0, 0, "0", CLIENT_VAR_ui.rocket, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData( "font", ibFonts.bold_14 ):ibData( "outline", true )

		local booster_position = {
			{ x = 466, y = 287 },
			{ x = 407, y = 358 },
			{ x = 332, y = 390 },
			{ x = 254, y = 388 },
		}

		for k,v in pairs(BOOSTS_LIST) do
			CLIENT_VAR_ui[ "boost".. k ] = ibCreateImage( _SCREEN_X - booster_position[ k ].x + 30, _SCREEN_Y - booster_position[ k ].y + 30, 90, 90, "img/icon_"..v.id..".png" )
			CLIENT_VAR_ui[ "count".. k ] = ibCreateLabel( 66, 15, 0, 0, GetPlayerBoosters( v.id ), CLIENT_VAR_ui[ "boost".. k ], 0xFFFFFFFF, 1, 1, "center", "center" ):ibData( "font", ibFonts.oxaniumbold_14 ):ibData( "outline", true )
			if GetPlayerBoosters( v.id ) <= 0 then
				CLIENT_VAR_ui[ "count".. k ]:ibData( "text", "" )
				CLIENT_VAR_ui[ "boost".. k ]:ibData( "color", 0xFFAAAAAA )
			end
		end

		localPlayer:setData( "rocket_ammo", 0, false )

		CLIENT_VAR_texture = dxCreateRenderTarget( 1, 1 )
		dxSetRenderTarget( CLIENT_VAR_texture, true )
		dxDrawRectangle( 0, 0, 1, 1, 0xffffffff )
		dxSetRenderTarget( )
		addEventHandler( "onClientRender", root, CLIENT_RenderBounds )

		CLIENT_VAR_colshape = ColShape.Polygon( unpack( CONST_BOUNDS ) )
		CLIENT_VAR_colshape.dimension = localPlayer.dimension
		addEventHandler( "onClientColShapeLeave", CLIENT_VAR_colshape, function( element )
			if element == localPlayer then
				localPlayer.health = 0
			end
		end )

		addEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )
		addEventHandler( "UdpateBoosterIcons", resourceRoot, CLIENT_UdpateBoosterIcons )
		addEventHandler( "ShowBoosterCooldown", resourceRoot, CLIENT_ShowBoosterCooldown )

		addEventHandler( "onClientPlayerDamage", localPlayer, CLIENT_onClientPlayerDamage_handler )
	end;

	CleanupPlayer_S_handler = function( self, player )
		removeEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler )

		if isElement( self.vehicles[ player ] ) then
			destroyElement( self.vehicles[ player ] )
		end
	end;

	Cleanup_S_handler = function( self )
		if isTimer( self.start_timer ) then
			killTimer( self.start_timer )
		end

		if isTimer( self.end_timer ) then
			killTimer( self.end_timer )
		end

		if isTimer( self.ammo_box_respawn ) then
			killTimer( self.ammo_box_respawn )
		end

		RemoveCustomServerEventHandler( self, "VehicleMinigunFire" )
		RemoveCustomServerEventHandler( self, "ClientPickupAmmoBox" )
	end;

	Cleanup_C_handler = function( )
		localPlayer:setData( "hud_timer_data", false, false )

		removeEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles_handler )

		removeEventHandler( event_id .."_VehicleMinigunStartFire", resourceRoot, CLIENT_VehicleMinigunStartFire_handler )
		removeEventHandler( event_id .."_VehicleMinigunStopFire", resourceRoot, CLIENT_VehicleMinigunStopFire_handler )

		removeEventHandler( event_id .."_PlayerPickupAmmo", resourceRoot, CLIENT_PlayerPickupAmmo_handler )
		removeEventHandler( event_id .."_ClientCreateAmmoBox", resourceRoot, CLIENT_ClientCreateAmmoBox_handler )

		toggleControl( "enter_exit", true )

		unbindKey( "mouse1", "both", CLIENT_ClientLocalPlayerVehicleMinigunFire )
		unbindKey( "mouse2", "both", CLIENT_ClientLocalPlayerVehicleMinigunFire )

		localPlayer:setData( "rocket_ammo", false, false )

		if isElement( CLIENT_VAR_texture ) then
			destroyElement( CLIENT_VAR_texture )
		end
		removeEventHandler( "onClientRender", root, CLIENT_RenderBounds )

		if isElement( CLIENT_VAR_colshape ) then
			destroyElement( CLIENT_VAR_colshape )
		end

		DestroyTableElements( CLIENT_VAR_ui )

		removeEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )
		removeEventHandler( "UdpateBoosterIcons", resourceRoot, CLIENT_UdpateBoosterIcons )
		removeEventHandler( "ShowBoosterCooldown", resourceRoot, CLIENT_ShowBoosterCooldown )
		removeEventHandler( "onClientPlayerDamage", localPlayer, CLIENT_onClientPlayerDamage_handler )

		for _, ammo_box in pairs( CLIENT_VAR_loaded_ammo_box ) do
			ammo_box:destroy( )
		end
	end;
}

-- Тестирование
if not localPlayer and SERVER_NUMBER > 100 then
    addCommandHandler( "halloween_derbi", function( player )
		iprint( "halloween_derbi count 2" )
		REGISTERED_EVENTS[ event_id ].count_players = 2
    end )
end