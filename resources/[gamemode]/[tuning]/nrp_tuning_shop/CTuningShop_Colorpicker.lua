function CreateColorpicker( data, conf )
    if isTimer( UI_elements.timer_colorpicker ) then killTimer( UI_elements.timer_colorpicker ) end
    UI_elements.colorpicker_area = ibCreateArea( wSide.px, wSide.py, wSide.sx, wSide.sy )

    local x_width, y_height = wSide.sx, 60
    local title_bg  = ibCreateImage( npx, npy, x_width, y_height, _, UI_elements.colorpicker_area, 0xff536885 )
    
    ibCreateLabel( 20, y_height / 2, 0, 0, conf.title or "Настройка цвета", title_bg ):ibBatchData( { align_y = "center", font = ibFonts.semibold_14 } )

    local bg = ibCreateImage( 0, y_height, x_width, wSide.sy - y_height, _, UI_elements.colorpicker_area, 0xcc475870 )
    
    UI_elements.colorwheel_texture = DxTexture( "img/colorwheel.png" )
    UI_elements.colorwheel = ibCreateImage( x_width / 2 - 100, 60 + 20, 199, 199, UI_elements.colorwheel_texture, UI_elements.colorpicker_area )

    UI_elements.colorpicker_selector_dummy = ibCreateArea( 100, 100, 0, 0, UI_elements.colorwheel ):ibBatchData( { disabled = true } )
    UI_elements.colorpicker_selector = ibCreateImage( 0, 0, 32, 32, "img/icon_colorpoint.png", UI_elements.colorpicker_selector_dummy )
    UI_elements.colorpicker_selector:center():ibBatchData( { disabled = true } )

    local brightness = conf.brightness or 1
    local r, g, b, a = 255 * brightness, 255 * brightness, 255 * brightness, 255
    UI_elements.colorwheel:ibData( "color", tocolor( 255 * brightness, 255 * brightness, 255 * brightness, 255 ) )

    local texture_px, texture_py = 100, 100

    local function ibOnMouseMove( )
        local cx, cy = getCursorPosition( )
        cx, cy = cx * x, cy * y

        local real_px, real_py = UI_elements.colorwheel:ibData( "real_px" ), UI_elements.colorwheel:ibData( "real_py" )

        texture_px = math.floor( cx - real_px )
        texture_py = math.floor( cy - real_py )
        
        texture_px = math.max( 1, math.min( 198, texture_px ) )
        texture_py = math.max( 1, math.min( 198, texture_py ) )
        
        local pixels = dxGetTexturePixels( UI_elements.colorwheel_texture )
        local nr, ng, nb, na = dxGetPixelColor( pixels, texture_px, texture_py )

        if na and na > 0 then
            UI_elements.colorpicker_selector_dummy:ibBatchData( { px = texture_px, py = texture_py } )

            r, g, b, a = nr, ng, nb, na
            
            if conf.OnChange then
                conf.OnChange( math.floor( r * brightness ), math.floor( g * brightness ), math.floor( b * brightness ), a )
            end

        end
    end

    addEventHandler( "ibOnElementMouseClick", UI_elements.colorwheel, function( key, state )
        if key ~= "left" or state ~= "down" then return end
        removeEventHandler( "ibOnRender", UI_elements.colorwheel, ibOnMouseMove )
        addEventHandler( "ibOnRender", UI_elements.colorwheel, ibOnMouseMove )
    end, false )

    addEventHandler( "ibOnMouseRelease", UI_elements.colorwheel, function( )
        removeEventHandler( "ibOnRender", UI_elements.colorwheel, ibOnMouseMove )
    end )

    UI_elements.colorpicker_sch = ibScrollbarH( { px = 90, py = 250, sx = 160, sy = 39, parent = bg } )
    :ibSetStyle( "tuning" ):ibData( "position", brightness )

    addEventHandler( "ibOnElementDataChange", UI_elements.colorpicker_sch, function( key, value )
        if key == "position" then            
            brightness = value
            UI_elements.colorwheel:ibData( "color", tocolor( 255 * brightness, 255 * brightness, 255 * brightness, 255 ) )

            if conf.OnChange then
                conf.OnChange( math.floor( r * brightness ), math.floor( g * brightness ), math.floor( b * brightness ), a )
            end
        end
    end, false )


    UI_elements.colorpicker_apply = ibCreateButton(     99, 60 + 266, 144, 70, UI_elements.colorpicker_area,
                                                        "img/btn_apply.png", "img/btn_apply.png", "img/btn_apply.png",
                                                        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
    addEventHandler( "ibOnElementMouseClick", UI_elements.colorpicker_apply, function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick()
        if conf.OnApply then
            conf.OnApply( math.floor( r * brightness ), math.floor( g * brightness ), math.floor( b * brightness ), a )
        end
    end, false )
    UI_elements.colorpicker_cancel = ibCreateButton(    115, 60 + 327, 111, 35, UI_elements.colorpicker_area,
                                                        "img/btn_cancel_2.png", "img/btn_cancel_2.png", "img/btn_cancel_2.png",
                                                        0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
    addEventHandler( "ibOnElementMouseClick", UI_elements.colorpicker_cancel, function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick()
        if conf.OnCancel then
            conf.OnCancel( )
        end
    end, false )

    if conf.OnChange then
        conf.OnChange( r, g, b, a )
    end
end

function ShowColorpicker( instant )
    if isTimer( UI_elements.timer_colorpicker ) then killTimer( UI_elements.timer_colorpicker ) end
    if instant then
        UI_elements.colorpicker_area:ibBatchData(
            {
                px = wSide.px, py = wSide.py
            }
        )
        UI_elements.colorpicker_area:ibBatchData( { disabled = false, alpha = 255 } )
    else
        UI_elements.colorpicker_area:ibMoveTo( wSide.px, wSide.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.colorpicker_area:ibBatchData( { disabled = false } )
        UI_elements.colorpicker_area:ibAlphaTo( 255, 50 * ANIM_MUL, "OutQuad" )
    end
end

function HideColorpicker( instant )
    if isTimer( UI_elements.timer_colorpicker ) then killTimer( UI_elements.timer_colorpicker ) end
    if not isElement( UI_elements.colorpicker_area ) then return end
    if instant then
        UI_elements.colorpicker_area:ibBatchData(
            {
                px = x, py = wSide.py
            }
        )
        UI_elements.colorpicker_area:ibBatchData( { disabled = true, alpha = 0 } )
    else
        UI_elements.colorpicker_area:ibMoveTo( x, wSide.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.colorpicker_area:ibBatchData( { disabled = true } )
        UI_elements.colorpicker_area:ibAlphaTo( 0, 50 * ANIM_MUL, "OutQuad" )
    end
end

function DestroyColorpicker( instant )
    if isTimer( UI_elements.timer_colorpicker ) then killTimer( UI_elements.timer_colorpicker ) end
    if instant then
        if isElement( UI_elements.colorpicker_area ) then destroyElement( UI_elements.colorpicker_area ) end
    else
        HideColorpicker( instant )
        UI_elements.timer_colorpicker = setTimer( DestroyColorpicker, 150 * ANIM_MUL, 1, true )
    end
end
