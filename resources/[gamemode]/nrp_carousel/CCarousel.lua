loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )

local ELEMENTS

ENTER_POSITION = Vector3( 1937.162, 801.192 + 860, 26.817 )
WHEEL_POSITION = Vector3( 1935.7264, 793.566 + 860, 78.9334 )
ROTATION_SPEED = 1

function CanPlayerEnter( )
    if localPlayer.vehicle then return end
    if localPlayer.dead then return end
    if localPlayer.health <= 0 then return end
    if localPlayer.dimension ~= 0 then return end
    if localPlayer.interior ~= 0 then return end

    return true
end

function CreateCarousel( )
    if ELEMENTS then return end
    DestroyCarousel( )

    TICK_START = getTickCount( )

    ELEMENTS = { }
    ELEMENTS.cabins = { }
    ELEMENTS.wheel = createObject( 745, WHEEL_POSITION, 0, 0, -15 )
    ELEMENTS.colshape = createColSphere( ENTER_POSITION, 5 )

    local cabins   = 16
    local dist     = 47.4
    local offset_z = 0.1

    for i = 1, cabins do
        local deg = math.pi * 2 * i / cabins
        local px, pz = math.sin( deg ) * dist, math.cos( deg ) * dist

        local obj = createObject( 746, 0, 0, 0 )
        attachElements( obj, ELEMENTS.wheel, px, 0, pz + offset_z, 0, 0, 0 )

        table.insert( ELEMENTS.cabins, obj )
    end

    addEventHandler( "onClientPreRender", root, RenderCarousel )

    addEventHandler( "onClientColShapeHit", ELEMENTS.colshape, function( player, matching_dimension )
        if player == localPlayer and matching_dimension and CanPlayerEnter( ) then
            ELEMENTS.info = ibInfoPressKey( {
                text = "чтобы сесть в кабинку колеса обозрения",
                key = "f",
                black_bg = 0,

                key_handler = function( self )
                    self:destroy( )
                    ToggleAttach( )
                end;
            } )
        end
    end )

    addEventHandler( "onClientColShapeLeave", ELEMENTS.colshape, function( player )
        if player == localPlayer then
            if ELEMENTS.info then ELEMENTS.info:destroy( ) end
        end
    end )
end

function RenderCarousel( )
    local rx, _, rz = getElementRotation( ELEMENTS.wheel )

    local ry = math.floor( ( ( ( getTickCount( ) - TICK_START ) / 100 * ROTATION_SPEED ) % 360 ) * 10 ) / 10
    ELEMENTS.wheel:setRotation( rx, ry, rz )

    for i, v in pairs( ELEMENTS.cabins ) do
        setElementRotation( v, 0, 0, 0, "ZXY" )
    end
end

function DestroyCarousel( )
    if not ELEMENTS then return end

    if IS_ATTACHED then ToggleAttach( ) end
    if ELEMENTS.info then ELEMENTS.info:destroy( ) end

    removeEventHandler( "onClientPreRender", root, RenderCarousel )
    DestroyTableElements( ELEMENTS and ELEMENTS.cabins )
    DestroyTableElements( ELEMENTS )

    ELEMENTS = nil
end

function ToggleAttach( )
    if IS_ATTACHED then
        if SAVED_POSITION then
            localPlayer.position = SAVED_POSITION
            SAVED_POSITION = nil
        end
        localPlayer.frozen = false

        if isElement( ELEMENTS.colshape_leave ) then destroyElement( ELEMENTS.colshape_leave ) end

        detachElements( getCamera( ), IS_ATTACHED )
        setCameraTarget( localPlayer )

        if isElement( ELEMENTS.label ) then
            ELEMENTS.label:ibData( "text", TEXT_ENTER )
        end
        IS_ATTACHED = nil
    else
        if not CanPlayerEnter( ) then return end

        SAVED_POSITION = localPlayer.position

        local pos = ENTER_POSITION + Vector3( 0, 0, 3000 )
        ELEMENTS.colshape_leave = createColSphere( pos, 20 )

        localPlayer.position = pos
        localPlayer.frozen = true

        addEventHandler( "onClientColShapeLeave", ELEMENTS.colshape_leave, function( player )
            if player == localPlayer and IS_ATTACHED then
                if ELEMENTS.info then ELEMENTS.info:destroy( ) end
                ToggleAttach( )
            end
        end, true, "high" )

        local element = ELEMENTS.cabins[ 1 ]
        IS_ATTACHED = element
        attachElements( getCamera( ), element, 0, 5, 0, 0, 0, 15 )

        ELEMENTS.info = ibInfoPressKey( {
            text = "чтобы покинуть колесо обозрения",
            key = "g",
            black_bg = 0,

            key_handler = function( self )
                self:destroy( )
                ToggleAttach( )
            end;
        } )
    end
end

function DestroyTableElements( tbl )
    for i, v in pairs( tbl or { } ) do
        if isElement( v ) then destroyElement( v ) end
        if isTimer( v ) then killTimer( v ) end
        if type( v ) == "table" then
            if v.destroy then
                v:destroy( )
            else
                DestroyTableElements( v )
            end
        end
    end
end

addEvent( "onPlayerVerifyReadyToSpawn", true )
addEventHandler( "onPlayerVerifyReadyToSpawn", root, function( )
    function checkPlayerIsOnCarousel( )
        removeEventHandler( "onClientPlayerSpawn", localPlayer, checkPlayerIsOnCarousel )
        if localPlayer.interior ~= 0 then return end
        if localPlayer.dimension ~= 0 then return end
        if ( ENTER_POSITION + Vector3( 0, 0, 3000 ) - localPlayer.position ).length <= 10 then
            localPlayer.position = ENTER_POSITION
        end
    end
    addEventHandler( "onClientPlayerSpawn", localPlayer, checkPlayerIsOnCarousel )
end )

function onClientResourceStop_handler( )
    if IS_ATTACHED then ToggleAttach( ) end
end
addEventHandler( "onClientResourceStop", resourceRoot, onClientResourceStop_handler )

PING_DISTANCE = setTimer( function( )
    local cx, cy, cz = getCameraMatrix( )
    if getDistanceBetweenPoints3D( cx, cy, cz, WHEEL_POSITION ) <= 300 then
        CreateCarousel( )
    else
        DestroyCarousel( )
    end
end, 1000, 0 )