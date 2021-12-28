
function onServerMasterHackedCar_handler()
    local lobby_data = GetLobbyDataByPlayer( client )
    if not lobby_data then return end
    lobby_data.is_success_hacked = true

    triggerEvent( lobby_data.end_step, client )
end
addEvent( "onServerMasterHackedCar", true )
addEventHandler( "onServerMasterHackedCar", resourceRoot, onServerMasterHackedCar_handler )