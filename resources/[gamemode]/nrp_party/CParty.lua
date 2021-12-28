addEventHandler( "onClientPlayerDamage", localPlayer, function ( )
    if localPlayer:getData( "in_party" ) then
        cancelEvent( )
    end
end )