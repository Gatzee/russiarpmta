Extend( "SPlayer" )

OFFER_DURATION = 3600 * 2 -- 2 hours
REPEAT_DURATION = 3600 * 24 * 7 -- 7 days
MAX_REPEAT = 2
LOSE_SUMMS = { }
ANALYTICS_OFFER_NAME = "casino_case_fast_offer"

addEvent( "onAddCasinoGameLoseAmount" )
addEventHandler( "onAddCasinoGameLoseAmount", root, function( lose_amount )
    if not LOSE_SUMMS[ source ] then return end

    LOSE_SUMMS[ source ] = LOSE_SUMMS[ source ] + lose_amount

    if LOSE_SUMMS[ source ] < 100000 then return end

    local current_time = getRealTimestamp( )
    local data = source:GetPermanentData( DATA_NAME )

    if not data or ( data.counter < MAX_REPEAT and current_time > data.time_to + REPEAT_DURATION ) then
        LOSE_SUMMS[ source ] = nil

        data = {
            counter = ( counter or 0 ) + 1,
            time_to = current_time + OFFER_DURATION,
        }

        source:SetPermanentData( DATA_NAME, data )
        source:SetPrivateData( DATA_NAME, data )

        triggerClientEvent( source, "onPlayerShortOfferCasino", source )

        -- analytics
        SendElasticGameEvent( source:GetClientID( ), "fast_offer_show_first", {
            name = ANALYTICS_OFFER_NAME,
        } )
    end
end )

addEventHandler( "onPlayerQuit", root, function ( )
    LOSE_SUMMS[ source ] = nil
end )

addEventHandler( "onPlayerReadyToPlay", root, function( )
    local data = source:GetPermanentData( DATA_NAME )
    if data and data.time_to > getRealTimestamp( ) then
        source:SetPrivateData( DATA_NAME, data )
    elseif not data or data.counter < MAX_REPEAT then
        LOSE_SUMMS[ source ] = 0
    end
end, true, "low" )

addEvent( "onPlayerWantBuyOfferCasino", true )
addEventHandler( "onPlayerWantBuyOfferCasino", resourceRoot, function ( )
    if not client then return end

    local current_time = getRealTimestamp( )
    local data = client:GetPermanentData( DATA_NAME )
    if not data or data.time_to < current_time then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    if client:TakeDonate( PACK_PRICE, "sale", ANALYTICS_OFFER_NAME ) then
        local soft_v = 200000
        local coins_v = 5

        client:GiveMoney( soft_v, "sale", ANALYTICS_OFFER_NAME )
        client:GiveCoins( coins_v, "default", ANALYTICS_OFFER_NAME, "NRPDszx5x" )

        -- notification
        client:ShowSuccess( "Поздравляем с покупкой!" )

        -- reset
        data.time_to = current_time
        client:SetPermanentData( DATA_NAME, data )
        client:SetPrivateData( DATA_NAME, nil )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "fast_offer_purchase", {
            id = ANALYTICS_OFFER_NAME,
            cost = PACK_PRICE,
            currency = "hard",
            reward = toJSON( {
                { item_name = "soft", quantity = soft_v, cost = soft_v / 1000, currency = "hard" },
                { item_name = "coins_default", quantity = coins_v, cost = coins_v * 20, currency = "hard" },
            } ),
        } )
    else
        triggerClientEvent( client, "onShopNotEnoughHard", client, "Short offer" )
    end
end )