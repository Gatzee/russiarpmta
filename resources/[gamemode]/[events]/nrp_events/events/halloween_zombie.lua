local event_id = "halloween_zombie"

local CONST_SPAWN_POSITION = Vector3( -2732.886, -941.237, 22.233 )
local zombie_shader = nil

local CONST_COINS_REWARDS = {
	[ 1 ] = 20;
	[ 2 ] = 13;
	[ 3 ] = 8;
	[ 4 ] = 3;
	[ 5 ] = 1;
}

local function SelectZombie( self )
	local players = { }
	for player in pairs( self.players ) do
		table.insert( players, player )
	end

	local current_zombie = math.random( 1, #players )
	self.current_zombie = players[ current_zombie ]

	triggerClientEvent( players, self.event_id .."_SetNewZombie", resourceRoot, self.current_zombie, 60 )


	if isTimer( self.zombie_die_timer ) then
		killTimer( self.zombie_die_timer )
	end

	self.zombie_die_timer = Timer( function( )
		local end_event = PlayerEndEvent( self.current_zombie, "Вы погибли" )
		if end_event then return end

		SelectZombie( self )
	end, 60000, 1 )
end

local function SetNewZombie( new_zombie, times )
	if isElement( zombie_shader ) then
		destroyElement( zombie_shader )
	end

	if new_zombie == localPlayer then
		ToggleStaminaHandler( false )
	else
		ToggleStaminaHandler( true )
	end

	localPlayer:setData( "hud_timer_data", {
		text = "Зараженный умрет через:",
		timestamp = getRealTime( ).timestamp + times
	}, false )

	zombie_shader = dxCreateShader( "fx/recolor.fx", 0, 70, true, "ped" )
	engineApplyShaderToWorldTexture( zombie_shader, "*", new_zombie )
	engineRemoveShaderFromWorldTexture( zombie_shader, "*sitem*", new_zombie )
	dxSetShaderValue( zombie_shader, "sMorphSize", 0.03, 0.03, 0.03 )
	dxSetShaderValue( zombie_shader, "sMorphColor", 1, 0, 0, 0.3 )
end

local BOUNDS = {
	-2700.708, -856.469,
	-2826.574, -893.015,
	-2786.821, -1031.132,
	-2660.991, -994.632,
	-2700.708, -856.469,
}
local COLSHAPE, TEXTURE
local function renderBounds()
    for i = 1, #BOUNDS, 2 do
        local x, y = BOUNDS[ i ], BOUNDS[ i + 1 ]

        local i_next = ( i + 2 ) >= #BOUNDS and 1 or ( i + 2 )
        local x_next, y_next = BOUNDS[ i_next ], BOUNDS[ i_next + 1 ]

        local _, _, z = getElementPosition( localPlayer )
        z = z - 10

        dxDrawMaterialLine3D( x, y, z, x_next, y_next, z, TEXTURE, 75, tocolor( 255, 128, 128, math.floor( 0.7 * 128 ) ), x_next + 1, y_next, z )
    end
end

local function KeyHandler( key, state )
	local disabled_keys = { p = true, q = true, tab = true, m = true }
	if disabled_keys[key] then
		cancelEvent()
	end
end

local function ClientPlayerDamage( attacker, weapon )
	if attacker ~= localPlayer then return end
	if source == localPlayer then return end
	if weapon ~= 0 then return end

	TriggerCustomServerEvent( "PlayerDamagePlayer", source )
end

local function PlayerDamagePlayer_handler( self, new_zombie )
	if self.current_zombie ~= client then return end
	if not self.players[ client ] or not self.players[ new_zombie ] then return end

	local players = { }
	for player in pairs( self.players ) do
		table.insert( players, player )
	end

	self.current_zombie = new_zombie

	if isTimer( self.zombie_die_timer ) then
		local times = getTimerDetails( self.zombie_die_timer )
		triggerClientEvent( players, event_id .."_SetNewZombie", resourceRoot, self.current_zombie, math.floor( times / 1000 ) )
	end
end

REGISTERED_EVENTS[ event_id ] = {
	name = "Зараженные";
	group = "halloween";
	count_players = 5;
	timeout = 10 * 60;

	Setup_S_handler = function( self )
		self.wasted_handler = function( )
			cancelEvent( )
			local is_end = PlayerEndEvent( source, "Вы погибли" )

			if not is_end and source == self.current_zombie then
				SelectZombie( self )
			end
		end

		for player in pairs( self.players ) do
			player.position = CONST_SPAWN_POSITION + Vector3( math.random( -5, 5 ), math.random( -5, 5 ), 0 )

			addEventHandler( "onPlayerPreWasted", player, self.wasted_handler )
			triggerEvent( "OnPlayerForceSwitchTeam", player, player, false )
		end

		AddCustomServerEventHandler( self, "PlayerDamagePlayer", PlayerDamagePlayer_handler )

		self.start_timer = Timer( function( )
			SelectZombie( self )
		end, 15000, 1 )
	end;

	Setup_C_handler = function( )
		addEvent( event_id .."_SetNewZombie", true )
		addEventHandler( event_id .."_SetNewZombie", resourceRoot, SetNewZombie )


		TEXTURE = dxCreateRenderTarget( 1, 1 )
		dxSetRenderTarget( TEXTURE, true )
		dxDrawRectangle( 0, 0, 1, 1, 0xffffffff )
		dxSetRenderTarget( )
		addEventHandler( "onClientRender", root, renderBounds )

		COLSHAPE = ColShape.Polygon( unpack( BOUNDS ) )
		COLSHAPE.dimension = localPlayer.dimension
		addEventHandler( "onClientColShapeLeave", COLSHAPE, function( element )
			if element == localPlayer then
				localPlayer.health = 0
			end
		end )

		addEventHandler( "onClientKey", root, KeyHandler )
		toggleControl( "aim_weapon", false )
		toggleControl( "next_weapon", false )
		toggleControl( "previous_weapon", false )
		toggleControl( "jump", false )

		localPlayer:setWeaponSlot( 0 )

		localPlayer:setData( "hud_timer_data", {
			text = "Начало через:",
			text_color = 0xff97ff63;
			timestamp = getRealTime( ).timestamp + 15
		}, false )

		addEventHandler( "onClientPlayerDamage", root, ClientPlayerDamage )
	end;

	CleanupPlayer_S_handler = function( self, player )
		if self.damage_handler then
			removeEventHandler( "onPlayerDamage", player, self.damage_handler )
		end

		if self.wasted_handler then
			removeEventHandler( "onPlayerPreWasted", player, self.wasted_handler )
		end

		triggerEvent( "OnPlayerForceSwitchTeam", player, player, true )
	end;

	Cleanup_S_handler = function( self )
		if isTimer( self.start_timer ) then
			killTimer( self.start_timer )
		end

		if isTimer( self.zombie_die_timer ) then
			killTimer( self.zombie_die_timer )
		end
	end;

	Cleanup_C_handler = function( )
		localPlayer:setData( "hud_timer_data", false, false )
		ToggleStaminaHandler( false )

		removeEventHandler( event_id .."_SetNewZombie", resourceRoot, SetNewZombie )

		if isElement( TEXTURE ) then
			destroyElement( TEXTURE )
		end
		removeEventHandler( "onClientRender", root, renderBounds )

		if isElement( COLSHAPE ) then
			destroyElement( COLSHAPE )
		end

		if isElement( zombie_shader ) then
			destroyElement( zombie_shader )
		end

		removeEventHandler( "onClientKey", root, KeyHandler )
		toggleControl( "aim_weapon", true )
		toggleControl( "next_weapon", true )
		toggleControl( "previous_weapon", true )
		toggleControl( "jump", true )

		removeEventHandler( "onClientPlayerDamage", root, ClientPlayerDamage )
	end;

	RewardPlayer_S_handler = function( self, player, number )
		if CONST_COINS_REWARDS[ number ] then
			local coins, _, booster_coins = player:GiveHalloweenCoins( CONST_COINS_REWARDS[ number ] )
			player:ShowRewards(
				{
					type = "halloween_coins";
					value = coins;
				},
				booster_coins and {
					type = "halloween_coins_booster";
					value = booster_coins;
				}
			)
			player:MissionCompleted( )

			return {
				event_prize = coins;
			}
		end
	end;
}