DEAD_VALUES = {
    "job_1_chain", "job_2_chain", "job_3_chain", "job_4_chain", "job_5_chain",
    "job_1_exp", "job_2_exp", "job_3_exp", "job_4_exp", "job_5_exp",
    "form_replied",
    "9may_quest", "9may_quest_info",
    "job_onshift",
    "br_promo_shown",
}

function Cleanup( player )
    local tbl = PLAYER_DATA[ player ][ LOCKED_KEY ]
    for i, v in pairs( DEAD_VALUES ) do
        if tbl[ v ] ~= nil then
            tbl[ v ] = nil
            if CHANGED_VALUES[ player ] == nil then CHANGED_VALUES[ player ] = { } end
            CHANGED_VALUES[ player ][ LOCKED_KEY ] = true
            --iprint( player, "cleaned value", v )
        end
    end
end