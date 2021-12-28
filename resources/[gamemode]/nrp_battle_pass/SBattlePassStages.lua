BP_CURRENT_SEASON_STAGE_ID = #BP_STAGES

for stage_id, stage in ipairs( BP_STAGES ) do
    if stage.start_ts > getRealTimestamp( ) then
        BP_CURRENT_SEASON_STAGE_ID = stage_id - 1
        break
    end
end

function SetCurrentStage( stage_id )
    BP_CURRENT_SEASON_STAGE_ID = stage_id
    SetNextStageTimer( )

    local stage_tasks = BP_STAGES[ BP_CURRENT_SEASON_STAGE_ID ].tasks
    for i, player in pairs( GetPlayersInGame( ) ) do
        for i, task in pairs( stage_tasks ) do
            local task_controller = BP_TASKS_CONTROLLERS[ task.cid ]
            if task_controller.Start then
                task_controller.Start( player )
            end
        end
    end
end

function SetNextStageTimer( )
    local next_stage_id = BP_CURRENT_SEASON_STAGE_ID + 1
    local next_stage = BP_STAGES[ next_stage_id ]
    if next_stage then
        if isTimer( NEXT_STAGE_TIMER ) then NEXT_STAGE_TIMER:destroy( ) end
        local time_left = math.max( 0, next_stage.start_ts - getRealTimestamp( ) )
        NEXT_STAGE_TIMER = setTimer( SetCurrentStage, time_left * 1000, 1, next_stage_id )
    end
end

addEventHandler( "onResourceStart", resourceRoot, function( )
    SetNextStageTimer( )
end )