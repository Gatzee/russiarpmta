local getElementData = getElementData
local getBlipIcon = getBlipIcon
local targetPosition = nil
local UI, confirmation

CONST_INFOBOX_SIZE_X = 340

CONST_BOX_SIZE_X, CONST_BOX_SIZE_Y = _SCREEN_X, _SCREEN_Y

CONST_U, CONST_V = 1, CONST_BOX_SIZE_Y / CONST_BOX_SIZE_X

CONST_BOX_PX, CONST_BOX_PY = 0, math.floor( _SCREEN_Y / 2 - CONST_BOX_SIZE_Y / 2 )

CONST_INFOBOX_PX = _SCREEN_X - CONST_INFOBOX_SIZE_X - 20
CONST_INFOBOX_PY = 20

RADAR_MAP_MODE_FOLLOW = 1
RADAR_MAP_MODE_DRAG = 2

CONST_MAX_ZOOM = 20
CONST_MIN_ZOOM = 1
CONST_ZOOM_MUL = 20

ZOOM_STAGES = {
    1, 2, 2.5,
}

CONST_MAP_SHOW_SPEED = 200

function IsCanShowHideMap()
    if localPlayer:getData( "block_hide_map" ) then 
        return false 
    end 
    return true
end

function IsCanShowMyPosition()
    if localPlayer:getData( "block_my_position" ) then 
        return false 
    end 
    return true
end

MAP_CONTROL_KEYS = {
    nonTarget = {
        { "M", "вкл/выкл карту", IsCanShowHideMap },
        { "G", "вкл/выкл легенду" },
        { "N", "текущее местоположение", IsCanShowMyPosition },
        { "mouse_rmb", "метка" },
        { "mouse_middle", "приближение карты" },
    },
    withTarget = {
        { "M", "спрятать карту", IsCanShowHideMap },
        { "N", "текущее местоположение цели", IsCanShowMyPosition },
        { "Z", "рация" },
        { "mouse_middle", "приближение карты" },
    }
}

CONST_MAP_LEGEND = {
    { { 28, 29 }, "Автосалон" },
    { 30, "Мотосалон" },
    { 44, "Казино" },
    { 52, "Бизнес" },
    { 42, "Работа: Грузчик" },
    { 56, "Работа: Таксист" },
    { 43, "Работа: Водитель автобуса" },
    { 35, "Работа: Сотрудник ЖКХ" },
    { 5, "Авиасалон" },
    { 36, "Автошкола" },
    { 31, "Дом/квартира" },
    { 33, "Заправка" },
    { 27, "Ремонтная мастерская" },
    { 10, "Еда" },
    { 40, "Аптека" },
    { 62, "Работа: Работник парка" },
    { 59, "Охота, Охотничий магазин" },
    { 60, "Сокровища, Магазин лопат" },
    { 61, "Рыбалка, Рыболовный магазин" },
    { 45, "Магазин одежды" },
    { 51, "Работа: Курьер" },
    { 48, "Школа танцев" },
    { 54, "Бойцовский клуб" },
    { 63, "Тюнинг-салон" },
    { 9, "Порты" },
    { 34, "Работа: Фермер" },
    { 58, "Автомеханик" },
    { 6, "Кланы: Вост. Картель" },
    { 7, "Кланы: Зап. Картель" },
    { 11, "Авиашкола" },
    { 12, "Обслуживание авиатехники" },
    { 13, "Работа: Дальнобойщик" },
    { 14, "Продажа транспорта гос-ву" },
    { 16, "Кинотеатр" },
    { 20, "Работа: Дровосек" },
    { 65, "Работа: Эвакуаторщик" },
    { 66, "Стрип клуб" },
    { 67, "Церковь" },
    { 68, "Оружейный магазин" },
    { 71, "Дом" },
    { 72, "Работа: Инкассатор" },
    { 73, "Бизнес центр" },
    { 75, "Зона рыбалки" },
    { 76, "Работа: Мусорщик" },
    { 8, "Работа: Лётчик" },
    { 77, "Работа: Доставка транспорта" },
    { 78, "Заданная точка" },
    { 79, "Работа: Промышленная рыбалка" },
    { 82, "Работа: Угон транспорта" },
    { 83, "Авторынок" },
    { 19, "Биржа" },
    { 3, "Опасные задания" },
}

table.sort( CONST_MAP_LEGEND, function( a, b ) return a[ 2 ] < b[ 2 ] end )
table.insert( CONST_MAP_LEGEND, 1, { "41_legend", "Точка назначения" } )
table.insert( CONST_MAP_LEGEND, 2, { "80_legend", "Точка назначения" } )
table.insert( CONST_MAP_LEGEND, 3, { "81_legend", "Точка назначения" } )
table.insert( CONST_MAP_LEGEND, 4, { "84_legend", "Метка игрока" } )

function ShowRadarMap( hide_legend )
    HideRadarMap( )

    ibUseRealFonts( true )

    UI = { }

    local map_texture = GetRadarMapTexture( )
    UI.overlay_texture = dxCreateRenderTarget( CONST_6K, CONST_6K, true )
    local overlay_render_texture = HUD_CONFIGS.radar.elements.overlay_render_texture

    showCursor( true, "radar_map" )

    UI.black_bg = ibCreateBackground( 0x00000000, function()
        if IGNORE_KEYPRESS then return end
        HideRadarMap() 
    end, _, true )
    local area = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, _, UI.black_bg, 0xaa000000 ):ibData( "priority", 0 ):ibData( "alpha", 0 )

    UI.shader = dxCreateShader( "fx/hud_mask.fx" )

    RADAR_ZOOM_STAGE = 1
    RADAR_MAP_ZOOM = ZOOM_STAGES[ RADAR_ZOOM_STAGE ]
    RADAR_MAP_MODE = RADAR_MAP_MODE_FOLLOW

    dxSetShaderValue( UI.shader, "sPicTexture", map_texture )
    dxSetShaderValue( UI.shader, "TexUV", 1, CONST_U, CONST_V )
    dxSetShaderValue( UI.shader, "TexOverlay", UI.overlay_texture )
    dxSetShaderValue( UI.shader, "TexOverlayRender", overlay_render_texture )
    dxSetShaderValue( UI.shader, "fMapAlphaMul", 1 )

    local bg_img = ibCreateImage( CONST_BOX_PX, CONST_BOX_PY, CONST_BOX_SIZE_X, CONST_BOX_SIZE_Y, UI.shader, area )

    if not hide_legend then
        local controlKeys = getTargetOnMap( ) and MAP_CONTROL_KEYS.withTarget or MAP_CONTROL_KEYS.nonTarget
        local npy = _SCREEN_Y - 45
        local bg_controls = ibCreateArea( 0, npy, 1, 20, area )
        local panel_width = 0
        local lets_starts = { }

        for i, v in pairs( controlKeys ) do
            if not v[ 3 ] or v[ 3 ]() then
                local img = nil

                if utf8.len( v[ 1 ] ) > 4 then
                    img = ibCreateImage( 0, 0, 18, 26, "img/radar/" .. v[ 1 ] .. ".png", bg_controls )
                else
                    img = ibCreateImage( 0, 0, 26, 26, "img/radar/key_bg.png", bg_controls )
                    ibCreateLabel( 0, 0, 26, 26, v[ 1 ], img, _, _, _, "center", "center", ibFonts.bold_12 )
                end

                if img then
                    local lbl = ibCreateLabel( img:ibGetAfterX( 10 ), img:ibGetCenterY( ), 0, 0, "-  " .. v[ 2 ], img, nil, nil, nil, "left", "center", ibFonts.bold_14 )

                    lets_starts[ i ] = { panel_width, img }
                    panel_width = panel_width + lbl:ibGetAfterX( 10 )
                end
            end
        end

        bg_controls:center_x( - panel_width / 2 )
        bg_controls:ibData( "sx", panel_width )

        for i, v in pairs( lets_starts ) do
            if lets_starts[ i ] then
                v[ 2 ]:ibData( "px", v[ 1 ] )
            end
        end
    end

    local function GetBlips( )
        local blips = getElementsByType( "blip" )
        local radarareas = getElementsByType( "radararea" )
        local interior = getElementInterior( localPlayer )
        local dimension = getElementDimension( localPlayer )

        local suitable_blips = { }
        for i, v in pairs( blips ) do
            if getBlipIcon( v ) > 0 and v.dimension == dimension and v.interior == interior and not v:getData( "is_hide" ) then
                table.insert( suitable_blips, v )
            end
        end
        for i, v in pairs( radarareas ) do
            if v.dimension == dimension and v.interior == interior then
                table.insert( suitable_blips, v )
            end
        end

        return suitable_blips
    end

    local function GetCurrentRealPositions( )
        local source_physics = getCameraTarget( localPlayer ) or getCamera( )
        local px, py = 0, 0

        if targetPosition then px, py = targetPosition.x, targetPosition.y
        else px, py = getElementPosition( source_physics )
        end

        return px - CONST_RADAR_CENTER_OFFSET_X, py - CONST_RADAR_CENTER_OFFSET_Y, source_physics
    end

    local targetAnim = { alpha = 200, dir = false }

    local drag_px, drag_py
    bg_img:ibOnRender( function( )
        local x, y

        if RADAR_MAP_MODE == RADAR_MAP_MODE_FOLLOW then
            x, y = GetCurrentRealPositions( )
        else
            x, y = drag_px, drag_py
        end

        local boundary_offset_x = CONST_3K - CONST_3K * 1 / RADAR_MAP_ZOOM * CONST_U 
        local boundary_offset_y = CONST_3K - CONST_3K * 1 / RADAR_MAP_ZOOM * CONST_V

        x = x > 0 and math.min( boundary_offset_x, x ) or math.max( -boundary_offset_x, x )
        y = y > 0 and math.min( boundary_offset_y, y ) or math.max( -boundary_offset_y, y )

        dxSetShaderValue( UI.shader, "gUVPosition", x / CONST_6K, y / -CONST_6K )
        dxSetShaderValue( UI.shader, "gUVScale", 1 / RADAR_MAP_ZOOM, 1 / RADAR_MAP_ZOOM * CONST_V )
        dxSetShaderValue( UI.shader, "fAlphaMul", area:ibData( "alpha" ) / 255 * 0.9 )

        drag_px, drag_py = x, y

        dxSetRenderTarget( overlay_render_texture, false )
            -- Локальный игрок / камера
            local _, _, source_physics = GetCurrentRealPositions( )
            local _, _, rotation = getElementRotation( source_physics )

            local scale = 1.5
            local px, py = 0, 0

            if targetPosition then px, py = targetPosition.x, targetPosition.y
            else px, py = getElementPosition( source_physics )
            end
            
            local dpx, dpy = ( px + CONST_3K - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K * CONST_RADAR_RENDERABLE_SIZE, ( 1 - ( py + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_RADAR_RENDERABLE_SIZE

            local icon_size = scale * CONST_RADAR_BLIP_SIZE * CONST_RADAR_RENDERABLE_SIZE_SCALE
            local icon_size_half = icon_size / 2

            if targetPosition then
                if targetAnim.dir then
                    targetAnim.alpha = targetAnim.alpha + 1
                    if targetAnim.alpha > 170 then targetAnim.dir = false end
                else
                    targetAnim.alpha = targetAnim.alpha - 1
                    if targetAnim.alpha < 100 then targetAnim.dir = true end
                end

                dxDrawRectangle( dpx - 50, dpy - 50, 100, 100, tocolor( 255, 0, 0, targetAnim.alpha ) )
            else
                dxDrawImage( dpx - icon_size_half, dpy - icon_size_half, icon_size, icon_size, "img/radar/icon_player.png", -rotation )
            end

        dxSetRenderTarget( )
    end )

    UI.scroll_handler = function( key, state, zoom_inc )
        if zoom_locked then return end
        if exports.nrp_ib:ibGetHoveredElement( ) ~= bg_img then return end

        if zoom_inc == "closer" then
            RADAR_ZOOM_STAGE = math.min( #ZOOM_STAGES, RADAR_ZOOM_STAGE + 1 )
        elseif zoom_inc == "farther" then
            RADAR_ZOOM_STAGE = math.max( 1, RADAR_ZOOM_STAGE - 1 )
        else
            RADAR_ZOOM_STAGE = zoom_inc
        end

        local duration = 150
        local interpolation = "Linear"
        
        local from_zoom = RADAR_MAP_ZOOM
        local target_zoom = ZOOM_STAGES[ RADAR_ZOOM_STAGE ]

        local zoom_diff = target_zoom - from_zoom

        zoom_locked = bg_img:ibInterpolate(
            function( self )
                RADAR_MAP_ZOOM = from_zoom + zoom_diff * self.progress
            end
        , duration, interpolation, 
        function( self ) zoom_locked = nil end )

        if RADAR_MAP_MODE == RADAR_MAP_MODE_DRAG then
            local base_px, base_py = drag_px, drag_py

            local mouse_px, mouse_py = getCursorPosition( )
            mouse_px, mouse_py = mouse_px * x, mouse_py * y

            local function GetMouseVec( )
                local vec_mouse = Vector2(
                    ( mouse_px - ( area:ibData( "px" ) + bg_img:ibData( "px" ) + bg_img:width( ) / 2 ) ) / bg_img:width( ) * 2,
                    ( mouse_py - ( area:ibData( "py" ) + bg_img:ibData( "py" ) + bg_img:height( ) / 2 ) ) / bg_img:height( ) * 2
                )
                return vec_mouse
            end

            local divisor = Vector2( CONST_3K, -CONST_3K * CONST_V )

            local function MouseToWorld( zoom )
                local vec_mouse = GetMouseVec( )
                return vec_mouse * divisor / zoom
            end

            local function WorldToMouse( world, zoom )
                return world / divisor * zoom
            end

            local vec_base = Vector2( base_px, base_py )
            local vec_offset = MouseToWorld( from_zoom ) - MouseToWorld( target_zoom )

            bg_img:ibInterpolate(
                function( self )
                    drag_px = base_px + vec_offset.x * self.progress
                    drag_py = base_py + vec_offset.y * self.progress
                end,
            duration, interpolation )
        end
    end

    local start_drag_px, start_drag_py
    local click_px, click_py
    UI.RenderMouseDragging = function( )
        local mouse_px, mouse_py = getCursorPosition( )
        mouse_px, mouse_py = mouse_px * x, mouse_py * y

        local diff_px = ( mouse_px - click_px ) / bg_img:width( ) * CONST_6K / RADAR_MAP_ZOOM
        local diff_py = ( mouse_py - click_py ) / bg_img:height( ) * CONST_6K / RADAR_MAP_ZOOM

        drag_px, drag_py = start_drag_px - diff_px, start_drag_py + diff_py
    end

    bg_img:ibOnClick( function( key, state )
        if key == "left" then
            if state == "down" then
                if RADAR_MAP_MODE ~= RADAR_MAP_MODE_DRAG then
                    RADAR_MAP_MODE = RADAR_MAP_MODE_DRAG
                    drag_px, drag_py = GetCurrentRealPositions( )
                end

                start_drag_px, start_drag_py = drag_px, drag_py

                click_px, click_py = getCursorPosition( )
                click_px, click_py = click_px * x, click_py * y

                removeEventHandler( "onClientPreRender", root, UI.RenderMouseDragging )
                addEventHandler( "onClientPreRender", root, UI.RenderMouseDragging )
            end
        elseif key == "right" and not targetPosition then
            if state == "down" then
                if exports.nrp_help:IsGPSEnabled( ) then
                    if confirmation then confirmation:destroy( ) end
                    confirmation = ibConfirm(
                        {
                            title = "ОТКЛЮЧИТЬ МЕТКУ", 
                            text = "Ты действительно хочешь убрать текущую метку?\nДанное действие нельзя отменить" ,
                            fn = function( self )
                                setSoundVolume( playSound( "sfx/radar_set_point.mp3", false ), 1 )
                                triggerEvent( "DisableGPS", localPlayer )
                                UI.UpdateBlips( )
                                self:destroy()
                            end,
                            escape_close = true,
                        }
                    )
                else
                    local mouse_px, mouse_py = getCursorPosition( )
                    mouse_px, mouse_py = mouse_px * x, mouse_py * y

                    local function GetMouseVec( )
                        local vec_mouse = Vector2(
                            ( mouse_px - ( area:ibData( "px" ) + bg_img:ibData( "px" ) + bg_img:width( ) / 2 ) ) / bg_img:width( ) * 2,
                            ( mouse_py - ( area:ibData( "py" ) + bg_img:ibData( "py" ) + bg_img:height( ) / 2 ) ) / bg_img:height( ) * 2
                        )
                        return vec_mouse
                    end

                    local divisor = Vector2( CONST_3K, -CONST_3K * CONST_V )
                    local function MouseToWorld( zoom )
                        local vec_mouse = GetMouseVec( )
                        return vec_mouse * divisor / zoom
                    end

                    local world_pos = Vector2( drag_px, drag_py ) + MouseToWorld( RADAR_MAP_ZOOM ) + Vector2( CONST_RADAR_CENTER_OFFSET_X, CONST_RADAR_CENTER_OFFSET_Y )
                    setSoundVolume( playSound( "sfx/radar_set_point.mp3", false ), 1 )

                    triggerEvent( "ToggleGPS", localPlayer,
                        Vector3( world_pos.x, world_pos.y, localPlayer.position.z ),
                        false, false, false, true
                    )
                end
            end
        end
    end )
    addEventHandler( "ibOnMouseRelease", bg_img, function( )
        removeEventHandler( "onClientPreRender", root, UI.RenderMouseDragging )
    end )

    UI.UpdateBlips = function( )
        if targetPosition then return end

        dxSetRenderTarget( UI.overlay_texture, true )
            if GPS.draw_path then
                for i = #GPS.draw_path - 1, 1, -1 do
                    local start_node = GPS.draw_path[ i ] 
                    local finish_node = GPS.draw_path[ i - 1 ]
                    if start_node and finish_node then
                        local dpx, dpy = ( start_node.x + CONST_3K - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K * CONST_6K, ( 1 - ( start_node.y + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_6K
                        local tpx, tpy = ( finish_node.x + CONST_3K - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K * CONST_6K, ( 1 - ( finish_node.y + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_6K
                        dxDrawLine( dpx, dpy, tpx, tpy, 0xFFFF8800, 5 )
                    end
                end
            end

            for i, v in pairs( getElementsByType( "blip" ) ) do
                local icon = getElementData( v, "extra_blip" ) or getBlipIcon( v )

                if icon >= 0 and v.dimension == localPlayer.dimension and not v:getData( "is_hide" ) then
                    local big_s = { [ 41 ] = true, [ 80 ] = true, [ 81 ] = true, [ 84 ] = true, }
                    local scale = big_s[ icon ] and 3 or getBlipSize( v ) / 2
                    local px, py, pz = getElementPosition( v )
                    local dpx, dpy = ( px + CONST_3K - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K * CONST_6K, ( 1 - ( py + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_6K
                    local icon_size = scale * CONST_RADAR_BLIP_SIZE
                    local icon_size_half = icon_size / 2

                    if icon ~= 0 then
                        local color = getElementData( v, "extra_blip_color" ) or 0xFFFFFFFF
                        dxDrawImage( dpx - icon_size_half, dpy - icon_size_half, icon_size, icon_size, "img/radar/blips/" .. icon .. ".png", 0, 0, 0, color )
                        if icon == 84 then
                            local player = getElementData( v, "extra_blip_element" )
                            dxDrawText( player:GetNickName(), dpx + icon_size / 4, dpy - icon_size / 2, 0, dpy, color, 1, 1, ibFonts.bold_30, "left", "center" )
                        end
                    end
                end
            end

            for _, v in pairs( getElementsByType( "radararea" ) ) do
                if v.dimension == localPlayer.dimension then
                    local px, py = getElementPosition( v )
                    local sx, sy = getRadarAreaSize( v )
                    local r, g, b, a = getRadarAreaColor( v )
                    local dpx, dpy = px + CONST_3K - CONST_RADAR_CENTER_OFFSET_X, ( 1 - ( py + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_6K
                    local dsx, dsy = sx, sy
                    dxDrawRectangle( dpx, dpy, dsx, dsy, tocolor( r, g, b, a ) )
                end
            end
        dxSetRenderTarget( )
    end
    FUNC_UPDATE_BLIPS_RADAR_MAP = UI.UpdateBlips

    addEventHandler( "RefreshRadarBlips", localPlayer, UI.UpdateBlips )
    addEventHandler( "onClientRestore", root, UI.UpdateBlips )

    UI.UpdateBlips( )

    local last_blips = { }
    bg_img:ibTimer( function( self )
        self:ibTimer( function( )
            local function reverse( tbl )
                local n = { }
                for i, v in pairs( tbl ) do
                    n[ v ] = true
                end
                return n
            end

            local function blips_identical( tbl1, tbl2 )
                for i, v in pairs( tbl1 ) do
                    if not tbl2[ i ] then
                        return false
                    end 
                end

                for i, v in pairs( tbl2 ) do
                    if not tbl1[ i ] then
                        return false
                    end 
                end

                return true
            end

            local blips = GetBlips( )
            local blips_updated = not blips_identical( reverse( blips ), reverse( last_blips ) )
            
            if blips_updated then
                UI.UpdateBlips( )
                last_blips = blips
            end
        end, CONST_RADAR_BLIPS_REFRESH_RATE, 0 )
    end, CONST_MAP_SHOW_SPEED, 1 )

    bindKey( "mouse_wheel_up", "down", UI.scroll_handler, "closer" )
    bindKey( "mouse_wheel_down", "down", UI.scroll_handler, "farther" )

    local px = CONST_INFOBOX_PX
    local py = CONST_INFOBOX_PY
    local sy = _SCREEN_Y - py - 20
    local bg_legend = ibCreateImage( x, py, CONST_INFOBOX_SIZE_X, sy, _, area, ibApplyAlpha( 0xff2a323c, 85 ) ):ibData( "alpha", 0 )
    ibCreateImage( 0, 50, bg_legend:width( ), 1, _, bg_legend, ibApplyAlpha( COLOR_WHITE, 25 ) )
    ibCreateLabel( 0, 0, bg_legend:width( ), 50, "Легенда", bg_legend, _, _, _, "center", "center", ibFonts.regular_14 )

    local rt, sc = ibCreateScrollpane( 0, 51, CONST_INFOBOX_SIZE_X, sy - 51, bg_legend, { scroll_px = -20 } )
    sc
        :ibSetStyle( "slim_nobg" )
        :ibBatchData( { sensivity = 100, absolute = true, color = 0x99ffffff } )

    local npy = 15
    for i, v in pairs( CONST_MAP_LEGEND ) do
        local img
        if type( v[ 1 ] ) == "table" then
            for i, k in pairs( v[ 1 ] ) do
                img = ibCreateImage( 20 + ( img and ( img:width( ) + 5 ) or 0 ), npy, 26, 26, "img/radar/blips/" .. k .. ".png" , rt )
            end
        else
            img = ibCreateImage( 20, npy, 26, 26, "img/radar/blips/" .. v[ 1 ] .. ".png" , rt )
        end

        if img then
            ibCreateLabel( img:ibGetAfterX( 14 ), img:ibGetCenterY( ), 0, 0, v[ 2 ], rt, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_12 )

            npy = npy + 26 + 10
        end
    end

    rt:ibData( "sy", math.max( rt:ibData( "viewport_sy" ), npy ) )
    sc:UpdateScrollbarVisibility( rt )

    if not getTargetOnMap( ) then
        local legend_state
        UI.ShowLegend = function( key, state )
            legend_state = not legend_state
            bg_legend:ibAlphaTo( legend_state and 255 or 0, 300 )
            bg_legend:ibMoveTo( legend_state and px or _SCREEN_X, _, 300 )
        end
        bindKey( "g", "down", UI.ShowLegend )
    end

    UI.ShowMyLocation = function( key, state )
        if not IsCanShowMyPosition() then return end
        
        RADAR_ZOOM_STAGE = #ZOOM_STAGES
        RADAR_MAP_ZOOM = ZOOM_STAGES[ RADAR_ZOOM_STAGE ]
        RADAR_MAP_MODE = RADAR_MAP_MODE_FOLLOW
    end
    bindKey( "n", "down", UI.ShowMyLocation )

    addEvent( "SetHUDMapFollowSelf", true )
    addEventHandler( "SetHUDMapFollowSelf", root, UI.ShowMyLocation )

    UI.area = area
    
    area:ibMoveTo( 0, 0, CONST_MAP_SHOW_SPEED ):ibAlphaTo( 255, CONST_MAP_SHOW_SPEED )

    ibUseRealFonts( false )
end
addEvent( "ShowRadarMap" )
addEventHandler( "ShowRadarMap", resourceRoot, ShowRadarMap )

function onClientChangePriorityRadarMap_handler( priority )
    if not UI or not isElement( UI.black_bg ) or not tonumber( priority ) then return end
    UI.black_bg:ibData( "priority", priority )
end
addEvent( "onClientChangePriorityRadarMap" )
addEventHandler( "onClientChangePriorityRadarMap", root, onClientChangePriorityRadarMap_handler )

function HideRadarMap( )
    if UI then
        unbindKey( "mouse_wheel_up", "down", UI.scroll_handler )
        unbindKey( "mouse_wheel_down", "down", UI.scroll_handler )
        unbindKey( "g", "down", UI.ShowLegend )
        unbindKey( "n", "down", UI.ShowMyLocation )

        removeEventHandler( "RefreshRadarBlips", localPlayer, UI.UpdateBlips )
        removeEventHandler( "onClientRestore", root, UI.UpdateBlips )
        removeEventHandler( "onClientPreRender", root, UI.RenderMouseDragging )
        removeEventHandler( "SetHUDMapFollowSelf", root, UI.ShowMyLocation )

        if confirmation then confirmation:destroy( ) end

        -- sputnik sync
        targetPosition = nil
        triggerEvent( "updateTargetPositionBySputnik", localPlayer )
    end

    FUNC_UPDATE_BLIPS_RADAR_MAP = nil
    DestroyTableElements( UI )
    UI = nil

    showCursor( false, "radar_map" )
end

function SetMapIgnoreKeypress_handler( state )
    IGNORE_KEYPRESS = state
end
addEvent( "SetMapIgnoreKeypress", true )
addEventHandler( "SetMapIgnoreKeypress", root, SetMapIgnoreKeypress_handler )

function ToggleRadarMap( )
    if IGNORE_KEYPRESS then return end

    if UI then
        HideRadarMap( )
    else
        if not PARENT:ibData( "visible" ) then return end
        if not IsHUDBlockActive( "radar" ) then return end
        ShowRadarMap( )
    end
end
bindKey( "m", "down", ToggleRadarMap )
bindKey( "f11", "down", ToggleRadarMap )

function SetHUDMapState_handler( state, hide_legend )
    if state then
        ShowRadarMap( hide_legend )
    else
        HideRadarMap( )
    end
end
addEvent( "SetHUDMapState", true )
addEventHandler( "SetHUDMapState", root, SetHUDMapState_handler )

function getTargetOnMap( )
    return targetPosition and targetPosition or nil
end

function showTargetOnMap_handler( position )
    targetPosition = position

    if not UI then
        AddHUDBlock( "radar" )
        ShowRadarMap( )
    end

    UI.ShowMyLocation( )
end
addEvent( "showTargetOnMap", true )
addEventHandler( "showTargetOnMap", root, showTargetOnMap_handler )