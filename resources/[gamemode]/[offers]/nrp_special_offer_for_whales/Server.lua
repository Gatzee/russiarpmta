loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "ShVehicleConfig" )

VEHICLE_EVENT_DATA = {
    ground     = { callback_event = "onDiscountedVehiclePurchaseCallback", resource_name = "nrp_shop"            },
    airplane   = { callback_event = "OnAirplaneMarketVehicleAdded"       , resource_name = "nrp_airplane_market" },
    helicopter = { callback_event = "OnAirplaneMarketVehicleAdded"       , resource_name = "nrp_airplane_market" },
    boat       = { callback_event = "OnBoatMarketVehicleAdded"           , resource_name = "nrp_boats_market"    }
}

CONST_BEGIN_TIME = 0
CONST_END_TIME = 0
OFFER_STAGE_NUM = 1
OFFER_GOODS = {}

function InitOffer( player )
    local timestamp = getRealTimestamp( )
    if timestamp < CONST_BEGIN_TIME or timestamp > CONST_END_TIME then return end
    if not player:HasFinishedBasicTutorial( ) then return end
    if player:GetPermanentData( "donate_total" ) < 20000 then return end

    local offer_data = player:GetPermanentData( "offer_for_whales" ) or { }
    if not offer_data.time_left or offer_data.time_left < CONST_BEGIN_TIME then
        offer_data.time_left = timestamp
        player:SetPermanentData( "offer_for_whales", offer_data )

        SendElasticGameEvent( player:GetClientID( ), "whale_offer_show_first" )
    end

    if CONST_END_TIME > timestamp then
        player:SetPrivateData( "offer_for_whales", CONST_END_TIME )
        if player:HasFinishedTutorial( ) then
            triggerClientEvent( player, "onPlayerShowSpecialOfferForWhales", resourceRoot )
        end
    end
end

addEventHandler( "onPlayerReadyToPlay", root, function( )
    InitOffer( source )
end )

function onPlayerTryPurchaseDiscountedVehicle_handler( player, item_index, color )
    player = client or player

    local vehicle_data = OFFER_GOODS[ item_index ]
    if not vehicle_data then
        player:ErrorWindow( "Операция была прервана!" )
        return
    end

    local vehicle_id = vehicle_data.vehicle_id
    local vehicle_config = VEHICLE_CONFIG[ vehicle_data.vehicle_id ]

    if not vehicle_config.special_type then
        if not vehicle_config.is_moto then
            if not player:HasFreeVehicleSlot( ) then
                triggerClientEvent( player, "onPlayerNotHaveSlotsForPurchase", resourceRoot, true )
                return
            end
        end

        if player.interior ~= 0 or player.dimension ~= 0 then
            player:ErrorWindow( "Покупать транспорт можно только на улице, не находясь на задании!" )
            return
        end

        if player:getData( "jailed" ) then
            player:ErrorWindow( "В тюрьме нельзя делать покупки" )
            return
        end
    end

    local cost = vehicle_data.cost

    if not player:TakeMoney( cost, "offer_for_whales", "vehicle_" .. vehicle_id ) then
        player:EnoughMoneyOffer( "offer_for_whales", cost, "onPlayerTryPurchaseDiscountedVehicle", resourceRoot, player, item_index, color )
        return
    end

    local owner_pid	= "p:" .. player:GetUserID( )
    local vehicle_conf	= {
        model 		= vehicle_id,
        variant		= vehicle_data.variant or 1,
        x			= 0,
        y			= 0,
        z			= 0,
        rx			= 0,
        ry			= 0,
        rz			= 0,
        owner_pid	= owner_pid,
        color		= color or { 255, 255, 255 },
    }

    exports.nrp_vehicle:AddVehicle( vehicle_conf, true, "OfferForWhalesCompleteCallback", { player = player, cost = cost, item_index = item_index } )

    player:InfoWindow( "Транспорт успешно приобретён!" )
    player:PlaySound( SOUND_TYPE_2D, ":nrp_shop/sfx/reward_big.wav" )

    local vehicle_name = vehicle_config.model .. ( vehicle_config.variants[ 2 ] and ( " " .. vehicle_config.variants[ vehicle_data.variant or 1 ].mod ) or "" )
    local data = {
        vehicle_id = vehicle_id,
        vehicle_name = Translit( vehicle_name ):lower( ),
        vehicle_cost = cost,
        currency  = "soft",
        quantity = 1,
        spend_sum = cost,
        stage_num = OFFER_STAGE_NUM,
    }
    SendElasticGameEvent( player:GetClientID( ), "whale_offer_purchase", data )
end
addEvent( "onPlayerTryPurchaseDiscountedVehicle", true )
addEventHandler( "onPlayerTryPurchaseDiscountedVehicle", resourceRoot, onPlayerTryPurchaseDiscountedVehicle_handler )

function OfferForWhalesCompleteCallback_handler( vehicle, data, error_reason )
    if error_reason then
        data.player:ShowError( error_reason )
        return
    end

    local vehicle_data = OFFER_GOODS[ data.item_index ]
    local vehicle_config = VEHICLE_CONFIG[ vehicle_data.vehicle_id ]
    local event_data = VEHICLE_EVENT_DATA[ vehicle_config.special_type or "ground" ]

    local resource_name = event_data.resource_name

    local resource = resource_name and getResourceFromName( resource_name )
    local source_element = resource and getResourceRootElement( resource )

    if source_element and getResourceState( resource ) == "running" then
        triggerEvent( event_data.callback_event, source_element, vehicle, data )
    else
        WriteLog( "offer_for_whales", "%s: не найден ресурс для vehicle_id %s", data.player, vehicle_data.vehicle_id )
    end
end
addEvent( "OfferForWhalesCompleteCallback" )
addEventHandler( "OfferForWhalesCompleteCallback", resourceRoot, OfferForWhalesCompleteCallback_handler )


addEvent( "onPlayerWantShowWhalesOfferDetailed", true )
addEventHandler( "onPlayerWantShowWhalesOfferDetailed", resourceRoot, function() 
	triggerClientEvent( client, "onPlayerShowWhalesOfferDetailed", resourceRoot, OFFER_GOODS )
end )

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	if key ~= "whale_offer" then return end

	if not value or next( value ) == nil then 
		CONST_BEGIN_TIME = 0
		CONST_END_TIME = 0
		--Если акция закончилась, очищать список офферов - нельзя
		--Потому-что если за 48 часов до окончания акции кто-то её получит, то она ему будет доступна 48 часов после её получения
		--И список будет отображатся пустым по окончании "раздачи" этой акции
		-- OFFER_GOODS = {}
	else
		CONST_BEGIN_TIME = getTimestampFromString( value [ 1 ].start_date )
		CONST_END_TIME = getTimestampFromString( value[ 1 ].finish_date )
		OFFER_GOODS = value[ 1 ].offer_goods
		OFFER_STAGE_NUM = value[ 1 ].stage_num or 1
	end
end )
function onResourceStart_handler( )
	triggerEvent( "onSpecialDataRequest", getResourceRootElement( ), "whale_offer" )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )





----------------------------------------------------------------------------

if SERVER_NUMBER > 100 then

    addCommandHandler( "init_offer_for_whales", function( player )
        player:SetPermanentData( "donate_total", 20000 )
        InitOffer( player )
    end )

end