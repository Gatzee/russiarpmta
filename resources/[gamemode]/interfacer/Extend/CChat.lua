
Player.SendMessageToServer = function( self, channel_id, msg )
    if not channel_id or not msg or msg == "" then
        outputDebugString( "Error sending message client to server, invalid arguments! [channel_id: " .. tostring( channel_id ) .. ", msg: " .. tostring( msg ), 1 )
        return
    end
    triggerServerEvent( "onServerReceiveSentMessage", self, channel_id, msg )
end

Player.SendMessage = function( self, channel_id, msg, color )
    if not channel_id or not msg or msg == "" then
        outputDebugString( "Error sending message from client to client, invalid arguments! [channel_id: " .. tostring( channel_id ) .. ", msg: " .. tostring( msg ), 1 )
        return
    end
    triggerEvent( "onClientReceiveSentMessage", root, channel_id, _, msg, color or 0xFFFFFFFF )
end

Player.ShowChat = function( self, state )
    triggerEvent( "onClientSetChatState", self, state )
end

Player.AddChatChannel = function( self, channel_id, active )
    triggerEvent( "onClientAddChatChannelClient", self, { channel_id }, active ) 
end

Player.RemoveChatChannel = function( self, channel_id )
    triggerEvent( "onClientRemoveChatChannelClient", self, { channel_id } ) 
end