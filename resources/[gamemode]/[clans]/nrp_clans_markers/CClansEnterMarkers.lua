loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "Globals" )
Extend( "ShClans" )
Extend( "CInterior" )

for i, conf in pairs( CLAN_BASEMENT_MARKER_CONFIGS ) do
    conf.text = "ALT Взаимодействие"
    conf.keypress = "lalt"
    conf.radius = 2
    conf.color = { 0, 0, 0, 0 }

    local tpoint = TeleportPoint( conf )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255 } )
    tpoint:SetImage( ":nrp_clans/img/tags/band/-2.png" )
    tpoint.element:setData( "material", true, false )

    if not conf.cartel_id then
        tpoint.elements = { }
        tpoint.elements.blip = Blip( conf.x, conf.y, conf.z, 0, 2, 255, 255, 255, 255, 1, 500 )
        tpoint.elements.blip:setData( "extra_blip", 69, false )
    end
        
    tpoint.PostJoin = function( self, player )
        if player:GetBlockInteriorInteraction() then
            player:ShowInfo( "Вы не можете войти во время задания" )
            return false
        end
        
        if player:GetClanID( ) then
            if conf.cartel_id and not player:IsInCartelClan( ) then
                player:ShowError( "К этому подвалу имеют доступ только члены Картеля!" )
                return
            end
            triggerServerEvent( "onPlayerWantEnterClanHouse", player, conf.base_id )
        else
            if player:GetLevel( ) < 6 then
                player:ShowError( "Быть бандитом можно только с 6 уровня!" )
                return
            end
            if player:IsInFaction( ) then
                player:ShowError( "Ты не можешь быть бандитом, находясь во фракции!" )
                return
            end
            triggerEvent( "ShowClanCreateOrJoinUI", player, true, conf.base_id )
        end
    end
end




BUNKER_MARKERS = { }

function CreateClanBunkerMarkers( )
    -- Админ меню

    local conf = {
        x = 13.915, y = 84.282, z = 1267.282,
        interior = 1, 
        dimension = localPlayer.dimension,
        text = "ALT Взаимодействие",
        keypress = "lalt",
        radius = 2,
        color = { 0, 0, 0, 0 },
    }

    local tpoint = TeleportPoint( conf )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255 } )
    tpoint:SetImage( ":nrp_clans/img/tags/band/-2.png" )
    tpoint.element:setData( "material", true, false )
        
    tpoint.PostJoin = function( self, player )
        triggerServerEvent( "onPlayerWantShowClanManageUI", localPlayer )
    end

    BUNKER_MARKERS.admin_menu = tpoint

    -- Хранилище

    local conf = {
        x = 8.740, y = 77.453, z = 1267.282,
        interior = 1, 
        dimension = localPlayer.dimension,
        text = "ALT Взаимодействие",
        keypress = "lalt",
        radius = 2,
        color = { 0, 0, 0, 0 },
    }

    local tpoint = TeleportPoint( conf )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255 } )
    tpoint:SetImage( ":nrp_clans/img/tags/band/46.png" )
    tpoint.element:setData( "material", true, false )
        
    tpoint.PostJoin = function( self, player )
        triggerServerEvent( "onPlayerWantShowClanStorageUI", localPlayer )
    end

    BUNKER_MARKERS.storage = tpoint

    -- Выход на улицу

    local conf = {
        x = -4.37, y = 88.08, z = 1267.28,
        interior = 1, 
        dimension = localPlayer.dimension,
        text = "ALT Взаимодействие",
        keypress = "lalt",
        radius = 2,
        color = { 0, 120, 255, 40 },
        marker_text = "Выход на улицу",
    }

    local tpoint = TeleportPoint( conf )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.55 } )
    tpoint.element:setData( "material", true, false )  

    tpoint.PostJoin = function( self, player )
        triggerServerEvent( "onPlayerWantExitClanHouse", localPlayer )
    end
    
    BUNKER_MARKERS.exit = tpoint
end

function DestroyClanBunkerMarkers( )
    DestroyTableElements( BUNKER_MARKERS )
end

function onClientPlayerEnterClanBunker_handler( )
    DestroyClanBunkerMarkers( )
    CreateClanBunkerMarkers( )
    triggerEvent( "onClientPlayerEnterClanBunker", localPlayer )
end
-- addEvent( "onClientPlayerEnterClanBunker", true )
-- addEventHandler( "onClientPlayerEnterClanBunker", root, onClientPlayerEnterClanBunker_handler )

local bunker_col = createColCuboid( CLAN_BUNKER_INTERIOR_BOUNDING_BOX.position, CLAN_BUNKER_INTERIOR_BOUNDING_BOX.size )
function onClientColShapeHit_handler( element, matching_dimension )
    if element == localPlayer then
        onClientPlayerEnterClanBunker_handler( )
    end
end
addEventHandler( "onClientColShapeHit", bunker_col, onClientColShapeHit_handler )

function onClientPlayerSpawn_handler( )
    if localPlayer:isWithinColShape( bunker_col ) then
        onClientPlayerEnterClanBunker_handler( )

    elseif localPlayer.dimension == 1337 then
        local position = localPlayer.position
        local cartel_house = CARTEL_HOUSES_INTERIORS_BOUNDING_SPHERES
        if position:distance( cartel_house[ 1 ].position ) < cartel_house[ 1 ].radius then
            triggerServerEvent( "onPlayerSpawnedInCartelHouse", localPlayer, 1 )
        elseif position:distance( cartel_house[ 2 ].position ) < cartel_house[ 2 ].radius then
            triggerServerEvent( "onPlayerSpawnedInCartelHouse", localPlayer, 2)
        end
    end
end
addEventHandler( "onClientPlayerSpawn", localPlayer, onClientPlayerSpawn_handler )


-- Дома картелей

for i, data in pairs( CARTEL_HOUSES_MARKER_CONFIGS ) do
    local conf = data.enter_position
    conf.text = "ALT Взаимодействие"
    conf.keypress = "lalt"
    conf.radius = 2
    conf.color = { 0, 0, 0, 0 }

    local tpoint = TeleportPoint( conf )
    local r, g, b = unpack ( data.color )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", r, g, b, 255 } )
    tpoint:SetImage( ":nrp_clans/img/tags/cartel/" .. data.cartel_id .. ".png" )
    tpoint.element:setData( "material", true, false )
    tpoint.elements = { }
    tpoint.elements.blip = Blip( conf.x, conf.y, conf.z, data.blip_id, 3, r, g, b, 255, 1, 500 )
        
    tpoint.PostJoin = function( self, player )
        if player:GetBlockInteriorInteraction() then
            player:ShowInfo( "Вы не можете войти во время задания" )
            return false
        end
        if player:GetClanCartelID( ) ~= data.cartel_id then
            player:ShowError( "Вы не состоите в этом Картеле!" )
            return
        end
        triggerServerEvent( "onPlayerWantEnterCartelHouse", player, data.cartel_id )
    end

    local conf = data.exit_position
    local conf = {
        x = conf.x, y = conf.y, z = conf.z,
        interior = 1, 
        dimension = 1337,
        text = "ALT Взаимодействие",
        keypress = "lalt",
        radius = 2,
        color = { 0, 120, 255, 40 },
        marker_text = "Выход на улицу",
    }
    
    local tpoint = TeleportPoint( conf )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.55 } )
    tpoint.element:setData( "material", true, false )  

    tpoint.PostJoin = function( self, player )
        triggerServerEvent( "onPlayerWantExitCartelHouse", localPlayer )
    end
end

-- Админ. панель картелей

CARTEL_MARKERS = {
    { x = 459.208, y = -1194.545, z = 1096.587, interior = 1, dimension = 1337 },
    { x = 445.818, y = -1198.500, z = 1798.99, interior = 1, dimension = 1337 },
}

for cartel_id, data in pairs( CARTEL_MARKERS ) do
    local conf = data
    conf.text = "ALT Взаимодействие"
    conf.keypress = "lalt"
    conf.radius = 2
    conf.color = { 0, 0, 0, 0 }

    local tpoint = TeleportPoint( conf )
    local r, g, b = 255, 255, 255 --unpack ( data.color )
    tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", r, g, b, 255, 0.6 } )
    tpoint:SetImage( ":nrp_clans/img/tags/cartel/" .. cartel_id .. ".png" )
    tpoint.element:setData( "material", true, false )
    tpoint.elements = { }
    tpoint.elements.blip = Blip( conf.x, conf.y, conf.z, data.blip_id, 2, r, g, b, 255, 1, 500 )
    tpoint.elements.blip.dimension = data.dimension
        
    tpoint.PostJoin = function( self, player )
        if player:GetClanID( ) then
            triggerServerEvent( "onPlayerWantShowClanCartelUI", player )
        end
    end
end