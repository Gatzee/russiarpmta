

function onServerChangeStateAnchor_handler()
    local lobby_data = GetLobbyDataByPlayer( client )
    if not lobby_data or client.vehicle ~= lobby_data.job_vehicle then return end

    lobby_data.job_vehicle.frozen = not lobby_data.job_vehicle.frozen
end
addEvent( "onServerChangeStateAnchor", true )
addEventHandler( "onServerChangeStateAnchor", resourceRoot, onServerChangeStateAnchor_handler )


function onServerChangeStateEngine_handler()
    local lobby_data = GetLobbyDataByPlayer( client )
    if not lobby_data or client.vehicle ~= lobby_data.job_vehicle then return end
    
    lobby_data.job_vehicle.engineState = not lobby_data.job_vehicle.engineState
end
addEvent( "onServerChangeStateEngine", true )
addEventHandler( "onServerChangeStateEngine", resourceRoot, onServerChangeStateEngine_handler )