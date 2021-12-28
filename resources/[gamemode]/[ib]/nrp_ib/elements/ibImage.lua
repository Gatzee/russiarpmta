local E_CLASS = "ibImage"

local DEFAULT_VALUES = {
    visible     = true,
    disabled    = false,
    priority    = 0,

    px          = 0,
    py          = 0,
    sx          = 0,
    sy          = 0,
    texture     = false,
    color       = 0xFFFFFFFF,
    rotation    = 0,
    rotation_offset_x = 0,
    rotation_offset_y = 0,

    alpha           = 255,
}

function ibImage( self, resource )
    if type( self ) ~= "table" then
        outputDebugString( "Bad argument @ibImage[1], expect table got ".. type( self ), 1 )
        return
    end
    local sourceResource = sourceResource or resource or _THIS_RESOURCE
    local element = ibCreateNewElementOfClass( self, E_CLASS, sourceResource )
    ibSetDefaultValues( self, DEFAULT_VALUES )

    triggerEvent( "ibOnElementCreate", element, self, E_CLASS, sourceResource )
    return element
end

local dxDrawImage          = dxDrawImage
local dxDrawRectangle      = dxDrawRectangle
local dxDrawImageSection   = dxDrawImageSection
local isElement            = isElement
local ConvertToForeignFile = ConvertToForeignFile
local ColorMulAlpha        = ColorMulAlpha
local math_floor           = math.floor

_RENDER_FUNCTIONS[ E_CLASS ] = function( element, data, parent_px, parent_py, mouse_px, mouse_py, alpha )
    local px, py    = parent_px + data.px, parent_py + data.py
    local alpha     = alpha * data.alpha
    local sx, sy    = data.sx, data.sy
    if alpha > 0 then
        local texture   = ConvertToForeignFile( element, data.texture, data.texture_surface ) 

        if isElement( texture ) then
            if data.u then
                dxDrawImageSection( px, py, sx, sy, 
                    data.u, data.v, data.u_size or sx, data.v_size or sy,
                    texture,
                    data.rotation,
                    data.rotation_offset_x, data.rotation_offset_y,
                    ColorMulAlpha( data.color, alpha ), data.postgui
                )
            elseif data.section then
                local real_sx, real_sy = dxGetMaterialSize( texture )
                local scale_sx, scale_sy = sx / real_sx, sy / real_sy

                local section_px = math_floor( ( data.section.px or 0 ) / scale_sx )
                local section_py = math_floor( ( data.section.py or 0 ) / scale_sy )

                local section_sx = math_floor( ( data.section.sx or sx ) / scale_sx )
                local section_sy = math_floor( ( data.section.sy or sy ) / scale_sy )

                local draw_sx = math_floor( data.section.sx or sx )
                local draw_sy = math_floor( data.section.sy or sy )

                dxDrawImageSection( px, py, draw_sx, draw_sy, 
                    section_px, section_py, section_sx, section_sy,
                    texture,
                    data.rotation,
                    data.rotation_offset_x, data.rotation_offset_y,
                    ColorMulAlpha( data.color, alpha ), data.postgui
                )
            else
                dxDrawImage(
                    px, py, sx, sy,
                    texture,
                    data.rotation,
                    data.rotation_offset_x, data.rotation_offset_y,
                    ColorMulAlpha( data.color, alpha ), data.postgui
                )
            end
        else
            dxDrawRectangle(
                px, py, sx, sy,
                ColorMulAlpha( data.color, alpha ), data.postgui, data.subpixel
            )
        end
    end

    return px, py, sx, sy, mouse_px + data.px, mouse_py + data.py, alpha
end

_IB_STYLES[ E_CLASS ] = {
    fullscreen = { px = 0, py = 0, sx = _SCREEN_X, sy = _SCREEN_Y }
}