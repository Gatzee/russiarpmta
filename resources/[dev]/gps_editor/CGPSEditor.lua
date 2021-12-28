loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "ib" )
Extend( "Globals" )
Extend( "CPlayer" )
Extend( "ShGpsNodes" )

iprint("loaded_nodes", #NODES)

-----------------------------------------------
-- node func
-----------------------------------------------

function AddNode( x, y )
    local node_data = GetNodeByWorldPosition( x, y )
    if node_data then return false end

    table.insert( NODES, {
        x = x,
        y = y,
        neighbours = {},
    } )

    return #NODES
end

function RemoveNode( x, y )
    local node_id = GetNodeByWorldPosition( x, y )
    local node_data = NODES[ node_id ]
    if not node_data then return false end

    for _, neighbour_data in pairs( node_data.neighbours ) do
        RemoveNeighbours( neighbour_data.id, node_id )
    end
    
    table.remove( NODES, node_id )
    
    for k, v in pairs( NODES ) do
        for _, neighbour_data in pairs( NODES[ k ].neighbours ) do
            if neighbour_data.id > node_id then
                neighbour_data.id = neighbour_data.id - 1
            end
            if neighbour_data.unidir and neighbour_data.unidir > node_id then
                neighbour_data.unidir = neighbour_data.unidir - 1
            end
        end
    end

    return true
end

function AddNeighbours( node_id_1, node_id_2, unidir )
    if not NODES[ node_id_1 ] or not NODES[ node_id_2 ] then return end

    local is_neighbour_exists = IsNeighbourExists( node_id_1, node_id_2 )
    if is_neighbour_exists then return false end

    local distance = GetDistanceBetweenCoords( NODES[ node_id_1 ].x, NODES[ node_id_1 ].y, NODES[ node_id_2 ].x, NODES[ node_id_2 ].y )
    table.insert( NODES[ node_id_1 ].neighbours, {
        id = node_id_2,
        distance = distance,
        unidir = unidir and node_id_2,
    } )

    table.insert( NODES[ node_id_2 ].neighbours, {
        id = node_id_1,
        distance = distance,
        unidir = unidir and node_id_2,
    } )

    return true
end

function IsNeighbourExists( node_id_1, node_id_2 )
    for k, v in pairs( NODES[ node_id_1 ].neighbours ) do
        if v.id == node_id_2 then
            return true
        end
    end

    return false
end

function RemoveNeighbours( node_id, neighbour_id )
    local node_data = NODES[ node_id ]
    if not node_data then return end
    
    for k, v in pairs( node_data.neighbours ) do
        if v.id == neighbour_id then
            table.remove( node_data.neighbours, k )
            return true
        end
    end

    return false
end

function GetNodeByWorldPosition( x, y, max_dist )
    local max_dist = max_dist or 5
    local node_id, distance = nil, math.huge
    
    for k, v in pairs( NODES ) do
        local cur_distance = GetDistanceBetweenCoords( x, y, v.x, v.y )
        if cur_distance < distance then
            node_id, distance = k, cur_distance 
        end
    end

    if node_id and distance < max_dist then
        return node_id
    end

    return false
end

-----------------------------------------------
-- path finder
-----------------------------------------------

function GeneraPath( x1, y1, x2, y2 )
    local ticks = getTickCount()
    local path = ProcessPathCalc( GetNodeByWorldPosition( x1, y1, 100 ), GetNodeByWorldPosition( x2, y2, 300 ) )
    if not path then 
        localPlayer:ShowInfo( "Не удалось построить маршрут" )
        return 
    end
    
    table.insert( path, 1, { x = x1, y = y1, distance = 0 } )
    table.insert( path,    { x = x2, y = y2, distance = 0 } )

    iprint( "time_to_find_path:", getTickCount() - ticks )

    return path
end

function ProcessPathCalc( node_id_1, node_id_2 )
    if not node_id_1 or not node_id_2 or node_id_1 == node_id_2 then
        return false
    end
    
    local start_node, finish_node = NODES[ node_id_1 ], NODES[ node_id_2 ]

    local ways = {}
    local current_nodes = {}
    local used_nodes = { [ node_id_1 ] = true }

    for _, v in pairs( start_node.neighbours ) do
		used_nodes[ v.id ] = true
		current_nodes[ v.id ] = v.distance
		ways[ v.id ] = { node_id_1 }
	end
    
    while true do
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
            
            finish_path = table.reverse( finish_path )
			return finish_path
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

function GetPath( t_x, t_y )
    local path = GeneraPath( getCamera().position.x, getCamera().position.y, t_x, t_y )
    if not path then return end
    
    DRAW_PATH = path
    UI_elements.update_nodes()

    --DrawMarkersPath()
end

local path_colshapes = {}
function DrawMarkersPath()
    DestroyTableElements( path_colshapes )
    path_colshapes = {}

    local current_marker = 1
    for k, v in ipairs( path ) do
        local colshape = createColCircle( v.x, v.y, 5 )
        
        local marker = createMarker( v.x, v.y, 0, "checkpoint", 5 )
        setElementParent( marker, colshape )
        
        local blip = createBlipAttachedTo( marker )
        setElementParent( blip, marker )
        
        addEventHandler( "onClientColShapeHit", colshape, function()
            if current_marker == k then
                destroyElement( source )
                current_marker = current_marker + 1
            end
        end )

        path_colshapes[ k ] = colshape
    end
end

-----------------------------------------------
-- Utils
-----------------------------------------------

function table.reverse( t )
	local newt = {}
	for idx,item in ipairs(t) do
		newt[#t - idx + 1] = item
	end
	return newt
end

function math.round( num,  idp )
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function GetDistanceBetweenCoords( x1, y1, x2, y2 ) 
    return math.sqrt( (x2 - x1)^2 + (y2 - y1)^2 ) 
end

function SaveCoordinates()
    ExportFinishFile()
end

function ExportFinishFile()
    local file_export = fileCreate( "nodes_export.json" )
    fileWrite( file_export, "NODES = \n{\n" )
    
    for k, v in pairs( NODES ) do
        local export_content = ""
        export_content = export_content .. "\t{\n\t\tx = " .. math.round( v.x, 4) .. ", y = " .. math.round( v.y, 4 ) .. (v.z and (", z = " .. v.z) or "") .. ",\n \t\tneighbours = { "
        for _, neighbour_date in pairs( v.neighbours ) do
            export_content = export_content .. "{ id = " .. neighbour_date.id .. ", distance = " .. neighbour_date.distance .. ", "
            if neighbour_date.unidir then
                export_content = export_content .. "unidir = " .. neighbour_date.unidir
            end
            export_content = export_content .. "}, "
        end
        export_content = export_content .. "},\n\t},\n"
        fileWrite( file_export, export_content )
    end
    
    fileWrite( file_export, "}\n return NODES" )
    fileClose( file_export )
end

addCommandHandler( "reload_nodes", function()
	local file = fileOpen( "nodes_export.json" )
	local file_content = fileRead( file, fileGetSize(file) )
	fileClose( file )
	NODES = loadstring( file_content )()
end )

local is_showed_nodes = false

function ShowNodes()
    local x, y, z = getElementPosition( localPlayer )
    z = z
    local neighbours_completed = {}
    for k, v in pairs( NODES ) do
        if GetDistanceBetweenCoords( x, y, v.x, v.y ) < 200 then
            dxDrawLine3D( v.x, v.y, z, v.x - 1, v.y - 1, z, 0xFF00FF00, 10, true )            
            for neighbour_key, neighbour_data in pairs( v.neighbours ) do
                local neighbour_id = neighbour_data.id
                if not neighbours_completed[ k .. neighbour_id ] and not neighbours_completed[ neighbour_id .. k ] then
                    dxDrawLine3D( v.x, v.y, z, NODES[ neighbour_id ].x, NODES[ neighbour_id ].y, z, 0xFFFF0000, 10, true )
                    neighbours_completed[ neighbour_id .. k ] = true
                    neighbours_completed[ k .. neighbour_id ] = true
                end
            end
        end
    end
end

addCommandHandler( "show_nodes", function()
    is_showed_nodes = not is_showed_nodes
    if is_showed_nodes then
        addEventHandler( "onClientRender", root, ShowNodes )
    else
        removeEventHandler( "onClientRender", root, ShowNodes )
    end
end )

addCommandHandler( "change_node", function()
    local node = GetNodeByWorldPosition( localPlayer.position.x, localPlayer.position.y, 15 )
    if node then
        NODES[ node ].x = localPlayer.position.x
        NODES[ node ].y = localPlayer.position.y
    end
end )
