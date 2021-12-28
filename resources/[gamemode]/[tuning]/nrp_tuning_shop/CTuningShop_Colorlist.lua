function CreateColorlist( data, conf )
    if isTimer( UI_elements.timer_colorlist ) then killTimer( UI_elements.timer_colorlist ) end
    UI_elements.colorlist_area = ibCreateArea( wSide.px, wSide.py, wSide.sx, wSide.sy )

    local x_width, y_height = wSide.sx, 60
    local title_bg  = ibCreateImage( 0, 0, x_width, y_height, _, UI_elements.colorlist_area, 0xff536885 )
    ibCreateLabel( 20, y_height / 2, 0, 0, conf.title or "Настройка цвета", title_bg ):ibBatchData( { align_y = "center", font = ibFonts.semibold_14 } )

    --local bg = ibCreateImage( 0, y_height, x_width, wSide.sy - y_height, _, UI_elements.colorlist_area, 0xcc475870 )

    local rt, sc = ibCreateScrollpane( 0, y_height, x_width, wSide.sy - y_height, UI_elements.colorlist_area )

    local colors = conf.colors or {
        "#ffffff", "#46ef72", "#8e00e8", "#cb29e9", "#e0a242", "#58e4d8", "#e04b55"
    }
    local colors_converted = { }
    local colors_rgba = { }
    for i, v in pairs( colors ) do
        local r, g, b, a = hex2rgb( v )
        table.insert( colors_converted, tocolor( r, g, b, a or 255 ) )
        table.insert( colors_rgba, { r, g, b, a or 255 } )
    end

    local r, g, b, a = unpack( colors_rgba[ 1 ] )

    local color_sx, color_sy = 300, 34
    local check_sx, check_sy = 18, 14

    local current_selection = 1

    local y_height = 50
    local npx, npy = 0, 0

    local ticks = { }

    for i = 1, #colors do
        local bg        = ibCreateImage( npx, npy, x_width, y_height + 1, _, rt, 0xcc475870 )
        ibCreateImage( npx + 0, npy + y_height, x_width, 1, _, rt, 0x20ffffff ):ibData( "priority", 5 )
        ibCreateImage( x_width / 2 - color_sx / 2, y_height / 2 - color_sy / 2, color_sx, color_sy, "img/bg_color.png", bg, colors_converted[ i ] )
        local tick      = ibCreateImage( x_width / 2 - check_sx / 2, y_height / 2 - check_sy / 2, check_sx, check_sy, "img/icon_check.png", bg ):ibData( "alpha", 0 )
        
        table.insert( ticks, tick )

        local detect_area    = ibCreateArea( 0, 0, x_width, y_height, bg )

        addEventHandler( "ibOnElementMouseEnter", detect_area, function( )
            bg:ibData( "color", 0xff677e9f )
            bg:ibData( "priority", 1 )
            tick:ibAlphaTo( 255, 150 )
        end, false )

        addEventHandler( "ibOnElementMouseLeave", detect_area, function( )
            bg:ibData( "color", 0xcc475870 )
            bg:ibData( "priority", 0 )
            if current_selection ~= i then
                tick:ibAlphaTo( 0, 0 )
            end
        end, false )

        addEventHandler( "ibOnElementMouseClick", detect_area, function( key, state )
            if key ~= "left" then return end
            if state == "up" then 
                ibClick()
                current_selection = i
                for i, v in pairs( ticks ) do
                    v:ibAlphaTo( i == current_selection and 255 or 0, 150 )
                end
                if conf.OnChange then
                    conf.OnChange( unpack( colors_rgba[ i ] ) )
                end
            end
        end, false )

        npy = npy + y_height
    end

    if npy < wSide.sy - 60 then
        ibCreateImage( npx, npy, x_width, wSide.sy - npy + 60, _, rt, 0xcc475870 )
        sc:ibData( "visible", false )
    else
        sc:ibData( "visible", true )
        sc:AdaptHeightToContents()
    end

    if conf.OnChange then
        conf.OnChange( r, g, b, a )
    end
end

function ShowColorlist( instant )
    if isTimer( UI_elements.timer_colorlist ) then killTimer( UI_elements.timer_colorlist ) end
    if instant then
        UI_elements.colorlist_area:ibBatchData(
            {
                px = wSide.px, py = wSide.py
            }
        )
        UI_elements.colorlist_area:ibBatchData( { disabled = false, alpha = 255 } )
    else
        UI_elements.colorlist_area:ibMoveTo( wSide.px, wSide.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.colorlist_area:ibBatchData( { disabled = false } )
        UI_elements.colorlist_area:ibAlphaTo( 255, 500 * ANIM_MUL, "OutQuad" )
    end
end

function HideColorlist( instant )
    if isTimer( UI_elements.timer_colorlist ) then killTimer( UI_elements.timer_colorlist ) end
    if not isElement( UI_elements.colorlist_area ) then return end
    if instant then
        UI_elements.colorlist_area:ibBatchData(
            {
                px = x, py = wSide.py
            }
        )
        UI_elements.colorlist_area:ibBatchData( { disabled = true, alpha = 0 } )
    else
        UI_elements.colorlist_area:ibMoveTo( x, wSide.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.colorlist_area:ibBatchData( { disabled = true } )
        UI_elements.colorlist_area:ibAlphaTo( 0, 50 * ANIM_MUL, "OutQuad" )
    end
end

function DestroyColorlist( instant )
    if isTimer( UI_elements.timer_colorlist ) then killTimer( UI_elements.timer_colorlist ) end
    if instant then
        if isElement( UI_elements.colorlist_area ) then destroyElement( UI_elements.colorlist_area ) end
    else
        HideColorlist( instant )
        UI_elements.timer_colorlist = setTimer( DestroyColorlist, 150 * ANIM_MUL, 1, true )
    end
end
