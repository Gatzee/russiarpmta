local MARKERS = {
    {
        x = 1954, y = 125.4, z = 635.15, interior = 1, dimension = 1,
        faction = F_POLICE_PPS_GORKI,
        text = "ALT Взаимодействие",
        marker_text = "Ориентировки",
    },
    {
        x = -364, y = -795.85, z = 1065.15, interior = 1, dimension = 1,
        faction = F_POLICE_PPS_NSK,
        text = "ALT Взаимодействие",
        marker_text = "Ориентировки",
    },
    {
        x = -1662.556, y = 2653.172, z = 1899.010, interior = 1, dimension = 1,
        faction = F_POLICE_PPS_MSK,
        text = "ALT Взаимодействие",
        marker_text = "Ориентировки",
    },
}

function createOrderMarker( config )
    config.radius = 1.4
    config.keypress = "lalt"

    local point = TeleportPoint( config )
    point.elements = { }
    point.marker:setColor( 255, 255, 255, 20 )
    point.PostJoin = onMarkerAction
    point.PostLeave = onMarkerLeave
    point:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1 } )
end

function onMarkerAction( marker )
    local faction = localPlayer:GetFaction( )

    if faction ~= marker.faction then
        localPlayer:ShowError( "У тебя нет доступа" )
        return
    end

    components.orientationsMenu( true )
end

function onMarkerLeave( )
    components.orientationsMenu( false )
end

for _, marker in pairs( MARKERS ) do
    createOrderMarker( marker )
end