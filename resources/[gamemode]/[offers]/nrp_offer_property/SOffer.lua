Extend( "SPlayer" )

HOURS_120 = 3600 * 120 -- start offer after 120 hours in game
OFFER_DURATION = 3600 * 24

function initOffer( player )
    if not player:HasFinishedTutorial( ) then return end

    local data = player:GetPermanentData( "offer_property" ) or { }
    if data.passed then return end

    local timestamp = getRealTimestamp( )
    local reg_date = player:GetPermanentData( "reg_date" ) or timestamp
    local spend = timestamp - reg_date

    if data.time_to and data.time_to <= timestamp then
        data.time_to = nil
        data.passed = true
        player:SetPermanentData( "offer_property", data )

    elseif not data.time_to and spend >= HOURS_120 then
        data.time_to = timestamp + OFFER_DURATION
        player:SetPrivateData( "offer_property", data )
        player:SetPermanentData( "offer_property", data )

        -- analytics
        SendElasticGameEvent( player:GetClientID( ), "mortage_20_offer_first" )

    elseif data.time_to then
        player:SetPrivateData( "offer_property", data )
    end

    if data.time_to then
        triggerClientEvent( player, "onPlayerOfferProperty", player )
    end
end

addEventHandler( "onPlayerReadyToPlay", root, function( )
    initOffer( source )
end, true, "low" )

addEvent( "onPlayerBoughtPropertyViaOffer" )
addEventHandler( "onPlayerBoughtPropertyViaOffer", root, function( mortage_id, class, cost )
    source:SetPrivateData( "offer_property", nil )
    source:SetPermanentData( "offer_property", { passed = true } )

    -- analytics
    SendElasticGameEvent( source:GetClientID( ), "mortage_20_offer_purchase", {
        mortage_id = mortage_id,
        mortage_group = class,
        mortage_type = "flat",
        mortage_cost = cost,
        quantity = 1,
        spend = cost,
        spend_sum = cost,
        currency = "soft",
    } )
end )

if SERVER_NUMBER > 100 then
    addCommandHandler( "init_offer_property", function( player )
        initOffer( player )
    end )

    addCommandHandler( "reset_offer_property", function( player )
        player:SetPrivateData( "offer_property", nil )
        player:SetPermanentData( "offer_property", nil )
    end )
end