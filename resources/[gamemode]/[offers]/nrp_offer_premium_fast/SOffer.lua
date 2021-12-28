loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

DAYS_WAIT_IN_SECONDS = 3600 * 24 * 30 -- 30 days
OFFER_DURATION = 3600 * 3 -- 3 hours

addEventHandler( "onPlayerReadyToPlay", root, function ( )
    if not source:HasFinishedTutorial( ) then return end

    local data = source:GetPermanentData( "offer_premium_fast" ) or { }
    local timestamp = getRealTimestamp( )

    if ( data.time_to or 0 ) > timestamp then
        source:SetPrivateData( "offer_premium_fast", data )
        triggerClientEvent( source, "onPlayerOfferPremiumDaily", source ) -- show offer
    end
end, true, "low" )

addEvent( "onPlayerTakeDailyAwards", false )
addEventHandler( "onPlayerTakeDailyAwards", root, function ( )
    if source:IsPremiumActive( ) then
        source:SetPermanentData( "offer_premium_fast", nil )
        return
    end

    local data = source:GetPermanentData( "offer_premium_fast" )
    local timestamp = getRealTimestamp( )

    if not data then
        source:SetPermanentData( "offer_premium_fast", { start_time = timestamp + DAYS_WAIT_IN_SECONDS } )
    elseif data.start_time <= timestamp then
        local uniq_id = ( SERVER_NUMBER .. ":" .. source:GetID( ) .. ":" .. getRealTimestamp( ) .. ":" .. hash( "md5", math.random( 9999 ) ) ):sub( 1, 32 )

        data = {
            start_time = timestamp + DAYS_WAIT_IN_SECONDS,
            time_to = timestamp + OFFER_DURATION,
            uniq_id = uniq_id,
        }

        source:SetPermanentData( "offer_premium_fast", data )
        source:SetPrivateData( "offer_premium_fast", data )

        triggerClientEvent( source, "onPlayerOfferPremiumDaily", source )

        -- analytics
        SendElasticGameEvent( source:GetClientID( ), "faster_prem_offer_show", {
            id_sale = uniq_id,
        } )
    end
end )

addEvent( "onPlayerWantBuyPremiumViaOffer", true )
addEventHandler( "onPlayerWantBuyPremiumViaOffer", resourceRoot, function ( variant )
    if not client or not VARIANTS[ variant ] then return end

    local data = client:GetPermanentData( "offer_premium_fast" ) or { }

    if ( data.time_to or 0 ) < getRealTimestamp( ) then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    if not client:TakeDonate( VARIANTS[ variant ].price, "premium_offer", variant ) then
        triggerEvent( "onPlayerRequestDonateMenu", client, "donate" )
    else
        client:GivePremiumExpirationTime( VARIANTS[ variant ].days )
        client:ShowSuccess( "Вы получили " .. VARIANTS[ variant ].days .. " дн. премиума" )

        client:SetPermanentData( "offer_premium_fast", nil )
        client:SetPrivateData( "offer_premium_fast", nil )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "faster_prem_offer_purchase", {
            id_sale = data.uniq_id,
            prem_type = VARIANTS[ variant ].days .. "d",
            prem_cost = VARIANTS[ variant ].price,
            quantity = 1,
            spend_sum = VARIANTS[ variant ].price,
            currency = "hard",
        } )
    end
end )