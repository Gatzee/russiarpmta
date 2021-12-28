-- Входная дверь в лабораторию
createObject( 2949, Vector3{ x = 1993.201, y = 1111.948 + 860, z = 15.393 }, Vector3{ x = 0.000, y = 0.000, z = 357.500 } )

local LABORATORY_MARKERS = {
    enter = {
        { x = -2743.32, y = -1829.24 + 860, z = 22.27 },
        { x = 1991.53, y = 1111.21 + 860, z = 16.39 },
    },
    exit = { x = -38.610, y = -35.300, z = 1952.806 },
}

local COLLECTING_MARKERS = {
    { x = -42.310, y = -18.769, z = 1951.038 },
    { x = -42.388, y = -15.545, z = 1951.038 },
    { x = -42.323, y = -11.044, z = 1951.038 },
    { x = -42.399, y = -7.945, z = 1951.038 },
    { x = -36.062, y = -9.244, z = 1951.038 },
    { x = -35.984, y = -11.816, z = 1951.038 },
    { x = -37.571, y = -11.762, z = 1951.038 },
    { x = -37.655, y = -14.277, z = 1951.038 },
    { x = -35.951, y = -14.456, z = 1951.038 },
    { x = -36.051, y = -16.938, z = 1951.038 },
    { x = -37.529, y = -16.942, z = 1951.038 },
    { x = -31.564, y = -17.557, z = 1951.045 },
    { x = -31.575, y = -16.185, z = 1951.038 },
    { x = -31.588, y = -14.638, z = 1951.038 },
    { x = -31.628, y = -9.775, z = 1951.038 },
    { x = -31.643, y = -7.924, z = 1951.038 },
    { x = -42.467, y = -17.396, z = 1951.038 },
    { x = -42.358, y = -9.541, z = 1951.038 },
}

local LAB_DIMENSION = 12

local COLLECTING_COOLDOWN_TS = 0

addEvent( "CHF:onClientCreateMarkers", true )
addEventHandler( "CHF:onClientCreateMarkers", resourceRoot, function( marker_cooldowns )
    for lab_id, conf in pairs( LABORATORY_MARKERS.enter ) do
        conf.marker_text = "Лаборатория"
        conf.text = "ALT Взаимодействие"
        conf.keypress = "lalt"
        conf.radius = 2
        conf.color = { 255, 168, 0, 70 }

        local tpoint = TeleportPoint( conf )
        tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.55 } )
        -- tpoint:SetImage( ":nrp_clans/img/tags/band/-2.png" )
        -- tpoint.element:setData( "material", true, false )
            
        tpoint.PostJoin = function( self, player )
            localPlayer:Teleport( LABORATORY_MARKERS.exit, LAB_DIMENSION + lab_id, 5, 500 )
        end
    end

    for marker_id, conf in pairs( COLLECTING_MARKERS ) do
        conf.interior = 5
        conf.dimension = localPlayer.dimension
        conf.text = "ALT Взаимодействие"
        conf.keypress = "lalt"
        conf.radius = 1
        conf.color = { 255, 168, 0, 70 }
    
        local tpoint = TeleportPoint( conf )
        -- tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255 } )
        -- tpoint:SetImage( ":nrp_clans/img/tags/band/-2.png" )
        -- tpoint.element:setData( "material", true, false )
            
        tpoint.PreJoin = function( self, player )
            return not isTimer( tpoint.cooldown_timer )
        end
            
        tpoint.PostJoin = function( self, player )
            local lab_id = localPlayer.dimension - LAB_DIMENSION
            triggerServerEvent( "CHF:onPlayerCollectHash", resourceRoot, lab_id, marker_id )
        end

        tpoint.SetCooldown = function( self, cooldown_ts )
            if cooldown_ts and cooldown_ts <= getRealTimestamp( ) then
                tpoint.element.interior = 5
                return
            end
            
            tpoint.element.interior = 11 -- Скрываем маркер

            if isTimer( tpoint.cooldown_timer ) then tpoint.cooldown_timer:destroy( ) end
            tpoint.cooldown_timer = setTimer( function( )
                if not isElement( tpoint.element ) then return end
                tpoint.element.interior = 5 -- Показываем обратно
            end, ( cooldown_ts and ( cooldown_ts - getRealTimestamp( ) ) or COLLECTING_COOLDOWN ) * 1000, 1 )
        end
    end
end )

addEvent( "CHF:UpdateMarkerCooldowns", true )
addEventHandler( "CHF:UpdateMarkerCooldowns", resourceRoot, function( marker_cooldowns )
    local lab_id = localPlayer.dimension - LAB_DIMENSION
    for marker_id, tpoint in pairs( COLLECTING_MARKERS ) do
        tpoint.dimension = LAB_DIMENSION + lab_id
        tpoint.element.dimension = LAB_DIMENSION + lab_id

        if marker_cooldowns[ marker_id ] then
            tpoint:SetCooldown( marker_cooldowns[ marker_id ] )
        else
            tpoint.element.interior = 5
        end
    end
end )

addEvent( "CHF:onClientCooldownMarker", true )
addEventHandler( "CHF:onClientCooldownMarker", resourceRoot, function( marker_id )
    if not isElement( COLLECTING_MARKERS[ marker_id ].element ) then return end
    COLLECTING_MARKERS[ marker_id ]:SetCooldown( )
end )

-- Маркер выхода из лаборатории

local conf = LABORATORY_MARKERS.exit
conf.interior = 5
conf.dimension = localPlayer.dimension
conf.radius = 2
conf.color = { 0, 120, 255, 40 }
conf.marker_text = "Выход на улицу"
conf.keypress = "lalt"
conf.text = "ALT Взаимодействие"

local tpoint = _TeleportPoint( conf ) -- _TeleportPoint чтобы не удалялся при очистке, маркер должен быть всегда на случай, если игрока выкинут из клана, когда он внутри
tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.55 } )
-- tpoint:SetImage( ":nrp_clans/img/tags/band/46.png" )
tpoint.element:setData( "material", true, false )

tpoint.PostJoin = function( self, player )
    local lab_id = localPlayer.dimension - LAB_DIMENSION
    localPlayer:Teleport( LABORATORY_MARKERS.enter[ lab_id ] or LABORATORY_MARKERS.enter[ 1 ], 0, 0, 500 )
end

-- 

local laboratory_col = createColCuboid( -44.617, -38.011, 1948, 15.954, 35.949, 10.000 )

addEventHandler( "onClientColShapeHit", laboratory_col, function( element, matching_dimension )
    if element ~= localPlayer then return end

    local lab_id = localPlayer.dimension - LAB_DIMENSION
    if lab_id == 1 or lab_id == 2 then
        triggerServerEvent( "CHF:onPlayerEnterLaboratory", resourceRoot, lab_id )
        localPlayer:setData( "in_hash_lab", true, false )

        LABORATORY_MARKERS.exit.element.dimension = LAB_DIMENSION + lab_id
        for i, tpoint in pairs( COLLECTING_MARKERS ) do
            tpoint.element.interior = 11 -- Скрываем маркер, покажем в UpdateMarkerCooldowns 
        end
    end
end )

addEventHandler( "onClientColShapeLeave", laboratory_col, function( element, matching_dimension )
    if element ~= localPlayer then return end

    localPlayer:setData( "in_hash_lab", false, false )

    local lab_id = localPlayer.dimension - LAB_DIMENSION
    triggerServerEvent( "CHF:onPlayerExitLaboratory", resourceRoot, lab_id )
end )