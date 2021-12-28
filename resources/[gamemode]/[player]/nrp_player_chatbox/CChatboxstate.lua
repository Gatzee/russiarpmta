loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )

LAST_STATE = false

function ChatboxTimer()
    if not localPlayer:IsInGame() then return end
    if isPedDead( localPlayer ) then return end

    local new_state = isChatBoxInputActive()
    if not LAST_STATE then
        if new_state then
            setElementData( localPlayer, "chatbox_active", true, false )
            triggerServerEvent( "ChatStart", resourceRoot )
            LAST_STATE = true
        end
    else
        if not new_state then
            setElementData( localPlayer, "chatbox_active", false, false )
            triggerServerEvent( "ChatStop", resourceRoot )
            LAST_STATE = false
        end
    end
end
Timer( ChatboxTimer, 1500, 0 )


DISTANCE_TIMERS = { }
function onClientElementStreamIn_handler()
    if getElementType( source ) ~= "player" then return end
    if source == localPlayer then return end

    onClientElementStreamOut_handler( source )

    setElementData( source, "chatbox_active", false, false )

    addEventHandler( "onClientElementStreamOut", source, onClientElementStreamOut_handler )
    addEventHandler( "onClientPlayerQuit", source, onClientElementStreamOut_handler )

    DISTANCE_TIMERS[ source ] = Timer( 
        function( source )
            if getElementData( source, "chatbox_active" ) and ( localPlayer.position - source.position ):getLength() > 30 then
                setElementData( source, "chatbox_active", false, false )
            end
        end
    , 2500, 0, source )
end
addEventHandler( "onClientElementStreamIn", root, onClientElementStreamIn_handler )

function onClientElementStreamOut_handler( player )
    local player = isElement( player ) and player or source
    setElementData( player, "chatbox_active", false, false )
    if isTimer( DISTANCE_TIMERS[ player ] ) then killTimer( DISTANCE_TIMERS[ player ] ) end
    DISTANCE_TIMERS[ player ] = nil
    removeEventHandler( "onClientElementStreamOut", player, onClientElementStreamOut_handler )
    removeEventHandler( "onClientPlayerQuit", player, onClientElementStreamOut_handler )
end

function C_ChatStart_handler( )
    setElementData( source, "chatbox_active", true, false )
end
addEvent( "C_ChatStart", true )
addEventHandler( "C_ChatStart", root, C_ChatStart_handler )

function C_ChatStop_handler( )
    setElementData( source, "chatbox_active", false, false )
end
addEvent( "C_ChatStop", true )
addEventHandler( "C_ChatStop", root, C_ChatStop_handler )