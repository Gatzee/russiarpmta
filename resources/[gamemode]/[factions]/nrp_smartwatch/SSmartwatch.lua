loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "Globals" )

function SWAction_handler( msg )
    triggerEvent( "onServerReceiveSentMessage", client, CHAT_TYPE_DO, msg, client )
end
addEvent( "SWAction", true )
addEventHandler( "SWAction", root, SWAction_handler )