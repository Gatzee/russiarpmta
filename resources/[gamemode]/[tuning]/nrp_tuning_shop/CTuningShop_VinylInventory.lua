
VINYLS_INVENTORY = {}
-- Создание таб-панели
function CreateVinylInventory( )
    if isElement( UI_elements.inventory_area ) then destroyElement( UI_elements.inventory_area ) end
    UI_elements.inventory_area = ibCreateArea( wInventory.px, wInventory.py, wInventory.sx, wInventory.sy )

    -- Заголовок
    UI_elements.img_inventory_header = ibCreateImage( 0, 0, wInventory.sx, 56, _, UI_elements.inventory_area, 0xCC516B86 )
    UI_elements.lbl_inventory_header = ibCreateLabel( 20, 0, 0, 56, "Установка винилов", UI_elements.img_inventory_header ):ibBatchData( { align_y = "center", font = ibFonts.semibold_14 } )

    -- Выбор вкладки
    --UI_elements.bg_style         = ibCreateImage( 0, 56, wInventory.sx / 2, 44, _, UI_elements.inventory_area, 0 )
    --UI_elements.lbl_style        = ibCreateLabel( 0, 0, wInventory.sx / 2, 44, "Магазин", UI_elements.bg_style ):ibBatchData( { align_x = "center", align_y = "center", font = ibFonts.semibold_12 } )
    --UI_elements.area_style       = ibCreateArea( 0, 0, wInventory.sx / 2, 44, UI_elements.bg_style )

    UI_elements.bg_inventory        = ibCreateImage( 0, 56, wInventory.sx, 44, _, UI_elements.inventory_area, 0 )
    UI_elements.lbl_inventory       = ibCreateLabel( 0, 0, wInventory.sx, 44, "Инвентарь", UI_elements.bg_inventory ):ibBatchData( { align_x = "center", align_y = "center", font = ibFonts.semibold_12 } )
    UI_elements.area_inventory      = ibCreateArea( 0, 0, wInventory.sx, 44, UI_elements.bg_inventory )

    --local tab_current = UI_elements.bg_style

    function ParseTabChange( key, state )
        if key ~= "left" or state ~= "up" then return end

        --if source == UI_elements.area_style then
        --    tab_current = UI_elements.bg_style
        --    RefreshVinylTabContent( DATA.available_parts )
        --    ibClick()
        --elseif source == UI_elements.area_inventory then
            tab_current = UI_elements.bg_inventory
            RefreshVinylTabContent( DATA.available_vinyls )
        --    ibClick()
        --else
        --    RefreshVinylTabContent( DATA.available_vinyls )
        --end

        UI_elements.is_style = UI_elements.bg_style and tab_current == UI_elements.bg_style or false

        --UI_elements.bg_style:ibData( "color", 0xF0637A92 )
        UI_elements.bg_inventory:ibData( "color", 0xF0637A92 )

        --UI_elements.lbl_style:ibData( "color", 0x90FFFFFF )
        UI_elements.lbl_inventory:ibData( "color", 0x90FFFFFF )

        tab_current:ibData( "color", 0xF08698AB )
        getElementsByType( "ibLabel", tab_current )[ 1 ]:ibData( "color", 0xFFFFFFFF )
    end
    --addEventHandler( "ibOnElementMouseClick", UI_elements.area_style, ParseTabChange, false )
    addEventHandler( "ibOnElementMouseClick", UI_elements.area_inventory, ParseTabChange, false )

    -- Скроллпейн
    UI_elements.inventory_rt, UI_elements.inventory_sc  = ibCreateScrollpane( 0, 100, wInventory.sx, wInventory.sy - 100, UI_elements.inventory_area,
        {
            scroll_px = -25,
            bg_sx = 0,
            handle_sy = 40,
            handle_sx = 16,
            handle_texture = "img/scroll.png",
            handle_upper_limit = -40 - 20,
            handle_lower_limit = 20,
        }
    )

    addEvent( "onServerElementRefreshVinylTabContent", true )
    addEventHandler( "onServerElementRefreshVinylTabContent", UI_elements.inventory_area, function()
        ParseTabChange( "left", "up" )
    end, false )

    ParseTabChange( "left", "up" )
end

-- Отображение таба
function ShowVinylInventory( instant )
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

-- Скрытие таба
function HideVinylInventory( instant )
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

-------------------------------
-- Обновление содержимого таба
-- data = data.available_vinyls
-------------------------------
function RefreshVinylTabContent( data )
    ClearVinylTabInventory( )

    if next( data ) then
        local i = 0
        local npx, npy = 0, 0
    
        for _, vinyl in pairs( data ) do
            if vinyl and VINYLS_INVENTORY[ vinyl[ P_NAME ] ] then
               
                local count_vinyls = tonumber( UI_elements[ "count_vinyls_" .. vinyl[ P_NAME ] ]:ibData( "text" ) ) or 1
                UI_elements[ "count_vinyls_" .. vinyl[ P_NAME ] ]:ibData( "text", count_vinyls + 1 )
                
            elseif vinyl then
                i = i + 1
                UI_elements[ "inventory_element_" .. i ], UI_elements[ "inventory_line_" .. i ] = CreateVinylListItem( npx, npy, vinyl, UI_elements.inventory_rt )
                
                ibCreateLabel( 170, 134, 0, 0, "Количество: ", UI_elements[ "inventory_element_" .. i ], 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_12 )
                UI_elements[ "count_vinyls_" .. vinyl[ P_NAME ] ] = ibCreateLabel( 275, 134, 0, 0, "1", UI_elements[ "inventory_element_" .. i ], 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_12 )

                VINYLS_INVENTORY[ vinyl[ P_NAME ] ] = true

                npy = npy + 169
            end
        end

        local start_position = 100
        if start_position + npy < wInventory.sy then
            UI_elements.inventory_sc:ibData( "alpha", 0 )
            UI_elements.inventory_rt_bg = ibCreateImage( 0, start_position + npy, wInventory.sx, wInventory.sy - start_position - npy, _, UI_elements.inventory_area, 0xF0475D75 )
            :ibData( "priority", -1 )
        else
            UI_elements.inventory_sc:ibData( "alpha", 255 )
        end

        UI_elements.inventory_rt:AdaptHeightToContents( )
        UI_elements.inventory_sc:ibData( "sensivity", 107 / UI_elements.inventory_rt:ibData( "sy" ) )
        UI_elements.inventory_sc:ibData( "position", 0 )
    else
        UI_elements.inventory_rt_bg = ibCreateImage( 0, 0, wInventory.sx, wInventory.sy, _, UI_elements.inventory_area, 0xF0475D75 )
        :ibData( "priority", -1 )
        UI_elements.not_vinyls_lbl = ibCreateLabel( 0, 0, wInventory.sx, wInventory.sy,  "У вас нет винилов в наличии.\nПриобретите винилы в кейсах.", UI_elements.inventory_rt_bg,
            0xFFFFFFFF, 1, 1, "center", "center", ibFonts.semibold_14)
    end
end

-- Обнуление содержимого таба
function ClearVinylTabInventory( )
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
    VINYLS_INVENTORY = {}
end

-- Создание итема винила в списке 
function CreateVinylListItem( px, py, vinyl, parent )
    
    -- Бекграунд итема
    local area = ibCreateImage( px, py, wInventory.sx, 170, _, parent, 0xF0475D75 )

    -- Иконка винила
    local icon = CreateVinylItem( 20, 20, 130, 130, vinyl )
    icon:setParent( area )

    if vinyl[ P_PRICE_TYPE ] == "hard" and icon:ibData( "texture" ) == "img/bg_part.png" then
        icon:ibData( "texture", "img/bg_part_hard.png" )
    end

    -- Лейблы цены
    local price = GetVinylSellPrice( vinyl )
    local text_price = format_price( tonumber( price ) or 0 )
    ibCreateLabel( 170, 26, 0, 0, "Цена продажи:", area, 0xFFB0B7BF, 1, 1, "left", "top", ibFonts.bold_13 )
    ibCreateLabel( 170, 54, 0, 0, text_price, area, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_16 )
    ibCreateImage( 174 + dxGetTextWidth( text_price, 1, ibFonts.bold_16 ), 57, 26, 22, "img/icon_soft.png", area )

    -- Нижняя линия для детали
    local horizontal_line = ibCreateImage( px + 0, py + 169, wInventory.sx, 1, _, parent, 0x15FFFFFF ):ibData( "priority", 5 )
    -- Взаимоедействие с винилом из инвентаря
    local detect_area = ibCreateArea( 0, 0, wInventory.sx, 170, area )
    addEventHandler( "ibOnElementMouseEnter", detect_area, function( )
        area:ibData( "color", 0xF06481A0 )
        area:ibData( "priority", 1 )
    end, false )

    addEventHandler( "ibOnElementMouseLeave", detect_area, function( )
        area:ibData( "color", 0xF0475D75 )
        area:ibData( "priority", 0 )
    end, false )

    addEventHandler( "ibOnElementMouseClick", detect_area, function( key, state )
        if key ~= "left" then return end

        local is_style = UI_elements.is_style
        DestroyFloatingVinyl( )

        if state == "down" then
            CreateFloatingVinyl( vinyl, is_style and DRAG_TYPE_FROM_STYLE or DRAG_TYPE_FROM_INVENTORY )
        end
    end, false )
    
    -- Кнопка продать
    ibCreateButton( 170, 92, 100, 34, detect_area, "img/btn_sell.png", "img/btn_sell_hover.png", "img/btn_sell_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xCCFFFFFF  )
    :ibOnClick( function( button, state ) 
        if button ~= "left" or state ~= "down" then return end
        ibClick()
        triggerServerEvent( "onVinylSellAttempt", resourceRoot, vinyl )
    end )

    return area, horizontal_line

end


function onVinylsInventoryUpdate_handler( vinyls )
    if not isElement( UI_elements.inventory_area ) then return end
    DATA.available_vinyls = vinyls
    local is_style = UI_elements.is_style
    if not is_style then
        triggerEvent( "onServerElementRefreshVinylTabContent", UI_elements.inventory_area )
    end
end
addEvent( "onVinylsInventoryUpdate", true )
addEventHandler( "onVinylsInventoryUpdate", root, onVinylsInventoryUpdate_handler )

function GetVinylSellPrice( vinyl )
    local price = vinyl[ P_PRICE ]
    if vinyl[ P_PRICE_TYPE ] == "hard" then
        price = math.floor( price * 1000 * 0.2 )
    else
        price = math.floor( price * 0.2 )
    end
    return price
end