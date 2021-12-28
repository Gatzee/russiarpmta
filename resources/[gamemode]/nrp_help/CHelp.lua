loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "Globals" )
Extend( "ShBusiness" )
Extend( "CInterior" )
Extend( "ShApartments" )
Extend( "ShVipHouses" )
Extend( "ShClothesShops" )

function onHUDDisplayHint_handler( id, values )
    if id and values then
        SHOW_ON_OPEN = { id, values }
    else
        SHOW_ON_OPEN = nil
    end
end
addEvent( "onHUDDisplayHint", true )
addEventHandler( "onHUDDisplayHint", root, onHUDDisplayHint_handler )

function ShowInfoUI_handler( state, tab_data )
    ShowInfoUI( state )
    if tab_data then
        SwitchToTabSimulated( unpack( tab_data ) )
    end
end
addEvent( "ShowInfoUI", true )
addEventHandler( "ShowInfoUI", root, ShowInfoUI_handler )

function ShowInfoUI( state, conf )
    if state then
        ibAutoclose( )
        ibWindowSound()
        ShowInfoUI( false )

        local conf = conf or { }
        UI_elements = { }
        local x, y = guiGetScreenSize()

        UI_elements.texture_preload = ibCreatePreloader(
            {
                "img/bg_container.png",
                "img/bg_header.png",
                "img/bg_left.png",
                "img/body_bottom_gradient.png",
                "img/btn_find_near.png",
                "img/btn_show_on_map.png",
                "img/header_line_active.png",
                "img/icon_dots.png",
                ":nrp_shared/img/confirm_btn_close.png",
                "img/btn_find_own_businesses.png",
                "img/btn_remove_navigation.png",
            }
        )

        UI_elements.black_bg = ibCreateBackground( 0xaa000000, ShowInfoUI, _, true ) :ibData( "alpha", 0 )

        UI_elements.bg_texture  = dxCreateTexture( "img/bg_container.png" )

        local sx, sy = dxGetMaterialSize( UI_elements.bg_texture )
        local px, py = math.floor( ( x - sx ) / 2 ), math.floor( ( y - sy ) / 2 )

        UI_elements.bg = ibCreateImage( px - 300, py, sx, sy, UI_elements.bg_texture, UI_elements.black_bg  ):ibData( "alpha", 0 )

        -- Левое меню - выбор элемента
        UI_elements.bg_left = ibCreateImage( 0, 72, 240, 509, "img/bg_left.png", UI_elements.bg )
        UI_elements.left_pane, UI_elements.left_scroll = ibCreateScrollpane( 0, 72, 240, 509, UI_elements.bg, { scroll_px = -20 } )
        UI_elements.left_scroll:ibSetStyle( "slim_small_nobg" ):ibData( "priority", 100 )

        UI_elements.items_pane, UI_elements.items_scroll = ibCreateScrollpane( 240, 72, 560, 508, UI_elements.bg, { scroll_px = -20 } )
        UI_elements.items_scroll:ibSetStyle( "slim_nobg" ):ibBatchData( { absolute = true, sensivity = 150 } ):ibData( "smooth", true )

        -- Верхняя часть
        UI_elements.bg_header = ibCreateImage( 0, 0, 800, 72, "img/bg_header.png", UI_elements.bg )
        UI_elements.btn_hide_gps = ibCreateButton(  569, 18, 149, 34, UI_elements.bg_header,
                                                    "img/btn_remove_navigation.png", "img/btn_remove_navigation.png", "img/btn_remove_navigation.png",
                                                    0xFFFFFFFF, 0xEEFFFFFF, 0xCCFFFFFF ):ibData( "visible", type( gps_marker ) == "table" )
        :ibOnClick( function( )
            ibClick( )
            DestroyMarkerAndBlip( )
        end )
        UI_elements.button_close = ibCreateButton(  sx - 24 - 24, 24, 22, 22, UI_elements.bg,
                                                    ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                                                    0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            ShowInfoUI( false )
        end )

        local font, npx, npy, nsy, gap = ibFonts.semibold_18, 30, 35, 71, 40
        local buttons, selected_tab = { }
        local default_alpha = 200
        for i, v in pairs( GLOBAL_TABS ) do
            local current_npx = npx
            local name = v.name

            local label = ibCreateLabel( npx, npy, 0, 0, name, UI_elements.bg_header, _, _, _, "left", "center", font ):ibBatchData( { alpha = default_alpha, disabled = true } )
            local label_colored = ibCreateLabel( npx, npy, 0, 0, name, UI_elements.bg_header, 0xffff9759, _, _, "left", "center", font ):ibBatchData( { alpha = 0, disabled = true } )
            
            local bg = ibCreateImage( npx - gap / 2, 0, label:width( ) + gap, nsy, nil, UI_elements.bg_header, 0 ):ibData( "priority", -1 )

            bg:ibOnClick( function( key, state, is_simulated )
                if key ~= "left" or state ~= "up" then return end
                if not is_simulated then ibClick( ) end
                local old_tab = selected_tab or 0

                if old_tab ~= i then
                    selected_tab = i

                    local current = buttons[ selected_tab ]

                    for i, v in pairs( buttons ) do
                        if v ~= current then
                            v.label:ibAlphaTo( default_alpha, 150 )
                            v.label_colored:ibAlphaTo( 0, 150 )
                        end
                    end

                    current.label:ibAlphaTo( 0, 150 )
                    current.label_colored:ibAlphaTo( 255, 150 )

                    local line_sx = label:width( ) * 1.15
                    local line_px = label:ibData( "px" ) + label:width( ) / 2 - line_sx / 2
                    if not isElement( UI_elements.tab_line ) then
                        UI_elements.tab_line = ibCreateImage( line_px, -7, line_sx, 21, "img/header_line_active.png", UI_elements.bg_header ):ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )
                    else
                        UI_elements.tab_line:ibMoveTo( line_px, _, 250 ):ibResizeTo( line_sx, _, 250 )
                    end

                    local move_duration, alpha_duration = 300, 150
                    local max_animation_time = math.max( move_duration, alpha_duration )
                    if selected_tab > old_tab then
                        if isElement( UI_elements.sidebar_parent ) then
                            UI_elements.sidebar_parent:ibMoveTo( -100, 0, move_duration ):ibAlphaTo( 0, alpha_duration )
                            UI_elements.sidebar_parent:ibTimer( function( self ) destroyElement( self ) end, max_animation_time, 1 )
                        end
                        UI_elements.sidebar_parent = CreateTabBar( v.tabs, selected_tab > old_tab, conf ):ibBatchData( { alpha = 0, px = 100 } ):ibAlphaTo( 255, alpha_duration ):ibMoveTo( 0, 0, move_duration )

                    else
                        if isElement( UI_elements.sidebar_parent ) then
                            UI_elements.sidebar_parent:ibMoveTo( 100, 0, move_duration ):ibAlphaTo( 0, alpha_duration )
                            UI_elements.sidebar_parent:ibTimer( function( self ) destroyElement( self ) end, max_animation_time, 1 )
                        end
                        UI_elements.sidebar_parent = CreateTabBar( v.tabs, selected_tab > old_tab, conf ):ibBatchData( { alpha = 0, px = -100 } ):ibAlphaTo( 255, alpha_duration ):ibMoveTo( 0, 0, move_duration )

                    end
                end
            end )

            bg:ibOnLeave( function( )
                if isElement( UI_elements.tab_hover_bg ) then
                    local found = false
                    for i, v in pairs( buttons ) do
                        if ibGetHoveredElement( ) == v.bg then
                            found = true
                            break
                        end
                    end
                    if not found then
                        UI_elements.tab_hover_bg:ibAlphaTo( 0, 250 )
                    end
                end
                if selected_tab ~= i then
                    label:ibAlphaTo( default_alpha, 150 )
                end
            end )

            bg:ibOnHover( function( )
                if not isElement( UI_elements.tab_hover_bg ) then
                    UI_elements.tab_hover_bg = ibCreateImage( current_npx - gap / 2, 0, label:width( ) + gap, nsy, nil, UI_elements.bg_header, 0x10ffffff ):ibBatchData( { alpha = 0, priority = -2 } ):ibAlphaTo( 255, 500 )
                else
                    local move_speed = UI_elements.tab_hover_bg:ibData( "alpha" ) == 0 and 0 or 250
                    UI_elements.tab_hover_bg:ibMoveTo( current_npx - gap / 2, _, move_speed ):ibResizeTo( bg:width( ), _, move_speed ):ibAlphaTo( 255, 100 )
                end
                if selected_tab ~= i then
                    label:ibAlphaTo( 255, 150 )
                end
            end )

            UI_elements[ "tab_" .. i ] = bg

            table.insert( buttons, { bg = bg, label = label, label_colored = label_colored } )

            npx = npx + label:width( ) + gap
        end

        showCursor( true )
        UI_elements.black_bg:ibAlphaTo( 255, 250 )
        UI_elements.bg:ibMoveTo( px, py, 200, "OutQuad" ):ibAlphaTo( 255, 500 )

        if SHOW_ON_OPEN then
            local id, values = unpack( SHOW_ON_OPEN )
            if id == "keyboard" then
                SwitchToTabSimulated( 2, 1, 1 )
            elseif values.tab then
                SwitchToTabSimulated( unpack( values.tab ) )
            else
                buttons[ conf.tab or 1 ].bg:ibSimulateClick( "left", "up" )
            end

            triggerEvent( "onHelpOpenAutomated", localPlayer, SHOW_ON_OPEN )
        else
            buttons[ conf.tab or 1 ].bg:ibSimulateClick( "left", "up" )
        end
    else
        for i, v in pairs( UI_elements or { } ) do
            if isElement( v ) then
                v:destroy( )
            end
        end

        UI_elements = nil
        showCursor( false )
    end
end
addEvent( "onHelpShowRequest", true )
addEventHandler( "onHelpShowRequest", root, ShowInfoUI )

function CreateTabBar( tabs, is_next, conf )
    local move_duration, alpha_duration = 300, 150
    local max_animation_time = math.max( move_duration, alpha_duration )
    if is_next then
        if isElement( UI_elements.contentbar_parent ) then
            UI_elements.contentbar_parent:ibMoveTo( -100, 0, move_duration ):ibAlphaTo( 0, alpha_duration )
            UI_elements.contentbar_parent:ibTimer( function( self ) destroyElement( self ) end, max_animation_time, 1 )
        end
        UI_elements.contentbar_parent = ibCreateArea( 0, 0, 540, 0, UI_elements.items_pane ):ibBatchData( { alpha = 0, px = 100 } ):ibAlphaTo( 255, alpha_duration ):ibMoveTo( 0, 0, move_duration )

    else
        if isElement( UI_elements.contentbar_parent ) then
            UI_elements.contentbar_parent:ibMoveTo( 100, 0, move_duration ):ibAlphaTo( 0, alpha_duration )
            UI_elements.contentbar_parent:ibTimer( function( self ) destroyElement( self ) end, max_animation_time, 1 )
        end
        UI_elements.contentbar_parent = ibCreateArea( 0, 0, 540, 0, UI_elements.items_pane ):ibBatchData( { alpha = 0, px = -100 } ):ibAlphaTo( 255, alpha_duration ):ibMoveTo( 0, 0, move_duration )

    end

    local dummy = ibCreateArea( 0, 0, 0, 0, UI_elements.left_pane )
    local tabs = tabs or { }
    local npx, npy = 0, 0
    local nsx, nsy = 240, 40

    local elements = { }

    if #tabs > 0 then

        local bg_selected = ibCreateImage( npx, npy, 240, 47, "img/bg_selected.png", dummy ):ibData( "priority", 4 )

        local tab_num_current = 0

        local function SwitchTab( tab_num, no_animations )
            local old_tab = tab_num_current
            if old_tab == tab_num then return end

            local target_bg = elements[ "tab_bg_" .. tab_num ]
            local py = target_bg:ibData( "py" )
            ibMoveTo( bg_selected, 0, py - 3, 200 )

            local area_bg, is_new = elements[ "tab_content_area_" .. tab_num ], false
            
            if not isElement( area_bg ) then
                is_new = true
                area_bg = ibCreateArea( 0, -100, 0, 0, UI_elements.contentbar_parent ):ibData( "alpha", 0 )
                elements[ "tab_content_area_" .. tab_num ] = area_bg
            end

            local old_tab_area = old_tab and elements[ "tab_content_area_" .. old_tab ]
            if isElement( old_tab_area ) then old_tab_area:ibData( "priority", -1 ) end
            area_bg:ibData( "priority", 0 )

            if tabs[ tab_num ].create_fn then
                if is_new then
                    local size = tabs[ tab_num ].create_fn( area_bg )
                    if size then
                        area_bg:ibBatchData( { sx = 560, sy = size } )
                        UI_elements.items_pane:ibData( "sy", size )
                        UI_elements.contentbar_parent:ibData( "sy", size )

                        UI_elements.items_scroll:ibData( 'position', 0 )

                        UI_elements.items_pane:AdaptHeightToContents( )
                        UI_elements.items_scroll:UpdateScrollbarVisibility( UI_elements.items_pane )
                    end
                else
                    UI_elements.items_pane:ibData( "sy", area_bg:ibData( "sy" ) )
                    UI_elements.contentbar_parent:ibData( "sy", area_bg:ibData( "sy" ) )

                    UI_elements.items_scroll:ibData( 'position', 0 )

                    UI_elements.items_pane:AdaptHeightToContents( )
                    UI_elements.items_scroll:UpdateScrollbarVisibility( UI_elements.items_pane )
                end
            
            elseif tabs[ tab_num ].menu then
                if is_new then
                    local menu = tabs[ tab_num ].menu
                    local navbar_sy, navbar_padding = 45, 14

                    -- Сортировка списка категорий + добавление категории "все"
                    local categories_list = table.copy( menu.categories or { } )
                    local categories = { }

                    local is_navbar_empty = #categories_list <= 1

                    -- Отступ элементов на 20 пикселей
                    if is_navbar_empty then
                        navbar_sy, navbar_padding = 6, 14
                    end

                    table.insert( categories_list, 1, "all" )
                    for i, v in pairs( categories_list ) do
                        categories[ v ] = { }
                    end

                    -- Фасовка по категориям
                    for i, v in ipairs( menu ) do
                        if categories[ v.category ] then
                            table.insert( categories[ v.category ], v )
                        end
                        table.insert( categories.all, v )
                    end

                    if menu.sort_fn then
                        menu.sort_fn( categories_list, categories )
                    end

                    -- Дефолтные значения меню навигации
                    local npx_default, npy_default = 30, 23

                    -- Текущие значения для подсчёта
                    local npx = npx_default
                    local font = ibFonts.semibold_12

                    local main_nav, dropdown_nav = { }, { }

                    SUBSUBTABS = { }

                    -- Подсчёт какие вкладки должны быть в навбаре, какие в дроп-меню
                    for i, v in pairs( categories_list ) do
                        local name = CATEGORIES_NAMES[ v ] or v
                        local width = dxGetTextWidth( name, 1, font )
                        npx = npx + math.floor( width ) + 30

                        SUBSUBTABS[ i ] = name

                        if npx <= 30 + 450 then
                            table.insert( main_nav, v )
                        else
                            table.insert( dropdown_nav, v )
                        end
                    end

                    local current_tab, current_area = 0
                    local tab_areas = { }
                    local function SwitchNavigationTab( number, is_simulated )
                        if not categories_list[ number ] then return end
                        if number == current_tab and not is_simulated then return end

                        local area_npx = 30
                        local previous_area = current_area
                        
                        if not tab_areas[ number ] then
                            local category = categories_list[ number ]
                            local list = categories[ category ]

                            local area = ibCreateArea( 30, navbar_sy + 14, 500, 180, area_bg )

                            local npy = 0
                            for i, v in pairs( list ) do
                                local image = ibCreateImage( 0, npy, 0, 0, "img/items/content/" .. v.image .. ".png", area ):ibSetRealSize( )
                                npy = npy + image:ibData( "sy" )

                                local name = menu.get_name_fn and menu.get_name_fn( v ) or v.name
                                ibCreateLabel( 26, 22, 0, 0, name, image, 0xffffffff, _, _, "left", "top", ibFonts.semibold_21 )

                                local add_lines_count = select( 2, name:gsub( "\n", "" ) )
                                local oy = add_lines_count * 29
                                if v.subtext then
                                    ibCreateLabel( 26, 65 + oy, 0, 0, v.subtext, image, 0x90ffffff, _, _, "left", "center", ibFonts.regular_14 )
                                elseif menu.get_subtext_fn then
                                    ibCreateLabel( 26, 65 + oy, 0, 0, menu.get_subtext_fn( v ), image, 0x90ffffff, _, _, "left", "center", ibFonts.regular_14 )
                                elseif v.level then
                                    ibCreateLabel( 26, 65 + oy, 0, 0, "Доступно с " .. v.level .. " уровня", image, 0x90ffffff, _, _, "left", "center", ibFonts.regular_14 )
                                end

                                local buttons = { }
                                -- Если у элемента свой набор кнопок (кастомный)
                                if v.buttons then
                                    buttons = v.buttons
                                elseif type( v.gps ) == "table" then
                                    local gps = v.gps
                                    -- Поддержка навигации в несколько точек
                                    if #gps > 0 then
                                        table.insert( buttons, "find_near" )
                                        table.insert( buttons, "show_on_map" )

                                    -- Только одна точка навигации
                                    else
                                        table.insert( buttons, "show_on_map" )
                                    end
                                end

                                if v.desc then
                                    npy = npy + 16
                                    local font = ibFonts.regular_18
                                    local diff = 26

                                    local lines = split( v.desc, "\n" )

                                    for i, v in pairs( lines ) do
                                        ibCreateLabel( 0, npy, 0, 0, v, area, _, _, _, "left", "top", font )
                                        npy = npy + diff
                                    end

                                    npy = npy + 12
                                else
                                    npy = npy + 20
                                end

                                -- Если есть кнопки
                                if #buttons > 0 then
                                    local btn_height, total_width = 40, 0

                                    -- Область кнопок
                                    local btn_area = ibCreateArea( 0, npy, 0, btn_height, area )

                                    -- Создаём элементы и считаем общий размер кнопок для центровки
                                    for button_number, button_id in pairs( buttons ) do
                                        if BUTTONS_FUNCTIONS[ button_id ] then
                                            local btn = BUTTONS_FUNCTIONS[ button_id ].create( v, btn_area ):ibData( "px", total_width )
                                            total_width = total_width + btn:ibData( "sx" ) + 20
                                        end
                                    end
                                    -- Добавляем учёт отступов для центровки
                                    total_width = total_width - 20

                                    btn_area:ibBatchData( { sx = total_width, px = 250 - total_width / 2 } )
                                    npy = npy + 60
                                end

                                -- Разделитель везде, кроме последнего пункта
                                if i ~= #list then
                                    ibCreateImage( 0, npy, 500, 1, _, area, 0x30000000 )
                                    npy = npy + 21
                                end
                            end


                            area:ibData( "sy", math.max( npy, UI_elements.items_pane:ibData( "viewport_sy" ) ) )
                            current_area = area
                        else
                            current_area = tab_areas[ number ]
                        end

                        local is_previous_area = isElement( previous_area )
                        local move_duration, alpha_duration = 250, 350
                        -- Вправо
                        if number > current_tab then
                            if is_previous_area then previous_area:ibMoveTo( area_npx - 100, _, move_duration ):ibAlphaTo( 0, alpha_duration ) end
                            current_area:ibBatchData( { alpha = 0, px = area_npx + 100 } ):ibMoveTo( area_npx, _, move_duration ):ibAlphaTo( 255, alpha_duration )
                        -- Влево
                        else
                            if is_previous_area then previous_area:ibMoveTo( area_npx + 100, _, move_duration ):ibAlphaTo( 0, alpha_duration ) end
                            current_area:ibBatchData( { alpha = 0, px = area_npx - 100 } ):ibMoveTo( area_npx, _, move_duration ):ibAlphaTo( 255, alpha_duration )
                        end

                        if is_previous_area then previous_area:ibData( "priority", -10 ) end
                        current_area:ibData( "priority", 0 )

                        local total_height = navbar_sy + navbar_padding + current_area:ibData( "sy" )
                        UI_elements.items_pane:ibData( "sy", total_height )
                        UI_elements.items_scroll:ibData( "position", 0 )
                        UI_elements.contentbar_parent:ibData( "sy", total_height )

                        current_tab = number
                    end

                    -- Панель навигации - верхняя часть без учета дроп-меню
                    local npx, npy = npx_default, npy_default
                    local elements = { }
                    local detect_sx_additional, detect_sy_absolute = 15, 30

                    local line_element

                    for i, v in pairs( main_nav ) do
                        local name = CATEGORIES_NAMES[ v ] or v

                        local current_npx = npx

                        local default_alpha = 200
                        local label = ibCreateLabel( npx, npy, 0, 0, name, area_bg, 0xffffffff, _, _, "left", "center", font ):ibData( "disabled", true ):ibData( "alpha", default_alpha )
                        local bg = ibCreateImage( npx - detect_sx_additional / 2, npy - detect_sy_absolute / 2, label:width( ) + detect_sx_additional, detect_sy_absolute, _, area_bg, 0 )
                        :ibBatchData( { priority = -1 } )
                        :ibOnClick( function( key, state, is_simulated )
                            if key ~= "left" or state ~= "up" then return end
                            if not is_simulated then ibClick( ) end
                            SwitchNavigationTab( i, is_simulated )
                            for i, v in pairs( elements ) do
                                if v.label ~= label then
                                    v.label:ibAlphaTo( default_alpha, 150 )
                                end
                            end

                            local move_duration, alpha_duration = 200, 200
                            if isElement( line_element ) then
                                line_element:ibMoveTo( current_npx, _, move_duration ):ibResizeTo( label:width( ), _, move_duration )
                            else
                                if not is_navbar_empty then
                                    line_element = ibCreateImage( current_npx, 42, label:width( ), 3, _, area_bg, 0xfffb9769 ):ibData( "alpha", 0 ):ibAlphaTo( 255, alpha_duration )
                                end
                            end
                            label:ibAlphaTo( 255, 150 )
                        end )
                        :ibOnHover( function( )
                            label:ibAlphaTo( 255, 150 )
                        end )
                        :ibOnLeave( function( )
                            if current_tab ~= i then
                                label:ibAlphaTo( default_alpha, 150 )
                            end
                        end )

                        UI_elements[ "subsubtab_" .. i ] = bg

                        table.insert( elements, { label = label, bg = bg } )
                        npx = npx + math.floor( label:width( ) ) + 30
                    end

                    -- Прячем панель если там всего 1 вкладка
                    if is_navbar_empty then
                        for i, v in pairs( elements ) do
                            for name, element in pairs( v ) do
                                element:ibData( "visible", false )
                            end
                        end 
                    
                    -- Добавляем линию в ином случае
                    else
                        ibCreateImage( 30, navbar_sy - 1, 500, 1, _, area_bg, 0x30ffffff )
                    end

                    -- Если есть элементы выпадающего списка, добавляем
                    if #dropdown_nav > 0 then
                        local default_alpha = 200
                        local btn = ibCreateImage( 500, navbar_sy / 2 - 15, 30, 30, _, area_bg, 0 ):ibData( "alpha", default_alpha )
                        ibCreateImage( 0, 0, 18, 6, "img/icon_dots.png", btn ):center( ):ibData( "disabled", true )

                        UI_elements[ "dropdown" ] = btn
                        addEvent( "onDropdownMenuOpen", true )
                        addEventHandler( "onDropdownMenuOpen", btn, function( item_num )
                            ibClick( )
                            SwitchNavigationTab( item_num )
                        end )

                        btn:ibOnHover( function( )
                            btn:ibAlphaTo( 255, 250 )
                        end )
                        :ibOnLeave( function( )
                            btn:ibAlphaTo( default_alpha, 250 )
                        end )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            if isElement( UI_elements.dropdown_bg ) then destroyElement( UI_elements.dropdown_bg ) return end

                            ibClick( )

                            local nsx, nsy = 200, 45
                            local npx, npy = 15, 5
                            local y_offset = 30
                            UI_elements.dropdown_bg = ibCreateArea( math.floor( 530 - nsx - 6 ), math.floor( btn:ibData( "py" ) + y_offset ), nsx, #dropdown_nav * nsy, area_bg ):ibData( "alpha", 0 )

                            ibCreateImage( nsx - 4 - 10, 0, 10, 5, "img/icon_triangle.png", UI_elements.dropdown_bg )
                            
                            for i, v in pairs( dropdown_nav ) do
                                local name = CATEGORIES_NAMES[ v ] or v

                                local bg = ibCreateImage( 0, npy, nsx, nsy, _, UI_elements.dropdown_bg, 0xff58819f )
                                local bg_hover

                                -- Если это первый элемент, у него нет линии сверху, поэтому сдвиг не нужен
                                if i == 1 then
                                    bg_hover = ibCreateImage( 0, npy, nsx, nsy, _, UI_elements.dropdown_bg, 0xff6c8ea9 ):ibBatchData( { alpha = 0, disabled = true } )
                                else
                                    bg_hover = ibCreateImage( 0, npy - 1, nsx, nsy + 1, _, UI_elements.dropdown_bg, 0xff6c8ea9 ):ibBatchData( { alpha = 0, disabled = true } )
                                end

                                local item_num = #main_nav + i

                                if item_num == current_tab then
                                    ibCreateImage( nsx - 3, npy + nsy / 2 - 13 / 2, 3, 13, _, UI_elements.dropdown_bg, 0xfffb9769 ):ibData( "priority", 5 )
                                end

                                bg:ibData( "priority", -1 )
                                :ibOnClick( function( key, state )
                                    if key ~= "left" or state ~= "up" then return end
                                    ibClick( )
                                    SwitchNavigationTab( item_num )
                                    if isElement( line_element ) then destroyElement( line_element ) end
                                    if isElement( UI_elements.dropdown_bg ) then destroyElement( UI_elements.dropdown_bg ) end
                                end )
                                :ibOnHover( function( )
                                    bg_hover:ibAlphaTo( 255, 150 )
                                end )
                                :ibOnLeave( function( )
                                    bg_hover:ibAlphaTo( 0, 150 )
                                end )

                                local label = ibCreateLabel( npx, npy, 0, nsy, name, UI_elements.dropdown_bg, 0xffffffff, _, _, "left", "center", font ):ibData( "disabled", true )
                                
                                -- Не нужна линия у последнего элемента списка
                                if i ~= #dropdown_nav then
                                    local line = ibCreateImage( 0, npy + nsy - 1, nsx, 1, _, UI_elements.dropdown_bg, 0x30000000 ):ibData( "priority", 2 )
                                    table.insert( elements, { label = label, bg = bg, bg_hover = bg_hover, line = line } )
                                end

                                UI_elements[ "subsubtab_" .. item_num ] = btn

                                npy = npy + nsy
                            end

                            local function HandleClickAnywhere( key, state )
                                if key ~= "left" or state ~= "up" then return end
                                if isElement( UI_elements.dropdown_bg ) then
                                    UI_elements.dropdown_bg:ibTimer( function( self ) self:destroy( ) end, 50, 1 )
                                end
                            end
                            addEventHandler( "onClientClick", root, HandleClickAnywhere, true, "low-1000000" )

                            UI_elements.dropdown_bg:ibOnDestroy( function( )
                                removeEventHandler( "onClientClick", root, HandleClickAnywhere )
                            end )

                            UI_elements.dropdown_bg:ibAlphaTo( 255, 200 )
                        
                        end )

                    end

                    --UI_elements.items_pane:ibData( "sy", navbar_sy )
                    --UI_elements.contentbar_parent:ibData( "sy", navbar_sy )

                    -- Открываем первый пункт по дефолту
                    tabs[ tab_num ].elements = elements
                end
                tabs[ tab_num ].elements[ 1 ].bg:ibTimer( function( self ) self:ibSimulateClick( "left", "up" ) end, 50, 1 )
            end

            local animation_duration = no_animations and 0 or 250

            if tab_num > tab_num_current then
                if elements[ "tab_content_area_" .. old_tab ] then
                    elements[ "tab_content_area_" .. old_tab ]:ibAlphaTo( 0, animation_duration )
                    elements[ "tab_content_area_" .. old_tab ]:ibMoveTo( 0, -100, animation_duration )
                end

                area_bg:ibData( "py", 100 )
                area_bg:ibData( "alpha", 0 )

                area_bg:ibMoveTo( 0, 0, animation_duration )
                area_bg:ibAlphaTo( 255, animation_duration )
            
            else
                if elements[ "tab_content_area_" .. old_tab ] then
                    elements[ "tab_content_area_" .. old_tab ]:ibAlphaTo( 0, animation_duration )
                    elements[ "tab_content_area_" .. old_tab ]:ibMoveTo( 0, 100, animation_duration )
                end

                area_bg:ibData( "py", -100 )
                area_bg:ibData( "alpha", 0 )

                area_bg:ibMoveTo( 0, 0, animation_duration )
                area_bg:ibAlphaTo( 255, animation_duration )
            end

            tab_num_current = tab_num
        end

        for tab_num, tab_info in pairs( tabs ) do
            local bg = ibCreateImage( npx, npy, nsx, nsy, "img/bg_hover.png", dummy, 0xffffffff ):ibData( "alpha", 0 ):ibData( "priority", 2 )
            ibCreateLabel( npx + 30, npy, 0, nsy, tab_info.name, dummy, 0xFFFFFFFF, 1, 1, "left", "center"):ibData( "font", ibFonts.regular_14 ):ibData( "priority", 4 )
            local area = ibCreateArea( npx, npy, nsx, nsy, dummy ):ibData( "priority", 5 )
            
            :ibOnHover( function( )
                bg:ibAlphaTo( 255, 200 )
            end )
            :ibOnLeave( function( )
                bg:ibAlphaTo( 0, 200 )
            end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                SwitchTab( tab_num )
            end )
            
            elements[ "tab_bg_" .. tab_num ] = bg
            elements[ "tab_area_" .. tab_num ] = area

            UI_elements[ "subtab_" .. tab_num ] = area

            ibCreateImage( npx, npy + nsy, nsx, 1, _, dummy, 0x25ffffff ):ibData( "priority", 6 )

            npy = npy + nsy
        end

        SwitchTab( 1, true )
    end

    dummy:ibBatchData( { sx = 240, sy = npy } )

    UI_elements.left_pane:ibData( "sy", math.max( npy, UI_elements.left_pane:ibData( "viewport_sy" ) ) )
    UI_elements.left_scroll:ibAlphaTo( UI_elements.left_pane:ibData( "sy" ) ~= UI_elements.left_pane:ibData( "viewport_sy" ) and 255 or 0, 250 )
    UI_elements.left_scroll:ibData( "position", 0 )

    return dummy
end

function onClientPlayerSyncOffersFinish_handler( )
    if BOUND then return end

    bindKey( "F1", "down", function( ) ShowInfoUI( not UI_elements ) end )
    BOUND = true

    ibAttachAutoclose( function( ) ShowInfoUI( false ) end )

    if localPlayer:GetLevel( ) < 3 then return end

    -- Показывать список обновлений
    local function Show( )
        ShowInfoUI( true, { tab = 3 } )

        local file = fileCreate( "upd.nrp" )
        fileWrite( file, tostring( LAST_UPDATE ) )
        fileClose( file )
    end

    -- Если файла нет, показываем 100%
    if not fileExists( "upd.nrp" ) then
        Show( )

    -- Если файл есть, проверяем дату последнего автоматического показа
    else
        local file = fileOpen( "upd.nrp" )
        local ts = tonumber( fileRead( file, fileGetSize( file ) ) )
        fileClose( file )
        if not ts or ts < LAST_UPDATE then
            Show( )
        end

    end
end
addEvent( "onClientPlayerSyncOffersFinish", true )
addEventHandler( "onClientPlayerSyncOffersFinish", root, onClientPlayerSyncOffersFinish_handler )