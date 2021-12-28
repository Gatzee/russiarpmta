local event_id = "halloween_destruction"

local CONST_TEXT_TO_START = {
	"Не падай в воду",
	"Уничтожай врагов",
}

local CONST_TIME_IN_MS_TO_TEXT_START = 1500
local CONST_TIME_TO_START_EVENT = 3
local CONST_TIME_TO_EVENT_END = 5 * 60

local CONST_VEHICLE_MODEL = 6552
local CONST_MAP_MODEL = 3458

local CONST_SPAWN_POSITIONS = {
	-- 1 уровень
	{  x = -2408.453, y = -2869.866, z = 2.382, rz = 314 },
	{  x = -2408.074, y = -2795.762, z = 2.380, rz = 225 },
	{  x = -2371.360, y = -2832.516, z = 2.380, rz = 314 },
	{  x = -2333.950, y = -2870.053, z = 2.383, rz = 45 },
	{  x = -2333.903, y = -2795.446, z = 2.382, rz = 133 },

	-- 2 уровень
	{ x = -2313.453, y = -2869.866, z = 7.382, rz = 314 },
	{ x = -2313.074, y = -2795.762, z = 7.38, rz = 225 },
	{ x = -2276.36, y = -2832.516, z = 7.38, rz = 314 },
	{ x = -2238.95, y = -2870.053, z = 7.383, rz = 45 },
	{ x = -2238.903, y = -2795.446, z = 7.382, rz = 133 },
}

local CONST_MAP_OBJECT_POSITIONS = { 
	-- 1 уровень
	{  x = -2351.1, y = -2795.1, z = 0.09, rz = 0, model = 642 },
	{ x = -2351.1, y = -2795.1, z = 0.09, rz = 0, model = 642 },
	{ x = -2391.45, y = -2795.1, z = 0.09, rz = 0, model = 642 },
	{ x = -2409.1, y = -2812.75, z = 0.1, rz = 90, model = 642 },
	{ x = -2409.1, y = -2853.15, z = 0.1, rz = 90, model = 642 },
	{ x = -2333.45, y = -2812.75, z = 0.1, rz = 90, model = 642 },
	{ x = -2333.45, y = -2853.15, z = 0.1, rz = 90, model = 642 },
	{ x = -2351.1, y = -2870.8, z = 0.09, rz = 0, model = 642 },
	{ x = -2391.45, y = -2870.8, z = 0.09, rz = 0, model = 642 },

	{ x = -2350.1, y = -2811.8, z = 0.08, rz = 45, model = 642 },
	{ x = -2378.6, y = -2840.31, z = 0.08, rz = 45, model = 642 },
	{ x = -2392.6, y = -2854.29, z = 0.07, rz = 45, model = 642 },

	{ x = -2350.1, y = -2853.8, z = 0.08, rz = -45, model = 642 },
	{ x = -2378.6, y = -2825.31, z = 0.1, rz = -45, model = 642 },
	{ x = -2392.6, y = -2811.29, z = 0.08, rz = -45, model = 642 },

	-- 2 уровень
	{ x = -2256.1, y = -2795.1, z = 5.09, rz = 0, model = 642 },
	{ x = -2296.45, y = -2795.1, z = 5.09, rz = 0, model = 642 },
	{ x = -2314.1, y = -2812.75, z = 5.1, rz = 90, model = 642 },
	{ x = -2314.1, y = -2853.15, z = 5.1, rz = 90, model = 642 },
	{ x = -2238.45, y = -2812.75, z = 5.1, rz = 90, model = 642 },
	{ x = -2238.45, y = -2853.15, z = 5.1, rz = 90, model = 642 },
	{ x = -2256.1, y = -2870.8, z = 5.09, rz = 0, model = 642 },
	{ x = -2296.45, y = -2870.8, z = 5.09, rz = 0, model = 642 },

	{ x = -2255.1, y = -2811.8, z = 5.08, rz = 45, model = 642 },
	{ x = -2283.6, y = -2840.31, z = 5.08, rz = 45, model = 642 },
	{ x = -2297.6, y = -2854.29, z = 5.07, rz = 45, model = 642 },

	{ x = -2255.1, y = -2853.8, z = 5.08, rz = -45, model = 642 },
	{ x = -2283.6, y = -2825.31, z = 5.1, rz = -45, model = 642 },
	{ x = -2297.6, y = -2811.29, z = 5.08, rz = -45, model = 642 },

	-- рампы
	{ x = -2325.962, y = -2794.68, z = 2.7, rz = -90, model = 643 },
	{ x = -2325.962, y = -2871.18, z = 2.7, rz = -90, model = 643 },

	{ x = -2325.962 + 6.5, y = -2794.68, z = 2.7, rz = 90, model = 643 },
	{ x = -2325.962 + 6.5, y = -2871.18, z = 2.7, rz = 90, model = 643 },
}

local CONST_MAP_OBJECTS = {
	642, 643,
}

local CLIENT_VAR_map_objects = { }
local CLIENT_VAR_is_vehicle_in_water_timer = nil
local CLIENT_VAR_attacker_damage_timer = nil

local CLIENT_VAR_lava = nil
local CLIENT_VAR_lava_sound = nil

local function SERVER_onPlayerPreWasted_handler(  )
	cancelEvent( )
	PlayerEndEvent( source, "Вы погибли", true )
end

local function SERVER_ClientKillVehicle_handler( self, attacker )
	local count_kill = ( attacker:getData( "count_kill" ) or 0 ) + 5
	attacker:SetPrivateData( "count_kill", count_kill )

	for player in pairs( self.players ) do
		triggerClientEvent( player, event_id .."_PlayerKillVehicle", resourceRoot, attacker, count_kill )
	end
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

if localPlayer then
	CLIENT_ReplaceModel( )
end

local function CLIENT_CreateMapObjects( )	
	for i, object in pairs( CONST_MAP_OBJECT_POSITIONS ) do
		CLIENT_VAR_map_objects[ i ] = Object( object.model, object.x, object.y, object.z, 0, 0, object.rz )
		CLIENT_VAR_map_objects[ i ]:setDimension( localPlayer.dimension )
		CLIENT_VAR_map_objects[ i ]:setInterior( localPlayer.interior )
		CLIENT_VAR_map_objects[ i ]:setFrozen( true )

		addEventHandler("onClientObjectDamage", CLIENT_VAR_map_objects[ i ], function( )
			cancelEvent()
		end )
	end
end

local function CLIENT_SetupVehicles_handler( vehicles )
	localPlayer:setData( "hud_timer_data", {
		text = "Конец раунда через:",
		timestamp = getRealTime( ).timestamp + CONST_TIME_TO_EVENT_END
	}, false )
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

local function CLIENT_onChangeCollisionVehicle_handler( player_respawn, data )
	if not isElement( player_respawn ) then return end
	if player_respawn == localPlayer then
		setCameraTarget( localPlayer )
	end

	CLIENT_ChangeCollisionVehicle( player_respawn, data, false )
	
	
	Timer( function( player_respawn, data )
		if not isElement( player_respawn ) then return end
		CLIENT_ChangeCollisionVehicle( player_respawn, data, true )
	end, 5 * 1000, 1, player_respawn, data )
end

local function CLIENT_PlayerKillVehicle_handler( player, count_kill )
	UpdateScoreboard( player, count_kill )
end

local function SERVER_RespawnVehicle_handler( self )
	createExplosion ( client.vehicle:getPosition( ), 4 )

	Timer( function( client )
		if not client.vehicle then return end
		local spawn = CONST_SPAWN_POSITIONS[ math.random( 1, #CONST_SPAWN_POSITIONS ) ]
		client.vehicle:spawn( spawn.x, spawn.y, spawn.z, 0, 0, spawn.rz )
		client.vehicle:setEngineState( true )

		for player in pairs( self.players ) do
			triggerClientEvent( player, event_id .."_ChangeCollisionVehicle", resourceRoot, client, self.vehicles )
		end
	end, 2 * 1000, 1, client )
end

local function CLIENT_onClientVehicleDamage_handler( attacker, theWeapon )
	if not source then return end
	if theWeapon then cancelEvent( ) end

	if source.health <= 400 then
		TriggerCustomServerEvent( "ClientRespawnVehicle" )
		removeEventHandler( "onClientVehicleDamage", localPlayer.vehicle, CLIENT_onClientVehicleDamage_handler )

		Timer( function( )
			addEventHandler( "onClientVehicleDamage", localPlayer.vehicle, CLIENT_onClientVehicleDamage_handler, true, "high+10000" )
		end, 2 * 1000, 1 )

		localPlayer:setData( "attacker", false, false )
	end

	if not attacker or attacker.type ~= "vehicle" then return end
	if source.health <= 400 then
		TriggerCustomServerEvent( "ClientKillVehicle", attacker.controller )
		return
	end

	localPlayer:setData( "attacker", attacker.controller, false )

	if isTimer( CLIENT_VAR_attacker_damage_timer ) then
		killTimer( CLIENT_VAR_attacker_damage_timer )
	end

	CLIENT_VAR_attacker_damage_timer = Timer( function( )
		localPlayer:setData( "attacker", false, false )
	end, 5 * 1000, 1 )
end

local function CLIENT_onClientVehicleInWatter( )
	local attacker = localPlayer:getData( "attacker" )

	if attacker then
		TriggerCustomServerEvent( "ClientKillVehicle", attacker )
	end

	TriggerCustomServerEvent( "ClientRespawnVehicle" )
	localPlayer:setData( "attacker", false, false )
end

function CLIENT_SetLavaState( state )
	if state then
		setWaterColor( 255, 255, 255, 255 )
		CLIENT_VAR_lava = dxCreateShader( "fx/lava.fx" )
		local textura = dxCreateTexture( "img/lava.png" )
		dxSetShaderValue( CLIENT_VAR_lava, "TEXTURE", textura )
		engineApplyShaderToWorldTexture( CLIENT_VAR_lava, "waterclear256" )

		CLIENT_VAR_lava_sound = playSound("sounds/lava.mp3", true )
		setSoundVolume( CLIENT_VAR_lava_sound, 0.2 )
	else
		setWaterColor( 93, 170, 170, 240 )
		stopSound( CLIENT_VAR_lava_sound )

		CLIENT_VAR_lava:destroy( )
		
		CLIENT_VAR_lava = nil
		CLIENT_VAR_lava_sound = nil
	end
end

REGISTERED_EVENTS[ event_id ] = {
	name = "Уничтожение";
	group = "halloween";
	count_players = 5;
	scoreboard_text_point = "Количество очков";

	coins_reward = {
		[ 1 ] = 16;
		[ 2 ] = 13;
		[ 3 ] = 10;
		[ 4 ] = 8;
		[ 5 ] = 5;
	},

	Setup_S_handler = function( self )
		self.vehicles = {}

		local counter = 0
		for player in pairs( self.players ) do
			counter = counter + 1
			local spawn = CONST_SPAWN_POSITIONS[ counter ]

			local vehicle = Vehicle.CreateTemporary( CONST_VEHICLE_MODEL, spawn.x, spawn.y, spawn.z, 0, 0, spawn.rz )
			vehicle.dimension = self.dimension
			self.vehicles[ player ] = vehicle

			setTimer( function( )
				player.vehicle = vehicle
				vehicle.frozen = true
			end, 100, 1 )

			addEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler )
		end

		AddCustomServerEventHandler( self, "ClientKillVehicle", SERVER_ClientKillVehicle_handler )
		AddCustomServerEventHandler( self, "ClientRespawnVehicle", SERVER_RespawnVehicle_handler )
	end;

	Setup_S_delay_handler = function( self, players )
		triggerClientEvent( self.players, event_id .."_SetupVehicles", resourceRoot, self.vehicles )

		self.start_timer = Timer( function( )
			for player in pairs( self.players ) do
				if isElement( player.vehicle ) then
					player:SetPrivateData( "count_kill", 0 )
					player.vehicle.frozen = false
				else
					PlayerEndEvent( player, "Ошибка инициализации" )
				end
			end
		end, CONST_TIME_TO_START_EVENT * 1000, 1 )

		self.end_timer = Timer( function( )
			local players_by_points = { }
			for player in pairs( self.players ) do
				table.insert( players_by_points, { player = player, points = player:getData( "count_kill" ) } )
			end

			table.sort( players_by_points, function( a, b )
				return a.points < b.points
			end )

			for _, data in pairs( players_by_points ) do
				PlayerEndEvent( data.player, "Время вышло" )
			end
		end, CONST_TIME_TO_EVENT_END * 1000, 1 )
	end;

	Cleanup_S_handler = function( self )
		RemoveCustomServerEventHandler( self, "ClientKillVehicle" )
		RemoveCustomServerEventHandler( self, "ClientRespawnVehicle" )

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
		end

		addEvent( event_id .."_PlayerKillVehicle", true )
		addEventHandler( event_id .."_PlayerKillVehicle", resourceRoot, CLIENT_PlayerKillVehicle_handler )
		
		addEvent( event_id .."_SetupVehicles", true )
		addEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles_handler )

		addEvent( event_id .."_ChangeCollisionVehicle", true )
		addEventHandler( event_id .."_ChangeCollisionVehicle", resourceRoot, CLIENT_onChangeCollisionVehicle_handler )
		
		toggleControl( "enter_exit", false )

		CLIENT_CreateMapObjects( )

		CreateUIStartTimer( CONST_TEXT_TO_START, CONST_TIME_IN_MS_TO_TEXT_START )
		CreateUITimeout( CONST_TIME_TO_EVENT_END )
		CLIENT_SetLavaState( true )

		CLIENT_VAR_is_vehicle_in_water_timer = Timer( function( )
			if localPlayer.vehicle and isElementInWater( localPlayer.vehicle ) then
				CLIENT_onClientVehicleInWatter( )
			end
		end, 3 * 1000, 0 )
	end;

	
	Cleanup_C_handler = function( )
		localPlayer:setData( "hud_timer_data", false, false )

		removeEventHandler( event_id .."_PlayerKillVehicle", resourceRoot, CLIENT_PlayerKillVehicle_handler )
		removeEventHandler( event_id .."_ChangeCollisionVehicle", resourceRoot, CLIENT_onChangeCollisionVehicle_handler )
		removeEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles_handler )

		toggleControl( "enter_exit", true )

		if isTimer( CLIENT_VAR_is_vehicle_in_water_timer ) then
			killTimer( CLIENT_VAR_is_vehicle_in_water_timer )
		end

		if isTimer( CLIENT_VAR_attacker_damage_timer ) then
			killTimer( CLIENT_VAR_attacker_damage_timer )
		end

		for _, object in pairs( CLIENT_VAR_map_objects ) do
			object:destroy( )
		end

		CLIENT_SetLavaState( )
	end;
}

-- Тестирование
if not localPlayer and SERVER_NUMBER > 100 then
	addCommandHandler( "halloween_destruction", function( player )
		iprint( "halloween_destruction count 2" )
        REGISTERED_EVENTS[ event_id ].count_players = 2
    end )
end