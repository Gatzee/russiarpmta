-- SPlayerCommon.lua

Import( "SDB" )

function STUB( query ) if query then dbFree( query ) end end

function GetCommonData( client_id, keys, args, callback )
    local keys_converted = { }
    for i, v in pairs( keys ) do
        local key_name = CommonDB:prepare( "??", v )
        local key = table.concat( { "JSON_EXTRACT( permanent_data,'$.", key_name, "' ) as ", key_name }, '' )
        table.insert( keys_converted, key )
    end

    local final_fn = STUB
    if callback then
        final_fn = function( query, ... )
            local result = query:poll( -1 )
            for i, v in pairs( result and result[ 1 ] or { } ) do
                if type( v ) == "string" and utf8.sub( v, 1, 1 ) == '"' then
                    result[ 1 ][ i ] = utf8.sub( v, 2, -2 )
                end
            end
            callback( result and result[ 1 ] or { }, ... )
        end
    end

    local request = "SELECT " .. table.concat( keys_converted, ", " ) .. " FROM nrp_players_common WHERE client_id=? LIMIT 1"
    local prepared_request = CommonDB:prepare( request, client_id )
    CommonDB:queryAsync(
        final_fn,
        args or { },
        prepared_request
    )
end

function SetCommonData( client_id, keys, args, callback )
    local keys_converted = { }
    for key, value in pairs( keys ) do
        local pair = CommonDB:prepare( "'$.??', ?", key, value )
        table.insert( keys_converted, pair )
    end

    local final_fn = STUB
    if callback then
        final_fn = function( query, ... )
            local result = query:poll( -1 )
            callback( result and result[ 1 ], ... )
        end
    end

    local request = [[
        INSERT INTO nrp_players_common ( client_id, permanent_data )
        VALUES ( ?, ? )
        ON DUPLICATE KEY UPDATE
        permanent_data = JSON_SET( permanent_data, ]] .. table.concat( keys_converted, ", " ) .. [[ )
    ]]
    local prepared_request = CommonDB:prepare( request, client_id, utf8.sub( toJSON( keys, true ), 2, -2 ) )
    --outputConsole( prepared_request )
    CommonDB:queryAsync(
        final_fn,
        args or { },
        prepared_request
    )
end

Player.GetCommonData = function( self, keys, args, callback )
    local values = { }
    for i, v in pairs( keys ) do
        values[ v ] = exports.nrp_player:GetGlobalData( self, v )
    end
    if callback then
        for i, v in pairs( values ) do
            if type( v ) == "string" and utf8.sub( v, 1, 1 ) == '"' then
                values[ i ] = utf8.sub( v, 2, -2 )
            end
        end
        callback( values, unpack( args or { } ) )
    end
end

Player.SetCommonData = function( self, keys, args, callback )
    for i, v in pairs( keys ) do
        exports.nrp_player:SetGlobalData( self, i, v )
    end
    if callback then callback( unpack( args or { } ) ) end
end

string.GetCommonData = function( self, ... )
    local player = GetPlayerFromClientID( self )
    if player then
        player:GetCommonData( ... )
    else
        GetCommonData( self, ... )
    end
end

string.SetCommonData = function( self, ... )
    local player = GetPlayerFromClientID( self )
    if player then
        player:SetCommonData( ... )
    else
        SetCommonData( self, ... )
    end
end