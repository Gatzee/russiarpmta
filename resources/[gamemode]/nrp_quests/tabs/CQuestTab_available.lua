
function CreateAvailableTabView()

    local content_area = ibCreateArea( TAB_PX, 137, 740, 413, UI_elements.bg )

    if #LIST["available"] > 0 and localPlayer:IsTutorialCompleted() then
 
        UI_elements.scroll_panel, UI_elements.scroll_v	= ibCreateScrollpane( 0, 0, 740, 413, content_area, { scroll_px = 10, bg_color = 0x00FFFFFF } )
        UI_elements.scroll_v:ibBatchData( { absolute = true, sensivity = 75 } )

        for k, v in pairs( LIST["available"] ) do
            CreateItemList( ( k - 1 ) * 64, v, UI_elements.scroll_panel )
        end

        UI_elements.scroll_panel:AdaptHeightToContents()
        UI_elements.scroll_v:UpdateScrollbarVisibility( UI_elements.scroll_panel )

    elseif not localPlayer:IsTutorialCompleted() then
        ibCreateLabel( 0, 182, 740, 0, "Вам пока недоступны задания, пройдите обучение", content_area, 0xFFB0B8C0, 1, 1, "center", "top", ibFonts.regular_16 )
    else

        ibCreateLabel( 0, 182, 740, 0, "В данный момент нет доступных заданий, выполняйте ежедневные задания", content_area, 0xFFB0B8C0, 1, 1, "center", "top", ibFonts.regular_16 )
        CreateTasksButton( 316, 220, "Ежедневные", content_area, function()
            SwitchTab( TAB_DAILY )
        end )

    end

    return content_area

end

