function CallServerStepFunction_handler( id, name, ... )
    local step = TUTORIAL_STEPS[ id ]
    if not step then return end

    if step[ name ] then
        step[ name ]( step, client, ... )
    end
end
addEvent( "CallServerStepFunction", true )
addEventHandler( "CallServerStepFunction", root, CallServerStepFunction_handler )

function CallClientStepFunction( player, id, name, ... )
    if not isElement( player ) then return end
    triggerClientEvent( player, "CallClientStepFunction", resourceRoot, id, name, ... )
end