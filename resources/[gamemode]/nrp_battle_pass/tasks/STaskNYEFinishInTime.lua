local task_cid = BP_TASK_NYE_TIME_FINISH_DANGEROUS_SPRINT

local self
self = {
    onPlayerEventAnyFinish = function( event_id, number, is_finished_in_time )
        local player = source

        if event_id ~= "new_year_dangerous_sprint" or not is_finished_in_time then return end

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        local is_task_completed = player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerEventFinish" )
addEventHandler( "onPlayerEventFinish", root, self.onPlayerEventAnyFinish )