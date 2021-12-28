local task_cids = {
    [ "new_year_dangerous_sprint" ] = BP_TASK_NYE_CAR_PUSH_DANGEROUS_SPRINT,
    [ "new_year_king_mountain" ] = BP_TASK_NYE_CAR_PUSH_KING_MOUNTAIN,
}

local self
self = {
    onPlayerPushOffOtherCar = function( event_id )
        local player = source

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

addEvent( "BP:NYE:onPlayerPushOffOtherCar", true )
addEventHandler( "BP:NYE:onPlayerPushOffOtherCar", root, self.onPlayerPushOffOtherCar )