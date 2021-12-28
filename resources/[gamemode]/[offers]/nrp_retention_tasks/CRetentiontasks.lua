Extend( "CPlayer" )
Extend( "CVehicle" )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "Globals" )

function GetRetentionTaskValue( id, key )
    return TASKS_CONFIG[ id ] and TASKS_CONFIG[ id ][ key ]
end

-- ЗАПУСК ЗАДАЧИ
function onRetentionTaskStartClientside_handler( id, data, is_first_time )
    local task = TASKS_CONFIG[ id ]

    -- Первый запуск таска
    if is_first_time and task and task.fn_pre_first_start and task.fn_pre_first_start.client then
        task.fn_pre_first_start.client( tasks, data )
    end

    -- Любой и повторный запуск таска после входа
    if task and task.fn_start and task.fn_start.client then
        task.fn_start.client( task, data )
    end
end
addEvent( "onRetentionTaskStartClientside", true )
addEventHandler( "onRetentionTaskStartClientside", root, onRetentionTaskStartClientside_handler )

function onRetentionTaskStartArrayClientside_handler( array )
    for id, data in pairs( array ) do
        onRetentionTaskStartClientside_handler( id, data, false )
    end
end
addEvent( "onRetentionTaskStartArrayClientside", true )
addEventHandler( "onRetentionTaskStartArrayClientside", root, onRetentionTaskStartArrayClientside_handler )

-- СТОП ЗАДАЧИ
function onRetentionTaskStopClientside_handler( id, data )
    local task = TASKS_CONFIG[ id ]

    if task and task.fn_stop and task.fn_stop.client then
        task.fn_stop.client( task, data )
    end
end
addEvent( "onRetentionTaskStopClientside", true )
addEventHandler( "onRetentionTaskStopClientside", root, onRetentionTaskStopClientside_handler )

function onRetentionTaskCompleteClientside_handler( id, data )
    local task = TASKS_CONFIG[ id ]

    if task and task.fn_complete and task.fn_complete.client then
        task.fn_complete.client( task, data )
    end
end
addEvent( "onRetentionTaskCompleteClientside", true )
addEventHandler( "onRetentionTaskCompleteClientside", root, onRetentionTaskCompleteClientside_handler )