local event_id = "mayevent_tank_battle"

local CONST_TEXT_TO_START = { "Уничтожай врага", "Используй тактику", "Побеждай!", }

local CONST_TIME_IN_MS_TO_TEXT_START = 1500

local CONST_TIME_TO_START_EVENT = 3
local CONST_TIME_TO_EVENT_END = 5 * 60
local CONST_TIME_TO_PLAYER_RESPAWN = 10
local CONST_TIME_TO_PLAYER_GM = 2
local CONST_TIME_TO_ZONE_EXIT = 5

local CONST_VEHICLE_MODEL = 432
local CONST_VEHICLE_HEALTH = 500

local CONST_SHELL_DAMAGE = 120
local CONST_SHELL_AMMO = 1
local CONST_SHELL_TIME_TO_FIRE = 1
local CONST_SHELL_TIME_TO_RELOAD = 2
local CONST_SHELL_DISTANCE_EFFECT = 10

local CONST_SPAWN_POSITIONS = {
	Vector3( -769.5460,  961.0924, 21.0838 );
	Vector3( -924.5780,  934.3097, 21.9066 );
	Vector3( -831.7454,  816.2340, 20.9269 );
	Vector3( -943.6216,  701.3193, 20.8982 );
	Vector3( -1073.1671, 741.7137, 21.1445 );
	Vector3( -1062.2735, 901.0399, 21.1852 );
}

local CONST_HIDE_HUD_BLOCKS = { "main", "notifications", "daily_quest", "factionradio", "cases_discounts", "quest", "ksusha", "wanted", "nodamage", "weapons", "offers", "offer_ingame_draw", "7cases", }

local CONST_RESPAWN_CAMERA_MAXTRIX = { -874.54797363281, 863.45520019531, 277.90319824219, -886.74401855469, 872.67364501953, 179.07872009277, 0, 70 }
local CONST_RESPAWN_PLAYER_TMP_POSITION = Vector3( -937.1722, 892.4990, 2012.2993 )

local CONST_GAME_ZONE = {
	-701, 1008,
	-1075, 1085,
	-1170, 557,
	-1006, 548,
	-746, 860,
	-701, 1008,
}

local CLIENT_VAR_wait_respawn_tmr = false
local CLIENT_VAR_respawn_gm_tick = 0
local CLIENT_VAR_tick_shell_reload = 0
local CLIENT_VAR_tick_shell_fire_timeout = 0
local CLIENT_VAR_shell_ammo = 0
local CLIENT_VAR_exit_zone_texture = nil
local CLIENT_VAR_game_zone_exit_tmr = false
local CLIENT_VAR_exit_zone_colshape = nil
local CLIENT_VAR_check_veh_respawn_tmr = nil

local CLIENT_VAR_disabled_keys = { p = true, q = true, tab = true, m = true, y = true, u = true }

local function SERVER_onPlayerPreWasted_handler(  )
	cancelEvent( )
	PlayerEndEvent( source, "Вы покинули состязание", true )
end

local function SERVER_ClientDestroyEnemyTank_handler( self, killer )
	if not client or client == killer then return end

	local kills_count = ( killer:getData( "kills_count" ) or 0 ) + 1
	killer:setData( "kills_count", kills_count, false )

	SyncEventScoreboard( self, event_id .. "_UpdatePoint_handler", kills_count, killer )

	triggerEvent( "BP:ME:onPlayerKill", killer, event_id )
	triggerEvent( "BP:ME:onPlayerWasted", client, event_id )
end

local function CLIENT_DeleteUIWeaponTankBattle( )
	if isElement( UIe.weapon_bg ) then destroyElement( UIe.weapon_bg ) end
end

local function CLIENT_CreateUIWeaponTankBattle( shell_ammo )
	CLIENT_DeleteUIWeaponTankBattle( )

	UIe.weapon_bg = ibCreateArea( _SCREEN_X - 197, _SCREEN_Y - 363, 167, 70 )
	UIe.shell_bg = ibCreateImage( 85, 0, 60, 55, "img/may_events/tank_battle_rocket_bg.png", UIe.weapon_bg )
end

local function CLIENT_UpdateUIWeaponTankBattle( shell_ammo, shell_timeout )
	if not isElement( UIe.weapon_bg ) then return end

	if shell_timeout then
		if isElement( UIe.shell_timeout ) then
			destroyElement( UIe.shell_timeout )
		end

		UIe.shell_bg:ibData( "color", ibApplyAlpha( COLOR_WHITE, 40 ) )
		UIe.shell_timeout = ibCreateLabel( 0, 0, 0, 0, shell_timeout, UIe.shell_bg, COLOR_WHITE, 1, 1, "center", "center" )
			:center( )
			:ibData( "font", ibFonts.bold_18 )
			:ibData( "outline", true )
			:ibTimer( function( self )
				local count = tonumber( self:ibData( "text" ) ) - 1
				if count > 0 then
					self:ibData( "text", count )
				else
					destroyElement( self )
					UIe.shell_bg:ibData( "color", COLOR_WHITE )
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
	CLIENT_DeleteUIWeaponTankBattle( )

	local vehicle = localPlayer.vehicle
	vehicle.position = CONST_RESPAWN_PLAYER_TMP_POSITION
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

		CLIENT_VAR_tick_shell_reload = 0
		CLIENT_VAR_tick_shell_fire_timeout = 0
		CLIENT_VAR_shell_ammo = CONST_SHELL_AMMO

		CLIENT_CreateUIWeaponTankBattle( CLIENT_VAR_shell_ammo )

		CLIENT_VAR_wait_respawn_tmr = false
		CLIENT_VAR_respawn_gm_tick = getTickCount( ) + CONST_TIME_TO_PLAYER_GM * 1000

		RemoveEffects( vehicle, CONST_TIME_TO_PLAYER_GM * 1000 )
		triggerEvent( "RC:ApplyEffect", localPlayer, 2, vehicle )

		DeleteUIRespawnTimer( )
	end, CONST_TIME_TO_PLAYER_RESPAWN * 1000, 1 )

	CreateUIRespawnTimer( CONST_TIME_TO_PLAYER_RESPAWN )

	setCameraMatrix( unpack( CONST_RESPAWN_CAMERA_MAXTRIX ) )
end

local function CLIENT_onClientExplosion_handler( x, y, z, type )
	local vehicle = localPlayer.vehicle
	if source == localPlayer or CLIENT_VAR_respawn_gm_tick > getTickCount() or type ~= 10 or not vehicle or vehicle.model ~= CONST_VEHICLE_MODEL then return end

	local vx, vy, vz = getElementPosition( vehicle )

	local distance_between_tank_and_grenade = getDistanceBetweenPoints3D( vx, vy, vz, x, y, z )
	if distance_between_tank_and_grenade > CONST_SHELL_DISTANCE_EFFECT then return end

	local new_health = math.max( 399, vehicle.health - CONST_SHELL_DAMAGE )
	setElementHealth( vehicle, new_health )
	
	CreateUIDamage( vehicle.position, source.position, vehicle.rotation.z )

	if new_health <= 400 then
		setTimer( CLIENT_StartRespawnPlayer, 50, 1 )
		TriggerCustomServerEvent( "ClientDestroyEnemyTank", source )
	end 
end

local function CLIENT_TankBattleKeyHandler( key, state )
	if CLIENT_VAR_disabled_keys[ key ] then 
		cancelEvent( ) 
		return
	end

	local vehicle_fire_keys = getBoundKeys( "vehicle_fire" )
	if vehicle_fire_keys[ key ] and key ~= "mouse1" then
		cancelEvent()
		return
	end
end

local function CLIENT_onUpdatePoint_handler( player, points, place )
	UpdateScoreboard( player, points, place )
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

	local vehicle = localPlayer.vehicle
	if not vehicle or vehicle.model ~= CONST_VEHICLE_MODEL or CLIENT_VAR_wait_respawn_tmr then return end

	local muzzle_comp_pos = Vector3( { vehicle:getComponentPosition( "misc_b" ) } )
  	local muzzle_world_pos = getPositionFromElementOffset( vehicle, muzzle_comp_pos )

	local turret_comp_pos = Vector3( { vehicle:getComponentPosition( "misc_c" ) } )
	local turret_world_pos = getPositionFromElementOffset( vehicle, turret_comp_pos ) + Vector3( 0, 0, 1.5 )
			
	local px, py = getScreenFromWorldPosition( muzzle_world_pos + getDirectionByTwoPoints( muzzle_world_pos, turret_world_pos, 80 ), 0, false )
	if px and py then
		local sx_a, sy_a = 158, 158
		
		dxDrawImage( math.floor( px - sx_a / 2 ), math.floor( py - sy_a / 2 ), sx_a, sy_a, "img/may_events/tank_aim.png" )

		local reload_progress = 1
		local scale_reload = 1
		local r, g, b = 255, 255, 255
		local realod_time_in_ms = CLIENT_VAR_tick_shell_reload - getTickCount()		
		if realod_time_in_ms > 0 then
			r, g, b = 0, 255, 0
			local time_reload_in_ms = CONST_SHELL_TIME_TO_RELOAD * 1000 
			reload_progress = (time_reload_in_ms - realod_time_in_ms) / time_reload_in_ms
			scale_reload = math.max( 1, scale_reload + (0.7 - reload_progress) )
		end

		local sx_r, sy_r = math.floor( 176 * scale_reload ), math.floor( 176  * scale_reload )
		dxSetShaderValue( CLIENT_VAR_tick_shell_shader_reload, "dg", reload_progress * 2 )
		dxSetShaderValue( CLIENT_VAR_tick_shell_shader_reload, "rgba", r, g, b, 255 )
		dxDrawImage( math.floor( px - sx_r / 2 ), math.floor( py - sy_r / 2 ), sx_r, sy_r, CLIENT_VAR_tick_shell_shader_reload, 0, 0, 0 )
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

local function CLIENT_UpdateFireControls( state )
	toggleControl( "vehicle_fire", state )
end

local function CLIENT_LocalPlayerVehicleFire( key, state )
	if not localPlayer.vehicle then return end
	if CLIENT_VAR_wait_respawn_tmr or CLIENT_VAR_tick_shell_fire_timeout > getTickCount( ) or CLIENT_VAR_tick_shell_reload > getTickCount() then return end

	CLIENT_VAR_tick_shell_fire_timeout = getTickCount( ) + CONST_SHELL_TIME_TO_FIRE * 1000

	if CLIENT_VAR_shell_ammo <= 0 then CLIENT_VAR_shell_ammo = CONST_SHELL_AMMO end
	CLIENT_VAR_shell_ammo = CLIENT_VAR_shell_ammo - 1

	if CLIENT_VAR_shell_ammo <= 0 then
		CLIENT_VAR_tick_shell_reload = getTickCount( ) + CONST_SHELL_TIME_TO_RELOAD * 1000
		
		setTimer( CLIENT_UpdateFireControls, 500, 1, false )
		CLIENT_VAR_enable_controls_tmr = setTimer( CLIENT_UpdateFireControls, CONST_SHELL_TIME_TO_RELOAD * 1000, 1, true )
		CLIENT_UpdateUIWeaponTankBattle( CONST_SHELL_AMMO, CONST_SHELL_TIME_TO_RELOAD )
	else
		CLIENT_UpdateUIWeaponTankBattle( CLIENT_VAR_shell_ammo )
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

local function CLIENT_onClientVehicleDamage_handler()
	cancelEvent( )
end

REGISTERED_EVENTS[ event_id ] = {
	name = "Танковая битва";
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

		AddCustomServerEventHandler( self, "ClientDestroyEnemyTank", SERVER_ClientDestroyEnemyTank_handler )
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
		RemoveCustomServerEventHandler( self, "ClientDestroyEnemyTank" )
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
		if isElement( vehicles[ localPlayer ] ) then
			addEventHandler( "onClientVehicleDamage", vehicles[ localPlayer ], CLIENT_onClientVehicleDamage_handler, true, "high+10000" )
		end

		localPlayer:setData( "block_radio", true, false )
		localPlayer:setData( "blocked_change_camera", true, false )

		toggleControl( "enter_exit", false )
		toggleControl( "vehicle_secondary_fire", false )

		CLIENT_UpdateFireControls( true )
		bindKey( "vehicle_fire", "down", CLIENT_LocalPlayerVehicleFire )

		removeEventHandler( "onClientKey", root, CLIENT_TankBattleKeyHandler )
		addEventHandler( "onClientKey", root, CLIENT_TankBattleKeyHandler )

		addEvent( event_id .."_SetupVehicles", true )
		addEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles )

		addEvent( event_id .."_UpdatePoint_handler", true )
		addEventHandler( event_id .."_UpdatePoint_handler", resourceRoot, CLIENT_onUpdatePoint_handler )

		addEventHandler( "onClientExplosion", root, CLIENT_onClientExplosion_handler )

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
		
		CLIENT_VAR_tick_shell_reload = 0
		CLIENT_VAR_tick_shell_fire_timeout = 0
		CLIENT_VAR_shell_ammo = CONST_SHELL_AMMO

		CLIENT_VAR_tick_shell_shader_reload = dxCreateShader( "fx/circle.fx" )
		CLIENT_VAR_tick_shell_texture_reload = dxCreateTexture( "img/may_events/tank_aim_reload.png" )
		dxSetShaderValue( CLIENT_VAR_tick_shell_shader_reload, "tex", CLIENT_VAR_tick_shell_texture_reload )
		dxSetShaderValue( CLIENT_VAR_tick_shell_shader_reload, "angle", 270 )
		dxSetShaderValue( CLIENT_VAR_tick_shell_shader_reload, "dg", 0 )
		dxSetShaderValue( CLIENT_VAR_tick_shell_shader_reload, "rgba", 255, 255, 255, 255 )
		
		CreateUIStartTimer( CONST_TEXT_TO_START, CONST_TIME_IN_MS_TO_TEXT_START )
		CreateUITimeout( CONST_TIME_TO_EVENT_END )
		CLIENT_CreateUIWeaponTankBattle( CLIENT_VAR_shell_ammo )
		CLIENT_StartCheckRespawnPositions( vehicles )

		setTimer( function()
			triggerEvent( "onClientHideHudComponents", root, CONST_HIDE_HUD_BLOCKS, true )
		end, 150, 1 )
	end;

	Cleanup_C_handler = function( )
		fadeCamera( true )
		unbindKey( "vehicle_fire", "down", CLIENT_LocalPlayerVehicleFire )

		removeEventHandler( "onClientKey", root, CLIENT_TankBattleKeyHandler )
		removeEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles )
		removeEventHandler( event_id .."_UpdatePoint_handler", resourceRoot, CLIENT_onUpdatePoint_handler )
		removeEventHandler( "onClientRender", root, CLIENT_render_handler )
		removeEventHandler( "onClientExplosion", root, CLIENT_onClientExplosion_handler )

		for k, v in pairs( { CLIENT_VAR_wait_respawn_tmr, CLIENT_VAR_game_zone_exit_tmr, CLIENT_VAR_enable_controls_tmr, CLIENT_VAR_check_veh_respawn_tmr } ) do
			if isTimer( v ) then killTimer( v ) end
		end
		
		for k, v in pairs( { CLIENT_VAR_exit_zone_texture, CLIENT_VAR_exit_zone_colshape, CLIENT_VAR_tick_shell_shader_reload, CLIENT_VAR_tick_shell_texture_reload } ) do
			if isElement( v ) then destroyElement( v ) end
		end

		localPlayer:setData( "block_radio", false, false )
		localPlayer:setData( "blocked_change_camera", false, false )

		toggleControl( "enter_exit", true )
		CLIENT_UpdateFireControls( false )
		setTimer( function()
			triggerEvent( "onClientHideHudComponents", root, CONST_HIDE_HUD_BLOCKS, false )
		end, 150, 1 )
	end;
}

if not localPlayer and SERVER_NUMBER > 100 then
    addCommandHandler( "tank_battle_player_count", function( player )
		REGISTERED_EVENTS[ event_id ].count_players = REGISTERED_EVENTS[ event_id ].count_players == 6 and 2 or 6
		iprint( "set 'tank_battle' count players: " .. REGISTERED_EVENTS[ event_id ].count_players )
    end )
end