Extend( "CPlayer" )
Extend( "CInterior" )

ELEMENTS = { }

local _TeleportPoint = TeleportPoint
TeleportPoint = function( ... )
    local tpoint = _TeleportPoint( ... )
    table.insert( ELEMENTS, tpoint )
    return tpoint
end

addEvent( "CAF:onClientCreateMarkers", true )
addEventHandler( "CAF:onClientCreateMarkers", resourceRoot, function( )
    DestroyTableElements( ELEMENTS )
    ELEMENTS = { }
end, true, "high" )

addEvent( "onClientPlayerLeaveClan", true )
addEventHandler( "onClientPlayerLeaveClan", root, function( )
    DestroyTableElements( ELEMENTS )
    ELEMENTS = { }
end )

---------------------------------------------------------------------------

local FACTORY_MARKERS = {
    enter = { x = 8.853, y = 88.831, z = 1267.282 },
    exit = { x = -99.680, y = 25.590, z = 1988.943 },
    ui = { x = -103.146, y = 31.788, z = 1988.943 },
}

addEvent( "CAF:onClientCreateMarkers", true )
addEventHandler( "CAF:onClientCreateMarkers", resourceRoot, function( marker_cooldowns )
    -- Маркер входа
    local conf = FACTORY_MARKERS.enter
    conf.interior = 1
    conf.dimension = localPlayer.dimension
    conf.marker_text = "Алко-Цех"
    conf.text = "ALT Взаимодействие"
    conf.keypress = "lalt"
    conf.radius = 2
    conf.color = { 255, 168, 0, 70 }

    local tpoint = TeleportPoint( conf )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.55 } )
    -- tpoint:SetImage( ":nrp_clans/img/tags/band/-2.png" )
    -- tpoint.element:setData( "material", true, false )
        
    tpoint.PostJoin = function( self, player )
        localPlayer:Teleport( FACTORY_MARKERS.exit, nil, 8, 300 )
    end


    -- Маркер интерфейса
    local conf = FACTORY_MARKERS.ui
    conf.interior = 8
    conf.dimension = localPlayer.dimension
    conf.radius = 2
    conf.color = { 0, 0, 0, 0 }
    conf.marker_text = "Алко-Цех"
    conf.keypress = "lalt"
    conf.text = "ALT Взаимодействие"

    local tpoint = TeleportPoint( conf )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255 } )
    tpoint:SetImage( "img/marker_factory.png" )
    -- tpoint.element:setData( "material", true, false )
        
    tpoint.PostJoin = function( self, player )
        triggerServerEvent( "CAF:onPlayerWantShowUI", resourceRoot )
    end

    FACTORY_MARKERS.exit.element.dimension = localPlayer.dimension
end )

-- Маркер выхода
local conf = FACTORY_MARKERS.exit
conf.interior = 8
conf.dimension = localPlayer.dimension
conf.radius = 2
conf.color = { 0, 120, 255, 40 }
conf.marker_text = "Вернуться в бункер"
conf.keypress = "lalt"
conf.text = "ALT Взаимодействие"

local tpoint = _TeleportPoint( conf ) -- _TeleportPoint чтобы не удалялся при очистке, маркер должен быть всегда на случай, если игрока выкинут из клана, когда он внутри
tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.55 } )
-- tpoint:SetImage( ":nrp_clans/img/tags/band/46.png" )
tpoint.element:setData( "material", true, false )
    
tpoint.PostJoin = function( self, player )
    localPlayer:Teleport( FACTORY_MARKERS.enter, nil, 1, 300 )
end

addEvent( "onClientPlayerEnterClanBunker", true )
addEventHandler( "onClientPlayerEnterClanBunker", root, function( )
    if not isElement( FACTORY_MARKERS.enter.element ) then return end

    for i, marker in pairs( FACTORY_MARKERS ) do
        marker.dimension = localPlayer.dimension
        marker.element.dimension = marker.dimension
    end
end )

-- На случай спавна внутри цеха при входе в игру (и его выкинули из клана, когда он был не в сети) (или если зареспавнят медики?)
addEventHandler( "onClientPlayerSpawn", localPlayer, function( )
    FACTORY_MARKERS.exit.element.dimension = localPlayer.dimension
end )