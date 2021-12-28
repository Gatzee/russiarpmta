loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )

addEvent( "RequestTeleportPlayer" )
function RequestTeleportPlayer( player, x, y, z, dimension, interior )
    if player.dimension == 0 and player.interior == 0 then
        player:SetPermanentData( "last_tp_position", player.position:totable( ) )
    end

    if dimension then player.dimension = dimension end
    if interior then player.interior = interior end
    if x and y and z then player.position = Vector3( x, y, z ) end
end
addEventHandler( "RequestTeleportPlayer", root, RequestTeleportPlayer )

addEvent( "RequestTeleport", true )
addEventHandler( "RequestTeleport", root, function( ... )
	RequestTeleportPlayer( client, ... )
end )