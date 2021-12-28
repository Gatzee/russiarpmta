loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

DAYS_WAIT_IN_SECONDS = 3600 * 24 * 3 -- 3 days
OFFER_DURATION = 3600 * 2 -- 2 hours

function GiveOffer( player, duration )
    local uniq_id = ( SERVER_NUMBER .. ":" .. player:GetID( ) .. ":" .. getRealTimestamp( ) .. ":" .. hash( "md5", math.random( 9999 ) ) ):sub( 1, 32 )

    local data = {
        start_time = getRealTimestamp( ) + ( duration or DAYS_WAIT_IN_SECONDS ),
        uniq_id = uniq_id,
        is_forced = duration and true,
    }
    player:SetPermanentData( "offer_premium_3d", data )
    player:SetPrivateData( "offer_premium_3d", data )

    player:GivePremiumExpirationTime( duration and ( duration / 24 / 60 / 60 ) or 3 ) -- give free premium
    triggerClientEvent( player, "onPlayerOfferPremium3DStart", resourceRoot ) -- send notification to player

    -- analytics
    SendElasticGameEvent( player:GetClientID( ), "3d_prem_give_offer_take", {
        id_sale = uniq_id,
    } )
end

addEventHandler( "onPlayerReadyToPlay", root, function ( )
    if not source:HasFinishedTutorial( ) then return end

    local data = source:GetPermanentData( "offer_premium_3d" )
    if not data or not data.is_forced then
        if ( source:GetPermanentData( "premium_transactions" ) or 0 ) > 0 then -- bought premium in past
            source:SetPermanentData( "offer_premium_3d", nil )
            return
        end
    end

    local don_counter = source:GetPermanentData( "donate_transactions" ) or 0
    local timestamp = getRealTimestamp( )

    if not data and don_counter == 3 then
        GiveOffer( source )
    elseif data and not data.time_to and data.start_time < timestamp then
        data.time_to = timestamp + OFFER_DURATION

        source:SetPermanentData( "offer_premium_3d", data )
        source:SetPrivateData( "offer_premium_3d", data )

        triggerClientEvent( source, "onPlayerOfferPremium3D", source )

        -- analytics
        SendElasticGameEvent( source:GetClientID( ), "3d_prem_give_offer_show", {
            id_sale = data.uniq_id,
        } )
    elseif data and data.time_to and data.time_to > timestamp then
        source:SetPrivateData( "offer_premium_3d", data )
        triggerClientEvent( source, "onPlayerOfferPremium3D", source )
    end
end, true, "low" )

addEvent( "onPlayerWantBuyPremiumViaOffer", true )
addEventHandler( "onPlayerWantBuyPremiumViaOffer", resourceRoot, function ( variant )
    if not client or not VARIANTS[ variant ] then return end

    local data = client:GetPermanentData( "offer_premium_3d" ) or { }

    if ( data.time_to or 0 ) < getRealTimestamp( ) then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    if not client:TakeDonate( VARIANTS[ variant ].price, "premium_offer", variant ) then
        triggerEvent( "onPlayerRequestDonateMenu", client, "donate" )
    else
        client:GivePremiumExpirationTime( VARIANTS[ variant ].days )
        client:ShowSuccess( "Вы получили " .. VARIANTS[ variant ].days .. " дн. премиума" )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "3d_prem_give_offer_purchase", {
            id_sale = data.uniq_id,
            prem_type = VARIANTS[ variant ].days .. "d",
            prem_cost = VARIANTS[ variant ].price,
            quantity = 1,
            spend_sum = VARIANTS[ variant ].price,
            currency = "hard",
        } )

        -- reset offer
        data = { }
        data.time_to = 0

        client:SetPermanentData( "offer_premium_3d", data )
        client:SetPrivateData( "offer_premium_3d", data )
    end
end )