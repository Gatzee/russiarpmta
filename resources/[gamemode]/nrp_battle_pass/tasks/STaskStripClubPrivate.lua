local task_cid = BP_TASK_STRIP_CLUB_PRIVATE

local self
self = {
    onPlayerPurchaseStripDance_handler = function( is_podium, is_private )
        local player = source

        if not is_private then return end

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, 1 )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerPurchaseStripDance" )
addEventHandler( "onPlayerPurchaseStripDance", root, self.onPlayerPurchaseStripDance_handler )