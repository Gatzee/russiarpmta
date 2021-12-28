Extend( "ib" )
Extend( "CPlayer" )
Extend( "CChat" )
Extend( "CUI" )

ibUseRealFonts( true )

CHAT_CHANNELS = {}
REVERSE_CHAT_CHANNELS = {}

function onClientReceiveSentMessage_handler( channel_id, sender, message, color, faction_prefix )
    if not CHAT_SETTING.chat_state then return end

    sender = sender or source
    if not sender or not message or message == "" then return false end
    
    local message_model = create_message( sender, message, channel_id, color, faction_prefix )
    if not REVERSE_CHAT_CHANNELS[ message_model.channel_id ] then  return end

    AddCacheMessage( message_model )
end
addEvent( "onClientReceiveSentMessage", true )
addEventHandler( "onClientReceiveSentMessage", root, onClientReceiveSentMessage_handler )

function onClientSetChatState_handler( state )
    SetChatActiveState( state )
end
addEvent( "onClientSetChatState", true )
addEventHandler( "onClientSetChatState", root, onClientSetChatState_handler )

function onClientSwitchChatChannel_handler( channel_id )
    SwitchChatChannel( channel_id )
end
addEvent( "onClientSwitchChatChannel", true )
addEventHandler( "onClientSwitchChatChannel", root, onClientSwitchChatChannel_handler )

function onClientAddChatChannelClient_handler( chat_channels_ids, is_set_active )
    for k, v in ipairs( chat_channels_ids ) do
        table.insert( CHAT_CHANNELS, 
        { 
            channel_id = v,
        } )
    end

    for k, v in ipairs( CHAT_CHANNELS ) do
        if not  REVERSE_CHAT_CHANNELS[ v.channel_id ] then
            REVERSE_CHAT_CHANNELS[ v.channel_id ] = v
        end
    end

    RefillActiveChatChannels()
    if is_set_active then SwitchChatChannel( chat_channels_ids[ 1 ] ) end
end
addEvent( "onClientAddChatChannelClient", true )
addEventHandler( "onClientAddChatChannelClient", root, onClientAddChatChannelClient_handler )

function onClientRemoveChatChannelClient_handler( chat_channels_ids, remove_btn )
    local temp = {}
    local remove_current_chat = false
    for k, v in ipairs( CHAT_CHANNELS ) do
        local find = false
        for _, channel_id in ipairs( chat_channels_ids ) do
            if channel_id == v.channel_id then
                find = true
                if not remove_current_chat then
                    remove_current_chat = CHAT_SETTING.current_channel_id == v.channel_id
                end
                break
            end
        end

        if not find then
            table.insert( temp, v )
        end
    end
    CHAT_CHANNELS = temp
    
    for k, v in pairs( chat_channels_ids ) do
        REVERSE_CHAT_CHANNELS[ v ] = nil
    end

    RefillActiveChatChannels()

    if remove_current_chat then
        SwitchChatChannel( CHAT_TYPE_NORMAL )
    end
end
addEvent( "onClientRemoveChatChannelClient", true )
addEventHandler( "onClientRemoveChatChannelClient", root, onClientRemoveChatChannelClient_handler )

function onClientInitializeChat_handler( chat_channels_ids )
    if fileExists( "not_switch_channel" ) then CHAT_SETTING.switch_channel = false end

    for k, v in ipairs( chat_channels_ids ) do
        table.insert( CHAT_CHANNELS, 
        { 
            channel_id = v,
        } )
    end

    for k, v in ipairs( CHAT_CHANNELS ) do
        REVERSE_CHAT_CHANNELS[ v.channel_id ] = v
    end

    LoadMergeSetting()
    SetChatActiveState( true )
    showChat( false )
end
addEvent( "onClientInitializeChat", true )
addEventHandler( "onClientInitializeChat", root, onClientInitializeChat_handler )

function onClientChatMessage_handler( text, r, g, b )
    triggerEvent( "onClientReceiveSentMessage", root, CHAT_TYPE_NORMAL, root, text:gsub( '#%x%x%x%x%x%x', '' ), tocolor( r, g, b ) )
end
addEventHandler( "onClientChatMessage", root, onClientChatMessage_handler )

function onStart()
    setTimer( showChat, 50, 0, false )
    
    if localPlayer:IsInGame() then
        if fileExists( "not_switch_channel" ) then CHAT_SETTING.switch_channel = false end
        guiSetInputMode( "no_binds_when_editing" )
        triggerServerEvent( "onServerInitializeChat", localPlayer )
    end
    
    for k, v in pairs( CHAT_CHANNELS_NAME ) do
        if k > MAX_CHANNEL_ID then MAX_CHANNEL_ID = k end
    end

    CHAT_CHANNELS_NAME[ CHAT_SETTING.btn_close_id ] = "Закрыть все СМС"
end
addEventHandler( "onClientResourceStart", resourceRoot, onStart )

function onSettingsChange_handler( changed, values )
    if not changed.switch_channel then return end
        
    if values.switch_channel then
        CHAT_SETTING.switch_channel = true
        if fileExists( "not_switch_channel" ) then fileDelete( "not_switch_channel" ) end
    else
        CHAT_SETTING.switch_channel = false
        local new_file = fileCreate( "not_switch_channel" )
        fileClose( new_file )
    end
end
addEvent( "onSettingsChange" )
addEventHandler( "onSettingsChange", root, onSettingsChange_handler )

--Команда для орущих, что время не могут узнать( Пидорасов )
function PrintTime()
    local time = getRealTime()
    local msg = "Текущее время: " .. time.hour .. ":" .. time.minute .. ":" .. time.second
    triggerEvent( "onClientReceiveSentMessage", root, CHAT_SETTING.current_channel_id, _, msg, 0xFF00FF00 )
end
addCommandHandler( "time", PrintTime )