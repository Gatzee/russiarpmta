local task_cid = BP_TASK_COOKING

local self
self = {
    onPlayerCookDish_handler = function( dish_id )
        local player = source
        
        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end

        local cooked_counts = player:GetTaskData( task_id, "cooked_counts" ) or { }
        cooked_counts[ dish_id ] = ( cooked_counts[ dish_id ] or 0 ) + 1
        player:SetTaskData( task_id, "cooked_counts", cooked_counts )
        
        if cooked_counts[ dish_id ] > player:GetTaskProgress( task_id ) then
            player:AddTaskProgress( task_id, 1 )
        end
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerCookDish" )
addEventHandler( "onPlayerCookDish", root, self.onPlayerCookDish_handler )