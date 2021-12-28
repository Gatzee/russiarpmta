local task_cid = BP_TASK_NYE_ANY_FINISH

local self
self = {
    onPlayerEventAnyFinish = function( )
        local player = source

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        local is_task_completed = player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerEventFinish" )
addEventHandler( "onPlayerEventFinish", root, self.onPlayerEventAnyFinish )