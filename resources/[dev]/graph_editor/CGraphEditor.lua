loadstring(exports.interfacer:extend("Interfacer"))()
Extend( "ib" )
Extend( "Globals" )
Extend( "CPlayer" )

NODES = {}


-----------------------------------------------
-- node func
-----------------------------------------------

function AddNode( x, y )
    local near_node_id = GetNodeByWorldPosition( x, y )
    if near_node_id then 
        if not LAST_NODE_ID or IsNeighbourExists( LAST_NODE_ID, near_node_id ) then return false end

        AddNeighbours( near_node_id, LAST_NODE_ID )
        LAST_NODE_ID = nil

        return near_node_id
    end

    table.insert( NODES, {
        x = x,
        y = y,
        tostring = function( self, separator )
            return "{ " .. math.round( self.x, 4 ) .. ", " .. math.round( self.y, 4 ) .. " }" .. (separator or "")
        end,
        tostring_x_y = function( self, separator )
            return "{ x = " .. math.round( self.x, 4 ) .. ", y = " .. math.round( self.y, 4 ) .. " }" .. (separator or "")
        end,
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
    if not node_id_1 or not node_id_2 then return end

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

local is_showed_nodes = false
addCommandHandler( "g_nodes", function()
    is_showed_nodes = not is_showed_nodes
    if is_showed_nodes then
        addEventHandler( "onClientRender", root, ShowNodes )
    else
        removeEventHandler( "onClientRender", root, ShowNodes )
    end
    localPlayer:ShowInfo( is_showed_nodes and "Точки отображены" or "Точки скрыты" )
end )

addCommandHandler( "g_reset", function()
	NODES = {}
    localPlayer:ShowInfo( "Точки сброшены" )
end )

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

-----------------------------------------------
-- Export
-----------------------------------------------

function ExportGraph()
    local groups = {}
    local groups_count = 0
    local get_group_index = function( target_node )
        for group_id, group_items in pairs( groups ) do
            for _, node_id in pairs( group_items ) do
                if IsNeighbourExists( target_node, node_id ) then
                    return group_id
                end
            end
        end

        groups_count = groups_count + 1
        return groups_count
    end
    
    for k, v in ipairs( NODES ) do
        local group_index = get_group_index( k )
        if not groups[ group_index ] then groups[ group_index ] = {} end

        table.insert( groups[ group_index ], k )
    end

    local export_content = ""
    for group_id, group_items in pairs( groups ) do
        export_content = export_content .. "\n{\n"
        for _, node_id in pairs( group_items ) do
            export_content = export_content .. "\t" .. NODES[ node_id ]:tostring_x_y( ",\n" )
        end
        export_content = export_content .. "},"
    end
    
    if setClipboard( export_content ) then
        localPlayer:ShowInfo( "Данные скопированы в буффер обмена" )
    end

    local file_export = fileCreate( "graph_export.json" )
    fileWrite( file_export, export_content )
    fileClose( file_export )
end