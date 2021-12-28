function CreateVinylColorpicker( data, conf )

    if isElement( UI_elements.bg_setting_color ) then 
        UI_elements.vinyl_colorpicker_selector_dummy:center()
        return 
    end

    UI_elements.bg_setting_color = ibCreateImage( wSettingColor.px, wSettingColor.py, wSettingColor.sx, wSettingColor.sy, "img/vinyl_setting/bg_setting_color.png" )
        
    UI_elements.vinyl_colorwheel_texture = DxTexture( "img/colorwheel.png" )
    UI_elements.vinyl_colorwheel = ibCreateImage( (wSettingColor.sx - 199)/2, 76, 199, 199, UI_elements.vinyl_colorwheel_texture, UI_elements.bg_setting_color )

    UI_elements.vinyl_colorpicker_selector_dummy = ibCreateArea( 100, 100, 0, 0, UI_elements.vinyl_colorwheel ):ibBatchData( { disabled = true } )
    UI_elements.vinyl_colorpicker_selector = ibCreateImage( 0, 0, 32, 32, "img/icon_colorpoint.png", UI_elements.vinyl_colorpicker_selector_dummy )
    UI_elements.vinyl_colorpicker_selector:center():ibBatchData( { disabled = true } )

    local brightness = conf.brightness or 1
    local r, g, b, a = 255 * brightness, 255 * brightness, 255 * brightness, 255
    UI_elements.vinyl_colorwheel:ibData( "color", tocolor( 255 * brightness, 255 * brightness, 255 * brightness, 255 ) )

    local texture_px, texture_py = 100, 100

    local function ibOnMouseMove( )
        local cx, cy = getCursorPosition( )
        cx, cy = cx * x, cy * y

        local real_px, real_py = UI_elements.vinyl_colorwheel:ibData( "real_px" ), UI_elements.vinyl_colorwheel:ibData( "real_py" )
        
        texture_px = math.floor( cx - real_px )
        texture_py = math.floor( cy - real_py )
        
        texture_px = math.max( 1, math.min( 198, texture_px ) )
        texture_py = math.max( 1, math.min( 198, texture_py ) )
        
        local pixels = dxGetTexturePixels( UI_elements.vinyl_colorwheel_texture )
        local nr, ng, nb, na = dxGetPixelColor( pixels, texture_px, texture_py )

        if na and na > 0 then
            UI_elements.vinyl_colorpicker_selector_dummy:ibBatchData( { px = texture_px, py = texture_py } )

            r, g, b, a = nr, ng, nb, na

            if conf.OnChange then
                conf.OnChange( math.floor( r * brightness ), math.floor( g * brightness ), math.floor( b * brightness ), a )
            end
        end
    end

    addEventHandler( "ibOnElementMouseClick", UI_elements.vinyl_colorwheel, function( key, state )
        if key ~= "left" or state ~= "down" then return end
        if isElement( UI_elements.vinyl_colorwheel ) then
            removeEventHandler( "ibOnRender", UI_elements.vinyl_colorwheel, ibOnMouseMove )
            addEventHandler( "ibOnRender", UI_elements.vinyl_colorwheel, ibOnMouseMove )
        end
    end, false )

    addEventHandler( "ibOnMouseRelease", UI_elements.vinyl_colorwheel, function( )
        if isElement( UI_elements.vinyl_colorwheel ) then
            removeEventHandler( "ibOnRender", UI_elements.vinyl_colorwheel, ibOnMouseMove )
        end
    end )

    UI_elements.vinyl_colorpicker_sch = ibScrollbarH( { px = 60, py = 295, sx = 160, sy = 39, parent = UI_elements.bg_setting_color } )
    :ibSetStyle( "tuning" )
    :ibData( "position", brightness )

    addEventHandler( "ibOnElementDataChange", UI_elements.vinyl_colorpicker_sch, function( key, value )
        if key == "position" then            
            brightness = value

            UI_elements.vinyl_colorwheel:ibData( "color", tocolor( 255 * brightness, 255 * brightness, 255 * brightness, 255 ) )

            if conf.OnChange then
                conf.OnChange( math.floor( r * brightness ), math.floor( g * brightness ), math.floor( b * brightness ), a )
            end
        end
    end, false )

    -- Сброс
    ibCreateButton( 0, 330 * wSettingColor.scale, 111 * wSettingColor.scale, 45 * wSettingColor.scale, UI_elements.bg_setting_color,
        "img/btn_reset.png", "img/btn_reset.png", "img/btn_reset.png",
        0xAAFFFFFF, 0xFFFFFFFF, 0xCCFFFFFF ):center_x( )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            if conf.OnReset then
                UI_elements.vinyl_colorpicker_selector_dummy:center( )
                UI_elements.vinyl_colorpicker_sch:ibData( "position", 1 )

                conf.OnReset( r, g, b, a )
            end
        end )
end

function ShowVinylColorpicker( instant )
    if not isElement( UI_elements.bg_setting_color ) then return end
    if instant then
        UI_elements.bg_setting_color:ibBatchData(
            {
                px = wSettingColor.px, py = wSettingColor.py
            }
        )
        UI_elements.bg_setting_color:ibBatchData( { disabled = false, alpha = 255 } )
    else
        UI_elements.bg_setting_color:ibMoveTo( wSettingColor.px, wSettingColor.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.bg_setting_color:ibBatchData( { disabled = false } )
        UI_elements.bg_setting_color:ibAlphaTo( 255, 50 * ANIM_MUL, "OutQuad" )
    end
end

function HideVinylColorpicker( instant )
    if not isElement( UI_elements.bg_setting_color ) then return end
    if instant then
        UI_elements.bg_setting_color:ibBatchData(
            {
                px = wSettingColor.px + wSettingColor.sx + 94 * wSettingColor.scale, py = wSettingColor.py
            }
        )
        UI_elements.bg_setting_color:ibBatchData( { disabled = true, alpha = 0 } )
    else
        UI_elements.bg_setting_color:ibMoveTo( wSettingColor.px + wSettingColor.sx + 94 * wSettingColor.scale, wSettingColor.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.bg_setting_color:ibBatchData( { disabled = true } )
        UI_elements.bg_setting_color:ibAlphaTo( 0, 50 * ANIM_MUL, "OutQuad" )
    end
end

function DestroyVinylColorpicker( instant )
    if instant then
        if isElement( UI_elements.bg_setting_color ) then destroyElement( UI_elements.bg_setting_color ) end
    else
        HideVinylColorpicker( instant )
    end
end
