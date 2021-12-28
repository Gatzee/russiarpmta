local event_id = "halloween_race"

local CONST_AMMO_BOX_SPAWN_POSITIONS = {
	Vector3( 2095.823, -1528.003, 60.552 );
	Vector3( 2092.224, -1529.484, 60.552 );
	Vector3( 2088.728, -1530.989, 60.546 );
	Vector3( 2085.199, -1532.477, 60.546 );

	Vector3( 1801.698, -964.57, 60.546 );
	Vector3( 1797.977, -965.811, 60.546 );
	Vector3( 1794.444, -967.075, 60.546 );
	Vector3( 1790.893, -968.346, 60.546 );

	Vector3( 1741.188, -454.114, 60.543 );
	Vector3( 1737.471, -452.687, 60.543 );
	Vector3( 1734.126, -451.242, 60.538 );
	Vector3( 1730.569, -449.66, 60.538 );

	Vector3( 2125.299, -332.185, 60.548 );
	Vector3( 2128.819, -330.824, 60.548 );
	Vector3( 2132.311, -329.477, 60.548 );
	Vector3( 2135.96, -328.068, 60.548 );

	Vector3( 2326.739, -664.488, 60.543 );
	Vector3( 2330.185, -663.2, 60.543 );
	Vector3( 2333.735, -661.848, 60.543 );
	Vector3( 2337.376, -660.462, 60.536 );

	Vector3( 2310.439, -1199.915, 60.277 );
	Vector3( 2313.844, -1201.734, 60.266 );
	Vector3( 2317.345, -1203.433, 60.277 );
	Vector3( 2320.662, -1205.387, 60.276 );
}

local CONST_BARREL_MODEL = 1222

local CONST_VEHICLE_MODEL = 6552

local CONST_VEHICLE_HEALTH = 500
local CONST_MINIGAN_DAMAGE = 5 / CONST_VEHICLE_HEALTH * ( 1000 - 360 )
local CONST_ROCKET_DAMAGE = 25 / CONST_VEHICLE_HEALTH * ( 1000 - 360 )

local CONST_TIME_TO_START_EVENT = 3
local CONST_TIME_TO_EVENT_END = 10 * 60
local CONST_TIME_TO_AMMOBOX_RESPAWN = 30

local CLIENT_VAR_ui = { }
local CLIENT_VAR_loaded_ammo_box = { }
local CLIENT_VAR_rocket_timeout = 0
local CLIENT_VAR_last_r_push = nil
local CLIENT_VAR_iRaceStarted
local CLIENT_VAR_iSecondsPassed
local CLIENT_VAR_iTotalSeconds

local CLIENT_VAR_loaded_objects = { }
local CLIENT_VAR_current_marker = nil
local CLIENT_VAR_current_marker_index = 0
local CLIENT_VAR_current_circle_index = 1

local CLIENT_VAR_count_marker = nil

local function SERVER_onPlayerWasted_handler( )
	cancelEvent( )
	PlayerEndEvent( source, "Вы погибли" )
end

local function SERVER_ClientMarkerHit_handler( self, count_marker )
	for player in pairs( self.players ) do
		triggerClientEvent( player, event_id .."_PlayerMarkerHit", resourceRoot, client, count_marker )
	end
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

local function SERVER_PlayerFinishCircle_handler( self, CLIENT_VAR_current_circle_index )
	if CLIENT_VAR_current_circle_index > 3 then
		self.count_finished = ( self.count_finished or 0 ) + 1
		local number = self.count_finished
		PlayerEndEvent( client, "Вы заняли ".. number .." место", _, number, true )

		if number == 1 then
			if isTimer( self.end_timer ) then
				killTimer( self.end_timer )
			end

			self.end_timer = Timer( function( )
				for player in pairs( self.players ) do
					PlayerEndEvent( player, "Вы не успели финишировать", _, 10 )
				end
			end, 120 * 1000, 1 )

			for player in pairs( self.players ) do
				triggerClientEvent( player, event_id .."_ClientUpdateTimer", resourceRoot )
			end
		end
	else
		if CLIENT_VAR_current_circle_index > self.CLIENT_VAR_current_circle_index then
			self.CLIENT_VAR_current_circle_index = CLIENT_VAR_current_circle_index

			for i in pairs( CONST_AMMO_BOX_SPAWN_POSITIONS ) do
				self.ammo_box[ i ] = true
			end

			for player in pairs( self.players ) do
				triggerClientEvent( player, event_id .."_ClientCreateAmmoBox", resourceRoot )
			end
		end
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

	if weapon_id == 51 then
		cancelEvent( )
		source.health = source.health - CONST_ROCKET_DAMAGE

	elseif weapon_id == 38 then
		cancelEvent( )
		source.health = source.health - CONST_MINIGAN_DAMAGE
	end

	if source.health <= 360 then
		cancelEvent( )
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

local function ClientLocalPlayerVehicleMinigunFire( key, state )
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
				x = position.x, y = position.y, z = position.z + 1;
				radius = 2;
				marker_text = ( i % 2 ) == 1 and "Миниган" or "Ракеты";
				dimension = localPlayer.dimension;
				keypress = false;
				accepted_elements = { player = true, vehicle = true }
			} )

			setMarkerType( ammo_box.marker, "corona" )
			ammo_box.marker:setColor( 255, 0, 0, 100 )
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

local function CLIENT_DrawOutlinedText( str, x, y, x2, y2, color, scale, font, align_x, align_y )
	dxDrawText( str, x-1, y, x2-1, y2, 0xFF000000, scale, font, align_x, align_y )
	dxDrawText( str, x+1, y, x2+1, y2, 0xFF000000, scale, font, align_x, align_y )
	dxDrawText( str, x, y-1, x2, y2-1, 0xFF000000, scale, font, align_x, align_y )
	dxDrawText( str, x, y+1, x2, y2+1, 0xFF000000, scale, font, align_x, align_y )
	dxDrawText( str, x, y, x2, y2, color, scale, font, align_x, align_y )
end

local function CLIENT_RenderBounds()
	if getKeyState( "r" ) then
		if not CLIENT_VAR_last_r_push then
			CLIENT_VAR_last_r_push = getTickCount()
		end
	else
		CLIENT_VAR_last_r_push = nil
	end

	if CLIENT_VAR_last_r_push then
		local fProgress = (getTickCount() - CLIENT_VAR_last_r_push) / 1000
		if fProgress >= 1 then
			CLIENT_RecoverVehicle()
			CLIENT_VAR_last_r_push = nil
		else
			dxDrawRectangle( _SCREEN_X/2-151, _SCREEN_Y-201, 302, 42, 0x99000000 )
			dxDrawRectangle( _SCREEN_X/2-150, _SCREEN_Y-200, 300*fProgress, 40, 0xFF22dd22 )
			CLIENT_DrawOutlinedText( "Возврат на трек", _SCREEN_X/2-150, _SCREEN_Y-200, _SCREEN_X/2+150, _SCREEN_Y-160, 0xFFFFFFFF, 1, ibFonts.bold_20, "center", "center" )
		end
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

local function CLIENT_PlayerMarkerHit_handler( player, count_marker )
	UpdateScoreboard( player, count_marker )
end

local function CLIENT_CreateNextRaceMarker( )
	if CLIENT_VAR_current_marker and isElement( CLIENT_VAR_current_marker.marker ) then
		destroyElement( CLIENT_VAR_current_marker.marker )
		destroyElement( CLIENT_VAR_current_marker.blip )
	end

	CLIENT_VAR_current_marker_index = CLIENT_VAR_current_marker_index + 1
	local next_marker = CONST_TRACK_DATA.markers[ CLIENT_VAR_current_marker_index ]
	if next_marker then
		CLIENT_VAR_count_marker = CLIENT_VAR_count_marker + 1
		TriggerCustomServerEvent( "ClientMarkerHit", CLIENT_VAR_count_marker )

		CLIENT_VAR_current_marker = { }
		CLIENT_VAR_current_marker.marker = createMarker( next_marker.x, next_marker.y, next_marker.z, "checkpoint", 20, 200, 50, 50 )
		CLIENT_VAR_current_marker.marker.dimension = localPlayer.dimension
		CLIENT_VAR_current_marker.blip = createBlipAttachedTo( CLIENT_VAR_current_marker.marker, 0, 3, 200, 50, 50 )

		addEventHandler( "onClientMarkerHit", CLIENT_VAR_current_marker.marker, function( player, dim )
			if player == localPlayer and dim then
				CLIENT_CreateNextRaceMarker()
			end
		end )

		local target_marker = CONST_TRACK_DATA.markers[ CLIENT_VAR_current_marker_index + 1 ]
		if target_marker then
			setMarkerTarget( CLIENT_VAR_current_marker.marker, target_marker.x, target_marker.y, target_marker.z )
		else
			setMarkerColor( CLIENT_VAR_current_marker.marker, 50, 200, 50, 150 )
			setMarkerIcon( CLIENT_VAR_current_marker.marker, "finish" )
		end
	else
		CLIENT_VAR_current_circle_index = CLIENT_VAR_current_circle_index + 1

		if CLIENT_VAR_current_circle_index <= 3 then
			CLIENT_VAR_ui.lap:ibData( "text", "Круги: " .. CLIENT_VAR_current_circle_index .. "/3" )
			CLIENT_VAR_current_marker_index = 0
			CLIENT_CreateNextRaceMarker( )
		end

		TriggerCustomServerEvent( "PlayerFinishCircle", CLIENT_VAR_current_circle_index )
	end
end

function CLIENT_RecoverVehicle()
	local recovery_marker_index = CLIENT_VAR_current_marker_index - 1

	if recovery_marker_index <= 0 then
		recovery_marker_index = #CONST_TRACK_DATA.markers - 1
	end

	local pRecoveryMarker = CONST_TRACK_DATA.markers[ recovery_marker_index ]
	setElementPosition( localPlayer.vehicle, pRecoveryMarker.x, pRecoveryMarker.y, pRecoveryMarker.z+0.1 )
	local pNextRecoveryMarker = CONST_TRACK_DATA.markers[ recovery_marker_index + 1 ]
	if pNextRecoveryMarker then
		local vecDirection = Vector3( pNextRecoveryMarker.x, pNextRecoveryMarker.y, pNextRecoveryMarker.z ) - Vector3( pRecoveryMarker.x, pRecoveryMarker.y, pRecoveryMarker.z )
		vecDirection:normalize()
		vecDirection.z = 0
		local direction_angle = -math.deg( math.atan2( pNextRecoveryMarker.x - pRecoveryMarker.x, pNextRecoveryMarker.y - pRecoveryMarker.y ) )

		setElementRotation( localPlayer.vehicle, 0, 0, direction_angle )
		localPlayer.vehicle.velocity = vecDirection*0.3
	end
end

local function CLIENT_DrawStartTimer()
	local fProgress = ( getTickCount() - CLIENT_VAR_iRaceStarted - CLIENT_VAR_iSecondsPassed*1000 ) / 1000
	local fInterpolated = interpolateBetween(0, 0, 0, _SCREEN_X, 0, 0, fProgress, "OutInBack")

	if fProgress >= 1 then
		CLIENT_VAR_iSecondsPassed = CLIENT_VAR_iSecondsPassed + 1
		if CLIENT_VAR_iSecondsPassed > CLIENT_VAR_iTotalSeconds then
			removeEventHandler( "onClientRender", root, CLIENT_DrawStartTimer )
		elseif CLIENT_VAR_iSecondsPassed == CLIENT_VAR_iTotalSeconds then
			playSound("sounds/start.wav")
		else
			playSound("sounds/timer_tick.wav")
		end
	end

	dxDrawRectangle(0, _SCREEN_Y / 2 - 25, _SCREEN_X, 50, tocolor(0,0,0,100))

	local iSecondsLeft = CLIENT_VAR_iTotalSeconds-CLIENT_VAR_iSecondsPassed
	CLIENT_DrawOutlinedText( iSecondsLeft > 0 and iSecondsLeft or "GO", fInterpolated, _SCREEN_Y / 2, fInterpolated, _SCREEN_Y / 2, 0xFFFFFFFF, 1, ibFonts.bold_20, "center", "center" )
end

local function CLIENT_ClientUpdateTimer( )
	localPlayer:setData( "hud_timer_data", {
		text = "Конец раунда через:",
		timestamp = getRealTime( ).timestamp + 120
	}, false )

	localPlayer:ShowError( "Торопись, лидер уже на финише!" )
end

REGISTERED_EVENTS[ event_id ] = {
	name = "Гонки на выживание";
	group = "halloween";
	count_players = 4;
	timeout = 10 * 60;
	scoreboard_text_point = false;

	coins_reward = {
		[ 1 ] = 15;
		[ 2 ] = 13;
		[ 3 ] = 8;
		[ 4 ] = 6;
	},

	Setup_S_handler = function( self )
		self.vehicles = {}

		local counter = 0
		for player in pairs( self.players ) do
			counter = counter + 1

			local vehicle = Vehicle.CreateTemporary( CONST_VEHICLE_MODEL, CONST_TRACK_DATA.spawns[ counter ].x, CONST_TRACK_DATA.spawns[ counter ].y, CONST_TRACK_DATA.spawns[ counter ].z, CONST_TRACK_DATA.spawns[ counter ].rx or 0, CONST_TRACK_DATA.spawns[ counter ].ry or 0, CONST_TRACK_DATA.spawns[ counter ].rz or 0 )
			vehicle.dimension = self.dimension
			self.vehicles[ player ] = vehicle

			setTimer( function( )
				player.vehicle = vehicle
				vehicle.frozen = true
			end, 100, 1 )

			addEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerWasted_handler )

			for i, info in pairs( BOOSTS_LIST ) do
				SetPlayerBoosters( player, info.id, 5 )
			end
		end

		AddCustomServerEventHandler( self, "VehicleMinigunFire", SERVER_VehicleMinigunFire_handler )
		AddCustomServerEventHandler( self, "ClientPickupAmmoBox", SERVER_ClientPickupAmmoBox_handler )
		AddCustomServerEventHandler( self, "PlayerFinishCircle", SERVER_PlayerFinishCircle_handler )
		AddCustomServerEventHandler( self, "ClientMarkerHit", SERVER_ClientMarkerHit_handler )

		self.CLIENT_VAR_current_circle_index = 1

		
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
				end
			end

			self.ammo_box = { }
			for i in pairs( CONST_AMMO_BOX_SPAWN_POSITIONS ) do
				self.ammo_box[ i ] = true
			end
			triggerClientEvent( players, event_id .."_ClientCreateAmmoBox", resourceRoot )

			triggerClientEvent( players, event_id .."_SetupVehicles", resourceRoot, self.vehicles )

			self.end_timer = Timer( function( )
				for player in pairs( self.players ) do
					PlayerEndEvent( player, "Вы не успели финишировать", _, 10 )
				end
			end, CONST_TIME_TO_EVENT_END * 1000, 1 )
		end, CONST_TIME_TO_START_EVENT * 1000, 1 )
	end;

	Setup_C_handler = function( players, vehicles )
		localPlayer:setData( "hud_timer_data", {
			text = "Начало через:",
			text_color = 0xff97ff63;
			timestamp = getRealTime( ).timestamp + CONST_TIME_TO_START_EVENT
		}, false )

		if isElement( vehicles[ localPlayer ] ) then
			addEventHandler( "onClientVehicleDamage", vehicles[ localPlayer ], CLIENT_onClientVehicleDamage_handler, true, "high+10000" )
		end

		addEvent( event_id .."_ClientUpdateTimer", true )
		addEventHandler( event_id .."_ClientUpdateTimer", resourceRoot, CLIENT_ClientUpdateTimer )

		addEvent( event_id .."_PlayerMarkerHit", true )
		addEventHandler( event_id .."_PlayerMarkerHit", resourceRoot, CLIENT_PlayerMarkerHit_handler )

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

		bindKey( "mouse1", "both", ClientLocalPlayerVehicleMinigunFire )
		bindKey( "mouse2", "both", ClientLocalPlayerVehicleMinigunFire )

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

		addEventHandler( "onClientRender", root, CLIENT_RenderBounds )

		removeEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )
		addEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )
		addEventHandler( "UdpateBoosterIcons", resourceRoot, CLIENT_UdpateBoosterIcons )
		addEventHandler( "ShowBoosterCooldown", resourceRoot, CLIENT_ShowBoosterCooldown )

		addEventHandler( "onClientPlayerDamage", localPlayer, CLIENT_onClientPlayerDamage_handler )

		CLIENT_VAR_loaded_objects = { }
		for k, v in pairs( CONST_TRACK_DATA.static_objects ) do
			local obj = createObject( v.model, v.x, v.y, v.z, 0, v.ry or 0, v.rz )
			obj.frozen = true
			obj.dimension = localPlayer.dimension

			table.insert( CLIENT_VAR_loaded_objects, obj )
		end

		CLIENT_VAR_current_marker = nil
		CLIENT_VAR_current_marker_index = 0
		CLIENT_VAR_current_circle_index = 1
		CLIENT_VAR_count_marker = 0
		CLIENT_CreateNextRaceMarker( )

		CLIENT_VAR_ui.lap = ibCreateLabel( 56 + 270, _SCREEN_Y - 26, 0, 0, "Круги: " .. CLIENT_VAR_current_circle_index .. "/3" , _, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData( "font", ibFonts.bold_14 ):ibData( "outline", true )

		CLIENT_VAR_iRaceStarted = getTickCount()
		CLIENT_VAR_iSecondsPassed = 0
		CLIENT_VAR_iTotalSeconds = iSeconds or 3
		addEventHandler( "onClientRender", root, CLIENT_DrawStartTimer )
		playSound( "sounds/timer_tick.wav" )
	end;

	CleanupPlayer_S_handler = function( self, player )
		removeEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerWasted_handler )

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
		RemoveCustomServerEventHandler( self, "PlayerFinishCircle" )
		RemoveCustomServerEventHandler( self, "ClientMarkerHit" )
	end;

	Cleanup_C_handler = function( )
		localPlayer:setData( "hud_timer_data", false, false )

		removeEventHandler( event_id .."_ClientUpdateTimer", resourceRoot, CLIENT_ClientUpdateTimer )

		removeEventHandler( event_id .."_PlayerMarkerHit", resourceRoot, CLIENT_PlayerMarkerHit_handler )

		removeEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles_handler )

		removeEventHandler( event_id .."_VehicleMinigunStartFire", resourceRoot, CLIENT_VehicleMinigunStartFire_handler )
		removeEventHandler( event_id .."_VehicleMinigunStopFire", resourceRoot, CLIENT_VehicleMinigunStopFire_handler )

		removeEventHandler( event_id .."_PlayerPickupAmmo", resourceRoot, CLIENT_PlayerPickupAmmo_handler )
		removeEventHandler( event_id .."_ClientCreateAmmoBox", resourceRoot, CLIENT_ClientCreateAmmoBox_handler )

		toggleControl( "enter_exit", true )

		unbindKey( "mouse1", "both", ClientLocalPlayerVehicleMinigunFire )
		unbindKey( "mouse2", "both", ClientLocalPlayerVehicleMinigunFire )

		localPlayer:setData( "rocket_ammo", false, false )

		removeEventHandler( "onClientRender", root, CLIENT_RenderBounds )

		DestroyTableElements( CLIENT_VAR_ui )

		removeEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )
		removeEventHandler( "UdpateBoosterIcons", resourceRoot, CLIENT_UdpateBoosterIcons )
		removeEventHandler( "ShowBoosterCooldown", resourceRoot, CLIENT_ShowBoosterCooldown )

		removeEventHandler( "onClientPlayerDamage", localPlayer, CLIENT_onClientPlayerDamage_handler )

		for _, ammo_box in pairs( CLIENT_VAR_loaded_ammo_box ) do
			ammo_box:destroy( )
		end

		for _, obj in pairs( CLIENT_VAR_loaded_objects ) do
			if isElement( obj ) then
				destroyElement( obj )
			end
		end

		if CLIENT_VAR_current_marker and isElement( CLIENT_VAR_current_marker.marker ) then
			destroyElement( CLIENT_VAR_current_marker.marker )
			destroyElement( CLIENT_VAR_current_marker.blip )
		end

		removeEventHandler( "onClientRender", root, CLIENT_DrawStartTimer )
	end;
}

if localPlayer then
	local col = engineLoadCOL( "models/".. CONST_BARREL_MODEL ..".col" )
	engineReplaceCOL( col, CONST_BARREL_MODEL )
	local txd = engineLoadTXD( "models/".. CONST_BARREL_MODEL ..".txd" )
	engineImportTXD( txd, CONST_BARREL_MODEL )
	local dff = engineLoadDFF( "models/".. CONST_BARREL_MODEL ..".dff" )
	engineReplaceModel( dff, CONST_BARREL_MODEL )
end


CONST_TRACK_DATA = {
	markers = { 
		{
			is_visible = true,
			x = 2132.4727,
			y = -1589.17981,
			z = 60.546463,
		},
		{
			is_visible = true,
			x = 2056.9326,
			y = -1467.84369,
			z = 60.547752,
		},
		{
			is_visible = true,
			x = 1977.6215,
			y = -1360.633,
			z = 60.547752,
		},
		{
			is_visible = true,
			x = 1891.7059,
			y = -1195.95139,
			z = 60.542149,
		},
		{
			is_visible = true,
			x = 1815.1304,
			y = -1012.91565,
			z = 60.539036,
		},
		{
			is_visible = true,
			x = 1763.1605,
			y = -872.471169,
			z = 60.545612,
		},
		{
			is_visible = true,
			x = 1723.5726,
			y = -729.32005,
			z = 60.545963,
		},
		{
			is_visible = true,
			x = 1709.416,
			y = -596.5459,
			z = 60.545963,
		},
		{
			is_visible = true,
			x = 1755.9686,
			y = -410.14688,
			z = 60.54335,
		},
		{
			is_visible = true,
			x = 1859.7937,
			y = -284.7702,
			z = 60.550377,
		},
		{
			is_visible = true,
			x = 1967.7582,
			y = -187.20947,
			z = 60.543098,
		},
		{
			is_visible = true,
			x = 2023.7893,
			y = -177.61066,
			z = 60.543098,
		},
		{
			is_visible = true,
			x = 2094.6531,
			y = -257.85114,
			z = 60.543098,
		},
		{
			is_visible = true,
			x = 2191.9539,
			y = -476.43939,
			z = 60.548264,
		},
		{
			is_visible = true,
			x = 2247.4067,
			y = -553.04883,
			z = 60.543362,
		},
		{
			is_visible = true,
			x = 2326.2771,
			y = -645.73984,
			z = 60.543362,
		},
		{
			is_visible = true,
			x = 2344.7249,
			y = -709.62628,
			z = 60.543362,
		},
		{
			is_visible = true,
			x = 2386.4155,
			y = -860.3236618,
			z = 60.545349,
		},
		{
			is_visible = true,
			x = 2363.9783,
			y = -1050.59671,
			z = 60.549141,
		},
		{
			is_visible = true,
			x = 2330.2366,
			y = -1163.15906,
			z = 60.549141,
		},
		{
			is_visible = true,
			x = 2296.4131,
			y = -1257.52319,
			z = 60.552048,
		},
		{
			is_visible = true,
			x = 2252.7915,
			y = -1377.54022,
			z = 60.54744,
		},
		{
			is_visible = true,
			x = 2218.2856,
			y = -1507.93292,
			z = 60.548828,
		},
	},
	spawns = { 
		{
			rz = 151,
			x = 2195.6992,
			y = -1551.26025,
			z = 60.546463,
		},
		{
			rz = 151,
			x = 2199.5012,
			y = -1552.4798,
			z = 60.546463,
		},
		{
			rz = 151,
			x = 2203.1587,
			y = -1553.46509,
			z = 60.546463,
		},
		{
			rz = 151,
			x = 2198.4705,
			y = -1545.97644,
			z = 60.546463,
		},
		{
			rz = 151,
			x = 2202.2935,
			y = -1546.62036,
			z = 60.546463,
		},
		{
			rz = 151,
			x = 2205.8535,
			y = -1547.61804,
			z = 60.548828,
		},
		{
			rz = 151,
			x = 2201.0923,
			y = -1540.54108,
			z = 60.546463,
		},
		{
			rz = 153,
			x = 2204.6191,
			y = -1541.43347,
			z = 60.548828,
		},
	},
	static_objects = { 
		{
			model = 1340,
			ry = 0,
			rz = -121,
			x = 2114.0222,
			y = -1589.65662,
			z = 59.546211
		},
		{
			model = 1340,
			ry = 0,
			rz = -121,
			x = 2116.5979,
			y = -1591.20435,
			z = 59.546463
		},
		{
			model = 1340,
			ry = 0,
			rz = -121,
			x = 2119.1736,
			y = -1592.75208,
			z = 59.546463
		},
		{
			model = 1340,
			ry = 0,
			rz = -118,
			x = 2121.7881,
			y = -1594.23145,
			z = 59.546463
		},
		{
			model = 1340,
			ry = 0,
			rz = -118,
			x = 2124.4414,
			y = -1595.64221,
			z = 59.546463
		},
		{
			model = 1340,
			ry = 0,
			rz = -118,
			x = 2127.0947,
			y = -1597.05298,
			z = 59.546463
		},
		{
			model = 1340,
			ry = 0,
			rz = -113,
			x = 2129.8044,
			y = -1598.34564,
			z = 59.546463
		},
		{
			model = 1340,
			ry = 0,
			rz = -106,
			x = 2132.6316,
			y = -1599.34717,
			z = 59.546463
		},
		{
			model = 1340,
			ry = 0,
			rz = -106,
			x = 2135.5203,
			y = -1600.1754799999999,
			z = 59.546463
		},
		{
			model = 1340,
			ry = 0,
			rz = -102,
			x = 2138.4343,
			y = -1600.90222,
			z = 59.546463
		},
		{
			model = 1340,
			ry = 0,
			rz = -99,
			x = 2141.3879,
			y = -1601.44983,
			z = 59.546463
		},
		{
			model = 1340,
			ry = 0,
			rz = -94,
			x = 2144.3708,
			y = -1601.7898599999999,
			z = 59.546463
		},
		{
			model = 1340,
			ry = 0,
			rz = -94,
			x = 2147.3684,
			y = -1601.99945,
			z = 59.546463
		},
		{
			model = 1340,
			ry = 0,
			rz = -94,
			x = 2150.366,
			y = -1602.20905,
			z = 59.566536
		},
		{
			model = 1340,
			ry = 0,
			rz = -88,
			x = 2153.3662,
			y = -1602.2616600000001,
			z = 59.59568
		},
		{
			model = 1340,
			ry = 0,
			rz = -81,
			x = 2156.3518,
			y = -1601.97443,
			z = 59.582954
		},
		{
			model = 1340,
			ry = 0,
			rz = -69,
			x = 2159.2388,
			y = -1601.20148,
			z = 59.591431
		},
		{
			model = 1340,
			ry = 0,
			rz = -69,
			x = 2162.0442,
			y = -1600.12457,
			z = 59.543144
		},
		{
			model = 1340,
			ry = 0,
			rz = -69,
			x = 2164.8496,
			y = -1599.04767,
			z = 59.506027
		},
		{
			model = 1340,
			ry = 0,
			rz = -69,
			x = 2167.655,
			y = -1597.9707600000002,
			z = 59.520214
		},
		{
			model = 1340,
			ry = 0,
			rz = -69,
			x = 2170.4604,
			y = -1596.8938600000001,
			z = 59.548206
		},
		{
			model = 1340,
			ry = 0,
			rz = -62,
			x = 2173.1899,
			y = -1595.65027,
			z = 59.546066
		},
		{
			model = 1340,
			ry = 0,
			rz = -61,
			x = 2175.8308,
			y = -1594.21649,
			z = 59.544724
		},
		{
			model = 1340,
			ry = 0,
			rz = -61,
			x = 2178.4592,
			y = -1592.75964,
			z = 59.545246
		},
		{
			model = 1340,
			ry = 180,
			rz = -85,
			x = 2148.9446,
			y = -1584.32959,
			z = 62.546463
		},
		{
			model = 1340,
			ry = 180,
			rz = -83,
			x = 2151.9326,
			y = -1584.0156200000001,
			z = 62.546463
		},
		{
			model = 1340,
			ry = 180,
			rz = -82,
			x = 2154.9119,
			y = -1583.62347,
			z = 62.546463
		},
		{
			model = 1340,
			ry = 180,
			rz = -77,
			x = 2157.8638,
			y = -1583.0765999999999,
			z = 62.546463
		},
		{
			model = 1340,
			ry = 180,
			rz = -70,
			x = 2160.7395,
			y = -1582.22504,
			z = 62.546463
		},
		{
			model = 1340,
			ry = 180,
			rz = -64,
			x = 2163.502,
			y = -1581.0527299999999,
			z = 62.546463
		},
		{
			model = 1340,
			ry = 180,
			rz = -58,
			x = 2166.1267,
			y = -1579.59814,
			z = 62.546463
		},
		{
			model = 1340,
			ry = 180,
			rz = -52,
			x = 2168.5852,
			y = -1577.87714,
			z = 62.546463
		},
		{
			model = 1340,
			ry = 180,
			rz = -48,
			x = 2170.886,
			y = -1575.94684,
			z = 62.546463
		},
		{
			model = 1340,
			ry = 180,
			rz = -45,
			x = 2173.0649,
			y = -1573.87915,
			z = 62.546463
		},
		{
			model = 1340,
			ry = 180,
			rz = -29,
			x = 2286.7908,
			y = -1254.18448,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 180,
			rz = -23,
			x = 2288.1067,
			y = -1251.4874,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 180,
			rz = -21,
			x = 2289.2324,
			y = -1248.7016899999999,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 180,
			rz = -21,
			x = 2290.3093,
			y = -1245.8962999999999,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 180,
			rz = -21,
			x = 2291.3862,
			y = -1243.09091,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 180,
			rz = -21,
			x = 2292.4631,
			y = -1240.28552,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 180,
			rz = -21,
			x = 2293.54,
			y = -1237.48013,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 180,
			rz = -16,
			x = 2294.4929,
			y = -1234.63321,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 0,
			rz = -10,
			x = 2301.1987,
			y = -1268.70181,
			z = 59.513802
		},
		{
			model = 1340,
			ry = 0,
			rz = -10,
			x = 2301.7205,
			y = -1265.74246,
			z = 59.549194
		},
		{
			model = 1340,
			ry = 0,
			rz = -15,
			x = 2302.3699,
			y = -1262.81143,
			z = 59.549141
		},
		{
			model = 1340,
			ry = 0,
			rz = -15,
			x = 2303.1475,
			y = -1259.90884,
			z = 59.544876
		},
		{
			model = 1340,
			ry = 0,
			rz = -18,
			x = 2304.0005,
			y = -1257.02856,
			z = 59.544876
		},
		{
			model = 1340,
			ry = 0,
			rz = -23,
			x = 2305.0518,
			y = -1254.21646,
			z = 59.554771
		},
		{
			model = 1340,
			ry = 0,
			rz = -23,
			x = 2306.2261,
			y = -1251.45035,
			z = 59.584484
		},
		{
			model = 1340,
			ry = 0,
			rz = -23,
			x = 2307.4004,
			y = -1248.68423,
			z = 59.605392
		},
		{
			model = 1340,
			ry = 0,
			rz = -23,
			x = 2308.5747,
			y = -1245.91812,
			z = 59.580029
		},
		{
			model = 1340,
			ry = 0,
			rz = -23,
			x = 2309.749,
			y = -1243.15201,
			z = 59.562172
		},
		{
			model = 1340,
			ry = 0,
			rz = -23,
			x = 2310.9233,
			y = -1240.38589,
			z = 59.549141
		},
		{
			model = 1340,
			ry = 0,
			rz = -23,
			x = 2312.0977,
			y = -1237.61978,
			z = 59.549141
		},
		{
			model = 1340,
			ry = 0,
			rz = -25,
			x = 2313.3198,
			y = -1234.87497,
			z = 59.549141
		},
		{
			model = 1340,
			ry = 0,
			rz = -25,
			x = 2314.5898,
			y = -1232.15152,
			z = 59.548042
		},
		{
			model = 1340,
			ry = 0,
			rz = -25,
			x = 2315.8599,
			y = -1229.42807,
			z = 59.526115
		},
		{
			model = 1340,
			ry = 0,
			rz = -28,
			x = 2317.2,
			y = -1226.73965,
			z = 59.496159
		},
		{
			model = 1340,
			ry = 0,
			rz = -10,
			x = 2336.0154,
			y = -1173.95325,
			z = 59.5284
		},
		{
			model = 1340,
			ry = 0,
			rz = -11,
			x = 2336.5627,
			y = -1170.99866,
			z = 59.549229
		},
		{
			model = 1340,
			ry = 0,
			rz = -11,
			x = 2337.136,
			y = -1168.0488599999999,
			z = 59.544586
		},
		{
			model = 1340,
			ry = 0,
			rz = -14,
			x = 2337.7859,
			y = -1165.11606,
			z = 59.544586
		},
		{
			model = 1340,
			ry = 0,
			rz = -19,
			x = 2338.6382,
			y = -1162.23749,
			z = 59.544586
		},
		{
			model = 1340,
			ry = 0,
			rz = -19,
			x = 2339.6165,
			y = -1159.3962099999999,
			z = 59.544586
		},
		{
			model = 1340,
			ry = 0,
			rz = -19,
			x = 2340.5947,
			y = -1156.55493,
			z = 59.544586
		},
		{
			model = 1340,
			ry = 0,
			rz = -19,
			x = 2341.573,
			y = -1153.71365,
			z = 59.544586
		},
		{
			model = 1340,
			ry = 0,
			rz = -19,
			x = 2342.5513,
			y = -1150.87238,
			z = 59.544586
		},
		{
			model = 1340,
			ry = 0,
			rz = -19,
			x = 2343.5295,
			y = -1148.0311,
			z = 59.549141
		},
		{
			model = 1340,
			ry = 0,
			rz = -19,
			x = 2344.5078,
			y = -1145.18982,
			z = 59.549141
		},
		{
			model = 1340,
			ry = 0,
			rz = -19,
			x = 2345.4861,
			y = -1142.34854,
			z = 59.549141
		},
		{
			model = 1340,
			ry = 0,
			rz = -19,
			x = 2346.4644,
			y = -1139.5072599999999,
			z = 59.549141
		},
		{
			model = 1340,
			ry = 0,
			rz = -27,
			x = 2347.6353,
			y = -1136.74774,
			z = 59.549141
		},
		{
			model = 1340,
			ry = 0,
			rz = -27,
			x = 2348.9995,
			y = -1134.07025,
			z = 59.564766
		},
		{
			model = 1340,
			ry = 0,
			rz = -27,
			x = 2350.3638,
			y = -1131.39276,
			z = 59.5471
		},
		{
			model = 1340,
			ry = 180,
			rz = -27,
			x = 2321.8037,
			y = -1159.21799,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 180,
			rz = -21,
			x = 2323.0247,
			y = -1156.47665,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 180,
			rz = -21,
			x = 2324.1016,
			y = -1153.67126,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 180,
			rz = -16,
			x = 2325.0544,
			y = -1150.8243400000001,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 180,
			rz = -15,
			x = 2325.8574,
			y = -1147.92877,
			z = 62.549141
		},
		{
			model = 1340,
			ry = 180,
			rz = -13,
			x = 2326.5842,
			y = -1145.01352,
			z = 62.747711
		},
		{
			model = 1340,
			ry = 180,
			rz = -13,
			x = 2327.2603,
			y = -1142.08554,
			z = 62.744453
		},
		{
			model = 1340,
			ry = 0,
			rz = 22,
			x = 2398.5938,
			y = -876.709023,
			z = 59.541973
		},
		{
			model = 1340,
			ry = 0,
			rz = 22,
			x = 2397.468,
			y = -873.922835,
			z = 59.545349
		},
		{
			model = 1340,
			ry = 0,
			rz = 3,
			x = 2396.8257,
			y = -871.02948,
			z = 59.545349
		},
		{
			model = 1340,
			ry = 0,
			rz = 6,
			x = 2396.5901,
			y = -868.0347595,
			z = 59.545349
		},
		{
			model = 1340,
			ry = 0,
			rz = 8,
			x = 2396.2241,
			y = -865.0526018,
			z = 59.545349
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2395.7029,
			y = -862.0950267,
			z = 59.545349
		},
		{
			model = 1340,
			ry = 0,
			rz = 10,
			x = 2395.1294,
			y = -859.14570296,
			z = 59.545349
		},
		{
			model = 1340,
			ry = 0,
			rz = 10,
			x = 2394.6077,
			y = -856.1863556,
			z = 59.545349
		},
		{
			model = 1340,
			ry = 0,
			rz = 10,
			x = 2394.0859,
			y = -853.2270083,
			z = 59.50576
		},
		{
			model = 1340,
			ry = 0,
			rz = 10,
			x = 2393.5642,
			y = -850.2676611,
			z = 59.434666
		},
		{
			model = 1340,
			ry = 0,
			rz = 15,
			x = 2392.9148,
			y = -847.336637,
			z = 59.434399
		},
		{
			model = 1340,
			ry = 0,
			rz = 15,
			x = 2392.1372,
			y = -844.43403,
			z = 59.466614
		},
		{
			model = 1340,
			ry = 0,
			rz = 15,
			x = 2391.3596,
			y = -841.531422,
			z = 59.495655
		},
		{
			model = 1340,
			ry = 0,
			rz = 15,
			x = 2390.582,
			y = -838.628815,
			z = 59.527718
		},
		{
			model = 1340,
			ry = 0,
			rz = 15,
			x = 2389.8044,
			y = -835.726208,
			z = 59.557873
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2389.1033,
			y = -832.805267,
			z = 59.545349
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2388.4785,
			y = -829.865932,
			z = 59.545349
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2387.8538,
			y = -826.926598,
			z = 59.545349
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2387.229,
			y = -823.987267,
			z = 59.576599
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2386.6042,
			y = -821.047935,
			z = 59.545349
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2385.9795,
			y = -818.108604,
			z = 59.538086
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2385.3547,
			y = -815.169273,
			z = 59.539124
		},
		{
			model = 1340,
			ry = 0,
			rz = 25,
			x = 2365.1611,
			y = -747.18069,
			z = 59.539207
		},
		{
			model = 1340,
			ry = 0,
			rz = 25,
			x = 2363.8911,
			y = -744.45724,
			z = 59.543362
		},
		{
			model = 1340,
			ry = 0,
			rz = 16,
			x = 2362.8416,
			y = -741.65136,
			z = 59.574612
		},
		{
			model = 1340,
			ry = 0,
			rz = 16,
			x = 2362.0132,
			y = -738.76276,
			z = 59.543362
		},
		{
			model = 1340,
			ry = 0,
			rz = 16,
			x = 2361.1848,
			y = -735.87417,
			z = 59.543362
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2360.4583,
			y = -732.96024,
			z = 59.543362
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2359.8335,
			y = -730.0209,
			z = 59.543362
		},
		{
			model = 1340,
			ry = 0,
			rz = 4,
			x = 2359.4158,
			y = -727.0524399999999,
			z = 59.543362
		},
		{
			model = 1340,
			ry = 0,
			rz = 4,
			x = 2359.2061,
			y = -724.05476,
			z = 59.543362
		},
		{
			model = 1340,
			ry = 0,
			rz = 4,
			x = 2358.9963,
			y = -721.05708,
			z = 59.53727
		},
		{
			model = 1340,
			ry = 0,
			rz = 4,
			x = 2358.7866,
			y = -718.0594,
			z = 59.53875
		},
		{
			model = 1340,
			ry = 0,
			rz = 30,
			x = 2336.696,
			y = -648.07504,
			z = 59.542427
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2335.2163,
			y = -645.45973,
			z = 59.452969
		},
		{
			model = 1340,
			ry = 0,
			rz = 25,
			x = 2333.8525,
			y = -642.78397,
			z = 59.403461
		},
		{
			model = 1340,
			ry = 0,
			rz = 25,
			x = 2332.5825,
			y = -640.0605,
			z = 59.4394
		},
		{
			model = 1340,
			ry = 0,
			rz = 25,
			x = 2331.3125,
			y = -637.33704,
			z = 59.4809
		},
		{
			model = 1340,
			ry = 0,
			rz = 25,
			x = 2330.0425,
			y = -634.61357,
			z = 59.460331
		},
		{
			model = 1340,
			ry = 0,
			rz = 27,
			x = 2328.7256,
			y = -631.91306,
			z = 59.44371
		},
		{
			model = 1340,
			ry = 0,
			rz = 27,
			x = 2327.3613,
			y = -629.23558,
			z = 59.351799
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2325.9507,
			y = -626.58269,
			z = 59.556465
		},
		{
			model = 1340,
			ry = 0,
			rz = 20,
			x = 2324.708,
			y = -623.85684,
			z = 59.578163
		},
		{
			model = 1340,
			ry = 0,
			rz = 39,
			x = 2145.4773,
			y = -340.55994,
			z = 59.547813
		},
		{
			model = 1340,
			ry = 0,
			rz = 39,
			x = 2143.5862,
			y = -338.22461,
			z = 59.548264
		},
		{
			model = 1340,
			ry = 0,
			rz = 26,
			x = 2141.9817,
			y = -335.70678999999996,
			z = 59.548264
		},
		{
			model = 1340,
			ry = 0,
			rz = 26,
			x = 2140.6646,
			y = -333.00591999999995,
			z = 59.548264
		},
		{
			model = 1340,
			ry = 0,
			rz = 23,
			x = 2139.4187,
			y = -330.27252,
			z = 59.548264
		},
		{
			model = 1340,
			ry = 0,
			rz = 23,
			x = 2138.2444,
			y = -327.50640999999996,
			z = 59.548264
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2137.3445,
			y = -324.65381,
			z = 59.548264
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2136.7197,
			y = -321.71448,
			z = 59.548264
		},
		{
			model = 1340,
			ry = 0,
			rz = 12,
			x = 2136.095,
			y = -318.77515000000005,
			z = 59.578461
		},
		{
			model = 1340,
			ry = 0,
			rz = 38,
			x = 2112.8088,
			y = -270.03186000000005,
			z = 59.532806
		},
		{
			model = 1340,
			ry = 0,
			rz = 38,
			x = 2110.9587,
			y = -267.66387999999995,
			z = 59.543098
		},
		{
			model = 1340,
			ry = 0,
			rz = 38,
			x = 2109.1086,
			y = -265.29589999999996,
			z = 59.544788
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2107.4548,
			y = -262.79796999999996,
			z = 59.544788
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2105.9978,
			y = -260.16974000000005,
			z = 59.544788
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2104.5408,
			y = -257.54150000000004,
			z = 59.544788
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2103.0837,
			y = -254.91327,
			z = 59.544788
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2101.6267,
			y = -252.28503,
			z = 59.544788
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2100.1697,
			y = -249.65679999999998,
			z = 59.544788
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2098.7126,
			y = -247.02855999999997,
			z = 59.544788
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2097.2556,
			y = -244.40033000000005,
			z = 59.544788
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2095.7986,
			y = -241.77209000000005,
			z = 59.543098
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2094.3416,
			y = -239.14386000000002,
			z = 59.543098
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2092.8845,
			y = -236.51562,
			z = 59.543098
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2091.4275,
			y = -233.88738999999998,
			z = 59.543098
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2089.9705,
			y = -231.25915999999995,
			z = 59.543098
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2088.5134,
			y = -228.63091999999995,
			z = 59.554283
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2087.0564,
			y = -226.00269000000003,
			z = 59.548405
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2085.5994,
			y = -223.37445000000002,
			z = 59.54826
		},
		{
			model = 1340,
			ry = 0,
			rz = 29,
			x = 2084.1423,
			y = -220.74622,
			z = 59.548111
		},
		{
			model = 1340,
			ry = 180,
			rz = 29,
			x = 2091.467,
			y = -268.99614999999994,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = 29,
			x = 2090.01,
			y = -266.36792,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = 29,
			x = 2088.553,
			y = -263.73969,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = 29,
			x = 2087.0959,
			y = -261.11145,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = 29,
			x = 2085.6389,
			y = -258.48321999999996,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = 29,
			x = 2084.1819,
			y = -255.85497999999995,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = 29,
			x = 2082.7249,
			y = -253.22675000000004,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = 39,
			x = 2081.051,
			y = -250.74474999999995,
			z = 62.746223
		},
		{
			model = 1340,
			ry = 0,
			rz = -50,
			x = 1973.9924,
			y = -173.3678,
			z = 59.550915
		},
		{
			model = 1340,
			ry = 0,
			rz = -61,
			x = 1971.5276,
			y = -175.06244000000004,
			z = 59.550976
		},
		{
			model = 1340,
			ry = 0,
			rz = -61,
			x = 1968.8994,
			y = -176.51928999999996,
			z = 59.551781
		},
		{
			model = 1340,
			ry = 0,
			rz = -61,
			x = 1966.2712,
			y = -177.97614,
			z = 59.59269
		},
		{
			model = 1340,
			ry = 0,
			rz = -57,
			x = 1963.6969,
			y = -179.52270999999996,
			z = 59.649952
		},
		{
			model = 1340,
			ry = 0,
			rz = -56,
			x = 1961.1912,
			y = -181.18120999999996,
			z = 59.610775
		},
		{
			model = 1340,
			ry = 0,
			rz = -57,
			x = 1958.6854,
			y = -182.83978000000002,
			z = 59.563759
		},
		{
			model = 1340,
			ry = 0,
			rz = -57,
			x = 1956.1652,
			y = -184.47644000000003,
			z = 59.559288
		},
		{
			model = 1340,
			ry = 0,
			rz = -57,
			x = 1953.6449,
			y = -186.11310000000003,
			z = 59.530319
		},
		{
			model = 1340,
			ry = 0,
			rz = -54,
			x = 1951.1692,
			y = -187.81444999999997,
			z = 59.519432
		},
		{
			model = 1340,
			ry = 0,
			rz = -54,
			x = 1948.7382,
			y = -189.58074999999997,
			z = 59.537941
		},
		{
			model = 1340,
			ry = 0,
			rz = -54,
			x = 1946.3071,
			y = -191.34704999999997,
			z = 59.550377
		},
		{
			model = 1340,
			ry = 0,
			rz = -54,
			x = 1943.8761,
			y = -193.11334,
			z = 59.550377
		},
		{
			model = 1340,
			ry = 0,
			rz = -54,
			x = 1941.4451,
			y = -194.87964,
			z = 59.550377
		},
		{
			model = 1340,
			ry = 0,
			rz = -59,
			x = 1938.9418,
			y = -196.53687000000002,
			z = 59.550377
		},
		{
			model = 1340,
			ry = 0,
			rz = -59,
			x = 1936.366,
			y = -198.08459000000005,
			z = 59.550377
		},
		{
			model = 1340,
			ry = 0,
			rz = -59,
			x = 1933.7902,
			y = -199.63232000000005,
			z = 59.550377
		},
		{
			model = 1340,
			ry = 0,
			rz = -59,
			x = 1931.2144,
			y = -201.18005000000005,
			z = 59.550377
		},
		{
			model = 1340,
			ry = 0,
			rz = -59,
			x = 1928.6385,
			y = -202.72778000000005,
			z = 59.545319
		},
		{
			model = 1340,
			ry = 0,
			rz = -63,
			x = 1926.012,
			y = -204.1839,
			z = 59.542023
		},
		{
			model = 1340,
			ry = 180,
			rz = -73,
			x = 1986.9758,
			y = -188.11865,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = -70,
			x = 1984.1271,
			y = -189.07165999999995,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = -70,
			x = 1981.3033,
			y = -190.09942999999998,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = -67,
			x = 1978.5084,
			y = -191.20032000000003,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = -64,
			x = 1975.7749,
			y = -192.44592,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = -62,
			x = 1973.0978,
			y = -193.80988000000002,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = -58,
			x = 1970.4968,
			y = -195.31128,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = -55,
			x = 1967.9917,
			y = -196.96918000000005,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = -57,
			x = 1965.5009,
			y = -198.64935000000003,
			z = 62.543098
		},
		{
			model = 1340,
			ry = 180,
			rz = -57,
			x = 1962.9806,
			y = -200.28601000000003,
			z = 62.550377
		},
		{
			model = 1340,
			ry = 180,
			rz = -57,
			x = 1960.4603,
			y = -201.92267000000004,
			z = 62.550377
		},
		{
			model = 1340,
			ry = 180,
			rz = -57,
			x = 1957.9401,
			y = -203.55933000000005,
			z = 62.545029
		},
		{
			model = 1340,
			ry = 180,
			rz = -53,
			x = 1955.4799,
			y = -205.28174,
			z = 62.540764
		},
		{
			model = 1340,
			ry = 180,
			rz = -1,
			x = 1719.1196,
			y = -588.82285,
			z = 62.545963
		},
		{
			model = 1340,
			ry = 180,
			rz = -1,
			x = 1719.0673,
			y = -591.8273899999999,
			z = 62.545963
		},
		{
			model = 1340,
			ry = 180,
			rz = -1,
			x = 1719.0149,
			y = -594.83194,
			z = 62.545963
		},
		{
			model = 1340,
			ry = 180,
			rz = -1,
			x = 1718.9625,
			y = -597.83649,
			z = 62.545963
		},
		{
			model = 1340,
			ry = 180,
			rz = -1,
			x = 1718.9102,
			y = -600.84103,
			z = 62.545963
		},
		{
			model = 1340,
			ry = 180,
			rz = -1,
			x = 1718.8578,
			y = -603.8455799999999,
			z = 62.545963
		},
		{
			model = 1340,
			ry = 180,
			rz = -1,
			x = 1718.8054,
			y = -606.85013,
			z = 62.545963
		},
		{
			model = 1340,
			ry = 180,
			rz = -1,
			x = 1718.7531,
			y = -609.85468,
			z = 62.749088
		},
		{
			model = 1340,
			ry = 0,
			rz = 11,
			x = 1701.1427,
			y = -580.5312799999999,
			z = 59.503242
		},
		{
			model = 1340,
			ry = 0,
			rz = 11,
			x = 1701.7161,
			y = -583.48108,
			z = 59.545963
		},
		{
			model = 1340,
			ry = 0,
			rz = 4,
			x = 1702.1078,
			y = -586.45477,
			z = 59.545963
		},
		{
			model = 1340,
			ry = 0,
			rz = 0,
			x = 1702.2128,
			y = -589.45612,
			z = 59.545963
		},
		{
			model = 1340,
			ry = 0,
			rz = 0,
			x = 1702.2128,
			y = -592.4611199999999,
			z = 59.548866
		},
		{
			model = 1340,
			ry = 0,
			rz = 0,
			x = 1702.2128,
			y = -595.46613,
			z = 59.559723
		},
		{
			model = 1340,
			ry = 0,
			rz = 0,
			x = 1702.2128,
			y = -598.47113,
			z = 59.588013
		},
		{
			model = 1340,
			ry = 0,
			rz = 0,
			x = 1702.2128,
			y = -601.47614,
			z = 59.560558
		},
		{
			model = 1340,
			ry = 0,
			rz = 0,
			x = 1702.2128,
			y = -604.48114,
			z = 59.545963
		},
		{
			model = 1340,
			ry = 0,
			rz = 0,
			x = 1702.2128,
			y = -607.48615,
			z = 59.545963
		},
		{
			model = 1340,
			ry = 0,
			rz = 0,
			x = 1702.2128,
			y = -610.4911500000001,
			z = 59.552883
		},
		{
			model = 1340,
			ry = 0,
			rz = 0,
			x = 1702.2128,
			y = -613.49615,
			z = 59.536167
		},
		{
			model = 1340,
			ry = 0,
			rz = -5,
			x = 1702.082,
			y = -616.49545,
			z = 59.545963
		},
		{
			model = 1340,
			ry = 0,
			rz = -5,
			x = 1701.8201,
			y = -619.48901,
			z = 59.545963
		},
		{
			model = 1340,
			ry = 0,
			rz = -5,
			x = 1701.5581,
			y = -622.48257,
			z = 59.545963
		},
		{
			model = 1340,
			ry = 0,
			rz = -5,
			x = 1701.2961,
			y = -625.47614,
			z = 59.545963
		},
		{
			model = 1340,
			ry = 0,
			rz = -5,
			x = 1701.0342,
			y = -628.4697,
			z = 59.545963
		},
		{
			model = 1340,
			ry = 0,
			rz = -10,
			x = 1700.6425,
			y = -631.44618,
			z = 59.507622
		},
		{
			model = 1340,
			ry = 0,
			rz = 40,
			x = 1795.7699,
			y = -991.8709699999999,
			z = 59.512016
		},
		{
			model = 1340,
			ry = 0,
			rz = 30,
			x = 1797.4873,
			y = -994.32291,
			z = 59.545612
		},
		{
			model = 1340,
			ry = 0,
			rz = 26,
			x = 1798.8973,
			y = -996.97447,
			z = 59.545612
		},
		{
			model = 1340,
			ry = 0,
			rz = 23,
			x = 1800.1432,
			y = -999.7079200000001,
			z = 59.539036
		},
		{
			model = 1340,
			ry = 0,
			rz = 24,
			x = 1801.3413,
			y = -1002.4635900000001,
			z = 59.545612
		},
		{
			model = 1340,
			ry = 0,
			rz = 23,
			x = 1802.5396,
			y = -1005.21924,
			z = 59.548824
		},
		{
			model = 1340,
			ry = 0,
			rz = 23,
			x = 1803.7136,
			y = -1007.98535,
			z = 59.546478
		},
		{
			model = 1340,
			ry = 0,
			rz = 20,
			x = 1804.8147,
			y = -1010.78026,
			z = 59.545162
		},
		{
			model = 1340,
			ry = 0,
			rz = 20,
			x = 1805.8425,
			y = -1013.60403,
			z = 59.519138
		},
		{
			model = 1340,
			ry = 0,
			rz = 20,
			x = 1806.8704,
			y = -1016.42781,
			z = 59.502914
		},
		{
			model = 1340,
			ry = 0,
			rz = 20,
			x = 1807.8982,
			y = -1019.25159,
			z = 59.460331
		},
		{
			model = 1340,
			ry = 0,
			rz = 20,
			x = 1808.926,
			y = -1022.07536,
			z = 59.468788
		},
		{
			model = 1340,
			ry = 0,
			rz = 20,
			x = 1809.9539,
			y = -1024.89914,
			z = 59.508774
		},
		{
			model = 1340,
			ry = 0,
			rz = 21,
			x = 1811.0062,
			y = -1027.71375,
			z = 59.542149
		},
		{
			model = 1340,
			ry = 0,
			rz = 21,
			x = 1812.0831,
			y = -1030.51917,
			z = 59.542149
		},
		{
			model = 1340,
			ry = 0,
			rz = 21,
			x = 1813.16,
			y = -1033.32458,
			z = 59.542149
		},
		{
			model = 1340,
			ry = 0,
			rz = 21,
			x = 1814.2369,
			y = -1036.13,
			z = 59.542149
		},
		{
			model = 1340,
			ry = 0,
			rz = 21,
			x = 1815.3138,
			y = -1038.93542,
			z = 59.542149
		},
		{
			model = 1340,
			ry = 0,
			rz = 17,
			x = 1816.2917,
			y = -1041.77493,
			z = 59.542149
		},
		{
			model = 1340,
			ry = 0,
			rz = 15,
			x = 1817.12,
			y = -1044.66306,
			z = 59.542149
		},
		{
			model = 1340,
			ry = 0,
			rz = 13,
			x = 1817.8469,
			y = -1047.57832,
			z = 59.534901
		},
		{
			model = 1340,
			ry = 0,
			rz = 13,
			x = 1818.5228,
			y = -1050.5063,
			z = 59.45327
		},
		{
			model = 1340,
			ry = 180,
			rz = 20,
			x = 1816.2147,
			y = -994.67477,
			z = 62.545612
		},
		{
			model = 1340,
			ry = 180,
			rz = 20,
			x = 1817.2426,
			y = -997.49855,
			z = 62.545612
		},
		{
			model = 1340,
			ry = 180,
			rz = 23,
			x = 1818.3434,
			y = -1000.29353,
			z = 62.545612
		},
		{
			model = 1340,
			ry = 180,
			rz = 23,
			x = 1819.5175,
			y = -1003.05965,
			z = 62.545612
		},
		{
			model = 1340,
			ry = 180,
			rz = 20,
			x = 1820.6185,
			y = -1005.85455,
			z = 62.545612
		},
		{
			model = 1340,
			ry = 180,
			rz = 20,
			x = 1821.6464,
			y = -1008.67833,
			z = 62.545612
		},
		{
			model = 1340,
			ry = 180,
			rz = 21,
			x = 1822.6987,
			y = -1011.49294,
			z = 62.545612
		},
		{
			model = 1340,
			ry = 180,
			rz = 21,
			x = 1823.7756,
			y = -1014.29836,
			z = 62.545612
		},
		{
			model = 1340,
			ry = 180,
			rz = 21,
			x = 1824.8525,
			y = -1017.10378,
			z = 62.545612
		},
		{
			model = 1340,
			ry = 180,
			rz = 21,
			x = 1825.9294,
			y = -1019.90919,
			z = 62.545612
		},
		{
			model = 1340,
			ry = 180,
			rz = 21,
			x = 1827.0063,
			y = -1022.71461,
			z = 62.545612
		},
		{
			model = 1340,
			ry = 180,
			rz = 21,
			x = 1828.0833,
			y = -1025.52003,
			z = 62.542149
		},
		{
			model = 1340,
			ry = 180,
			rz = 21,
			x = 1829.1602,
			y = -1028.32545,
			z = 62.542149
		},
		{
			model = 1340,
			ry = 180,
			rz = 23,
			x = 1830.2855,
			y = -1031.11125,
			z = 62.542149
		},
		{
			model = 1340,
			ry = 180,
			rz = 24,
			x = 1831.4836,
			y = -1033.86693,
			z = 62.744137
		},
		{
			model = 1340,
			ry = 180,
			rz = 40,
			x = 1833.0601,
			y = -1036.39088,
			z = 62.745274
		},
		{
			model = 1340,
			ry = 0,
			rz = 85,
			x = 2013.630,
			y = -167.750,
			z = 59.5
		},
		{
			model = 1340,
			ry = 0,
			rz = 82,
			x = 2016.620,
			y = -168.0,
			z = 59.5
		},
		{
			model = 1340,
			ry = 0,
			rz = 80,
			x = 2019.610,
			y = -168.5,
			z = 59.5
		},
		{
			model = 1340,
			ry = 0,
			rz = 77,
			x = 2022.550,
			y = -169.1,
			z = 59.5
		},
		{
			model = 1340,
			ry = 0,
			rz = 74,
			x = 2025.460,
			y = -169.9,
			z = 59.5
		},
		{
			model = 1340,
			ry = 0,
			rz = 67,
			x = 2028.300,
			y = -170.9,
			z = 59.5
		},
		{
			model = 1340,
			ry = 0,
			rz = 65,
			x = 2031.0,
			y = -172.1,
			z = 59.5
		},
	}
}

-- Тестирование
if not localPlayer and SERVER_NUMBER > 100 then
    addCommandHandler( "halloween_race", function( player )
        iprint( "halloween_race count 2" )
        REGISTERED_EVENTS[ event_id ].count_players = 2
    end )
end

