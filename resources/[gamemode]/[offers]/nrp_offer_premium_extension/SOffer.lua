loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

DAYS_WAIT_IN_SECONDS = 3600 * 24 * 2 -- 2 days
OFFER_DURATION = 3600 * 24 -- 24 hours
REPEAT_COUNTER = 2

addEventHandler( "onPlayerReadyToPlay", root, function ( )
    if not source:HasFinishedTutorial( ) then return end

    local premium_last_duration = source:GetPermanentData( "premium_last_duration" )
    if not premium_last_duration then return end -- not bought premium in past

    local timestamp = getRealTimestamp( )
    local last_pay = source:GetPermanentData( "premium_last_date" )
    local data = source:GetPermanentData( "offer_premium_extension" )

    if timestamp > ( source:GetPermanentData( "premium_time_left" ) or 0 ) + DAYS_WAIT_IN_SECONDS then
        if not data or ( data.num < REPEAT_COUNTER and data.last_pay ~= last_pay ) then
            local uniq_id = ( SERVER_NUMBER .. ":" .. source:GetID( ) .. ":" .. getRealTimestamp( ) .. ":" .. hash( "md5", math.random( 9999 ) ) ):sub( 1, 32 )

            data = {
                uniq_id = uniq_id,
                last_pay = last_pay,
                num = data and data.num or 1,
                time_to = timestamp + OFFER_DURATION,
                duration = premium_last_duration,
            }

            source:SetPermanentData( "offer_premium_extension", data )
            source:SetPrivateData( "offer_premium_extension", data )

            triggerClientEvent( source, "onPlayerOfferPremiumExtension", source )

            -- analytics
            SendElasticGameEvent( source:GetClientID( ), "extension48_prem_offer_show", {
                id_sale = uniq_id,
            } )
        elseif data and data.time_to > timestamp then
            source:SetPrivateData( "offer_premium_extension", data )

            triggerClientEvent( source, "onPlayerOfferPremiumExtension", source )
        end
    end
end )

addEvent( "onPlayerWantBuyPremiumViaOffer", true )
addEventHandler( "onPlayerWantBuyPremiumViaOffer", resourceRoot, function ( )
    if not client then return end

    local data = client:GetPermanentData( "offer_premium_extension" ) or { }

    if ( data.time_to or 0 ) < getRealTimestamp( ) then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    local info = VARIANTS[ data.duration ]

    if not client:TakeDonate( info.price, "premium_offer", info.variant ) then
        triggerEvent( "onPlayerRequestDonateMenu", client, "donate" )
    else
        client:GivePremiumExpirationTime( data.duration )
        client:ShowSuccess( "Вы получили " .. data.duration .. " дн. премиума" )

        data.time_to = 0 -- reset offer

        client:SetPermanentData( "offer_premium_extension", data )
        client:SetPrivateData( "offer_premium_extension", data )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "extension48_prem_offer_purchase", {
            id_sale = data.uniq_id,
            prem_type = data.duration .. "d",
            prem_cost = info.price,
            quantity = 1,
            spend_sum = info.price,
            currency = "hard",
        } )
    end
end )