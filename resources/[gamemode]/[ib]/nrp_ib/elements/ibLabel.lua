local E_CLASS = "ibLabel"

local DEFAULT_VALUES = {
    visible         = true,
    disabled        = false,
    priority        = 0,

    text            = "Empty Label",
    px              = 0,
    py              = 0,
    sx              = 0,
    sy              = 0,
    color           = 0xFFFFFFFF,
    scale_x         = 1,
    scale_y         = 1,
    font            = "default",
    align_x         = "left",
    align_y         = "top",
    clip            = false,
    wordbreak       = false,
    postgui         = false,
    colored         = false,
    subpixel        = false,
    rotation        = 0,
    rotation_center_x = 0,
    rotation_center_y = 0,
    rotation_offset_x = 0,
    rotation_offset_y = 0,

    alpha           = 255,
}

function ibLabel( self, resource )
    if type( self ) ~= "table" then
        outputDebugString( "Bad argument @ibLabel[1], expect table got ".. type( self ), 1 )
        return
    end
    local sourceResource = sourceResource or resource or _THIS_RESOURCE
    local element = ibCreateNewElementOfClass( self, E_CLASS, sourceResource )
    ibSetDefaultValues( self, DEFAULT_VALUES )

    triggerEvent( "ibOnElementCreate", element, self, E_CLASS, sourceResource )

    local function SetColorlessText( text )
        _IB_ELEMENT_DATA[ element ].text_colorless = utf8.gsub( text, "#%x%x%x%x%x%x", "" )
    end

    local function ibOnElementDataChange_handler( key, value )
        if key == "text" then
            SetColorlessText( value )
        end
    end
    addEventHandler( "ibOnElementDataChange", element, ibOnElementDataChange_handler )

    SetColorlessText( self.text )

    return element
end

local dxDrawText    = dxDrawText
local ColorMulAlpha = ColorMulAlpha
local tonumber      = tonumber

_RENDER_FUNCTIONS[ E_CLASS ] = function( element, data, parent_px, parent_py, mouse_px, mouse_py, alpha )
    local px, py = parent_px + data.px, parent_py + data.py

    local alpha  = alpha * data.alpha

    if alpha > 0 then

        local rotation_center_x = data.rotation_center_x
        local rotation_center_y = data.rotation_center_y
        if rotation_center_x == 0 and rotation_center_y == 0 then
            rotation_center_x = px + data.sx * 0.5 + data.rotation_offset_x
            rotation_center_y = py + data.sy * 0.5 + data.rotation_offset_y
        end

        if data.outline then
            local width = tonumber( data.outline ) or 1
            local alpha_result = ColorMulAlpha( data.outline_color or 0xFF000000, alpha )
            
            dxDrawText( 
                data.text_colorless, px-width, py, px + data.sx-width, py + data.sy,
                alpha_result, data.scale_x, data.scale_y,
                data.font, data.align_x, data.align_y,
                data.clip, data.wordbreak, data.postgui,
                data.colored, data.subpixel,
                data.rotation, rotation_center_x, rotation_center_y
            )

            dxDrawText( 
                data.text_colorless, px, py-width, px + data.sx, py + data.sy-width,
                alpha_result, data.scale_x, data.scale_y,
                data.font, data.align_x, data.align_y,
                data.clip, data.wordbreak, data.postgui,
                data.colored, data.subpixel,
                data.rotation, rotation_center_x, rotation_center_y
            )

            dxDrawText( 
                data.text_colorless, px+width, py, px + data.sx+width, py + data.sy,
                alpha_result, data.scale_x, data.scale_y,
                data.font, data.align_x, data.align_y,
                data.clip, data.wordbreak, data.postgui,
                data.colored, data.subpixel,
                data.rotation, rotation_center_x, rotation_center_y
            )

            dxDrawText( 
                data.text_colorless, px, py+width, px + data.sx, py + data.sy+width,
                alpha_result, data.scale_x, data.scale_y,
                data.font, data.align_x, data.align_y,
                data.clip, data.wordbreak, data.postgui,
                data.colored, data.subpixel,
                data.rotation, rotation_center_x, rotation_center_y
            )
        end

        if data.shadow then
            local shadow = data.shadow

            local offset_x, offset_y = shadow.offset_x or -1, shadow.offset_y or 1
            
            local color = shadow.color or 0xff000000
            local alpha_result = ColorMulAlpha( color, alpha )

            local px, py = px + offset_x, py + offset_y
            dxDrawText( 
                data.text, px, py, px + data.sx, py + data.sy,
                alpha_result, data.scale_x, data.scale_y,
                data.font, data.align_x, data.align_y,
                data.clip, data.wordbreak, data.postgui,
                data.colored, data.subpixel,
                data.rotation, rotation_center_x, rotation_center_y
            )
        end

        dxDrawText( 
            data.text, px, py, px + data.sx, py + data.sy,
            ColorMulAlpha( data.color, alpha ), data.scale_x, data.scale_y,
            data.font, data.align_x, data.align_y,
            data.clip, data.wordbreak, data.postgui,
            data.colored, data.subpixel,
            data.rotation, rotation_center_x, rotation_center_y
        )
    end

    return px, py, data.sx, data.sy, mouse_px + data.px, mouse_py + data.py, alpha
end

_IB_STYLES[ E_CLASS ] = {
    centered = { align_x = "center", align_y = "center" },
}