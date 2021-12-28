local task_cid = BP_TASK_NYE_COUNT_GIFT_COLLECTION

local self
self = {
    onPlayerPickupGiftBox = function( )
        local player = source

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "BP:NYE:onPlayerPickupGiftBox" )
addEventHandler( "BP:NYE:onPlayerPickupGiftBox", root, self.onPlayerPickupGiftBox )