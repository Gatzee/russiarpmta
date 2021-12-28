local auto_school_markers_enterances = { }
local auto_school_marker_exit = nil

SCHOOL_MARKETS_INTERFACE_LIST =
{
    { x = 2300.4128, y = -2347.6696 + 860, z = 21.263, radius = 2, keypress = "lalt", text = "ALT Взаимодействие", marker_text = "Авиашкола", color = { 0, 100, 255, 40 } },
    { x = -2514.907, y = 380.412 + 860,   z = 16.023, radius = 2, keypress = "lalt", text = "ALT Взаимодействие", marker_text = "Авиашкола", color = { 0, 100, 255, 40 } },
    { x = 451.8218,	 y = -1200.2188, z = 1189.85, interior = 1, dimension = 1, radius = 1.3, keypress = "lalt", text = "ALT Взаимодействие", marker_image = "img/auto/green.png", marker_text = "Автошкола", color = { 0, 255, 0, 100 } },
    { x = 451.8218,	 y = -1203.5480, z = 1189.85, interior = 1, dimension = 1, radius = 1.3, keypress = "lalt", text = "ALT Взаимодействие", marker_image = "img/auto/green.png", marker_text = "Автошкола", color = { 0, 255, 0, 100 } },
    { x = 451.8218,	 y = -1207.0500, z = 1189.85, interior = 1, dimension = 1, radius = 1.3, keypress = "lalt", text = "ALT Взаимодействие", marker_image = "img/auto/green.png", marker_text = "Автошкола", color = { 0, 255, 0, 100 } },
}

SCHOOL_MARKERS_ENTRANCES_LIST =
{
    { x = 410.678, y = -2079.557 + 860, z = 21.853, marker_text = "Автошкола", color = { 255, 255, 255, 50 }, interior = 0, dimension = 0, radius = 1.5, iNumber = 1 },
    { x = 2145.19, y = -877.77 + 860, z = 62.62, marker_text = "Автошкола", color = { 255, 255, 255, 50 }, interior = 0, dimension = 0, radius = 1.5, iNumber = 2, },}

SCHOOL_MARKERS_EXITS_LIST =
{
    { x = 443.0, y = -1207.6, z = 1189.9, marker_text = "Выход на улицу", color = { 255, 255, 255, 50 }, interior = 1, dimension = 1, radius = 1.5 }
}

function OnClientResourceStart( )
    for k,v in pairs( SCHOOL_MARKETS_INTERFACE_LIST ) do
        if v.marker_text == "Автошкола" then
            CreateMarkerInterfaceAuto( v )
        elseif v.marker_text == "Авиашкола" then
            CreateMarkerInterfaceAir( v, k )
        end
    end

    for k,v in pairs( SCHOOL_MARKERS_EXITS_LIST ) do
        CreateMarkerExit( v )
    end

    for k,v in pairs( SCHOOL_MARKERS_ENTRANCES_LIST ) do
        CreateMarkerEnterance( v, k )
    end
end
addEventHandler( "onClientResourceStart", resourceRoot, OnClientResourceStart )

function CreateMarkerInterfaceAuto( data )
    local created_marker = TeleportPoint( data )
    created_marker.element:setData( "material", true, false )
    created_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1 } )

    created_marker.PreJoin = function( self , player )
        if player:GetBlockInteriorInteraction() then
            player:ShowInfo( "Вы не можете войти во время задания" )
            return false
        end
		return true
    end

    created_marker.PostJoin = function( self )
        OnShowUIAutoSchool_handler( true, "main" )
    end

    created_marker.PostLeave = function( self )
        OnShowUIAutoSchool_handler( false )
    end
end

function CreateMarkerInterfaceAir( data, i )
    local created_marker = TeleportPoint( data )
    created_marker.elements = { }
	created_marker.elements.blip = Blip( data.x, data.y, data.z, 11, 2, 255, 0, 0, 255, 0, 300 )
    created_marker:SetImage( "img/air/icon_marker.png" )
    created_marker.element:setData( "material", true, false )
    created_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.45 } )

    created_marker.PreJoin = function( self , player )
        if player:GetBlockInteriorInteraction() then
            player:ShowInfo( "Вы не можете войти во время задания" )
            return false
        end
		return true
    end

    created_marker.PostJoin = function( self )
		OnShowUIAirSchool_handler( true, i )
    end

    created_marker.PostLeave = function( self )
        OnShowUIAirSchool_handler( false )
    end
end

function CreateMarkerEnterance( data, i )
    local created_marker = TeleportPoint( data )
    created_marker.elements = { }
    created_marker.elements.blip = createBlipAttachedTo( created_marker.marker, 36 )
    created_marker.element:setData( "material", true, false )
    created_marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.15 } )

    created_marker.text = "ALT Взаимодействие"
    created_marker.teleport = auto_school_marker_exit
    created_marker.iNumber = data.iNumber

    created_marker.PreJoin = function( self, player )
        if player:GetBlockInteriorInteraction() then
            player:ShowInfo( "Вы не можете войти во время задания" )
            return false
        end
        player:setData( "iDrivingSchool", created_marker.iNumber, false )
        triggerEvent( "onPlayerEnterDrivingSchool", player )
        return true
    end

    created_marker.PostJoin = function( self, player )
        player:CompleteDailyQuest( "np_visit_autoschool" )
        return true
    end

    auto_school_markers_enterances[ i ] = created_marker
end

function CreateMarkerExit( data )
    auto_school_marker_exit = TeleportPoint( data )
    auto_school_marker_exit.text = "ALT Взаимодействие"
    auto_school_marker_exit.element:setData( "material", true, false )
    auto_school_marker_exit:SetDropImage( { ":nrp_shared/img/dropimage.png", 255, 255, 255, 255, 1.15 } )

    auto_school_marker_exit.PreJoin = function( self, player )
        local i = getElementData( player, "iDrivingSchool" ) or 1
        auto_school_marker_exit.teleport = auto_school_markers_enterances[ i ]
        return true
    end

    auto_school_marker_exit.PostJoin = function( self, player )
        player:setData( "iDrivingSchool", false, false )
        return true
    end
end