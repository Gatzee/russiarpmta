Extend( "CPlayer" )
Extend( "CVehicle" )

IS_TAKING_ALL_REWARDS = false

function TakeNextAvaliableReward( )
    IS_TAKING_ALL_REWARDS = false

    local rewards = DATA.rewards
    for i, type in pairs( { "free", DATA.is_premium_active and "premium" or nil } ) do
        if not rewards[ type ] then
            rewards[ type ] = { }
        end

        for level = 1, ( DATA.level or 0 ) do
            if not rewards[ type ][ level ] then
                local reward = BP_LEVELS_REWARDS[ type ][ level ]
                if reward then
                    if reward.TakeReward_client then
                        reward:TakeReward_client( level, type )
                    else
                        ShowReward( level, type )
                    end

                    IS_TAKING_ALL_REWARDS = true
                    return true
                end
            end
        end
    end

    if not DATA.is_premium_active then
        ShowPremiumOffer( false, true )
    end
end

addEvent( "BP:onClientRewardTake", true )
addEventHandler( "BP:onClientRewardTake", resourceRoot, function( level, is_premium )
    if not isElement( UI.bg ) then return end

    if IS_TAKING_ALL_REWARDS then
        TakeNextAvaliableReward( )
    end
end, true, "low-1" )
