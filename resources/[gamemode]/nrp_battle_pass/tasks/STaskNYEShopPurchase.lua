local task_cid = BP_TASK_NYE_SHOP_PURCHASE

local self
self = {
    event_item_purchase = function( )
        local player = source

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "SDEV2DEV_event_item_purchase" )
addEventHandler( "SDEV2DEV_event_item_purchase", root, self.event_item_purchase )