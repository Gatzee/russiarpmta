Extend( "SPlayer" )
Extend( "SVehicle" )

OFFER_DURATION = 3600 * 2 -- 2 hours
ANALYTICS_OFFER_NAME = "second_wheels_fast_offer"

function initOffer( player )
    local data = player:GetPermanentData( DATA_NAME )
    data.time_to = getRealTimestamp( ) + OFFER_DURATION

    player:SetPermanentData( DATA_NAME, data )
    player:SetPrivateData( DATA_NAME, data )

    triggerClientEvent( player, "onPlayerShortOfferSV", player )

    -- analytics
    SendElasticGameEvent( player:GetClientID( ), "fast_offer_show_first", {
        name = ANALYTICS_OFFER_NAME,
    } )
end

addEvent( "onPlayerGotNewVehicle" )
addEventHandler( "onPlayerGotNewVehicle", root, function( vehicle )
    local data = source:GetPermanentData( DATA_NAME )
    if data then
        return
    end

    local counter = 0
    for i, veh in pairs( source:GetVehicles( false, true, true ) ) do
        if not veh:GetPermanentData( "temp_timeout" ) then
            counter = counter + 1
        end
    end

    if counter == 2 then
        local class = vehicle:GetTier( )
        if not PACK_PRICES[ class ] then return end

        data = {
            model = vehicle.model,
            class = class,
        }
        source:SetPermanentData( DATA_NAME, data )

        if source:StartShortOffer( DATA_NAME ) then
            initOffer( source )
        end
    elseif counter > 2 then
        data = { time_to = 0 }
        source:SetPermanentData( DATA_NAME, data )
    end
end )

addEventHandler( "onPlayerReadyToPlay", root, function( )
    if source:LoadShortOffer( DATA_NAME ) then
        initOffer( source )
    end
end, true, "low" )

addEvent( "onPlayerWantBuyCasesSV", true )
addEventHandler( "onPlayerWantBuyCasesSV", resourceRoot, function ( )
    if not client then return end

    local data = client:GetPermanentData( DATA_NAME )
    if not data or data.time_to < getRealTimestamp( ) then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    local pack_price = PACK_PRICES[ data.class ].price
    if client:TakeDonate( pack_price, "sale", ANALYTICS_OFFER_NAME ) then
        local soft_v = 100000
        local repair_box_v = 2
        local tuning_case_v = 1

        client:GiveMoney( soft_v, "sale", ANALYTICS_OFFER_NAME )
        client:InventoryAddItem( IN_REPAIRBOX, nil, repair_box_v )
        client:GiveTuningCase( 5, data.class, INTERNAL_PART_TYPE_R, tuning_case_v )

        -- notification
        client:ShowSuccess( "Поздравляем с покупкой! Кейс можно открыть в тюнинг-ателье" )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "fast_offer_purchase", {
            id = ANALYTICS_OFFER_NAME,
            cost = pack_price,
            currency = "hard",
            reward = toJSON( {
                { item_name = "soft", quantity = soft_v, cost = soft_v / 1000, currency = "hard" },
                { item_name = "repairbox", quantity = repair_box_v, cost = 25 * repair_box_v, currency = "hard" },
                {
                    item_name = "tuning_case",
                    quantity = tuning_case_v,
                    cost = ( data.class == 6 and 3 or data.class ) * 100 + 49,
                    currency = "hard"
                },
            } ),
        } )

        -- reset
        data = { time_to = 0 }
        client:SetPermanentData( DATA_NAME, data )
        client:SetPrivateData( DATA_NAME, nil )
    else
        triggerClientEvent( client, "onShopNotEnoughHard", client, "Short offer" )
    end
end )