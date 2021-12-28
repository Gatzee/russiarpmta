local task_cid = BP_TASK_PHONE_CALL_TIME

local self
self = {
    AddProgress = function( player, progress )
        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        player:AddTaskProgress( task_id, progress )
    end,

    onPlayerPhoneCall_handler = function( price, time_call, __, __, abonent )
        local progress = time_call / 60
        self.AddProgress( source, progress )
        if isElement( abonent ) then
            self.AddProgress( abonent, progress )
        end
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerPhoneCall" )
addEventHandler( "onPlayerPhoneCall", root, self.onPlayerPhoneCall_handler )