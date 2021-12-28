Extend( "SPlayer" )

OFFER_DURATION = 3600 * 2 -- 2 hours
ANALYTICS_OFFER_NAME = "first_house_fast_offer"

function initOffer( player )
    local data = {
        time_to = getRealTimestamp( ) + OFFER_DURATION,
    }

    player:SetPermanentData( DATA_NAME, data )
    player:SetPrivateData( DATA_NAME, data )

    triggerClientEvent( player, "onPlayerShortOfferFH", player )

    -- analytics
    SendElasticGameEvent( player:GetClientID( ), "fast_offer_show_first", {
        name = ANALYTICS_OFFER_NAME,
    } )
end

addEvent( "onPlayerHousePurchase" )
addEventHandler( "onPlayerHousePurchase", root, function( )
    local data = source:GetPermanentData( DATA_NAME )
    if data then
        return
    end

    local apartments = source:getData( "apartments" ) or { }
    local viphouse = source:getData( "viphouse" ) or { }

    if ( #apartments == 1 and not next( viphouse ) ) or ( #viphouse == 1 and not next( apartments ) ) then
        if source:StartShortOffer( DATA_NAME ) then
            initOffer( source )
        end
    end
end )

addEventHandler( "onPlayerReadyToPlay", root, function( )
    if source:LoadShortOffer( DATA_NAME ) then
        initOffer( source )
    end
end, true, "low" )

addEvent( "onPlayerWantBuyOfferFH", true )
addEventHandler( "onPlayerWantBuyOfferFH", resourceRoot, function ( )
    if not client then return end

    local data = client:GetPermanentData( DATA_NAME )
    if not data or data.time_to < getRealTimestamp( ) then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    local conf = PACKS[ client:GetGender( ) ]

    if client:TakeDonate( conf.price, "sale", ANALYTICS_OFFER_NAME ) then
        local soft_v = 100000

        client:GiveSkin( conf.skin_id  )
        client:GiveMoney( soft_v, "sale", ANALYTICS_OFFER_NAME )

        -- notification
        client:ShowSuccess( "Поздравляем с покупкой!" )

        -- reset
        data = { time_to = 0 }
        client:SetPermanentData( DATA_NAME, data )
        client:SetPrivateData( DATA_NAME, nil )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "fast_offer_purchase", {
            id = ANALYTICS_OFFER_NAME,
            cost = conf.price,
            currency = "hard",
            reward = toJSON( {
                { item_name = "soft", quantity = soft_v, cost = soft_v / 1000, currency = "hard" },
                { item_name = "skin", quantity = 1, cost = conf.skin_cost, currency = "hard" },
            } ),
        } )
    else
        triggerClientEvent( client, "onShopNotEnoughHard", client, "Short offer" )
    end
end )