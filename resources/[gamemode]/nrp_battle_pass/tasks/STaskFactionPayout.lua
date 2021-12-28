local task_cid = BP_TASK_FACTION_PAYOUT

local self
self = {
    onPlayerFactionPayout = function( )
        local player = source
        
        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerFactionPayout" )
addEventHandler( "onPlayerFactionPayout", root, self.onPlayerFactionPayout )