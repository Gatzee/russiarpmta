local task_cid = BP_TASK_DAILY_QUEST

local self
self = {
    onDailyQuestCompleted_handler = function( )
        local player = source
        
        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        local is_task_completed = player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onDailyQuestCompleted" )
addEventHandler( "onDailyQuestCompleted", root, self.onDailyQuestCompleted_handler )