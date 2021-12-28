
function onServerGetPreLastMarker_handler( point_id )
    local lobby_data = GetLobbyDataByPlayer( client )
    if not lobby_data then return end

    local coordinator = GetLobbyPlayersByRole( lobby_data.lobby_id, JOB_ROLE_COORDINATOR, true )
    if isElement( coordinator ) then
        triggerClientEvent( coordinator, "onClientDriverTakePoint", resourceRoot, point_id )
    end
end
addEvent( "onServerDriverTakePoint", true )
addEventHandler( "onServerDriverTakePoint", resourceRoot, onServerGetPreLastMarker_handler )

function DestroyBlipDeliveredVehicle( lobby_data )
	if isElement( lobby_data.blip_delivery_vehicle  ) then
		destroyElement( lobby_data.blip_delivery_vehicle  )
	end
end

function GetFreeVehicleSpawnId()
    local spawn_id = 1
    for k, v in pairs( SPAWN_ZONES_OF_CARS ) do
        local vehicles_on_spawn = getElementsWithinRange( v.pos, 3, "vehicle" )
        if #vehicles_on_spawn == 0 then
            spawn_id = k
            break
        end
    end
    return spawn_id
end