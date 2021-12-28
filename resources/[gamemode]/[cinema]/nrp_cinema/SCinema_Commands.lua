-- Пропуск видео для администрации

SKIP_ACCESS_LEVEL_MIN = 1

addCommandHandler( "skip", function( player )
    if player:GetAccessLevel( ) < SKIP_ACCESS_LEVEL_MIN then return end

    local room_num

    for i, v in pairs( ROOMS ) do
        for _, room_player in pairs( v.players ) do
            if player == room_player then
                room_num = i
                break
            end
        end
    end

    if room_num then
        if ROOMS[ room_num ].video then
            for i, v in pairs( ROOMS[ room_num ].players ) do
                outputChatBox( "Данное видео было пропущено администратором " .. player:GetNickName( ), v, 255, 255, 255 )
            end
            ParseRoomVideo( room_num, true )
        
        else
            outputChatBox( "В кинозале нет включенных видео", player, 255, 0, 0 )
        end
    
    else
        outputChatBox( "Кинозал не найден", player, 255, 0, 0 )

    end
end )