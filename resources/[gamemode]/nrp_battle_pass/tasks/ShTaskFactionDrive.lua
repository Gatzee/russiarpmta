local task_cid = BP_TASK_FACTION_DRIVE

local self
self = {
    server = {
        Start = function( player )
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
            
            triggerClientEvent( player, "BP:onClientTaskFactionDriveStart", resourceRoot )
        end,

        onPlayerReadyToPlay_handler = function( )
            local player = source
            self.Start( player )
        end,

        onTaskFactionDriveProgress_handler = function( distance )
            local player = client
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
            
            local is_task_completed = player:AddTaskProgress( task_id, distance / 1000 )
            if is_task_completed then
                triggerClientEvent( player, "BP:onClientTaskFactionDriveStop", resourceRoot )
            end
        end,
    },

    client = {
        UpdateDistance = function( )
            if not isElement( localPlayer.vehicle ) then
                self.StopDistanceTracking( )
                return
            end
            
            if self.last_position then
                local added_distance = ( localPlayer.vehicle.position - self.last_position ).length
                if added_distance >= 50 then
                    triggerServerEvent( "BP:onTaskFactionDriveProgress", resourceRoot, added_distance )
                    self.last_position = localPlayer.vehicle.position
                end
            else
                self.last_position = localPlayer.vehicle.position
            end
        end,

        StartDistanceTracking = function( )
            self.StopDistanceTracking( )

            local vehicle = localPlayer.vehicle

            if ( localPlayer.vehicleSeat or 1 ) > 0 then return end
            if IsSpecialVehicle( vehicle.model ) then return end
            if not vehicle:IsInFaction( ) then return end
            if not vehicle:IsOwnedBy( localPlayer ) then return end

            self.UpdateDistance( )
            self.timer = setTimer( self.UpdateDistance, 5000, 0 )

            return true
        end,

        StopDistanceTracking = function( )
            if isTimer( self.timer ) then killTimer( self.timer ) end
            self.timer = nil
            self.last_position = nil
        end,

        OnStart = function( )
            if not ( localPlayer.vehicle and self.StartDistanceTracking( ) ) then
                removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, self.StartDistanceTracking )
                addEventHandler( "onClientPlayerVehicleEnter", localPlayer, self.StartDistanceTracking )
            end
        end,

        OnStop = function( )
            self.StopDistanceTracking( )
            removeEventHandler( "onClientPlayerVehicleEnter", localPlayer, self.StartDistanceTracking )
        end,
    },
}
self = localPlayer and self.client or self.server
BP_TASKS_CONTROLLERS[ task_cid ] = self

if not localPlayer then
    addEvent( "onPlayerReadyToPlay" )
    addEventHandler( "onPlayerReadyToPlay", root, self.onPlayerReadyToPlay_handler )

    addEvent( "onPlayerFactionChange" )
    addEventHandler( "onPlayerFactionChange", root, self.onPlayerReadyToPlay_handler )

    addEvent( "BP:onTaskFactionDriveProgress", true )
    addEventHandler( "BP:onTaskFactionDriveProgress", resourceRoot, self.onTaskFactionDriveProgress_handler )
else
    addEvent( "BP:onClientTaskFactionDriveStart", true )
    addEventHandler( "BP:onClientTaskFactionDriveStart", resourceRoot, self.OnStart )

    addEvent( "BP:onClientTaskFactionDriveStop", true )
    addEventHandler( "BP:onClientTaskFactionDriveStop", resourceRoot, self.OnStop )
end