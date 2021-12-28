local ENABLE_COLLISION_TIMER

addEvent( "requestNoCollisionTimePlayer", true )
addEventHandler( "requestNoCollisionTimePlayer", localPlayer, function ( )
    local players = getElementsByType( "player" )

    for idx, player in pairs( players ) do
        setElementCollidableWith( localPlayer, player, false )
    end

    if isTimer( ENABLE_COLLISION_TIMER ) then
        ENABLE_COLLISION_TIMER:destroy( )
    end
    ENABLE_COLLISION_TIMER = Timer( function ( )
        for idx, player in pairs( players ) do
            if isElement( player ) then
                setElementCollidableWith( localPlayer, player, true )
            end
        end
    end, 5000, 1 )
end )