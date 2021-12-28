
function onDefenderFatherlandDayOfferShowFirst( player )
    SendElasticGameEvent( player:GetClientID( ), "defender_day_offer_show_first" )
end

function onDefenderFatherlandDaySegmentChange( player, segment_num )
    SendElasticGameEvent( player:GetClientID( ), "defender_day_segment_change",
    {
        segment_num = tonumber( segment_num ),
    } )
end

function onDefenderFatherlandDayOfferPurchase( player, id, name, cost, currency, spend_sum, quantity, reward, segment_num )
    SendElasticGameEvent( player:GetClientID( ), "defender_day_offer_purchase", 
    { 
        id          = tostring( id ),
        name        = tostring( name ),
        cost        = tonumber( cost ),
        currency    = tostring( currency ),
        spend_sum   = tonumber( spend_sum ),
        quantity    = tonumber( quantity ),
        reward      = tostring( reward ),
        segment_num = tonumber( segment_num ),
    } )
end