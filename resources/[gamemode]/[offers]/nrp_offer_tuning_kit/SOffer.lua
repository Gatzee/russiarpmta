Extend( "SPlayer" )
Extend( "ShVehicle" )

START_OFFER_DATE = 0
END_OFFER_DATE = 0

function initOfferViaVehicleEnter( )
    if source.dimension ~= 0 then
        return
    end

    initOffer( source )
end

function initOffer( player )
    removeEventHandler( "onPlayerVehicleEnter", player, initOfferViaVehicleEnter )

    local current_time = getRealTimestamp( )
    if current_time < START_OFFER_DATE or current_time > END_OFFER_DATE then
        return
    end

    local vehicle = player.vehicle
    if not player:HasFinishedTutorial( ) or not vehicle or vehicle:GetOwnerID( ) ~= player:GetID( ) or not isAvailableModel( vehicle.model ) then
        addEventHandler( "onPlayerVehicleEnter", player, initOfferViaVehicleEnter )
        return
    end

    local data = player:GetPermanentData( DATA_NAME ) or { }
    if data.time_to ~= END_OFFER_DATE then
        player:SetPermanentData( DATA_NAME, {
            time_to = END_OFFER_DATE,
        } )

        -- analytics
        SendElasticGameEvent( player:GetClientID( ), "tuning_kit_show_first" )
    end

    player:SetPrivateData( DATA_NAME, {
        time_to = END_OFFER_DATE
    } )

    triggerClientEvent( player, "onPlayerOfferTuningKit", player, vehicle )
end

addEventHandler( "onPlayerReadyToPlay", root, function ( )
    initOffer( source )
end, true, "low" )

addEvent( "onPlayerWantBuyTuningKit", true )
addEventHandler( "onPlayerWantBuyTuningKit", root, function ( pack_id, tier, subtype )
    if not client then
        return
    end

    -- check subtype
    subtype = tonumber( subtype ) or 0
    if not INTERNAL_PARTS_NAMES_TYPES[ subtype ] then
        return
    end

    -- check pack_id
    pack_id = tonumber( pack_id ) or 0
    local data = PACKS[ pack_id ]
    if not data then
        return
    end

    -- check tier
    tier = tonumber( tier ) or 0
    local prices = data.price_by_class[ tier ]
    if not prices then
        return
    end

    -- check offer's time
    local current_time = getRealTimestamp( )
    if current_time < START_OFFER_DATE or current_time > END_OFFER_DATE then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    if tier == 6 and subtype ~= INTERNAL_PART_TYPE_R then
        return
    end

    -- function of give pack
    local function givePack( )
        local items = { }

        for idx, v in pairs( data.vinyl_cases_list or { } ) do
            local vinyl_case_id = VINYL_CASE_TIERS_STR_CONVERT[ "VINYL_CASE_" .. v.id .. "_" .. tier ]
            local case = exports.nrp_tuning_cases:GetVinylCases( )[ vinyl_case_id ] or { }

            table.insert( items, {
                item_name = v.name or "",
                item_count = v.amount or 1,
                item_cost = case.cost or 0,
                item_currency = case.cost_is_soft and "soft" or "hard",
            } )

            client:GiveVinylCase( vinyl_case_id, v.amount or 1 )
        end

        for idx, v in pairs( data.tuning_cases_list or { } ) do
            local case_cost, is_soft = exports.nrp_tuning_cases:getCaseCost( v.id, tier )

            table.insert( items, {
                item_name = v.name or "",
                item_count = v.amount or 1,
                item_cost = case_cost or 0,
                item_currency = is_soft and "soft" or "hard",
            } )

            client:GiveTuningCase( v.id, tier, subtype, v.amount or 1 )
        end

        -- notification
        client:ShowSuccess( "Поздравляем с покупкой! Кейсы могут быть открыты в любом тюнинг-ателье" )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "tuning_kit_purchase", {
            id = pack_id,
            name = data.name,
            cost = prices.new_price,
            currency = prices.is_hard and "hard" or "soft",
            true_cost = prices.old_price,
            items = toJSON( items ),
        } )
    end

    -- try buy
    if prices.is_hard then
        if client:TakeDonate( prices.new_price, "sale", "tuning_kit" ) then
            givePack( )
        else
            triggerClientEvent( client, "onShopNotEnoughHard", client, "Offer tuning kit", "onPlayerWantBuyTuningKit", client, pack_id, tier, subtype )
        end
    else
        if client:TakeMoney( prices.new_price, "sale", "tuning_kit" ) then
            givePack( )
        else
            client:EnoughMoneyOffer( "Offer tuning kit", prices.new_price, "onPlayerWantBuyTuningKit", client, pack_id, tier, subtype )
        end
    end
end )

addEventHandler( "onSpecialDataUpdate", root, function ( key, value )
    if key ~= "offer_tuning_kit" then
        return
    end

    if not value or next( value ) == nil then
        START_OFFER_DATE = 0
        END_OFFER_DATE = 0
    else
        START_OFFER_DATE = getTimestampFromString( value[ 1 ].start_date )
        END_OFFER_DATE = getTimestampFromString( value[ 1 ].finish_date )
    end
end )
--После запуска ресурса обновляем все даты
triggerEvent( "onSpecialDataRequest", resourceRoot, "offer_tuning_kit" )