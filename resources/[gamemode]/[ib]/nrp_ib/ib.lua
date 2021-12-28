_IB_ELEMENT_DATA = { }
_RENDER_FUNCTIONS = { }
_TOTAL_ELEMENTS = 0

_SCREEN_X, _SCREEN_Y = guiGetScreenSize( )
_THIS_RESOURCE = getThisResource( )

local _IB_ELEMENT_DATA_LOCAL = _IB_ELEMENT_DATA
local _RENDER_FUNCTIONS_LOCAL = _RENDER_FUNCTIONS

_IB_ROOT = createElement( "ibElement", "ibRoot" )

function ibSortByPriority( a, b )
    local n      = _IB_ELEMENT_DATA_LOCAL
    local a_data = n[ a ]
    local b_data = n[ b ]

    local a_priority = a_data.priority
    local b_priority = b_data.priority

    if a_priority == b_priority then
        return a_data.creation_id < b_data.creation_id
    end
    
    return a_priority < b_priority
end

local getElementChildren      = getElementChildren
local table_sort              = table.sort
local ibSortByPriority        = ibSortByPriority
local isElement               = isElement
local triggerEvent            = triggerEvent
local pairs                   = pairs
local bitExtract              = bitExtract
local bitReplace              = bitReplace
local utf8_sub                = utf8.sub
local table_concat            = table.concat
local table_insert            = table.insert
local type                    = type
local addEventHandler         = addEventHandler
local removeEventHandler      = removeEventHandler
local getResourceRootElement  = getResourceRootElement
local isCursorShowing         = isCursorShowing

function ibGetHoveredElement( )
    return HOVER_ELEMENT
end

local NEXT_FRAME_TRIGGER_KEYS = { }
addEventHandler( "onClientKey", root, function( key, state )
    table_insert( NEXT_FRAME_TRIGGER_KEYS, { key, state } )
end )

local x, y = guiGetScreenSize( )

function ibRenderElements( )
    --local tick = getTickCount( )
    
    THIS_HOVER_ELEMENT = nil

    CURSOR_SHOWING = isCursorShowing( )
    CURSOR_X, CURSOR_Y = getCursorPosition( )
    CURSOR_X, CURSOR_Y = ( CURSOR_X or 0 ) * x, ( CURSOR_Y or 0 ) * y

    --triggerEvent( "ibOnPreRender", _IB_ROOT )

    ibRenderElementRecursive( _, _IB_ROOT, 0, 0, 0, 0, 1, 0, 0, x, y )

    local triggerLeave

    if HOVER_ELEMENT ~= THIS_HOVER_ELEMENT then
        if isElement( HOVER_ELEMENT ) then
            local data = _IB_ELEMENT_DATA_LOCAL[ HOVER_ELEMENT ]
            if data.hover then
                triggerLeave = HOVER_ELEMENT
                --triggerEvent( "ibOnElementMouseLeave", HOVER_ELEMENT )
                data.hover = nil
            end
        end
    end

    HOVER_ELEMENT = THIS_HOVER_ELEMENT

    if triggerLeave then
        triggerEvent( "ibOnElementMouseLeave", triggerLeave )
    end

    local is_hover_element = isElement( HOVER_ELEMENT )
    if is_hover_element then
        local data = _IB_ELEMENT_DATA_LOCAL[ HOVER_ELEMENT ]
        if data.hover == nil then
            triggerEvent( "ibOnElementMouseEnter", HOVER_ELEMENT )
            data.hover = true
        end
    end

    if NEXT_FRAME_IS_CLICK then
        local simulated_element = NEXT_FRAME_IS_CLICK[ 3 ]
        local is_simulated      = isElement( simulated_element )
        local hover_element     = is_simulated and simulated_element or is_hover_element and HOVER_ELEMENT
        if hover_element then
            triggerEvent( "ibOnElementMouseClick", hover_element, NEXT_FRAME_IS_CLICK[ 1 ], NEXT_FRAME_IS_CLICK[ 2 ], is_simulated )
        end
        NEXT_FRAME_IS_CLICK = nil
    end

    for i, v in pairs( NEXT_FRAME_TRIGGER_KEYS ) do
        triggerEvent( "ibOnClientKey", _IB_ROOT, v[ 1 ], v[ 2 ] )
    end
    NEXT_FRAME_TRIGGER_KEYS = { }

    triggerEvent( "ibOnRender", _IB_ROOT )

    --iprint( "Render all tick: ", getTickCount( ) - tick, "ms" )
end
addEventHandler( "onClientRender", root, ibRenderElements )

function ibRenderElementRecursive( parent, element, px, py, mouse_px, mouse_py, alpha, detect_px, detect_py, detect_sx, detect_sy )
    local element_data      = _IB_ELEMENT_DATA_LOCAL[ element ]
    local element_type      = element_data and element_data.type
    local render_function   = _RENDER_FUNCTIONS_LOCAL[ element_type ]

    if render_function then
        if not element_data.visible then return end
        local is_render_changable = element_data ~= "ibRenderTarget"

        if is_render_changable and element_data.blend_mode then
            dxSetBlendMode( element_data.blend_mode )
        end

        local offset_x, offset_y, sx, sy,
            offset_mouse_px, offset_mouse_py,
                alpha_new,
                    detect_px_new, detect_py_new, detect_sx_new, detect_sy_new =
                        render_function( element, element_data, px, py, mouse_px, mouse_py, alpha, detect_px, detect_py, detect_sx, detect_sy )
        
        if is_render_changable and element_data.blend_mode_after then
            dxSetBlendMode( element_data.blend_mode_after )
        end

        if not offset_x then return end -- Завершение рендера в случае отключения элемента

        px, py                  = offset_x, offset_y
        mouse_px, mouse_py      = offset_mouse_px, offset_mouse_py

        element_data.real_px    = offset_mouse_px
        element_data.real_py    = offset_mouse_py
        
        if alpha_new then alpha = alpha_new / 255 end

        detect_px               = detect_px_new or detect_px
        detect_py               = detect_py_new or detect_py
        detect_sx               = detect_sx_new or detect_sx
        detect_sy               = detect_sy_new or detect_sy

        if element_data.disabled ~= true and isMouseWithinRangeOf( offset_mouse_px, offset_mouse_py, sx, sy ) and isMouseWithinRangeOf( detect_px, detect_py, detect_sx, detect_sy ) then
            if element_data.unhoverable ~= true then
                THIS_HOVER_ELEMENT = element
            end
        end
    end

    local element_children = getElementChildren( element )
    if #element_children > 0 then
        local table_sort = table_sort
        table_sort( element_children, ibSortByPriority )

        local ibRenderElementRecursive = ibRenderElementRecursive
        for i, v in pairs( element_children ) do
            ibRenderElementRecursive( element, v, px, py, mouse_px, mouse_py, alpha, detect_px, detect_py, detect_sx, detect_sy )
        end
    end
end

function onClientClick_handler( key, state, ax, ay, wx, wy, wz, clicked_world )
    NEXT_FRAME_IS_CLICK = { key, state }

    triggerEvent( "ibOnAnyClick", _IB_ROOT, key, state, ax, ay, wx, wy, wz, clicked_world )

    if key == "left" and state == "up" then
        triggerEvent( "ibOnMouseRelease", _IB_ROOT, key, state )
    end
end
addEventHandler( "onClientClick", root, onClientClick_handler )

function ibSimulateClick_handler( key, state )
    NEXT_FRAME_IS_CLICK = { key, state, source }

    if key == "left" and state == "up" then
        triggerEvent( "ibOnMouseRelease", _IB_ROOT, key, state )
    end
end
addEvent( "ibSimulateClick", true )
addEventHandler( "ibSimulateClick", root, ibSimulateClick_handler )

local RESOURCE_NAME_CACHE = { }
setmetatable( RESOURCE_NAME_CACHE, { __mode = "kv" } )
function ibOnElementCreate_handler( data, class, source_resource )
    _IB_ELEMENT_DATA_LOCAL[ source ]  = data

    local resource_name = RESOURCE_NAME_CACHE[ source_resource ]
    if not resource_name then
        resource_name = getResourceName( source_resource )
        RESOURCE_NAME_CACHE[ source_resource ] = resource_name
    end

    data.creation_id            = _TOTAL_ELEMENTS
    data.resource               = source_resource
    data.resource_name          = resource_name
    data.type                   = class

    setElementParent( source, isElement( data.parent ) and data.parent or _IB_ROOT )
end
addEvent( "ibOnElementCreate", true )
addEventHandler( "ibOnElementCreate", root, ibOnElementCreate_handler )

function ibGetAllData( element )
    return _IB_ELEMENT_DATA_LOCAL[ element ]
end

function ibGetData( element, key )
    local edata = _IB_ELEMENT_DATA_LOCAL[ element ]
    if edata then return edata[ key ] end
end

function ibSetData( element, key, value )
    if isElement( element ) ~= true then
        outputDebugString( "Bad argument @IbSetData[1], expected element got " .. type( element ) .. ": " .. inspect( element ) .. ", values: " .. inspect( { key, value } ), 1 )
        return
    end

    local element_data = _IB_ELEMENT_DATA_LOCAL[ element ]
    local old = element_data[ key ]

    element_data[ key ] = value
    triggerEvent( "ibOnElementDataChange", element, key, value, old )
end
addEvent( "ibSetData", true )
addEventHandler( "ibSetData", root, ibSetData )

-- Скоростной вариант
function _FAST_ibSetData( key, value )
    local element_data = _IB_ELEMENT_DATA_LOCAL[ source ]
    local old = element_data[ key ]

    element_data[ key ] = value
    triggerEvent( "ibOnElementDataChange", source, key, value, old )
end
addEvent( "_FAST_ibSetData", true )
addEventHandler( "_FAST_ibSetData", _IB_ROOT, _FAST_ibSetData )

function ibSetBatchData( element, vals )
    if isElement( element ) ~= true then
        outputDebugString( "Bad argument @ibSetBatchData[1], expected element got " .. type( element ) .. ": " .. inspect( element ) .. ", values: " .. inspect( { key, value } ), 1 )
        return
    end
    local ibSetData = ibSetData
    
    for i, v in pairs( vals ) do
        ibSetData( element, i, v, true )
    end
end
addEvent( "ibSetBatchData", true )
addEventHandler( "ibSetBatchData", root, ibSetBatchData )

-- Скоростной вариант
function _FAST_ibSetBatchData( vals )
    local element_data = _IB_ELEMENT_DATA_LOCAL[ source ]
    
    for key, value in pairs( vals ) do
        local old = element_data[ key ]
        element_data[ key ] = value
        triggerEvent( "ibOnElementDataChange", source, key, value, old )
    end
end
addEvent( "_FAST_ibSetBatchData", true )
addEventHandler( "_FAST_ibSetBatchData", _IB_ROOT, _FAST_ibSetBatchData )

function ConvertToForeignFile( element, str, texture_surface )
    if type( str ) ~= "string" then return str end

    if utf8_sub( str, 1, 1 ) == ":" then
        return GetTextureFor( element, str, texture_surface )
    else
        return GetTextureFor( element, table_concat( { ":", _IB_ELEMENT_DATA_LOCAL[ element ].resource_name, "/", str }, '' ), texture_surface )
    end
end

function ibCreateNewElementOfClass( data, class, source_resource )
    _TOTAL_ELEMENTS = _TOTAL_ELEMENTS + 1
    local element = createElement( class, table_concat( { class, "_", _TOTAL_ELEMENTS }, '' ) )
    local resource_root = getResourceRootElement( source_resource )

    -- Отключение ресурса, который создал элемент
    local function onStop( )
        if isElement( element ) then destroyElement( element ) end
    end
    addEventHandler( "onClientResourceStop", resource_root, onStop )

    -- Любое удаление элемента
    local function onDestroy( )
        removeEventHandler( "onClientResourceStop", resource_root, onStop )

        local removable_textures = IB_TEXTURES_ASSIGNMENT[ element ]
        if removable_textures then
            for i, v in pairs( removable_textures ) do
                local list = IB_TEXTURES[ i ]
                if list then list.elements[ element ] = nil end
                CheckTextureForRemoval( i )
            end
            IB_TEXTURES_ASSIGNMENT[ element ] = nil
        end

        _IB_ELEMENT_DATA_LOCAL[ element ] = nil
    end
    addEventHandler( "onClientElementDestroy", element, onDestroy, false )

    return element
end

function ColorMulAlpha( color, alpha )
    return alpha == 255 and color or bitReplace( color, bitExtract( color, 24, 8 ) * alpha / 255, 24, 8 )
end

function ibSetDefaultValues( tbl, values )
    for i, v in pairs( values ) do
        if tbl[ i ] == nil then tbl[ i ] = v end
    end
end

function isMouseWithinRangeOf( px, py, sx, sy )
    local px, py, sx, sy = px or 0, py or 0, sx or 0, sy or 0
    return CURSOR_SHOWING and ( CURSOR_X >= px and CURSOR_X <= px + sx and CURSOR_Y >= py and CURSOR_Y <= py + sy )
end

addEvent( "ibOnElementMouseEnter", true )
addEvent( "ibOnElementMouseLeave", true )
addEvent( "ibOnElementMouseClick", true )
addEvent( "ibOnElementDataChange", true )
addEvent( "ibOnMouseRelease", true )
addEvent( "ibOnClientKey", true )
addEvent( "ibOnPreRender", true )
addEvent( "ibOnRender", true )
addEvent( "ibOnAnyClick", true )