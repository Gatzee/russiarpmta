local task_cid = BP_TASK_CALORIES_WASTE

local self
self = {
    onCaloriesUpdate_handler = function( delta_value )
        local player = client

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, delta_value )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onCaloriesUpdate", true )
addEventHandler( "onCaloriesUpdate", root, self.onCaloriesUpdate_handler )