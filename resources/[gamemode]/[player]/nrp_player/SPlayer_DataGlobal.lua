GLOBAL_DATA = { }
CHANGED_GLOBAL_DATA = { }

function GetGlobalData( player, key )
    return GLOBAL_DATA[ player ] and GLOBAL_DATA[ player ][ key ]
end

function SetGlobalData( player, key, value )
    if GLOBAL_DATA[ player ] then
        CHANGED_GLOBAL_DATA[ player ] = true
        GLOBAL_DATA[ player ][ key ] = value
    end
end

function LoadGlobalData( player, callback, ... )
    local player, callback = player, callback

    CommonDB:queryAsync( function( query, ... )
        if not isElement( player ) then
            dbFree( query )
            return
        end
        local result = query:poll( 0 )
        GLOBAL_DATA[ player ] = result[ 1 ] and result[ 1 ].permanent_data and fromJSON( result[ 1 ].permanent_data ) or { }

        callback( player, ... )
    end, { ... }, "SELECT permanent_data FROM nrp_players_common WHERE client_id=? LIMIT 1", player:GetClientID( ) )
end

function SaveGlobalData( player, clear )
    if GLOBAL_DATA[ player ] then
        local data = utf8.sub( toJSON( GLOBAL_DATA[ player ], true ), 2, -2 )
        CommonDB:exec( [[
            INSERT INTO nrp_players_common (client_id, permanent_data)
            VALUES (?, ?)
            ON DUPLICATE KEY UPDATE
            permanent_data = ?
        ]], player:GetClientID( ), data, data )
        
        CHANGED_GLOBAL_DATA[ player ] = nil
        if clear then GLOBAL_DATA[ player ] = nil end
    end
end