local E_CLASS = "ibScrollbarV"

local DEFAULT_VALUES = {
    visible         = true,
    priority        = 0,

    px              = 0,
    py              = 0,
    sx              = 0,
    sy              = 0,
    position        = 0,

    bg_texture = false, 
    bg_px = 0, bg_py = 0, 
    bg_color = 0x33FFFFFF,

    handle_texture = false, 
    handle_px = 0, handle_py = 0, 
    handle_color = 0XFFFFFFFF,

    sensivity       = 0.1,
    smooth          = true,

    alpha           = 255,
}

addEvent( "ibSmoothScrollAdd" )

function ibScrollbarV( self, resource )
    if type( self ) ~= "table" then
        outputDebugString( "Bad argument @ibScrollbarV[1], expect table got ".. type( self ), 1 )
        return
    end
    
    local sourceResource = sourceResource or resource or _THIS_RESOURCE
    local element = ibCreateNewElementOfClass( self, E_CLASS, sourceResource )
    ibSetDefaultValues( self, DEFAULT_VALUES )

    triggerEvent( "ibOnElementCreate", element, self, E_CLASS, sourceResource )


    local handle_conf = { }

    handle_conf.texture     = self.handle_texture
    handle_conf.sx          = self.handle_sx or self.sx
    handle_conf.sy          = self.handle_sy or self.sx
    handle_conf.px          = self.handle_px or 0
    handle_conf.py          = self.handle_py or 0
    handle_conf.upper_limit = self.handle_upper_limit or 0
    handle_conf.lower_limit = self.handle_lower_limit or 0
    handle_conf.original_px = handle_conf.px
    handle_conf.original_py = handle_conf.py


    local handle = ibButton( handle_conf, sourceResource )
    setElementParent( handle, element )
    ibSetData( handle, "bg", element )
    ibSetData( element, "handle", handle )

    addEventHandler( "ibOnElementMouseClick", handle, function( key, state )
        if key ~= "left" or state ~= "down" then return end
        if ibGetData( handle, "dragging" ) then return end

        local mouse = Vector2( CURSOR_X, CURSOR_Y )
        ibSetData( handle, "dragging", mouse )
    end, false )

    addEventHandler( "ibOnMouseRelease", handle, function( key, state )
        if not ibGetData( handle, "dragging" ) then return end

        ibSetData( handle, "dragging", false )
    end )

    local function setScroll( value )
        local handle_offset = ibGetData( handle, "original_py" ) or 0

        local y_min = handle_offset + ( ibGetData( handle, "lower_limit" ) or 0 )
        local y_max = ibGetData( element, "sy" ) + handle_offset + ( ibGetData( handle, "upper_limit" ) or 0 )
        local y_new = value and ( y_min + ( y_max - y_min ) * value ) or ibGetData( handle, "py" ) or 0
    
        y_new = y_new > y_max and y_max or y_new < y_min and y_min or y_new
    
        local position = ( y_new - y_min ) / ( y_max - y_min )
        _IB_ELEMENT_DATA[ element ].position = position

        ibSetData( handle, "py", y_new )

        triggerEvent( "ibOnScrollbarChange", element, y_new, position )
    end
    
    addEventHandler( "ibOnScrollbarChange", element, function( absolute, relative )
        local render_target = ibGetData( element, "connectedRenderTarget" )

        if isElement( render_target ) then
            local viewport_sy = ibGetData( render_target, "viewport_sy" )
            local sy          = ibGetData( render_target, "sy" )
            
            local viewport_py = sy > viewport_sy and ( sy - viewport_sy ) * relative or 0

            ibSetData( render_target, "viewport_py", viewport_py )
        end
    end )

    -- Поддержка плавного скроллинга
    local tick_last, key_last, inertia_threshold, fling_velocity = 0
    local function RenderSmoothScroll( )
        local scrollPosition = ibGetData( element, "position" )
        local inertia_acceleration = ibGetData( element, "inertia_acceleration" ) or 0.95
        local inertia_scroll_factor = ibGetData( element, "inertia_scroll_factor" ) or 0.9

        scrollPosition = scrollPosition + fling_velocity * inertia_scroll_factor
        fling_velocity = fling_velocity * inertia_acceleration

        if math.abs( fling_velocity ) < inertia_threshold then
            fling_velocity = 0
            removeEventHandler( "ibOnRender", element, RenderSmoothScroll )
        end
        
        scrollPosition = scrollPosition > 1 and 1 or scrollPosition < 0 and 0 or scrollPosition

        ibSetData( element, "position", scrollPosition )
    end

    addEventHandler( "ibSmoothScrollAdd", element, function( key, sensivity, precision )
        local tick_now = getTickCount( )

        inertia_threshold = precision
        if key_last ~= key then
            if fling_velocity and fling_velocity > 0 then
                tick_last, fling_velocity = tick_now, 0
                key_last = key
                return
            end
        end
        
        local delta_bottom_boundary = ibGetData( element, "delta_bottom_boundary" ) or 50
        local delta_top_boundary    = ibGetData( element, "delta_bottom_boundary" ) or 500
        local delta_divisor         = ibGetData( element, "delta_bottom_boundary" ) or 100

        local delta = math.max( delta_bottom_boundary, math.min( delta_top_boundary, ( tick_now - tick_last ) ) ) / delta_divisor

        fling_velocity = key == "mouse_wheel_up" and -sensivity / delta or key == "mouse_wheel_down" and sensivity / delta

        removeEventHandler( "ibOnRender", element, RenderSmoothScroll )
        addEventHandler( "ibOnRender", element, RenderSmoothScroll )

        tick_last, key_last = tick_now, key
    end, false )

    -- Обновление позиции скроллера
    addEventHandler( "ibOnElementDataChange", element, function( key, value, old )
        if key == "position" then
            setScroll( value )
            
        elseif key == "sy" then
            setScroll( )
        
        elseif key == "style" then
            setScroll( )

        -- Перехват установки данных для хендла
        elseif utf8.sub( key, 1, 7 ) == "handle_" then
            ibSetData( handle, utf8.sub( key, 8, -1 ), value )

        end
    end )

    setScroll()

    return element
end

local dxDrawImage           = dxDrawImage
local isElement             = isElement
local dxDrawRectangle       = dxDrawRectangle

_RENDER_FUNCTIONS[ E_CLASS ] = function( element, data, parent_px, parent_py, mouse_px, mouse_py, alpha )
    local px, py        = parent_px + data.px, parent_py + data.py

    local alpha        = alpha * data.alpha

    if alpha > 0 then

        -- Отрисовка фона
        local bg_px, bg_py = px + ( data.bg_px or 0 ), py + ( data.bg_py or 0 )
        local bg_sx, bg_sy = data.bg_sx or data.sx, data.bg_sy or data.sy
        local bg_texture   = ConvertToForeignFile( element, data.bg_texture )

        if isElement( bg_texture ) then
            dxDrawImage( 
                bg_px, bg_py, bg_sx, bg_sy,
                bg_texture,
                0, 0, 0,
                ColorMulAlpha( data.bg_color or 0xFFFFFFFF, alpha ), data.postgui
            )
        else
            dxDrawRectangle( 
                bg_px, bg_py, bg_sx, bg_sy, 
                ColorMulAlpha( data.bg_color or 0xFFFFFFFF, alpha ), data.postgui
            )
        end

    end

    -- Обработка хендла
    local handle = data.handle
    if isElement( handle ) then
        local mouse = ibGetData( handle, "dragging" )
        if mouse then
            local mouse_now     = Vector2( CURSOR_X, CURSOR_Y )
            local mouse_diff    = mouse_now - mouse
            local y_new         = ibGetData( handle, "py" ) + mouse_diff.y
            local handle_offset = ibGetData( handle, "original_py" ) or 0

            local y_min = handle_offset + ( ibGetData( handle, "lower_limit" ) or 0 )
            local y_max = data.sy + handle_offset + ( ibGetData( handle, "upper_limit" ) or 0 )

            y_new = y_new > y_max and y_max or y_new < y_min and y_min or y_new

            local position = ( y_new - y_min ) / ( y_max - y_min )

            ibSetData( element, "position", position )
            ibSetData( handle, "dragging", mouse_now )
        end
    end

    return px, py, data.sx, data.sy, mouse_px + data.px, mouse_py + data.py, alpha
end

addEvent( "ibOnScrollbarChange", true )

_IB_STYLES[ E_CLASS ] = {
    default = {
        scroll_sx = 14,

        bg_texture = false,
        bg_px = 6, bg_py = 0, bg_sx = 2,
        bg_color = 0x55ffffff,

        handle_texture = ":nrp_shared/img/scroll_bg.png",
        handle_px = 0, handle_py = 0, handle_sx = 14, handle_sy = 104,
        handle_lower_limit = 0, handle_upper_limit = -104,
    },

    default_nobg = {
        scroll_sx = 14,

        bg_texture = false,
        bg_px = 6, bg_py = 0, bg_sx = 2,

        handle_texture = ":nrp_shared/img/scroll_bg.png",
        handle_px = 0, handle_py = 0, handle_sx = 14, handle_sy = 104,
        handle_lower_limit = 0, handle_upper_limit = -104,
        bg_color = 0
    },

    small_nobg = {
        scroll_px = -22,

        bg_px = 0, bg_py = 0,
        bg_sx = 0,

        handle_px = 0, handle_py = 0, 
        handle_sx = 16, handle_sy = 40,
        handle_texture = ":nrp_shared/img/scroll_bg_small.png",
        handle_upper_limit = -40 - 20,
        handle_lower_limit = 20,
    },

    slim_nobg = {
        scroll_sx = 10,

        bg_texture = false,
        bg_px = 5, bg_py = 0, bg_sx = 2,
        bg_color = 0,

        handle_texture = ":nrp_shared/img/scroll_bg_slim.png",
        handle_px = 0, handle_py = 0, handle_sx = 10, handle_sy = 100,
        handle_lower_limit = 20, handle_upper_limit = -120,
        handle_color = 0x55ffffff, handle_color_hover = 0x88ffffff, handle_color_active = 0xaaffffff,
    },

    slim_small_nobg = {
        scroll_sx = 10,

        bg_texture = false,
        bg_px = 5, bg_py = 0, bg_sx = 2,
        bg_color = 0,

        handle_texture = ":nrp_shared/img/scroll_bg_slim_small.png",
        handle_px = 0, handle_py = 0, handle_sx = 10, handle_sy = 60,
        handle_lower_limit = 20, handle_upper_limit = -80,
        handle_color = 0x55ffffff, handle_color_hover = 0x88ffffff, handle_color_active = 0xaaffffff,
    }
}

--[[
    local conf = conf or { }
    conf.scroll_px = conf.scroll_px or 20
    conf.scroll_py = conf.scroll_py or 0
    conf.scroll_sx = conf.scroll_sx or 14
    conf.handle_px = conf.handle_px or 0
    conf.handle_py = conf.handle_px or 0
    conf.handle_texture = conf.handle_texture or ":nrp_shared/img/scroll_bg.png"
    conf.handle_sx = conf.handle_sx or 14
    conf.handle_sy = conf.handle_sy or 104
    conf.handle_lower_limit = conf.handle_lower_limit or 0
    conf.handle_upper_limit = conf.handle_upper_limit or -104
    conf.bg_px = conf.bg_px or 6
    conf.bg_py = conf.bg_py or 0
    conf.bg_sx = conf.bg_sx or 2
    conf.bg_color = conf.bg_color or 0x55ffffff
    conf.bg_texture = conf.bg_texture or false

    local render_target = ibRenderTarget(
        {
            px = px, py = py, sx = sx, sy = sy,
            parent = parent,
        }
    )

    local scrollbar = ibScrollbarV(
        {
            px = px + sx + conf.scroll_px,
            py = py + conf.scroll_py,
            sx = conf.scroll_sx, sy = sy,
            bg = {
                texture = conf.bg_texture,
                px = conf.bg_px, py = conf.bg_py, sx = conf.bg_sx,
                color = conf.bg_color,
            },
            handle = {
                texture = conf.handle_texture,
                px = conf.handle_px, py = conf.handle_py, sx = conf.handle_sx, sy = conf.handle_sy,
                lower_limit = conf.handle_lower_limit, upper_limit = conf.handle_upper_limit,
            },
            parent = parent,
        }
    )
]]