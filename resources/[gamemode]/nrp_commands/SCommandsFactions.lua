-- Установка фракции
function Player_Setfaction( player, command, target_id, faction )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end
    local faction = tonumber( faction )
    if not faction then return ERRCODE_WRONG_SYNTAX end

    if faction ~= 0 and not FACTIONS_NAMES[ faction ] then
        player:outputChat( "Такой фракции не существует", 255, 0, 0 )
        return 
    end

    if target_player:IsInClan() then 
        player:outputChat( "Игрок находится в клане", 255, 0, 0 )
        return 
    end

    local faction_name = FACTIONS_NAMES[ faction ] or "Нет фракции"

    target_player:SetFaction( faction )

    if faction > 0 and FACTIONS_NAMES[ faction ] then
        target_player:EndUrgentMilitary()
    end

    outputChatBox( target_player:GetNickName() .. " был установлен во фракцию " .. faction_name, player, 0, 255, 0 )
    LogSlackCommand( "%s был установлен во фракцию %s %s", target_player, player, faction_name )
end
addCommandHandler( "setfaction", Player_Setfaction )

function Player_Offlinesetfaction( player, command, target_uid, faction )
    local target_uid = tonumber( target_uid )
    if GetPlayer( target_uid, true ) then
        player:outputChat( "Игрок должен быть не в сети для этой команды. Используйте /setfaction", 255, 0, 0 )
        return
    end
    local faction = tonumber( faction )
    if not faction then return ERRCODE_WRONG_SYNTAX end

    if faction ~= 0 and not FACTIONS_NAMES[ faction ] then
        player:outputChat( "Такой фракции не существует", 255, 0, 0 )
        return 
    end

    DB:queryAsync( function( query )
        local result = query:poll( -1 )
        if #result <= 0 then
            player:outputChat( "Игрок с таким UserID не найден (" .. tostring( target_uid ) ..")", 255, 0, 0 )
            return
        end
    
        local data = result[ 1 ]
    
        if faction == data.faction_id then
            player:outputChat( "Игрок уже состоит в этой фракции", 255, 0, 0 )
            return
        end
    
        if data.military_level < 4 then
            player:outputChat( "У игрока нет военного билета. Доступно только /setfaction когда игрок в сети", 255, 0, 0 )
            return
        end
        
        DB:exec( "UPDATE nrp_players SET faction_id=?, faction_level=1 WHERE id=? LIMIT 1", faction, target_uid )

        local faction_name = FACTIONS_NAMES[ faction ] or "Нет фракции"
    
        outputChatBox( "[Offline] " .. data.nickname .. " был установлен во фракцию " .. faction_name, player, 0, 255, 0 )
        LogSlackCommand( "[Offline] %s был установлен во фракцию %s %s", data.nickname, player, faction_name )
    end, {}, "SELECT nickname, client_id, faction_id, faction_level, military_level FROM nrp_players WHERE id=? LIMIT 1", target_uid )
end
addCommandHandler( "offsetfaction", Player_Offlinesetfaction )

-- Установка левела
function Player_Setfactionlevel( player, command, target_id, level )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end
    local level = tonumber( level )
    if not level then return ERRCODE_WRONG_SYNTAX end

    local faction = target_player:GetFaction( )

    if not faction or faction == 0 then
        player:outputChat( "Игрок не во фракции", 255, 0, 0 )
        return
    end

    if not FACTIONS_LEVEL_NAMES[ faction ][ level ] then
        player:outputChat( "Такого ранга не существует", 255, 0, 0 )
        return
    end

    target_player:SetFactionLevel( level )
    outputChatBox( target_player:GetNickName() .. " был установлен на ранг " .. level, player, 255, 0, 0 )
    LogSlackCommand( "%s поставил уровень фракции %s %s", player, level, target_player )
end
addCommandHandler( "setfactionlevel", Player_Setfactionlevel )

function Player_Offlinesetfactionlevel( player, command, target_uid, level )
    local target_uid = tonumber( target_uid )
    if GetPlayer( target_uid, true ) then
        player:outputChat( "Игрок должен быть не в сети для этой команды. Используйте /setfactionlevel", 255, 0, 0 )
        return
    end
    local level = tonumber( level )
    if not level then return ERRCODE_WRONG_SYNTAX end

    DB:queryAsync( function( query )
        local result = query:poll( -1 )
        if #result <= 0 then
            player:outputChat( "Игрок с таким UserID не найден (" .. tostring( target_uid ) ..")", 255, 0, 0 )
            return
        end

        local data = result[ 1 ]

        if data.faction_id == 0 then
            player:outputChat( "Игрок не во фракции", 255, 0, 0 )
            return
        end

        if not FACTIONS_LEVEL_NAMES[ data.faction_id ][ level ] then
            player:outputChat( "Такого ранга не существует", 255, 0, 0 )
            return
        end

        if level == data.faction_level then
            player:outputChat( "Игрок уже назначен на данный ранг во фракции", 255, 0, 0 )
            return
        end
        
        DB:exec( "UPDATE nrp_players SET faction_level=? WHERE id=? LIMIT 1", level, target_uid )

        outputChatBox( data.nickname .. " был установлен на ранг " .. level, player, 255, 0, 0 )
        LogSlackCommand( "%s поставил уровень фракции %s %s", player, level, data.nickname )        
    end, {}, "SELECT nickname, client_id, faction_id, faction_level, military_level FROM nrp_players WHERE id=? LIMIT 1", target_uid )
end
addCommandHandler( "offsetfactionlevel", Player_Offlinesetfactionlevel )