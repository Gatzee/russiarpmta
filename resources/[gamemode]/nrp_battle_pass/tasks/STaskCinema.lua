local task_cid = BP_TASK_CINEMA_PLAY_TIME

local self
self = {
    pulse_interval = 60,
    
    timers = { },

    onCinemaRoomEnter_handler = function( room )
        local player = client
        if self.timers[ player ] then return end
        self.timers[ player ] = setTimer( self.Pulse, self.pulse_interval * 1000, 0, player, room )
    end,
    
    onCinemaRoomLeave_handler = function( )
        local player = client
        self.ClearPlayerData( player )
    end,

    Pulse = function( player, room )
        if not isElement( player ) then
            self.ClearPlayerData( player )
            return
        end

        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end

        if not exports.nrp_cinema:IsRoomVideoRunning( room ) then return end
        
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
}
BP_TASKS_CONTROLLERS[ task_cid ] = self

addEvent( "onCinemaRoomEnter", true )
addEventHandler( "onCinemaRoomEnter", root, self.onCinemaRoomEnter_handler )

addEvent( "onCinemaRoomLeave", true )
addEventHandler( "onCinemaRoomLeave", root, self.onCinemaRoomLeave_handler )