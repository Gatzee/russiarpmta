local task_cid = BP_TASK_FACTION_TASK

local registered_factions_tasks_reverse = { }
for i, tasks_ids in pairs( REGISTERED_FACTIONS_TASKS ) do
    for i, task_id in pairs( tasks_ids ) do
        registered_factions_tasks_reverse[ "task_" .. task_id ] = true
    end
end

local self
self = {
    onPlayerQuestComplete_handler = function( quest, _, quests_data )
        local player = source
        if not registered_factions_tasks_reverse[ quest.id ] and not quest.training_id then return end
        
        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerQuestComplete", true )
addEventHandler( "onPlayerQuestComplete", root, self.onPlayerQuestComplete_handler )