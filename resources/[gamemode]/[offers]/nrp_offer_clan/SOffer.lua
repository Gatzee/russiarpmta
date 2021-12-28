Extend( "SPlayer" )

START_OFFER_DATE = 0
END_OFFER_DATE = 0

function initOffer( player )
    if not player:HasFinishedTutorial( ) then return end
    if player:GetLevel( ) < 6 or player:IsInClan( ) or player:IsInFaction( ) then return end

    local timestamp = getRealTimestamp( )
    if timestamp >= START_OFFER_DATE and timestamp <= END_OFFER_DATE then
        local data = {
            time_to = END_OFFER_DATE,
            new_price = CLAN_CREATION_COST / 2,
        }

        player:SetPrivateData( "offer_clan", data )
        triggerClientEvent( player, "onPlayerOfferClan", player )
    end
end

addEventHandler( "onPlayerReadyToPlay", root, function( )
    initOffer( source )
end, true, "low" )

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
    if key ~= "clan_offer" then return end

    if not value or next( value ) == nil then
        START_OFFER_DATE = 0
        END_OFFER_DATE = 0
    else
        START_OFFER_DATE = getTimestampFromString( value[ 1 ].start_date )
        END_OFFER_DATE = getTimestampFromString( value[ 1 ].finish_date )
    end
end )
--После запуска ресурса обновляем все даты
triggerEvent( "onSpecialDataRequest", getResourceRootElement( ), "clan_offer" )

if SERVER_NUMBER > 100 then
    addCommandHandler( "init_offer_clan", function( player )
        initOffer( player )
    end )
end