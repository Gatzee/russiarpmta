local task_cid = BP_TASK_RUN

local self
self = {
    server = {
        Start = function( player )
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
            
            triggerClientEvent( player, "BP:onClientTaskRunStart", resourceRoot )
        end,

        onPlayerReadyToPlay_handler = function( )
            local player = source
            self.Start( player )
        end,

        onTaskRunProgress_handler = function( distance )
            local player = client
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
            
            local is_task_completed = player:AddTaskProgress( task_id, distance / 1000 )
            if is_task_completed then
                triggerClientEvent( player, "BP:onClientTaskRunStop", resourceRoot )
            end
        end,
    },

    client = {
        UpdateDistance = function( )
            if localPlayer.vehicle then return end
            if localPlayer:IsInOrAroundWater( ) then return end
            if not isPedOnGround( localPlayer ) then return end

            if self.last_position then
                local added_distance = ( localPlayer.position - self.last_position ).length
                if added_distance >= 5 then
                    if added_distance >= 20 then
                        self.last_position = localPlayer.position
                    else
                        triggerServerEvent( "BP:onTaskRunProgress", resourceRoot, added_distance )
                        self.last_position = localPlayer.position
                    end
                end
            else
                self.last_position = localPlayer.position
            end
        end,

        StartDistanceTracking = function( )
            self.StopDistanceTracking( )
            self.UpdateDistance( )
            self.timer = setTimer( self.UpdateDistance, 2500, 0 )
        end,

        StopDistanceTracking = function( )
            if isTimer( self.timer ) then killTimer( self.timer ) end
            self.timer = nil
            self.last_position = nil
        end,
    },
}
self = localPlayer and self.client or self.server
BP_TASKS_CONTROLLERS[ task_cid ] = self

if not localPlayer then
    addEvent( "onPlayerReadyToPlay", true )
    addEventHandler( "onPlayerReadyToPlay", root, self.onPlayerReadyToPlay_handler )

    addEvent( "BP:onTaskRunProgress", true )
    addEventHandler( "BP:onTaskRunProgress", resourceRoot, self.onTaskRunProgress_handler )
else
    addEvent( "BP:onClientTaskRunStart", true )
    addEventHandler( "BP:onClientTaskRunStart", resourceRoot, self.StartDistanceTracking )

    addEvent( "BP:onClientTaskRunStop", true )
    addEventHandler( "BP:onClientTaskRunStop", resourceRoot, self.StopDistanceTracking )
end