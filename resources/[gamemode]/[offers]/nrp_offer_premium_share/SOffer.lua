Extend( "SPlayer" )

START_OFFER_DATE = 0
END_OFFER_DATE = 0

function InitOffer( player )
    if not player:HasFinishedTutorial( ) then return end
    if not player:IsPremiumActive( ) then return end -- has not premium
    if getRealTimestamp( ) < START_OFFER_DATE or getRealTimestamp( ) > END_OFFER_DATE then return end

    local data = player:GetPermanentData( "offer_premium_share" )
    if not data or data.time_to ~= END_OFFER_DATE then
        local uniq_id = ( SERVER_NUMBER .. ":" .. player:GetID( ) .. ":" .. getRealTimestamp( ) .. ":" .. hash( "md5", math.random( 9999 ) ) ):sub( 1, 32 )

        player:SetPermanentData( "offer_premium_share", {
            time_to = END_OFFER_DATE,
            uniq_id = uniq_id,
        } )

        -- analytics
        SendElasticGameEvent( player:GetClientID( ), "premium_share_offer_show", {
            id_sale = uniq_id,
        } )
    end

    player:SetPrivateData( "offer_premium_share", {
        time_to = END_OFFER_DATE
    } )

    triggerClientEvent( player, "onPlayerOfferPremiumShare", player )
end

addEventHandler( "onPlayerReadyToPlay", root, function( )
    InitOffer( source )
end, true, "low" )

addEvent( "onPlayerWantBuyCasesViaOffer", true )
addEventHandler( "onPlayerWantBuyCasesViaOffer", resourceRoot, function ( variant, tier )
    if not client or not VARIANTS[ variant ] then return end

    if not client:IsPremiumActive( ) then
        client:ShowError( "Данная акция доступна только игрокам с премиум аккаунтом" )
        return
    end

    if END_OFFER_DATE < getRealTimestamp( ) then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    local data = client:GetPermanentData( "offer_premium_share" )
    local info = VARIANTS[ variant ]

    if not info.prices[ tier ] or not data then return end -- bad data

    local price = info.prices[ tier ].new

    if not client:TakeDonate( price, "premium_offer", variant ) then
        triggerEvent( "onPlayerRequestDonateMenu", client, "donate" )
    else
        client:ShowSuccess( "Вы успешно приобрели кейсы.\nОтправляйтесь в тюнинг-ателье" )

        client:GiveTuningCase( info.tuning_case_id, tier, 1, info.amount[ 1 ] ) -- type? now is "R"
        client:GiveVinylCase( info.vinyl_cases_ids[ tier ], info.amount[ 2 ] )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "premium_share_offer_purchase", {
            id_sale = data.uniq_id,
            vehicle_class = tostring( VEHICLE_CLASSES_NAMES[ tier ] ),
            pack_name = info.en_name,
            pack_cost = price,
            quantity = 1,
            spend_sum = price,
            currency = "hard",
        } )
    end
end )

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
    if key ~= "premium_share_offer" then return end

    if not value or next( value ) == nil then
        START_OFFER_DATE = 0
        END_OFFER_DATE = 0
    else
        START_OFFER_DATE = getTimestampFromString( value[ 1 ].start_date )
        END_OFFER_DATE = getTimestampFromString( value[ 1 ].finish_date )
    end
end )
--После запуска ресурса обновляем все даты
triggerEvent( "onSpecialDataRequest", resourceRoot, "premium_share_offer" )

if SERVER_NUMBER > 100 then
    addCommandHandler( "init_premium_share_offer", function( player )
        InitOffer( player )
    end )
end