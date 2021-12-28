Extend( "SPlayer" )
Extend( "SVehicle" )

OFFER_DURATION = 3600 * 2 -- 2 hours
ANALYTICS_OFFER_NAME = "first_moto_fast_offer"

function initOffer( player )
    local data = player:GetPermanentData( DATA_NAME )
    data.time_to = getRealTimestamp( ) + OFFER_DURATION

    player:SetPermanentData( DATA_NAME, data )
    player:SetPrivateData( DATA_NAME, data )

    triggerClientEvent( player, "onPlayerShortOfferFM", player )

    -- analytics
    SendElasticGameEvent( player:GetClientID( ), "fast_offer_show_first", {
        name = ANALYTICS_OFFER_NAME,
    } )
end

addEvent( "onPlayerGotNewVehicle" )
addEventHandler( "onPlayerGotNewVehicle", root, function( vehicle )
    local data = source:GetPermanentData( DATA_NAME )
    if data or not VEHICLE_CONFIG[ vehicle.model ].is_moto
    or vehicle.model == 468 then
        return
    end

    for i, veh in pairs( source:GetMotorbikes( true ) ) do
        if not veh:GetPermanentData( "temp_timeout" ) and vehicle ~= veh then
            data = { time_to = 0 }
            source:SetPermanentData( DATA_NAME, data )
            return
        end
    end

    data = { model = vehicle.model }
    source:SetPermanentData( DATA_NAME, data )

    if source:StartShortOffer( DATA_NAME ) then
        initOffer( source )
    end
end )

addEventHandler( "onPlayerReadyToPlay", root, function( )
    if source:LoadShortOffer( DATA_NAME ) then
        initOffer( source )
    end
end, true, "low" )

addEvent( "onPlayerWantBuyCasesFM", true )
addEventHandler( "onPlayerWantBuyCasesFM", resourceRoot, function ( )
    if not client then return end

    local data = client:GetPermanentData( DATA_NAME )
    if not data or data.time_to < getRealTimestamp( ) then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    if client:TakeDonate( PACK_PRICE, "sale", ANALYTICS_OFFER_NAME ) then
        local vinyl_case_v = 2
        local tuning_case_v = 3

        client:GiveVinylCase( VINYL_CASE_TIERS_STR_CONVERT[ "VINYL_CASE_1_6" ], vinyl_case_v )
        client:GiveTuningCase( 4, 6, INTERNAL_PART_TYPE_R, tuning_case_v )

        -- notification
        client:ShowSuccess( "Поздравляем с покупкой! Кейсы могут быть открыты в любом тюнинг-ателье" )

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
                { item_name = "vinyl_case", quantity = vinyl_case_v, cost = 807, currency = "hard" },
                { item_name = "tuning_case", quantity = tuning_case_v, cost = 298, currency = "hard" },
            } ),
        } )
    else
        triggerClientEvent( client, "onShopNotEnoughHard", client, "Short offer" )
    end
end )