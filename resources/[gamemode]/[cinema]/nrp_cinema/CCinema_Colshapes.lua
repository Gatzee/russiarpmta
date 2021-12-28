COLSHAPE_ELEMENTS = { }
MARKERS = { }
GENERATED_GREEN_ZONES = { }

function IsWithinCinemaQuest( )
    local quest_data = localPlayer:getData( "current_quest" )
    return quest_data and quest_data.id == "angela_cinema"
end

function RecheckColshapes( )
    local room_to_join
    if getElementInterior( localPlayer ) == 1 and not IsWithinCinemaQuest( ) then
        for i, v in pairs( COLSHAPE_ELEMENTS ) do
            if isElementWithinColShape( localPlayer, v ) then
                room_to_join = i
            end
        end
    end

    if not CURRENT_ROOM or room_to_join and GetShapeNumFromRoomID( room_to_join ) ~= CURRENT_ROOM then
        if room_to_join then
            LeaveRooms( true )
            JoinRoom( room_to_join )
        end
    else
        if not room_to_join then
            LeaveRooms( true )
        end
    end
end

function onPlayerMarkerJoin( self )
    local room_num = GetRoomIDFromShapeNum( self.i )
    triggerServerEvent( "onCinemaRequestRoomInformation", resourceRoot, room_num )
end


function onPlayerCinemaEnter_handler( )
    RecheckColshapes( )

    RECENT_CINEMA_DIMENSION = getElementDimension( localPlayer )
    for i, v in pairs( ROOMS_CONFIG ) do
        local position = v.marker
        if position then
            local conf = {
                id        = "cinema_" .. i,
                text      = "ALT Взаимодействие",
                x         = position[ 1 ],
                y         = position[ 2 ],
                z         = position[ 3 ],
                PostJoin  = onPlayerMarkerJoin,
                PostLeave = function( ) ShowPlaylistUI_handler( false ) ShowRoomUI_handler( false ) end,
                dimension = RECENT_CINEMA_DIMENSION,
                interior  = 1,
                radius    = 2,
                color     = { 150, 0, 255, 10 },
                i         = i,
            }
            local tpoint = TeleportPoint( conf )
            tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 150, 255, 150, 1.45 } )
            table.insert( MARKERS, tpoint )
        end
    end

    for i, position in pairs( MOVELIST_MARKERS ) do
        local conf = {
            id          = "cinema_movelist_" .. i,
            marker_text = "Афиша",
            text        = "ALT Взаимодействие",
            x           = position[ 1 ],
            y           = position[ 2 ],
            z           = position[ 3 ],
            PostJoin    = function( ) triggerServerEvent( "onCinemaRequestMovieList", localPlayer, getElementDimension( localPlayer ) ) end,
            dimension   = RECENT_CINEMA_DIMENSION,
            interior    = 1,
            radius      = 3,
            color       = { 255, 0, 0, 10 },
            i           = i,
        }
        local tpoint = TeleportPoint( conf )
        tpoint:SetImage( "img/marker.png" )
        tpoint.element:setData( "material", true, false )
        tpoint:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 2 } )
        table.insert( MARKERS, tpoint )
    end

    -- При смене измерения, повторный запрос на кино
    MAINTAIN_DIMENSION_TIMER = setTimer( function( )
        if RECENT_CINEMA_DIMENSION ~= getElementDimension( localPlayer ) then
            onPlayerCinemaLeave_handler( )
            IS_INSIDE_CINEMA = nil
        end
    end, 1000, 0 )

    if not GENERATED_GREEN_ZONES[ RECENT_CINEMA_DIMENSION ] then
        triggerEvent( "CreateSphericalGreenZone", localPlayer, { position = Vector3( -295.348, -405.422, 1353.649 ), size = 70, interior = 1, dimension = RECENT_CINEMA_DIMENSION } )
        GENERATED_GREEN_ZONES[ RECENT_CINEMA_DIMENSION ] = true
    end

end
addEvent( "onPlayerCinemaEnter", true )
addEventHandler( "onPlayerCinemaEnter", root, onPlayerCinemaEnter_handler )

function onPlayerCinemaLeave_handler( )
    for i, v in pairs( MARKERS ) do
        if type( v ) == "table" then v:destroy( ) end
    end
    MARKERS = { }
    if isTimer( MAINTAIN_DIMENSION_TIMER ) then killTimer( MAINTAIN_DIMENSION_TIMER ) end
    MAINTAIN_DIMENSION_TIMER = nil
end
addEvent( "onPlayerCinemaLeave", true )
addEventHandler( "onPlayerCinemaLeave", root, onPlayerCinemaLeave_handler )


function RecheckColshapesWithDelay( )
    if isTimer( RECHECK_TIMER ) then killTimer( RECHECK_TIMER ) end
    RECHECK_TIMER = setTimer( RecheckColshapes, 50, 1 )
end

function GetRoomIDFromShapeNum( i )
    return localPlayer.dimension * 100 + i
end

function JoinRoom( i )
    if not CURRENT_ROOM then
        CURRENT_ROOM = GetRoomIDFromShapeNum( i )
        triggerServerEvent( "onCinemaRoomEnter", resourceRoot, CURRENT_ROOM )
    end
end

function LeaveRooms( force )
    if CURRENT_ROOM or force then
        RemoveBrowserFromScreens( )
        triggerEvent( "DestroyCinemaDimmer", localPlayer, true )
        if CURRENT_ROOM then
            triggerServerEvent( "onCinemaRoomLeave", resourceRoot, CURRENT_ROOM )
            CURRENT_ROOM = nil
        end
    end
end

addEventHandler( "onClientResourceStart", resourceRoot, function( )
    for i, conf in pairs( ROOMS_CONFIG ) do
        local shape     = createColPolygon( unpack( conf.positions ) )
        shape.interior  = 1

        addEventHandler( "onClientColShapeHit", shape, function( player )
            if player ~= localPlayer then return end
            if localPlayer.interior ~= 1 then return end
            RecheckColshapesWithDelay( )
        end )

        addEventHandler( "onClientColShapeLeave", shape, function( player )
            if player ~= localPlayer then return end
            RecheckColshapesWithDelay( )
        end )

        table.insert( COLSHAPE_ELEMENTS, shape )
    end
end )