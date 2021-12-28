local task_cid = BP_TASK_FACTION_EXP

local self
self = {
    onFactionEXPChange_handler = function( value, old_value )
        local player = source
        local delta = value - old_value
        if delta <= 0 then return end
        
        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, delta )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onFactionEXPChange", false )
addEventHandler( "onFactionEXPChange", root, self.onFactionEXPChange_handler )