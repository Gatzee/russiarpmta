function onServerIndustrialFishingTakeFish_handler( side_index, hold )
    local lobby_data = GetLobbyDataByPlayer( client )
    if not lobby_data or lobby_data.hold.side[ side_index ] == SIZE_FISH_IN_ZONE then return end

    lobby_data.hold.all = lobby_data.hold.all + SIZE_FISH_IN_ZONE
    lobby_data.hold.side[ side_index ] = SIZE_FISH_IN_ZONE

    triggerClientEvent( { GetLobbyPlayersByRole( lobby_data.lobby_id, FISHERMAN )[ side_index ] }, "UpdateIndustrialFishingProgress", resourceRoot, {
        [ FISHERMAN ] = {
            value = lobby_data.hold.side[ side_index ] / SIZE_SIDE_HOLD,
            index = "hold",
        }
    } )

    onServerFisherManManipulatorObject_handler( MANIPULATION_FISH_FULL, side_index )    
end
addEvent( "onServerIndustrialFishingTakeFish", true )
addEventHandler( "onServerIndustrialFishingTakeFish", resourceRoot, onServerIndustrialFishingTakeFish_handler )