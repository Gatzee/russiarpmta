Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

OFFER_DURATION = 3600 * 2 -- 2 hours
ANALYTICS_OFFER_NAME = "rally_fast_offer"

function initOffer( player )
    local class = 1
    for i, vehicle in pairs( player:GetVehicles( false, false, true ) ) do
        local tier = vehicle:GetTier( )
        if tier > class then
            class = tier
        end
    end

    local data = {
        time_to = getRealTimestamp( ) + OFFER_DURATION,
        class = class,
    }

    player:SetPermanentData( DATA_NAME, data )
    player:SetPrivateData( DATA_NAME, data )

    triggerClientEvent( player, "onPlayerShortOfferRally", player )

    -- analytics
    SendElasticGameEvent( player:GetClientID( ), "fast_offer_show_first", {
        name = ANALYTICS_OFFER_NAME,
    } )
end

addEvent( "onPlayerEvacuateVehicle" )
addEventHandler( "onPlayerEvacuateVehicle", root, function ( )
    local data = source:GetPermanentData( DATA_NAME )
    if not data or not data.is_ready then
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

addEvent( "onPlayerWantBuyOfferRally", true )
addEventHandler( "onPlayerWantBuyOfferRally", resourceRoot, function ( )
    if not client then return end

    local data = client:GetPermanentData( DATA_NAME )
    if not data or data.time_to < getRealTimestamp( ) then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    local pack_price = PACK_PRICES[ data.class ].price
    if client:TakeDonate( pack_price, "sale", ANALYTICS_OFFER_NAME ) then
        local case_v = 2
        local tuning_case_v = 2

        client:GiveCase( "bronze", case_v )
        client:GiveTuningCase( 5, data.class, INTERNAL_PART_TYPE_F, tuning_case_v )

        -- notification
        client:ShowSuccess( "Поздравляем с покупкой!" )

        -- reset
        data = { time_to = 0 }
        client:SetPermanentData( DATA_NAME, data )
        client:SetPrivateData( DATA_NAME, nil )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "fast_offer_purchase", {
            id = ANALYTICS_OFFER_NAME,
            cost = pack_price,
            currency = "hard",
            reward = toJSON( {
                { item_name = "bronze_case", quantity = case_v, cost = case_v * 99, currency = "hard" },
                { item_name = "tuning_case", quantity = tuning_case_v, cost = tuning_case_v * data.class * 100 + 98, currency = "hard" },
            } ),
        } )
    else
        triggerClientEvent( client, "onShopNotEnoughHard", client, "Short offer" )
    end
end )