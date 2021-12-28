Extend( "SPlayer" )
Extend( "ShVinyls" )
Extend( "ShVehicle" )
Extend( "ShVehicleConfig" )

BASE_URL = "https://pyapi.gamecluster.nextrp.ru/v1.0/payments/pay"
PACK_ID  = 903

function onServerPlayerWantToBuyValentinePack_handler( pack_id )
    if not isElement( client ) or not IsOfferActive() then return end

    local segment_number = GetPlayerSegment( client )
    local pack_data = PACK_DATA[ segment_number ][ pack_id ]
    if not pack_data then return end
    
    if client:TakeDonate( pack_data.cost, "sale", pack_data.id ) then
        onServerPlayerPurchaseValentinePack_handler( client, pack_data.cost )
    else
        triggerClientEvent( client, "onClientSelectValentinePackInBrowser", resourceRoot, PACK_ID, pack_data.cost, BASE_URL )
    end
end
addEvent( "onServerPlayerWantToBuyValentinePack", true )
addEventHandler( "onServerPlayerWantToBuyValentinePack", resourceRoot, onServerPlayerWantToBuyValentinePack_handler )

function onServerPlayerPurchaseValentinePack_handler( player, sum )
    local target_segment, target_pack = nil
    for segment_id, segment_data in pairs( PACK_DATA ) do
        for _, pack_data in pairs( segment_data ) do
            if pack_data.cost == sum then
                target_segment = segment_id
                target_pack = pack_data
                break
            end
        end

        if target_pack then break end
    end

    if not target_pack then return end

    for k, v in ipairs( target_pack.rewards ) do
        REWARDS[ v.type ]( player, v )
    end
    triggerClientEvent( player, "onClientSuccessfulPurchaseValentineDayOffer", resourceRoot )


    -- Аналитика: Покупка оффера
    local spend_sum = (player:GetPermanentData( OFFER_NAME .. "_spend_sum" ) or 0) + target_pack.cost
    local quantity = (player:GetPermanentData( OFFER_NAME .. "_quantity" ) or 0) + 1

    player:SetPermanentData( OFFER_NAME .. "_spend_sum", spend_sum )
    player:SetPermanentData( OFFER_NAME .. "_quantity", quantity )

    onValentineDayOfferPurchase( player, target_pack.id, target_pack.name, target_pack.cost, "hard", spend_sum, quantity, toJSON( target_pack.rewards ), target_segment )
end
addEvent( "onServerPlayerPurchaseValentinePack" )
addEventHandler( "onServerPlayerPurchaseValentinePack", root, onServerPlayerPurchaseValentinePack_handler )

function onServerPlayerLoadOfferSegment_handler( player )
    local player = player or source
    if not isElement( player ) then return end

    local reward_data = player:GetPermanentData( "last_valentine_day_vinyl" )
    if reward_data then
        triggerClientEvent( player, "onClientSelectVinyl", resourceRoot, reward_data )
    end


    if not IsOfferActive() then return end
    triggerClientEvent( player, "onClientShowValentineDayOffer", resourceRoot, exports.nrp_shop:GetCasesInfo(), 
    {
        segment_num = GetPlayerSegment( player ),
        reward_data = reward_data,
    } )


    -- Аналитика: Первый показ акции
    if not player:GetPermanentData( OFFER_NAME .. "_show_first" ) then
        player:SetPermanentData( OFFER_NAME .. "_show_first", true )
        onValentineDayOfferShowFirst( player )
    end
end
addEvent( "onServerPlayerLoadOfferSegment" )
addEventHandler( "onServerPlayerLoadOfferSegment", root, onServerPlayerLoadOfferSegment_handler )

function onServerRequestShowValentineDayOffer_handler()
    if not isElement( client ) or not IsOfferActive() then return end

    triggerClientEvent( client, "onClientShowValentineDayOffer", resourceRoot, nil, 
    {
        segment_num = GetPlayerSegment( client ),
    } )
end
addEvent( "onServerRequestShowValentineDayOffer", true )
addEventHandler( "onServerRequestShowValentineDayOffer", root, onServerRequestShowValentineDayOffer_handler )

function GetPlayerSegment( player )
    local segment_num = exports.nrp_shop:GetCurrentSegment( player )
    local last_segment_num = player:GetPermanentData( OFFER_NAME .. "_last_segment" )

    if segment_num ~= last_segment_num then
        player:SetPermanentData( OFFER_NAME .. "_last_segment", segment_num )

        -- Аналитика: Смена сегмента
        onValentineDaySegmentChange( player, segment_num )
    end

    return segment_num
end

if SERVER_NUMBER > 100 then
    addCommandHandler( "clear_vd", function( player )
        player:SetPermanentData( OFFER_NAME .. "_last_segment", nil )
        player:SetPermanentData( OFFER_NAME .. "_show_first", nil )
        player:SetPermanentData( OFFER_NAME .. "_spend_sum", nil )
        player:SetPermanentData( OFFER_NAME .. "_quantity", nil )
        player:ShowInfo( "Данные оффера сброшены" )
    end )

    addCommandHandler( "min_cost_vd", function( player )
        local cost = 1
        for segment_id, segment_data in pairs( PACK_DATA ) do
            for _, pack_data in pairs( segment_data ) do
                pack_data.cost = cost
                cost = cost + 1
            end
        end
        
        player:ShowInfo( "Установлены минимальные цены на оффер цены: 1 - " .. cost - 1 .. " руб." )
    end )
end