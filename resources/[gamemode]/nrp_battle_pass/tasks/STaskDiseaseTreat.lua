local task_cid = BP_TASK_DISEASE_TREAT

local self
self = {
    onPlayerTreatComplete_handler = function( player )
        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        local is_task_completed = player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerTreatComplete", true )
addEventHandler( "onPlayerTreatComplete", root, self.onPlayerTreatComplete_handler )