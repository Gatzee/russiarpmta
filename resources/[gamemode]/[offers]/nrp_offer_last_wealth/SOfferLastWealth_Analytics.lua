

function onLastRichesHardPurchase( player, spend_sum, give_sum, cur_mul )
    local cur_mul_level_data = LEVEL_MULTIPLY[ cur_mul ] or DEFAULT_MULTIPLY_DATA
    
    local count_steps = 0
    local count_completed_steps = 0
    local cur_mul_step = player:GetMulSteps()
    local exec_mul_step = player:GetExecutableMulStep()

    local level = LEVEL_MULTIPLY[ exec_mul_step ] or LEVEL_MULTIPLY[ exec_mul_step ] or cur_mul_level_data
    for step_id, step_data in pairs( level.steps ) do
        local task_progress_steps = math.min( cur_mul_step[ step_id ] or 0, step_data.count  )
        count_completed_steps = count_completed_steps + (task_progress_steps == step_data.count and 1 or 0)
        count_steps = count_steps + 1
    end

    SendElasticGameEvent( player:GetClientID( ), "last_riches_hard_purchase", 
    { 
        multiplier_num  = tonumber( cur_mul_level_data.value ),
        spend_sum       = tonumber( spend_sum ),
        give_hard_sum   = tonumber( give_sum ),
        currency        = "rub",
        task_count      = tonumber( cur_mul ),
        task_compliting = tonumber( 0.01 * math.floor( 100 * ( count_completed_steps / count_steps ) ) ),
        task_id         = tostring( "hard_task" .. cur_mul ),

    } )
end

function onLastRichesTaskComplete( player, completed_mul )
    local cur_mul = player:GetCurrentMulStep()
    local cur_mul_level_data = LEVEL_MULTIPLY[ cur_mul ]
    SendElasticGameEvent( player:GetClientID( ), "last_riches_task_complete", 
    { 
        step_num       = tonumber( completed_mul ),
        multiplier_num = tonumber( cur_mul_level_data.value ),
        task_id        = tostring( "hard_task" .. completed_mul ),
    } )
end