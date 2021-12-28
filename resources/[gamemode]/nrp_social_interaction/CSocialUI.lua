addEvent( "socialInteractionShowMenu", false )
addEventHandler( "socialInteractionShowMenu", root, function ( )
    components.window( true )
end )

addEvent( "socialInteractionShowStats", false )
addEventHandler( "socialInteractionShowStats", root, function ( player, is_achievements )
    if not isElement( player ) then
        localPlayer:ShowError( "Игрок не в сети" )
        return
    end

    if is_achievements then
        components.windowAchievements( true, player:GetNickName( ) )
    else
        components.windowStats( true )
    end


    -- update data
    if is_achievements then
        updateData( "achievements_other_player", player )
    else
        updateData( "statistic_other_player", player )
    end
end )