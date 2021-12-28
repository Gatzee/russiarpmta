Extend( "SVehicle" )
Extend( "SPlayer" )
Extend( "SQuestCoop" )

addEventHandler( "onResourceStart", resourceRoot, function()
	SQuestCoop( QUEST_DATA )
end )

function onServerIndustrialFishingStartWork_handler( lobby )
	local lobby_data = GetLobbyDataById( lobby.lobby_id )
	if lobby_data then
		WriteLog("#1 ERROR CREATE LOBBY TASK INDUSTRIAL FISHING")
		return false
	end
	
	lobby_data = CreateLobbyData( lobby.lobby_id, lobby )
end
addEvent( "onServerIndustrialFishingStartWork" )
addEventHandler( "onServerIndustrialFishingStartWork", root, onServerIndustrialFishingStartWork_handler )

function onPlayerPreLogout_handler()
	if source:GetJobClass() == JOB_CLASS_INDUSTRIAL_FISHING then
		source.position = RESPAWN_POSITIONS[ math.random(1, #RESPAWN_POSITIONS) ]
	end
end
addEvent( "onPlayerPreLogout" )
addEventHandler( "onPlayerPreLogout", root, onPlayerPreLogout_handler )

function onServerIndustrialFishingEndWork_handler( lobby_id, reason_data )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	for k, v in pairs( lobby_data.participants ) do
		v.player:setData( "no_evacuation", false, false )
		v.player:SetPrivateData( "fisherman_index", false )
		OnIndustrialFishingJobFinish( v.player, lobby_data, reason_data )
	end
end
addEvent( "onServerIndustrialFishingEndWork" )
addEventHandler( "onServerIndustrialFishingEndWork", root, onServerIndustrialFishingEndWork_handler )


if SERVER_NUMBER > 100 then
    local lap_elements = {}
    addCommandHandler( "industrial_fish_marker", function( player, cmd, route_id )
    	DestroyTableElements( lap_elements )
    	lap_elements = {}
    	lap_elements.marker_id = 1

    	route_id = tonumber( route_id )
    	if not route_id then return end
		
		local routes = FISHING_ROUTES[ route_id ]
		lap_elements.CreateNextMarker = function()
			if routes[ lap_elements.marker_id ] then
				lap_elements.marker = createMarker( routes[ lap_elements.marker_id ] + Vector3( 0, 0, 2 ) )
				lap_elements.marker.size = 5
				
				lap_elements.blip = createBlip( routes[ lap_elements.marker_id ] )
				addEventHandler ( "onMarkerHit", lap_elements.marker, function( element )
					if element ~= player then return end

					lap_elements.marker_id = lap_elements.marker_id + 1

					destroyElement( lap_elements.marker )
					destroyElement( lap_elements.blip )

					lap_elements.CreateNextMarker()
				end )
			else
				player:ShowInfo( "Маршрут пройден" )
			end
		end
		lap_elements.CreateNextMarker()

    end )

	addCommandHandler( "industrial_fish_route", function( player, cmd, route_id )
		route_id = tonumber( route_id )
    	if not route_id or not FISHING_ROUTES[ route_id ] then 
			TARGET_ROUTE_ID = nil
			return 
		end

		TARGET_ROUTE_ID = route_id
	end )
end