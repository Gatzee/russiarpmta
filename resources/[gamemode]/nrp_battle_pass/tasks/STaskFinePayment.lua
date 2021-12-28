local task_cid = BP_TASK_FINE_PAYMENT

local self
self = {
    OnPlayerFinePaid = function( fine_id )
        local player = source

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        local need_fine_id = GetTaskInfoByCID( task_cid, task_id, "fine_id" )
        if need_fine_id ~= fine_id then return end
        
        player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "OnPlayerFinePaid" )
addEventHandler( "OnPlayerFinePaid", root, self.OnPlayerFinePaid )