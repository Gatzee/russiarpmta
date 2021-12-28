
function onOfferDiscountGiftShowFirst( player )
    SendElasticGameEvent( player:GetClientID( ), "donate_offer_discount_showfirst" )
end

function onOfferDiscountGiftPurchase( player, pack_data )
    SendElasticGameEvent( player:GetClientID( ), "donate_offer_discount_purchase", 
    { 
        id            = tostring( pack_data.id ),
        cost          = tonumber( pack_data.cost ),
        value_sum     = tonumber( pack_data.value_sum ),
        currency      = tostring( pack_data.currency ),
        discount_data = tostring( toJSON( pack_data.discount_data ) ),
    } )
end
