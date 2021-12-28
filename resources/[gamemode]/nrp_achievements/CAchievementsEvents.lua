addEvent( "onClientPlayerSomeDo", false )
addEventHandler( "onClientPlayerSomeDo", root, function ( achievement_id )
    local achievements = localPlayer:getData( "achievements_list") or { }

    if not achievements[ achievement_id ] then
        triggerServerEvent( "onClientPlayerSomeDo", resourceRoot, achievement_id )
    end
end )