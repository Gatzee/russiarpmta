-- SActionTasks.lua
Import( "ShActionTasks" )

LOADED_ACTIONS = LOADED_ACTIONS or { }

FNS_GENERAL = {
    StartActionTask = function( self, player, ... )
        iprint( "START ACTION TASK", player, self.players_data )
        self.players_data[ player ] = {
            step = 0,
        }

        addEventHandler( "onPlayerQuit", player, self.fns.on_quit )
        addEventHandler( "onPlayerWasted", player, self.fns.on_wasted )

        if self.entrypoints.server then
            self.entrypoints.server( self, player, ... )
        end

        if self.entrypoints.client then
            triggerClientEvent( player, self.events.start, resourceRoot, ... )
        end

        self.fns.step_next( self, player )
    end,

    StopActionTask = function( self, player, ignore_call_client, args_server, args_client, success )
        if self.exitpoints.server then
            self.exitpoints.server( self, player, success, unpack( args_server or { } ) )
        end

        if not ignore_call_client and self.exitpoints.client then
            triggerClientEvent( player, self.events.stop, resourceRoot, success, unpack( args_client or { } ) )
        end

        removeEventHandler( "onPlayerQuit", player, self.fns.on_quit )
        removeEventHandler( "onPlayerWasted", player, self.fns.on_wasted )
        self.players_data[ player ] = nil
    end,

    StartStep = function( self, player, step, args_server, args_client )
        local current_step = self.players_data[ player ].step

        self.fns.call_step_cleanup( self, player, current_step, args_server, args_client )

        -- Если есть этап
        local step_list = self.array.steps
        local step_data = step_list[ step ]
        if step_data then
            self.fns.call_step_setup( self, player, step, args_server, args_client )
            self.players_data[ player ].step = step
            return true
        end
    end,

    NextStep = function( self, player, args_server, args_client )
        if not self.fns.step_start( self, player, self.players_data[ player ].step + 1, args_server, args_client ) then
            self.fns.stop( self, player, false, args_server, args_client, true )
        end
    end,

    CallClientFunction = function( self, player, fn_name, ... )
        triggerClientEvent( player, self.events.call_client_function_callback, resourceRoot, fn_name, ... )
    end,

    CallServerFunction_callback = function( self, player, fn_name, ... )
        if self.remote_fns and self.remote_fns.server and self.remote_fns.server[ fn_name ] then
            self.remote_fns.server[ fn_name ]( self, client, ... )
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
        fns = { },

        -- Данные игроков на время выполнения задачи
        players_data = { },
    }

    local self = LOADED_ACTIONS[ id ]

    -- Обертка для self'а в ивентах
    local wrapped_fns = { }
    local function WrapFunction( name, fn )
        wrapped_fns[ name ] = function( ... )
            fn( self, source, ... )
        end
        return wrapped_fns[ name ]
    end

    -- Обертка для общшх функций, которые можно вызывать всегда
    for i, v in pairs( FNS_GENERAL ) do WrapFunction( i, v ) end

    -- Обертка временных функций с переключаемым ивентом
    self.fns.on_quit = WrapFunction( "on_quit", function ( self, source )
        self.fns.stop( self, source, true )
    end )

    self.fns.on_wasted = WrapFunction( "on_wasted", function( self, source )
        self.fns.stop( self, source, false )
    end )

    self.fns.call_step_cleanup = function( self, player, step, args_server, args_client )
        local step_list = self.array.steps
        local step_data = step_list[ step ]

        if step_data and step_data.cleanup then
            if step_data.cleanup.server then
                step_data.cleanup.server( self, player, unpack( args_server or { } ) )
            end

            if step_data.cleanup.client then
                triggerClientEvent( player, self.events.step_cleanup, resourceRoot, step, unpack( args_client or { } ) )
            end

            return true
        end
    end

    self.fns.call_step_setup = function( self, player, step, args_server, args_client )
        local step_list = self.array.steps
        local step_data = step_list[ step ]

        if step_data and step_data.setup then
            if step_data.setup.server then
                step_data.setup.server( self, player, unpack( args_server or { } ) )
            end

            if step_data.setup.client then
                triggerClientEvent( player, self.events.step_setup, resourceRoot, step, unpack( args_client or { } ) )
            end

            return true
        end
    end

    -- Магия, не трогать
    for fn, event_pattern in pairs( EVENT_PATTERNS_SERVER ) do
        local event_name = string.gsub( event_pattern, "%$(%w+)", { id = self.id } )
        local fn_target = FN_PATTERNS_CONVERSION_SERVER[ fn ]
        if fn_target then
            self.events[ fn ] = event_name
            self.fns[ fn ] = FNS_GENERAL[ fn_target ]

            addEvent( event_name, true )
            addEventHandler( event_name, root, wrapped_fns[ fn_target ] )
        end
    end

    for fn, event_pattern in pairs( EVENT_PATTERNS_CLIENT ) do
        local event_name = string.gsub( event_pattern, "%$(%w+)", { id = self.id } )
        self.events[ fn ] = event_name
    end

    for fn, fn_target_name in pairs( FN_PATTERNS_CONVERSION_SERVER ) do
        local fn_target = FN_PATTERNS_CONVERSION_SERVER[ fn ]
        if fn_target then
            self.fns[ fn ] = FNS_GENERAL[ fn_target ]
        end
    end

    -- Ивенты шагов
    for i, v in pairs( self.array.steps ) do
        local event_end = v.event_end or string.gsub( "$id_$step_event_end", "%$(%w+)", { id = self.id, step = i } )
        addEvent( event_end, true )
        addEventHandler( event_end, root, function( args_server, args_client )
            iprint( "STEP:", self.players_data[ source ].step, i )
            if self.players_data[ source ].step == i then
                self.fns.step_next( self, source )
            else
                outputDebugString( "attept to finish wrong step", 1 )
            end
        end )
    end

    iprint( "Created new task serverside", self.id )
    return self
end

--[[function UnloadAction( id )

end]]

function IsActionAvailableServerside( id, player )
    local self = LOADED_ACTIONS[ id ]
    if not self then
        return false, "Задача отключена" 
    end

    if self.players_data[ player ] then
        return false, "Задача уже активна"
    end

    -- TODO: Добавить основные проверки на запуск

    if self.checkpoints and self.checkpoints.server then
        return self.checkpoints.server( self, player )
    end
end

function GetActionTask( id )
    return LOADED_ACTIONS[ id ]
end