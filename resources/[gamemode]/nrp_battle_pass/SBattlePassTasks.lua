Player.GetTasks = function( self )
    return self:GetPermanentData( "bp_tasks" ) or { }
end

Player.SetTasks = function( self, data )
    return self:SetPermanentData( "bp_tasks", data )
end

Player.GetActiveTaskID = function( self, cid )
    if not cid or not BP_TASKS_INFO_BY_CID[ cid ] then return end

    local player_tasks = self:GetTasks( )
    for i, task_info in ipairs( BP_TASKS_INFO_BY_CID[ cid ] ) do
        local task = player_tasks[ task_info.id ]
        if ( not task or not task.completed ) and task_info.start_ts < getRealTimestamp( ) then
            if not task_info.condition or task_info.condition( self ) then
                return task_info.id
            end
        end
    end

    return false
end

Player.GetTaskProgress = function( self, id, absolute )
    local tasks = self:GetTasks( )
    local task = tasks[ id ]
    local progress = task and task.progress or 0
    if not absolute then
        progress = progress * GetTaskInfo( self, id, "need_progress" )
        progress = ( math.ceil( progress ) - progress < 0.1 ^ 5 ) and math.ceil( progress ) or math.floor( progress )
    end
    return progress
end

Player.SetTaskProgress = function( self, id, value )
    local tasks = self:GetTasks( )
    local task = tasks[ id ]
    if not task then
        task = { }
        tasks[ id ] = task
    end
    task.progress = value
    
    return self:SetTasks( tasks )
end

Player.AddTaskProgress = function( self, id, progress, skip_cost )
    if not skip_cost and progress <= 0 then return end
    if BP_CURRENT_SEASON_END_TS <= getRealTimestamp( ) then return end

    local tasks = self:GetTasks( )
    local task = tasks[ id ]
    if not task then
        task = { }
        tasks[ id ] = task
    end

    if task.completed then return end

    local task_info = GetTaskInfo( self, id )
    task.progress = skip_cost and 1 or ( task.progress or 0 ) + progress / task_info.need_progress

    if 1 - task.progress < 0.1 ^ 12 then
        task.progress = 1
        task.completed = true

        if not skip_cost then
            self:PhoneNotification( {
                title = "Сезонные награды",
                msg = "Выполнена задача \"" .. task_info.name .. "\" в сезонных наградах.",
                special = "battle_pass",
            } )
        end

        local old_level = self:GetBattlePassLevel( )
        local reward_type, quantity
        if old_level == BP_MAX_LEVEL then
            self:GiveMoney( task_info.money, "battle_pass", "battle_pass_soft" )
            task.got_money = true
            reward_type, quantity = "soft", task_info.money
        else
            local reward_num = self:GiveBattlePassEXP( task_info.reward )
            reward_type, quantity = "season_exp", reward_num
        end

        local current_level = self:GetBattlePassLevel( )
        SendElasticGameEvent( self:GetClientID( ), "battle_pass_task_complited", {
            season_num = BP_CURRENT_SEASON_ID,
            num_task = id,
            id_task = "battle_q" .. id .. ( task_info.branch_id and ( "_" .. task_info.branch_id ) or "" ),
            name_task = Translit( task_info.name:gsub( "\n", " " ) ),
            reward_type = reward_type,
            quantity = quantity,
            total_boost = math.floor( self:GetBattlePassBoostCoef( ) * 100 + 0.5 ),
            is_levelup = ( old_level ~= current_level ) and "true" or "false",
            level_num = current_level,
            is_skipped = skip_cost and "true" or "false",
            skip_sum = skip_cost or 0,
        } )
    end
    
    return self:SetTasks( tasks )
end

Player.GetTaskData = function( self, id, key )
    local tasks = self:GetTasks( )
    local task = tasks[ id ]
    if not task then return end
    if not task.data then return end

    return task.data[ key ]
end

Player.SetTaskData = function( self, id, key, value )
    local tasks = self:GetTasks( )
    local task = tasks[ id ]
    if not task then
        task = { }
        tasks[ id ] = task
    end
    if not task.data then
        task.data = { }
    end
    task.data[ key ] = value
    self:SetTasks( tasks )
end

addEvent( "BP:onPlayerWantSkipTask", true )
addEventHandler( "BP:onPlayerWantSkipTask", resourceRoot, function( task_id )
    local player = client

    if BP_CURRENT_SEASON_END_TS <= getRealTimestamp( ) then
        player:ShowInfo( "Сезон уже окончен" )
        return
    end

    if player:GetTaskProgress( task_id, true ) == 1 then
        player:ShowInfo( "Вы уже выполнили эту задачу" )
        return
    end

    local task_skip_count = ( player:GetPermanentData( "bp_task_skip_count" ) or 0 ) + 1
    local cost = BP_TASK_SKIP_COSTS[ task_skip_count ]
    if not player:TakeDonate( cost, "battle_pass", "battle_pass_season" .. BP_CURRENT_SEASON_ID ) then
        triggerClientEvent( player, "onShopNotEnoughHard", player, "Battle pass task skip", "onPlayerRequestDonateMenu", "donate" )
        return
    end

    player:SetPermanentData( "bp_task_skip_count", task_skip_count )
    player:AddTaskProgress( task_id, _, cost )

    triggerClientEvent( player, "BP:UpdateUI", resourceRoot, {
        task_skip_count = task_skip_count,
        tasks = player:GetTasks( ),
        level = player:GetBattlePassLevel( ),
        exp = player:GetBattlePassEXP( ),
    } )

    SendElasticGameEvent( player:GetClientID( ), "battle_pass_purchase", {
        id_item = "skip_task",
        season_num = BP_CURRENT_SEASON_ID,
        quantity = 1,
        spend_sum = cost,
        currency = "hard",
        discount = 0,
    } )
end )

addEvent( "onPlayerPreLogout" )
addEventHandler( "onPlayerPreLogout", root, function( )
    local player = source

    for task_cid, task_controller in pairs( BP_TASKS_CONTROLLERS ) do
        if task_controller.ClearPlayerData then
            task_controller.ClearPlayerData( player )
        end
    end
end )

addEventHandler( "onResourceStart", resourceRoot, function( )
    setTimer( function( )
        for i, player in pairs( GetPlayersInGame( ) ) do
            for task_cid, task_controller in pairs( BP_TASKS_CONTROLLERS ) do
                if task_controller.Start then
                    task_controller.Start( player )
                end
            end
        end
    end, 3000, 1 )
end )