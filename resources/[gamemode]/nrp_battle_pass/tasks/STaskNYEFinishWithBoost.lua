local task_cids = {
    [ "new_year_gift_collection"  ] = BP_TASK_NYE_BOOST_FINISH_GIFT_COLLECTION,
    [ "new_year_dangerous_sprint" ] = BP_TASK_NYE_BOOST_FINISH_DANGEROUS_SPRINT,
    [ "new_year_king_mountain"    ] = BP_TASK_NYE_BOOST_FINISH_KING_MOUNTAIN,
}

local self
self = {
    onPlayerEventAnyFinish = function( event_id, number, is_finished_in_time, with_boost )
        local player = source

        if not with_boost then return end

        local task_cid = task_cids[ event_id ]
        if not task_cid then return end

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        local is_task_completed = player:AddTaskProgress( task_id, 1 )
    end,
}
for i, task_cid in pairs( task_cids ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "onPlayerEventFinish" )
addEventHandler( "onPlayerEventFinish", root, self.onPlayerEventAnyFinish )