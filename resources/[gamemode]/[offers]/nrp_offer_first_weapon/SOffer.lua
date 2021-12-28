Extend( "SPlayer" )

START_OFFER_DATE = 0
END_OFFER_DATE = 0
OFFER_DURATION = 3600 * 48 -- 48 hours

function initOffer( player )
    if not player:HasFinishedTutorial( ) then return end

    local data = player:GetPermanentData( "offer_first_weapon" )
    if ( data and data.passed ) or player:GetClanID( ) then return end
    local timestamp = getRealTimestamp( )

    if ( not data or data.time_to ~= timestamp ) and timestamp >= START_OFFER_DATE and timestamp < END_OFFER_DATE then
        if player:GetSocialRating( ) <= 0 or player:GetLevel( ) < 6 or player:InventoryGetItemCount( IN_WEAPON ) > 0 then
            return
        end

        data = {
            passed = false,
            time_to = timestamp + OFFER_DURATION,
        }

        player:SetPrivateData( "offer_first_weapon", data )
        player:SetPermanentData( "offer_first_weapon", data )

        -- show offer
        triggerClientEvent( player, "onPlayerOfferFirstWeapon", player )

        -- analytics
        SendElasticGameEvent( player:GetClientID( ), "first_weapon_offer_show_first" )
    elseif data and data.time_to > timestamp then
        player:SetPrivateData( "offer_first_weapon", data )

        -- show offer
        triggerClientEvent( player, "onPlayerOfferFirstWeapon", player )
    end
end

addEventHandler( "onPlayerReadyToPlay", root, function ( )
    initOffer( source )
end )

addEvent( "onPlayerWantBuyFirstWeaponViaOffer", true )
addEventHandler( "onPlayerWantBuyFirstWeaponViaOffer", resourceRoot, function ( variant )
    variant = tonumber( variant ) or 0

    if not client or not OFFERS_PACK[ variant ] then return end -- if has got bad data

    local data = client:GetPermanentData( "offer_first_weapon" ) or { }
    local timestamp = getRealTimestamp( )

    if ( data.time_to or 0 ) < timestamp or data.passed then
        client:ShowError( "Время действия предложения закончилось" )
        return
    end

    local pack = OFFERS_PACK[ variant ]
    local price = math.ceil( ( 100 - pack.discount ) / 100 * pack.price )

    if not client:TakeDonate( price, "first_weapon_offer", pack.id ) then
        triggerEvent( "onPlayerRequestDonateMenu", client, "donate" )
    else
        local licenses = client:GetPermanentData( "gun_licenses" ) or { }
        timestamp = ( licenses.expires or 0 ) - timestamp > 0 and licenses.expires or timestamp
        licenses.expires = timestamp + pack.licenses_days * 24 * 3600

        client:SetPermanentData( "gun_licenses", licenses )
        client:SetPrivateData( "gun_licenses", licenses.expires )

        client:InventoryAddItem( pack.armor_id, nil, 1 )
        client:InventoryAddItem( IN_WEAPON, { pack.weapon_data.id, pack.weapon_data.ammo }, 1 )

        client:ShowSuccess( "Вы успешно приобрели набор" )

        -- analytics
        SendElasticGameEvent( client:GetClientID( ), "first_weapon_offer_purchase", {
            id = pack.id,
            name = pack.name,
            cost = price,
            currency = "hard",
            quantity = 1,
            spend_sum = price,
        } )

        -- reset offer
        data.passed = true
        data.time_to = nil

        client:SetPrivateData( "offer_first_weapon", data )
        client:SetPermanentData( "offer_first_weapon", data )
    end
end )

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
    if key ~= "first_weapon_offer" then return end

    if not value or next( value ) == nil then
        START_OFFER_DATE = 0
        END_OFFER_DATE = 0
    else
        START_OFFER_DATE = getTimestampFromString( value[ 1 ].start_date )
        END_OFFER_DATE = getTimestampFromString( value[ 1 ].finish_date )
    end
end )
triggerEvent( "onSpecialDataRequest", getResourceRootElement( ), "first_weapon_offer" )

if SERVER_NUMBER > 100 then
    addCommandHandler( "init_offer_first_weapon", function( player )
        initOffer( player )
    end )

    addCommandHandler( "reset_offer_first_weapon", function( player )
        player:SetPrivateData( "offer_first_weapon", nil )
        player:SetPermanentData( "offer_first_weapon", nil )
    end )
end