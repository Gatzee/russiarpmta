local task_cid_by_inv_item_id = {
    [ IN_BOTTLE_DIRTY ] = BP_TASK_CLAN_RAW_COLLECTING,
    [ IN_HASH_RAW ] = BP_TASK_CLAN_RAW_COLLECTING,

    [ IN_ALCO ] = BP_TASK_CLAN_FACTORY_PRODUCT,
    [ IN_HASH ] = BP_TASK_CLAN_FACTORY_PRODUCT,
}

local self
self = {
    onPlayerCollectClanFactoryItem = function( inv_item_id, count )
        local player = source

        local task_cid = task_cid_by_inv_item_id[ inv_item_id ]
        if not task_cid then return end

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end

        player:AddTaskProgress( task_id, count or 1 )
    end,
}
for i, task_cid in pairs( task_cid_by_inv_item_id ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "onPlayerCollectClanFactoryItem" )
addEventHandler( "onPlayerCollectClanFactoryItem", root, self.onPlayerCollectClanFactoryItem )