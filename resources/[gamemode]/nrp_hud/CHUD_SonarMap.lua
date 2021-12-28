local ui
local coeff_sonar = 2
local sonar_data = {
    ship = nil,
    fishes = { },
    sonar_depth = 0,
    fish_depth = 0,
}

SONAR_CONTROL_KEYS = {
    {
        keys = { "K" }, 
        text = "Закрыть эхолокатор" 
    },
    {
        keys = { "˄", "˅" }, 
        text = "Уровень Глубины" 
    },
}

SONAR_LEGEND = {
    { "ship", "Корабль и направление" },
    { "fish", "Рыба" },
}

function onClientUpdateSonar_handler( data, timer )
    for type, value in pairs( data ) do
        sonar_data[ type ] = value
        sonar_data.timer = timer and ( getRealTimestamp( ) + 2 ) or 0

        if type == "direction" then
            UpdateAnimationDepthSonar( value )
        end
    end
end
addEvent( "onClientUpdateSonar", true )
addEventHandler( "onClientUpdateSonar", root, onClientUpdateSonar_handler )

function UpdateAnimationDepthSonar( direction )
    if not ui.depth_sonar then return end
    ui.depth_sonar:ibData( "rotation", 0 )

    ui.depth_sonar:ibRotateTo( direction and 360 or -360, 1500, "InQuad" )
end

function UpdateAnimationSearchSonar( )
    if not ui.serach then return end
    ui.serach:ibData( "rotation", 0 )

    ui.serach:ibRotateTo( 360, 4000, "Linear" )
end

function ShowSonarMap( )
    HideSonarMap( )
    ibUseRealFonts( true )

    ui = { }
    ui.fishes = { }

    ui.bg = ibCreateBackground( 0x00000000, _, _, true )
    ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, "img/bg_sonar.png", ui.bg )
    ibCreateImage( 0, 0, 520, 520, "img/bg_sonar_line.png", ui.bg ):center( )
    ui.serach = ibCreateImage( 0, 0, 440, 440, "img/bg_sonar_search.png", ui.bg ):center( )
        :ibTimer( UpdateAnimationSearchSonar, 4000, 0 )
    UpdateAnimationSearchSonar( )

    ui.depth_sonar = ibCreateImage( 0, 0, 518, 518, "img/bg_sonar_depth.png", ui.bg ):center( )
    ui.depth_icon = ibCreateImage( 0, 0, 518, 518, "img/bg_sonar_depth_icon.png", ui.bg ):center( )
    
    ui.depth_text = ibCreateLabel( 0, 0, 0, 0, "Глубина: ", ui.bg, _, _, _, "center", "center", ibFonts.regular_16 ):center( -30, -310 )
    ui.depth = ibCreateLabel( 40, 0, 0, 0, sonar_data.sonar_depth or 0, ui.depth_text, _, _, _, "left", "center", ibFonts.bold_18 )
    ui.depth_type = ibCreateLabel( ui.depth:width( ) + 10, 0, 0, 0, " М", ui.depth, _, _, _, "center", "center", ibFonts.regular_16 )

    ui.ship = ibCreateImage( 0, 0, 72, 72, "img/radar/blips/ship.png", bg ):center( )

    --эхолокатор
    ui.ship:ibOnRender( function( )
        if not sonar_data.ship then HideSonarMap( ) return end

        ui.depth:ibData( "text", sonar_data.sonar_depth )
        ui.depth_type:ibData( "px", ui.depth:width( ) + 10 )

        local ship_rotation = sonar_data.ship and sonar_data.ship.rotation.z or 0
        ui.ship:ibData( "rotation", - ship_rotation or 0 )

        if not sonar_data.fishes then return end

        for k, fish in ipairs( sonar_data.fishes ) do
            if isElement( fish.point_shape ) and sonar_data.sonar_depth == sonar_data.fish_depth and getRealTimestamp( ) >= sonar_data.timer then
                local ship_position = sonar_data.ship.position
                local fish_position = fish.point_shape.position
                local px = ( fish_position.x - ship_position.x ) * coeff_sonar + 26
                local py = ( ship_position.y - fish_position.y ) * coeff_sonar + 26

                if ui.fishes[ k ] then
                    ui.fishes[ k ]:ibBatchData( { px = px, py = py } )
                else
                    local fish_img = ibCreateImage( px, py, 20, 20, "img/radar/blips/fish.png", ui.ship )
                    table.insert( ui.fishes, fish_img )
                end
            else
                if ui.fishes[ k ] then
                    ui.fishes[ k ]:destroy( )
                    table.remove( ui.fishes, k )
                end
            end
        end
    end )

    --управление
    local control_sy = 88 + ( #SONAR_CONTROL_KEYS - 1 ) * 10  + #SONAR_CONTROL_KEYS * 26
    local bg_controls = ibCreateImage( CONST_INFOBOX_PX, CONST_INFOBOX_PY, CONST_INFOBOX_SIZE_X, control_sy, _, ui.bg, ibApplyAlpha( 0xff2a323c, 85 ) )
    local npy = 68

    ibCreateImage( 0, 50, bg_controls:width( ), 1, _, bg_controls, ibApplyAlpha( COLOR_WHITE, 25 ) )
    ibCreateLabel( 20, 0, bg_controls:width( ), 50, "Управление", bg_controls, _, _, _, "left", "center", ibFonts.regular_14 )

    for i, element in pairs( SONAR_CONTROL_KEYS ) do
        local img

        for k, key in pairs( element.keys ) do
            img = ibCreateImage( 20 + ( ( k - 1 ) * 36 ), npy, 26, 26, "img/radar/key_bg.png", bg_controls )
            ibCreateLabel( 0, 0, 26, 26, key, img, _, _, _, "center", "center", ibFonts.bold_12 )
        end

        ibCreateLabel( img:ibGetAfterX( 14 ), img:ibGetCenterY( ), 0, 0, element.text, bg_controls, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_12 )
        npy = npy + 26 + 10
    end

    --легенда
    local legend_sy = 88 + ( #SONAR_LEGEND - 1 ) * 10  + #SONAR_LEGEND * 26
    local bg_legend = ibCreateImage( CONST_INFOBOX_PX, bg_controls:ibGetAfterY( 20 ), CONST_INFOBOX_SIZE_X, legend_sy, _, ui.bg, ibApplyAlpha( 0xff2a323c, 85 ) )
    local npy = 68

    ibCreateImage( 0, 50, bg_legend:width( ), 1, _, bg_legend, ibApplyAlpha( COLOR_WHITE, 25 ) )
    ibCreateLabel( 20, 0, bg_legend:width( ), 50, "Информация", bg_legend, _, _, _, "left", "center", ibFonts.regular_14 )

    for i, element in pairs( SONAR_LEGEND ) do
        local img = ibCreateImage( 20 , npy, 26, 26, "img/radar/blips/" .. element[ 1 ] .. ".png", bg_legend )
        ibCreateLabel( img:ibGetAfterX( 14 ), img:ibGetCenterY( ), 0, 0, element[ 2 ], bg_legend, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_12 )
        npy = npy + 26 + 10
    end
end

function HideSonarMap( )
    DestroyTableElements( ui )
    ui = nil
end

function ToggleSonarMap_handler( )
    if ui then
        HideSonarMap( )
    else
        if not IsHUDBlockActive( "radar" ) then return end
        ShowSonarMap( )
    end
end
addEvent( "ToggleSonarMap" )
addEventHandler( "ToggleSonarMap", root, ToggleSonarMap_handler )

function SetHUDSonarState_handler( state, clean )
    if state then
        ShowSonarMap( )
    else
        HideSonarMap( )
        if clean then
            sonar_data = {
                ship = nil,
                fishes = { },
                sonar_depth = 0,
                fish_depth = 0,
            }
        end
    end
end
addEvent( "SetHUDSonarState", true )
addEventHandler( "SetHUDSonarState", root, SetHUDSonarState_handler )