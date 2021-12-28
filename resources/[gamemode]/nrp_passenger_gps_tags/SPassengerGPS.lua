
local GPS_TAGS = {}

function onServerRequestCreateGPSTag_handler( target_position )
    local vehicle = client.vehicle
    if not vehicle then return end

    local target_players = {} 
    local occupants = getVehicleOccupants( vehicle )
    for k, v in pairs( occupants ) do
        if v ~= client then
            table.insert( target_players, v )
        end
    end

    if GPS_TAGS[ client ] then
        RemoveGPSTag( client )
    end
    GPS_TAGS[ client ] = { target_players = target_players, target_position = target_position }

    if #target_players == 0 then return end
    
    triggerClientEvent( target_players, "onClientCreateGPSTag", client, target_position )

    local other_gps_player_markers = {} 
    for k, v in pairs( occupants ) do
        if v ~= client and GPS_TAGS[ v ] then
            table.insert( other_gps_player_markers, { player = v, target_position = GPS_TAGS[ v ].target_position } )
            table.insert( GPS_TAGS[ v ].target_players, client )
        end
    end
    if #other_gps_player_markers == 0 then return end

    triggerClientEvent( client, "onClientCreateTableGPSTags", client, other_gps_player_markers )
end
addEvent( "onServerRequestCreateGPSTag", true )
addEventHandler( "onServerRequestCreateGPSTag", root, onServerRequestCreateGPSTag_handler )


function RemoveGPSTag( player )
    if not GPS_TAGS[ player ] then return end

    local target_players = {}
    for k, v in pairs( GPS_TAGS[ player ].target_players ) do
        if isElement( v ) and v ~= player then
            table.insert( target_players, v )
        end
    end

    if #target_players > 0 then
        triggerClientEvent( target_players, "onClientDestroyGPSTag", player )
    end

    for _, cur_player in pairs( target_players ) do
        for k, v in pairs( GPS_TAGS[ cur_player ] or {} ) do
            if v == player then
                table.remove( GPS_TAGS[ cur_player ].target_players, k )
            end
        end
    end

    GPS_TAGS[ player ] = nil
end

function onServerRequestDestroyGPSTag_handler()
    RemoveGPSTag( client )
end
addEvent( "onServerRequestDestroyGPSTag", true )
addEventHandler( "onServerRequestDestroyGPSTag", root, onServerRequestDestroyGPSTag_handler )

function onPlayerPreLogout_handler()
    GPS_TAGS[ source ] = nil
end
addEvent( "onPlayerPreLogout" )
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )

addEventHandler( "onPlayerVehicleExit", root, onPlayerPreLogout_handler )