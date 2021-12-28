Extend( "rewards/Client" )

function Show7CasesReward( reward_id )
    local item = DISCOUNT_DATA and DISCOUNT_DATA.rewards[ reward_id ]
	if not item then return end

    ShowTakeReward( _, item, function( args )
        triggerServerEvent( "PlayerWantReceive7CasesReward", resourceRoot, args )
    end, Is7CasesDiscountShown( ) )
end
addEvent( "Show7CasesReward", true )
addEventHandler( "Show7CasesReward", resourceRoot, Show7CasesReward )