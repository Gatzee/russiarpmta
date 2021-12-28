Extend( "ib" )
Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "CInterior" )
Extend( "CActionTasksUtils" )
Extend( "CAI" )
Extend( "CUI" )

engineLoadIFP( "ifp/dead.ifp", "tutorial.dead" )
engineLoadIFP( "ifp/razgovor.ifp", "Razgovor" )

local _BlockAllKeys = BlockAllKeys
function BlockAllKeys( ... )
    local result = _BlockAllKeys( ... )
    ibAutoclose( )
    return result
end

function onClientPlayerDamage_handler()
	cancelEvent()
end

function AddRestoreVehiclePostion()
    removeRestoreVehiclePostion()
    RESTORE_TMR = setTimer( function()
        local vehicle = localPlayer.vehicle
        if vehicle then
            if (vehicle.position - Vector3( 1772, -631+860, 60 )).length > 400 then
                vehicle.position = Vector3( 1810.2163, -551.8115+860, 60.5469 )
                vehicle.rotation = Vector3( 0, 0, 60 )
            end
        end
    end, 1000, 0 )
end

function removeRestoreVehiclePostion()
    if isTimer( RESTORE_TMR ) then killTimer( RESTORE_TMR ) end
end

--[[function GetTargetCameraMatrix( )
    local mx_old = { getCameraMatrix( ) }
    setCameraTarget( localPlayer )
    local mx = { getCameraMatrix( ) }
    setCameraMatrix( unpack( mx_old ) )

    return unpack( mx )
end

local from = { 1809.5186767578, 264.42700195313, 68.569602966309, 1763.6663818359, 178.28594970703, 46.722808837891 }
local to = { GetTargetCameraMatrix( ) }
smoothMoveCamera( from[1], from[2], from[3], from[4], from[5], from[6], to[1], to[2], to[3], to[4], to[5], to[6], 5000 )]]

--[[Extend( "CBezierPaths" )

local path = {
    { 1964.034, 424.756 },
    { 1864.187, 354.846 },
    { 1821.289, 325.250 },
    { 1816.782, 261.908 },
}

local function Smooth( path, weight_data, weight_smooth, tolerance )
    local weight_data = weight_data or 0.5
    local weight_smooth = weight_smooth or 0.1
    local tolerance = tolerance or 0.0000001

    local new = { }
    for i, v in pairs( path ) do
        table.insert( new, v )
    end

    local dimensions = #path[ 1 ]
    local change = tolerance

    while change >= tolerance do
        change = 0.0
        for i = 2, #new - 1 do
            for j = 1, dimensions do
                x_i = path[ i ][ j ]
                
                y_i, y_prev, y_next = new[ i ][ j ], new[ i - 1 ][ j ], new[ i + 1 ][ j ]

                y_i_saved = y_i
                y_i = y_i + weight_data * ( x_i - y_i ) + weight_smooth * ( y_next + y_prev - ( 2 * y_i ) )
                new[ i ][ j ] = y_i

                change = change + math.abs( y_i - y_i_saved )
            end
        end
    end

    return new
end

local smooth_path = Smooth( path, 0.1, 0.05, 0000.1 )

addEventHandler( "onClientRender", root, function( )
    for i = 1, #smooth_path - 1 do
        dxDrawLine3D( smooth_path[ i ][ 1 ], smooth_path[ i ][ 2 ], localPlayer.position.z, smooth_path[ i + 1 ][ 1 ], smooth_path[ i + 1 ][ 2 ], localPlayer.position.z, 0xFFFFFFFF, 2 )
    end
end )]]

--[[local function CreatePath( path )
    for i = 1, #path, 2 do
        if path[ i + 1 ] then

            local point_a = path[ i ]
            local point_b = path[ i + 1 ]

            local bezier = BezierCurve:new( )

            bezier:compute( {
                point_a,
                point_b,
                point_a,
                point_b,
            }, 50 )

            bezier:debug_draw( 0xFFFF0000, 2 )
        end
        --break
    end
end

CreatePath( path )]]

--[[local bezier = BezierCurve:new( )

bezier:compute( {
    Vector2( 1964.034, 424.756 ),
    Vector2( 1864.187, 354.846 ),
    Vector2( 1821.289, 325.250 ),
    Vector2( 1816.782, 261.908 ),
}, 99 )

bezier:debug_draw( 0xFFFF0000, 2 )]]