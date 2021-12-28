
UNIQUE_JOB_ANALYTICS = 
{
    [ JOB_CLASS_TRUCKER ] =
    {
        onJobStarted = function( player )
            local shift = player:GetPermanentData( "job_shift" )
            local city_names = { [ 0 ] = "countryside", [ 1 ] = "gorki" }
            
            SendElasticGameEvent( player:GetClientID( ), "trucker_job_start",
            {
                company_num  = tonumber( JOB_DATA[ JOB_CLASS_TRUCKER ].conf_reverse[ player:GetJobID() ].position ),
                shift_id     = tostring( player:GetShiftID() ),
                current_lvl  = tonumber( player:GetLevel() ),
                type_trucker = tostring( city_names[ shift.city ] ),
            } )
        end,

        onJobFinishedVoyage = function( player, receive_sum, exp_sum )
            local shift = player:GetPermanentData( "job_shift" )
            shift.receive_sum = shift.receive_sum + receive_sum
            shift.exp_sum     = shift.exp_sum + exp_sum
            player:SetPermanentData( "job_shift", shift )
            
            SendElasticGameEvent( player:GetClientID( ), "trucker_job_finish_voyage",
            {
                shift_id     = tostring( player:GetShiftID() ),
                company_num  = tonumber( JOB_DATA[ JOB_CLASS_TRUCKER ].conf_reverse[ player:GetJobID() ].position ),
                current_lvl  = tonumber( player:GetLevel() ),
                job_duration = tonumber( getRealTimestamp() - shift.last_started ),
                receive_sum  = tonumber( receive_sum ),
                currency     = "soft",
                exp_sum      = tonumber( exp_sum ),
            } )

            player:setData( "last_voyage", true, false )
            player:setData( "trucker_prev_reward", false, false )
        end,

        onJobFinished = function( player, finish_reason )
            local shift = player:GetPermanentData( "job_shift" )
            local city_names = { [ 0 ] = "countryside", [ 1 ] = "gorki" }

            local prev_reward = player:getData( "trucker_prev_reward" )
            if prev_reward then
                shift.receive_sum = shift.receive_sum + prev_reward.money
                shift.exp_sum = shift.exp_sum + prev_reward.exp
            end

            SendElasticGameEvent( player:GetClientID( ), "trucker_job_finish",
            {
                shift_id       = tostring( player:GetShiftID() ),
                current_lvl    = tonumber( player:GetLevel() ),
                company_num    = tonumber( JOB_DATA[ JOB_CLASS_TRUCKER ].conf_reverse[ player:GetJobID() ].position ),
                type_trucker   = tostring( city_names[ shift.city ] ),
                job_duration   = tonumber( getRealTimestamp() - shift.last_started ),
                receive_sum    = tonumber( shift.receive_sum ),
                currency       = "soft",
                exp_sum        = tonumber( shift.exp_sum ),
                finish_reason  = tostring( finish_reason ),
                is_voyage_fail = tostring( not player:getData( "last_voyage" ) ),
            } )

            player:setData( "trucker_prev_reward", false, false )
            player:setData( "last_voyage", false, false )
        end,
    },

}


function onJobFinishedVoyage_handler( receive_sum, exp_sum )
    local unique_job_analytics = UNIQUE_JOB_ANALYTICS[ source:GetJobClass() ]
    if unique_job_analytics and unique_job_analytics.onJobFinishedVoyage then 
        unique_job_analytics.onJobFinishedVoyage( source, receive_sum or 0, exp_sum or 0 ) 
    else
        onJobFinishedVoyage( source, receive_sum or 0, exp_sum or 0 ) 
    end
end
addEvent( "onJobFinishedVoyage" )
addEventHandler( "onJobFinishedVoyage", root, onJobFinishedVoyage_handler )


function onJobStarted( player )
    local job_class, job_id = player:GetJobClass(), player:GetJobID()
    local company_data = JOB_DATA[ job_class ].conf_reverse[ job_id ]
    
    SendElasticGameEvent( player:GetClientID( ), "job_start",
    {
        id           = tostring( company_data.id ),
        name         = tostring( JOB_NAMES[ job_class ] .. " " .. company_data.position ),
        current_lvl  = tonumber( player:GetLevel() ),
    } )
end

function onJobFinishedVoyage( player, receive_sum, exp_sum )
    local job_class, job_id = player:GetJobClass(), player:GetJobID()
    local company_data = JOB_DATA[ job_class ].conf_reverse[ job_id ]
    
    local shift = player:GetPermanentData( "job_shift" )
    shift.receive_sum = (shift.receive_sum or 0) + receive_sum
    shift.exp_sum     = (shift.exp_sum or 0) + exp_sum
    player:SetPermanentData( "job_shift", shift )
    
    local ts = getRealTimestamp()
    SendElasticGameEvent( player:GetClientID( ), "job_voyage",
    {
        id           = tostring( company_data.id ),
        name         = tostring( JOB_NAMES[ job_class ] .. " " .. company_data.position ),
        current_lvl  = tonumber( player:GetLevel() ),
        job_duration = tonumber( ts - (shift.last_started or ts) ),
        receive_sum  = tonumber( receive_sum ),
        currency     = "soft",
        exp_sum      = tonumber( exp_sum ),
    } )
end

function onJobFinished( player, finish_reason )
    local job_class, job_id = player:GetJobClass(), player:GetJobID()
    local company_data = JOB_DATA[ job_class ].conf_reverse[ job_id ]
    
    local shift = player:GetPermanentData( "job_shift" )

    local ts = getRealTimestamp()
    SendElasticGameEvent( player:GetClientID( ), "job_finish",
    {
        id            = tostring( company_data.id ),
        name          = tostring( JOB_NAMES[ job_class ] .. " " .. company_data.position ),
        current_lvl   = tonumber( player:GetLevel() ),
        receive_sum   = tonumber( shift.receive_sum or 0 ),
        currency      = "soft",
        exp_sum       = tonumber( shift.exp_sum or 0 ),
        job_duration  = tonumber( ts - (shift.last_started or ts) ),
        finish_reason = tostring( finish_reason ),
    } )
end