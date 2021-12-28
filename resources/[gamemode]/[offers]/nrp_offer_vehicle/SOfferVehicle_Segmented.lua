local CONST_OFFER_TIME_SEC = 48 * 3600
local CONST_MAX_PRE_OFFER_TIME_PLAY_SEC = 80 * 3600

function TrySegmentedPlayer( player )
    local player = source or player

    local offer_vehicle_passed = player:GetPermanentData( "offer_vehicle_passed" )
    if offer_vehicle_passed then
        return
    end

    local timestamp = getRealTimestamp( )
    if timestamp - player:GetPermanentData( "reg_date" ) < CONST_MAX_PRE_OFFER_TIME_PLAY_SEC then
        return
    end

    if not player:GetPermanentData( "comfort_test_offer_passed" )
    or player:GetPermanentData( "comfort_test_offer_purchase" ) then
        return
    end

    local offer_vehicle_end_date = player:GetPermanentData( "offer_vehicle_end_date" )
    if offer_vehicle_end_date then
        if offer_vehicle_end_date > timestamp then
            ShowPlayerOffer( player, offer_vehicle_end_date - timestamp, false )
        else
            ResetOffer( player )
        end
    else
        player:SetPermanentData( "offer_vehicle_end_date", timestamp + CONST_OFFER_TIME_SEC )
        ShowPlayerOffer( player, CONST_OFFER_TIME_SEC, true )

        -- Аналитика :-
        onShowFirstTime( player )
    end
end
addEventHandler( "onPlayerReadyToPlay", root, TrySegmentedPlayer )

function ResetOffer( player, purchase )
    if purchase then player:SetPermanentData( "offer_vehicle_purchase", purchase ) end

    player:SetPermanentData( "offer_vehicle_passed", true )
    player:SetPermanentData( "offer_vehicle_end_date", nil )

    player:SetPrivateData( "offer_vehicle_end_date", nil )
end

if SERVER_NUMBER > 100 then
    addCommandHandler( "removeoffervehicle", function( player )
        ResetOffer( player )
        player:ShowInfo( "Оффер очищен" )
    end )

    addCommandHandler( "addoffervehicle", function( player )
        ResetOffer( player )

        player:SetPermanentData( "offer_vehicle_passed", nil )
        player:SetPermanentData( "offer_vehicle_purchase", nil )

        player:SetPermanentData( "comfort_test_offer_passed", true )
        player:SetPermanentData( "comfort_test_offer_purchase", nil )

        player:ShowInfo( "Оффер подготовлен" )
    end )

    addCommandHandler( "segmentplayer", function( player )
        TrySegmentedPlayer( player )
    end )
end