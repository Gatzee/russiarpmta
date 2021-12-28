Extend( "SPlayer" )

OFFER_DURATION = 3600 * 2 -- 2 hours
MIN_SHIFT_TIME = 3600 -- 1 hour
ANALYTICS_OFFER_NAME = "vacation_time_fast_offer"

function initOffer( player )
    local data = {
        getRealTimestamp( ) + OFFER_DURATION,
    }

    player:SetPermanentData( DATA_NAME, data )
    player:SetPrivateData( DATA_NAME, data )

    triggerClientEvent( player, "onPlayerShortOfferVacationTime", player )

    -- analytics
    SendElasticGameEvent( player:GetClientID( ), "fast_offer_show_first", {
        name = ANALYTICS_OFFER_NAME,
    } )
end

addEvent( "PlayerAction_EndJobShift" )
addEventHandler( "PlayerAction_EndJobShift", root, function( time_passed )
    if ( time_passed or 0 ) < MIN_SHIFT_TIME then
        return
    end

    local data = source:GetPermanentData( DATA_NAME ) or { }
    if data.time_to or data.time_from then
        return
    end

    data.shifts_counter = ( data.shifts_counter or 0 ) + 1
    if data.shifts_counter >= 50 then
        if source:StartShortOffer( DATA_NAME ) then
            initOffer( source )
        end
    else
        source:SetPermanentData( DATA_NAME, data )
    end
end )

addEventHandler( "onPlayerReadyToPlay", root, function( )
    if source:LoadShortOffer( DATA_NAME ) then
        initOffer( source )
    end
end, true, "low" )

addEvent( "onPlayerWantBuyOfferVacationTime", true )
addEventHandler( "onPlayerWantBuyOfferVacationTime", resourceRoot, function ( )
    if not client then return end

    local data = client:GetPermanentData( DATA_NAME )
    if not data or data.time_to < getRealTimestamp( ) then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    if client:TakeDonate( PACK_PRICE, "sale", ANALYTICS_OFFER_NAME ) then
        local soft_v = 100000
        local case_v = 1
        local premium_v = 3

        client:GiveMoney( soft_v, "sale", ANALYTICS_OFFER_NAME )
        client:GiveCase( "bronze", case_v )
        client:GivePremiumExpirationTime( premium_v )

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
                { item_name = "bronze_case", quantity = case_v, cost = case_v * 99, currency = "hard" },
                { item_name = "premium", quantity = premium_v, cost = 299, currency = "hard" },
            } ),
        } )
    else
        triggerClientEvent( client, "onShopNotEnoughHard", client, "Short offer" )
    end
end )