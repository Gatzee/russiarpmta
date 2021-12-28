loadstring( exports.interfacer:extend( "Interfacer" ) )( )

function ChatStart_handler()
    local x, y, z = getElementPosition( client )
    local dimension = getElementDimension( client )

    local players = { }
    for i, v in pairs( getElementsByType( "player" ) ) do
        if client ~= v then
            local vx, vy, vz = getElementPosition( v )
            local vdimension = getElementDimension( v )
            if dimension == vdimension and getDistanceBetweenPoints3D( x, y, z, vx, vy, vz ) <= 30 then
                table.insert( players, v )
            end
        end
    end

    if #players > 0 then
        triggerClientEvent( players, "C_ChatStart", resourceRoot )
    end
end
addEvent( "ChatStart", true )
addEventHandler( "ChatStart", root, ChatStart_handler )

function ChatStop_handler()
    local x, y, z = getElementPosition( client )
    local dimension = getElementDimension( client )
    
    local players = { }
    for i, v in pairs( getElementsByType( "player" ) ) do
        if client ~= v then
            local vx, vy, vz = getElementPosition( v )
            local vdimension = getElementDimension( v )
            if dimension == vdimension and getDistanceBetweenPoints3D( x, y, z, vx, vy, vz ) <= 30 then
                table.insert( players, v )
            end
        end
    end

    if #players > 0 then
        triggerClientEvent( players, "C_ChatStop", resourceRoot )
    end

    --setElementData( client, "chatbox_active", false, false )
end
addEvent( "ChatStop", true )
addEventHandler( "ChatStop", root, ChatStop_handler )