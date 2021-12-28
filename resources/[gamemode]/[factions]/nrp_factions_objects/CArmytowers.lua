--[[
    19629, tower, 0, -2295.89, 959.889, 15.0154, 0.0, 0.0, 0.707107, 0.707107, -1
    19629, tower, 0, -2444.22, 959.889, 15.0154, 0.0, 0.0, 0.707107, 0.707107, -1
    19629, tower, 0, -2290.89, 570.783, 17.1598, 0.0, 0.0, -0.707107, 0.707107, -1
    19629, tower, 0, -2622.16, 557.778, 16.7234, 0.0, 0.0, -0.707107, 0.707107, -1
    19629, tower, 0, -2290.89, 832.652, 17.1598, 0.0, 0.0, -0.707107, 0.707107, -1
    19629, tower, 0, -2625.75, 776.2, 17.5142, 0.0, 0.0, 0.0, 1.0, -1
]]

local MODEL = 1332

local OBJECTS = {
    { -2633.472, 782.106, 16, 0.0, 0.0, 0.125 },
    { -2629.918, 548.952, 15.5, 0.0, 0.0, 0 },
    { -2293.276, 561.129, 17.1, 0.0, 0.0, 0.5 },
    { -2283.047, 715.740, 17, 0.0, 0.0, -0.25 },
    { -2295.561, 966.348, 16.5, 0.0, 0.0, 0.55 },
    { -2450.797, 966.353, 16.3, 0.0, 0.0, 0 },
    { -2458.112, 793.333, 16.5, 0.0, 0.0, 0.25 },
}

local col = engineLoadCOL( "models/tower.col" )
engineReplaceCOL( col, MODEL )
local txd = engineLoadTXD( "models/tower.txd" )
engineImportTXD( txd, MODEL )
local dff = engineLoadDFF( "models/tower.dff" )
engineReplaceModel( dff, MODEL )

for i, v in pairs( OBJECTS ) do

    local x, y, z, rx, ry, rz = unpack( v )

    rx = rx * 360
    ry = ry * 360
    rz = rz * 360

    v.object = createObject( MODEL, x, y, z, rx, ry, rz )
    v.object.dimension = -1
    setObjectBreakable( v.object, false )
    setElementFrozen( v.object, true )
end