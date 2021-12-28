WAITRESSES_DATA =
{
    interior = 1,
    dimension = 1,

    marker_position = Vector3( -56.3415, -100.4115, 1372.7133 ),
    marker_radius = 5.5,
    girls = {},
}

WAITRESSES_PATHS =
{
    {
        path =
        {
            {
                { x = -68.5220, y = -94.0995, z = 1372.6600, distance = 0.1, move_type = 4, duration = 0 },
                { x = -61.9153, y = -95.5089, z = 1372.6600, distance = 0.1, move_type = 4, duration = 5 },
                { x = -61.1894, y = -96.9078, z = 1372.6600, distance = 0.1, move_type = 4, duration = 8 },
            },
            {
                { x = -61.1894, y = -96.9078, z = 1372.6600, distance = 0.1, move_type = 4, duration = 0 },
                { x = -57.3698, y = -91.7818, z = 1372.6600, distance = 0.1, move_type = 4, duration = 5 },
                { x = -45.6742, y = -91.4890, z = 1372.6600, distance = 0.1, move_type = 4, duration = 13 },
            },
            {
                { x = -45.6742, y = -91.4890,  z = 1372.6600, distance = 0.1, move_type = 4, duration = 0 },
                { x = -50.2021, y = -93.4445,  z = 1372.6600, distance = 0.1, move_type = 4, duration = 3 },
                { x = -48.5917, y = -101.4220, z = 1372.6600, distance = 0.1, move_type = 4, duration = 10 },
                { x = -54.7091, y = -108.2762, z = 1372.6600, distance = 0.1, move_type = 4, duration = 16 },
                { x = -58.2416, y = -107.4003, z = 1372.6600, distance = 0.1, move_type = 4, duration = 19 },
                { x = -62.1762, y = -103.3373, z = 1372.6600, distance = 0.1, move_type = 4, duration = 23 },
            },
            {
                { x = -62.1762, y = -103.3373, z = 1372.6600, distance = 0.1, move_type = 4, duration = 0 },
                { x = -58.2331, y = -108.2217, z = 1372.6600, distance = 0.1, move_type = 4, duration = 5 },
                { x = -54.7091, y = -108.2762, z = 1372.6600, distance = 0.1, move_type = 4, duration = 8 },
                { x = -48.5917, y = -101.4220, z = 1372.6600, distance = 0.1, move_type = 4, duration = 14 },
                { x = -49.9982, y = -92.9510,  z = 1372.6600, distance = 0.1, move_type = 4, duration = 20 },
                { x = -45.6742, y = -91.4890,  z = 1372.6600, distance = 0.1, move_type = 4, duration = 24 },
            },
            {
                { x = -45.6742, y = -91.4890, z = 1372.6600, distance = 0.1, move_type = 4, duration = 0 },
                { x = -57.3698, y = -91.7818, z = 1372.6600, distance = 0.1, move_type = 4, duration = 9 },
                { x = -68.5220, y = -94.0995, z = 1372.6600, distance = 0.1, move_type = 4, duration = 17 },
            },
        },
        path_duration = { 15, 34, 64, 95, 119 },
    },

    {
        path =
        {
            {
                { x = -37.6921, y = -95.2698,  z = 1372.6600, distance = 0.1, move_type = 4, duration = 0 },
                { x = -54.6990, y = -108.9027, z = 1372.6600, distance = 0.1, move_type = 4, duration = 16 },
                { x = -56.9954, y = -111.3009, z = 1372.6600, distance = 0.1, move_type = 4, duration = 20 },
                { x = -71.6531, y = -110.2134, z = 1377.6600, distance = 0.1, move_type = 4, duration = 29 },
                { x = -71.5131, y = -100.6956, z = 1377.6600, distance = 0.1, move_type = 4, duration = 37 },
                { x = -65.8385, y = -100.7352, z = 1377.6600, distance = 0.1, move_type = 4, duration = 41 },
            },
            {
                { x = -65.8385, y = -100.7352, z = 1377.6600, distance = 0.1, move_type = 4, duration = 0 },
                { x = -71.5131, y = -100.6956, z = 1377.6600, distance = 0.1, move_type = 4, duration = 7 },
                { x = -71.4312, y = -89.7699,  z = 1377.6600, distance = 0.1, move_type = 4, duration = 15 },
                { x = -55.9740, y = -89.9767,  z = 1372.6600, distance = 0.1, move_type = 4, duration = 25 },
                { x = -49.3380, y = -97.0439,  z = 1372.6600, distance = 0.1, move_type = 4, duration = 32 },
                { x = -37.6921, y = -95.2698,  z = 1372.6600, distance = 0.1, move_type = 4, duration = 41 },
            },
        },
        path_duration = { 48, 96 },
    },
}

function InitWaitresses()
    for id, path_block in pairs( WAITRESSES_PATHS ) do
        local girl_data = {}
        girl_data.route_id, girl_data.timer_dur, girl_data.start_timestamp = GetStartWaitressesRoute( path_block.path_duration )
        girl_data.girl = CreateAIPed( 305, Vector3( path_block.path[ girl_data.route_id ][ 1 ].x, path_block.path[ girl_data.route_id ][ 1 ].y, path_block.path[ girl_data.route_id ][ 1 ].z ), 0 )
        girl_data.girl.dimension = localPlayer.dimension
        girl_data.girl.interior = localPlayer.interior
        setPedWalkingStyle( girl_data.girl, 132 )
        SetUndamagable( girl_data.girl, true )
        table.insert( WAITRESSES_DATA.girls, girl_data )
        SetWaitresssesRoute( id )
    end

    local girl_data = {}
    girl_data.girl = CreateAIPed( 305, Vector3( -28.3062, -109.1249, 1372.6600), 90 )
    SetUndamagable( girl_data.girl, true )
    girl_data.girl.dimension = localPlayer.dimension
    girl_data.girl.interior = localPlayer.interior
    girl_data.girl:setAnimation( "shop", "smoke_ryd", -1, true, false, false, false )
    
    local effect = createEffect( "cigarette_smoke", -28.3062, -109.1249, 1372.6600 )
    local obj = createObject( 3027, -28.3062, -109.1249, 1372.6600 )
    obj.dimension = localPlayer.dimension
    obj.interior = localPlayer.interior

    exports.bone_attach:attachElementToBone( obj, girl_data.girl, 11, 0.01, 0.05, 0.11, 95, 0, 0 )
    exports.bone_attach:attachElementToBone( effect, girl_data.girl, 11, 0.01, -0.05, 0.11, 95, 0, 0 )

    table.insert( WAITRESSES_DATA.girls, effect )
    table.insert( WAITRESSES_DATA.girls, obj )
end

function SetWaitresssesRoute( id )
    local girl_data = WAITRESSES_DATA.girls[ id ]
    if girl_data and isElement( girl_data.girl ) then
        SetAIPedMoveByDuration( girl_data.girl, WAITRESSES_PATHS[ id ].path[ girl_data.route_id ], false, girl_data.start_timestamp, function()
            local animation_list = { "shift", "shldr", "stretch", "strleg", "time" }
            girl_data.girl:setAnimation( "playidles", animation_list[ math.random(1, #animation_list)] )
            girl_data.timer = setTimer( function()
                if not isElement( girl_data.girl ) then return end
                girl_data.girl.position = Vector3( WAITRESSES_PATHS[ id ].path[ girl_data.route_id ].x, WAITRESSES_PATHS[ id ].path[ girl_data.route_id ].y, WAITRESSES_PATHS[ id ].path[ girl_data.route_id ].z)
                girl_data.girl:setAnimation()
                girl_data.start_timestamp = getRealTimestamp()
                girl_data.timer_dur = 7
                girl_data.route_id = girl_data.route_id + 1 > #WAITRESSES_PATHS[ id ].path and 1 or girl_data.route_id + 1
                SetWaitresssesRoute( id )
            end, girl_data.timer_dur * 1000, 1 )
            
        end )
    end
end

function StopMoveWaitresses()
    for k, girl_data in pairs( WAITRESSES_DATA.girls or {}) do
        if isElement( girl_data.girl ) then
            ResetAIPedPattern( girl_data.girl )
            removePedTask( girl_data.girl )
        end
        if isTimer( girl_data.timer ) then
            killTimer( girl_data.timer )
        end
    end
end

function GetStartWaitressesRoute( durations )
    local passed_time = getRealTimestamp() - START_RESOURCE_TIMESTAMP
    local number_passes = math.floor( passed_time / durations[ #durations ] )
    local passed_time = passed_time - number_passes * durations[ #durations ]
    local start_timestamp = getRealTimestamp() - passed_time

    for k, v in ipairs( durations ) do
        if passed_time <= v then
            passed_time = math.max( 0, k > 1 and math.abs( passed_time - v ) or passed_time )
            return k, math.min( 7, math.max( 0.05, v - passed_time ) ), ( k > 1 and (start_timestamp + durations[ k - 1 ]) or start_timestamp )
        end
    end
end

function DestroyWaitresses()
    for k, girl_data in pairs( WAITRESSES_DATA.girls or {}) do
        if isElement( girl_data.girl ) then
            ResetAIPedPattern( girl_data.girl )
            removePedTask( girl_data.girl )
            destroyElement( girl_data.girl )
        end
        if isTimer( girl_data.timer ) then
            killTimer( girl_data.timer )
        end
    end
    WAITRESSES_DATA.girls = {}
end