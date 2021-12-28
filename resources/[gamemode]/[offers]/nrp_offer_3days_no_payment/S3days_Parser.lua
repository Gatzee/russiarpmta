GROUP_3DAYS_DURATION = 48 * 60 * 60
BASE_URL = "https://pyapi.gamecluster.nextrp.ru/v1.0/payments/pay"

function on3daysGroupLoaded_handler( group_3days, is_first_time )
    local player = source

    player:GetCommonData( { "started_3days", "bought_3days" }, { player, group_3days, is_first_time }, function( result, player, group_3days, is_first_time )
        if not isElement( player ) then return end -- Игрок вышел за время запроса

        if result.bought_3days then return end

        if not result.started_3days then
            local ts = getRealTime( ).timestamp
            result.started_3days = ts
            player:SetCommonData( { started_3days = ts } )
        end
        
        local passed = getRealTime( ).timestamp - result.started_3days
        local left   = GROUP_3DAYS_DURATION - passed

        if left > 0 then
            if not player:HasFinishedTutorial( ) then return end
            
            triggerClientEvent( player, "onActivateGroup3daysOffer", resourceRoot, BASE_URL, left, is_first_time )
            if is_first_time then
                triggerEvent( "on3daysShowFirst", player )
            end
        end
    end )
end
addEvent( "on3daysGroupLoaded", true )
addEventHandler( "on3daysGroupLoaded", root, on3daysGroupLoaded_handler )

function on3daysPurchase_handler( sum )
    local player = source
    player:SetCommonData( { bought_3days = true } )
    triggerClientEvent( player, "onParse3daysOfferPurchase", resourceRoot )
end
addEvent( "on3daysPurchase", true )
addEventHandler( "on3daysPurchase", root, on3daysPurchase_handler )
