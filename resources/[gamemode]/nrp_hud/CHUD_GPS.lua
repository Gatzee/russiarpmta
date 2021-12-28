Extend( "ShGpsNodes" )

local math_sqrt = math.sqrt
local mode_calculation = true

GPS = 
{
	coroutine = nil,

	node_1 = nil,
	node_2 = nil,

	draw_path = nil,
	path_data = nil,

	enalbe = true,
	stop_draw = false,
	is_cleanup_path = false,

	time_calc_path = nil,
	const_time_recalc = 300,
	const_couroutine_ticks_calc = 6,

	delay_time = 17,

	func_start_calc_path = function( self, x2, y2 )
		if not isElement( localPlayer.vehicle ) then return end
		if x2 and y2 then self.node_2 = get_node_by_world_position( x2, y2 ) end

		local player_position =localPlayer.position
		self.node_1 = get_node_by_world_position( player_position.x, player_position.y )

		if not self.node_1 or not self.node_2 or self.node_1 == self.node_2 then
			return false
		end

		local draw_point_id, draw_point_node_id = nil, nil
		for k, v in pairs( self.draw_path or {} ) do
			if v.id == self.node_1 then
				draw_point_id, draw_point_node_id = k, v.id
				break
			end
		end
		if draw_point_id then
			for k, v in pairs( self.draw_path ) do
				if k > draw_point_id then
					self.draw_path[ k ] = nil
				end
			end

			self.start_await_recalc_ticks = getTickCount()
			self.await_time = self.const_time_recalc
			addEventHandler( "onClientRender", root, self.func_render_await_recalc )
			return
		end	

		self.start_calc_ticks = getTickCount()
		self.time_calc_path   = self.start_calc_ticks
		
		self.stop_draw = false
		self.coroutine = coroutine.create( ProcessPathCalcAStar )
		
		self:func_resume_calc()
	end,

	func_resume_calc = function( self )
		if self.stop_draw then return end
		
		self.start_calc_ticks = getTickCount()
		
		local status, data = coroutine.resume( self.coroutine, self.node_1, self.node_2 )
		if self.stop_draw then
			self.coroutine = nil
			return
		end

		if data then
			self:func_set_current_path( data )
		else
			self.start_await_resume_ticks = getTickCount()
			addEventHandler( "onClientRender", root, self.func_render_await )
		end
	end,

	func_stop_draw_path = function( self, is_destroy )
		self.stop_draw = true
		if is_destroy then self.route_id = nil end

		self.draw_path = nil
		self:refresh_ui( true )

		self.node_1, self.node_2 = nil, nil
		
		self.start_await_recalc_ticks = nil
		self.start_await_resume_ticks = nil
		self.time_calc_path = nil
		self.start_calc_ticks = nil

		removeEventHandler( "onClientRender", root, GPS.func_render_await )
		removeEventHandler( "onClientRender", root, GPS.func_render_await_recalc )
	end,

	func_set_current_path = function( self, data )
		self.draw_path = data
		self.time_calc_path = getTickCount() - self.time_calc_path
		local diff = self.time_calc_path - self.const_time_recalc
		if diff < 0 then
			self.start_await_recalc_ticks = getTickCount()
			self.await_time = diff * -1
			addEventHandler( "onClientRender", root, self.func_render_await_recalc )
		
		elseif not self.stop_draw then
			self:refresh_ui()
			self:func_start_calc_path()
		end
	end,

	refresh_ui = function( self, stop )
		if FUNC_UPDATE_BLIPS_RADAR_MAP then 
			FUNC_UPDATE_BLIPS_RADAR_MAP()
			if stop then
				HUD_CONFIGS.radar.fns.UpdateBlips( true )
			end
		else
			HUD_CONFIGS.radar.fns.UpdateBlips( true )
		end
	end,

	func_render_await = function()
		if getTickCount() - GPS.start_await_resume_ticks > GPS.delay_time then
			removeEventHandler( "onClientRender", root, GPS.func_render_await )
			GPS.start_await_resume_ticks = nil

			GPS:func_resume_calc()
		end
	end,

	func_render_await_recalc = function()
		if getTickCount() - GPS.start_await_recalc_ticks > GPS.await_time then
			removeEventHandler( "onClientRender", root, GPS.func_render_await_recalc )
			
			if not GPS.stop_draw then
				GPS:refresh_ui()
				GPS:func_start_calc_path() 
			end
		end
	end,
}

function IsCanGenerateRoute()
	if not GPS.enalbe or localPlayer:getData( "in_race") then return end
	return true
end

function onClientTryGenerateGPSPath_handler( data, near )
	if not IsCanGenerateRoute() then return end

	GPS.path_data = { data = data, near = near }

	local player_vehicle = localPlayer.vehicle
	if not player_vehicle or IsSpecialVehicle( player_vehicle.model ) then
		return 
	end

	if not data then return end
	if type( data ) == "table" and data[ 1 ] then
		local min_index = 1
		local min_len = getDistanceBetweenPoints3D( data[1].x, data[1].y, data[1].z, localPlayer.position )

		for i, pos in pairs( data ) do
			local len = getDistanceBetweenPoints3D( pos.x, pos.y, pos.z, localPlayer.position )
			if len < min_len then
				min_index = i
				min_len = len
			end
		end

		data = data[ min_index ]
	end
	
	if data.x and data.y then
		GPS:func_stop_draw_path( true )
		GPS:func_start_calc_path( data.x, data.y )
		GPS.route_id = data.route_id
	end
end
addEvent( "onClientTryGenerateGPSPath" )
addEventHandler( "onClientTryGenerateGPSPath", root, onClientTryGenerateGPSPath_handler )

function onClientTryDestroyGPSPath_handler( route_id )
	if not route_id or GPS.route_id == route_id then
		GPS:func_stop_draw_path( true )
		GPS.path_data = nil
	end
end
addEvent( "onClientTryDestroyGPSPath" )
addEventHandler( "onClientTryDestroyGPSPath", root, onClientTryDestroyGPSPath_handler )

function onClientElementDestroy_handler()
	if last_player_vehicle == source then GPS:func_stop_draw_path() end
end
addEventHandler( "onClientElementDestroy", root, onClientElementDestroy_handler )

function onClientPlayerVehicleExit_handler()
	if not GPS.stop_draw then
		GPS:func_stop_draw_path()
		last_player_vehicle = nil
	end
end
addEventHandler( "onClientPlayerVehicleExit", localPlayer, onClientPlayerVehicleExit_handler )

function onClientPlayerVehicleEnter_handler( vehicle )
	if not GPS.path_data or IsSpecialVehicle( vehicle.model ) then return end
	last_player_vehicle = vehicle
	
	onClientTryGenerateGPSPath_handler( GPS.path_data.data, GPS.path_data.near )

	local target_players = {}
    for k, v in pairs( getVehicleOccupants( vehicle ) ) do
        if v ~= localPlayer then
            table.insert( target_players, v )
        end
    end
    if #target_players == 0 then return end

	local gps_marker = GPS.path_data.data
    triggerServerEvent( "onServerRequestCreateGPSTag", root, { x = gps_marker.x, y = gps_marker.y, z = gps_marker.z } )
end
addEventHandler( "onClientPlayerVehicleEnter", localPlayer, onClientPlayerVehicleEnter_handler )

function get_node_by_world_position( x, y )
    local node_id, distance = nil, math.huge
	
	local function GetDistanceBetweenCoords( x1, y1, x2, y2 ) 
		return math_sqrt( (x2 - x1)^2 + (y2 - y1)^2 ) 
	end

    for k, v in pairs( NODES ) do
        local cur_distance = GetDistanceBetweenCoords( x, y, v.x, v.y )
        if cur_distance < distance then
            node_id, distance = k, cur_distance 
        end
    end

    if node_id and distance < 350 then
        return node_id
    end

    return false
end

function get_heuristic_cost( node_1, node_2 )
	return math_sqrt( (node_2.x - node_1.x)^2 + (node_2.y - node_1.y)^2 )
end

function dist_between( node_1, node_2 )
	return math_sqrt( (node_2.x - node_1.x)^2 + (node_2.y - node_1.y)^2 )
end

function ProcessPathCalcAStar( node_start, node_end )
    local ways = {}
    local openset   = { [ node_start ] = true }
    local closedset = {}
	
	local g_score = { [ node_start ] = 0 }
	local f_score = { [ node_start ] = g_score[ node_start ] + get_heuristic_cost( NODES[ node_start ], NODES[ node_end ] ) }
    
    while true do
        if getTickCount() - GPS.start_calc_ticks > GPS.const_couroutine_ticks_calc then coroutine.yield() end

        local bester_node_id, bester_node_score = -1, 12000
		for node_id in pairs( openset ) do
	    	if f_score[ node_id ] < bester_node_score then
	    		bester_node_id, bester_node_score = node_id, f_score[ node_id ]
	    	end
        end
		
		if bester_node_id == node_end then
            local finish_path = {}

            local node_number = 1
            local way_node_id = node_end
            while way_node_id ~= nil do
				finish_path[ node_number ] = NODES[ way_node_id ]
				finish_path[ node_number ].id = way_node_id
                node_number = node_number + 1
                way_node_id = ways[ way_node_id ]
            end
            coroutine.yield( finish_path )
		elseif bester_node_id == -1 then
            return false
        end
        
        openset[ bester_node_id ], closedset[ bester_node_id ] = nil, true
        
		for _, v in pairs( NODES[ bester_node_id ].neighbours ) do 
			if not closedset[ v.id ] and bester_node_id ~= v.unidir then
                
                local tentative_g_score = g_score[ bester_node_id ] + dist_between( NODES[ bester_node_id ], NODES[ v.id ] ) 
				if not openset[ v.id ] or tentative_g_score < g_score[ v.id ] then 
					ways[ v.id ]    = bester_node_id
					g_score[ v.id ] = tentative_g_score
					f_score[ v.id ] = g_score[ v.id ] + get_heuristic_cost( NODES[ v.id ], NODES[ node_end ] )
                    
                    if not openset[ v.id ] then openset[ v.id ] = true end
				end
			end
        end
    end
end

--[[
function ProcessPathCalc( node_id_1, node_id_2 )
    local ways = {}
    local current_nodes = {}
    local used_nodes = { [ node_id_1 ] = true }

	local start_node, finish_node = NODES[ node_id_1 ], NODES[ node_id_2 ]
    for _, v in pairs( start_node.neighbours ) do
		used_nodes[ v.id ] = true
		current_nodes[ v.id ] = v.distance
		ways[ v.id ] = { node_id_1 }
	end
	
	while true do
		if getTickCount() - GPS.start_calc_ticks >= GPS.const_couroutine_ticks_calc then coroutine.yield() end

        local bester_node_id, bester_node_distance = -1, 12000
		for node_id, node_distancne in pairs( current_nodes ) do
            if node_distancne < bester_node_distance then
				bester_node_id, bester_node_distance = node_id, node_distancne
			end
        end
        
        if bester_node_id == -1 then 
            return false
        elseif node_id_2 == bester_node_id then
            local finish_path = {}

            local node_number = 1
            local way_node_id = bester_node_id
			while way_node_id ~= nil do
				finish_path[ node_number ] = NODES[ way_node_id ]
				node_number = node_number + 1		
				way_node_id = ways[ way_node_id ]
			end
			            
			coroutine.yield( finish_path )
		end
		
		for _, v in pairs( NODES[ bester_node_id ].neighbours ) do
            if not used_nodes[ v.id ] and bester_node_id ~= v.unidir then
                used_nodes[ v.id ] = true
                current_nodes[ v.id ] = bester_node_distance + v.distance
				ways[ v.id ] = bester_node_id
			end
        end
        
		current_nodes[ bester_node_id ] = nil
	end
end
--]]

function onSettingsChange_handler( changed, values )
	if changed.gps_enalbe ~= nil then
		GPS.enalbe = values.gps_enalbe
		onClientTryDestroyGPSPath_handler()
	elseif changed.gps_quality then
		GPS.const_couroutine_ticks_calc = 6 - values.gps_quality
	end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )


local GPS_TAGS = {}
local CONST_BLIP_ICON_ID = 84
local CONST_COLOR_PASSENGER_PLACE =
{
    [ 0 ] = 0xFFCD5C5C,
    [ 1 ] = 0XFFFFA500,
    [ 2 ] = 0XFF1E90FF,
    [ 3 ] = 0XFF00FF00,
}

function CreateGPSTag( player, position )
	if GPS_TAGS[ player ] then return end
	
	GPS_TAGS[ player ] = createBlip( Vector3( position ) )
    setElementData( GPS_TAGS[ player ], "extra_blip", CONST_BLIP_ICON_ID, false )
    setElementData( GPS_TAGS[ player ], "extra_blip_color", CONST_COLOR_PASSENGER_PLACE[ player.vehicleSeat ], false )
    setElementData( GPS_TAGS[ player ], "extra_blip_element", player, false )
end

function onClientCreateGPSTag_handler( position )
    if not position or source.vehicle ~= localPlayer.vehicle then return end
    
	CreateGPSTag( source, position )
end
addEvent( "onClientCreateGPSTag", true )
addEventHandler( "onClientCreateGPSTag", root, onClientCreateGPSTag_handler )

function onClientCreateTableGPSTags_handler( other_gps_player_markers )
    for k, v in pairs( other_gps_player_markers ) do
		CreateGPSTag( v.player, v.target_position )
	end
end
addEvent( "onClientCreateTableGPSTags", true )
addEventHandler( "onClientCreateTableGPSTags", root, onClientCreateTableGPSTags_handler )

function onClientDestroyGPSTag_handler()
    if source == localPlayer then
        for k, v in pairs( GPS_TAGS ) do destroyElement( v ) end
        GPS_TAGS = {}
    elseif GPS_TAGS[ source ] then
        GPS_TAGS[ source ]:destroy()
        GPS_TAGS[ source ] = nil
    end
    
    triggerEvent( "RefreshRadarBlips", localPlayer )
end
addEventHandler( "onClientPlayerQuit", root, onClientDestroyGPSTag_handler )
addEventHandler( "onClientPlayerVehicleExit", root, onClientDestroyGPSTag_handler )

addEvent( "onClientDestroyGPSTag", true )
addEventHandler( "onClientDestroyGPSTag", root, onClientDestroyGPSTag_handler )