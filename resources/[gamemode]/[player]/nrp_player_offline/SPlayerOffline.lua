loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

SDB_SEND_CONNECTIONS_STATS = true
Extend( "SDB" )

CLIENT_ID = { }

function LoadPlayersData( )
    CLIENT_ID = { }
    DB:queryAsync( function( query )
        local result = query:poll( -1 )
        for i, v in pairs( result ) do
            CLIENT_ID[ v.id ] = v
            CLIENT_ID[ v.client_id ] = v
        end
    end, { }, "SELECT id, client_id, nickname, level FROM nrp_players" )
end

function GetOfflineDataFromClientID( client_id, key )
    return CLIENT_ID[ client_id ] and CLIENT_ID[ client_id ][ key ]
end

function GetOfflineDataFromUserID( user_id, key )
    return CLIENT_ID[ user_id ] and CLIENT_ID[ user_id ][ key ]
end

function SetOfflineDataForClientID( client_id, key, value )
    if not CLIENT_ID[ client_id ] then
        CLIENT_ID[ client_id ] = { }
    end
    CLIENT_ID[ client_id ][ key ] = value
end
addEvent( "SetOfflineDataForClientID", true )
addEventHandler( "SetOfflineDataForClientID", root, SetOfflineDataForClientID )

LoadPlayersData( )