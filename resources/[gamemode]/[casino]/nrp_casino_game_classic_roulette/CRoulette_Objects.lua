
INTERACTIVE_OBJECTS = nil
ROULETTE_OBJECTS_DATA = 
{
    ring_dial =       { id = 922, pos = { [ CASINO_THREE_AXE ] = Vector3( -86.992027, -469.47507, 914.008 ), [ CASINO_MOSCOW ] = Vector3( 2441.5706, -1329.0861, 2799.96 ) }, rot = { [ CASINO_THREE_AXE ] = Vector3(), [ CASINO_MOSCOW ] = Vector3( 0, 0, 90 ), } },
    dial =            { id = 923, pos = { [ CASINO_THREE_AXE ] = Vector3( -86.991203, -469.47507, 914.182 ), [ CASINO_MOSCOW ] = Vector3( 2441.5706, -1329.0861, 2800.13 ) }, rot = { [ CASINO_THREE_AXE ] = Vector3(), [ CASINO_MOSCOW ] = Vector3( 0, 0, 90 ), } },
    ball =            { id = 925, pos = { [ CASINO_THREE_AXE ] = Vector3( -86.992027, -469.47507, 914.008 ), [ CASINO_MOSCOW ] = Vector3( 2442.1285, -1329.0236, 2800.00 ) }, rot = { [ CASINO_THREE_AXE ] = Vector3(), [ CASINO_MOSCOW ] = Vector3( 0, 0, 90 ), } },
    roulette_fields = { id = 930, pos = { [ CASINO_THREE_AXE ] = Vector3( -86.991282, -471.50942, 913.906 ), [ CASINO_MOSCOW ] = Vector3( 2443.6960, -1328.8550, 2799.84 ) }, rot = { [ CASINO_THREE_AXE ] = Vector3(), [ CASINO_MOSCOW ] = Vector3( 0, 0, 90 ), } },
}

START_NUMBERS = 
{
    { field_id = 3, rotation = 12  },
    { field_id = 5, rotation = 10  },
    { field_id = 13, rotation = 13 },
    { field_id = 17, rotation = 13 },
}

CENTER_RING_START_POSITIONS =
{
    [ CASINO_THREE_AXE ] = Vector3( -86.992027, -469.47507, 914.15 ),
    [ CASINO_MOSCOW ] = Vector3( 2441.5706, -1329.0861, 2800.036 ),
}
CENTER_RING_START_POSITION = nil
CENTER_RING_START_POSITION_CF = 0.44

CENTER_RING_FIELD_POSITIONS = 
{
    [ CASINO_THREE_AXE ] = Vector3( -86.992027, -469.47507, 914.04 ),
    [ CASINO_MOSCOW ] = Vector3( 2441.5706, -1329.0861, 2799.989 ),
}
CENTER_RING_FIELD_POSITION = nil
CENTER_RING_FIELD_POSITION_CF = 0.299

DIAL_SPEED_ROTATION = 1.3
BALL_SPEED_ROTATION = 2.5

STATIC_OBJECTS = 
{
    { id = 922, interior = 4, dimension = 1, pos = Vector3( 2432.9966,  -1323.0592,  2799.96 ), rot = Vector3( 0, 0, 90 ) },
    { id = 923, interior = 4, dimension = 1, pos = Vector3( 2432.9966,  -1323.0592,  2800.13 ), rot = Vector3( 0, 0, 90 ) },
    { id = 930, interior = 4, dimension = 1, pos = Vector3( 2435.1221,  -1322.8281,  2799.84 ), rot = Vector3( 0, 0, 270 ) },
    
    { id = 922, interior = 4, dimension = 1, pos = Vector3( 2434.8728,  -1328.9304,  2799.96 ), rot = Vector3( 0, 0, 90 ) },
    { id = 923, interior = 4, dimension = 1, pos = Vector3( 2434.8728,  -1328.9304,  2800.13 ), rot = Vector3( 0, 0, 90 ) },
    { id = 930, interior = 4, dimension = 1, pos = Vector3( 2436.9983,  -1328.6993,  2799.84 ), rot = Vector3( 0, 0, 90 ) },
    
    { id = 922, interior = 4, dimension = 1, pos = Vector3( 2441.5706,  -1329.0861,  2799.96 ), rot = Vector3( 0, 0, 90 ) },
    { id = 923, interior = 4, dimension = 1, pos = Vector3( 2441.5706,  -1329.0861,  2800.13 ), rot = Vector3( 0, 0, 90 ) },
    { id = 930, interior = 4, dimension = 1, pos = Vector3( 2443.6960,  -1328.855,   2799.84 ), rot = Vector3( 0, 0, 90 ) },
}

for k, v in pairs( STATIC_OBJECTS ) do
    local obj = createObject( v.id, v.pos, v.rot )
    obj.dimension = v.dimension
    obj.interior = v.interior
end

function CreateRouletteObjects()
    INTERACTIVE_OBJECTS = {}
    for k, v in pairs( ROULETTE_OBJECTS_DATA ) do
        INTERACTIVE_OBJECTS[ k ] = createObject( v.id, v.pos[ ROULETTE_DATA.casino_id ], v.rot[ ROULETTE_DATA.casino_id ] )
        INTERACTIVE_OBJECTS[ k ].dimension = localPlayer.dimension
        INTERACTIVE_OBJECTS[ k ].interior  = localPlayer.interior
    end

    CENTER_RING_START_POSITION = CENTER_RING_START_POSITIONS[ ROULETTE_DATA.casino_id ]
    CENTER_RING_FIELD_POSITION = CENTER_RING_FIELD_POSITIONS[ ROULETTE_DATA.casino_id ]
    
    removeEventHandler( "onClientClick", root, OnClickOnRouletteField )
    addEventHandler( "onClientClick", root, OnClickOnRouletteField )
end

function StartMoveBall( state_data )
    ROULETTE_DATA.ball_sound = playSound( "sfx/ball_sound.mp3" )
    ROULETTE_DATA.ball_sound.volume = 0.8
    
    ROULETTE_DATA.end_ticks = getTickCount() + state_data.time_left_iteration
    ROULETTE_DATA.dial_data = START_NUMBERS[ math.random( 1, #START_NUMBERS ) ]
    ROULETTE_DATA.end_rotation = ROULETTE_DATA.dial_data.rotation + GetRotationByFieldId( state_data.win_field )
    ROULETTE_DATA.offset = math.random( 1, 4 )  * 90 + ROULETTE_DATA.dial_data.field_id * math.random(15, 30)


    local fProgress = 1 - (ROULETTE_DATA.end_ticks - getTickCount()) / (DURATION_STATE[ CR_STATE_ROTATE_DIAL ] * 1000)
    ROULETTE_DATA.start_rotation, ROULETTE_DATA.last_z = interpolateBetween( ROULETTE_DATA.offset, CENTER_RING_START_POSITION.z, 0, ROULETTE_DATA.offset + 360 * 4, CENTER_RING_START_POSITION.z, 0, fProgress, "Linear" )

    removeEventHandler( "onClientPreRender", root, onRenderObjects )
    addEventHandler( "onClientPreRender", root, onRenderObjects ) 
end

function onRenderObjects( time_slice )
    local fProgress = 1 - (ROULETTE_DATA.end_ticks - getTickCount()) / (DURATION_STATE[ CR_STATE_ROTATE_DIAL ] * 1000)
    if fProgress > 0 and fProgress <= 1 then
        local dial_speed_rotation = getDialData( fProgress )
        local ball_speed_rotation, move_dist_cf, ball_z = getBallData( fProgress )

        INTERACTIVE_OBJECTS.dial.rotation = Vector3( 0, 0, dial_speed_rotation )
        INTERACTIVE_OBJECTS.ball.rotation = Vector3( 0, 0, ball_speed_rotation )
        INTERACTIVE_OBJECTS.ball.position = Vector3(CENTER_RING_START_POSITION.x, CENTER_RING_START_POSITION.y, ball_z) + Vector3(math.cos( math.rad( INTERACTIVE_OBJECTS.ball.rotation.z ) ) * move_dist_cf, math.sin( math.rad( INTERACTIVE_OBJECTS.ball.rotation.z ) ) * move_dist_cf, 0)
    else
        INTERACTIVE_OBJECTS.dial.rotation = Vector3( 0, 0, INTERACTIVE_OBJECTS.dial.rotation.z - time_slice / 15 )
        INTERACTIVE_OBJECTS.ball.rotation = Vector3( 0, 0, INTERACTIVE_OBJECTS.ball.rotation.z - time_slice / 15 )
        INTERACTIVE_OBJECTS.ball.position = Vector3(CENTER_RING_START_POSITION.x, CENTER_RING_START_POSITION.y, INTERACTIVE_OBJECTS.ball.position.z) + Vector3(math.cos( math.rad( INTERACTIVE_OBJECTS.ball.rotation.z ) ) * CENTER_RING_FIELD_POSITION_CF, math.sin( math.rad( INTERACTIVE_OBJECTS.ball.rotation.z ) ) * CENTER_RING_FIELD_POSITION_CF, 0)
    end
end

function GetRotationByFieldId( field_id )
    local step = 360 / 37
    return ROULETTE_FIELDS[ field_id ].ring_id * step - step
end

function getBallData( fProgress )
    local ball_speed_rotation, ball_z = interpolateBetween( ROULETTE_DATA.offset, CENTER_RING_START_POSITION.z, 0, ROULETTE_DATA.offset + 360 * 4, CENTER_RING_FIELD_POSITION.z, 0, fProgress, "Linear" )
    local move_dist_cf = CENTER_RING_START_POSITION_CF
    if fProgress > 0.925 then
        local dProgress = (ROULETTE_DATA.end_ticks - getTickCount()) / (DURATION_STATE[ CR_STATE_ROTATE_DIAL ] * 1000 * 0.075)
        move_dist_cf = interpolateBetween( CENTER_RING_FIELD_POSITION_CF, 0, 0, CENTER_RING_START_POSITION_CF, 0, 0, dProgress, "Linear" )
    end
    return ball_speed_rotation, move_dist_cf, ball_z
end

function getDialData( fProgress )
    local dial_speed_rotation = interpolateBetween( ROULETTE_DATA.offset + 360 * 4 + ROULETTE_DATA.end_rotation, 0, 0, ROULETTE_DATA.offset + ROULETTE_DATA.end_rotation, 0, 0, fProgress, "Linear" )
    return dial_speed_rotation
end

function OnClickOnRouletteField( button, state, _, _, wx, wy, wz )
    if not ROULETTE_DATA or ROULETTE_DATA.current_state ~= CR_STATE_RATE then return end

    if button == "left" and state == "down" then
        local roulette_field = GetRouletteFieldByPosition( ROULETTE_DATA.casino_id, Vector3( wx, wy, wz ) )
        if roulette_field then
            if not fileExists( CASINO_GAME_CLASSIC_ROULETTE ) then
                local file = fileCreate( CASINO_GAME_CLASSIC_ROULETTE ) 
                fileClose( file ) 
                if UI_elements.hint then
                    UI_elements.hint:destroy()
                end
                
                UI_elements.hint_return_rate = ibCreateImage( (scX - 402 * cfX) / 2, scY - 250 * cfY, 402, 34, "img/hint1.png" )
                ROULETTE_DATA.time_hide_hint = setTimer( function()
                    UI_elements.hint_return_rate:ibAlphaTo( 0, 250 )
                    ROULETTE_DATA.time_hide_hint = setTimer( function()
                        UI_elements.hint_return_rate:destroy()
                    end, 250, 1 )
                end, 5000, 1 )
            end

            if ROULETTE_DATA.current_chip then
                OnTryAddRate( roulette_field )
            end
        end
    elseif button == "right" and state == "down" then
        local roulette_field = GetRouletteFieldByPosition( ROULETTE_DATA.casino_id, Vector3( wx, wy, wz ) )
        if roulette_field and ROULETTE_DATA then
            OnTryRemoveRate( roulette_field )
            if isTimer( ROULETTE_DATA.time_hide_hint ) then
                killTimer( ROULETTE_DATA.time_hide_hint )
                UI_elements.hint_return_rate:destroy()
            end
        end
    end
end

function DestroyRouletteObjects()
    removeEventHandler( "onClientClick", root, OnClickOnRouletteField )
    removeEventHandler( "onClientPreRender", root, onRenderObjects )
    for k, v in pairs( INTERACTIVE_OBJECTS or {} ) do
        if isElement( v ) then
            destroyElement( v )
        end
    end
    INTERACTIVE_OBJECTS = nil
end

