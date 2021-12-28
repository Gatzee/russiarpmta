local task_cids = {
    [ "new_year_gift_collection" ] = BP_TASK_NYE_MAX_DEATH_COUNT_GIFT_COLLECTION,
    [ "new_year_king_mountain" ] = BP_TASK_NYE_MAX_DEATH_COUNT_KING_MOUNTAIN,
}

local self
self = {
    onPlayerWasted = function( event_id )
        local player = source

        local task_cid = task_cids[ event_id ]
        if not task_cid then return end

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end

        local deaths = player:GetTaskData( task_id, "deaths" ) or 0

        local event_start_timestamp = player:getData( "event_start_timestamp" )
        if event_start_timestamp ~= ( player:GetTaskData( task_id, "last_start_ts" ) or 0 ) then
            player:SetTaskData( task_id, "last_start_ts", event_start_timestamp )
            deaths = 0
        end
        
        deaths = deaths + 1
        player:SetTaskData( task_id, "deaths", deaths )
    end,

    onPlayerEventFinish = function( event_id )
        local player = source

        local task_cid = task_cids[ event_id ]
        if not task_cid then return end

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end

        local deaths = player:GetTaskData( task_id, "deaths" ) or 0
        local max_death_count = GetTaskInfoByCID( task_cid, task_id, "max_death_count" )
        
        local event_start_timestamp = player:getData( "event_start_timestamp" )
        if event_start_timestamp ~= ( player:GetTaskData( task_id, "last_start_ts" ) or 0 ) then
            deaths = 0
        end
        
        if deaths <= max_death_count then
            player:AddTaskProgress( task_id, 1 )
        end
    end,
}
for i, task_cid in pairs( task_cids ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "BP:NYE:onPlayerWasted", true )
addEventHandler( "BP:NYE:onPlayerWasted", root, self.onPlayerWasted )

addEvent( "onPlayerEventFinish" )
addEventHandler( "onPlayerEventFinish", root, self.onPlayerEventFinish )