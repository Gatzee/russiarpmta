-- Завершить 75 любых майских событий
do
    local task_cid = BP_TASK_ME_ANY_FINISH

    local self
    self = {
        onPlayerEventAnyFinish = function( )
            local player = source

            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
            
            player:AddTaskProgress( task_id, 1 )
        end,
    }
    BP_TASKS_CONTROLLERS[ task_cid ] = self

    addEvent( "onPlayerEventFinish" )
    addEventHandler( "onPlayerEventFinish", root, self.onPlayerEventAnyFinish )
end

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- Уничтожь в общей сложности 100 противников в состязаниях "Танковая битва" и "Бой охотников"
do
    local task_cid = BP_TASK_ME_TOTAL_KILLS

    local self
    self = {
        onPlayerKill = function( )
            local player = source
    
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
    
            player:AddTaskProgress( task_id, 1 )
        end,
    }
    BP_TASKS_CONTROLLERS[ task_cid ] = self
    
    addEvent( "BP:ME:onPlayerKill", true )
    addEventHandler( "BP:ME:onPlayerKill", root, self.onPlayerKill )
end

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- Поучаствуй в состязании "Танковая битва" 10 раз
do
    local task_cids = {
        [ "mayevent_tank_battle" ] = BP_TASK_ME_TANK_BATTLE_FINISH,
        [ "mayevent_fight_hunters" ] = BP_TASK_ME_HUNTER_BATTLE_FINISH,
        [ "mayevent_victory_drag" ] = BP_TASK_ME_WIN_DRAG_FINISH,
    }
    
    local self
    self = {
        onPlayerEventAnyFinish = function( event_id )
            local player = source
    
            local task_cid = task_cids[ event_id ]
            if not task_cid then return end
    
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
            
            player:AddTaskProgress( task_id, 1 )
        end,
    }
    for i, task_cid in pairs( task_cids ) do
        BP_TASKS_CONTROLLERS[ task_cid ] = self
    end
    
    addEvent( "onPlayerEventFinish" )
    addEventHandler( "onPlayerEventFinish", root, self.onPlayerEventAnyFinish )
end

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- 20 раз займи 1-3 место в состязании "Танковая битва"
do
    local task_cids = {
        [ "mayevent_tank_battle" ] = BP_TASK_ME_TANK_BATTLE_TOP3,
        [ "mayevent_fight_hunters" ] = BP_TASK_ME_HUNTER_BATTLE_TOP3,
    }
    
    local self
    self = {
        onPlayerEventAnyFinish = function( event_id, number )
            local player = source

            if not number or number > 3 then return end
    
            local task_cid = task_cids[ event_id ]
            if not task_cid then return end
    
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
            
            player:AddTaskProgress( task_id, 1 )
        end,
    }
    for i, task_cid in pairs( task_cids ) do
        BP_TASKS_CONTROLLERS[ task_cid ] = self
    end
    
    addEvent( "onPlayerEventFinish" )
    addEventHandler( "onPlayerEventFinish", root, self.onPlayerEventAnyFinish )
end

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- 20 раз займи 1 место в состязании "Победный драг"
do
    local task_cids = {
        [ "mayevent_victory_drag" ] = BP_TASK_ME_WIN_DRAG_TOP1,
    }
    
    local self
    self = {
        onPlayerEventAnyFinish = function( event_id, number )
            local player = source

            if not number or number > 1 then return end
    
            local task_cid = task_cids[ event_id ]
            if not task_cid then return end
    
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
            
            player:AddTaskProgress( task_id, 1 )
        end,
    }
    for i, task_cid in pairs( task_cids ) do
        BP_TASKS_CONTROLLERS[ task_cid ] = self
    end
    
    addEvent( "onPlayerEventFinish" )
    addEventHandler( "onPlayerEventFinish", root, self.onPlayerEventAnyFinish )
end

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- Уничтожь не менее 10 танков противника в течение одного состязания "Танковая битва"
do
    local task_cids = {
        [ "mayevent_tank_battle" ] = BP_TASK_ME_TANK_BATTLE_KILLS,
        [ "mayevent_fight_hunters" ] = BP_TASK_ME_HUNTER_BATTLE_KILLS,
    }

    local self
    self = {
        onPlayerKill = function( event_id )
            local player = source

            local task_cid = task_cids[ event_id ]
            if not task_cid then return end
    
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
    
            local event_start_timestamp = player:getData( "event_start_timestamp" )
            if event_start_timestamp ~= ( player:GetTaskData( task_id, "last_start_ts" ) or 0 ) then
                player:SetTaskProgress( task_id, 0 )
                player:SetTaskData( task_id, "last_start_ts", event_start_timestamp )
            end

            player:AddTaskProgress( task_id, 1 )
        end,
    
        onPlayerEventFinish = function( event_id )
            local player = source
    
            local task_cid = task_cids[ event_id ]
            if not task_cid then return end
    
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end

            player:SetTaskProgress( task_id, 0 )
        end,
    }
    for i, task_cid in pairs( task_cids ) do
        BP_TASKS_CONTROLLERS[ task_cid ] = self
    end
    
    addEvent( "BP:ME:onPlayerKill", true )
    addEventHandler( "BP:ME:onPlayerKill", root, self.onPlayerKill )
    
    addEvent( "onPlayerEventFinish" )
    addEventHandler( "onPlayerEventFinish", root, self.onPlayerEventFinish )
end

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- Погибни не более 5 раз в состязании "Танковая битва"
do
    local task_cids = {
        [ "mayevent_tank_battle" ] = BP_TASK_ME_TANK_BATTLE_DEATHS,
    }
    
    local self
    self = {
        onPlayerWasted = function( event_id )
            local player = source
    
            local task_cid = task_cids[ event_id ]
            if not task_cid then return end
    
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
    
            local deaths = player:GetTaskData( task_id, "deaths" ) or 0
    
            local event_start_timestamp = player:getData( "event_start_timestamp" )
            if event_start_timestamp ~= ( player:GetTaskData( task_id, "last_start_ts" ) or 0 ) then
                player:SetTaskData( task_id, "last_start_ts", event_start_timestamp )
                deaths = 0
            end
            
            deaths = deaths + 1
            player:SetTaskData( task_id, "deaths", deaths )
        end,
    
        onPlayerEventFinish = function( event_id )
            local player = source
    
            local task_cid = task_cids[ event_id ]
            if not task_cid then return end
    
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
    
            local deaths = player:GetTaskData( task_id, "deaths" ) or 0
            local max_death_count = GetTaskInfoByCID( task_cid, task_id, "max_death_count" )
            
            local event_start_timestamp = player:getData( "event_start_timestamp" )
            if event_start_timestamp ~= ( player:GetTaskData( task_id, "last_start_ts" ) or 0 ) then
                deaths = 0
            end
            
            if deaths <= max_death_count then
                player:AddTaskProgress( task_id, 1 )
            end
        end,
    }
    for i, task_cid in pairs( task_cids ) do
        BP_TASKS_CONTROLLERS[ task_cid ] = self
    end
    
    addEvent( "BP:ME:onPlayerWasted", true )
    addEventHandler( "BP:ME:onPlayerWasted", root, self.onPlayerWasted )
    
    addEvent( "onPlayerEventFinish" )
    addEventHandler( "onPlayerEventFinish", root, self.onPlayerEventFinish )
end