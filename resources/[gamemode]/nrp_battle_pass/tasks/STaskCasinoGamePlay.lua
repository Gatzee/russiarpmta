local task_cid_by_casino_game = {
    -- [ CASINO_GAME_FOOL                    ] = BP_TASK_CASINO_FOOL            ,
       [ CASINO_GAME_DICE                    ] = BP_TASK_CASINO_DICE            ,
       [ CASINO_GAME_DICE_VIP                ] = BP_TASK_CASINO_DICE            ,
       [ CASINO_GAME_ROULETTE                ] = BP_TASK_CASINO_ROULETTE        ,
       [ CASINO_GAME_CLASSIC_ROULETTE        ] = BP_TASK_CASINO_CLASSIC,
       [ CASINO_GAME_SLOT_MACHINE_GOLD_SKULL ] = BP_TASK_CASINO_SLOT_MACHINE    ,
       [ CASINO_GAME_SLOT_MACHINE_VALHALLA   ] = BP_TASK_CASINO_SLOT_MACHINE    ,
       [ CASINO_GAME_SLOT_MACHINE_CHICAGO    ] = BP_TASK_CASINO_SLOT_MACHINE    ,
       [ CASINO_GAME_BLACK_JACK              ] = BP_TASK_CASINO_BLACKJACK       ,
}

local self
self = {
    onCasinoPlayersGame_handler = function( game, players )
        local task_cid = task_cid_by_casino_game[ game ]
        if not task_cid then return end
        
        for i, player in pairs( players ) do
            local task_id = player:GetActiveTaskID( task_cid )
            if task_id then
                player:AddTaskProgress( task_id, 1 )
            end
        end
    end,
}
for i, task_cid in pairs( task_cid_by_casino_game ) do
    BP_TASKS_CONTROLLERS[ task_cid ] = self
end

addEvent( "onCasinoPlayersGame" )
addEventHandler( "onCasinoPlayersGame", root, self.onCasinoPlayersGame_handler )