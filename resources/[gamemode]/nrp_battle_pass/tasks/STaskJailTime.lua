local task_cid = BP_TASK_JAIL_TIME

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
        if not isElement( player ) or not player:getData( "jailed" ) then
            self.ClearPlayerData( player )
            return
        end

        self.AddProgress( player )
    end,

    AddProgress = function( player )
        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        local is_task_completed = player:AddTaskProgress( task_id, 1 )
        if is_task_completed then
            self.ClearPlayerData( player )
        end
    end,

    ClearPlayerData = function( player )
        if self.timers[ player ] then
            local remaining_time = getTimerDetails( self.timers[ player ] )
            killTimer( self.timers[ player ] )
            self.timers[ player ] = nil

            -- Фикс бага, когда не засчитывало последную минуту, 
            -- т.к. OnPlayerReleasedFromJail мог вызваться на 10 с раньше 
            -- из-за интервала проверки срока в 10 с
            if remaining_time < 11000 then
                self.AddProgress( player )
            end
        end
    end,

    OnPlayerJailed_handler = function( player )
        local player = source
        self.StartTimeTracking( player )
    end,

    OnPlayerReleasedFromJail = function( )
        local player = source
        self.StopTimeTracking( player )
    end,

    ------------------------------------------------

    Start = function( player )
        if player:getData( "jailed" ) then
            self.StartTimeTracking( player )
        end
    end,
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "OnPlayerJailed" )
addEventHandler( "OnPlayerJailed", root, self.OnPlayerJailed_handler )

addEvent( "OnPlayerPrisoned" )
addEventHandler( "OnPlayerPrisoned", root, self.OnPlayerJailed_handler )

addEvent( "OnPlayerReleasedFromJail" )
addEventHandler( "OnPlayerReleasedFromJail", root, self.OnPlayerReleasedFromJail )