Extend( "SPlayer" )
Extend( "ShVinyls" )

START_OFFER_DATE = 0
END_OFFER_DATE = 0
OFFER_DURATION = 3600 * 48 -- 48 hours

addEventHandler( "onPlayerReadyToPlay", root, function ( )
    if not source:HasFinishedTutorial( ) then return end

    if ( source:GetPermanentData( "premium_transactions" ) or 0 ) > 0 then -- bought premium in past
        source:SetPermanentData( "offer_premium_np", nil )
        return
    end

    local timestamp = getRealTimestamp( )
    local data = source:GetPermanentData( "offer_premium_np" )

    if timestamp >= START_OFFER_DATE and timestamp < END_OFFER_DATE then
        if not data then
            local uniq_id = ( SERVER_NUMBER .. ":" .. source:GetID( ) .. ":" .. getRealTimestamp( ) .. ":" .. hash( "md5", math.random( 9999 ) ) ):sub( 1, 32 )

            data = {
                variant = 2,
                time_to = timestamp + OFFER_DURATION,
                uniq_id = uniq_id,
            }

            if ( source:GetPermanentData( "donate_transactions" ) or 0 ) > 0 then
                data.variant = 1
            end

            source:SetPermanentData( "offer_premium_np", data )
            source:SetPrivateData( "offer_premium_np", data )

            triggerClientEvent( source, "onPlayerOfferPremiumNopurchase", source )

            -- analytics
            SendElasticGameEvent( source:GetClientID( ), "prem_nopurchase_offer_show", {
                id_sale = uniq_id,
            } )
        elseif data.time_to > timestamp then
            source:SetPrivateData( "offer_premium_np", data )
            triggerClientEvent( source, "onPlayerOfferPremiumNopurchase", source )
        end
    end
end, true, "low" )

addEvent( "onPlayerWantBuyFirstPremium", true )
addEventHandler( "onPlayerWantBuyFirstPremium", resourceRoot, function ( pack_id, tier )
    if not client then return end

    local data = client:GetPermanentData( "offer_premium_np" ) or { }

    if ( data.time_to or 0 ) < getRealTimestamp( ) or not tonumber( data.variant ) then
        client:ShowError( "Время действия акции закончилось" )
        return
    end

    if not VARIANTS[ data.variant ] or not VARIANTS[ data.variant ][ pack_id ] then
        return
    end

    local pack_data = VARIANTS[ data.variant ][ pack_id ]

    if not client:TakeDonate( pack_data.price, "premium_offer", pack_id ) then
        triggerEvent( "onPlayerRequestDonateMenu", client, "donate" )
    else
        if pack_data.free_evacuation then
            client:GiveFreeEvacuation( pack_data.free_evacuation )
        end

        if pack_data.vinyl_id then
            client:GiveVinyl( {
                [ P_PRICE_TYPE ] = "hard",
                [ P_IMAGE ]      = "s" .. pack_data.vinyl_id,
                [ P_CLASS ]      = tier,
                [ P_NAME ]       = VINYL_NAMES[ "s" .. pack_data.vinyl_id ],
                [ P_PRICE ]      = 0,
            } )
        end

        if pack_data.accessory_id then
            client:AddOwnedAccessory( pack_data.accessory_id )
        end

        iprint( pack_data.items, "<<<" )
        for idx, item in pairs( pack_data.items or { } ) do
            iprint( item.id, item.count, "<<<" )
            client:InventoryAddItem( item.id, nil, item.count )
        end

        client:GivePremiumExpirationTime( pack_data.premium_days )
        client:ShowSuccess( "Вы получили пакет, включающий в себя " .. pack_data.premium_days .. " дн. премиума" )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "prem_nopurchase_offer_purcahse", {
            id_sale = data.uniq_id,
            pack_name = pack_data.name,
            prem_pack_cost = pack_data.price,
            quantity = 1,
            spend_sum = pack_data.price,
            currency = "hard",
        } )

        -- reset offer
        data = { }
        data.time_to = 0

        client:SetPermanentData( "offer_premium_np", data )
        client:SetPrivateData( "offer_premium_np", data )
    end
end )

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
    if key ~= "premium_nopurchase_offer" then return end

    if not value or next( value ) == nil then
        START_OFFER_DATE = 0
        END_OFFER_DATE = 0
    else
        START_OFFER_DATE = getTimestampFromString( value[ 1 ].start_date )
        END_OFFER_DATE = getTimestampFromString( value[ 1 ].finish_date )
    end
end )
--После запуска ресурса обновляем все даты
triggerEvent( "onSpecialDataRequest", getResourceRootElement( ), "premium_nopurchase_offer" )