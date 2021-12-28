
function onDoubleMayhemPurchased( player, pack_id, is_take_gift )
    SendElasticGameEvent( player:GetClientID( ), "double_mayhem_purchase", { 
        pack_id      = pack_id,
        pack_cost    = OFFER_CONFIG.packs[ pack_id ].cost,
        is_take_gift = tostring( is_take_gift ),
        id_reward    = tostring( is_take_gift and OFFER_CONFIG.gift.params.model or "null" ),
        reward_cost  = OFFER_CONFIG.packs[ pack_id ].cost_original + ( is_take_gift and OFFER_CONFIG.gift.cost or 0 ),
        currency     = "hard",
    } )
end