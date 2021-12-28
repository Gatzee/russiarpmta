local task_cid_by_hobby = {
    [ HOBBY_FISHING ] = BP_TASK_HOBBY_FISHING_SELL,
    [ HOBBY_HUNTING ] = BP_TASK_HOBBY_HUNTING_SELL,
    -- [ HOBBY_DIGGING ] = BP_TASK_HOBBY_DIGGING_SELL,
}

local self
self = {
    OnPlayerSellItems_handler = function( hobby, weight )
        local player = source
        local task_cid = task_cid_by_hobby[ hobby ]
        if not task_cid then return end

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        local need_weight = GetTaskInfoByCID( task_cid, task_id, "need_weight" )
        if weight < need_weight then return end

        player:AddTaskProgress( task_id, 1 )
    end,
}
for i, task_cid in pairs( task_cid_by_hobby ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "HB:OnPlayerSellItems" )
addEventHandler( "HB:OnPlayerSellItems", root, self.OnPlayerSellItems_handler )