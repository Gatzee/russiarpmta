local task_cid_by_variant = {
    [ 3 ] = BP_TASK_CASINO_LOTTERY_VARIANT_3,
}

local self
self = {
    onPlayeLotteryPurchase = function( lottery_id, lottery_variant, count )
        local task_cid = task_cid_by_variant[ lottery_variant ]
        if not task_cid then return end
        local player = source

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, count or 1 )
    end,
}
for i, task_cid in pairs( task_cid_by_variant ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "onPlayeLotteryPurchase" )
addEventHandler( "onPlayeLotteryPurchase", root, self.onPlayeLotteryPurchase )