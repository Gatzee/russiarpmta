local task_cid = BP_TASK_CASINO_LOTTERY

local self
self = {
    onPlayeLotteryPurchase = function( lottery_id, lottery_variant, count )
        local player = source

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, count or 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayeLotteryPurchase" )
addEventHandler( "onPlayeLotteryPurchase", root, self.onPlayeLotteryPurchase )