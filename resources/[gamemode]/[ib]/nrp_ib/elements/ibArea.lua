local E_CLASS = "ibArea"

local DEFAULT_VALUES = {
    visible     = true,
    disabled    = false,
    priority    = 0,

    px          = 0,
    py          = 0,
    sx          = 0,
    sy          = 0,

    alpha           = 255,
}

function ibArea( self, resource )
    if type( self ) ~= "table" then
        outputDebugString( "Bad argument @ibArea[1], expect table got ".. type( self ), 1 )
        return
    end
    local sourceResource = sourceResource or resource or _THIS_RESOURCE
    local element = ibCreateNewElementOfClass( self, E_CLASS, sourceResource )
    ibSetDefaultValues( self, DEFAULT_VALUES )

    triggerEvent( "ibOnElementCreate", element, self, E_CLASS, sourceResource )
    return element
end

_RENDER_FUNCTIONS[ E_CLASS ] = function( element, data, parent_px, parent_py, mouse_px, mouse_py, alpha )
    local px, py    = parent_px + data.px, parent_py + data.py
    local alpha     = alpha * data.alpha
    return px, py, data.sx, data.sy, mouse_px + data.px, mouse_py + data.py, alpha
end