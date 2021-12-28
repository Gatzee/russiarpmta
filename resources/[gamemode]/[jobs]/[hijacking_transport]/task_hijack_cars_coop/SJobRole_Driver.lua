

function onServerDriverHackedCar_handler()
    local lobby_data = GetLobbyDataByPlayer( client )
    if not lobby_data then return end
    lobby_data.hijacked_vehicle:setEngineState( true )

    triggerEvent( lobby_data.end_step, client )
end
addEvent( "onServerDriverHackedCar", true )
addEventHandler( "onServerDriverHackedCar", resourceRoot, onServerDriverHackedCar_handler )