function StartTutorialStep( num, is_blend )
    local step = TUTORIAL_STEPS[ num ]
    if not step then
        iprint( "NO TUTORIAL STEP FOUND", num, is_blend, step )
        return
    end

    iprint( "Attempt to enter step ", num, is_blend )
    if step.entrypoint then
        step:entrypoint( is_blend )
    end
end

function CallServerStepFunction( id, name, ... )
    triggerServerEvent( "CallServerStepFunction", resourceRoot, id, name, ... )
end

function CallClientStepFunction_handler( id, name, ... )
    local step = TUTORIAL_STEPS[ id ]
    if not step then return end

    if step[ name ] then
        step[ name ]( step, ... )
    end
end
addEvent( "CallClientStepFunction", true )
addEventHandler( "CallClientStepFunction", root, CallClientStepFunction_handler )