local task_cid_by_job_class = {
    [ JOB_CLASS_COURIER            ] = BP_TASK_JOB_LAP_COURIER       ,
    [ JOB_CLASS_DRIVER             ] = BP_TASK_JOB_LAP_DRIVER        ,
    [ JOB_CLASS_TAXI               ] = BP_TASK_JOB_LAP_TAXI          ,
    [ JOB_CLASS_TAXI_PRIVATE       ] = BP_TASK_JOB_LAP_TAXI          ,
    [ JOB_CLASS_FARMER             ] = BP_TASK_JOB_LAP_FARMER        ,
    [ JOB_CLASS_TOWTRUCKER         ] = BP_TASK_JOB_LAP_TOWTRUCKER    ,
    [ JOB_CLASS_PARK_EMPLOYEE      ] = BP_TASK_JOB_LAP_PARK_EMPLOYEE ,
    [ JOB_CLASS_LOADER             ] = BP_TASK_JOB_LAP_LOADER        ,
    [ JOB_CLASS_HCS                ] = BP_TASK_JOB_LAP_HCS           ,
    [ JOB_CLASS_TRANSPORT_DELIVERY ] = BP_TASK_JOB_LAP_DELIVERY_CARS ,
    -- [ JOB_CLASS_TRUCKER            ] = BP_TASK_JOB_LAP_TRUCKER       ,

    [ "any_coop" ] = BP_TASK_JOB_LAP_ANY_COOP,
}

local task_cid_by_job_class_voyage = {
    [ JOB_CLASS_TRUCKER            ] = BP_TASK_JOB_LAP_TRUCKER       ,
}

local self
self = {
    onJobEarnMoney = function( job_class, money, money_source )
        local player = source

        if money_source == "Ежедневная задача" then return end

        local task_cid = task_cid_by_job_class[ job_class ]
        local task_id = player:GetActiveTaskID( task_cid )
        if task_id then
            player:AddTaskProgress( task_id, 1 )
        end
    end,

    onJobFinishedVoyage = function( )
        local player = source

        local task_cid = task_cid_by_job_class_voyage[ player:GetJobClass( ) ]
        local task_id = player:GetActiveTaskID( task_cid )
        if task_id then
            player:AddTaskProgress( task_id, 1 )
        end
    end,

    onCoopJobEarnMoney = function( money )
        local player = source

        local task_id = player:GetActiveTaskID( BP_TASK_JOB_LAP_ANY_COOP )
        if task_id then
            player:AddTaskProgress( task_id, 1 )
        end
    end,
}
for i, task_cid in pairs( task_cid_by_job_class ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end
for i, task_cid in pairs( task_cid_by_job_class_voyage ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "onJobEarnMoney" )
addEventHandler( "onJobEarnMoney", root, self.onJobEarnMoney )

addEvent( "onCoopJobEarnMoney" )
addEventHandler( "onCoopJobEarnMoney", root, self.onCoopJobEarnMoney )

addEvent( "onJobFinishedVoyage" )
addEventHandler( "onJobFinishedVoyage", root, self.onJobFinishedVoyage )