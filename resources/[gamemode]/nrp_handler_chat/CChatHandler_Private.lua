
local PRIVATE_CHANNELS = {}

function onClientReceivePrivateMessage_handler( message_data )
    local channel_id = message_data.player_id + MAX_CHANNEL_ID
    message_data.player_id = channel_id
    CHAT_CHANNELS_NAME[ channel_id ] = message_data.player_nick

    if not PRIVATE_CHANNELS[ channel_id ] then
        CHAT_SETTING.private_channels = CHAT_SETTING.private_channels + 1
        PRIVATE_CHANNELS[ channel_id ] = true

        local add_chats = { channel_id }
        if CHAT_SETTING.private_channels > 1 and not CHAT_SETTING.btn_close_private then
            table.insert( add_chats, CHAT_SETTING.btn_close_id )
            CHAT_SETTING.btn_close_private = true
        end

        triggerEvent( "onClientAddChatChannelClient", localPlayer, add_chats )
    end

    if message_data.src == localPlayer:GetUserID() and message_data.from_tp then
        triggerEvent( "onPlayerPressPhoneKey", localPlayer, true )
        if not CHAT_SETTING.active_state then
            SwitchChatChannel( channel_id )
            NextMessage()
        end
    elseif message_data.src ~= localPlayer:GetUserID() then
        SwitchChatChannel( channel_id )
    end

    triggerEvent( "onClientReceiveSentMessage", localPlayer, channel_id, GetPlayer( message_data.src ), message_data.message )
end
addEvent( "onClientReceivePrivateMessage", true )
addEventHandler( "onClientReceivePrivateMessage", root, onClientReceivePrivateMessage_handler )

function onClientRemovePrivateChatChannel_handler( channel_id )
    if not PRIVATE_CHANNELS[ channel_id ] then return end
    
    CHAT_SETTING.private_channels = CHAT_SETTING.private_channels - 1

    if CHAT_SETTING.private_channels == 0 and CHAT_SETTING.btn_close_private then
        CHAT_SETTING.btn_close_private = false
        triggerEvent( "onClientRemoveChatChannelClient", localPlayer, { CHAT_SETTING.btn_close_id }, true )       
    end

    PRIVATE_CHANNELS[ channel_id ] = false
    triggerEvent( "onClientRemoveChatChannelClient", localPlayer, { channel_id } )
end
addEvent( "onClientRemovePrivateChatChannel", true )
addEventHandler( "onClientRemovePrivateChatChannel", root, onClientRemovePrivateChatChannel_handler )

function IsPrivateChatExist( player_id )
    local channel_id = player_id + MAX_CHANNEL_ID
    return PRIVATE_CHANNELS[ channel_id ] or false
end