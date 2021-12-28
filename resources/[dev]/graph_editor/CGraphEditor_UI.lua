
ibUseRealFonts( true )

UI_elements = nil
LAST_NODE_ID = nil

MAP_ACTION_NONE = 1
MAP_ACTION_DRAG = 2

local CONST_6K = 6520
local CONST_3K = 3260

CONST_RADAR_CENTER_OFFSET_X = -58
CONST_RADAR_CENTER_OFFSET_Y = -7

CONST_RADAR_RENDERABLE_SIZE = 3000

CONST_U, CONST_V = 1, _SCREEN_Y / _SCREEN_X

ZOOM_STAGES = {
    1, 2.5, 5, 7.5, 10, 12.5, 15
}

DRAW_PATH = {}

function ShowGraphEditorUI( state )
    if state then
        ShowGraphEditorUI( false )

        UI_elements = {}
        UI_elements.black_bg = ibCreateBackground( 0xCC000000, ShowGraphEditorUI, true, true )
        
        UI_elements.bg_area = ibCreateArea( 0, 0, _SCREEN_X, _SCREEN_Y, UI_elements.black_bg ):ibData( "priority", 0 )
            
        UI_elements.shader = dxCreateShader( "fx/hud_mask.fx" )
        UI_elements.overlay_texture = dxCreateRenderTarget( CONST_6K, CONST_6K, true )
        UI_elements.overlay_render_texture = dxCreateRenderTarget( CONST_RADAR_RENDERABLE_SIZE, CONST_RADAR_RENDERABLE_SIZE, true )

        ibCreateButton( 30, 30, 120, 50, UI_elements.black_bg, "img/btn_save.png", "img/btn_save_hover.png", "img/btn_save_hover.png", 0xFFBBBBBB, 0xFFFFFFFF, 0xCCFFFFFF  )
		    :ibOnClick( function( button, state ) 
		    	if button ~= "left" or state ~= "down" then return end
                ibClick()
                ExportGraph()
		    end)

        local info_text = [[ПКМ - перемещение
ЛКМ - поставить точку
CTRL + ЛКМ - соединить точки
SHIFT + ПКМ - удалить точку
SHIFT + ЛКМ - строить непрерывно граф
Колесико мыши - приблизить/отдалить
g_nodes - показать линии в мире
g_reset - сбросить точки]]

        ibCreateLabel( 30, 100, 120, 50, info_text, UI_elements.black_bg, 0xFFFFFFFF, _, _, "left", "top", ibFonts.bold_14 )

        RADAR_ZOOM_STAGE = 1
        RADAR_MAP_ZOOM = ZOOM_STAGES[ RADAR_ZOOM_STAGE ]
        RADAR_MAP_MODE = MAP_ACTION_NONE
            
        dxSetShaderValue( UI_elements.shader, "sPicTexture", getMapTexture() )
        dxSetShaderValue( UI_elements.shader, "TexUV", 1, CONST_U, CONST_V )
        dxSetShaderValue( UI_elements.shader, "TexOverlay", UI_elements.overlay_texture )
        dxSetShaderValue( UI_elements.shader, "TexOverlayRender", UI_elements.overlay_render_texture )
        dxSetShaderValue( UI_elements.shader, "fMapAlphaMul", 1 )
        dxSetShaderValue( UI_elements.shader, "gUVScale", 1 / RADAR_MAP_ZOOM, 1 / RADAR_MAP_ZOOM * CONST_V )

        local drag_px, drag_py
        local click_px, click_py
        local start_drag_px, start_drag_py

        local function GetCurrentRealPositions( )
            local source_physics = getCameraTarget( localPlayer ) or getCamera( )
            local px, py = getElementPosition( source_physics )
            return px - CONST_RADAR_CENTER_OFFSET_X, py - CONST_RADAR_CENTER_OFFSET_Y, source_physics
        end
        
        local function GetMouseVec( mouse_px, mouse_py )
            return Vector2(
                ( mouse_px - ( UI_elements.bg_area:ibData( "px" ) + UI_elements.bg_img:ibData( "px" ) + UI_elements.bg_img:width( ) / 2 ) ) / UI_elements.bg_img:width( ) * 2,
                ( mouse_py - ( UI_elements.bg_area:ibData( "py" ) + UI_elements.bg_img:ibData( "py" ) + UI_elements.bg_img:height( ) / 2 ) ) / UI_elements.bg_img:height( ) * 2
            )
        end

        local function MouseToWorld( zoom, mouse_px, mouse_py )
            local vec_mouse = GetMouseVec( mouse_px, mouse_py )
            local divisor = Vector2( CONST_3K, -CONST_3K * CONST_V )
            return vec_mouse * divisor / zoom
        end

        function GetWorldPosition()
            local mouse_px, mouse_py = getCursorPosition( )
            mouse_px, mouse_py = mouse_px * _SCREEN_X, mouse_py * _SCREEN_Y
            return Vector2( drag_px, drag_py ) + MouseToWorld( RADAR_MAP_ZOOM, mouse_px, mouse_py ) + Vector2( CONST_RADAR_CENTER_OFFSET_X, CONST_RADAR_CENTER_OFFSET_Y )
        end

        UI_elements.bg_img = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, UI_elements.shader, UI_elements.bg_area )
            :ibOnRender( function( )
                local x, y = drag_px, drag_py

                if RADAR_MAP_MODE == MAP_ACTION_NONE then
                    x, y = GetCurrentRealPositions( )
                end

                local boundary_offset_x = CONST_3K - CONST_3K * 1 / RADAR_MAP_ZOOM * CONST_U 
                local boundary_offset_y = CONST_3K - CONST_3K * 1 / RADAR_MAP_ZOOM * CONST_V

                x = x > 0 and math.min( boundary_offset_x, x ) or math.max( -boundary_offset_x, x )
                y = y > 0 and math.min( boundary_offset_y, y ) or math.max( -boundary_offset_y, y )

                dxSetShaderValue( UI_elements.shader, "gUVPosition", x / CONST_6K, y / -CONST_6K )
                dxSetShaderValue( UI_elements.shader, "gUVScale", 1 / RADAR_MAP_ZOOM, 1 / RADAR_MAP_ZOOM * CONST_V )
                dxSetShaderValue( UI_elements.shader, "fAlphaMul", UI_elements.bg_area:ibData( "alpha" ) / 255 * 0.9 )

                drag_px, drag_py = x, y
            end )
        
        
        UI_elements.bg_img
            :ibOnClick( function( key, state )
                if key == "right" then
                    if state == "down" and getKeyState( "lshift" ) then
                        local world_pos = GetWorldPosition()
                        local remove = RemoveNode( world_pos.x, world_pos.y )
                        if remove then
                            UI_elements.update_nodes()
                        end
                    elseif state == "down" then
                        if RADAR_MAP_MODE ~= RADAR_MAP_MODE_DRAG then
                            RADAR_MAP_MODE = RADAR_MAP_MODE_DRAG
                            drag_px, drag_py = GetCurrentRealPositions( )
                        end

                        start_drag_px, start_drag_py = drag_px, drag_py

                        click_px, click_py = getCursorPosition( )
                        click_px, click_py = click_px * _SCREEN_X, click_py * _SCREEN_Y

                        removeEventHandler( "onClientPreRender", root, UI_elements.mouse_drag )
                        addEventHandler( "onClientPreRender", root, UI_elements.mouse_drag )
                    else
                        removeEventHandler( "onClientPreRender", root, UI_elements.mouse_drag )
                    end
                elseif key == "left" then
                    if getKeyState( "lctrl" ) then
                        if state == "down" and not UI_elements.start_node then
                            local world_pos = GetWorldPosition()
                            UI_elements.start_node = GetNodeByWorldPosition( world_pos.x, world_pos.y )
                        elseif state == "down" and UI_elements.start_node then
                            local world_pos = GetWorldPosition()
                            UI_elements.end_node = GetNodeByWorldPosition( world_pos.x, world_pos.y )
                            local is_add = AddNeighbours( UI_elements.start_node, UI_elements.end_node, getKeyState( "lalt" ) )
                            if is_add then 
                                UI_elements.update_nodes() 
                            end
                            UI_elements.start_node, UI_elements.end_node = nil, nil
                        end
                    else
                        if state == "down" then
                            local world_pos = GetWorldPosition()
                            local add_node = AddNode( world_pos.x, world_pos.y )
                            if add_node then
                                if getKeyState( "lshift" ) then
                                    local is_add = AddNeighbours( LAST_NODE_ID, add_node, getKeyState( "lalt" ) )
                                    if is_add then UI_elements.update_nodes() end
                                    LAST_NODE_ID = add_node
                                else
                                    LAST_NODE_ID = nil
                                end
                                UI_elements.update_nodes()
                            end
                        elseif target_node then
                            local world_pos = GetWorldPosition()
                            NODES[ target_node ].x = world_pos.x
                            NODES[ target_node ].y = world_pos.y
                            target_node = nil
                            UI_elements.update_nodes() 
                        end
                    end
                end
            end )

        UI_elements.mouse_drag = function( )
            local mouse_px, mouse_py = getCursorPosition( )
            mouse_px, mouse_py = mouse_px * _SCREEN_X, mouse_py * _SCREEN_Y
    
            drag_px = start_drag_px - (( mouse_px - click_px ) / UI_elements.bg_img:width( ) * CONST_6K / RADAR_MAP_ZOOM)
            drag_py = start_drag_py + (( mouse_py - click_py ) / UI_elements.bg_img:height( ) * CONST_6K / RADAR_MAP_ZOOM)    
        end

        UI_elements.scroll_handler = function( key, state, zoom_inc )
            if zoom_locked then return end
            if exports.nrp_ib:ibGetHoveredElement( ) ~= UI_elements.bg_img then return end

            RADAR_ZOOM_STAGE = zoom_inc == "closer" and math.min( #ZOOM_STAGES, RADAR_ZOOM_STAGE + 1 ) or zoom_inc == "farther" and math.max( 1, RADAR_ZOOM_STAGE - 1 ) or zoom_inc
    
            local start_zoom = RADAR_MAP_ZOOM
            local target_zoom = ZOOM_STAGES[ RADAR_ZOOM_STAGE ]

            local zoom_diff = target_zoom - start_zoom
    
            zoom_locked = UI_elements.bg_img:ibInterpolate( function( self )
                RADAR_MAP_ZOOM = start_zoom + ( zoom_diff * self.progress )
            end, 150, "Linear", function( self ) zoom_locked = nil end )
            
            -- Refresh size drag
            if RADAR_MAP_MODE == RADAR_MAP_MODE_DRAG then
                local base_px, base_py = drag_px, drag_py
    
                local mouse_px, mouse_py = getCursorPosition( )
                mouse_px, mouse_py = mouse_px * _SCREEN_X, mouse_py * _SCREEN_Y
    
                local vec_base = Vector2( base_px, base_py )
                local vec_offset = MouseToWorld( start_zoom, mouse_px, mouse_py ) - MouseToWorld( target_zoom, mouse_px, mouse_py )
    
                UI_elements.bg_img:ibInterpolate(function( self )
                    drag_px = base_px + vec_offset.x * self.progress
                    drag_py = base_py + vec_offset.y * self.progress
                end, 150, "Linear" )
            end
        end

        UI_elements.show_nodes = true
        UI_elements.update_nodes = function()
            dxSetRenderTarget( UI_elements.overlay_texture, true )
                local neighbours_completed = {}
                local colors = { 0xFFFF0000, 0xFF00FF00, 0xFFFF8800 }
                for k, v in pairs( NODES ) do
                    local dpx, dpy = ( v.x + CONST_3K - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K * CONST_6K, ( 1 - ( v.y + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_6K
                    for neighbour_key, neighbour_data in pairs( v.neighbours ) do
                        local neighbour_id = neighbour_data.id
                        if not neighbours_completed[ k .. neighbour_id ] and not neighbours_completed[ neighbour_id .. k ]then
                            local n_x, n_y = NODES[ neighbour_id ].x, NODES[ neighbour_id ].y
                            if neighbour_data.unidir then
                                local len = math.round( neighbour_data.distance / 2 )
                                n_x = v.x + ( (NODES[ neighbour_id ].x - v.x) * len) / math.sqrt( (v.x - NODES[ neighbour_id ].x )^2 + (v.y - NODES[ neighbour_id ].y)^2 )
                                n_y = v.y + ( (NODES[ neighbour_id ].y - v.y) * len) / math.sqrt( (v.x - NODES[ neighbour_id ].x )^2 + (v.y - NODES[ neighbour_id ].y)^2 )
                            else
                                neighbours_completed[ neighbour_id .. k ] = true
                                neighbours_completed[ k .. neighbour_id ] = true
                            end

                            local tpx, tpy = ( n_x + CONST_3K - CONST_RADAR_CENTER_OFFSET_X ) / CONST_6K * CONST_6K, ( 1 - ( n_y + CONST_3K - CONST_RADAR_CENTER_OFFSET_Y ) / CONST_6K ) * CONST_6K
                            if dpx ~= dpx or dpy ~= dpy or tpx ~= tpx or tpy ~= tpy  then
                                tpx, tpy = 0, 0
                            end
                            dxDrawLine( dpx, dpy, tpx, tpy, ibApplyAlpha( colors[ neighbour_data.unidir == k and 2 or 3 ], 100 ), 2 )
                        end
                    end

                    if UI_elements.show_nodes then
                        local icon_size = 6
                        local icon_size_half = icon_size / 2
                        dxDrawRectangle( dpx - icon_size_half, dpy - icon_size_half, icon_size, icon_size, 0xFF00FF00 )
                    end
                end
            
            dxSetRenderTarget( )
        end
        addEventHandler( "onClientRestore", root, UI_elements.update_nodes )
        
        UI_elements.onClientKey = function( key, state )
            if key == "lctrl" and not state then
                UI_elements.start_node, UI_elements.end_node = nil, nil
            elseif key == "mouse3" then
                UI_elements.show_nodes = not UI_elements.show_nodes
                UI_elements.update_nodes()
            end
        end
        addEventHandler( "onClientKey", root, UI_elements.onClientKey )

        UI_elements.update_nodes()

        bindKey( "mouse_wheel_up", "down", UI_elements.scroll_handler, "closer" )
        bindKey( "mouse_wheel_down", "down", UI_elements.scroll_handler, "farther" )
        
        showCursor( true )
    elseif isElement( UI_elements and UI_elements.black_bg ) then
        removeEventHandler( "onClientKey", root, UI_elements.onClientKey )
        removeEventHandler( "onClientPreRender", root, UI_elements.mouse_drag )
        destroyElement( UI_elements.black_bg )
        
        unbindKey( "mouse_wheel_up", "down", UI_elements.scroll_handler )
        unbindKey( "mouse_wheel_down", "down", UI_elements.scroll_handler )

        UI_elements = nil

        showCursor( false )
    end
end

addCommandHandler( "graph_editor", function()
    ShowGraphEditorUI( true )
end )