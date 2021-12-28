Extend( "SPlayer" )

OFFER_DURATION = 3600 * 2 -- 2 hours
ANALYTICS_OFFER_NAME = "clan_recruit_fast_offer"

function initOffer( player )
    local data = {
        time_to = getRealTimestamp( ) + OFFER_DURATION,
    }

    player:SetPermanentData( DATA_NAME, data )
    player:SetPrivateData( DATA_NAME, data )

    triggerClientEvent( player, "onPlayerShortOfferClan", player )

    -- analytics
    SendElasticGameEvent( player:GetClientID( ), "fast_offer_show_first", {
        name = ANALYTICS_OFFER_NAME,
    } )
end

addEvent( "onPlayerClanRankReached" )
addEventHandler( "onPlayerClanRankReached", root, function( rank )
    if rank ~= 2 then
        return
    end

    local data = source:GetPermanentData( DATA_NAME )
    if data then
        return
    end

    if source:StartShortOffer( DATA_NAME ) then
        initOffer( source )
    end
end )

addEventHandler( "onPlayerReadyToPlay", root, function( )
    if source:LoadShortOffer( DATA_NAME ) then
        initOffer( source )
    end
end, true, "low" )

addEvent( "onPlayerWantBuyOfferClan", true )
addEventHandler( "onPlayerWantBuyOfferClan", resourceRoot, function ( )
    if not client then return end

    local data = client:GetPermanentData( DATA_NAME )
    if not data or data.time_to < getRealTimestamp( ) then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    if client:TakeDonate( PACK_PRICE, "sale", ANALYTICS_OFFER_NAME ) then
        local soft_v = 100000
        local premium_v = 30

        client:GiveMoney( soft_v, "sale", ANALYTICS_OFFER_NAME )
        client:GivePremiumExpirationTime( premium_v )
        triggerEvent( "onPlayerWantAddClanMoney", client, soft_v )

        -- notification
        client:ShowSuccess( "Поздравляем с покупкой!" )

        -- reset
        data = { time_to = 0 }
        client:SetPermanentData( DATA_NAME, data )
        client:SetPrivateData( DATA_NAME, nil )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "fast_offer_purchase", {
            id = ANALYTICS_OFFER_NAME,
            cost = PACK_PRICE,
            currency = "hard",
            reward = toJSON( {
                { item_name = "soft", quantity = soft_v, cost = soft_v / 1000, currency = "hard" },
                { item_name = "premium", quantity = premium_v, cost = 999, currency = "hard" },
            } ),
        } )
    else
        triggerClientEvent( client, "onShopNotEnoughHard", client, "Short offer" )
    end
end )