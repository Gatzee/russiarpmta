Extend( "SPlayer" )

ERR_PLAYER_NOT_FOUND = "Данный игрок не найден"
ERR_PLAYER_IS_SAME = "Вы не можете использовать эту команду на себе"

function PlayerParseCommand( player, command, target_id, allow_same )
    -- Нет доступа к команде
    --if not player:HasCommandAccess( command ) then player:outputChat( ERR_NO_ACCESS, 255, 0, 0 ) return end
    -- Игрок не найден
    local target_player = GetPlayer( tonumber( target_id ) )
    if not isElement( target_player ) then player:outputChat( ERR_PLAYER_NOT_FOUND, 255, 0, 0 ) return end
    -- Разрешение выполнения команды на самом себе
    if not allow_same and player == target_player then player:outputChat( ERR_PLAYER_IS_SAME, 255, 0, 0 ) return end
    -- Всё тип-топ, возвращаем игрока, которого он искал
    return target_player
end

function Player_Admins( player, command )
    player:outputChat( "-----------------------------------------", 255, 255, 255 )
    player:outputChat( "Список администрации онлайн: ", 255, 255, 255 )
    for i, v in pairs( getElementsByType( "player" ) ) do
        local access_level = v:GetAccessLevel()
        if access_level > 0 and not v:getData( "hidden_admin" ) then
            local access_level_name = ACCESS_LEVEL_NAMES[ v:GetAccessLevel() ] or "Администрация"
            player:outputChat( table.concat( { '[', access_level_name, '] ', v:GetNickName() } ), 255, 255, 0, true )
        end
    end
    player:outputChat( "-----------------------------------------", 255, 255, 255 )
end
addCommandHandler( "admins", Player_Admins )

function Player_Adminshide( player, command )
    local new_state = not player:getData( "hidden_admin" )
    player:setData( "hidden_admin", new_state, false )
    if new_state then
        player:outputChat( "Ты спрятал себя из списка админов", 0, 255, 0 )
    else
        player:outputChat( "Ты показал себя в списке админов", 255, 0, 0 )
    end
end
addCommandHandler( "adminshide", Player_Adminshide )

function Player_Commands( player, command )
    player:outputChat( "-----------------------------------------", 255, 255, 255 )
    player:outputChat( "Список команд для вашего уровня доступа: ", 255, 255, 255 )
    for i, v in pairs( COMMAND_ACCESS_LEVELS ) do
        local desc
        if type( v ) == "table" and v[ 2 ] then
            desc = v[ 2 ]:gsub( "-", "#ffffff-" )
        else
            desc = "/" .. i
        end
        player:outputChat( desc, 255, 255, 0, true )
    end
    player:outputChat( "-----------------------------------------", 255, 255, 255 )
end
addCommandHandler( "commands", Player_Commands )

function Player_Inv( player, command )
    player.alpha = player.alpha == 0 and 255 or 0
end
addCommandHandler( "inv", Player_Inv )

function Player_Global( player, command, ... )
    local msg = table.concat( { ... }, ' ' )
    if utf8.len( msg ) <= 0 then return ERRCODE_WRONG_SYNTAX end
    local access_level_name = ACCESS_LEVEL_NAMES[ player:GetAccessLevel() ] or "Администрация"
    outputChatBox( table.concat( { '[', access_level_name, '] ', player:GetNickName(), ': ', msg }, '' ), root, 255, 0, 0 )
end
addCommandHandler( "global", Player_Global )

function Player_Alarm( player, command, ... )
    local msg = table.concat( { ... }, ' ' )
    if utf8.len( msg ) <= 0 then return ERRCODE_WRONG_SYNTAX end
    -- local access_level_name = ACCESS_LEVEL_NAMES[ player:GetAccessLevel() ] or "Администрация" -- unused
	triggerClientEvent( "OnClientReceivePhoneNotification", resourceRoot, {
		title = "Администрация";
		msg = msg;
	} )
end
addCommandHandler( "alarm", Player_Alarm )

-- Телепорт игрока
function Player_Get( player, command, target_id )
    local target_player = PlayerParseCommand( player, command, target_id )
    if not target_player then return end

    if target_player.vehicle then target_player.vehicle = nil end

    target_player:Teleport( player.position + Vector3( 0, 1, 0.75 ), player.dimension, player.interior )
end
addCommandHandler( "get", Player_Get )

-- Телепорт к игроку
function Player_Warp( player, command, target_id )
    local target_player = PlayerParseCommand( player, command, target_id )
    if not target_player then return end

    player:Teleport( target_player.position + Vector3( 0, 1, 0.75 ), target_player.dimension, target_player.interior )
end
addCommandHandler( "pwarp", Player_Warp )

-- Джейл игрока
function Player_Jail( player, command, target_id, time, ... )
    local target_player = PlayerParseCommand( player, command, target_id )
    if not target_player then return end
    local time = tonumber( time )
    if not time then return ERRCODE_WRONG_SYNTAX end
    time = time * 60
    local reason = table.concat( { ... }, " " )
    if utf8.len( reason ) <= 0 then return ERRCODE_WRONG_SYNTAX end

    target_player:Jail( player, _, time, reason, true )

    local time = math.floor( time / 60 )
    LogSlackCommand( "%s был заключен в тюрьму %s на %s по причине %s", target_player, player, time, reason )
    outputChatBox( target_player:GetNickName() .. " был заключен в тюрьму " .. player:GetNickName() .. " на " .. time .. "м. по причине: " .. reason, root, 255, 0, 0 )
    
    SendAdminActionToLogserver(
        target_player:GetNickName( ) .. " был заключен в тюрьму " .. player:GetNickName() .. " на " .. time .. "м. по причине: " .. reason,
        { reason = reason, time = time },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "jail", Player_Jail )

-- Анджейл игрока
function Player_Unjail( player, command, target_id )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    target_player:Release( player, _, true )
    LogSlackCommand( "%s был вытащен из тюрьмы %s", target_player, player )
    outputChatBox( target_player:GetNickName() .. " был вытащен из тюрьмы " .. player:GetNickName(), root, 0, 255, 0 )

    SendAdminActionToLogserver(
        target_player:GetNickName() .. " был вытащен из тюрьмы " .. player:GetNickName(),
        { },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "unjail", Player_Unjail )

function Player_ToPrison( src_player, command, target_id )
    local target_player = PlayerParseCommand( src_player, command, target_id, true )
    if not target_player then return end

    local data = target_player:getData("jailed")
    if data == "is_prison" then
        outputChatBox( "Данный игрок уже находится в колонии", src_player, 255, 0, 0 )
    elseif data == true then
        local jailed_players = exports.nrp_jail:GetJailedPlayers()
        for _, v in pairs( jailed_players ) do
            if v.player == target_player then
                fadeCamera( v.player, false, 0 )
                setTimer( fadeCamera, 50, 1, v.player, true, 1 )
                exports.nrp_jail:ReleasePlayer( true, v.player, "Транспортировка в тюрьму", true )
                v.player:setData( "jailed", "move_prison", false )
                triggerEvent( "onServerJailedPlayerDeliveredToPrison", src_player, { { player = v.player, data = v.data } } )
                outputChatBox( "Игрок успешно переведён из КПЗ в колонию!", src_player, 0, 255, 0 )
                break
            end
        end
    else
        outputChatBox( "Данный игрок не находится в КПЗ!", src_player, 255, 0, 0 )
    end

end
addCommandHandler( "toprison", Player_ToPrison )

function Player_FreePrison( src_player, command, target_id )
    local target_player = PlayerParseCommand( src_player, command, target_id, true )
    if not target_player then return end

    local data = target_player:getData("jailed")
    if data == "is_prison" then
        exports.nrp_fsin_jail:ReleasePlayer( nil, target_player, "Освобождение админом", true )
        outputChatBox( "Игрок освобожден из колонии", src_player, 0, 255, 0 )
    else
        outputChatBox( "Данный игрок не находится в колонии!", src_player, 255, 0, 0 )
    end

end
addCommandHandler( "freeprison", Player_FreePrison )

-- Джейл оффлайн
function Player_JailOffline( player, command, target_id, time, ... )
    local time = tonumber( time )
    if not time then return ERRCODE_WRONG_SYNTAX end
    time = time * 60
    local reason = table.concat( { ... }, " " )
    if utf8.len( reason ) <= 0 then return ERRCODE_WRONG_SYNTAX end

    DB:queryAsync(function(queryHandler, player, time, reason)
        local result = dbPoll(queryHandler,0)
        if not isElement( player ) then return end
        if type ( result ) ~= "table" or #result == 0 then
            player:ShowError("Игрок с таким ID не найден")
            return false
        end

        local result = result[1]

        local data = result.permanent_data and fromJSON(result.permanent_data) or {}

        data.jail_data = {
            time_left = time,
            jail_id = 1,
            reason = reason,
            admin = true,
        }

        DB:exec("UPDATE nrp_players SET permanent_data = ? WHERE id = ? LIMIT 1", toJSON(data), result.id)

        local time = math.floor( time / 60 )
        LogSlackCommand( "[Offline] %s был заключен в тюрьму %s на %s по причине %s", result.nickname, player, time, reason )
        outputChatBox( "[Offline] " .. result.nickname .. " был заключен в тюрьму " .. player:GetNickName() .. " на " .. time .. "м. по причине: " .. reason, root, 255, 0, 0 )

        SendAdminActionToLogserver(
            result.nickname .. " был заключен в тюрьму " .. player:GetNickName( ) .. " на " .. time .. "м. по причине: " .. reason,
            {
                time = time, reason = reason, jail_type = "offline",
                player_name = result.nickname, player_id = result.id, player_clientid = result.client_id, player_serial = result.last_serial
            },
            { player, "admin" }
        )

    end, {player, time, reason}, "SELECT id, client_id, nickname, last_serial, permanent_data FROM nrp_players WHERE id=? LIMIT 1", target_id)
end
addCommandHandler( "jailoffline", Player_JailOffline )

-- Выдача хп
function Player_SetHealth( player, command, target_id, hp )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    if not hp or not tonumber(hp) then
        return ERRCODE_WRONG_SYNTAX
    end

    local hp = tonumber(hp)

    target_player:SetHP( hp )
    player:outputChat( " Уровень жизней игрока "..target_player:GetNickName().." изменён на "..hp, 0, 255, 0 ) 
end
addCommandHandler( "sethp", Player_SetHealth)

-- Изменение уровня
function Player_SetLevel( player, command, target_id, new_level, ... )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local reason = table.concat( { ... }, " " )
    if utf8.len( reason ) <= 0 then return ERRCODE_WRONG_SYNTAX end

    if not new_level or not tonumber(new_level) then
        return ERRCODE_WRONG_SYNTAX
    end

    local new_level = tonumber(new_level)

    if new_level < 1 or new_level > ( #LEVELS_EXPERIENCE + 1 ) then
        player:outputChat("Допустимы лишь значения в диапазоне от 1 до ".. ( #LEVELS_EXPERIENCE + 1 ), 240, 20, 20)
        return false
    end

    player:outputChat( "Уровень игрока #22dd22"..target_player:GetNickName().." #ffffffизменён с #dd2222"..target_player:GetLevel().." #ffffffна #dd2222"..new_level , 255, 255, 255, true ) 
    LogSlackCommand( "[Level] Уровень игрока %s был изменён с %s на %s администратором %s по причине %s", target_player, target_player:GetLevel(), new_level, player, reason )

    target_player:SetLevel( new_level )
end
addCommandHandler( "setlevel", Player_SetLevel)

-- Изменение социального рейтинга
function Player_SetSocialRating( player, command, target_id, value, ... )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local reason = table.concat( { ... }, " " )
    if utf8.len( reason ) <= 0 then return ERRCODE_WRONG_SYNTAX end

    if not value or not tonumber(value) then
        return ERRCODE_WRONG_SYNTAX
    end

    local value = tonumber(value)

    player:outputChat( "Социальный рейтинг игрока #22dd22"..target_player:GetNickName().." #ffffffизменён на #dd2222"..value , 255, 255, 255, true )
    LogSlackCommand( "[Rating] Социальный рейтинг игрока %s был изменён на %s администратором %s по причине %s", target_player, value, player, reason )

    target_player:SetSocialRating( value )
    target_player:SetSocialRatingAnchor( value )
end
addCommandHandler( "setrating", Player_SetSocialRating)

-- Фриз-анфриз
function Player_Freeze( player, command, target_id )
    local target_player = PlayerParseCommand( player, command, target_id )
    if not target_player then return end

    target_player.frozen = not target_player.frozen

    local task = target_player.frozen and "заморожен" or "разморожен"
    outputChatBox( target_player:GetNickName() .. " был " .. task .. " " .. player:GetNickName(), player, 255, 0, 0 )

    LogSlackCommand( "%s был %s %s", target_player, task, player )
end
addCommandHandler( "pfreeze", Player_Freeze )
addCommandHandler( "punfreeze", Player_Freeze )

-- Выдача прав хелпера
function Player_Givehelper( player, command, target_id )
    local target_player = PlayerParseCommand( player, command, target_id )
    if not target_player then return end

    local current_rights = target_player:GetAccessLevel()
    if current_rights == 0 and command == "takehelper" then return end
    if current_rights == ACCESS_LEVEL_HELPER and command == "givehelper" then return end

    if current_rights >= player:GetAccessLevel() then return end

    target_player:SetAccessLevel( current_rights == 0 and ACCESS_LEVEL_HELPER or 0 )

    local task = current_rights == 0 and "получил права хелпера от" or "был лишен прав хелпера"
    outputChatBox( target_player:GetNickName() .. " " .. task .. " " .. player:GetNickName(), player, 255, 0, 0 )

    LogSlackCommand( "%s %s %s", target_player, task, player )

    if current_rights ~= ACCESS_LEVEL_HELPER then
        SendAdminActionToLogserver(
            player:GetNickName( ) .. " выдал права хелпера " .. target_player:GetNickName( ),
            { rights_action = "give_helper" },
            { player, "admin" }, { target_player, "player" }
        )
    else
        SendAdminActionToLogserver(
            player:GetNickName( ) .. " снял права хелпера " .. target_player:GetNickName( ),
            { rights_action = "take_helper" },
            { player, "admin" }, { target_player, "player" }
        )
    end
end
addCommandHandler( "givehelper", Player_Givehelper )
addCommandHandler( "takehelper", Player_Givehelper )

-- Выдача прав модератора
function Player_Givemoderator( player, command, target_id )
    local target_player = PlayerParseCommand( player, command, target_id )
    if not target_player then return end

    local current_rights = target_player:GetAccessLevel()
    if current_rights == 0 and command == "takemoderator" then return end
    if current_rights == ACCESS_LEVEL_MODERATOR and command == "givemoderator" then return end

    if current_rights >= player:GetAccessLevel() then return end

    target_player:SetAccessLevel( current_rights == 0 and ACCESS_LEVEL_MODERATOR or 0 )

    local task = current_rights == 0 and "получил права модератора от" or "был лишен прав модератора"
    outputChatBox( target_player:GetNickName() .. " " .. task .. " " .. player:GetNickName(), player, 255, 0, 0 )

    LogSlackCommand( "%s %s %s", target_player, task, player )

    if current_rights ~= ACCESS_LEVEL_MODERATOR then
        SendAdminActionToLogserver(
            player:GetNickName( ) .. " выдал права модератора " .. target_player:GetNickName( ),
            { rights_action = "give_moderator" },
            { player, "admin" }, { target_player, "player" }
        )
    else
        SendAdminActionToLogserver(
            player:GetNickName( ) .. " снял права модератора " .. target_player:GetNickName( ),
            { rights_action = "take_moderator" },
            { player, "admin" }, { target_player, "player" }
        )
    end
end
addCommandHandler( "givemoderator", Player_Givemoderator )
addCommandHandler( "takemoderator", Player_Givemoderator )

-- Выдача камхака
function Player_Givecamhack( player, command, target_id )
    local target_player = PlayerParseCommand( player, command, target_id )
    if not target_player then return end

    local current_camhack = target_player:GetPermanentData( "camhack" )

    target_player:SetPermanentData( "camhack", not current_camhack )

    local task = not current_camhack and "получил разрешение на камхак" or "был лишен разрешения на камхак"
    outputChatBox( target_player:GetNickName() .. " " .. task .. " " .. player:GetNickName(), player, 255, 0, 0 )

    LogSlackCommand( "%s %s %s", target_player, task, player )
end
addCommandHandler( "camhack", Player_Givecamhack )

-- Кик игрока
function Player_Kick( player, command, target_id, ... )
    local target_player = PlayerParseCommand( player, command, target_id, true ) -- можно самого себя кикать, почему бы и нет
    if not target_player then return end

    local reason = table.concat( { ... }, ' ' )

    outputChatBox( target_player:GetNickName() .. " был кикнут " .. player:GetNickName() .. " по причине: " .. reason, root, 255, 0, 0 )

    LogSlackCommand( "%s был кикнут %s по причине: %s", target_player, player, reason )

    SendAdminActionToLogserver(
        target_player:GetNickName( ) .. " был кикнут " .. player:GetNickName( ) .. " по причине: " .. reason,
        { reason = reason },
        { player, "admin" }, { target_player, "player" }
    )

    target_player:kick( reason )
end
addCommandHandler( "pkick", Player_Kick )

-- Мут игрока
MUTE_TIMERS = { }
function Player_Mute( player, command, target_id, duration, ... )
    local target_player = PlayerParseCommand( player, command, target_id, true ) -- можно мутить себя, почему бы и нет
    if not target_player then return end

    local duration = tonumber( duration )
    if command == "pmute" and not duration then return ERRCODE_WRONG_SYNTAX end

    if isTimer( MUTE_TIMERS[ target_player ] ) then killTimer( MUTE_TIMERS[ target_player ] ) end

    local mute_state = target_player.muted

    if command == "pmute" and not mute_state then
        target_player.muted = true
        local reason = table.concat( { ... }, ' ' )
        outputChatBox( target_player:GetNickName() .. " получил мут от " .. player:GetNickName() .. " на " .. duration .. " м. по причине: " .. reason, root, 255, 0, 0 )
        LogSlackCommand( "%s получил мут от %s на %s м. по причине: %s", target_player, player, duration, reason )
        target_player:SetPermanentData( "muted", getRealTime().timestamp + duration * 60 )
        target_player:SetPrivateData( "_muted", true )
        MUTE_TIMERS[ target_player ] = Timer( UnmuteAfterTimer, duration * 60 * 1000, 1, target_player )

        SendAdminActionToLogserver(
            target_player:GetNickName() .. " получил мут от " .. player:GetNickName() .. " на " .. duration .. " м. по причине: " .. reason,
            { reason = reason, time = duration },
            { player, "admin" }, { target_player, "player" }
        )

    elseif command == "punmute" and mute_state then
        target_player.muted = false
        outputChatBox( target_player:GetNickName() .. " получил размут от " .. player:GetNickName(), root, 0, 255, 0 )
        LogSlackCommand( "%s получил размут от %s", target_player, player )
        target_player:SetPermanentData( "muted", 0 )
        target_player:SetPrivateData( "_muted", false )

        SendAdminActionToLogserver(
            target_player:GetNickName() .. " получил размут от " .. player:GetNickName(),
            { },
            { player, "admin" }, { target_player, "player" }
        )
    else
        player:outputChat( "Выполнение команды не требуется", 255, 255, 0 )
    end
end
addCommandHandler( "pmute", Player_Mute )
addCommandHandler( "punmute", Player_Mute )

function UnmuteAfterTimer( player )
    if not isElement( player ) then return end
    player.muted = false
    player:SetPermanentData( "muted", 0 )
    player:SetPrivateData( "_muted", false )
    player:ShowInfo( "Вы снова можете говорить с другими игроками" )
end

function onPlayerCompleteLogin_MuteHandler( )
    local muted = source:GetPermanentData( "muted" )
    if tonumber( muted ) and muted >= getRealTime().timestamp then
        local duration = muted - getRealTime().timestamp
        source.muted = true
        source:SetPrivateData( "_muted", true )
        MUTE_TIMERS[ source ] = Timer( UnmuteAfterTimer, duration * 1000, 1, source )
    end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_MuteHandler )

function onPlayerPreLogout_MuteHandler( )
    if isTimer( MUTE_TIMERS[ source ] ) then killTimer( MUTE_TIMERS[ source ] ) end
    MUTE_TIMERS[ source ] = nil
end
addEventHandler( "onPlayerQuit", root, onPlayerPreLogout_MuteHandler )


-- Бан и разбан игрока
function Player_Ban( player, command, target_id, duration, ... )
    local target_player = PlayerParseCommand( player, command, target_id )
    if not target_player then return end

    if target_player:IsAdmin() then
        if player:GetAccessLevel() < ACCESS_LEVEL_DEVELOPER then
            player:outputChat( "Вы не можете банить членов администрации", 255, 0, 0 )
            return
        end
    end

    local duration = tonumber( duration ) or 0

    if not AdminTryGiveSomething( player, target_player, "ban", 1 ) then
        return ERRCODE_DAILY_LIMITS
    end

    local reason = table.concat( { ... }, ' ' )
    outputChatBox( target_player:GetNickName() .. " был забанен " .. player:GetNickName() .. " по причине: " .. reason, root, 255, 0, 0 )
    target_player:SetPermanentData( "banned", getRealTime().timestamp + duration * 60 )

    local banned_serials = target_player:GetPermanentData( "banned_serials" )
    table.insert( banned_serials, target_player.serial )
    target_player:SetPermanentData( "banned_serials", banned_serials )

    LogSlackCommand( "%s забанил игрока %s на %s по причине: %s", player, target_player, duration * 60, reason )

    SendAdminActionToLogserver(
        target_player:GetNickName( ) .. " был забанен " .. player:GetNickName( ) .. " по причине: " .. reason,
        { reason = reason, time = duration * 60 },
        { player, "admin" }, { target_player, "player" }
    )

    Ban( _, _, target_player.serial, player, reason, duration * 60 )
end
addCommandHandler( "pban", Player_Ban )

function Player_Banoffline( player, command, target_uid, duration, ... )
    local target_uid = tonumber( target_uid )
    if not target_uid then return ERRCODE_WRONG_SYNTAX end

    local duration = tonumber( duration ) or 0

    if GetPlayer( target_uid, true ) then
        player:outputChat( "Игрок должен быть оффлайн для бана", 255, 0, 0 )
        return
    end
    
    local args = { ... }

	DB:queryAsync( function( qh )
		local result = qh:poll( -1 )

		if #result <= 0 then
			player:outputChat( "Игрок с таким UserID не найден (" .. tostring( target_uid ) ..")", 255, 0, 0 )
			return
		end

		local data = result[ 1 ]

		if data.accesslevel >= player:GetAccessLevel() and player:GetAccessLevel() < ACCESS_LEVEL_DEVELOPER then
			player:outputChat( "Нельзя забанить администратора старше рангом", 255, 0, 0 )
			return
		end
 
		if not AdminTryGiveSomething( player, player, "ban", 1 ) then
			return ERRCODE_DAILY_LIMITS
		end

		DB:exec( "UPDATE nrp_players SET banned=? WHERE id=? LIMIT 1", getRealTime().timestamp + duration * 60, target_uid )

		local reason = table.concat( args, ' ' )
		outputChatBox( data.nickname .. " был забанен " .. player:GetNickName() .. " по причине: " .. reason, root, 255, 0, 0 )

		LogSlackCommand( "[Offline] %s забанил игрока %s на %s", player, data.nickname, duration * 60 )

		SendAdminActionToLogserver(
			data.nickname .. " был забанен " .. player:GetNickName() .. " по причине: " .. reason,
			{ ban_type = "offline", reason = reason, time = duration * 60, player_name = data.nickname, player_clientid = data.client_id, player_serial = data.last_serial, player_id = data.id },
			{ player, "admin" }
		)
	end, {}, "SELECT id, nickname, accesslevel, client_id, last_serial FROM nrp_players WHERE id=? LIMIT 1", target_uid )
end
addCommandHandler( "pbanoffline", Player_Banoffline )

function onPlayerCompleteLogin_BanHandler( )
    local banned_timestamp = tonumber( source:GetPermanentData( "banned" ) )
    if not banned_timestamp then return end

	local banned_timeleft = banned_timestamp - getRealTime().timestamp
    if banned_timeleft > 0 then
        local banned_serials = source:GetPermanentData( "banned_serials" )
        table.insert( banned_serials, source.serial )
        source:SetPermanentData( "banned_serials", banned_serials )

        SendAdminActionToLogserver(
            "Автоматический бан для " .. source:GetNickName( ),
            { ban_type = "automatic", time = banned_timeleft * 60 },
            { source, "player" }
        )

		Ban( _, _, source.serial, _, "Вы забанены", banned_timeleft )
	end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_BanHandler, true, "low-999999999" )

function Player_Unban( player, command, target_userid )
    if not player:HasCommandAccess( command ) then player:ShowError( ERR_NO_ACCESS ) return end
    local target_userid = tonumber( target_userid )
    if not target_userid then return ERRCODE_WRONG_SYNTAX end

    DB:queryAsync( Player_UnbanCallback, { player, command, target_userid }, "SELECT id, last_serial, nickname, banned_serials, client_id FROM nrp_players WHERE id=? AND banned>0", target_userid )
end
addCommandHandler( "punban", Player_Unban )

function Player_UnbanCallback( query, player, command, target_userid )
    local result = query:poll( -1 )
    if #result <= 0 then
        player:outputChat( "Данный UserID не заблокирован" )
        return
    end
    local result = result[ 1 ]

    local banned_serials = { }
    for i, v in pairs( fromJSON( result.banned_serials or "[[]]" ) or { } ) do
        banned_serials[ v ] = true
    end

    for i, v in pairs( getBans() ) do
        if banned_serials[ v.serial ] then
            player:outputChat( "Разбанен серийный номер: " .. v.serial, 255, 255, 0 )
            removeBan( v )
        end
    end

    DB:exec( "UPDATE nrp_players SET banned=0,banned_serials='' WHERE id=?", target_userid )

    player:outputChat( ">>> Разбан успешно выдан игроку " .. tostring( result.nickname ), 0, 255, 0 )

    LogSlackCommand( "%s разбанил игрока %s (userid %s)", player, result.nickname, target_userid )

    SendAdminActionToLogserver(
        result.nickname .. " был разбанен " .. player:GetNickName( ),
        { ban_type = "offline", reason = reason, player_name = result.nickname, player_clientid = result.client_id, player_serial = result.last_serial, player_id = result.id },
        { player, "admin" }
    )
end


-- /respawn
function Player_Respawn( player )
    if player.dead then return end
    if not player:IsInGame() or not player:HasFinishedTutorial() then return end
    
    if getElementData(player, "is_handcuffed") then
        player:ShowError( "Ты в наручниках!" )
        return
    end

    if getElementData(player, "in_fc") then
        player:ShowError( "Для начала закончи бой" )
        return
    end

    if getElementData( player, "in_race" ) then
        player:ShowError( "Нельзя сделать это во время гонки!" )
        return
    end

    if getElementData(player, "in_clan_event_lobby") then
        player:ShowError( "Нельзя сделать это во время мероприятия!" )
        return
    end

    if getElementData(player, "jailed") then
        player:ShowError( "Нельзя сделать это в заключении!" )
        return
    end

    if getElementData(player, "current_event") then
        player:ShowError( "Нельзя сделать это на эвенте!" )
        return
    end

    if getElementData(player, "in_coop_quest") then
        player:ShowError( "Нельзя сделать это во время квеста!" )
        return
    end

    local default_cooldown = 60 * 15 -- 15 минут
    local cur_timestamp = getRealTimestamp()
    local last_use = player:GetPermanentData( "respawn_cmd_ts" ) or 0
    local diff = cur_timestamp - last_use

    if diff < default_cooldown then
        player:ShowError( "Эту команду можно использовать через " .. ( default_cooldown - diff ) .. " секунд." )
        return
    end

    if player:getData( "incasator_has_bag" ) then
        player:setData( "incasator_has_bag", nil, false )
    end

    player.health = 0

    player:SetPermanentData( "respawn_cmd_ts", cur_timestamp )
end
addCommandHandler( "respawn", Player_Respawn )
addCommandHandler( "suicide", Player_Respawn )

-- Лицензии
function Player_License( player, command, target_id, license_num )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local license_num = tonumber( license_num )
    if not license_num then return ERRCODE_WRONG_SYNTAX end

    target_player:GiveLicense( license_num )
    player:outputChat( "Права " .. license_num .. " выданы игроку " .. target_player:GetNickName( ), 0, 255, 0 ) 

    LogSlackCommand( "%s выдал права %s у %s", player, license_num, target_player )

    SendAdminActionToLogserver(
        player:GetNickName( ) .. " выдал права на транспорт " .. license_num .. " игроку " .. target_player:GetNickName( ),
        { license = license_num },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "license", Player_License )

-- Снятие лицензий
function Player_Takelicense( player, command, target_id, license_num )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local license_num = tonumber( license_num )
    if not license_num then return ERRCODE_WRONG_SYNTAX end

    target_player:TakeLicense( license_num )
    player:outputChat( "Права " .. license_num .. " сняты у игрока " .. target_player:GetNickName(), 0, 255, 0 ) 

    LogSlackCommand( "%s снял права %s у %s", player, license_num, target_player )

    SendAdminActionToLogserver(
        player:GetNickName( ) .. " забрал права на транспорт " .. license_num .. " игроку " .. target_player:GetNickName( ),
        { license = license_num },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "takelicense", Player_Takelicense )

-- Выдача денег
function Player_Givemoney( player, command, target_id, amount )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local amount = tonumber( amount )
    if not amount then return ERRCODE_WRONG_SYNTAX end

    if amount <= 0 then return ERRCODE_WRONG_SYNTAX end

    if not AdminTryGiveSomething( player, target_player, "money", amount ) then
        return ERRCODE_DAILY_LIMITS
    end

    target_player:GiveMoney( amount, "admin_command_givemoney" )
    player:outputChat( "Вы выдали " .. amount .. " р. игроку " .. target_player:GetNickName(), 0, 255, 0 ) 

    LogSlackCommand( "%s выдал %s р. у %s", player, amount, target_player )

    SendAdminActionToLogserver(
        player:GetNickName( ) .. " выдал деньги " .. amount .. " игроку " .. target_player:GetNickName( ),
        { amount = amount, money_action = "give" },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "givemoney", Player_Givemoney )

-- Снятие денег
function Player_Takemoney( player, command, target_id, amount )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local amount = tonumber( amount )
    if not amount then return ERRCODE_WRONG_SYNTAX end

    target_player:TakeMoney( amount, "admin_command_takemoney" )
    player:outputChat( "Вы сняли " .. amount .. " р. у игрока " .. target_player:GetNickName(), 0, 255, 0 ) 

    LogSlackCommand( "%s снял %s р. у %s", player, amount, target_player )

    SendAdminActionToLogserver(
        player:GetNickName( ) .. " снял деньги " .. amount .. " у игрока " .. target_player:GetNickName( ),
        { amount = amount, money_action = "take" },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "takemoney", Player_Takemoney )


-- Выдача доната
function Player_Givedonate( player, command, target_id, amount )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local amount = tonumber( amount )
    if not amount then return ERRCODE_WRONG_SYNTAX end

    if amount <= 0 then return ERRCODE_WRONG_SYNTAX end

    if not AdminTryGiveSomething( player, target_player, "donate", amount ) then
        return ERRCODE_DAILY_LIMITS
    end

    target_player:GiveDonate( amount, "admin_command_givedonate" )
    WriteLog( "commands/donate", "%s выдал %s донат %s", player, target_player, amount )
    player:outputChat( "Вы выдали " .. amount .. " доната игроку " .. target_player:GetNickName(), 0, 255, 0 ) 

    LogSlackCommand( "%s выдал %s доната %s", player, amount, target_player )

    SendAdminActionToLogserver(
        player:GetNickName( ) .. " выдал донат " .. amount .. " игроку " .. target_player:GetNickName( ),
        { amount = amount, donate_action = "give" },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "givedonate", Player_Givedonate )

-- Снятие денег
function Player_Takedonate( player, command, target_id, amount )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local amount = tonumber( amount )
    if not amount then return ERRCODE_WRONG_SYNTAX end

    target_player:TakeDonate( amount, "admin_command_takedonate" )
    WriteLog( "commands/donate", "%s забрал %s донат %s", player, target_player, amount )
    player:outputChat( "Вы сняли " .. amount .. " доната у игрока " .. target_player:GetNickName(), 0, 255, 0 ) 

    LogSlackCommand( "%s снял %s доната у %s", player, amount, target_player )

    SendAdminActionToLogserver(
        player:GetNickName( ) .. " снял донат " .. amount .. " у игрока " .. target_player:GetNickName( ),
        { amount = amount, donate_action = "take" },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "takedonate", Player_Takedonate )

-- Выдача опыта
function Player_Giveexp( player, command, target_id, amount )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local amount = tonumber( amount )
    if not amount then return ERRCODE_WRONG_SYNTAX end

    target_player:GiveExp( amount )
    WriteLog( "commands/other", "%s выдал %s опыт %s", player, target_player, amount )
    player:outputChat( "Вы выдали " .. amount .. " опыта игроку " .. target_player:GetNickName(), 0, 255, 0 ) 

    LogSlackCommand( "%s выдал %s опыта %s", player, amount, target_player )
end
addCommandHandler( "giveexp", Player_Giveexp )

function Player_Giveclanexp( player, command, target_id, amount )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local amount = tonumber( amount )
    if not amount then return ERRCODE_WRONG_SYNTAX end

    target_player:GiveClanEXP( amount )
    WriteLog( "commands/other", "%s выдал %s рангового опыт %s", player, target_player, amount )
    player:outputChat( "Вы выдали " .. amount .. " рангового опыта игроку " .. target_player:GetNickName(), 0, 255, 0 ) 

    LogSlackCommand( "%s выдал %s рангового опыта %s", player, amount, target_player )
end
addCommandHandler( "giveclanexp", Player_Giveclanexp )

-- Установка скина
function Player_Skin( player, command, target_id, skin_id )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local skin_id = tonumber( skin_id )
    if not skin_id then return ERRCODE_WRONG_SYNTAX end

    target_player.model = skin_id
    local skins = target_player:GetSkins( )
    skins.s1 = skin_id
    target_player:SetPermanentData( "skins", skins )
    target_player:SetPrivateData( "skins", skins )

    WriteLog( "commands/other", "%s установил скин %s на %s", player, target_player, skin_id )
    player:outputChat( "Вы установили скин " .. skin_id .. " игроку " .. target_player:GetNickName(), 0, 255, 0 ) 

    LogSlackCommand( "%s установил скин %s игроку %s", player, skin_id, target_player )

    SendAdminActionToLogserver(
        player:GetNickName( ) .. " установил скин " .. skin_id .. " игроку " .. target_player:GetNickName( ),
        { skin_id = skin_id, skin_type = "permanent" },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "skin", Player_Skin )

-- Установка временного скина
function Player_Tempskin( player, command, target_id, skin_id )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local skin_id = tonumber( skin_id )
    if not skin_id then return ERRCODE_WRONG_SYNTAX end

    target_player.model = skin_id

    WriteLog( "commands/other", "%s установил временный скин %s на %s", player, target_player, skin_id )
    player:outputChat( "Вы установили временный скин " .. skin_id .. " игроку " .. target_player:GetNickName(), 0, 255, 0 ) 

    LogSlackCommand( "%s установил временный скин %s игроку %s", player, skin_id, target_player )

    SendAdminActionToLogserver(
        player:GetNickName( ) .. " установил временный скин " .. skin_id .. " игроку " .. target_player:GetNickName( ),
        { skin_id = skin_id, skin_type = "temporary" },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "tempskin", Player_Tempskin )

-- Оживление
function Player_Revive( player, command, target_id )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    if not isPedDead( target_player ) then return end

    target_player:spawn( target_player.position, target_player.rotation, target_player.model, target_player.interior, target_player.dimension )

    WriteLog( "commands/donate", "%s оживил %s", player, target_player )
    player:outputChat( "Вы оживили игрока " .. target_player:GetNickName(), 0, 255, 0 ) 
end
addCommandHandler( "reviving", Player_Revive )


function Player_Setnickname( player, command, target_id, ... )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local nickname = table.concat( { ... }, " " )

	nickname = utf8.gsub(nickname, "Ё", "Е")
	nickname = utf8.gsub(nickname, "ё", "е")
    local success, error = VerifyPlayerName( nickname )
    
    if not success then
        player:outputChat( "Ошибка: " .. tostring( error ), 255, 0, 0 )
        return
    end

    local oldName = player:GetNickName()
	if nickname == oldName then
		player:ShowError( "Имя персонажа уже занято!" )
		return
    end
    
	DB:queryAsync( function( query, player, nickname )
		local result = query:poll( -1 )
		if #result >= 1 then
			player:ShowError( "Имя персонажа уже занято!" )
			return
        end

        WriteLog( "commands/other", "%s установил ник %s на %s", player, target_player, nickname )
        player:outputChat( "Вы установили ник " .. target_player:GetNickName() .. " на " .. nickname, 0, 255, 0 ) 
        LogSlackCommand( "%s установил имя %s игроку %s", player, nickname, target_player )
    
        SendAdminActionToLogserver(
            player:GetNickName( ) .. " установил ник " .. target_player:GetNickName( ) .. " на " .. nickname,
            { nickname_type = "permanent" },
            { player, "admin" }, { target_player, "player" }
        )
    
        target_player:SetNickName( nickname )
        target_player:SetPermanentData( "nickname", nickname )
        target_player:UpdateOfflineData( "nickname", nickname )
	end, { player, nickname }, "SELECT id FROM nrp_players WHERE nickname=?", nickname )
end
addCommandHandler( "setnickname", Player_Setnickname )

function Player_Tempnickname( player, command, target_id, ... )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local nickname = table.concat( { ... }, " " )

	nickname = utf8.gsub(nickname, "Ё", "Е")
	nickname = utf8.gsub(nickname, "ё", "е")
    local success, error = VerifyPlayerName( nickname )
    
    if not success then
        player:outputChat( "Ошибка: " .. tostring( error ), 255, 0, 0 )
        return
    end



    WriteLog( "commands/other", "%s установил временный ник %s на %s", player, target_player, nickname )
    player:outputChat( "Вы установили временный ник " .. target_player:GetNickName() .. " на " .. nickname, 0, 255, 0 ) 
    LogSlackCommand( "%s установил временное имя %s игроку %s", player, nickname, target_player )
    
    SendAdminActionToLogserver(
        player:GetNickName( ) .. " установил временный ник " .. target_player:GetNickName( ) .. " на " .. nickname,
        { nickname_type = "temporary" },
        { player, "admin" }, { target_player, "player" }
    )
    
    target_player:SetNickName( nickname )
end
addCommandHandler( "tempnickname", Player_Tempnickname )


function Player_GiveWeapon( player, command, target_id, ... )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local args = {...}
    local iWeaponID = args[1]
    local sWeaponName = getWeaponNameFromID( iWeaponID )
    local iAmmo = args[2] or 30

    if not sWeaponName then
        player:outputChat("Не указан ID оружия", 255, 0, 0) 
        return false
    end

    target_player:GiveWeapon( iWeaponID, iAmmo, true, true )

    player:outputChat( "Вы выдали игроку " .. target_player:GetNickName() .. " оружие " ..sWeaponName.."("..iAmmo..")" , 0, 255, 0 )
    LogSlackCommand( "%s выдал оружие %s(%s) игроку %s", player, sWeaponName, iAmmo, target_player )

    SendAdminActionToLogserver(
        player:GetNickName( ) .. " выдал оружие " .. sWeaponName .. " (" .. iWeaponID .. ", патроны: " .. iAmmo .. ") игроку " .. target_player:GetNickName( ),
        { weapon_id = iWeaponID, weapon_name = sWeaponName, weapon_ammo = iAmmo, weapon_action = "give" },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "weapongive", Player_GiveWeapon )

function Player_TakeWeapon( player, command, target_id, ... )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    local args = {...}
    local iWeaponID = args[1]
    local sWeaponName = getWeaponNameFromID( iWeaponID )
    local iAmmo = args[2]

    if not sWeaponName then
        player:outputChat("Не указан ID оружия", 255, 0, 0) 
        return false
    end

    target_player:TakeWeapon( iWeaponID, iAmmo )

    player:outputChat( "Вы отняли у игрока " .. target_player:GetNickName() .. " оружие " ..sWeaponName , 0, 255, 0 )
    LogSlackCommand( "%s отнял оружие %s у игрока %s", player, sWeaponName, target_player )

    SendAdminActionToLogserver(
        player:GetNickName( ) .. " забрал оружие " .. sWeaponName .. " (" .. iWeaponID .. ", патроны: " .. iAmmo .. ") у игрока " .. target_player:GetNickName( ),
        { weapon_id = iWeaponID, weapon_name = sWeaponName, weapon_ammo = iAmmo, weapon_action = "take" },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "weapontake", Player_TakeWeapon )

function Player_TakeAllWeapons( player, command, target_id, ... )
    local target_player = PlayerParseCommand( player, command, target_id, true )
    if not target_player then return end

    target_player:TakeAllWeapons(  )

    player:outputChat( "Вы отняли у игрока " .. target_player:GetNickName() .. " всё оружие" , 0, 255, 0 )
    LogSlackCommand( "%s отнял всё оружие у игрока %s", player, target_player )

    SendAdminActionToLogserver(
        player:GetNickName( ) .. " забрал всё оружие у игрока " .. target_player:GetNickName( ),
        { weapon_action = "take_all" },
        { player, "admin" }, { target_player, "player" }
    )
end
addCommandHandler( "takeallweapons", Player_TakeAllWeapons )