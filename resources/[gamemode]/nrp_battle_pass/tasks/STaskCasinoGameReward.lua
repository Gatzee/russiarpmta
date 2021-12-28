local task_cid_by_casino_game = {
    -- [ CASINO_GAME_FOOL             ] = BP_TASK_CASINO_FOOL_REWARD,
    -- [ CASINO_GAME_DICE             ] = BP_TASK_CASINO_DICE_REWARD,
    -- [ CASINO_GAME_DICE_VIP         ] = BP_TASK_CASINO_DICE_VIP_REWARD,
    -- [ CASINO_GAME_ROULETTE         ] = BP_TASK_CASINO_ROULETTE_REWARD,
    [ CASINO_GAME_SLOT_MACHINE_GOLD_SKULL ] = BP_TASK_CASINO_SLOT_MACHINE_REWARD    ,
    [ CASINO_GAME_SLOT_MACHINE_VALHALLA   ] = BP_TASK_CASINO_SLOT_MACHINE_REWARD    ,
    [ CASINO_GAME_SLOT_MACHINE_CHICAGO    ] = BP_TASK_CASINO_SLOT_MACHINE_REWARD    ,
    [ CASINO_GAME_CLASSIC_ROULETTE        ] = BP_TASK_CASINO_CLASSIC_REWARD,
    [ CASINO_GAME_BLACK_JACK              ] = BP_TASK_CASINO_BLACKJACK_REWARD       ,
}

local self
self = {
    onAddCasinoGameWinAmount_handler = function( player, casino_id, game_id, sum )
        local task_cid = task_cid_by_casino_game[ game_id ]
        if not task_cid or not sum then return end
        
        local task_id = player:GetActiveTaskID( task_cid )
        if not task_id then return end

        local is_task_completed = player:AddTaskProgress( task_id, sum )
    end,
}
for i, task_cid in pairs( task_cid_by_casino_game ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "onAddCasinoGameWinAmount" )
addEventHandler( "onAddCasinoGameWinAmount", root, self.onAddCasinoGameWinAmount_handler )