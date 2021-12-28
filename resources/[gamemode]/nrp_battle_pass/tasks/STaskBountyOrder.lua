local task_cid_by_order_way = {
    _default  = BP_TASK_BOUNTY_ORDER,

    clans  = BP_TASK_BOUNTY_ORDER_CLAN,
    police = BP_TASK_BOUNTY_ORDER_PPS,
}

local self
self = {
    onPlayerOrderCivilianForBounty_handler = function( order_way )
        local player = source
        local task_cid = task_cid_by_order_way[ order_way ]
        if not task_cid then return end
        
        local task_id = player:GetActiveTaskID( task_cid ) or player:GetActiveTaskID( task_cid_by_order_way._default )
        if not task_id then return end
        
        local is_task_completed = player:AddTaskProgress( task_id, 1 )
    end,
}
for i, task_cid in pairs( task_cid_by_order_way ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "onPlayerOrderCivilianForBounty" )
addEventHandler( "onPlayerOrderCivilianForBounty", root, self.onPlayerOrderCivilianForBounty_handler )