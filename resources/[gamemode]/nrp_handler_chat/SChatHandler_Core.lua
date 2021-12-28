Extend( "SPlayer" )
Extend( "SChat" )

REPEAT_MESSAGE_TIMEOUT = 2000
NORMAL_MESSAGE_THRESHOLD = 10
ANTISPAM_LAST_MESSAGES = { }

local command_channels = { ["me"] = CHAT_TYPE_ME, ["do"] = CHAT_TYPE_DO, ["try"] = CHAT_TYPE_TRY, ["b"] = CHAT_TYPE_LOCALOOC }

function onServerReceiveSentMessage_handler( channel_id, msg, player )
    player = player or client
    local mask = '[^ a-zA-Zа-яА-ЯёЁ0-9\"\'\\.,!?*@#$%^&()-=_%[%]№;:{}|~`]'
    msg = utf8.gsub( msg, mask, "" )
    if msg:gsub(" ", ""):len() <= 0 then return end

    local msg_unpacked = split(msg, " ")
    local command = msg_unpacked[1]
    if command:sub(1, 1) == "/" then
        
        local command = utf8.sub(command, 2, utf8.len(command))
        if command == "" then return end
        
        table.remove( msg_unpacked, 1 )
        local args = table.concat( msg_unpacked, " " )
        if command_channels[command] then
            onServerReceiveSentMessage_handler( command_channels[ command ], args, player )
            return
        end
        local execute = executeCommandHandler( command, player, args )
        if not execute then
            player:SendMessage( channel_id, "Команда не найдена: " .. command, 0xFFFF0000 )
        end
        return
    end

    local muted = player.muted
    if muted then
        player:SendMessage( channel_id, "Игровой чат был отключен администрацией", 0xFFFF0000 )
        return
    end

    local previous_message_list = ANTISPAM_LAST_MESSAGES[ player ]
    if previous_message_list then
        if #previous_message_list > NORMAL_MESSAGE_THRESHOLD - 1 then
            table.remove( previous_message_list, 1 )
        end
        for i, v in pairs( previous_message_list ) do
            if str == v[ 1 ] and getTickCount() - v[ 2 ] <= REPEAT_MESSAGE_TIMEOUT then
                player:SendMessage( channel_id, "[Запрещено флудить в чат]", 0xFFFF0000 )
                return
            end
        end
    else
        ANTISPAM_LAST_MESSAGES[ player ] = { }
    end
    table.insert( ANTISPAM_LAST_MESSAGES[ player ], { msg, getTickCount() } )



    local target_players = get_local_players( player )
    local color = nil
    local faction_prefix = nil
    if channel_id == CHAT_TYPE_NORMAL or channel_id == CHAT_TYPE_ME or channel_id == CHAT_TYPE_LOCALOOC or channel_id == CHAT_TYPE_DO then
        triggerClientEvent( target_players, "onChat", player, msg, channel_id )
    
    elseif channel_id == CHAT_TYPE_TRY then
        msg =  " попытался " .. msg .. "( " .. (math.random( 1, 2 ) == 1 and "удачно" or "неудачно") .. " )"
        triggerClientEvent( target_players, "onChat", player, msg, channel_id )
    
    elseif channel_id == CHAT_TYPE_ADMIN then
        if not player:IsAdmin() then return  end
        
        faction_prefix = ACCESS_LEVEL_NAMES[ player:GetAccessLevel( ) or 0 ]
        target_players = get_admin_players( player )
    
    elseif channel_id == CHAT_TYPE_CLAN then
        local clan_id = player:GetClanID()
        if not clan_id then  return  end
        target_players = get_clan_players( clan_id )
    
    elseif channel_id == CHAT_TYPE_FACTION then
        
        local faction = player:GetFaction()
        if not faction or faction == 0 or not CHAT_FACTIONS_SHORT_LEVEL_NAMES[ faction ] then  return end
        
        local faction_level = player:GetFactionLevel()
        local faction_level_name = CHAT_FACTIONS_SHORT_LEVEL_NAMES[ faction ] [ faction_level ]
        
        faction_prefix = "[" .. tostring( faction_level_name ) .. "]"
        target_players = get_faction_players( faction )
    
    elseif channel_id == CHAT_TYPE_ALLFACTION then
        
        local faction = player:GetFaction()
        local faction_name = FACTIONS_SHORT_NAMES[ faction ]
        
        if not faction_name then return end
        
        local faction_level = player:GetFactionLevel()
        local faction_level_name = CHAT_FACTIONS_SHORT_LEVEL_NAMES[ faction ] [ faction_level ]
        
        faction_prefix = "(" .. tostring( faction_name ) .. ")[" .. tostring( faction_level_name ) .. ']'
        target_players = get_allfactions_players( )
    
    elseif channel_id == CHAT_TYPE_TRADE then
        target_players = getElementsByType( "player" )
    
    elseif channel_id == CHAT_TYPE_REPORT then
        triggerEvent( "onServerUserTalkToGamemaster", player, msg )
        return true
    
    elseif channel_id == CHAT_TYPE_JOB then
        

        local count_sms = player:getData( "count_sms" )
        if count_sms then
            player:setData( "count_sms", count_sms + 1, false )
        end
        
        target_players = get_job_players( player )
    elseif channel_id == CHAT_TYPE_MEGAPHONE then
        
        local faction = player:GetFaction()
        faction_prefix = FACTIONS_SHORT_NAMES[ faction ]
        
        target_players = get_megaphone_players( player )
    end
    if #target_players > 0 then
        triggerClientEvent( target_players, "onClientReceiveSentMessage", player, channel_id, _, msg, color, faction_prefix )
    end
end
addEvent( "onServerReceiveSentMessage", true )
addEventHandler( "onServerReceiveSentMessage", root, onServerReceiveSentMessage_handler )

function onLogin( player )
    local player = isElement( player ) and player or source
    
    local avaible_chats = 
    {
        CHAT_TYPE_NORMAL, 
        CHAT_TYPE_TRADE,
        CHAT_TYPE_OFFGAME,
    }

    -- Админ чат
    if player:IsAdmin() then 
        table.insert( avaible_chats, CHAT_TYPE_ADMIN )
    end

    -- Общий чат фракций
    if player:IsInFaction() then
        table.insert( avaible_chats, CHAT_TYPE_FACTION )
        table.insert( avaible_chats, CHAT_TYPE_ALLFACTION )
    elseif player:GetClanID() then
        table.insert( avaible_chats, CHAT_TYPE_CLAN )
    end

    triggerClientEvent( player, "onClientInitializeChat", player, avaible_chats )
end
addEventHandler( "onPlayerReadyToPlay", root, onLogin, true, "low-1000000000" )

function onServerInitializeChat_handler()
    if client:IsInGame() then onLogin( client ) end
end
addEvent( "onServerInitializeChat", true )
addEventHandler("onServerInitializeChat", root, onServerInitializeChat_handler )


function onPlayerFactionChange_handler( player )
    local player = isElement( player ) and player or source
    if player:IsInFaction() then
        triggerClientEvent( player, "onClientAddChatChannelClient", player, { CHAT_TYPE_FACTION, CHAT_TYPE_ALLFACTION } )
    else
        triggerClientEvent( player, "onClientRemoveChatChannelClient", player, { CHAT_TYPE_FACTION, CHAT_TYPE_ALLFACTION } )
    end
end
addEvent( "onPlayerFactionChange", true )
addEventHandler( "onPlayerFactionChange", root, onPlayerFactionChange_handler )

function onPlayerJoinClan_handler( player )
    local player = isElement( player ) and player or source
    onPlayerLeaveClan_handler( player )
    triggerClientEvent( player, "onClientAddChatChannelClient", player, { CHAT_TYPE_CLAN } )
end
addEvent( "onPlayerJoinClan", true )
addEventHandler( "onPlayerJoinClan", root, onPlayerJoinClan_handler )

function onPlayerLeaveClan_handler( player )
    local player = isElement( player ) and player or source
    triggerClientEvent( player, "onClientRemoveChatChannelClient", player, { CHAT_TYPE_CLAN } )
end
addEvent( "onPlayerLeaveClan" )
addEventHandler( "onPlayerLeaveClan", root, onPlayerLeaveClan_handler )


function onPlayerPreLogout_handler()
    ANTISPAM_LAST_MESSAGES[ source ] = nil
end
addEventHandler( "onPlayerQuit", root, onPlayerPreLogout_handler )

function onPlayerChat_handler()
    cancelEvent()
end
addEventHandler( "onPlayerChat", root, onPlayerChat_handler )

function onPlayerPrivateMessage_handler()
	cancelEvent()
end
addEventHandler( "onPlayerPrivateMessage", root, onPlayerPrivateMessage_handler )