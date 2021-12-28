local task_cid = BP_TASK_JAIL_JOB

local self
self = {
    onPlayerCompleteJailQuest_handler = function( )
        local player = client

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerCompleteJailQuest", true )
addEventHandler( "onPlayerCompleteJailQuest", root, self.onPlayerCompleteJailQuest_handler )