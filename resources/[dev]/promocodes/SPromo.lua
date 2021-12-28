loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SDB" )

PROMOCODES = { }

function LoadCSV( )
    local file = fileOpen( "promo.csv" )
    local contents = fileRead( file, fileGetSize( file ) )
    fileClose( file )

    local lines = split( contents, "\n" )
    for i, v in pairs( lines ) do
        local data = split( v, "," )
        local nickname, id, server, old_promo, target_promo = unpack( data )
        if not PROMOCODES[ server ] then PROMOCODES[ server ] = { } end

        PROMOCODES[ server ][ target_promo:gsub( "\r", "" ) ] = tonumber( id )
    end
end

addEventHandler( "onResourceStart", resourceRoot, function( )
    LoadCSV( )

    for i, v in pairs( PROMOCODES ) do
        outputConsole( "SERVER: " .. i .. " -> " .. toJSON( v ) )
    end
end )