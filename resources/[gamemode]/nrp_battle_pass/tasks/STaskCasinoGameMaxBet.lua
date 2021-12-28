local task_cid_by_game = {
    [ CASINO_GAME_BLACK_JACK ] = BP_TASK_CASINO_BLACKJACK_MAX_BET,
}

local task_cid_by_casino_by_game = {
    [ CASINO_MOSCOW ] = {
        [ CASINO_GAME_CLASSIC_ROULETTE ] = BP_TASK_CASINO_MSC_CLASSIC_MAX_BET,
    },

    [ CASINO_THREE_AXE ] = {
        -- [ CASINO_GAME_CLASSIC_ROULETTE ] = BP_TASK_CASINO_MSC_CLASSIC_MAX_BET,
    },
}

local self
self = {
    onCasinoPlayerMaxBet = function( casino_id, game )
        local player = source

        local task_cid = task_cid_by_game[ game ]
        if task_cid then
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
            
            player:AddTaskProgress( task_id, 1 )
        end

        local task_cid = task_cid_by_casino_by_game[ casino_id ][ game ]
        if task_cid then
            local task_id = player:GetActiveTaskID( task_cid )
            if not task_id then return end
            
            player:AddTaskProgress( task_id, 1 )
        end
    end,
}
for i, task_cid in pairs( task_cid_by_game ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end
for i, task_cid_by_game in pairs( task_cid_by_casino_by_game ) do
    for i, task_cid in pairs( task_cid_by_game ) do
        BP_TASKS_CONTROLLERS[ task_cid ] = self
    end
end

addEvent( "onCasinoPlayerMaxBet" )
addEventHandler( "onCasinoPlayerMaxBet", root, self.onCasinoPlayerMaxBet )