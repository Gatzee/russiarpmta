

Player.SendMessage = function( self, channel_id, msg, color )
    if not channel_id or not msg or msg == "" then
        outputDebugString( "Error sending message from server to client, invalid arguments! [channel_id: " .. tostring( channel_id ) .. ", msg: " .. tostring( msg ), 1 )
        return
    end
    triggerClientEvent( self, "onClientReceiveSentMessage", root, channel_id, _, msg, color or 0xFFFFFFFF )
end

Player.ShowChat = function( self, state )
    triggerClientEvent( self, "onClientSetChatState", self, state )
end

Player.AddChatChannel = function( self, channel_id, active )
    triggerClientEvent( self, "onClientAddChatChannelClient", self, { channel_id }, active ) 
end

Player.RemoveChatChannel = function( self, channel_id )
    triggerClientEvent( self, "onClientRemoveChatChannelClient", self, { channel_id } ) 
end