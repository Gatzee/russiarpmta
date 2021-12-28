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

addEvent( "InitRouletteWindow", true )
addEventHandler( "InitRouletteWindow", root, function( )
    local player = client
    if not CheckVisitsCount( player, OFFER.need_visits_count, OFFER.need_visits_period ) then return end
    if player:GetLevel( ) < OFFER.need_level then return end

    local real_ts = getRealTimestamp( )
    if OFFER.cooldown then
        if ( player:GetPermanentData( OFFER.id .. "_cooldown_ts" ) or 0 ) > real_ts then return end
    else
        if player:GetPermanentData( OFFER.id .. "_data" ) then return end
    end

    local ts_7d_ago = real_ts - 7 * 24 * 60 * 60
	local last_wof_purchase_ts = player:GetPermanentData( "last_wof_purchase_ts" ) or 0
	local donate_last_date = player:GetPermanentData( "donate_last_date" ) or 0
    local offer_variant

    -- в течение 7 дней игрок НЕ ПОКУПАЛ жетоны любого Колеса Фортуны
    -- последний платеж был от 7 дней назад либо никогда
    if last_wof_purchase_ts < ts_7d_ago and donate_last_date < ts_7d_ago then
        offer_variant = 1
    -- в течение 7 дней игрок НЕ ПОКУПАЛ жетоны любого Колеса Фортуны
    -- последний платеж был в течение предыдущих 7 дней
    elseif last_wof_purchase_ts < ts_7d_ago and donate_last_date >= ts_7d_ago then
        offer_variant = 2
    -- в течение 7 дней игрок ХОТЯ БЫ РАЗ ПОКУПАЛ жетоны любого Колеса Фортуны
    -- последний платеж был в течение предыдущих 7 дней
    elseif last_wof_purchase_ts >= ts_7d_ago and donate_last_date >= ts_7d_ago then
        offer_variant = 3
    end

    if offer_variant then
        local data = {
            variant = offer_variant,
            finish_ts = real_ts + OFFER.duration,
        }
        player:SetPermanentData( OFFER.id .. "_data", data )
        if OFFER.cooldown then
            player:SetPermanentData( OFFER.id .. "_cooldown_ts", real_ts + OFFER.cooldown )
        end
        triggerClientEvent( player, "IO:ShowOffer", resourceRoot, data )

        SendElasticGameEvent( player:GetClientID( ), "ind_wof_offer_show", {
            id = "ind_wof_offer0" .. offer_variant,
        } )
    end
end )

addEvent( "onPlayerWofCoinsPurchase" )
addEventHandler( "onPlayerWofCoinsPurchase", root, function( type )
    local player = source
    player:SetPermanentData( "last_wof_purchase_ts", getRealTimestamp( ) )
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

    local offer = OFFER.variants[ data.variant ]
    local analytics_id = "ind_wof_offer0" .. data.variant
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

    triggerClientEvent( player, "IO:onClientPurchase", resourceRoot )

    data.finish_ts = 0
    player:SetPermanentData( OFFER.id .. "_data", data )

    SendElasticGameEvent( player:GetClientID( ), "ind_wof_offer_purchase", {
        id = analytics_id,
        cost = offer.cost,
        currency = "hard",
        quantity = 1,
        spend_sum = offer.cost,
    } )
end )

function CheckVisitsCount( player, need_count, need_duration )
    local last_visits = player:GetPermanentData( OFFER.id .. "_check_data" ) or { }

    local real_ts = getRealTimestamp( )
    table.insert( last_visits, 1, real_ts )

    if #last_visits > need_count then
        last_visits[ need_count + 1 ] = nil
    end

    for i = #last_visits, 1, -1 do
        if last_visits[ i ] + need_duration < real_ts then
            last_visits[ i ] = nil
        else
            break
        end
    end

    player:SetPermanentData( OFFER.id .. "_check_data", last_visits )

    return #last_visits >= need_count
end