FORBES_CACHE = { }
FORBES_CACHE_UPDATE_FREQ = 30

function onClientRequestForbesList_handler( )

    local function SendListToPlayer( player )
        local player_info
        local coins = player:GetBusinessCoins( )
        local userid = player:GetUserID( )
        for i, v in pairs( FORBES_CACHE.list ) do
            if userid == v.id then
                player_info = { position = i, coins = coins }
                break
            end
        end

        local list_to_send = { }
        for i = 1, 10 do
            table.insert( list_to_send, FORBES_CACHE.list[ i ] )
        end

        triggerClientEvent( player, "onClientRequestForbesListCallback", resourceRoot, { list = list_to_send, player_info = player_info, office_data = player:GetPermanentData( "office_data" ) })
    end

    -- Кешированные значения
    if FORBES_CACHE and FORBES_CACHE.last_update and getRealTime( ).timestamp - FORBES_CACHE.last_update <= FORBES_CACHE_UPDATE_FREQ then
        SendListToPlayer( client )
        return
    end

    -- Новый запрос + добавление в кеш
    DB:queryAsync( function( query, player )
        local list = query:poll( -1 )
        FORBES_CACHE.list = list
        FORBES_CACHE.last_update = getRealTime( ).timestamp

        if player then
            SendListToPlayer( player )
        end
    
    end,
    { client }, "SELECT id, nickname, business_coins FROM nrp_players WHERE business_coins > 0 ORDER BY business_coins DESC" )
end
addEvent( "onClientRequestForbesList", true )
addEventHandler( "onClientRequestForbesList", root, onClientRequestForbesList_handler )