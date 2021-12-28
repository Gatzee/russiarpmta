local task_cid_by_job_class = {
    [ JOB_CLASS_COURIER ] 		= BP_TASK_JOB_COURIER_TIME,
    [ JOB_CLASS_DRIVER ] 		= BP_TASK_JOB_DRIVER_TIME,
    [ JOB_CLASS_TAXI ] 			= BP_TASK_JOB_TAXI_TIME,
    [ JOB_CLASS_TAXI_PRIVATE ]  = BP_TASK_JOB_TAXI_TIME,
    [ JOB_CLASS_TRUCKER ] 		= BP_TASK_JOB_TRUCKER_TIME,
    [ JOB_CLASS_FARMER ] 		= BP_TASK_JOB_FARMER_TIME,
    [ JOB_CLASS_MECHANIC ] 		= BP_TASK_JOB_MECHANIC_TIME,
    [ JOB_CLASS_PARK_EMPLOYEE ] = BP_TASK_JOB_PARK_EMPLOYEE_TIME,
    [ JOB_CLASS_HCS ] 			= BP_TASK_JOB_HCS_TIME,
    [ JOB_CLASS_LOADER ] 		= BP_TASK_JOB_LOADER_TIME,
    -- [ JOB_CLASS_PILOT ] 		= BP_TASK_JOB_PILOT_TIME,
    -- [ JOB_CLASS_WOODCUTTER ] 	= BP_TASK_JOB_WOODCUTTER_TIME,
    -- [ JOB_CLASS_TOWTRUCKER ] 	= BP_TASK_JOB_TOWTRUCKER_TIME,
    -- [ JOB_CLASS_INKASSATOR ] 	= BP_TASK_JOB_INKASSATOR_TIME,
}

local self
self = {
    pulse_interval = 60,
    
    timers = { },

    StartTimeTracking = function( player )
        local task_cid = task_cid_by_job_class[ player:GetJobClass( ) ]
        if not task_cid then return end

        if self.timers[ player ] then return end
        self.timers[ player ] = setTimer( self.Pulse, self.pulse_interval * 1000, 0, player, self.pulse_interval )
    end,
    
    StopTimeTracking = function( player )
        self.ClearPlayerData( player )
    end,

    Pulse = function( player )
        if not isElement( player ) or not player:GetOnShift( ) then
            self.ClearPlayerData( player )
            return
        end

        local task_cid = task_cid_by_job_class[ player:GetJobClass( ) ]
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

    PlayerAction_StartJobShift_handler = function( )
        local player = source
        self.StartTimeTracking( player )
    end,
    
    PlayerAction_EndJobShift_handler = function( )
        local player = source
        self.StopTimeTracking( player )
    end,

    ------------------------------------------------

    Start = function( player )
        if not player:GetOnShift( ) then return end
        local task_cid = task_cid_by_job_class[ player:GetJobClass( ) ]
        local task_id = player:GetActiveTaskID( task_cid )
        if task_id then
            self.StartTimeTracking( player )
        end
    end,
}
for i, task_cid in pairs( task_cid_by_job_class ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "PlayerAction_StartJobShift" )
addEventHandler( "PlayerAction_StartJobShift", root, self.PlayerAction_StartJobShift_handler )

addEvent( "PlayerAction_EndJobShift" )
addEventHandler( "PlayerAction_EndJobShift", root, self.PlayerAction_EndJobShift_handler )