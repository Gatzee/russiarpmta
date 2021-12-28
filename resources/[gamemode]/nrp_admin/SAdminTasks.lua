ADMIN_TASKS = {
	-- [ player ] = {
    --     [ 1 ] = { completed = true, reset_date = timestamp },
    --     [ 2 ] = { completed = false, reset_date = timestamp },
    -- },
}

ADMIN_TASKS_TIMERS = { }

function CompleteAdminTask( player, task_id, ignore_sync )
    if not player:IsAdmin( ) then return end

    local task = ADMIN_TASKS[ player ][ task_id ]
    task.completed = true
    player:AddRewardPayout( task.reward, task_id )
    if not ignore_sync then
        player:SetAdminData( "tasks", ADMIN_TASKS[ player ] )
        triggerClientEvent( player, "AP:TaskCompleted", player, task_id )
    end

    WriteLog( "admin/tasks", "%s выполнил TASK_ID:%s, REWARD:%s", player, task_id, task.reward )

    ADMIN_TASKS_TIMERS[ player ][ task_id ] = nil
end

function onPlayerCompleteLogin_tasksHandler( player )
    local player = isElement( player ) and player or source
    if not player:IsAdmin( ) then return end
    
    local current_timestamp = os.time( )
    ADMIN_TASKS_TIMERS[ player ] = { }
	
    local tasks = player:GetAdminData( "tasks" ) or { }
    ADMIN_TASKS[ player ] = tasks
    if next( tasks ) then
        local worked_time = ADMIN_WORKED_TIME[ player ]
        for task_id, task in pairs( tasks ) do
            setmetatable( task, { __index = TASKS_INFO[ task_id ] } )

            if task.reset_date and NEXT_RESET_DATES[ task.reset_period ] > task.reset_date then
                task.completed = false
                task.reset_date = NEXT_RESET_DATES[ task.reset_period ]
            end

            if task.type == ADMIN_TASK_WORKED_TIME and not task.completed then
                local progress = worked_time[ task.need_period ]
                local remaining_time = task.need_value - progress.time
                if remaining_time > 0 then
                    local complete_date = current_timestamp + remaining_time
                    -- не ставим таймер, если задача или её прогресс будут сброшены до её завершения
                    if task.reset_date > complete_date or progress.reset_date > complete_date then
                        -- если дневной лимит будет исчерпан раньше (или он уже исчерпан)
                        local time_left_to_daily_limit = MAX_WORKED_TIME_IN_DAY - worked_time.day.time
                        if time_left_to_daily_limit < remaining_time then
                            -- и счётчик будет сброшен позже, то учитываем эту разницу
                            local time_left_to_daily_reset = worked_time.day.reset_date - current_timestamp
                            if time_left_to_daily_reset > time_left_to_daily_limit then
                                remaining_time = remaining_time + time_left_to_daily_reset - time_left_to_daily_limit
                            end
                        end

                        ADMIN_TASKS_TIMERS[ player ][ task_id ] = setTimer(
                            CompleteAdminTask, remaining_time * 1000, 1, player, task_id 
                        )
                    end
                else
                    CompleteAdminTask( player, task_id, true )
                end
            end
        end

    else
        for task_id, task_info in pairs( TASKS_INFO ) do
            tasks[ task_id ] = { 
                completed = false, 
                reset_date = NEXT_RESET_DATES[ task_info.reset_period ], 
            }
            setmetatable( tasks[ task_id ], { __index = TASKS_INFO[ task_id ] } )
        end
    end

    player:SetAdminData( "tasks", tasks )
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_tasksHandler )

function onResourceStart_tasksHandler()
    for i, v in pairs( GetPlayersInGame( ) ) do
        onPlayerCompleteLogin_tasksHandler( v )
    end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_tasksHandler )

function onAdminAcceptReport_tasksHandler()
    local reports = ADMIN_REPORTS_ACCEPTED[ source ]
    if not reports then return end

    local tasks = ADMIN_TASKS[ source ]
    for task_id, task in pairs( tasks ) do
        if task.type == ADMIN_TASK_REPORTS and not task.completed then
            local current_progress = reports[ task.need_period ].count + reports.session
            if current_progress >= task.need_value then
                CompleteAdminTask( source, task_id )
            end
        end
    end
end
addEvent( "onAdminAcceptReport" )
addEventHandler( "onAdminAcceptReport", root, onAdminAcceptReport_tasksHandler )

function ResetOnlineAdminsTasks( reset_period, new_reset_date )
    for player, tasks in pairs( ADMIN_TASKS ) do
        local tasks_timers = ADMIN_TASKS_TIMERS[ player ]
        for task_id, task in pairs( tasks ) do
            if task.reset_period == reset_period then
                task.reset_date = new_reset_date
                task.completed = false

                if task.type == ADMIN_TASK_WORKED_TIME then
                    if isTimer( tasks_timers[ task_id ] ) then
                        killTimer( tasks_timers[ task_id ] )
                    end
                    tasks_timers[ task_id ] = setTimer(
                        CompleteAdminTask, task.need_value * 1000, 1, player, task_id 
                    )
                end
            end
        end
        player:SetAdminData( "tasks", tasks )
    end
end

function onPlayerPreLogout_tasksHandler( player )
    local player = isElement( player ) and player or source

    if ADMIN_TASKS_TIMERS[ player ] then
        for i, timer in pairs( ADMIN_TASKS_TIMERS[ player ] ) do
            if isTimer( timer ) then killTimer( timer ) end
        end
        ADMIN_TASKS_TIMERS[ player ] = nil
	    ADMIN_TASKS[ player ] = nil
    end
end
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_tasksHandler )

addEvent( "onPlayerAccessLevelChange" )
addEventHandler( "onPlayerAccessLevelChange", root, function( old_access_level, new_access_level )
    if old_access_level == 0 and new_access_level > 0 then
        onPlayerPreLogout_tasksHandler( source )
        onPlayerCompleteLogin_tasksHandler( source )
    elseif old_access_level > 0 and new_access_level == 0 then
        onPlayerPreLogout_tasksHandler( source )
    end
end )

function RequestWorkData_tasksHandler()
    UpdateWorkedTimeData( client )

    local payout_data = PAYOUTS[ client:GetClientID( ) ]
    triggerClientEvent( client, "AP:ReceiveWorkData", resourceRoot,
        ADMIN_TASKS[ client ],
        ADMIN_WORKED_TIME[ client ],
        ADMIN_REPORTS_ACCEPTED[ client ],
        payout_data and payout_data.server_id
    )
end
addEvent( "AP:RequestWorkData", true )
addEventHandler( "AP:RequestWorkData", root, RequestWorkData_tasksHandler )

local SYNC_CHANGED_DATA_TIMER
function SyncOnlineAdminsWorkData( )
    if isTimer( SYNC_CHANGED_DATA_TIMER ) then return end 
    SYNC_CHANGED_DATA_TIMER = setTimer( function( )
        for player, tasks in pairs( ADMIN_TASKS ) do
            triggerClientEvent( player, "AP:ReceiveWorkData", resourceRoot,
                tasks,
                ADMIN_WORKED_TIME[ player ],
                ADMIN_REPORTS_ACCEPTED[ player ]
            )
        end
    end, 1000, 1 )
end