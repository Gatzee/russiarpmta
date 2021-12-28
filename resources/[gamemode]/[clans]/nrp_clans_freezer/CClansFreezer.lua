Extend( "CPlayer" )
Extend( "CInterior" )
Extend( "ShClans" )

local FREEZER_MARKER

function CreateFreezerMarker( )
    if FREEZER_MARKER then return end

    local conf = {
        x = -1.47, y = 76.94, z = 1267.28,
        interior = 1, 
        dimension = localPlayer.dimension, 
        radius = 1,
        color = { 0, 0, 0, 0 },
        marker_text = "Морозильная камера",
        keypress = "lalt",
        text = "ALT Взаимодействие",
    }

    local tpoint = TeleportPoint( conf )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255 } )
    -- tpoint:SetImage( ":nrp_clans/img/tags/band/46.png" )
    tpoint.element:setData( "material", true, false )
        
    tpoint.PostJoin = function( self, player )
        triggerServerEvent( "CF:onPlayerWantShowUI", resourceRoot )
    end

    FREEZER_MARKER = tpoint
end
addEvent( "CF:onClientCreateMarkers", true )
addEventHandler( "CF:onClientCreateMarkers", root, CreateFreezerMarker )
addEvent( "CAF:onClientCreateMarkers", true )
addEventHandler( "CAF:onClientCreateMarkers", root, CreateFreezerMarker )
addEvent( "CHF:onClientCreateMarkers", true )
addEventHandler( "CHF:onClientCreateMarkers", root, CreateFreezerMarker )

addEvent( "onClientPlayerEnterClanBunker", true )
addEventHandler( "onClientPlayerEnterClanBunker", root, function( )
    if not FREEZER_MARKER then return end
    FREEZER_MARKER.dimension = localPlayer.dimension
    FREEZER_MARKER.element.dimension = FREEZER_MARKER.dimension
end )

addEvent( "onClientPlayerLeaveClan", true )
addEventHandler( "onClientPlayerLeaveClan", root, function( )
    if not FREEZER_MARKER then return end
    FREEZER_MARKER:destroy( )
    FREEZER_MARKER = nil
end )