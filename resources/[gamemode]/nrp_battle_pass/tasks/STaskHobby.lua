local task_cid_by_hobby = {
    -- [ HOBBY_FISHING ] = BP_TASK_HOBBY_FISHING,
    -- [ HOBBY_HUNTING ] = BP_TASK_HOBBY_HUNTING,
    [ HOBBY_DIGGING ] = BP_TASK_HOBBY_DIGGING,
}

local self
self = {
    OnPlayerReceiveItem_handler = function( hobby )
        local player = source
        local task_cid = task_cid_by_hobby[ hobby ]
        if not task_cid then return end

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end

        player:AddTaskProgress( task_id, 1 )
    end,
}
for i, task_cid in pairs( task_cid_by_hobby ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "HB:OnPlayerReceiveItem" )
addEventHandler( "HB:OnPlayerReceiveItem", root, self.OnPlayerReceiveItem_handler )