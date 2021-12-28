local task_cid = BP_TASK_PARACHUTE_JUMPING

local self
self = {
    requestAddParachute_handler = function( price )
        local player = client

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "requestAddParachute", true )
addEventHandler( "requestAddParachute", root, self.requestAddParachute_handler )