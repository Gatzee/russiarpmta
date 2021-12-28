local task_cid = BP_TASK_ARMOR_PURCHASE

local self
self = {
    onPlayerArmorPurchase_handler = function( amount )
        local player = source

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, amount )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerArmorPurchase" )
addEventHandler( "onPlayerArmorPurchase", root, self.onPlayerArmorPurchase_handler )