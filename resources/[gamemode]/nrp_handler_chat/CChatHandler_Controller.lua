CHAT_SETTING = 
{
    chat_state = false,
    current_channel_id = 1,
    select_chat_list = false,
    
    switch_channel = false,
    active_state = false,
    
    max_messages = 50,
    max_messsage_len = 200,

    btn_close_private = false,
    btn_close_id = 99999999,
    private_channels = 0,

    blocked_channels = {},
    blocked_time = 60000,
}

CACHE_MESSAGES = {} --divide2tables

MAX_CHANNEL_ID = 1

function AddCacheMessage( message_model )
    table.insert( CACHE_MESSAGES, message_model )

    local first_msg_id = nil
    local count_msg = 0
    local target_channel_id = message_model.channel_id
    for k, v in pairs( CACHE_MESSAGES ) do
        if v.channel_id == target_channel_id then
            count_msg = count_msg + 1
            if not first_msg_id then first_msg_id = k end
        end
    end
    if count_msg > CHAT_SETTING.max_messages then table.remove( CACHE_MESSAGES, first_msg_id ) end

    local merge_channel_data = MERGE_CHANNELS[ CHAT_SETTING.current_channel_id ]
    if CHAT_SETTING.current_channel_id == target_channel_id or (merge_channel_data and merge_channel_data[ target_channel_id ]) then
        local push_result = CHAT_SETTING.active_state and RefillActiveChatMessages() or RefillPassiveChatMessages()
    end
end

function GetCacheMessages( channel_id )
    local target_messages = {}
    for k, v in pairs( CACHE_MESSAGES ) do
        local is_merge = (MERGE_CHANNELS[ channel_id ] and MERGE_CHANNELS[ channel_id ][ v.channel_id ]) and MERGE_CHANNELS[ channel_id ][ v.channel_id ].merge or false
        if channel_id == v.channel_id or is_merge then
            table.insert( target_messages, v )
        end
    end
    return target_messages 
end

function SetChatActiveState( state )
    CHAT_SETTING.chat_state = state
    
    unbindKey( "t", "down", NextMessage )
    unbindKey( "y", "down", OpenFactionOrClanChat )
    unbindKey( "u", "down", OpenAllFactionOrClanChat)
    unbindKey( "b", "down", OpenOfftopChat )

    if state then
        bindKey( "t", "down", NextMessage, true )
        bindKey( "y", "down", OpenFactionOrClanChat )
        bindKey( "u", "down", OpenAllFactionOrClanChat )
        bindKey( "b", "down", OpenOfftopChat )
        ShowActiveChat( false )
        ShowPassiveChat( true )        
    else
        ShowActiveChat( false )
        ShowPassiveChat( false )
        showCursor( false, not localPlayer:getData( "bFirstPerson" ) )
    end
end

function NextMessage( key, key_state, is_bind )
    if is_bind and CHAT_SETTING.switch_channel and CHAT_SETTING.current_channel_id ~= CHAT_TYPE_NORMAL then
        SwitchChatChannel( CHAT_TYPE_NORMAL )
    end

    if CHAT_SETTING.active_state and isElement(UI_elements and UI_elements.edf_message) then 
        UI_elements.edf_message:ibData( "text", "" )
        UI_elements.edf_message:ibData( "caret_position", 0 )  
    end
    ChangeChatMode()
end

function SwitchChatChannel( new_channel_id )
    if CHAT_SETTING.btn_close_id == new_channel_id then
        onClickButtonCloseAllPrivateChannels()
        SwitchChatChannel( CHAT_TYPE_NORMAL )
        return
    elseif CHAT_SETTING.current_channel_id == new_channel_id then
        return
    end

    local old_channel_id = CHAT_SETTING.current_channel_id
    CHAT_SETTING.current_channel_id = new_channel_id

    if CHAT_SETTING.active_state then
        RefillActiveChatMessages()
        RefreshStatesActiveChat( old_channel_id, new_channel_id )
        
        if isElement(UI_elements and UI_elements.edf_message) then
            UI_elements.edf_message:ibTimer( function( self ) 
                if CheckBlockCurrentChannel() then return end
                self:ibData( "focused", true )
            end, 150, 1 )
        end
    else
        RefillPassiveChatMessages()
    end
end

function ChangeChatMode()
    if not CHAT_SETTING.active_state then
        ShowPassiveChat( false )
        ShowActiveChat( true )
        CHAT_SETTING.active_state = true
    else
        ShowActiveChat( false )
        ShowPassiveChat( true )
        CHAT_SETTING.active_state = false
    end
end

function CheckBlockCurrentChannel()
    local result = false
    local blocked_time = CHAT_SETTING.blocked_channels[ CHAT_SETTING.current_channel_id ]
    if blocked_time and getTickCount() - blocked_time < CHAT_SETTING.blocked_time then
        result = true
    end
    if isElement(UI_elements and UI_elements.edf_message) then
        UI_elements.edf_message:ibData( "disabled", result )
        UI_elements.edf_message:ibData( "alpha", result and 0 or 255 )
    end
    return result
end

function SendMessageToServer()
    if CheckBlockCurrentChannel() then return end
    
    local msg = UI_elements.edf_message:ibData( "text" )
    if msg == "" then 
        NextMessage()
        return 
    end
    
    if CHAT_SETTING.current_channel_id > MAX_CHANNEL_ID and utf8.len( msg ) > 0 then
        local res = utf8.gsub( msg, "%s+", "" )
        if utf8.len( res ) > 0 then
            triggerServerEvent( "onServerPlayerSendSmsByChat", localPlayer, CHAT_SETTING.current_channel_id - MAX_CHANNEL_ID, msg )
        end
    else
        local msg_unpacked = split( msg, " " )
        local command = msg_unpacked[1]
        if command and command:sub(1, 1) == "/" then
            local command = utf8.sub( command, 2, utf8.len( command ) )
            if command ~= "" and  CHAT_SETTING.current_channel_id == CHAT_TYPE_NORMAL then 
                table.remove( msg_unpacked, 1 )
                local args = table.concat( msg_unpacked, " " )
                local execute = executeCommandHandler( command, args )
                if execute then 
                    NextMessage()
                    return 
                end
            end
        elseif CHAT_SETTING.current_channel_id == CHAT_TYPE_TRADE and not command then
            NextMessage()
            return 
        end

         if CHAT_SETTING.current_channel_id == CHAT_TYPE_TRADE then
            CHAT_SETTING.blocked_channels[ CHAT_SETTING.current_channel_id ] = getTickCount()
        end

        localPlayer:SendMessageToServer( CHAT_SETTING.current_channel_id, msg )
    end

    NextMessage()
end

function OpenFactionOrClanChat()
    local is_faction = localPlayer:GetFaction()
    local is_clan = localPlayer:IsInClan()

    if is_faction ~= 0 then
        SwitchChatChannel( CHAT_TYPE_FACTION )
    elseif is_clan then
        SwitchChatChannel( CHAT_TYPE_CLAN )
    else
        return false
    end

    ChangeChatMode()
end

function OpenAllFactionOrClanChat()
    local is_faction = localPlayer:GetFaction()
    local is_clan = localPlayer:GetClanID()

    if is_faction ~= 0 then
        SwitchChatChannel( CHAT_TYPE_ALLFACTION )
    elseif is_clan then
        SwitchChatChannel( CHAT_TYPE_CLAN )
    else
        return false
    end

    ChangeChatMode()
end

function OpenOfftopChat()
    SwitchChatChannel( CHAT_TYPE_OFFGAME )
    ChangeChatMode()
end