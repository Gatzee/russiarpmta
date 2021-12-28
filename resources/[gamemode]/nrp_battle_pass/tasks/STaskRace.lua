local task_cid_by_race_type = {
    [ RACE_TYPE_CIRCLE_TIME ] 	= BP_TASK_RACE_CIRCLE_TIME,
    [ RACE_TYPE_DRIFT ] 		= BP_TASK_RACE_DRIFT,
    [ RACE_TYPE_DRAG ] 			= BP_TASK_RACE_DRAG,
}

local self
self = {
    onRaceAnyFinish_handler = function( race_type, is_really_finished )
        if not is_really_finished then return end
        
        local player = source
        local task_cid = task_cid_by_race_type[ race_type ]
        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end
        
        local is_task_completed = player:AddTaskProgress( task_id, 1 )
    end,
}
for i, task_cid in pairs( task_cid_by_race_type ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "onRaceAnyFinish" )
addEventHandler( "onRaceAnyFinish", root, self.onRaceAnyFinish_handler )