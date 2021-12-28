
function CreateDailyTabView()

    local content_area = ibCreateArea( TAB_PX, 137, 740, 413, UI_elements.bg )
    
    UI_elements.scroll_panel, UI_elements.scroll_v	= ibCreateScrollpane( 0, 0, 740, 413, content_area, { scroll_px = 10, bg_color = 0x00FFFFFF } )
    UI_elements.scroll_v:ibBatchData( { absolute = true, sensivity = 75 } )
    
    if #LIST.daily > 0 then
        local count = 0
        local px, py = 0, 0
        for _, v in pairs( LIST.daily ) do
            --Перенос на новую "строку"
            if count > 0 and count % 3 == 0 then
                if #LIST.daily == 5 then
                    px = 127
                else
                    px = 0
                end
                py = py + 216
            end
            if v.name then
                CreateBoxItem( px, py, v, UI_elements.scroll_panel )
            else
                CreateDummyBoxItem( px, py, v, UI_elements.scroll_panel )
            end
            count = count  + 1
            px = px + 253
        end
    else
        ibCreateLabel( 0, 182, 740, 0, "Вам пока недоступны задания, пройдите обучение", UI_elements.scroll_panel, 0xFFB0B8C0, 1, 1, "center", "top", ibFonts.regular_16 )
    end

    UI_elements.scroll_panel:AdaptHeightToContents()
    UI_elements.scroll_v:UpdateScrollbarVisibility( UI_elements.scroll_panel )

    return content_area

end