loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "rewards/Server" )

addEventHandler( "onPlayerReadyToPlay", root, function( )
    local player = source
    if not player:HasFinishedTutorial( ) then return end

    local data = player:GetPermanentData( OFFER.id .. "_data" )
    if data and data.finish_ts > getRealTimestamp( ) then
        triggerClientEvent( player, "IO:ShowOffer", resourceRoot, data )
    end
end, true, "low" )

addEvent( "onPlayerCarsellOpen" )
addEventHandler( "onPlayerCarsellOpen", root, function( )
    local player = source
    if player:GetLevel( ) < OFFER.need_level then return end

    local real_ts = getRealTimestamp( )
    local all_vehicles_discount = player:GetPermanentData( "all_vehicles_discount" )
    if not all_vehicles_discount or ( all_vehicles_discount.percentage == 25 and all_vehicles_discount.timestamp >= real_ts ) then return end

    if #player:GetVehicles( false, true, true ) > 0 then return end

    if OFFER.cooldown then
        if ( player:GetPermanentData( OFFER.id .. "_cooldown_ts" ) or 0 ) > real_ts then return end
    else
        if player:GetPermanentData( OFFER.id .. "_data" ) then return end
    end

    local data = {
        variant = offer_variant,
        finish_ts = real_ts + OFFER.duration,
    }
    player:SetPermanentData( OFFER.id .. "_data", data )
    if OFFER.cooldown then
        player:SetPermanentData( OFFER.id .. "_cooldown_ts", real_ts + OFFER.cooldown )
    end
    triggerClientEvent( player, "IO:ShowOffer", resourceRoot, data )

    SendElasticGameEvent( player:GetClientID( ), "ind_soft_car_offer_show", {
        id = "ind_soft_car",
    } )
end )

addEvent( "IO:onPlayerWantBuy", true )
addEventHandler( "IO:onPlayerWantBuy", resourceRoot, function( )
    local player = client
    local data = player:GetPermanentData( OFFER.id .. "_data" )
    if not data then return end

    if data.finish_ts < getRealTimestamp( ) then
        player:ShowError( "Данное предложение больше недоступно" )
        return
    end

    local offer = OFFER
    local analytics_id = "ind_soft_car_offer"
    if not player:TakeDonate( offer.cost, "individual_offer", analytics_id ) then
        triggerEvent( "onPlayerRequestDonateMenu", player, "donate", analytics_id )
        return
    end

    for i, item in pairs( offer.items ) do
        player:GiveReward( item, {
            source = "individual_offer",
            source_type = analytics_id,
        } )
    end
    player:GiveAllVehiclesDiscount( 24 * 60 * 60, OFFER.car_discount )

    triggerClientEvent( player, "IO:onClientPurchase", resourceRoot )

    data.finish_ts = 0
    player:SetPermanentData( OFFER.id .. "_data", data )

    SendElasticGameEvent( player:GetClientID( ), "ind_soft_car_offer_purchase", {
        id = analytics_id,
        cost = offer.cost,
        currency = "hard",
        quantity = 1,
        spend_sum = offer.cost,
    } )
end )