
function onServerFishermanLoadedFish_handler()
    local lobby_data = GetLobbyDataByPlayer( client )
    if not lobby_data then return end
    
    local side_index = client:getData( "fisherman_index" )
    if not side_index then return end

    local driver = GetLobbyPlayersByRole( lobby_data.lobby_id, DRIVER, true )
    local target_fisherman = GetLobbyPlayersByRole( lobby_data.lobby_id, FISHERMAN )[ side_index ]
    
    client:ShowInfo( "Рыба погружена в трюм" )
    triggerClientEvent( { driver, target_fisherman }, "UpdateIndustrialFishingProgress", resourceRoot, {
        [ DRIVER ] = {
            value = lobby_data.hold.all / SIZE_HOLD,
            index = "hold",
        },
        [ FISHERMAN ] = {
            value = 0,
            index = "hold",
        }
    } )
    onServerFisherManManipulatorObject_handler( MANIPULATION_FISH_EMPTY, side_index, true )   
    
    lobby_data.fish_side_loaded[ side_index ] = true
    if lobby_data.fish_side_loaded[ LEFT_BOAT_SIDE ] and lobby_data.fish_side_loaded[ RIGHT_BOAT_SIDE ] then
        triggerEvent( lobby_data.end_step, GetLobbyPlayersByRole( lobby_data.lobby_id, COORDINATOR, true ) )
    end
end
addEvent( "onServerFishermanLoadedFish", true )
addEventHandler( "onServerFishermanLoadedFish", resourceRoot, onServerFishermanLoadedFish_handler )

function onServerFisherManManipulatorObject_handler( operation, target_side, is_off_manipulator )
    local lobby_data = GetLobbyDataByPlayer( client )
    if not lobby_data then return end
    
    local target_players = {}
    for k, v in pairs( lobby_data.participants ) do
        table.insert( target_players, v.player )  
    end
    triggerClientEvent( target_players, "onClientFisherManManipulatorObject", resourceRoot, operation, target_side, is_off_manipulator )

    
    if operation == MANIPULATION_CONTAINER_LOADED then
        lobby_data.container_unload_quantity = lobby_data.container_unload_quantity + 1

        if not lobby_data.side_loaded then lobby_data.side_loaded = {} end

        lobby_data.side_loaded[ target_side ] = math.min( (lobby_data.side_loaded[ target_side ] or 0) + 1, CONTAINER_UNLOAD_COUNT )

        
        local container_need_count = CONTAINER_UNLOAD_COUNT * 2
        triggerClientEvent( GetLobbyPlayersByRole( lobby_data.lobby_id, DRIVER, true ), "UpdateIndustrialFishingProgress", resourceRoot, {
            [ DRIVER ] = {
                value = (container_need_count - lobby_data.container_unload_quantity) / container_need_count,
                index = "hold",
            }
        } )

        if lobby_data.container_unload_quantity == container_need_count then
            triggerEvent( lobby_data.end_step, client )
        end
    end
end
addEvent( "onServerFisherManManipulatorObject", true )
addEventHandler( "onServerFisherManManipulatorObject", resourceRoot, onServerFisherManManipulatorObject_handler )