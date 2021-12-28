local E_CLASS = "ibButton"

local DEFAULT_VALUES = {
    visible         = true,
    priority        = 0,

    px              = 0,
    py              = 0,
    sx              = 0,
    sy              = 0,
    texture         = false,
    texture_hover   = false,
    texture_click   = false,
    texture_disabled = false,

    color           = 0xFFFFFFFF,
    color_hover     = 0xFFFFFFFF,
    color_click     = 0xFFFFFFFF,
    color_disabled  = 0xFFFFFFFF,

    rotation            = 0,
    rotation_offset_x   = 0,
    rotation_offset_y   = 0,

    alpha           = 255,
}

function ibButton( self, resource )
    if type( self ) ~= "table" then
        outputDebugString( "Bad argument @ibButton[1], expect table got ".. type( self ), 1 )
        return
    end
    local sourceResource = sourceResource or resource or _THIS_RESOURCE
    local element = ibCreateNewElementOfClass( self, E_CLASS, sourceResource )
    ibSetDefaultValues( self, DEFAULT_VALUES )

    triggerEvent( "ibOnElementCreate", element, self, E_CLASS, sourceResource )
    return element
end

local dxDrawImage   = dxDrawImage
local isElement     = isElement
local getKeyState   = getKeyState

_RENDER_FUNCTIONS[ E_CLASS ] = function( element, data, parent_px, parent_py, mouse_px, mouse_py, alpha )
    local px, py = parent_px + data.px, parent_py + data.py

    local alpha  = alpha * data.alpha
    if alpha > 0 then

        local is_hovered    = ibGetData( element, "hover" )
        local is_clicked    = is_hovered and getKeyState( "mouse1" )
        local is_disabled   = ibGetData( element, "disabled" )

        local texture   = is_disabled and data.texture_disabled or is_hovered and ( is_clicked and data.texture_click or data.texture_hover ) or data.texture
        texture = ConvertToForeignFile( element, texture )
        local color     = is_disabled and data.color_disabled or is_hovered and ( is_clicked and data.color_click or data.color_hover ) or data.color

        if isElement( texture ) then
            dxDrawImage(
                px, py, data.sx, data.sy,
                texture,
                data.rotation, data.rotation_offset_x, data.rotation_offset_y,
                ColorMulAlpha( color, alpha ), data.postgui
            )
            --dxDrawText( inspect( { px, py, data.sx, data.sy } ), px, py, 0, 0 ) -- WARNING DEBUG
        else
            dxDrawRectangle(
                px, py, data.sx, data.sy,
                ColorMulAlpha( color, alpha ), data.postgui, data.subpixel
            )
        end

    end

    return px, py, data.sx, data.sy, mouse_px + data.px, mouse_py + data.py, alpha
end