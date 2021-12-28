local E_CLASS = "ibWebEdit"

local DEFAULT_VALUES = {
    visible  = true,
    priority = 0,

    px                  = 0,
    py                  = 0,
    sx                  = 0,
    sy                  = 0,
    alpha               = 255,
    color               = 0xFFFFFFFF,
    bg_color            = 0xFF000000,
    max_length          = 1024 * 1024,
    autofocus           = false,
    placeholder         = "",
    placeholder_color   = 0x77ffffff,
}

local FONTS_TYPES = { 
    regular    = "OpenSans/OpenSans-Regular.ttf",
    bold       = "OpenSans/OpenSans-Bold.ttf",
    light      = "OpenSans/OpenSans-Light.ttf",
    semibold   = "OpenSans/OpenSans-SemiBold.ttf",
    italic     = "OpenSans/OpenSans-Italic.ttf",
    bolditalic = "OpenSans/OpenSans-BoldItalic.ttf",
}

local KEEP_UPDATED = {
    sx                  = true,
    sy                  = true,
    font                = true,
    text                = true,
    text_align          = true,
    color               = true,
    bg_color            = true,
    max_length          = true,
    autofocus           = true,
    placeholder         = true,
    placeholder_color   = true,
    bg_color_focused    = true,
}

function ibWebEdit( self, resource )
    if type( self ) ~= "table" then
        outputDebugString( "Bad argument @ibWebEdit[1], expect table got ".. type( self ), 1 )
        return
    end
    local sourceResource = sourceResource or resource or _THIS_RESOURCE
    local element = ibCreateNewElementOfClass( self, E_CLASS, sourceResource )
    ibSetDefaultValues( self, DEFAULT_VALUES )
    triggerEvent( "ibOnElementCreate", element, self, E_CLASS, sourceResource )

    local browser_element = ibBrowser( { px = 0, py = 0, sx = self.sx, sy = self.sy, is_local = true, is_transparent = true, parent = element } )
    local browser = ibGetData( browser_element, "browser" )

    --setElementParent( browser_element, element )
    
    local function ibOnBrowserCreated_handler( )
        loadBrowserURL( browser, "http://mta/local/html/ibWebEdit.html", "", false )
    end
    addEventHandler( "ibOnBrowserCreated", browser_element, ibOnBrowserCreated_handler )

    addEventHandler( "ibOnElementDataChange", browser_element, function( key, value )
        if not _IB_ELEMENT_DATA[ element ].autofocus and key == "focused" then
            --iprint( getTickCount( ), "focus state:", value and true or false )
            triggerEvent( "ibBrowserCallElementFunction", browser_element, "ibWebEdit", value and "focus( )" or "blur( )" )
        end
    end )
    
    local function ibOnElementDataChange_handler( key, value )
        -- Установка текста для поля для ввода
        if key == "text" then
            triggerEvent( "ibBrowserSetElementValue", browser_element, "ibWebEdit", value )
            
        elseif key == "color" then
            local b, g, r, a = bitExtract( value, 0, 8 ), bitExtract( value, 8, 8 ), bitExtract( value, 16, 8 ), bitExtract( value, 24, 8 ) or 255
            triggerEvent( "ibBrowserInjectCSS", browser_element, "input { color: rgba(" .. r .. ", " .. g .. ", " .. b .. ", " .. a .. "); }" )

        elseif key == "text_align" then
            triggerEvent( "ibBrowserInjectCSS", browser_element, "input { text-align: " .. value .. "; }" )

        elseif key == "bg_color" then
            local b, g, r, a = bitExtract( value, 0, 8 ), bitExtract( value, 8, 8 ), bitExtract( value, 16, 8 ), bitExtract( value, 24, 8 ) or 255
            triggerEvent( "ibBrowserInjectCSS", browser_element, "body { background-color: rgba(" .. r .. ", " .. g .. ", " .. b .. ", " .. a .. "); }" )

        elseif key == "font" then
            local font_type, font_size = string.match( value, "(%a+)_(%d+)" )
            local font_size = tonumber( font_size )
            local _, _, font_weight = string.match( value, "(%a+)_(%d+)_(%d+)" )

            triggerEvent( "ibBrowserInjectCSS", browser_element, [[
                @font-face {
                    font-family: "]] .. value .. [[";
                    src: url( "http://mta/nrp_fonts/Resources/Fonts/]] .. FONTS_TYPES[ font_type ] .. [[" );
                }
                input {
                    font-family: "]] .. value .. [[";
                    font-size: ]] .. font_size .. [[pt;
                    font-weight: ]] .. ( font_weight or 400 ) .. [[;
                }
            ]] )

        elseif key == "max_length" then
            triggerEvent( "ibBrowserSetElementParameter", browser_element, "ibWebEdit", "maxLength", value or 0 )
        elseif key == "placeholder" then
            triggerEvent( "ibBrowserSetElementParameter", browser_element, "ibWebEdit", "placeholder", value or "" )
        elseif key == "placeholder_color" then
            local b, g, r, a = bitExtract( value, 0, 8 ), bitExtract( value, 8, 8 ), bitExtract( value, 16, 8 ), bitExtract( value, 24, 8 ) or 255
            triggerEvent( "ibBrowserInjectCSS", browser_element, "::placeholder { color: rgba(" .. r .. ", " .. g .. ", " .. b .. "); opacity: " .. ( a / 255 ) .. "; }" )
        elseif key == "autofocus" then
            triggerEvent( "ibBrowserSetElementParameter", browser_element, "ibWebEdit", "autofocus", value and "true" or "false" )
        elseif key == "focus" then
            triggerEvent( "ibBrowserCallElementFunction", browser_element, "ibWebEdit", "focus()" )
        elseif key == "blur" then
            triggerEvent( "ibBrowserCallElementFunction", browser_element, "ibWebEdit", "blur()" )

        -- Проброс значений на элемент браузера
        else
            ibSetData( browser_element, key, value )
            
        end
    end
    addEventHandler( "ibOnElementDataChange", element, ibOnElementDataChange_handler, false )

    local function ibOnBrowserDocumentReady_handler( )
        for i, v in pairs( _IB_ELEMENT_DATA[ element ] ) do
            if KEEP_UPDATED[ i ] then
                ibOnElementDataChange_handler( i, v )
            end
        end
    end
    addEventHandler( "ibOnBrowserDocumentReady", browser_element, ibOnBrowserDocumentReady_handler )

    local function ibOnWebInputTextChange_handler( text )
        --iprint( "TEXT CHANGED:", text )
        _IB_ELEMENT_DATA[ element ].text = text
        triggerEvent( "ibOnWebInputTextChange", element, text )
    end
    addEventHandler( "ibOnWebInputTextChange", browser, ibOnWebInputTextChange_handler )

    local function ibWebEditSetText( text )
        triggerEvent( "ibBrowserSetElementHTML", browser_element, "ibWebEdit", text )
    end
    addEventHandler( "ibWebEditSetText", browser_element, ibWebEditSetText )

    local is_focused = false
    local function onClientBrowserInputFocusChanged_handler( focused )
        is_focused = focused
        guiSetInputMode( focused and "no_binds" or "no_binds_when_editing" )
        if _IB_ELEMENT_DATA[ element ].bg_color_focused then
            ibOnElementDataChange_handler( "bg_color", focused and _IB_ELEMENT_DATA[ element ].bg_color_focused or _IB_ELEMENT_DATA[ element ].bg_color )
        end
        triggerEvent( "ibOnWebInputFocusChange", element, focused )
    end
    addEventHandler( "onClientBrowserInputFocusChanged", browser, onClientBrowserInputFocusChanged_handler )

    local function onClientElementDestroy_handler( )
        if is_focused then guiSetInputMode( "no_binds_when_editing" ) end
        if isElement( browser_element ) then destroyElement( browser_element ) end
    end
    addEventHandler( "onClientElementDestroy", element, onClientElementDestroy_handler, false )

    return element
end

addEvent( "ibWebEditSetText" )
addEvent( "ibOnWebInputTextChange" )
addEvent( "ibOnWebInputFocusChange" )

_RENDER_FUNCTIONS[ E_CLASS ] = function( element, data, parent_px, parent_py, mouse_px, mouse_py, alpha )
    local px, py = parent_px + data.px, parent_py + data.py
    local alpha  = alpha * data.alpha

    return px, py, data.sx, data.sy, mouse_px + data.px, mouse_py + data.py, alpha
end