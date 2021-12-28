Extend( "CInterior" )

local PLAYER_TO_REVIVE
local REVIVE_MARKER

local colshape_reviving = {}
local reviving_factions = {
	[ F_MEDIC ] = true,
	[ F_MEDIC_MSK ] = true,
}

function onClientSetReviveMarker_handler( interior_tpoint_position )
    DestroyMarkerAndBlip( )

    PLAYER_TO_REVIVE = source

    local position = interior_tpoint_position or PLAYER_TO_REVIVE.position
    REVIVE_MARKER = TeleportPoint( { 
        x = position.x, y = position.y, z = position.z, 
        interior = interior_tpoint_position and 0 or PLAYER_TO_REVIVE.interior, 
        dimension = interior_tpoint_position and 0 or PLAYER_TO_REVIVE.dimension, 
        radius = 2, 
        gps = true, 
        keypress = false, 
        accepted_elements = { player = true, vehicle = true },
    } )
    REVIVE_MARKER.marker.markerType = "checkpoint"
    REVIVE_MARKER.marker:setColor( 250, 50, 50, 150 )
    REVIVE_MARKER.elements = { }
    REVIVE_MARKER.elements.blip = createBlipAttachedTo( REVIVE_MARKER.marker, 40, 4, 250, 50, 50 )
    REVIVE_MARKER.elements.blip.position = REVIVE_MARKER.marker.position
    REVIVE_MARKER.PostJoin = function( )
        if interior_tpoint_position then
            triggerEvent( "onClientSetReviveMarker", PLAYER_TO_REVIVE )
        else
            triggerServerEvent( "onMedicArrivedToReviveCall", localPlayer, PLAYER_TO_REVIVE )
            DestroyMarkerAndBlip( )
        end
    end

    addEventHandler( "onClientPlayerSpawn", PLAYER_TO_REVIVE, onClientPlayerSpawn_handler )
    addEventHandler( "onClientPlayerQuit", PLAYER_TO_REVIVE, onClientPlayerQuit_handler )
end
addEvent( "onClientSetReviveMarker", true )
addEventHandler( "onClientSetReviveMarker", root, onClientSetReviveMarker_handler )

function DestroyMarkerAndBlip( )
    if isElement( PLAYER_TO_REVIVE ) then
        removeEventHandler( "onClientPlayerSpawn", PLAYER_TO_REVIVE, onClientPlayerSpawn_handler )
        removeEventHandler( "onClientPlayerQuit", PLAYER_TO_REVIVE, onClientPlayerQuit_handler )
    end

    if not REVIVE_MARKER then return end

    if REVIVE_MARKER.destroy then REVIVE_MARKER.destroy( ) end

    REVIVE_MARKER = nil
    PLAYER_TO_REVIVE = nil
end

function onClientPlayerSpawn_handler( )
    DestroyMarkerAndBlip( )
    if source.health >= 60 and source.interior == 1 and source.dimension == 1 then
        localPlayer:PhoneNotification( { 
            title = "[Минздрав] Отмена вызова", 
            msg = source:GetNickName( ) .. " умер. Вы не успели его спасти!",
        } )
    end
end

function onClientPlayerQuit_handler( )
    DestroyMarkerAndBlip( )
end

function createColshapeReviving()
	if source == localPlayer or not localPlayer:IsOnFactionDuty() or not reviving_factions[ localPlayer:GetFaction() ] then return end
    
    colshape_reviving[ source ] = createColSphere( source.position, 5 )
	colshape_reviving[ source ].dimension = source.dimension
	colshape_reviving[ source ].interior = source.interior
        
	addEventHandler( "onClientColShapeHit", colshape_reviving[ source ], function( element, matching_dimension )
        if element ~= localPlayer or not matching_dimension then return end
        
		destroyColshapeReviving( source )
        
        if getPedWeaponSlot( localPlayer ) ~= 10 and reviving_factions[ localPlayer:GetFaction() ] and localPlayer:IsOnFactionDuty() then
		    localPlayer:ShowInfo( "Для реанимации возьми дефибриллятор в руки" )
        end
	end )
end
addEventHandler( "onClientPlayerWasted", root, createColshapeReviving )

function destroyColshapeReviving( player )
	local player = source or player
	if isElement( colshape_reviving[ player ] ) then
    	destroyElement( colshape_reviving[ player ]  )
		colshape_reviving[ player ] = nil
	end
end
addEventHandler( "onClientPlayerSpawn", root, destroyColshapeReviving )
addEventHandler( "onClientPlayerQuit", root, destroyColshapeReviving )