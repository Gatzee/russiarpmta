Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShTimelib" )
Extend( "SDB" )

RETENTION_TASKS_TIMERS = { }

function onPlayerReadyToPlay_handler( player )
    local player = isElement( player ) and player or source

    local tasks = player:GetPermanentData( "retention_tasks" ) or { }
    local timestamp = getRealTime( ).timestamp
    local timestamp = getRealTimestamp()

    -- Оставляем только валидные задачи
    local start_array = { }
    for id, data in pairs( tasks ) do
        local task = TASKS_CONFIG[ id ]
        if task and (data.timestamp_start and data.timestamp_start <= timestamp) and (data.timestamp_end and data.timestamp_end >= timestamp) then
            start_array[ id ] = data
        else
            StopRetentionTask( player, id )
        end
    end

    -- Начинаем нужные таски
    if next( start_array ) then
        triggerClientEvent( player, "onRetentionTaskStartArrayClientside", resourceRoot, start_array )
        for id, data in pairs( start_array ) do
            local task = TASKS_CONFIG[ id ]
            triggerEvent( "onRetentionTaskStart", player, id, task.name, data )
        end
    end
end
addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler, true, "high" )

function onResourceStart_handler( )
    setTimer( function( )
        for i, v in pairs( GetPlayersInGame( ) ) do
            onPlayerReadyToPlay_handler( v )
        end
    end, 2000, 1 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function StartRetentionTask( player, id, duration )
    local task = TASKS_CONFIG[ id ]
    if not task then return end

    local tasks = player:GetPermanentData( "retention_tasks" ) or { }
    if tasks[ id ] then return end

    local ts = getRealTimestamp()

    if task.global_start and ts <= task.global_start then return end
    if task.global_finish and ts >= task.global_finish then return end

    if not duration then
        if type( task.normal_duration ) == "function" then
            duration = task.normal_duration( )
        elseif task.normal_duration then
            duration = task.normal_duration
        else
            return
        end
    end

    tasks[ id ] = { }
    tasks[ id ].timestamp_start = getRealTimestamp()
    tasks[ id ].timestamp_end   = tasks[ id ].timestamp_start + duration

    player:SetPermanentData( "retention_tasks", tasks )

    triggerEvent( "onRetentionTaskStart", player, id, task.name, tasks[ id ], true )
end
addEvent( "StartRetentionTask", true )
addEventHandler( "StartRetentionTask", root, StartRetentionTask )

function ClearRetentionTask( player, id )
    local tasks = player:GetPermanentData( "retention_tasks" ) or { }
    if not tasks[ id ] then return end

    tasks[ id ] = nil
    player:SetPermanentData( "retention_tasks", tasks )

    if RETENTION_TASKS_TIMERS[ player ] then
        if isTimer( RETENTION_TASKS_TIMERS[ player ][ id ] ) then killTimer( RETENTION_TASKS_TIMERS[ player ][ id ] ) end
        RETENTION_TASKS_TIMERS[ player ][ id ] = nil
    end
end

function StopRetentionTask( player, id )
    local tasks = player:GetPermanentData( "retention_tasks" ) or { }
    ClearRetentionTask( player, id )

    local task = TASKS_CONFIG[ id ]
    if not task then return end

    -- Любой и повторный запуск таска после входа
    if task and task.fn_stop and task.fn_stop.server then
        task.fn_stop.server( task, player, tasks[ id ] )
    end
    triggerClientEvent( player, "onRetentionTaskStopClientside", resourceRoot, id, tasks[ id ] )
end
addEvent( "StopRetentionTask", true )
addEventHandler( "StopRetentionTask", root, StopRetentionTask )

function CompleteRetentionTask( player, id )
    local task = TASKS_CONFIG[ id ]
    if not task then return end

    local data = player:GetPermanentData( "retention_tasks" )[ id ]
    if not data then
        ClearRetentionTask( player, id )
        return
    end

    StopRetentionTask( player, id )

    if task and task.fn_complete and task.fn_complete.server then
        task.fn_complete.server( task, player, data )
    end

    triggerClientEvent( player, "onRetentionTaskCompleteClientside", resourceRoot, id, data )

    local retention_tasks_today = player:GetPermanentData( "retention_tasks_today" ) or 0
    player:SetPermanentData( "retention_tasks_today", retention_tasks_today + 1 )

    if task.name and task.reward then
        triggerEvent( "onRetentionTaskComplete", player, id, task.name, task.reward, task.currency, getRealTimestamp() - data.timestamp_start )
    end
end
addEvent( "onRetentionTaskComplete", true )

function onRetentionTaskStart_handler( id, name, data, is_first_time )
    local task = TASKS_CONFIG[ id ]

    triggerClientEvent( source, "onRetentionTaskStartClientside", resourceRoot, id, data, is_first_time )

    -- Первый запуск таска
    if is_first_time and task and task.fn_pre_first_start and task.fn_pre_first_start.server then
        task.fn_pre_first_start.server( task, source, data )
    end

    -- Любой и повторный запуск таска после входа
    if task and task.fn_start and task.fn_start.server then
        task.fn_start.server( task, source, data )
    end

    RETENTION_TASKS_TIMERS[ source ] = RETENTION_TASKS_TIMERS[ source ] or { }
    RETENTION_TASKS_TIMERS[ source ][ id ] = setTimer( StopRetentionTask, math.max( 50, ( data.timestamp_end - getRealTimestamp() ) * 1000 ), 1, source, id )
end
addEvent( "onRetentionTaskStart", true )
addEventHandler( "onRetentionTaskStart", root, onRetentionTaskStart_handler )

function ShowRetentionInterfaceRequest_handler( current_id )
    local tasks = source:GetPermanentData( "retention_tasks" ) or { }
    if source:HasFinishedTutorial( ) then
        triggerClientEvent( source, "ShowRetentionInterface", resourceRoot, tasks, current_id )
    end
end
addEvent( "ShowRetentionInterfaceRequest", true )
addEventHandler( "ShowRetentionInterfaceRequest", root, ShowRetentionInterfaceRequest_handler )

function onPlayerPreLogout_handler( )
    local player = source
    
    local tasks = player:GetPermanentData( "retention_tasks" ) or { }
    for id, data in pairs( tasks ) do
        if id then
            local task = TASKS_CONFIG[ id ]
            if task and task.fn_stop and task.fn_stop.server then
                task.fn_stop.server( task, player, data )
            end
        end
    end

    if RETENTION_TASKS_TIMERS[ player ] then
        DestroyTableElements( RETENTION_TASKS_TIMERS[ player ] )
        RETENTION_TASKS_TIMERS[ player ] = nil
    end
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )
addEventHandler( "onPlayerQuit", root, onPlayerPreLogout_handler )

function ResetTodayTasks( )
    for i, v in pairs( GetPlayersInGame( ) ) do
        v:SetPermanentData( "retention_tasks_today", nil )
    end
    DB:exec( "UPDATE nrp_players SET retention_tasks_today=NULL" )
end

ExecAtTime( "00:00", function( )
    ResetTodayTasks( )
    TODAY_TASKS_TIMER = setTimer( ResetTodayTasks, 24 * 60 * 60 * 1000, 0 )
end )