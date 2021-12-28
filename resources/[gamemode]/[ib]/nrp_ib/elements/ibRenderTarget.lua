local E_CLASS = "ibRenderTarget"

local DEFAULT_VALUES = {
    visible     = true,
    priority    = 0,

    px          = 0,
    py          = 0,
    sx          = 0,
    sy          = 0,
    color       = 0xFFFFFFFF,
    rotation    = 0,
    rotation_offset_x = 0,
    rotation_offset_y = 0,

    viewport_px = 0,
    viewport_py = 0,

    transparent     = true,

    alpha           = 255,
    
    modify_content_alpha = true,
}

local allowed_keys = {
    mouse_wheel_up      = true,
    mouse_wheel_down    = true,
}

function ibRenderTarget( self, resource )
    if type( self ) ~= "table" then
        outputDebugString( "Bad argument @ibRenderTarget[1], expect table got ".. type( self ), 1 )
        return
    end
    local sourceResource = sourceResource or resource or _THIS_RESOURCE
    local element = ibCreateNewElementOfClass( self, E_CLASS, sourceResource )
    ibSetDefaultValues( self, DEFAULT_VALUES )

    triggerEvent( "ibOnElementCreate", element, self, E_CLASS, sourceResource )

    local render_target

    local function RecreateRenderTarget( )
        local render_target_current = render_target
        if isElement( render_target_current ) then destroyElement( render_target_current ) end

        local sx, sy, transparent = ibGetData( element, "sx" ), ibGetData( element, "sy" ), ibGetData( element, "transparent" )
        
        render_target = dxCreateRenderTarget( sx, sy, transparent )
        ibSetData( element, "render_target", render_target )
    end
    RecreateRenderTarget( )

    local function renderTargetAdaptHeightToContents( )
        local viewport_sy       = ibGetData( element, "viewport_sy" )
        local max_height        = 0

        local children = getElementChildren( element )
        for i, child in pairs( children ) do
            local py = ibGetData( child, "py" )
            local sy = ibGetData( child, "viewport_sy" ) or ibGetData( child, "sy" )

            max_height          = math.max( max_height, py + sy )
        end

        local new_sy = math.max( max_height, viewport_sy )

        ibSetData( element, "sy", new_sy ) 
    end
    addEventHandler( "ibRenderTargetAdaptHeightToContents", element, renderTargetAdaptHeightToContents, false )

    addEventHandler( "ibOnElementDataChange", element, function( key, value, old )
        if key == "viewport_sx" or key == "viewport_sy" then
            if ibGetData( element, "connectedScrollbarH" ) or ibGetData( element, "connectedScrollbarV" ) then
                RecreateRenderTarget( )
            end

        elseif key == "connectedScrollbarH" or key == "connectedScrollbarV" then
            local scrollbar = isElement( value ) and value
            if scrollbar then
                ibSetData( scrollbar, "connectedRenderTarget", element )

                local sx, sy = ibGetData( element, "sx" ), ibGetData( element, "sy" )
                
                local viewport_sx, viewport_sy = ibGetData( element, "viewport_sx" ), ibGetData( element, "viewport_sy" )
               
                ibSetData( element, "viewport_sx", viewport_sx or sx )
                ibSetData( element, "viewport_sy", viewport_sy or sy )

                RecreateRenderTarget( )
            end
        end
    end, false )

    addEventHandler( "onClientElementDestroy", element, function()
        if isElement( render_target ) then destroyElement( render_target ) end
    end, false, "high" )

    -- Обработка скролла по РТ
    addEventHandler( "ibOnClientKey", element, function( key, state )
        if not allowed_keys[ key ] or not state then return end

        local parent_element = element
        repeat
            if not _IB_ELEMENT_DATA[ parent_element ].visible then
                return
            end
            parent_element = parent_element.parent
        until not _IB_ELEMENT_DATA[ parent_element ]

        local data                      = _IB_ELEMENT_DATA[ element ]
        local scrollbar                 = data.connectedScrollbarV or data.connectedScrollbarH

        if data.disabled or not scrollbar then return end

        local scrollbar_data            = _IB_ELEMENT_DATA[ scrollbar ]

        local px, py                    = data.real_px, data.real_py
        local sx, sy                    = data.sx, data.sy

        local viewport_sx, viewport_sy  = data.viewport_sx or sx, data.viewport_sy or sy

        if isMouseWithinRangeOf( px, py, viewport_sx, viewport_sy ) then
            -- Поддержка абсолютной чувствительности скролла
            local sensivity = scrollbar_data.sensivity
            if scrollbar_data.absolute then sensivity = sensivity / data.sy end

            -- Плавный скроллинг
            if scrollbar_data.smooth then
                triggerEvent( "ibSmoothScrollAdd", scrollbar, key, sensivity / 4, 1 / data.sy )

            -- Попиксельный скроллинг
            else
                if key == "mouse_wheel_up" then
                    ibSetData( scrollbar, "position", scrollbar_data.position - sensivity )
                elseif key == "mouse_wheel_down" then
                    ibSetData( scrollbar, "position", scrollbar_data.position + sensivity )
                end
            end
        end

    end, true )

    return element
end

local dxDrawImage        = dxDrawImage
local dxSetBlendMode     = dxSetBlendMode
local dxSetRenderTarget  = dxSetRenderTarget
local dxDrawImageSection = dxDrawImageSection
local table_sort         = table.sort
local math_floor         = math.floor
local pairs              = pairs
local getElementChildren = getElementChildren

_RENDER_FUNCTIONS[ E_CLASS ] = function( element, data, parent_px, parent_py, mouse_px, mouse_py, alpha, detect_px, detect_py, detect_sx, detect_sy )
    local data_px, data_py          = data.px, data.py
    local px, py                    = parent_px + data_px, parent_py + data_py

    local relative_alpha = alpha * data.alpha
    local alpha          = data.modify_content_alpha and 255 or relative_alpha

    if alpha > 0 then

        local render_target             = data.render_target
        local sx, sy                    = data.sx, data.sy
        local viewport_px, viewport_py  = math_floor( data.viewport_px or 0 ), math_floor( data.viewport_py or 0 )
        local viewport_sx, viewport_sy  = math_floor( data.viewport_sx or sx ), math_floor( data.viewport_sy or sy )
        local npx, npy                  = mouse_px + data_px - viewport_px, mouse_py + data_py - viewport_py

        local element_children = getElementChildren( element )
        table_sort( element_children, ibSortByPriority )

        local ibRenderElementRecursive = ibRenderElementRecursive

        local old_render_target = RENDER_TARGET

        dxSetRenderTarget( render_target, true )
            RENDER_TARGET = render_target
            
            for i, v in pairs( element_children ) do
                local child_py = _IB_ELEMENT_DATA[ v ].py
                local child_sy = _IB_ELEMENT_DATA[ v ].sy

                local child_px = _IB_ELEMENT_DATA[ v ].px
                local child_sx = _IB_ELEMENT_DATA[ v ].sx

                if child_py + child_sy >= viewport_py and child_py <= viewport_py + viewport_sy
                    and child_px + child_sx >= viewport_px and child_px <= viewport_px + viewport_sx
                        then
                            dxSetBlendMode( data.blend_mode or "modulate_add" )

                            if old_render_target then
                                data.real_px = detect_px + px
                                data.real_py = detect_py + py
                                ibRenderElementRecursive( element, v, -viewport_px, -viewport_py, npx, npy, data.modify_content_alpha and relative_alpha / 255 or 1, detect_px + px, detect_py + py, viewport_sx, viewport_sy )
                            
                            else
                                data.real_px = px
                                data.real_py = py
                                ibRenderElementRecursive( element, v, -viewport_px, -viewport_py, npx, npy, data.modify_content_alpha and relative_alpha / 255 or 1, px, py, viewport_sx, viewport_sy )
                            
                            end
                end
            end

        if old_render_target then
            RENDER_TARGET = old_render_target
            dxSetRenderTarget( old_render_target )
        else
            RENDER_TARGET = nil
            dxSetRenderTarget( )
        end
        dxSetBlendMode( data.blend_mode_after or "add" )

        if not data.no_render_to_screen then
            dxDrawImage(
                px, py, viewport_sx, viewport_sy,
                render_target,
                data.rotation,
                data.rotation_offset_x, data.rotation_offset_y,
                ColorMulAlpha( data.color, alpha ), data.postgui
            )
        end

        dxSetBlendMode( "blend" )
    end
end

addEvent( "ibRenderTargetAdaptHeightToContents", true )