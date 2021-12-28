local E_CLASS = "ibScrollbarH"

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
    handle_color = 0xFFFFFFFF,

    sensivity       = 0.1,
    smooth          = true,

    alpha           = 255,
}

function ibScrollbarH( self, resource )
    if type( self ) ~= "table" then
        outputDebugString( "Bad argument @ibScrollbarH[1], expect table got ".. type( self ), 1 )
        return
    end
    
    --iprint( "handle PRE create", sourceResource )
    local sourceResource = sourceResource or resource or _THIS_RESOURCE
    local element = ibCreateNewElementOfClass( self, E_CLASS, sourceResource )
    ibSetDefaultValues( self, DEFAULT_VALUES )

    triggerEvent( "ibOnElementCreate", element, self, E_CLASS, sourceResource )


    local handle_conf   = { }

    handle_conf.texture     = self.handle_texture
    handle_conf.sx          = self.handle_sx or self.sy
    handle_conf.sy          = self.handle_sy or self.sy
    handle_conf.px          = self.handle_px or 0
    handle_conf.py          = self.handle_py or 0
    handle_conf.upper_limit = self.handle_upper_limit or 0
    handle_conf.lower_limit = self.handle_lower_limit or 0
    handle_conf.original_px = handle_conf_px
    handle_conf.original_py = handle_conf_py

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
        local handle_offset = ibGetData( handle, "original_px" ) or 0

        local x_min = handle_offset + ( ibGetData( handle, "lower_limit" ) or 0 )
        local x_max = ibGetData( element, "sx" ) + handle_offset + ( ibGetData( handle, "upper_limit" ) or 0 )
        local x_new = value and ( x_min + ( x_max - x_min ) * value ) or ibGetData( handle, "px" ) or 0
    
        x_new = x_new > x_max and x_max or x_new < x_min and x_min or x_new
    
        local position = ( x_new - x_min ) / ( x_max - x_min )
        _IB_ELEMENT_DATA[ element ].position = position

        ibSetData( handle, "px", x_new )

        triggerEvent( "ibOnScrollbarChange", element, x_new, position )
    end
    
    addEventHandler( "ibOnScrollbarChange", element, function( absolute, relative )
        --iprint( "SCROLL POSITION: ", relative )
        local render_target = ibGetData( element, "connectedRenderTarget" )
        if isElement( render_target ) then
            local viewport_sx  = ibGetData( render_target, "viewport_sx" )
            local sx = ibGetData( render_target, "sx" )
            
            local viewport_px = sx > viewport_sx and ( sx - viewport_sx ) * relative or 0

            ibSetData( render_target, "viewport_px", viewport_px )
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
    end )

    -- Обновление позиции скроллера
    addEventHandler( "ibOnElementDataChange", element, function( key, value, old )
        if key == "position" then
            setScroll( value )
        elseif key == "sx" then
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
            local x_new         = ibGetData( handle, "px" ) + mouse_diff.x
            local handle_offset = ibGetData( handle, "original_px" ) or 0

            local x_min = handle_offset + ( ibGetData( handle, "lower_limit" ) or 0 )
            local x_max = data.sx + handle_offset + ( ibGetData( handle, "upper_limit" ) or 0 )

            x_new = x_new > x_max and x_max or x_new < x_min and x_min or x_new

            local position = ( x_new - x_min ) / ( x_max - x_min )

            ibSetData( element, "position", position )
            ibSetData( handle, "dragging", mouse_now )
        end
    end

    return px, py, data.sx, data.sy, mouse_px + data.px, mouse_py + data.py, alpha
end

addEvent( "ibOnScrollbarChange", true )

_IB_STYLES[ E_CLASS ] = {
    default = {
        bg_texture = false, bg_px = 0, bg_py = 0, bg_sy = 2, bg_color = 0x55ffffff,
        handle_texture = ":nrp_shared/img/handle_h.png", handle_px = 0, handle_py = -11, handle_sx = 22, handle_sy = 22, handle_lower_limit = 0, handle_upper_limit = -22,
    },

    slim_nobg = {
        scroll_sx = 10,

        bg_texture = false,
        bg_px = 5, bg_py = 0, bg_sy = 2,
        bg_color = 0,

        handle_texture = ":nrp_shared/img/scroll_h_bg_slim.png",
        handle_px = 0, handle_py = 0, handle_sx = 100, handle_sy = 10,
        handle_lower_limit = 20, handle_upper_limit = -120,
        handle_color = 0x55ffffff, handle_color_hover = 0x88ffffff, handle_color_active = 0xaaffffff,
    },

    tuning = {
        bg_texture = ":nrp_shared/img/bg_h_tuning.png", bg_px = 0, bg_py = 0, bg_sy = 3, bg_color = 0xffffffff,
        handle_texture = ":nrp_shared/img/handle_h_tuning.png", handle_px = 0, handle_py = -6, handle_sx = 39, handle_sy = 15, handle_lower_limit = 0, handle_upper_limit = -39,
    },
}

