local category_current = 1
local subtype_current = 1

function CreateInventory( )
    if isElement( UI_elements.inventory_area ) then destroyElement( UI_elements.inventory_area ) end

    ibUseRealFonts( true )

    local filter_btn_w = wInventory.sx / 3
    local filter_c_btn_w = filter_btn_w - 12
    local filter_c_shift = DATA.current_tier - 2

    UI_elements.inventory_area = ibCreateArea( wInventory.px, wInventory.py, wInventory.sx, wInventory.sy )

    -- Заголовок
    UI_elements.img_inventory_header = ibCreateImage( 0, 0, wInventory.sx, 56, _, UI_elements.inventory_area, 0xff516b86 )
    UI_elements.lbl_inventory_header = ibCreateLabel( 20, 0, 0, 56, "Установка деталей", UI_elements.img_inventory_header )
    :ibBatchData( { align_y = "center", font = ibFonts.bold_16 } )

    -- Класс авто
    UI_elements.bg_class = ibCreateImage( 0, 56, wInventory.sx, 70, _, UI_elements.inventory_area, 0xcc516b86 )
    ibCreateLabel( 16, 0, wInventory.sx, 36, "Выбери класс автомобиля", UI_elements.bg_class, ibApplyAlpha( 0xffffffff, 40 ) )
    :ibBatchData( { align_x = "center", align_y = "center", font = ibFonts.regular_14 } )
    ibCreateImage( 66, 10, 22, 16, "img/icon_car.png", UI_elements.bg_class )

    UI_elements.bg_class_rt = ibCreateRenderTarget( 18, 36, wInventory.sx - 36, 34, UI_elements.bg_class )
    UI_elements.area_class_f = ibCreateArea( 0, 0, filter_c_btn_w * #VEHICLE_CLASSES_NAMES, 36, UI_elements.bg_class_rt )

    local function moveHorizontalSelector( need_on_display )
        if filter_c_shift < 0 then
            filter_c_shift = need_on_display and 0 or #VEHICLE_CLASSES_NAMES - 3
        elseif filter_c_shift > #VEHICLE_CLASSES_NAMES - 3 then
            filter_c_shift = need_on_display and #VEHICLE_CLASSES_NAMES - 3 or 0
        end

        UI_elements.area_class_f:ibMoveTo( - 1 * filter_c_shift * filter_c_btn_w )
    end
    moveHorizontalSelector( true )

    ibCreateButton( 0, 36, 18, 34, UI_elements.bg_class,
        "img/btn_arrow.png", "img/btn_arrow.png", "img/btn_arrow.png", 0xBBFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
    :ibOnClick( function ( key, state )
        if key ~= "left" or state ~= "up" then return end

        filter_c_shift = filter_c_shift - 1
        moveHorizontalSelector( )
    end )
    ibCreateButton( wInventory.sx - 18, 36, 18, 34, UI_elements.bg_class,
        "img/btn_arrow.png", "img/btn_arrow.png", "img/btn_arrow.png", 0xBBFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
    :ibData( "rotation", 180 )
    :ibOnClick( function ( key, state )
        if key ~= "left" or state ~= "up" then return end

        filter_c_shift = filter_c_shift + 1
        moveHorizontalSelector( )
    end )

    for class_id, name in ipairs( VEHICLE_CLASSES_NAMES ) do
        ibCreateLabel( ( class_id - 1 ) * filter_c_btn_w, 0, filter_c_btn_w, 34, name .. " - Класс", UI_elements.area_class_f )
        :ibBatchData( { align_x = "center", align_y = "center", font = ibFonts.bold_14 } )

        UI_elements[ "filter_by_class_" .. class_id ] = ibCreateButton( ( class_id - 1 ) * filter_c_btn_w, 0, filter_c_btn_w, 34, UI_elements.area_class_f,
    nil, nil, nil, class_id == DATA.current_tier and 0x66FFFFFF or 0x22FFFFFF, 0x66FFFFFF, 0x88FFFFFF )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            for class_id2 in ipairs( VEHICLE_CLASSES_NAMES ) do
                if class_id == class_id2 then
                    UI_elements[ "filter_by_class_" .. class_id2 ]:ibData( "color", 0x66FFFFFF )
                else
                    UI_elements[ "filter_by_class_" .. class_id2 ]:ibData( "color", 0x22FFFFFF )
                end
            end

            DATA.current_tier = class_id
            RefreshInventory( )
            ibClick( )
        end )
    end

    -- Фильтрация детали
    UI_elements.bg_category = ibCreateImage( 0, 126, wInventory.sx, 55, _, UI_elements.inventory_area, 0xcc516b86 )
    UI_elements.lbl_category_current = ibCreateLabel( 0, 0, wInventory.sx, 55, "", UI_elements.bg_category )
    :ibBatchData( { align_x = "center", align_y = "center", font = ibFonts.bold_15 } )

    local categories = {
        [ 1 ] = "Все детали",
        [ 2 ] = "Двигатель",
        [ 3 ] = "Турбонаддув",
        [ 4 ] = "Трансмиссия",
        [ 5 ] = "Чиповка",
        [ 6 ] = "Тормозные колодки",
        [ 7 ] = "Подвеска",
        [ 8 ] = "Шины",
    }

    category_current = 1
    subtype_current = 1

    UI_elements.btn_category_left   = ibCreateButton( 20, 18, 24, 20, UI_elements.bg_category,
            "img/icon_arrow_bigger.png", "img/icon_arrow_bigger.png", "img/icon_arrow_bigger.png",
            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 ):ibData( "rotation", 180 )
    UI_elements.btn_category_right  = ibCreateButton( wInventory.sx - 20 - 24, 18, 24, 20, UI_elements.bg_category,
            "img/icon_arrow_bigger.png", "img/icon_arrow_bigger.png", "img/icon_arrow_bigger.png",
            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )

    local function ParseSectionChange( key, state )
        if key ~= "left" or state ~= "up" then return end

        if source == UI_elements.btn_category_left then
            category_current = category_current - 1
            ibClick()
        elseif source == UI_elements.btn_category_right then
            category_current = category_current + 1
            ibClick()
        end

        if category_current < 1 then
            category_current = #categories
        elseif category_current > #categories then
            category_current = 1
        end

        UI_elements.lbl_category_current:ibData( "text", categories[ category_current ] )
        RefreshInventory( ) -- update inventory
    end
    addEventHandler( "ibOnElementMouseClick", UI_elements.btn_category_left, ParseSectionChange, false )
    addEventHandler( "ibOnElementMouseClick", UI_elements.btn_category_right, ParseSectionChange, false )

    UI_elements.bg_filter = ibCreateImage( 0, 55, wInventory.sx, 34, _, UI_elements.bg_category, 0xcc516b86 )

    for subtype, typeName in ipairs( INTERNAL_PARTS_NAMES_TYPES ) do
        ibCreateLabel( ( subtype - 1 ) * filter_btn_w, 0, filter_btn_w, 34, "Type " .. typeName, UI_elements.bg_filter )
        :ibBatchData( { align_x = "center", align_y = "center", font = ibFonts.bold_14 } )

        UI_elements[ "filter_by_subtype_" .. subtype ] = ibCreateButton( ( subtype - 1 ) * filter_btn_w, 0, filter_btn_w, 34, UI_elements.bg_filter,
                nil, nil, nil, subtype == subtype_current and 0x66FFFFFF or 0x22FFFFFF, 0x66FFFFFF, 0x88FFFFFF )
        :ibOnClick( function ( key, state )
            if key ~= "left" or state ~= "up" then return end

            for subtype2 in ipairs( INTERNAL_PARTS_NAMES_TYPES ) do
                if subtype == subtype2 then UI_elements[ "filter_by_subtype_" .. subtype2 ]:ibData( "color", 0x66FFFFFF )
                else UI_elements[ "filter_by_subtype_" .. subtype2 ]:ibData( "color", 0x22FFFFFF )
                end
            end

            subtype_current = subtype
            ParseSectionChange( "left", "up" )
            ibClick()
        end )
    end

    -- Скроллпейн
    local srollpane_py = 215
    UI_elements.inventory_rt, UI_elements.inventory_sc  = ibCreateScrollpane( 0, srollpane_py,
            wInventory.sx, wInventory.sy - srollpane_py, UI_elements.inventory_area,
        {
            scroll_px = -20,
            bg_sx = 0,
            handle_sy = 40,
            handle_sx = 10,
            handle_texture = "img/scroll.png",
            handle_upper_limit = -40 - 20,
            handle_lower_limit = 20,
        }
    )

    addEvent( "RefreshInventoryList", true )
    addEventHandler( "RefreshInventoryList", UI_elements.inventory_area, function( )
        ParseSectionChange( "left", "up" )
    end, false )

    -- Симуляция пустого нажатия для начала сортировки
    setTimer( function ( )
        if not isElement( UI_elements.inventory_area ) then
            return
        end

        ParseSectionChange( "left", "up" )
    end, 500, 1 )

    ibUseRealFonts( false )
end

function ShowInventory( instant )
    if instant then
        UI_elements.inventory_area:ibBatchData(
            {
                px = wInventory.px, py = wInventory.py
            }
        )
        UI_elements.inventory_area:ibBatchData( { disabled = false, alpha = 255 } )
    else
        UI_elements.inventory_area:ibMoveTo( wInventory.px, wInventory.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.inventory_area:ibBatchData( { disabled = false } )
        UI_elements.inventory_area:ibAlphaTo( 255, 150 * ANIM_MUL, "OutQuad" )
    end
end

function HideInventory( instant )
    if not isElement( UI_elements.inventory_area ) then return end
    if instant then
        UI_elements.inventory_area:ibBatchData(
            {
                px = x, py = wInventory.py
            }
        )
        UI_elements.inventory_area:ibBatchData( { disabled = true, alpha = 0 } )
    else
        UI_elements.inventory_area:ibMoveTo( x, wInventory.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.inventory_area:ibBatchData( { disabled = true } )
        UI_elements.inventory_area:ibAlphaTo( 0, 50 * ANIM_MUL, "OutQuad" )
    end
end

function ClearInventory( )
    local i = 1

    while isElement( UI_elements[ "inventory_element_" .. i ] ) do
        local element = UI_elements[ "inventory_element_" .. i ]
        destroyElement( element )
        local element = UI_elements[ "inventory_line_" .. i ]
        destroyElement( element )
        i = i + 1
    end

    if isElement( UI_elements.inventory_rt_bg ) then
        destroyElement( UI_elements.inventory_rt_bg )
    end
end

function isFilteredPart( part )
    local filerByType = category_current - 1

    if ( filerByType == 0 or filerByType == part.type ) and part.subtype == subtype_current then
        return true
    end
end

function updateBgOfInventory( k )
    local start_position = 215
    local npy = 124 * ( k - 1 )

    if start_position + npy < wInventory.sy then
        UI_elements.inventory_sc:ibData( "alpha", 0 )
        UI_elements.inventory_rt_bg = ibCreateImage( 0, start_position + npy, wInventory.sx, wInventory.sy - start_position - npy, _, UI_elements.inventory_area, 0xf0475d75 )
        :ibData( "priority", -1 ):ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            removePartFromPreview( )
        end )
    else
        UI_elements.inventory_sc:ibData( "alpha", 255 )
    end

    UI_elements.inventory_rt:AdaptHeightToContents( )
    UI_elements.inventory_sc:ibData( "sensivity", 124 / UI_elements.inventory_rt:ibData( "sy" ) )
    UI_elements.inventory_sc:ibData( "position", 0 )
end

function addPartInInventory( part, k )
    if k or isFilteredPart( part ) then
        local needUpdateScroll = false

        if not k then
            needUpdateScroll = true
            k = 1

            while isElement( UI_elements[ "inventory_element_" .. k ] ) do k = k + 1 end
        end

        UI_elements[ "inventory_element_" .. k ], UI_elements[ "inventory_line_" .. k ] = CreatePartListElement( 0, 124 * ( k - 1 ), part, UI_elements.inventory_rt )

        if needUpdateScroll then
            updateBgOfInventory( k )
        end
    end
end

function RefreshInventory( )
    ClearInventory( )

    local k = 0
    for category = #PARTS_TIER_NAMES, 1, -1 do
        for _, part in pairs( DATA.all_parts[ DATA.current_tier ] or { } ) do
            if part.category == category and isFilteredPart( part ) then
                k = k + 1

                UI_elements.inventory_rt:ibTimer( function( _, part, idx )
                    addPartInInventory( part, idx )

                    if idx == k then
                        updateBgOfInventory( idx )
                        UI_elements.inventory_rt:ibData( "alpha", 255 )
                        if loading then loading:destroy( ) loading = nil end
                    end
                end, k * 10, 1, part, k )
            end
        end
    end

    if loading then loading:destroy( ) loading = nil end
    if k > 1 then
        UI_elements.inventory_rt:ibData( "alpha", 100 )
        loading = ibLoading( { parent = UI_elements.inventory_area } )
    else
        updateBgOfInventory( 1 )
    end
end

function CreatePartListElement( px, py, part, parent )
    local area = ibCreateImage( px, py, wInventory.sx, 124, nil, parent, 0xf0475d75 )
    local icon = CreatePartElement( 20, 15, part, area, nil, part.amount )
    icon:setParent( area )

    -- Иконки статистики
    local hintTexture = "img/icons_hint.png"
    if not UI_elements[ hintTexture ] then UI_elements[ hintTexture ] = dxCreateTexture( hintTexture, "dxt5" ) end
    ibCreateImage( 0, 0, wInventory.sx, 124, UI_elements[ hintTexture ], area )

    -- Нижняя линия для детали
    local horizontal_line = ibCreateImage( px + 0, py + 123, wInventory.sx, 1, _, parent, 0x15ffffff ):ibData( "priority", 5 )

    -- Вертикальная линия для детали
    ibCreateImage( wInventory.sx - 88, 17, 1, 86, _, area, 0x15ffffff )

    -- Иконка денег для детали
    local money_area = ibCreateArea( wInventory.sx - 76, 17, 66, 86, area )
    ibCreateImage( 0, 0, 24, 21, "img/icon_soft.png", money_area ):center( 0, -12 )
    ibCreateLabel( 0, 0, 0, 0, format_price( getSellPriceOfPart( part ) ), money_area, _, _, _, "center", _, ibFonts.oxaniumbold_12 ):center( 0, 5 )

    local detect_area = ibCreateArea( 0, 0, wInventory.sx, 125, area )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        removePartFromPreview( )
    end )
    --:ibAttachTooltip( "ПКМ - примерить деталь" )

    addEventHandler( "ibOnElementMouseEnter", detect_area, function( )
        area:ibData( "color", 0xf06481a0 )
        area:ibData( "priority", 1 )
    end, false )

    addEventHandler( "ibOnElementMouseLeave", detect_area, function( )
        area:ibData( "color", 0xf0475d75 )
        area:ibData( "priority", 0 )
    end, false )

    addEventHandler( "ibOnElementMouseClick", detect_area, function( key, state )
        if key == "left" then
            DestroyFloatingPart( )

            if state == "down" then
                CreateFloatingPart( part, DRAG_TYPE_FROM_INVENTORY )
            end
        elseif state == "up" then
            local tier = DATA.vehicle:GetTier( )
            if DATA.current_tier ~= tier then
                localPlayer:ErrorWindow( "Эта деталь не подходит для данного транспорта" )
                return
            end

            local parts = DATA.installed_parts or DATA.parts
            if parts[ part.type ] then
                localPlayer:ErrorWindow( "Данный слот уже занят" )
                return
            end

            addPartForPreview( part.id, part.type ) -- fast preview via right click
        end
    end, false )

    return area, horizontal_line
end

function onPartsInventoryUpdate_handler( data )
    if not isElement( UI_elements.inventory_area ) then return end

    local convertedData = { }
    for tier, parts in pairs( data or DATA.all_parts ) do
        convertedData[ tier ] = { }

        for _, id in pairs( parts ) do
            local part = getTuningPartByID( id, tier )

            if part then
                if convertedData[ tier ][ part.id ] then
                    convertedData[ tier ][ part.id ].amount = ( convertedData[ tier ][ part.id ].amount or 1 ) + 1
                else
                    convertedData[ tier ][ part.id ] = part
                end
            end
        end
    end
    DATA.all_parts = convertedData

    triggerEvent( "RefreshInventoryList", UI_elements.inventory_area )
end
addEvent( "onPartsInventoryUpdate", true )
addEventHandler( "onPartsInventoryUpdate", root, onPartsInventoryUpdate_handler )

function onPartsInventoryUpdate_handler( )
    if not isElement( UI_elements.inventory_area ) then
        return
    end

    UI_elements.inventory_area:ibTimer( RefreshInventory, 100, 1 )
end
addEvent( "onPartsInventoryRefresh", true )
addEventHandler( "onPartsInventoryRefresh", root, onPartsInventoryUpdate_handler )

addEvent( "onPlayerAddTuningPartInInventory", true )
addEventHandler( "onPlayerAddTuningPartInInventory", resourceRoot, function ( id, tier )
    if not isElement( UI_elements.inventory_area ) then
        return
    end

    local part = getTuningPartByID( id, tier )
    if not part then
        return
    end

    if not DATA.all_parts[ tier ] then
        DATA.all_parts[ tier ] = { }
    end

    if DATA.all_parts[ tier ][ part.id ] then
        DATA.all_parts[ tier ][ part.id ].amount = ( DATA.all_parts[ tier ][ part.id ].amount or 1 ) + 1
    else
        DATA.all_parts[ tier ][ part.id ] = part
    end
end )