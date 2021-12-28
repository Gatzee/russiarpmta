local task_cid = BP_TASK_BAR_ALCOHOL

local self
self = {
    onPlayerPurchaseAlcohol = function( )
        local player = source

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerPurchaseAlcohol" )
addEventHandler( "onPlayerPurchaseAlcohol", root, self.onPlayerPurchaseAlcohol )