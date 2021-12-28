local WAITRESSES_DATA = nil
local WAITRESSES_PATHS =
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

local START_RESOURCE_TIMESTAMP = getRealTimestamp()

function InitWaitresses()
    WAITRESSES_DATA = { elements = {} }

    for id, path_block in pairs( WAITRESSES_PATHS ) do
        local girl_data = {}
        
        girl_data.route_id = GetStartWaitressesRoute( path_block.path_duration )
        
        girl_data.girl = CreateAIPed( 305, Vector3( path_block.path[ girl_data.route_id ][ 1 ].x, path_block.path[ girl_data.route_id ][ 1 ].y, path_block.path[ girl_data.route_id ][ 1 ].z ), 0 )
        table.insert( WAITRESSES_DATA.elements, girl_data )

        LocalizeQuestElement( girl_data.girl  )
 
        setPedWalkingStyle( girl_data.girl, 132 )
        SetUndamagable( girl_data.girl, true )
        
        SetWaitresssesRoute( id )
    end

    local girl_data = {}
    girl_data.girl = CreateAIPed( 305, Vector3( -28.3062, -109.1249, 1372.6600), 90 )
    SetUndamagable( girl_data.girl, true )
    LocalizeQuestElement( girl_data.girl  )

    girl_data.girl:setAnimation( "shop", "smoke_ryd", -1, true, false, false, false )
    
    local effect = createEffect( "cigarette_smoke", -28.3062, -109.1249, 1372.6600 )
    local obj = createObject( 3027, -28.3062, -109.1249, 1372.6600 )
    LocalizeQuestElement( obj )

    exports.bone_attach:attachElementToBone( obj, girl_data.girl, 11, 0.01, 0.05, 0.11, 95, 0, 0 )
    exports.bone_attach:attachElementToBone( effect, girl_data.girl, 11, 0.01, -0.05, 0.11, 95, 0, 0 )

    table.insert( WAITRESSES_DATA.elements, effect )
    table.insert( WAITRESSES_DATA.elements, obj )

    local girls = 
    {
        CreateAIPed( 306, Vector3( -55.6088, -103.5262, 1373.6009 ), 0 ),
        CreateAIPed( 307, Vector3( -55.3174, -97.51681, 1373.6009 ), 0 ),
        CreateAIPed( 308, Vector3( -53.6703, -101.5174, 1373.6009 ), 0 ),
        CreateAIPed( 309, Vector3( -53.9452, -98.40461, 1373.6009 ), 0 ),
    }

    for k, v in pairs( girls ) do
        LocalizeQuestElement( v )

        setPedWalkingStyle( v, 132 )
        setElementRotation( v, 0, 0, 270 )
        SetUndamagable( v, true )

        v:setAnimation( "strip_club.dances", "private", -1, true, false, false, false, 250 )

        table.insert( WAITRESSES_DATA.elements, v )
    end
end

function SetWaitresssesRoute( id )
    local girl_data = WAITRESSES_DATA.elements[ id ]
    if not girl_data or not isElement( girl_data.girl ) then return end

    SetAIPedMoveByRoute( girl_data.girl, WAITRESSES_PATHS[ id ].path[ girl_data.route_id ], false, function()
        local animation_list = { "shift", "shldr", "stretch", "strleg", "time" }
        girl_data.girl:setAnimation( "playidles", animation_list[ math.random(1, #animation_list)] )
        
        girl_data.timer = setTimer( function()
            if not isElement( girl_data.girl ) then return end

            girl_data.girl:setAnimation()
            girl_data.route_id = girl_data.route_id + 1 > #WAITRESSES_PATHS[ id ].path and 1 or girl_data.route_id + 1
            
            SetWaitresssesRoute( id )
        end, 7 * 1000, 1 )
        
    end )
end

function GetStartWaitressesRoute( durations )
    local passed_time = getRealTimestamp() - START_RESOURCE_TIMESTAMP
    local number_passes = math.floor( passed_time / durations[ #durations ] )
    local passed_time = passed_time - number_passes * durations[ #durations ]

    for k, v in ipairs( durations ) do
        if passed_time <= v then
            passed_time = math.max( 0, k > 1 and math.abs( passed_time - v ) or passed_time )
            return k
        end
    end
end

function DestroyWaitresses()
    if not WAITRESSES_DATA then return end

    for k, girl_data in pairs( WAITRESSES_DATA.elements or {}) do
        if isTimer( girl_data.timer ) then killTimer( girl_data.timer ) end

        if isElement( girl_data.girl ) then
            ResetAIPedPattern( girl_data.girl )
            destroyElement( girl_data.girl )
        end
    end
    WAITRESSES_DATA = nil
end