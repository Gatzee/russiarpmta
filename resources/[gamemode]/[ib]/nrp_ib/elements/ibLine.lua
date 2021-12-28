local E_CLASS = "ibLine"

local DEFAULT_VALUES = {
    visible  = true,
    disabled = false,
    priority = 0,

    px        = 0,
    py        = 0,
    target_px = 0,
    target_py = 0,

    color = 0xFFFFFFFF,
    width = 1,

    alpha = 255,
}

function ibLine( self, resource )
    if type( self ) ~= "table" then
        outputDebugString( "Bad argument @ibLine[1], expect table got ".. type( self ), 1 )
        return
    end
    local sourceResource = sourceResource or resource or _THIS_RESOURCE
    local element = ibCreateNewElementOfClass( self, E_CLASS, sourceResource )
    ibSetDefaultValues( self, DEFAULT_VALUES )

    triggerEvent( "ibOnElementCreate", element, self, E_CLASS, sourceResource )
    return element
end

local dxDrawLine    = dxDrawLine
local ColorMulAlpha = ColorMulAlpha

_RENDER_FUNCTIONS[ E_CLASS ] = function( element, data, parent_px, parent_py, mouse_px, mouse_py, alpha )
    local px, py = parent_px + data.px, parent_py + data.py
    local alpha     = alpha * data.alpha
    if alpha > 0 then
        local target_px, target_py = parent_px + data.target_px, parent_py + data.target_py
        
        dxDrawLine( px, py, target_px, target_py, ColorMulAlpha( data.color, alpha ), data.width, data.postgui )
    end

    return px, py, 0, 0, mouse_px + data.px, mouse_py + data.py, alpha
end