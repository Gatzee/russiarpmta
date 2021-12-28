local task_cid = BP_TASK_SOCIAL_RATING_DONATE

local self
self = {
    onPlayerSentDonateForSocialRating_handler = function( direction, cost, currency, old_rating, new_rating, delta )
        local player = source

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end

        player:AddTaskProgress( task_id, math.abs( delta ) )
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onPlayerSentDonateForSocialRating" )
addEventHandler( "onPlayerSentDonateForSocialRating", root, self.onPlayerSentDonateForSocialRating_handler )