Extend( "SPlayer" )
Extend( "ShSkin" )

HOURS_72 = 3600 * 72 -- start offer after 72 hours in game
OFFER_DURATION = 3600 * 24

function initOffer( player )
    if not player:HasFinishedTutorial( ) then return end

    local data = player:GetPermanentData( "offer_skin" ) or { }
    if data.passed then return end

    local timestamp = getRealTimestamp( )
    local reg_date = player:GetPermanentData( "reg_date" ) or timestamp
    local spend = timestamp - reg_date

    if data.time_to and data.time_to <= timestamp then
        data.time_to = nil
        data.passed = true
        player:SetPermanentData( "offer_skin", data )

    elseif not data.time_to and spend >= HOURS_72 then
        data.time_to = timestamp + OFFER_DURATION
        player:SetPrivateData( "offer_skin", data )
        player:SetPermanentData( "offer_skin", data )

        -- analytics
        SendElasticGameEvent( player:GetClientID( ), "skin_15offer_show_first" )

    elseif data.time_to then
        player:SetPrivateData( "offer_skin", data )
    end

    if data.time_to then
        triggerClientEvent( player, "onPlayerOfferSkin", player )
    end
end

addEventHandler( "onPlayerReadyToPlay", root, function( )
    initOffer( source )
end, true, "low" )

addEvent( "onPlayerBoughtSkinViaOffer" )
addEventHandler( "onPlayerBoughtSkinViaOffer", root, function( skin_id, cost )
    source:SetPrivateData( "offer_skin", nil )
    source:SetPermanentData( "offer_skin", { passed = true } )

    -- analytics
    SendElasticGameEvent( source:GetClientID( ), "skin_15offer_offer_purchase", {
        skin_id = skin_id,
        skin_name = SKINS_NAMES[ skin_id ] or "",
        skin_cost = cost,
        quantity = 1,
        currency = "soft",
        spend_sum = cost,
    } )
end )

if SERVER_NUMBER > 100 then
    addCommandHandler( "init_offer_skin", function( player )
        initOffer( player )
    end )

    addCommandHandler( "reset_offer_skin", function( player )
        player:SetPrivateData( "offer_skin", nil )
        player:SetPermanentData( "offer_skin", nil )
    end )
end