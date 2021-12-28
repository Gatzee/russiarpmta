Extend( "CPlayer" )
Extend( "CInterior" )

local ELEMENTS = { }

_TeleportPoint = TeleportPoint
TeleportPoint = function( ... )
    local tpoint = _TeleportPoint( ... )
    table.insert( ELEMENTS, tpoint )
    return tpoint
end

addEvent( "CHF:onClientCreateMarkers", true )
addEventHandler( "CHF:onClientCreateMarkers", resourceRoot, function( )
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
    enter = { x = -4.11, y = 82.32, z = 1267.28 },
    exit = { x = -71.648, y = -40.341, z = 1998.980 },
    ui = { x = -73.9, y = -33.717, z = 1998.980 },
}

addEvent( "onClientClanUpgrade", true )
addEventHandler( "onClientClanUpgrade", root, function( upgrade_id, upgrade_lvl )
    if upgrade_id == CLAN_UPGRADE_HASH_FACTORY and upgrade_lvl == 1 then
        triggerEvent( "CHF:onClientCreateMarkers", resourceRoot )
    end
end )

addEvent( "onClientClanUpgradesSync", true )
addEventHandler( "onClientClanUpgradesSync", root, function( upgrades )
    if ( upgrades[ CLAN_UPGRADE_HASH_FACTORY ] or 0 ) >= 1 then
        triggerEvent( "CHF:onClientCreateMarkers", resourceRoot )
    end
end )

addEvent( "CHF:onClientCreateMarkers", true )
addEventHandler( "CHF:onClientCreateMarkers", resourceRoot, function( )
    -- Маркер входа
    local conf = FACTORY_MARKERS.enter
    conf.interior = 1
    conf.dimension = localPlayer.dimension
    conf.marker_text = "Цех-Петрушки"
    conf.text = "ALT Взаимодействие"
    conf.keypress = "lalt"
    conf.radius = 2
    conf.color = { 255, 168, 0, 70 }

    local tpoint = TeleportPoint( conf )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.55 } )
    -- tpoint:SetImage( ":nrp_clans/img/tags/band/-2.png" )
    -- tpoint.element:setData( "material", true, false )
        
    tpoint.PostJoin = function( self, player )
        localPlayer:Teleport( FACTORY_MARKERS.exit, nil, 9, 300 )
    end


    -- Маркер интерфейса
    
    for i = 1, 2 do
        for j = 1, 6 do
            local conf = table.copy( FACTORY_MARKERS.ui )
            conf.x = conf.x + ( i - 1 ) * 3
            conf.y = conf.y + ( j - 1 ) * 3.959

            conf.interior = 9
            conf.dimension = localPlayer.dimension
            conf.radius = 1
            conf.color = { 0, 0, 0, 0 }
            -- conf.marker_text = "Цех-Петрушки"
            conf.keypress = "lalt"
            conf.text = "ALT Взаимодействие"

            local tpoint = TeleportPoint( conf )
            tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255 } )
            tpoint:SetImage( "img/marker_dry.png" )
            -- tpoint.element:setData( "material", true, false )
                
            tpoint.PostJoin = function( self, player )
                triggerServerEvent( "CHF:onPlayerWantShowUI", resourceRoot )
            end

            FACTORY_MARKERS[ "ui" .. i .. "_" .. j ] = tpoint
        end
    end
    FACTORY_MARKERS.exit.element.dimension = localPlayer.dimension
end )

-- Маркер выхода
local conf = FACTORY_MARKERS.exit
conf.interior = 9
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
        if marker.element then
            marker.dimension = localPlayer.dimension
            marker.element.dimension = marker.dimension
        end
    end
end )

-- На случай спавна внутри цеха при входе в игру (и его выкинули из клана, когда он был не в сети) (или если зареспавнят медики?)
addEventHandler( "onClientPlayerSpawn", localPlayer, function( )
    FACTORY_MARKERS.exit.element.dimension = localPlayer.dimension
end )