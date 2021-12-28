local task_cid = BP_TASK_NYE_TOTAL_KILLS_GIFT_COLLECTION

local self
self = {
    onPlayerKill = function( )
        local player = source

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end

        player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "BP:NYE:onPlayerKill", true )
addEventHandler( "BP:NYE:onPlayerKill", root, self.onPlayerKill )