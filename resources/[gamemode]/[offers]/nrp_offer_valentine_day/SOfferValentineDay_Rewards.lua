
REWARDS =
{
    soft = function( player, reward_data )
        player:GiveMoney( reward_data.cost * 1000, "sale", "valentine_pack_reward" )
    end,

    case = function( player, reward_data )
        player:GiveCase( reward_data.item_id, reward_data.quantity )
    end,

    vinyl = function( player, reward_data )
        reward_data.params = 
        {
            id = reward_data.item_id,
        }
        player:SetPermanentData( "last_valentine_day_vinyl", reward_data )
        triggerClientEvent( player, "onClientSelectVinyl", resourceRoot, reward_data )
    end,

    iventory_item = function( player, reward_data )
        player:InventoryAddItem( reward_data.item_id, nil, reward_data.quantity )
    end,
}

function onServerPlayerSelectedVinyl_handler( data )
    local player = client
    if not isElement( player ) then return end

    local reward_data = player:GetPermanentData( "last_valentine_day_vinyl" )
    if not reward_data then return end

    player:GiveVinyl( {
        [ P_PRICE_TYPE ] = "hard",
        [ P_IMAGE      ] = reward_data.item_id,
        [ P_CLASS      ] = (data and data.vehicle and data.vehicle:GetTier()) or 1,
        [ P_NAME       ] = VINYL_NAMES[ reward_data.item_id ],
        [ P_PRICE      ] = reward_data.cost,
    } )

    player:SetPermanentData( "last_valentine_day_vinyl", nil )
end
addEvent( "onServerPlayerSelectedVinyl", true )
addEventHandler( "onServerPlayerSelectedVinyl", resourceRoot, onServerPlayerSelectedVinyl_handler )