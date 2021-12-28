local event_id = "mayevent_fight_hunters"

local CONST_TEXT_TO_START = { "Уничтожай врага", "Используй тактику", "Побеждай!", }

local CONST_TIME_IN_MS_TO_TEXT_START = 1500

local CONST_TIME_TO_START_EVENT = 3
local CONST_TIME_TO_EVENT_END = 5 * 60
local CONST_TIME_TO_PLAYER_RESPAWN = 10
local CONST_TIME_TO_PLAYER_GM = 2
local CONST_TIME_TO_ZONE_EXIT = 10

local CONST_VEHICLE_MODEL = 425
local CONST_VEHICLE_HEALTH = 500

local CONST_ROCKET_DAMAGE = 300
local CONST_ROCKET_AMMO = 1
local CONST_ROCKET_TIME_TO_FIRE = 1
local CONST_ROCKET_TIME_TO_RELOAD = 5
local CONST_ROCKET_DISTANCE_EFFECT = 5

local CONST_MINIGUN_DAMAGE = 5
local CONST_MINIGUN_AMMO = 150
local CONST_MINIGUN_FIRE_TIME_IN_MS = 70
local CONST_MINIGUN_TIME_TO_RELOAD = 10
local CONST_MINIGUN_DISTANCE_EFFECT = 10

local CONST_SPAWN_POSITIONS = {
	Vector3( 602.3207, -2273.8193, 21.9 );
	Vector3( 328.4069, -2454.6108, 21.9 );
	Vector3( 134.9834, -2394.8945, 21.9 );
	Vector3( 30.3711,  -2279.3508, 21.9 );
	Vector3( 154.7552, -2136.0971, 21.9 );
	Vector3( 375.9400, -2142.2290, 21.9 );
}

local CONST_HIDE_HUD_BLOCKS = { "main", "notifications", "daily_quest", "factionradio", "cases_discounts", "quest", "ksusha", "wanted", "nodamage", "weapons", "offers", "offer_ingame_draw", "vehicle", "7cases", }

local CONST_RESPAWN_CAMERA_MAXTRIX = { 426.57516479492, -2309.4384765625, 283.19784545898, 426.62408447266, -2305.6083984375, 183.27122497559, 0, 70 }
local CONST_RESPAWN_PLAYER_TMP_POSITION = Vector3( 404.3743, -2219.6928, 2003.0900 )

local CONST_GAME_ZONE = {
	684, -2573,
	-16,  -2573,
	-25, -2075,
	684, -2080,
	684, -2573,
}

local CLIENT_VAR_wait_respawn_tmr = false
local CLIENT_VAR_respawn_gm_tick = 0

local CLIENT_VAR_tick_rocket_reload = 0
local CLIENT_VAR_tick_rocket_fire_timeout = 0
local CLIENT_VAR_rocket_ammo = 0

local CLIENT_VAR_tick_minigun_reload = 0
local CLIENT_VAR_tick_rocket_minigun_timeout = 0
local CLIENT_VAR_minigun_ammo = 0

local CLIENT_VAR_exit_zone_texture = nil
local CLIENT_VAR_game_zone_exit_tmr = false
local CLIENT_VAR_exit_zone_colshape = nil
local CLIENT_VAR_check_veh_respawn_tmr = nil

local CLIENT_VAR_disabled_keys = { p = true, tab = true, m = true, y = true, u = true }

local function SERVER_onPlayerPreWasted_handler(  )
	cancelEvent( )
	PlayerEndEvent( source, "Вы покинули состязание", true )
end

local function SERVER_ClientDestroyEnemyHeli_handler( self, killer )
	if not client or client == killer then return end

	local kills_count = ( killer:getData( "kills_count" ) or 0 ) + 1
	killer:setData( "kills_count", kills_count, false )

	SyncEventScoreboard( self, event_id .. "_UpdatePoint_handler", kills_count, killer )

	triggerEvent( "BP:ME:onPlayerKill", killer, event_id )
end

local function CLIENT_DestroyHeliTutorial()
	if isElement( UIe and UIe.black_bg_heli_tutorial ) then
		destroyElement( UIe.black_bg_heli_tutorial )
	end
	showCursor( false )
end

local function CLIENT_ShowHeliTutorial( state )
	if state then
		CLIENT_DestroyHeliTutorial( false )

		if fileExists( "event.heli_tutorial" ) then return end
    	local file = fileCreate( "event.heli_tutorial" )
    	fileClose( file )

		UIe.black_bg_heli_tutorial = ibCreateBackground( 0xC01D252E, nil ):ibData( "alpha", 0 ):ibAlphaTo( 255, 1500 )
			:ibTimer( function( self )
				self:ibAlphaTo( 0, 500 )
			end, 10 * 1000, 1 )
		
		UIe.bg_heli_tutorial = ibCreateImage( 0, 0, 1024, 720, "img/may_events/bg_heli_tutorial.png", UIe.black_bg_heli_tutorial ):center()
		
		local btn_ok = ibCreateButton( 437, 636, 150, 54, UIe.bg_heli_tutorial, "img/may_events/btn_ok.png", "img/may_events/btn_ok_h.png", "img/may_events/btn_ok_h.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC ):center_x()
			:ibData( "disabled", true )
			:ibData( "alpha", 128 )
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				ibClick( )

				CLIENT_DestroyHeliTutorial( false )
			end )
	
		ibCreateLabel( 0, 30, 150, 54, "5 секунд", btn_ok, 0xFFB1C6E1, nil, nil, "center", "top", ibFonts.regular_12 ):ibData( "disabled", true )
			:ibData( "count_tick", 5 )
			:ibTimer( function( self )
				local count_tick = tonumber( self:ibData( "count_tick" ) ) - 1
				self:ibData( "count_tick", count_tick )
				if count_tick > 0 then
					self:ibData( "text", count_tick .. " " .. plural( count_tick, "секунда", "секунды", "секунд" ) )
				else
					bindKey( "space", "up", CLIENT_DestroyHeliTutorial )
					self:ibData( "text", "[ПРОБЕЛ]" )
					btn_ok:ibData( "disabled", false )
					btn_ok:ibAlphaTo( 255, 250 )
				end
			end, 1000, 10 )

		showCursor( true )
	end
end

local function CLIENT_DeleteUIWeaponFightHunters( )
	if isElement( UIe.weapon_bg ) then destroyElement( UIe.weapon_bg ) end
end

local function CLIENT_CreateUIWeaponFightHunters( minigun_ammo, rocket_ammo )
	CLIENT_DeleteUIWeaponFightHunters( )

	UIe.weapon_bg = ibCreateArea( _SCREEN_X - 192, _SCREEN_Y - 371, 187, 80 )
	UIe.minigun_bg = ibCreateImage( 0, 0, 86, 80, "img/may_events/fight_hunters_minigun_bg.png", UIe.weapon_bg )
	UIe.minigun_ammo = ibCreateLabel( 0, 15, 0, 0, minigun_ammo, UIe.minigun_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_18 ):ibData( "outline", true ):center_x()

	UIe.rocket_bg = ibCreateImage( 104, 0, 86, 80, "img/may_events/fight_hunters_rocket_bg.png", UIe.weapon_bg )
end

local function CLIENT_UpdateUIWeaponFightHunters( minigun_ammo, minigun_timeout, rocket_ammo, rocket_timeout )
	if not isElement( UIe.weapon_bg ) then return end

	if minigun_ammo then UIe.minigun_ammo:ibData( "text", minigun_ammo ) end
	if minigun_timeout then
		if isElement( UIe.minigun_timeout ) then
			destroyElement( UIe.minigun_timeout )
		end

		UIe.minigun_bg:ibData( "color", ibApplyAlpha( COLOR_WHITE, 40 ) )
		UIe.minigun_ammo:ibData( "color", ibApplyAlpha( COLOR_WHITE, 40 ) )
		UIe.minigun_timeout = ibCreateLabel( 0, 0, 0, 0, minigun_timeout, UIe.minigun_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_18 )
			:center( )
			:ibData( "outline", true )
			:ibTimer( function( self )
				local count = tonumber( self:ibData( "text" ) ) - 1
				if count > 0 then
					self:ibData( "text", count )
				else
					destroyElement( self )
					UIe.minigun_bg:ibData( "color", COLOR_WHITE )
					UIe.minigun_ammo:ibData( "color", COLOR_WHITE )
				end
			end, 1000, 0 )
	end

	if rocket_timeout then
		if isElement( UIe.rocket_timeout ) then
			destroyElement( UIe.rocket_timeout )
		end

		UIe.rocket_bg:ibData( "color", ibApplyAlpha( COLOR_WHITE, 40 ) )
		UIe.rocket_timeout = ibCreateLabel( 0, 0, 0, 0, rocket_timeout, UIe.rocket_bg, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_18 )
			:center( )
			:ibData( "outline", true )
			:ibTimer( function( self )
				local count = tonumber( self:ibData( "text" ) ) - 1
				if count > 0 then
					self:ibData( "text", count )
				else
					destroyElement( self )
					UIe.rocket_bg:ibData( "color", COLOR_WHITE )
				end
			end, 1000, 0 )
	end
end

local function CLIENT_SetupVehicles( vehicles )
	for player, vehicle in pairs( vehicles ) do
		local veh_blip = createBlipAttachedTo( vehicle, 0, 1, 255, 0, 0 )
		vehicle:setData( "veh_blip", veh_blip, false )
		addEventHandler( "onClientElementDestroy", vehicle, function( )
			if isElement( veh_blip ) then destroyElement( veh_blip ) end
		end )
	end
end

local function CLIENT_StartRespawnPlayer()
	if CLIENT_VAR_wait_respawn_tmr then return end
	CLIENT_DeleteUIWeaponFightHunters( )

	local vehicle = localPlayer.vehicle
	vehicle.position = CONST_RESPAWN_PLAYER_TMP_POSITION + Vector3( (vehicle:getData("spawn_id") or 1) * 4, 0, 0 )
	vehicle.frozen = true

	CLIENT_VAR_wait_respawn_tmr = setTimer( function( )
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

		vehicle.position = random_point
		vehicle.rotation = Vector3( 0, 0, math.random( 0, 360 ) )
		vehicle.health = 1000
		vehicle.frozen = false

		setCameraTarget( localPlayer )

		CLIENT_VAR_tick_rocket_reload = 0
		CLIENT_VAR_tick_rocket_fire_timeout = 0
		CLIENT_VAR_rocket_ammo = CONST_ROCKET_AMMO

		CLIENT_VAR_tick_minigun_reload = 0
		CLIENT_VAR_minigun_ammo = CONST_MINIGUN_AMMO

		CLIENT_CreateUIWeaponFightHunters( CLIENT_VAR_minigun_ammo, CLIENT_VAR_rocket_ammo )

		CLIENT_VAR_wait_respawn_tmr = false
		CLIENT_VAR_respawn_gm_tick = getTickCount( ) + CONST_TIME_TO_PLAYER_GM * 1000

		RemoveEffects( vehicle, CONST_TIME_TO_PLAYER_GM * 1000 )
		triggerEvent( "RC:ApplyEffect", localPlayer, 2, vehicle )

		DeleteUIRespawnTimer( )
	end, CONST_TIME_TO_PLAYER_RESPAWN * 1000, 1 )

	CreateUIRespawnTimer( CONST_TIME_TO_PLAYER_RESPAWN )

	setCameraMatrix( unpack( CONST_RESPAWN_CAMERA_MAXTRIX ) )
end

local function CLIENT_onClientVehicleDamage_handler( attacker, weapon_id, loss )
	if not source then return end
	cancelEvent( )

	local tick = getTickCount()
	if not weapon_id or CLIENT_VAR_respawn_gm_tick > tick then return end

	if isElement( attacker ) and attacker.type == "vehicle" then
		attacker = attacker.controller
	end
	if not attacker or attacker == localPlayer then return end

	local damage = false
	if weapon_id == 51 then
		if (CLIENT_VAR_rocket_timeout_player_dmg[ attacker ] or 0) > tick then return false end

		damage = CONST_ROCKET_DAMAGE * ( loss / 1100 )
		CLIENT_VAR_rocket_timeout_player_dmg[ attacker ] = tick + CONST_ROCKET_TIME_TO_RELOAD * 1000 - 1000
	elseif weapon_id == 38 then
		damage = CONST_MINIGUN_DAMAGE
	end

	if damage then
		local new_health = math.max( 399, source.health - damage )
		setElementHealth( source, new_health )
		CLIENT_VAR_vehicle_health = new_health

		if isElement( attacker ) then
			CreateUIDamage( source.position, attacker.vehicle.position, source.rotation.z )
		end
	end

	if source.health <= 400 then
		CLIENT_VAR_vehicle_health = nil
		setTimer( CLIENT_StartRespawnPlayer, 50, 1 )

		if isElement( attacker ) then
			TriggerCustomServerEvent( "ClientDestroyEnemyHeli", attacker )
		end
	end
end

local function CLIENT_RaceKeyHandler( key, state )
	if CLIENT_VAR_disabled_keys[ key ] then 
		cancelEvent( )
		return
	end

	local vehicle_fire_keys = getBoundKeys( "vehicle_fire" )
	if vehicle_fire_keys[ key ] and key ~= "lshift" then
		cancelEvent()
		return
	end

	local vehicle_secondary_keys = getBoundKeys( "vehicle_secondary_fire" )
	if vehicle_secondary_keys[ key ] and key ~= "lctrl" then
		cancelEvent()
		return
	end
end

local function CLIENT_onUpdatePoint_handler( player, points, place )
	UpdateScoreboard( player, points, place )
end

local function CLIENT_ChangeFireControlState( control, state )
	toggleControl( control, state )
	setPedControlState( localPlayer, control, state )
end

local function getPositionFromElementOffset( element, v  )
	return element:getMatrix():transformPosition( v.x, v.y, v.z )
end

local function getDirectionByTwoPoints( v1, v2, mul )
	local length = v2 - v1
    local normal = length:getSquaredLength()
    return normal > 0 and length / normal * mul or Vector3()
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

	local tick = getTickCount()
	if CLIENT_VAR_start_minigun_fire_tick and tick - CLIENT_VAR_last_minigun_fire_tick > CONST_MINIGUN_FIRE_TIME_IN_MS then
		
		CLIENT_VAR_last_minigun_fire_tick = tick

		if CLIENT_VAR_minigun_ammo <= 0 then CLIENT_VAR_minigun_ammo = CONST_MINIGUN_AMMO end
		CLIENT_VAR_minigun_ammo = CLIENT_VAR_minigun_ammo - 1

		if CLIENT_VAR_minigun_ammo <= 0 then
			CLIENT_VAR_tick_minigun_reload = tick + CONST_MINIGUN_TIME_TO_RELOAD * 1000			
			CLIENT_UpdateUIWeaponFightHunters( CONST_MINIGUN_AMMO, CONST_MINIGUN_TIME_TO_RELOAD )

			CLIENT_VAR_start_minigun_fire_tick = nil
			CLIENT_ChangeFireControlState( "vehicle_secondary_fire", false )
		else
			CLIENT_UpdateUIWeaponFightHunters( CLIENT_VAR_minigun_ammo )
		end
	end

	local vehicle = localPlayer.vehicle
	if not vehicle or vehicle.model ~= CONST_VEHICLE_MODEL or CLIENT_VAR_wait_respawn_tmr then return end
	local omni01_comp_pos = Vector3( { vehicle:getComponentPosition( "Omni01" ) } )
  	local omni01_world_pos = getPositionFromElementOffset( vehicle, omni01_comp_pos )

	local static_comp_pos = Vector3( { vehicle:getComponentPosition( "static_rotor" ) } )
	local static_world_pos = getPositionFromElementOffset( vehicle, static_comp_pos ) + Vector3( 0, 0, -0.4 )
			
	local px, py = getScreenFromWorldPosition( omni01_world_pos + getDirectionByTwoPoints( omni01_world_pos, static_world_pos, 400 ), 0, false )
	if px and py then
		local sx_a, sy_a = 150, 150
		dxDrawImage( math.floor( px - sx_a / 2 ), math.floor( py - sy_a / 2 ), sx_a, sy_a, "img/may_events/tank_aim.png" )
	end
end

local function CLIENT_PlayerExitFromGameZone( element, dim )
	if not dim or element ~= localPlayer then return end

	if isTimer( CLIENT_VAR_game_zone_exit_tmr ) then
		killTimer( CLIENT_VAR_game_zone_exit_tmr )
	end

	CLIENT_VAR_game_zone_exit_tmr = setTimer( function( )
		localPlayer.health = 0
		CLIENT_VAR_game_zone_exit_tmr = false
	end, CONST_TIME_TO_ZONE_EXIT * 1000, 1 )

	CreateUIZoneExit( CONST_TIME_TO_ZONE_EXIT )
end

local function CLIENT_PlayerEnterToGameZone( element, dim )
	if not dim or element ~= localPlayer then return end

	if isTimer( CLIENT_VAR_game_zone_exit_tmr ) then
		killTimer( CLIENT_VAR_game_zone_exit_tmr )
	end

	DeleteUIZoneExit( )
end

local function CLIENT_LocalPlayerVehiclePrimaryFire( key, state )
	if not localPlayer.vehicle then return end
	if CLIENT_VAR_wait_respawn_tmr or CLIENT_VAR_tick_rocket_fire_timeout > getTickCount( ) or CLIENT_VAR_tick_rocket_reload > getTickCount() then return end

	CLIENT_VAR_tick_rocket_fire_timeout = getTickCount( ) + CONST_ROCKET_TIME_TO_FIRE * 1000

	if CLIENT_VAR_rocket_ammo <= 0 then CLIENT_VAR_rocket_ammo = CONST_ROCKET_AMMO end
	CLIENT_VAR_rocket_ammo = CLIENT_VAR_rocket_ammo - 1

	if CLIENT_VAR_rocket_ammo <= 0 then
		CLIENT_ChangeFireControlState( "vehicle_fire", true )

		CLIENT_VAR_tick_rocket_reload = getTickCount( ) + CONST_ROCKET_TIME_TO_RELOAD * 1000
		CLIENT_VAR_off_controls_primary_tmr = setTimer( CLIENT_ChangeFireControlState, 500, 1, "vehicle_fire", false )

		CLIENT_UpdateUIWeaponFightHunters( nil, nil, CONST_ROCKET_AMMO, CONST_ROCKET_TIME_TO_RELOAD )
	else
		CLIENT_ChangeFireControlState( "vehicle_fire", false )
		CLIENT_UpdateUIWeaponFightHunters( nil, nil, CLIENT_VAR_rocket_ammo )
	end
end

local function CLIENT_LocalPlayerVehicleSecondaryFire( key, state )
	if not localPlayer.vehicle then return end

	if state == "down" then
		local tick = getTickCount()
		if CLIENT_VAR_wait_respawn_tmr or CLIENT_VAR_tick_minigun_reload > tick then return end
		
		CLIENT_VAR_start_minigun_fire_tick = tick
		CLIENT_VAR_last_minigun_fire_tick = tick
		
		CLIENT_ChangeFireControlState( "vehicle_secondary_fire", true )
	else
		CLIENT_ChangeFireControlState( "vehicle_secondary_fire", false )
		CLIENT_VAR_start_minigun_fire_tick = nil
	end
end

local function CLIENT_StartCheckRespawnPositions( vehicles )
	CLIENT_VAR_check_veh_respawn_tmr = setTimer( function()
		for k, v in pairs( vehicles ) do
			if isElement( v ) then
				local blip = v:getData( "veh_blip" )
				if isElement( blip ) then
					if (v.position - CONST_RESPAWN_PLAYER_TMP_POSITION).length < 5 then
						blip:setData( "is_hide", true, false )
					else
						blip:setData( "is_hide", false, false )
					end
				end
			end
		end
	end, 1000, 0 )
end

REGISTERED_EVENTS[ event_id ] = {
	name = "Бой охотников";
	group = "may_events";
	count_players = 6;
	scoreboard_text_point = "Количество очков";

	coins_reward = {
		[ 1 ] = 44;
		[ 2 ] = 38;
		[ 3 ] = 31;
		[ 4 ] = 26;
		[ 5 ] = 21;
        [ 6 ] = 12;
	},

	Setup_S_handler = function( self )
		self.vehicles = {}

		local counter = 0
		local players = { }
		for player in pairs( self.players ) do
			player:setData( "kills_count", 0, false )

			counter = counter + 1

			local vehicle = Vehicle.CreateTemporary( CONST_VEHICLE_MODEL, CONST_SPAWN_POSITIONS[ counter ].x, CONST_SPAWN_POSITIONS[ counter ].y, CONST_SPAWN_POSITIONS[ counter ].z, 0, 0, math.random( 0, 360 ) )
			vehicle.dimension = self.dimension
			self.vehicles[ player ] = vehicle

			setTimer( function( )
				player.vehicle = vehicle
				vehicle.frozen = true
			end, 100, 1 )

			addEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler )
			table.insert( players, player )
		end

		AddCustomServerEventHandler( self, "ClientDestroyEnemyHeli", SERVER_ClientDestroyEnemyHeli_handler )
	end;

	Setup_S_delay_handler = function( self, players )
		triggerClientEvent( players, event_id .."_SetupVehicles", resourceRoot, self.vehicles )

		self.start_tmr = setTimer( function( )
			for player in pairs( self.players ) do
				if isElement( player ) and isElement( player.vehicle ) then
					player.vehicle.frozen = false
				end
			end
		end, CONST_TIME_TO_START_EVENT * 1000, 1 )

		self.end_tmr = setTimer( function( )
			for k = #self.players_point, 1, -1 do
				PlayerEndEvent( self.players_point[ k ][ 1 ], "Вы заняли ".. k .." место", _, k, true )
			end
		end, CONST_TIME_TO_EVENT_END * 1000, 1 )
	end;

	Cleanup_S_handler = function( self )
		RemoveCustomServerEventHandler( self, "ClientDestroyEnemyHeli" )
		for k, v in pairs( { self.start_tmr, self.end_tmr } ) do
			if isTimer( v ) then killTimer( v ) end
		end
	end;

	CleanupPlayer_S_handler = function( self, player )
		removeEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler )

		if isElement( self.vehicles[ player ] ) then
			destroyElement( self.vehicles[ player ] )
		end
	end;

	Setup_C_handler = function( players, vehicles )
		local id = 1;
		for k, v in pairs( vehicles ) do
			if isElement( v ) then
				v:setData( "spawn_id", id, false )
				id = id + 1
			end
		end

		if isElement( vehicles[ localPlayer ] ) then
			addEventHandler( "onClientVehicleDamage", vehicles[ localPlayer ], CLIENT_onClientVehicleDamage_handler, true, "high+10000" )
		end

		localPlayer:setData( "block_radio", true, false )

		toggleControl( "enter_exit", false )

		CLIENT_ChangeFireControlState( "vehicle_fire", false )
		CLIENT_ChangeFireControlState( "vehicle_secondary_fire", false )

		bindKey( "lshift", "down", CLIENT_LocalPlayerVehiclePrimaryFire, "vehicle_fire" )
		bindKey( "lctrl", "both", CLIENT_LocalPlayerVehicleSecondaryFire, "vehicle_secondary_fire" )

		removeEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )
		addEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )

		addEvent( event_id .."_SetupVehicles", true )
		addEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles )

		addEvent( event_id .."_UpdatePoint_handler", true )
		addEventHandler( event_id .."_UpdatePoint_handler", resourceRoot, CLIENT_onUpdatePoint_handler )

		CLIENT_VAR_exit_zone_texture = dxCreateRenderTarget( 1, 1 )
		dxSetRenderTarget( CLIENT_VAR_exit_zone_texture, true )
		dxDrawRectangle( 0, 0, 1, 1, 0xffffffff )
		dxSetRenderTarget( )
		addEventHandler( "onClientRender", root, CLIENT_render_handler )

		CLIENT_VAR_exit_zone_colshape = ColShape.Polygon( unpack( CONST_GAME_ZONE ) )
		CLIENT_VAR_exit_zone_colshape.dimension = localPlayer.dimension
		addEventHandler( "onClientColShapeLeave", CLIENT_VAR_exit_zone_colshape, CLIENT_PlayerExitFromGameZone )
		addEventHandler( "onClientColShapeHit", CLIENT_VAR_exit_zone_colshape, CLIENT_PlayerEnterToGameZone )

		CLIENT_VAR_wait_respawn_tmr = false
		CLIENT_VAR_respawn_gm_tick = 0
		
		CLIENT_VAR_tick_minigun_reload = 0
		CLIENT_VAR_minigun_ammo = CONST_MINIGUN_AMMO

		CLIENT_VAR_tick_rocket_reload = 0
		CLIENT_VAR_tick_rocket_fire_timeout = 0
		CLIENT_VAR_rocket_ammo = CONST_ROCKET_AMMO
		CLIENT_VAR_rocket_timeout_player_dmg = {}
		
		CreateUIStartTimer( CONST_TEXT_TO_START, CONST_TIME_IN_MS_TO_TEXT_START )
		CreateUITimeout( CONST_TIME_TO_EVENT_END )
		CLIENT_CreateUIWeaponFightHunters( CLIENT_VAR_minigun_ammo, CLIENT_VAR_rocket_ammo )
		CLIENT_StartCheckRespawnPositions( vehicles )

		CLIENT_ShowHeliTutorial( true )
		triggerEvent( "onClientHideHudComponents", root, CONST_HIDE_HUD_BLOCKS, true )
	end;

	Cleanup_C_handler = function( )
		unbindKey( "lshift", "both", CLIENT_LocalPlayerVehiclePrimaryFire )
		unbindKey( "lctrl", "both", CLIENT_LocalPlayerVehicleSecondaryFire )

		CLIENT_DestroyHeliTutorial()
		CLIENT_ChangeFireControlState( "vehicle_fire", false )
		CLIENT_ChangeFireControlState( "vehicle_secondary_fire", false )

		removeEventHandler( "onClientKey", root, CLIENT_RaceKeyHandler )
		removeEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles )
		removeEventHandler( event_id .."_UpdatePoint_handler", resourceRoot, CLIENT_onUpdatePoint_handler )
		removeEventHandler( "onClientRender", root, CLIENT_render_handler )

		for k, v in pairs( { CLIENT_VAR_wait_respawn_tmr, CLIENT_VAR_game_zone_exit_tmr, CLIENT_VAR_enable_controls_primary_tmr, CLIENT_VAR_enable_controls_secondary_tmr,
							 CLIENT_VAR_off_controls_primary_tmr, CLIENT_VAR_off_controls_secondary_tmr, CLIENT_VAR_check_veh_respawn_tmr } ) do
			if isTimer( v ) then killTimer( v ) end
		end
		
		for k, v in pairs( { CLIENT_VAR_exit_zone_texture, CLIENT_VAR_exit_zone_colshape } ) do
			if isElement( v ) then destroyElement( v ) end
		end

		toggleControl( "enter_exit", true )

		localPlayer:setData( "block_radio", false, false )
		triggerEvent( "onClientHideHudComponents", root, CONST_HIDE_HUD_BLOCKS, false )
	end;
}

if not localPlayer and SERVER_NUMBER > 100 then
    addCommandHandler( "fight_hunters_player_count", function( player )
		REGISTERED_EVENTS[ event_id ].count_players = REGISTERED_EVENTS[ event_id ].count_players == 6 and 2 or 6
		iprint( "set 'fight_hunters' count players: " .. REGISTERED_EVENTS[ event_id ].count_players )
    end )
end