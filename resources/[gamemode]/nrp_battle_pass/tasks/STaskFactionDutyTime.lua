local task_cid = BP_TASK_FACTION_DUTY_TIME

local self
self = {
    pulse_interval = 60,
    
    timers = { },

    StartTimeTracking = function( player )
        if self.timers[ player ] then return end
        self.timers[ player ] = setTimer( self.Pulse, self.pulse_interval * 1000, 0, player, self.pulse_interval )
    end,
    
    StopTimeTracking = function( player )
        self.ClearPlayerData( player )
    end,

    Pulse = function( player )
        if not isElement( player ) or not player:IsOnFactionDuty( ) then
            self.ClearPlayerData( player )
            return
        end

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        local is_task_completed = player:AddTaskProgress( task_id, self.pulse_interval / 60 )
        if is_task_completed then
            self.ClearPlayerData( player )
        end
    end,

    ClearPlayerData = function( player )
        if self.timers[ player ] then
            killTimer( self.timers[ player ] )
            self.timers[ player ] = nil
        end
    end,

    OnPlayerFactionDutyStart_handler = function( )
        local player = source
        self.StartTimeTracking( player )
    end,
    
    OnPlayerFactionDutyEnd_handler = function( )
        local player = source
        self.StopTimeTracking( player )
    end,

    ------------------------------------------------

    Start = function( player )
        if not player:IsOnFactionDuty( ) then return end
        local task_id = player:GetActiveTaskID( task_cid )
        if task_id then
            self.StartTimeTracking( player )
        end
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "OnPlayerFactionDutyStart" )
addEventHandler( "OnPlayerFactionDutyStart", root, self.OnPlayerFactionDutyStart_handler )

addEvent( "OnPlayerFactionDutyEnd" )
addEventHandler( "OnPlayerFactionDutyEnd", root, self.OnPlayerFactionDutyEnd_handler )