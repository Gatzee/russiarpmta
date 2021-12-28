NORMAL_MINUTE_COST = 500
VIP_MINUTE_COST    = 1000

function GetVideoCost( video, is_vip )
    return math.floor( video.duration_seconds / 60 * ( is_vip and VIP_MINUTE_COST or NORMAL_MINUTE_COST ) )
end

NORMAL_DURATION = 15 * 60
VIP_DURATION    = 60 * 60

function GetReadableDuration( time )
    local hours = math.floor( time / 60 / 60 )
    local minutes = math.floor( ( time - hours * 60 * 60 ) / 60 )
    local seconds = math.floor( ( ( time - hours * 60 * 60 ) - minutes * 60 ) )

    local str = minutes .. " мин. " .. seconds .. " сек."
    if hours > 0 then
        str = hours .. " ч. " .. str
    end

    return str
end

ROOMS_CONFIG = {
    -- №1
    { 
        positions = {
            -291.927, -398.605,
            -289.010, -387.416,
            -272.068, -387.775,
            -274.601, -420.048,
            -291.030, -420.243,
            -291.927, -398.605,
        },
        marker = {
            -285.944, -396.340, 1353.531,
        },
        name = "№1",
    },

    -- №2
    { 
        positions = {
            -299.769, -398.737,
            -300.084, -406.567,
            -321.555, -406.370,
            -321.205, -378.142,
            -301.982, -379.234,
        },
        marker = {
            -305.454, -402.647, 1353.531,
        },
        name = "№2",
    },

    -- №3
    {
        positions = {
            -299.691, -427.936,
            -301.460, -438.540,
            -325.484, -436.244,
            -321.553, -406.697,
            -300.001, -406.991,
            -299.691, -427.936,
        },
        marker = {
            -305.252, -430.435, 1353.531,
        },
        name = "№3",
    },

    -- №4
    {
        positions = {
            -291.886, -426.217,
            -291.058, -420.006,
            -269.629, -420.273,
            -267.953, -449.324,
            -288.897, -450.778,
            -291.696, -432.505,
            -291.886, -426.217,
        },
        marker = {
            -286.126, -424.169, 1353.531,
        },
        name = "№4",
    },

    -- Вип зал
    {
        positions = {
            -294.971, -437.738,
            -291.312, -439.351,
            -289.268, -443.358,
            -285.909, -461.149,
            -318.688, -461.447,
            -320.276, -436.839,
            -294.971, -437.738,
        },
        marker = {
            -292.806, -443.062, 1353.531,
        },
        is_vip = true,
        name = "VIP",
    }
}

MOVELIST_MARKERS = {
    { -300.719, -358.937, 1353.688 },
}

function GetShapeNumFromRoomID( i )
    return i % 100
end