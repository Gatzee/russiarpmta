
function onShowFirstTime( player )
    SendElasticGameEvent( player:GetClientID( ), "car_notpay_offer_show_first" )
end

function onPlayerOfferPurchase( player, vehicle_id, vehicle_name, vehicle_class, vehicle_cost )
    SendElasticGameEvent( player:GetClientID( ), "car_notpay_offer_purchase", 
    { 
        vehicle_id    = tonumber( vehicle_id ),
        vehicle_name  = tostring( vehicle_name ),
        vehicle_cost  = tonumber( vehicle_cost ),
        vehicle_class = tonumber( vehicle_class ),
        currency      = "hard",
        quantity      = 1,
        spend_sum     = tonumber( vehicle_cost ),
    } )
end