function CreateSidebar( )
    UI_elements.side_rt, UI_elements.side_sc = ibCreateScrollpane( wSide.px, wSide.py, wSide.sx, wSide.sy, _,
        {
            scroll_px = -25,
            bg_sx = 0,
            handle_sy = 40,
            handle_sx = 16,
            handle_texture = "img/scroll.png",
            handle_upper_limit = -40 - 20,
            handle_lower_limit = 20 + 60,
        }
    )
end

function ShowSidebar( instant )
    if instant then
        UI_elements.side_rt:ibBatchData(
            {
                px = wSide.px, py = wSide.py
            }
        )
        UI_elements.side_sc:ibBatchData( { disabled = false, alpha = 255 } )
    else
        UI_elements.side_rt:ibMoveTo( wSide.px, wSide.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.side_sc:ibBatchData( { disabled = false } )
        UI_elements.side_sc:ibAlphaTo( 255, 500 * ANIM_MUL, "OutQuad" )
    end
end

function HideSidebar( instant )
    if instant then
        UI_elements.side_rt:ibBatchData(
            {
                px = x, py = wSide.py
            }
        )
        UI_elements.side_sc:ibBatchData( { disabled = true, alpha = 0 } )
    else
        UI_elements.side_rt:ibMoveTo( x, wSide.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.side_sc:ibBatchData( { disabled = true } )
        UI_elements.side_sc:ibAlphaTo( 0, 50 * ANIM_MUL, "OutQuad" )
    end
end

function InitMenuTree( )
    RegenerateMenuTree( )
end

function RegenerateMenuTree( animated )
    IS_HOME_MENU = true

    local model = DATA.vehicle.model
    local is_moto = VEHICLE_CONFIG[ model ].is_moto
    local allow_change_lights_color = VEHICLE_CONFIG[ model ].allow_change_lights_color
    local structure = {
        name = "Улучшения " .. ( is_moto and "мотоцикла" or "автомобиля" )
    }

    for _, data in pairs( MENU_STRUCTURE or { } ) do
        if ( type( data ) ~= "table" or not is_moto )
        or ( is_moto and data.allow_moto and ( data.task ~= TUNING_TASK_LIGHTSCOLOR or allow_change_lights_color ) ) then
            table.insert( structure, data )
        end
    end

    CreateList( structure, animated )
end

function DestroyList( animated )
    local i = 1
    while ( UI_elements[ "sidebar_list_item_" .. i ] ) do
        local element = UI_elements[ "sidebar_list_item_" .. i ]
        if isElement( element ) then
            if animated then
                element:ibAlphaTo( 0, 150 * ANIM_MUL, "OutQuad" )
                element:ibMoveTo( 100, 0, 250 * ANIM_MUL, "OutQuad", true )
                setTimer( function( element ) if isElement( element ) then destroyElement( element ) end end, 500, 1, element )
            else
                destroyElement( element )
            end
        end
        if isElement( UI_elements[ "sidebar_list_line_" .. i ] ) then
            destroyElement( UI_elements[ "sidebar_list_line_" .. i ] )
        end
        i = i + 1
    end
end

function CreateList( list, animated )
    DestroyList( animated )

    local list = table.copy( list )

    local npx, npy = 0, 0
    local x_width, y_height = wSide.sx, 60
    local icon_px, icon_py = x_width - 24 - 18, y_height / 2 - 5

    table.insert( list, 1, { name = list.name, header = true } )

    for i, v in ipairs( list ) do
        if v.header then
            local bg        = ibCreateImage( npx, npy, x_width, y_height + 1, _, UI_elements.side_rt, 0xff536885 )
            local line      = ibCreateImage( npx + 0, npy + y_height, x_width, 1, _, UI_elements.side_rt, 0x20ffffff ):ibData( "priority", 5 )
            ibCreateLabel( 20, y_height / 2, 0, 0, v.name or "-----", bg ):ibBatchData( { align_y = "center", font = ibFonts.semibold_14 } )

            UI_elements[ "sidebar_list_item_" .. i ] = bg
            UI_elements[ "sidebar_list_line_" .. i ] = line

            if animated then
                bg:ibBatchData( { alpha = 0, px = npx + 30 } )
                bg:ibMoveTo( -30, 0, 200 * ANIM_MUL, "OutQuad", true )
                bg:ibAlphaTo( 255, 200 * ANIM_MUL, "OutQuad" )
            end

        else
            local bg        = ibCreateImage( npx, npy, x_width, y_height + 1, _, UI_elements.side_rt, 0xcc475870 )
            local line      = ibCreateImage( npx + 0, npy + y_height, x_width, 1, _, UI_elements.side_rt, 0x20ffffff ):ibData( "priority", 5 )
            if v.img then
                local img_area  = ibCreateArea( 20, 0, 26, y_height, bg )
                ibCreateImage( 20, 0, 0, 0, "img/menu/" .. v.img, img_area ):ibSetRealSize( ):center( )
            end
            ibCreateLabel( v.img and 58 or 20, y_height / 2, 0, 0, v.name or "-----", bg ):ibBatchData( { align_y = "center", font = ibFonts.semibold_12, color = 0xffd0d6db } )
            local icon      = ibCreateImage( icon_px, y_height / 2 - 5, 18, 10, "img/icon_arrow.png", bg ):ibData( "alpha", 0 )

            local detect_area    = ibCreateArea( 0, 0, x_width, y_height, bg )

            addEventHandler( "ibOnElementMouseEnter", detect_area, function( )
                icon:ibAlphaTo( 255, 125 * ANIM_MUL, "OutQuad" )
                icon:ibBatchData( { px = icon_px - 25, py = icon_py } )
                icon:ibMoveTo( icon_px, icon_py, 125 * ANIM_MUL, "OutQuad" )
                bg:ibData( "color", 0xff677e9f )
                bg:ibData( "priority", 1 )
            end )

            addEventHandler( "ibOnElementMouseLeave", detect_area, function( )
                icon:ibAlphaTo( 0, 125 * ANIM_MUL, "OutQuad" )
                icon:ibMoveTo( icon_px + 25, icon_py, 125 * ANIM_MUL, "OutQuad" )
                bg:ibData( "color", 0xcc475870 )
                bg:ibData( "priority", 0 )
            end )

            addEventHandler( "ibOnElementMouseClick", detect_area, function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()
                ParseMenuNavigation( v )
            end, false )

            if animated then
                bg:ibBatchData( { alpha = 0, px = npx + 30 } )
                bg:ibMoveTo( -30, 0, 200 * ANIM_MUL, "OutQuad", true )
                bg:ibAlphaTo( 255, 200 * ANIM_MUL, "OutQuad" )
            end

            UI_elements[ "sidebar_list_item_" .. i ] = bg
            UI_elements[ "sidebar_list_line_" .. i ] = line
        end

        npy = npy + y_height
    end

    -- Фон если вдруг количество пунктов меньше высоты экрана
    if npy < wSide.sy then
        local bg = ibCreateImage( npx, npy, x_width, wSide.sy - npy, _, UI_elements.side_rt, 0xcc475870 )
        if animated then
            bg:ibBatchData( { alpha = 0, px = npx + 30 } )
            bg:ibMoveTo( -30, 0, 200 * ANIM_MUL, "OutQuad", true )
            bg:ibAlphaTo( 255, 200 * ANIM_MUL, "OutQuad" )
        end

        UI_elements[ "sidebar_list_item_" .. ( #list + 1 ) ] = bg
        UI_elements.side_sc:ibData( "visible", false )

    else
        UI_elements.side_sc:ibData( "visible", true )
    end

    UI_elements.side_sc:ibData( "position", 0 )
    UI_elements.side_rt:ibData( "sy", math.max( npy, wSide.sy ) )
end
