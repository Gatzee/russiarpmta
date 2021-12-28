local pNumbersList = {}
local ui_numbers = {}

local bEmpty = true
local pEditTimer

function CreateNumbersList( )
    ibUseRealFonts(true)

    if isElement( UI_elements.numbers_area ) then destroyElement( UI_elements.numbers_area ) end
    UI_elements.numbers_area = ibCreateArea( wSide.px, wSide.py, 340, wSide.sy )

    UI_elements.bg         = ibCreateImage( 0, 0, wSide.sx, wSide.sy, _, UI_elements.numbers_area, 0xf1475d75 )

    -- Заголовок
    UI_elements.img_numbers_header = ibCreateImage( 0, 0, wInventory.sx, 116, _, UI_elements.numbers_area, 0x2595caff )
    UI_elements.lbl_numbers_header = ibCreateLabel( 20, 0, 0, 50, "Установка номеров", UI_elements.img_numbers_header ):ibBatchData( { align_y = "center", font = ibFonts.bold_16 } )

    -- Поиск
    UI_elements.search_bg = ibCreateImage( wSide.sx/2-150, 56, 300, 40, "img/search.png", UI_elements.img_numbers_header )

    UI_elements.icon_searching = ibCreateImage( 260, 12, 18, 18, "img/icon_searching.png", UI_elements.search_bg )
    :ibData("alpha", 0)
    :ibOnRender( function()
        UI_elements.icon_searching:ibData( "rotation", -getTickCount( ) / 2 )
    end)

    UI_elements.edit_search = ibCreateEdit( 44, 0, 250, 40, "", UI_elements.search_bg, 0xffffffff, 0x00ffffff, 0xffffffff )
    :ibData( "font", ibFonts.regular_14 )

    UI_elements.tooltip = ibCreateImage( -260, 20, 250, 100, nil, UI_elements.bg, 0x8095caff )
    :ibData("alpha", 0)
    ibCreateLabel( 10, 0, 230, 100, "- Использовать только кириллицу\n- Не более 3 букв\n- Не более 3 цифр", UI_elements.tooltip, 
        0xffffffff, _, _, "left", "center", ibFonts.bold_12 )

    -- Список
    UI_elements.scrollpane, UI_elements.scrollbar = ibCreateScrollpane( 0, 116, 340, wSide.sy-116, UI_elements.bg, { scroll_px = -20 } )
    UI_elements.scrollbar:ibSetStyle( "slim_nobg" ):ibBatchData( { sensivity = 100, absolute = true, color = 0x99ffffff } )

    ibUseRealFonts(false)

    triggerServerEvent( "OnPlayerRequestNumbersList", localPlayer )

    addEventHandler("ibOnElementDataChange", UI_elements.edit_search, function( key, value )
        if key == "text" then
            if value == "" and not bEmpty then
                bEmpty = true
                triggerServerEvent( "OnPlayerRequestNumbersList", localPlayer )
            else
                bEmpty = false
            end

            if isTimer(bEditTimer) then killTimer(bEditTimer) end

            bEditTimer = setTimer(function( str )
                if value == "" then
                    triggerServerEvent( "OnPlayerRequestNumbersList", localPlayer )
                    UI_elements.icon_searching:ibData("alpha", 255)
                else
                    if not string.find(value, "000") then
                        triggerServerEvent( "OnPlayerRequestNumbersList", localPlayer, value )
                        UI_elements.icon_searching:ibData("alpha", 255)
                    end
                end
            end, 2000, 1, value)
        elseif key == "focused" then
            if value then
                UI_elements.tooltip:ibData("alpha", 255)
            end
        end
    end)
end

function ShowNumbersList( instant )
    if instant then
        UI_elements.numbers_area:ibBatchData(
            {
                px = wSide.px, py = wSide.py
            }
        )
        UI_elements.numbers_area:ibBatchData( { disabled = false, alpha = 255 } )
    else
        UI_elements.numbers_area:ibMoveTo( wSide.px, wSide.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.numbers_area:ibBatchData( { disabled = false } )
        UI_elements.numbers_area:ibAlphaTo( 255, 150 * ANIM_MUL, "OutQuad" )
    end
end

function HideNumbersList( instant )
    if not isElement( UI_elements.numbers_area ) then return end
    if instant then
        UI_elements.numbers_area:ibBatchData(
            {
                px = x, py = wSide.py
            }
        )
        UI_elements.numbers_area:ibBatchData( { disabled = true, alpha = 0 } )
    else
        UI_elements.numbers_area:ibMoveTo( x, wSide.py, 150 * ANIM_MUL, "OutQuad" )
        UI_elements.numbers_area:ibBatchData( { disabled = true } )
        UI_elements.numbers_area:ibAlphaTo( 0, 50 * ANIM_MUL, "OutQuad" )
    end
end

function OnClientNumbersListReceive( pList )
    local bNotFound = false

    local iList = 0

    for k,v in pairs(pList) do
        iList = iList + 1
    end

    if iList == 0 then
        bNotFound = true
    else
        pNumbersList = pList
    end

    RefreshNumbersList( bNotFound )
end
addEvent("OnClientNumbersListReceive", true)
addEventHandler("OnClientNumbersListReceive", root, OnClientNumbersListReceive)

function RefreshNumbersList( bNotFound )
    if not isElement(UI_elements.numbers_area) then return end

    UI_elements.icon_searching:ibData("alpha", 0)
    UI_elements.tooltip:ibData("alpha", 0)

    for k,v in pairs( ui_numbers ) do
        if isElement(v) then
            destroyElement( v )
        end
    end

    ibUseRealFonts(true)

    local py = 0

    if bNotFound then
        py = py + 20

        local not_found = ibCreateImage( 340/2-259/2, py, 259, 49, "img/not_found.png", UI_elements.scrollpane )
        table.insert(ui_numbers, not_found)

        py = py + 60
    end

    for category, list in pairs(pNumbersList) do
        py = py + 30

        local pCategoryData = NUMBER_TYPE_CONFIG[ category ]
        local line = ibCreateImage( 0, py, 340, 8, nil, UI_elements.scrollpane, pCategoryData.visible_color or 0xffffffff ):ibData("alpha", 0.1*255)
        local label = ibCreateLabel( 0, py, 340, 8, pCategoryData.visible_name.." номера", UI_elements.scrollpane, pCategoryData.visible_color or 0xffffffff, _, _, "center", "center", ibFonts.bold_14 ):ibData("alpha", 0.75*255)
        table.insert(ui_numbers, line)
        table.insert(ui_numbers, label)

        for k,v in pairs(list) do
            local area = ibCreateArea( 0, py, 340, 86, UI_elements.scrollpane )

            --ibCreateImage( 20, 20, 116, 14, "img/icon_preview.png", area )
            local number_bg = ibCreateImage( 20, 40, 136, 40, category == NUMBER_TYPE_UNIQUE and "img/golden_preview_bg.png" or "img/preview_bg.png", area )

            local pNumber = split( v, ":" )
            local cost = ApplyDiscount( pCategoryData.cost )

            ibCreateLabel( 0, 0, 95, 40, utf8.sub(pNumber[2], 1, 6), number_bg, 0xff3a4c5f, _, _, "center", "center", ibFonts.extrabold_16 )
            ibCreateLabel( 95, 0, 40, 30, utf8.sub(pNumber[2], 7), number_bg, 0xff3a4c5f, _, _, "center", "center", ibFonts.extrabold_14 )

            ibCreateLabel( 166, 40, 0, 0, "Стоимость:", area, 0xc0ffffff, _, _, _, _, ibFonts.regular_12 )
            ibCreateLabel( 166, 54, 0, 0, format_price( cost ), area, 0xffffffff, _, _, _, _, ibFonts.bold_16 )

            ibCreateButton( 276, 42, 40, 34, area,
                            "img/btn_buy_number.png", "img/btn_buy_number_hover.png", "img/btn_buy_number_hover.png",
                            0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end

                ParseMenuNavigation( { task = TUNING_TASK_NUMBERS_PURCHASE, value = { v, cost } } )

                ibClick()
            end)

            if next(list, k) then
                ibCreateImage( 0, 99, 340, 1, nil, area, 0x25ffffff )
                py = py + 86
            else
                py = py + 76
            end

            table.insert( ui_numbers, area )
        end
    end

    UI_elements.scrollpane:AdaptHeightToContents( )
    UI_elements.scrollbar:UpdateScrollbarVisibility( UI_elements.scrollpane )
    UI_elements.scrollbar:ibData("position", 0)

    ibUseRealFonts(false)
end