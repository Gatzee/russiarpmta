--local gedit = guiCreateEdit(0,0,0,0,tostring(text) or "",false,GlobalEditParent)
--guiSetProperty(gedit,"ClippedByParent","False")

local _IB_EDIT_PARENT = guiCreateLabel( 0, 0, 0, 0, "", false )

local E_CLASS = "ibEdit"

local DEFAULT_VALUES = {
    visible         = true,
    disabled        = false,
    priority        = 0,

    text            = "Empty Label",
    px              = 0,
    py              = 0,
    sx              = 0,
    sy              = 0,
    color           = 0xffffffff,
    bg_color        = 0x99000000,
    caret_color     = 0xFFff0000,
    scale_x         = 1,
    scale_y         = 1,
    font            = "default",
    align_x         = "left",
    -- align_y         = "top",
    clip            = false,
    wordbreak       = false,
    postgui         = false,
    colored         = false,
    subpixel        = false,
    rotation        = 0,
    rotation_center_x = 0,
    rotation_center_y = 0,

    caret_position  = 0,
    symbols_shift   = 0,
    max_length      = 128,

    alpha           = 255,
}

function ibEdit( self, resource )
    if type( self ) ~= "table" then
        outputDebugString( "Bad argument @ibEdit[1], expect table got ".. type( self ), 1 )
        return
    end
    local sourceResource = sourceResource or resource or _THIS_RESOURCE
    local element = ibCreateNewElementOfClass( self, E_CLASS, sourceResource )
    ibSetDefaultValues( self, DEFAULT_VALUES )

    guiSetInputMode( "no_binds_when_editing" )

    triggerEvent( "ibOnElementCreate", element, self, E_CLASS, sourceResource )

    local cegui_edit = guiCreateEdit( self.px, self.py, self.sx, self.sy, "", false, _IB_EDIT_PARENT )
    guiSetProperty( cegui_edit, "ClippedByParent", "False" )
    guiSetProperty( cegui_edit, "BlinkCaret", "False" )
    
    guiSetAlpha( cegui_edit, 0 )

    ibSetData( element, "cegui_edit", cegui_edit )

    local repeat_timer

    local function ParseKeypress( key, state, repeating )
        if isTimer( repeat_timer ) then killTimer( repeat_timer ) end
        if state then
            if repeating and not getKeyState( key ) then return end

            local repeat_again      = false

            local text              = ibGetData( element, "text" )
            local caret_position    = ibGetData( element, "caret_position" )

            if key == "arrow_l" or key == "mouse_wheel_up" then
                caret_position = caret_position > 0 and caret_position - 1 or caret_position
                ibSetData( element, "caret_position", caret_position )
                repeat_again = true

            elseif key == "arrow_r" or key == "mouse_wheel_down" then
                caret_position = caret_position < utf8.len( text ) and caret_position + 1 or caret_position
                ibSetData( element, "caret_position", caret_position )
                repeat_again = true

            elseif key == "backspace" then
                text = utf8.remove( text, caret_position, caret_position )
                ibSetData( element, "text", text )
                ParseKeypress( "arrow_l", true )
                repeat_again = true

            elseif key == "delete" then
                text = utf8.remove( text, caret_position + 1, caret_position +1 )
                ibSetData( element, "text", text )
                repeat_again = true
                
            end

            if repeat_again and getKeyState( key ) then
                repeat_timer = setTimer( ParseKeypress, not repeating and 350 or 50, 1, key, true, true )
            end

        end
    end

    local function GetViewableCharacters( )
        local text          = ibGetData( element, "text" )
        local symbols_shift = ibGetData( element, "symbols_shift" )
        local sx            = ibGetData( element, "sx" )

        local viewable_characters = 0

        local scale_x   = ibGetData( element, "scale_x" )
        local font      = ibGetData( element, "font" )

        for i = symbols_shift, utf8.len( text ) do
            local test_text = utf8.sub( text, symbols_shift, i )
            local width     = dxGetTextWidth( test_text, scale_x, font )
            if width < sx then
                viewable_characters = viewable_characters + 1
            end
        end

        viewable_characters = viewable_characters > 1 and viewable_characters - 1 or viewable_characters

        return viewable_characters
    end

    local function SetFocused( state )
        if state then
            removeEventHandler( "onClientKey", root, ParseKeypress )
            addEventHandler( "onClientKey", root, ParseKeypress )
            ibSetData( element, "focused", true )
            ibSetData( element, "last_blink", nil )
            ibSetData( element, "caret_state", true  )
            guiSetSize( cegui_edit, 0, 0, false )

        else
            removeEventHandler( "onClientKey", root, ParseKeypress )
            ibSetData( element, "focused", nil )
            ibSetData( element, "last_blink", nil )
            ibSetData( element, "caret_state", nil  )
            guiSetSize( cegui_edit, self.sx, self.sy, false )

        end
        triggerEvent( "ibOnWebInputFocusChange", element, state )
    end

    addEventHandler( "onClientGUIBlur", cegui_edit, function( )
        if source == cegui_edit then
            SetFocused( false )
        end
    end, true )

    addEventHandler( "onClientGUIFocus", cegui_edit, function( )
        if source == cegui_edit then
            SetFocused( true )
        end
    end, true )

    addEventHandler( "onClientGUIChanged", cegui_edit, function() 
        local insert_text = guiGetText( cegui_edit )
        guiSetText( cegui_edit, "" )
        
        local pattern = ibGetData( element, "pattern" )
        if pattern then
            insert_text = utf8.match( insert_text, pattern )
            if not insert_text then return end
        end

        local insert_text_length = utf8.len( insert_text )
        if insert_text_length <= 0 then return end

        local text = ibGetData( element, "text" )

        local caret_position = ibGetData( element, "caret_position" ) + insert_text_length
        text = utf8.insert( text, caret_position, insert_text )

        local len = utf8.len( text )
        if len > ibGetData( element, "max_length" ) then return end

        ibSetData( element, "text", text )
        ibSetData( element, "caret_position", caret_position )
    end, false )

    addEventHandler( "ibOnElementDataChange", element, function( key, value, old )
        if key == "caret_position" then
            local symbols_shift         = ibGetData( element, "symbols_shift" )
            local viewable_characters   = GetViewableCharacters( )

            while value < symbols_shift do
                symbols_shift = symbols_shift - 1
            end

            while value > symbols_shift + viewable_characters + 1 do
                symbols_shift = symbols_shift + 1
            end

            ibSetData( element, "symbols_shift", symbols_shift )
            ibSetData( element, "viewable_characters", GetViewableCharacters( ) )

            ibSetData( element, "last_blink", nil )
            ibSetData( element, "caret_state", nil  )
        elseif key == "focused" then
            if value then
                guiBringToFront( cegui_edit )
                
                local symbols_shift             = ibGetData( element, "symbols_shift" )
                local viewable_characters       = ibGetData( element, "viewable_characters" ) or 0
                ibSetData( element, "caret_position", symbols_shift + viewable_characters )
            end
        end
    end )

    function handleMouseClick( key, state )
        if key ~= "left" or state ~= "down" then return end

        if source == element then
            guiBringToFront( cegui_edit )
            local mouse     = Vector2( CURSOR_X, CURSOR_Y )
            local px        = ibGetData( element, "real_px" )
            local mx        = mouse.x - px

            local text      = ibGetData( element, "text" )

            local symbols_shift             = ibGetData( element, "symbols_shift" )
            local viewable_characters       = ibGetData( element, "viewable_characters" ) or 0

            local scale_x       = ibGetData( element, "scale_x" )
            local font          = ibGetData( element, "font" )
            local caret_ox      = 0
            if ibGetData( element, "align_x" ) == "center" then
                caret_ox        = ibGetData( element, "sx" ) / 2 - dxGetTextWidth( text, scale_x, font ) / 2
            end

            for i = symbols_shift, symbols_shift + viewable_characters do
                local caret_text_start  = utf8.sub( text, symbols_shift, i )
                local caret_px          = dxGetTextWidth( caret_text_start, scale_x, font ) + caret_ox

                if caret_px > mx then
                    ibSetData( element, "caret_position", i )
                    return
                end
            end

            ibSetData( element, "caret_position", symbols_shift + viewable_characters )
        end
    end
    addEventHandler( "ibOnElementMouseClick", element, handleMouseClick, false )

    addEventHandler( "onClientElementDestroy", element, function()
        if source ~= element then return end
        if isElement( cegui_edit ) then destroyElement( cegui_edit ) end
        removeEventHandler( "onClientKey", root, ParseKeypress )
        removeEventHandler( "ibOnElementMouseClick", _IB_ROOT, handleMouseClick )
    end, false )
    
    ibSetData( element, "caret_position", 0 )

    return element
end

local dxDrawRectangle       = dxDrawRectangle
local dxGetTextWidth        = dxGetTextWidth
local guiSetPosition        = guiSetPosition

_RENDER_FUNCTIONS[ E_CLASS ] = function( element, data, parent_px, parent_py, mouse_px, mouse_py, alpha )
    local px, py = parent_px + data.px, parent_py + data.py

    local alpha         = alpha * data.alpha
    if alpha > 0 then

        local cegui_edit    = ibGetData( element, "cegui_edit" )
        local text          = ibGetData( element, "text" )

        dxDrawRectangle( 
            px, py, data.sx, data.sy, 
            data.bg_color 
        )

        local symbols_shift         = ibGetData( element, "symbols_shift" )
        local viewable_characters   = ibGetData( element, "viewable_characters" ) or 0

        local caret_position            = ibGetData( element, "caret_position" )
        local caret_position_drawable   = caret_position - symbols_shift
        local caret_text_start          = utf8.sub( text, symbols_shift, symbols_shift + caret_position_drawable )
        local caret_px                  = dxGetTextWidth( caret_text_start, data.scale_x, data.font )
        if data.align_x == "center" then
            caret_px = data.sx / 2 + caret_px - dxGetTextWidth( text, data.scale_x, data.font ) / 2
        end

        dxDrawText( 
            utf8.sub( text, symbols_shift, symbols_shift + viewable_characters ), 
            px, py, px + data.sx, py + data.sy,
            ColorMulAlpha( data.color, alpha ), data.scale_x, data.scale_y,
            data.font, data.align_x, "center",
            data.clip, data.wordbreak, data.postgui,
            data.colored, data.subpixel,
            data.rotation, data.rotation_center_x, data.rotation_center_y
        )

        if data.focused then
            guiSetPosition( cegui_edit, mouse_px + data.px, mouse_py + data.py, false )

            local caret_state   = ibGetData( element, "caret_state" )
            local last_blink    = data.last_blink

            if not last_blink or getTickCount() - last_blink > 500 then
                ibSetData( element, "last_blink", getTickCount() )
                caret_state = not caret_state
                ibSetData( element, "caret_state", caret_state  )
            end

            if caret_state then
                local height = data.sy * 0.6
                dxDrawRectangle( 
                    px + caret_px, py + data.sy / 2 - height / 2, 
                    1, height, 
                    ColorMulAlpha( data.caret_color, alpha )
                )
            end

        end

    end

    return px, py, data.sx, data.sy, mouse_px + data.px, mouse_py + data.py, alpha
end