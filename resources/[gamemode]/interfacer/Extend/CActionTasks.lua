-- CActionTasks.lua
Import( "ShActionTasks" )

LOADED_ACTIONS = LOADED_ACTIONS or { }

FNS_GENERAL = {
    StartActionTask = function( self, ... )
        if self.entrypoints.client then
            self.entrypoints.client( self, ... )
        end
    end,

    StopActionTask = function( self, ... )
        if self.exitpoints.client then
            self.exitpoints.client( self, ... )
        end
    end,

    CleanupStep = function( self, step, ... )
        local step_list = self.array.steps
        local step_data = step_list[ step ]
        step_data.cleanup.client( self, ... )
    end,

    SetupStep = function( self, step, ... )
        local step_list = self.array.steps
        local step_data = step_list[ step ]
        iprint( "Clientside SETUP CALL", step, ... )
        step_data.setup.client( self, ... )
    end,

    CallServerFunction = function( self, fn_name, ... )
        triggerServerEvent( self.events.call_server_function_callback, resourceRoot, fn_name, ... )
    end,

    CallClientFunction_callback = function( self, fn_name, ... )
        if self.remote_fns and self.remote_fns.client and self.remote_fns.client[ fn_name ] then
            self.remote_fns.client[ fn_name ]( self, ... )
        end
    end,
}

function LoadAction( array )
    if not array then
        return false, "No action array specified"
    end

    local id = array.id

    if not id then
        return false, "No action id specified"
    end

    if not array.entrypoints then
        return false, "No entrypoint specified for " .. id
    end

    if LOADED_ACTIONS[ id ] then
        return false, "The action is already loaded: " .. id
    end

    LOADED_ACTIONS[ id ] = {
        -- Общие данные
        id         = id,
        array      = array,

        -- Точки начала, конца и проверки
        entrypoints = array.entrypoints,
        exitpoints  = array.exitpoints,
        checkpoints = array.checkpoints,

        remote_fns = array.remote_fns,

        -- Ивенты и алиасы к функциям
        events = { },
        fns = { }
    }

    local self = LOADED_ACTIONS[ id ]

    -- Обертка для self'а в ивентах
    local wrapped_fns = { }
    for i, v in pairs( FNS_GENERAL ) do
        wrapped_fns[ i ] = function( ... )
            v( self, ... )
        end
    end

    for fn, event_pattern in pairs( EVENT_PATTERNS_CLIENT ) do
        local event_name = string.gsub( event_pattern, "%$(%w+)", { id = self.id } )
        local fn_target = FN_PATTERNS_CONVERSION_CLIENT[ fn ]
        if fn_target then
            self.events[ fn ] = event_name
            self.fns[ fn ] = FNS_GENERAL[ fn_target ]

            addEvent( event_name, true )
            addEventHandler( event_name, root, wrapped_fns[ fn_target ] )
        end
    end

    for fn, event_pattern in pairs( EVENT_PATTERNS_SERVER ) do
        local event_name = string.gsub( event_pattern, "%$(%w+)", { id = self.id } )
        self.events[ fn ] = event_name
    end

    for fn, fn_target_name in pairs( FN_PATTERNS_CONVERSION_CLIENT ) do
        local fn_target = FN_PATTERNS_CONVERSION_CLIENT[ fn ]
        if fn_target then
            self.fns[ fn ] = FNS_GENERAL[ fn_target ]
        end
    end

    iprint( "Created new task clientside", self.id )
end

function UnloadAction( id )

end

function IsActionAvailableServerside( player, id )

end