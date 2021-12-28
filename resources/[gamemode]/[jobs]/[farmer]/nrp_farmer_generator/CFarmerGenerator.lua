LINES = { }

LINES_CONFIG = {
    -- FARM 1
    -- Line 1
    --[[{ 
        base = Vector3( -1319.0999755859, 622.09997558594, 28.799999237061 ),
        target = Vector3( -1307.9000244141, 571.26000976563, 26.930000305176 ),
        amount = 25,
        object_id = 628,
        object_offset = Vector3( 0, 0, 1 ),
    },
    -- Line 2
    { 
        base = Vector3( -1324.0100097656, 622.09002685547, 28.670000076294 ),
        target = Vector3( -1307.9000244141, 571.26000976563, 26.930000305176 ),
        amount = 25,
        object_id = 628,
        object_offset = Vector3( 0, 0, 1 ),
    },
    -- Line 3
    { 
        base = Vector3( -1329.2700195313, 621.75, 28.670000076294 ),
        amount = 25,
        object_id = 628,
        object_offset = Vector3( 0, 0, 1 ),
    },
    -- Line 4
    { 
        base = Vector3( -1334.1700439453, 620.51000976563, 28.670000076294 ),
        amount = 25,
        object_id = 628,
        object_offset = Vector3( 0, 0, 1 ),
    },
    -- Line 5
    { 
        base = Vector3( -1339.1700439453, 619.78997802734, 28.670000076294 ),
        amount = 25,
        object_id = 628,
        object_offset = Vector3( 0, 0, 1 ),
    },]]
}

local OBJECTS = { }

local object_amount = 25
local object_id = 628
local object_offset = Vector3( 0, 0, 1 )
local diff = Vector3( 0, 0, 10 )

function onRender( )
    local objects = getElementsByType( "object" )
    for i, start_object in pairs( objects ) do
            local id = getElementID( start_object )
            local line_num = id and string.match( id, "line_(%d+)_start" )

            if line_num then
                local end_id = "line_" .. line_num .. "_end"
                local end_object = getElementByID( end_id )
                if end_object then
                    if not OBJECTS[ line_num ] then
                        OBJECTS[ line_num ] = { }
                    end

                    local difference = ( end_object.position - start_object.position ) / object_amount
                    local position = start_object.position - difference
                    for obj_num = 1, object_amount + 1 do
                        position = position + difference

                        local hit, _, _, z = processLineOfSight( position - diff, position + diff, true, true, true, true, true, true, true, true, OBJECTS[ line_num ][ obj_num ] )

                        position.z = z

                        if OBJECTS[ line_num ][ obj_num ] then
                            OBJECTS[ line_num ][ obj_num ].position = position
                        else
                            local object = createObject( object_id, position )
                            setElementCollisionsEnabled( object, false )
                            setElementData( object, "generated", true, false )
                            object.dimension = localPlayer.dimension

                            table.insert( OBJECTS[ line_num ], object )
                        end
                    end

                end
            end
    end
end
addEventHandler( "onClientPreRender", root, onRender )

addCommandHandler( "save", function()
    local lines = { }

    local lines_num = 1
    for line_number, line_objects in pairs( OBJECTS ) do
        if not lines[ lines_num ] then lines[ lines_num ] = { } end
        for obj_num, object in pairs( line_objects ) do
            local position = object.position
            table.insert( lines[ lines_num ], { x = position.x, y = position.y, z = position.z } )
        end
        lines_num = lines_num + 1
    end
    local json = toJSON( lines, true )
    local file = fileCreate( "lines.json" )
    fileWrite( file, json )
    fileClose( file )

    --iprint( "Saved lines:", #lines )
end )

addCommandHandler( "load", function()
    local file = fileOpen( "lines.json" )
    local tbl = fromJSON( fileRead( file, fileGetSize( file ) ) )
    for i, v in pairs( tbl ) do
        for n, t in pairs( v ) do
            local object = createObject( object_id, t.x, t.y, t.z + 1 )
            setElementCollisionsEnabled( object, false )
            object.dimension = localPlayer.dimension
        end
    end
    fileClose( file )
end )