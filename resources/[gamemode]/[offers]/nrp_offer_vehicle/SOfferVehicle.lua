loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SDB" )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )
Extend( "SPlayerCommon" )
Extend( "ShTimelib" )

local CONST_GLOBAL_PACK_ID = 900
local PACK_DATA =
{
    [ 1 ] = 
    {
        cost = 69,
        cost_original = 90,
        vehicle_id = 6550,
    }, 
    [ 2 ] = 
    {
        cost = 249,
        cost_original = 349,
        vehicle_id = 467,
    },
    [ 3 ] = 
    {
        cost = 549,
        cost_original = 890,
        vehicle_id = 6567,
    },
    [ 4 ] = 
    {
        cost = 890,
        cost_original = 1500,
        vehicle_id = 410,
    },
}

local BASE_URL = "https://pyapi.gamecluster.nextrp.ru/v1.0/payments/pay"

function ShowPlayerOffer( player, time_left, is_first_time )
    triggerClientEvent( player, "onClientStartOfferlVehicleRequest", resourceRoot, {
        url           = BASE_URL,
        time_left     = time_left,
        is_first_time = is_first_time,
        pack_data     = PACK_DATA,
    } )
end

function onServerPlayerTryBuyOfferVehicle_handler( pack_id, color )
    local player = client
    if not isElement( player ) then return end

    local pack = PACK_DATA[ pack_id ]
    if not pack then return end

    if not client:HasFreeVehicleSlot( ) then
        triggerClientEvent( client, "onPlayerNotHaveSlotsForPurchase", resourceRoot )
        return
    end

    if client.interior ~= 0 or client.dimension ~= 0 then
        client:ErrorWindow( "Покупать машины можно только на улице, не находясь на задании!" )
        return
    end

    if client:getData( "jailed" ) then
        client:ErrorWindow( "В тюрьме нельзя делать покупки" )
        return
    end

    if client:TakeDonate( pack.cost ) then
        onPlayerPurchaseOfferVehicle_handler( client, pack_id, color )
    else
        triggerClientEvent( client, "onClientSelectOfferVehiclePackInBrowser", resourceRoot, CONST_GLOBAL_PACK_ID, pack.cost )
    end
end
addEvent( "onServerPlayerTryBuyOfferVehicle", true )
addEventHandler( "onServerPlayerTryBuyOfferVehicle", root, onServerPlayerTryBuyOfferVehicle_handler )

function onPlayerPurchaseOfferVehicle_handler( player, pack_id, color )
    local pack_data = PACK_DATA[ pack_id ]
    local owner_pid	= "p:" .. player:GetUserID( )
    local vehicle_conf = {
        model 		= pack_data.vehicle_id,
        variant		= 1,
        x			= 0,
        y			= 0,
        z			= 0,
        rx			= 0,
        ry			= 0,
        rz			= 0,
        owner_pid	= owner_pid,
        color		= color or { 255, 255, 255 },
    }

    exports.nrp_vehicle:AddVehicle( vehicle_conf, true, "onPlayerPurchaseOfferVehicleAddCallback", { player = player, cost = pack_data.cost, vehicle_id = pack_data.vehicle_id } )
end
addEvent( "onPlayerPurchaseOfferVehicle" )
addEventHandler( "onPlayerPurchaseOfferVehicle", root, onPlayerPurchaseOfferVehicle_handler )


function onPlayerPurchaseOfferVehicleAddCallback_handler( vehicle, data )
    local player = data.player

    -- Выдача, настройка машины
    local sOwnerPID = "p:" ..player:GetUserID( )
	vehicle.locked = true
	vehicle.engineState = true
	vehicle:SetFuel( "full" )
	vehicle:SetPermanentData( "showroom_cost", data.cost * 1000 )
	vehicle:SetPermanentData( "showroom_date", getRealTimestamp( ) )
	vehicle:SetPermanentData( "first_owner", sOwnerPID )

	player:AddVehicleToList( vehicle )
    
    player:GiveFreeEvacuation( vehicle:GetID() )

	vehicle.position = player.position

	removePedFromVehicle( player )
    warpPedIntoVehicle( player, vehicle ) 
    

    ResetOffer( player, true )
    triggerClientEvent( player, "onClientOfferlVehicleHide", resourceRoot )

    -- Аналитика :-
    onPlayerOfferPurchase( player, data.vehicle_id, VEHICLE_CONFIG[ data.vehicle_id ].model, vehicle:GetTier(), data.cost )
end
addEvent( "onPlayerPurchaseOfferVehicleAddCallback" )
addEventHandler( "onPlayerPurchaseOfferVehicleAddCallback", root, onPlayerPurchaseOfferVehicleAddCallback_handler )