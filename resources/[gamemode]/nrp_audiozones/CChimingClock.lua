Timer( function( )
    local h, m = getTime( )
    if h % 12 == 0 and m == 0 and not isElement( CHIMING_SOUND ) then
        CHIMING_SOUND = playSound3D( "sfx/chiming_clock.mp3", Vector3{ x = 228.330, y = 2356.147, z = 59.151 } )
        CHIMING_SOUND:setMaxDistance( 900 )
    end
end, 1000, 0 )

