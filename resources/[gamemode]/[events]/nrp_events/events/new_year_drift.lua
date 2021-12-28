local event_id = "new_year_drift"

local CONST_TEXT_TO_START = {
	"Вали боком",
	"Набирай очки",
	"Не врезайся",
}
local CONST_TIME_IN_MS_TO_TEXT_START = 1500

local CONST_TIME_TO_START_EVENT = 3
local CONST_TIME_TO_EVENT_END = 5 * 60

local CONST_VEHICLE_MODEL = 480

local CONST_SPAWN_POSITIONS = {
	Vector3( 1582.001, 1726.857, 15.797 );
	Vector3( 1575.827, 1728.170, 15.797 );
	Vector3( 1575.576, 1722.700, 15.797 );
	Vector3( 1582.255, 1732.221, 15.797 );
}
local CONST_SPAWN_ROTATION = 122

local CONST_ROUTE = nil
local CONST_GAME_ZONE_EXIT = nil
local CONST_GAME_ZONE_ENTER = nil

local CONST_TIME_TO_ZONE_EXIT = 5
local CONST_TIME_TO_DRIFT_IDLE_WAIT = 1000
local CONST_TIME_TO_WRONG_WAY_WAIT = 1000
local CONST_MAX_DRIFT_MUL = 9

local CONST_VEHICLE_VINYLS = {
  {
    [ 3 ] = 3,
    [ 7 ] = "Arrow-olds",
    [ 10 ] = 150000,
    [ 14 ] = "soft",
    [ 15 ] = "Arrow-olds",
    [ 16 ] = 1,
    [ 17 ] = {
      rotation = 89.376923,
      x = 785,
      color = -16777216,
      y = 507,
      size = 1.5
    }
  },
  {
    [ 3 ] = 3,
    [ 7 ] = "girl_3",
    [ 10 ] = 500,
    [ 14 ] = "hard",
    [ 15 ] = "girl_3",
    [ 16 ] = 2,
    [ 17 ] = {
      y = 287,
      x = 486,
      rotation = 175.67693,
      mirror = true,
      size = 0.75326926
    }
  },
  {
    [ 3 ] = 3,
    [ 7 ] = "girl_3",
    [ 10 ] = 500,
    [ 14 ] = "hard",
    [ 15 ] = "girl_3",
    [ 16 ] = 3,
    [ 17 ] = {
      y = 729,
      x = 494,
      rotation = 0,
      size = 0.78955126
    }
  },
  {
    [ 3 ] = 3,
    [ 7 ] = "deer",
    [ 10 ] = 68,
    [ 14 ] = "hard",
    [ 15 ] = "deer",
    [ 16 ] = 4,
    [ 17 ] = {
      y = 512,
      x = 221,
      color = -16777216,
      rotation = 89.46154,
      mirror = true,
      size = 0.84205127
    }
  },
  {
    [ 3 ] = 3,
    [ 7 ] = "skull",
    [ 10 ] = 255,
    [ 14 ] = "hard",
    [ 15 ] = "skull",
    [ 16 ] = 5,
    [ 17 ] = {
      y = 436,
      x = 174,
      color = -16777216,
      rotation = 68.215385,
      size = 0.57570517
    }
  },
  {
    [ 3 ] = 3,
    [ 7 ] = "skull",
    [ 10 ] = 255,
    [ 14 ] = "hard",
    [ 15 ] = "skull",
    [ 16 ] = 6,
    [ 17 ] = {
      y = 590,
      x = 176,
      color = -16777216,
      rotation = 114.45385,
      mirror = true,
      size = 0.58564103
    }
  }
}

local CLIENT_VAR_tick = 0
local CLIENT_VAR_drift_score = 0
local CLIENT_VAR_drift_score_last_sync = false
local CLIENT_VAR_drift_total_score = 0
local CLIENT_VAR_drift_mp = 0
local CLIENT_VAR_drift_mp_time = 0
local CLIENT_VAR_drift_chain = 1
local CLIENT_VAR_drift_side = nil
local CLIENT_VAR_drift_chain_tick = 0
local CLIENT_VAR_drift_ilde_tick = 0
local CLIENT_VAR_is_wrongway = false
local CLIENT_VAR_route_point = nil
local CLIENT_VAR_route_point_index = 0
local CLIENT_VAR_exit_zone_texture = nil
local CLIENT_VAR_exit_zone_colshape = nil
local CLIENT_VAR_enter_zone_colshape = nil
local CLIENT_VAR_game_zone_exit_timer = nil


local function SERVER_onPlayerPreWasted_handler(  )
	cancelEvent( )
	PlayerEndEvent( source, "Вы погибли", true )
end

local function SERVER_UpdatePlayerTotalDriftPoints_handler( self, points )
	if not client then return end

	client:SetPrivateData( "drift_points", points )

	for player in pairs( self.players ) do
		triggerClientEvent( player, event_id .."_SyncPlayerTotalDriftPoints", resourceRoot, client, points )
	end
end


local function CLIENT_SetupVehicles( vehicles )
	for player, vehicle in pairs( vehicles ) do
		localPlayer.vehicle:setCollidableWith( vehicle, false )
	end
end

local function CLIENT_SyncPlayerTotalDriftPoints_handler( player, points )
	UpdateScoreboard( player, points )
end

local function CLIENT_CreateNextRoutePoint( )
	if isElement( CLIENT_VAR_route_point ) then
		destroyElement( CLIENT_VAR_route_point )
	end

	CLIENT_VAR_route_point_index = ( CLIENT_VAR_route_point_index % #CONST_ROUTE ) + 1

	local route_point_position = CONST_ROUTE[ CLIENT_VAR_route_point_index ]
	if not route_point_position then return end

	CLIENT_VAR_route_point = createColSphere( route_point_position, 10 )
	CLIENT_VAR_route_point.dimension = localPlayer.dimension
	addEventHandler( "onClientColShapeHit", CLIENT_VAR_route_point, function( element, dimension )
		if not dimension then return end
		if element ~= localPlayer.vehicle then return end

		CLIENT_CreateNextRoutePoint( )
	end )
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

local function CLIENT_EndDrift( failed )
	if CLIENT_VAR_drift_score == 0 then return end

	if not failed then
		CLIENT_VAR_drift_total_score = CLIENT_VAR_drift_total_score + CLIENT_VAR_drift_score
		UpdateUIDrift_total( CLIENT_VAR_drift_total_score )
	end

	TriggerCustomServerEvent( "UpdatePlayerTotalDriftPoints", CLIENT_VAR_drift_total_score )

	CLIENT_VAR_drift_chain = 1
	CLIENT_VAR_drift_score = 0
	CLIENT_VAR_drift_chain_tick = 0
	CLIENT_VAR_drift_side = nil

	UpdateUIDrift_current( CLIENT_VAR_drift_score )
	UpdateUIDrift_mul( CLIENT_VAR_drift_chain )

	if failed then
		UpdateUIDrift_state( not failed )
	end
end

local function CLIENT_onClientVehicleDamage_handler( attacker, weapon_id, loss )
	if not source then return end
	cancelEvent( )

	CLIENT_EndDrift( true )
end

local function CLIENT_CalculateDriftData( )
	local vehicle = localPlayer.vehicle

	local vx, vy, vz = getElementVelocity( vehicle )
	local modV = math.sqrt( vx * vx + vy * vy )

	if not isVehicleOnGround( vehicle ) then
		return 0
	end

	if CLIENT_VAR_is_wrongway then
		return 0
	end

	local rz = vehicle.rotation.z
	local sn, cs = math.sin( math.rad( rz ) ), math.cos( math.rad(rz ) )

	local timediff = CLIENT_VAR_tick - CLIENT_VAR_drift_mp_time
	if CLIENT_VAR_drift_mp > 1 and modV <= 0.3 and timediff > CONST_TIME_TO_DRIFT_IDLE_WAIT then
		CLIENT_VAR_drift_mp = math.max( CLIENT_VAR_drift_mp - 1, 1 )
		CLIENT_VAR_drift_mp_time = CLIENT_VAR_tick

	elseif timediff > 1500 then
		local temp = 1 + math.min( CLIENT_VAR_drift_chain / 2, 10 )
		if temp > CLIENT_VAR_drift_mp then
			CLIENT_VAR_drift_mp = temp
			CLIENT_VAR_drift_mp_time = CLIENT_VAR_tick
		end
	end

	if modV <= 0.15 then
		return 0
	end

	local velocity = vehicle.velocity
	local forward = vehicle.matrix.forward

	local divisor = ( velocity.length * forward.length )
	local cosine = velocity:dot( forward ) / ( divisor ~= 0 and divisor or 1 )

	local angle = math.deg( math.acos( cosine ) )
	if angle < 15 or angle > 75 then
		return 0
	end

	local right = vehicle.matrix.right
	return angle, modV, ( velocity:dot(right) >= 0 and "left" or "right" )
end

local function CLIENT_render_handler( )
	if not localPlayer.vehicle then return end

	for i = 1, #CONST_GAME_ZONE_EXIT, 2 do
        local x, y = CONST_GAME_ZONE_EXIT[ i ], CONST_GAME_ZONE_EXIT[ i + 1 ]

        local i_next = ( i + 2 ) >= #CONST_GAME_ZONE_EXIT and 1 or ( i + 2 )
        local x_next, y_next = CONST_GAME_ZONE_EXIT[ i_next ], CONST_GAME_ZONE_EXIT[ i_next + 1 ]

        local _, _, z = getElementPosition( localPlayer )
        z = z - 10

        dxDrawMaterialLine3D( x, y, z, x_next, y_next, z, CLIENT_VAR_exit_zone_texture, 75, tocolor( 255, 128, 128, math.floor( 0.7 * 128 ) ), x_next + 1, y_next + 1, z )
	end

	for i = 1, #CONST_GAME_ZONE_ENTER, 2 do
        local x, y = CONST_GAME_ZONE_ENTER[ i ], CONST_GAME_ZONE_ENTER[ i + 1 ]

        local i_next = ( i + 2 ) >= #CONST_GAME_ZONE_ENTER and 1 or ( i + 2 )
        local x_next, y_next = CONST_GAME_ZONE_ENTER[ i_next ], CONST_GAME_ZONE_ENTER[ i_next + 1 ]

        local _, _, z = getElementPosition( localPlayer )
        z = z - 10

        dxDrawMaterialLine3D( x, y, z, x_next, y_next, z, CLIENT_VAR_exit_zone_texture, 75, tocolor( 255, 128, 128, math.floor( 0.7 * 128 ) ), x_next + 1, y_next + 1, z )
	end


	local vehicle = localPlayer.vehicle
	CLIENT_VAR_tick = getTickCount( )

	if vehicle.frozen and CLIENT_VAR_drift_score > 0 and not CLIENT_VAR_drift_score_last_sync then
		CLIENT_EndDrift( )
		CLIENT_VAR_drift_score_last_sync = true
		CreateUIStartTimer( { "Подсчёт очков" }, 3000 )
		return
	end

	local angle, velocity, side = CLIENT_CalculateDriftData( )
	if side then
		if side ~= CLIENT_VAR_drift_side then
			if ( CLIENT_VAR_tick - CLIENT_VAR_drift_chain_tick ) >= 1300 then
				if CLIENT_VAR_drift_chain < CONST_MAX_DRIFT_MUL then
					CLIENT_VAR_drift_chain = CLIENT_VAR_drift_chain + 1
					CLIENT_VAR_drift_chain_tick = CLIENT_VAR_tick

					UpdateUIDrift_mul( CLIENT_VAR_drift_chain )
				end

				CLIENT_VAR_drift_side = side
				UpdateUIDrift_state( true )
			end
		end
	end

	local is_idle = ( CLIENT_VAR_tick - ( CLIENT_VAR_drift_ilde_tick ) ) > CONST_TIME_TO_DRIFT_IDLE_WAIT
	if is_idle and CLIENT_VAR_drift_score ~= 0 then
		CLIENT_EndDrift( )
		CLIENT_VAR_drift_score = 0
	else
		if angle ~= 0 then
			local tmp = math.floor( math.abs( angle ) ^ 0.7 * math.abs( velocity ) * CLIENT_VAR_drift_mp )
			if tmp > 0 then
				CLIENT_VAR_drift_score = CLIENT_VAR_drift_score + math.floor( math.abs( angle ) ^ 0.7 * math.abs( velocity ) * CLIENT_VAR_drift_mp )
				UpdateUIDrift_current( CLIENT_VAR_drift_score )

				CLIENT_VAR_drift_ilde_tick = CLIENT_VAR_tick
			end
		end
	end

	do
		local vec1 = CLIENT_VAR_route_point.position - vehicle.position
		local vec2 = vehicle.velocity.length ~= 0 and vehicle.velocity or vehicle.matrix.forward

		local divisor = ( vec1.length * vec2.length )
		local cosine = vec1:dot( vec2 ) / ( divisor ~= 0 and divisor or 1 )

		local angle = math.deg( math.acos( cosine ) )
		if angle >= 100 then
			local timestamp = getRealTime( ).timestamp
			if not CLIENT_VAR_is_wrongway then
				CLIENT_VAR_is_wrongway = timestamp
				CreateUIWrongWay( )
			elseif ( CLIENT_VAR_is_wrongway + 8 ) <= timestamp then
				localPlayer.health = 0
			end
		elseif CLIENT_VAR_is_wrongway then
			CLIENT_VAR_is_wrongway = false
			DestroyUIWrongWay( )
		end
	end
end

REGISTERED_EVENTS[ event_id ] = {
	name = "Новогодний дрифт";
	group = "new_year";
	count_players = 2;
	scoreboard_text_point = "Очков дрифта";

	coins_reward = {
		[ 1 ] = 74;
		[ 2 ] = 64;
		[ 3 ] = 42;
		[ 4 ] = 32;
	},

	Setup_S_handler = function( self )
		self.vehicles = {}

		local colors = {
			{ 255, 255, 255 },
			{ 255, 0, 255 },
			{ 0, 255, 0 },
			{ 255, 255, 0 },
			{ 255, 0, 0 },
		}
		local counter = 0
		for player in pairs( self.players ) do
			counter = counter + 1

			local vehicle = Vehicle.CreateTemporary( CONST_VEHICLE_MODEL, CONST_SPAWN_POSITIONS[ counter ].x, CONST_SPAWN_POSITIONS[ counter ].y, CONST_SPAWN_POSITIONS[ counter ].z, 0, 0, CONST_SPAWN_ROTATION )
			vehicle.dimension = self.dimension
			vehicle:SetVariant( 2 )
			vehicle:setColor( unpack( colors[ counter ] ) )
			player.vehicle = vehicle
			vehicle.frozen = true

			vehicle:SetVinyls( CONST_VEHICLE_VINYLS )

			self.vehicles[ player ] = vehicle

			player:SetPrivateData( "drift_points", 0 )

			addEventHandler( "onPlayerPreWasted", player, SERVER_onPlayerPreWasted_handler )
		end

		AddCustomServerEventHandler( self, "UpdatePlayerTotalDriftPoints", SERVER_UpdatePlayerTotalDriftPoints_handler )

		self.gift_box_owner = nil
	end;

	Setup_S_delay_handler = function( self, players )
		triggerClientEvent( players, event_id .."_SetupVehicles", resourceRoot, self.vehicles )

		self.start_timer = Timer( function( )
			for player in pairs( self.players ) do
				player.vehicle.frozen = false
			end
		end, CONST_TIME_TO_START_EVENT * 1000, 1 )

		self.pre_end_timer = Timer( function( )
			for player in pairs( self.players ) do
				player.vehicle.frozen = true
			end
		end, CONST_TIME_TO_EVENT_END * 1000, 1 )

		self.end_timer = Timer( function( )
			local sorted_players = { }
			for player in pairs( self.players ) do
				table.insert( sorted_players, {
					player = player,
					count = player:getData( "drift_points" ) or 0,
				} )
			end

			table.sort( sorted_players, function( a, b )
				return a.count < b.count
			end )

			for _, data in pairs( sorted_players ) do
				PlayerEndEvent( data.player )
			end
		end, CONST_TIME_TO_EVENT_END * 1000 + 3000, 1 )
	end;

	Cleanup_S_handler = function( self )
		RemoveCustomServerEventHandler( self, "UpdatePlayerTotalDriftPoints" )

		if isTimer( self.start_timer ) then
			killTimer( self.start_timer )
		end

		if isTimer( self.pre_end_timer ) then
			killTimer( self.pre_end_timer )
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

	Setup_C_handler = function( players )
		addEventHandler( "onClientVehicleDamage", localPlayer.vehicle, CLIENT_onClientVehicleDamage_handler, true, "high+10000" )

		toggleControl( "enter_exit", false )

		addEvent( event_id .."_SetupVehicles", true )
		addEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles )

		addEvent( event_id .."_SyncPlayerTotalDriftPoints", true )
		addEventHandler( event_id .."_SyncPlayerTotalDriftPoints", resourceRoot, CLIENT_SyncPlayerTotalDriftPoints_handler )

		CLIENT_VAR_drift_score = 0
		CLIENT_VAR_drift_score_last_sync = false
		CLIENT_VAR_drift_total_score = 0
		CLIENT_VAR_drift_mp = 0
		CLIENT_VAR_drift_mp_time = 0
		CLIENT_VAR_drift_chain = 1
		CLIENT_VAR_drift_side = nil
		CLIENT_VAR_drift_chain_tick = 0
		CLIENT_VAR_drift_ilde_tick = 0
		CLIENT_VAR_is_wrongway = false
		CLIENT_VAR_route_point = nil
		CLIENT_VAR_route_point_index = 0

		CLIENT_CreateNextRoutePoint( )

		CreateUIStartTimer( CONST_TEXT_TO_START, CONST_TIME_IN_MS_TO_TEXT_START )
		CreateUIDrift( CONST_MAX_DRIFT_MUL )
		CreateUITimeout( CONST_TIME_TO_EVENT_END, true )

		CLIENT_VAR_exit_zone_texture = dxCreateRenderTarget( 1, 1 )
		dxSetRenderTarget( CLIENT_VAR_exit_zone_texture, true )
		dxDrawRectangle( 0, 0, 1, 1, 0xffffffff )
		dxSetRenderTarget( )

		addEventHandler( "onClientRender", root, CLIENT_render_handler )

		CLIENT_VAR_exit_zone_colshape = ColShape.Polygon( unpack( CONST_GAME_ZONE_EXIT ) )
		CLIENT_VAR_exit_zone_colshape.dimension = localPlayer.dimension
		addEventHandler( "onClientColShapeLeave", CLIENT_VAR_exit_zone_colshape, CLIENT_PlayerExitFromGameZone )
		addEventHandler( "onClientColShapeHit", CLIENT_VAR_exit_zone_colshape, CLIENT_PlayerEnterToGameZone )

		CLIENT_VAR_enter_zone_colshape = ColShape.Polygon( unpack( CONST_GAME_ZONE_ENTER ) )
		CLIENT_VAR_enter_zone_colshape.dimension = localPlayer.dimension
		addEventHandler( "onClientColShapeHit", CLIENT_VAR_enter_zone_colshape, CLIENT_PlayerExitFromGameZone )
		addEventHandler( "onClientColShapeLeave", CLIENT_VAR_enter_zone_colshape, CLIENT_PlayerEnterToGameZone )

		setCameraClip( true, false )
	end;

	Cleanup_C_handler = function( )
		unbindKey( "mouse1", "both", CLIENT_LocalPlayerVehicleMinigunFire )
		unbindKey( "mouse2", "both", CLIENT_LocalPlayerVehicleMinigunFire )

		toggleControl( "enter_exit", true )

		removeEventHandler( event_id .."_SetupVehicles", resourceRoot, CLIENT_SetupVehicles )
		removeEventHandler( event_id .."_SyncPlayerTotalDriftPoints", resourceRoot, CLIENT_SyncPlayerTotalDriftPoints_handler )

		removeEventHandler( "onClientRender", root, CLIENT_render_handler )

		if isElement( CLIENT_VAR_exit_zone_texture ) then
			destroyElement( CLIENT_VAR_exit_zone_texture )
		end

		if isElement( CLIENT_VAR_exit_zone_colshape ) then
			destroyElement( CLIENT_VAR_exit_zone_colshape )
		end

		if isElement( CLIENT_VAR_enter_zone_colshape ) then
			destroyElement( CLIENT_VAR_enter_zone_colshape )
		end

		if isTimer( CLIENT_VAR_game_zone_exit_timer ) then
			killTimer( CLIENT_VAR_game_zone_exit_timer )
		end

		setCameraClip( true, true )
	end;
}


CONST_ROUTE = {
	Vector3( 1459.025, 1653.901, 15.794 );
	Vector3( 1427.332, 1737.624, 15.795 );
	Vector3( 1608.778, 1847.928, 15.799 );
	Vector3( 1643.069, 1809.320, 15.797 );
	Vector3( 1725.216, 1868.045, 15.799 );
	Vector3( 1727.145, 1916.009, 15.801 );
	Vector3( 1679.727, 1936.445, 15.797 );
	Vector3( 1690.011, 2055.918, 15.799 );
	Vector3( 1659.880, 2145.349, 15.792 );
	Vector3( 1622.115, 2256.672, 15.795 );
	Vector3( 1607.234, 2398.577, 15.795 );
	Vector3( 1626.814, 2466.538, 15.800 );
	Vector3( 1654.369, 2494.590, 15.793 );
	Vector3( 1780.132, 2451.285, 15.799 );
	Vector3( 1833.555, 2466.416, 15.797 );
	Vector3( 1869.146, 2624.508, 15.800 );
	Vector3( 1961.589, 2636.125, 15.797 );
	Vector3( 2022.135, 2607.497, 15.790 );
	Vector3( 2067.745, 2570.984, 15.791 );
	Vector3( 2006.132, 2462.553, 15.800 );
	Vector3( 1954.488, 2390.648, 15.799 );
	Vector3( 1830.986, 2425.652, 15.799 );
	Vector3( 1793.042, 2238.449, 15.789 );
	Vector3( 1839.432, 2197.987, 15.792 );
	Vector3( 1829.364, 2146.335, 15.793 );
	Vector3( 1729.579, 1831.046, 15.799 );
	Vector3( 1645.756, 1769.817, 15.797 );
}

CONST_GAME_ZONE_EXIT = {
	1458.161, 1631.061,
	1439.597, 1660.265,
	1404.279, 1735.820,
	1612.499, 1866.476,
	1643.867, 1818.931,
	1709.444, 1861.462,
	1722.054, 1908.740,
	1676.098, 1920.720,
	1670.674, 1940.169,
	1674.473, 1956.966,
	1685.293, 2006.961,
	1684.031, 2053.999,
	1673.093, 2092.622,
	1623.093, 2222.757,
	1604.972, 2311.808,
	1598.189, 2382.575,
	1605.060, 2429.830,
	1621.005, 2469.613,
	1636.537, 2498.326,
	1660.907, 2501.528,
	1753.570, 2467.733,
	1778.494, 2461.179,
	1821.240, 2470.921,
	1830.272, 2481.894,
	1859.969, 2635.324,
	1948.187, 2646.123,
	1973.081, 2639.653,
	2087.715, 2581.379,
	2070.271, 2551.291,
	1961.117, 2375.779,
	1866.971, 2412.902,
	1821.540, 2418.272,
	1785.931, 2404.906,
	1762.929, 2383.605,
	1747.637, 2352.198,
	1746.995, 2308.511,
	1771.910, 2264.489,
	1846.530, 2204.301,
	1846.298, 2192.351,
	1841.527, 2167.017,
	1754.639, 1859.183,
	1731.474, 1821.313,
	1706.693, 1801.667,
	1708.148, 1799.763,
	1505.930, 1671.723,
	1506.073, 1668.653,
	1467.371, 1635.229,
	1458.161, 1631.061,
}

CONST_GAME_ZONE_ENTER = {
	1468.347, 1665.669,
	1454.745, 1667.781,
	1446.810, 1688.621,
	1445.193, 1705.563,
	1435.595, 1733.794,
	1490.742, 1768.603,
	1495.144, 1776.608,
	1589.576, 1833.896,
	1600.374, 1835.211,
	1603.507, 1842.169,
	1605.751, 1842.134,
	1635.397, 1793.628,
	1714.096, 1840.926,
	1731.736, 1859.615,
	1746.065, 1920.060,
	1693.682, 1934.299,
	1687.031, 1939.909,
	1694.279, 1964.196,
	1700.444, 1988.934,
	1703.176, 2013.270,
	1698.937, 2030.784,
	1697.896, 2051.737,
	1691.860, 2080.771,
	1630.747, 2247.726,
	1612.890, 2361.146,
	1623.237, 2439.744,
	1641.710, 2480.462,
	1650.404, 2487.013,
	1664.352, 2487.016,
	1759.651, 2449.893,
	1789.870, 2435.373,
	1834.366, 2437.467,
	1869.149, 2612.480,
	1884.220, 2625.692,
	1941.351, 2632.136,
	1973.521, 2624.996,
	2053.881, 2583.641,
	2060.936, 2562.600,
	2048.192, 2540.080,
	1980.813, 2431.583,
	1961.170, 2401.705,
	1938.670, 2398.167,
	1845.427, 2435.633,
	1832.998, 2431.771,
	1817.434, 2430.421,
	1789.645, 2423.279,
	1771.164, 2409.671,
	1755.240, 2395.390,
	1739.604, 2371.590,
	1728.641, 2332.993,
	1734.293, 2285.883,
	1765.890, 2251.965,
	1825.828, 2205.460,
	1831.409, 2201.414,
	1833.732, 2198.286,
	1833.699, 2189.838,
	1830.302, 2171.031,
	1805.167, 2083.534,
	1798.374, 2076.033,
	1782.889, 2021.368,
	1782.201, 2002.519,
	1745.200, 1873.420,
	1726.104, 1836.412,
	1709.157, 1824.344,
	1697.167, 1809.273,
	1468.347, 1665.669,
}