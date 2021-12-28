loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

local casino_colshapes =
{
    [ CASINO_THREE_AXE ] = 
    {
        interior = 1,
        dimension = 1,
        poly = { -98.5210, -508.1313, -98.7815, -476.2350, -34.0361, -476.2350, -34.0361, -508.1313, -98.5210, -508.1313 },
    },
    [ CASINO_MOSCOW ] = 
    {
        interior = 4,
        dimension = 1,
        poly = { 2452.4377, -1338.2269, 2459.4772, -1259.9085, 2343.8083, -1244.2005, 2331.5043, -1339.8381, 2452.4377, -1338.2269 },
    },
}

function SwitchPosition_handler( )
    triggerEvent( "onTaxiPrivateFailWaiting", client, "Пассажир отменил заказ", "Ты зашёл в помещение, заказ в Такси отменен" )
    triggerEvent( "onPlayerCasinoEnter", client )
end
addEvent( "SwitchPosition", true )
addEventHandler( "SwitchPosition", resourceRoot, SwitchPosition_handler )


function onClientPlayerEnterLeaveCasino_handler( casino_id )
    client:SetPrivateData( "casino_id", casino_id and casino_id or false )
end
addEvent( "onClientPlayerEnterLeaveCasino", true )
addEventHandler( "onClientPlayerEnterLeaveCasino", resourceRoot, onClientPlayerEnterLeaveCasino_handler )

-- Reconnect in casino
function onPlayerReadyToPlay_handler( )
    local player = source
    if not isElement( player ) then return end

    for k, v in pairs( casino_colshapes ) do
        if isInsideColShape( v.colshape, player.position ) then
            triggerClientEvent( player, "onClientPlayerCasinoEnter", player, k )
            player:SetPrivateData( "casino_id", k )
            break
        end
    end
end
addEvent( "onPlayerReadyToPlay" )
addEventHandler( "onPlayerReadyToPlay", root, onPlayerReadyToPlay_handler )


function onStart()
    for k, v in pairs( casino_colshapes ) do
        v.colshape = createColPolygon( unpack( v.poly ) )
        v.colshape.interior = v.interior
        v.colshape.dimension = v.dimension
    end
end
addEventHandler( "onResourceStart", resourceRoot, onStart )