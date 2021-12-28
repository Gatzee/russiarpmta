
function CreateCompletedTabView()

    local content_area = ibCreateArea( TAB_PX, 137, 740, 413, UI_elements.bg )

    if #LIST["completed"] > 0 then

        --Скролл панель, внутри контейнера
        UI_elements.scroll_panel, UI_elements.scroll_v	= ibCreateScrollpane( 0, 0, 740, 413, content_area, { scroll_px = 10, bg_color = 0x00FFFFFF } )
        UI_elements.scroll_v:ibBatchData( { absolute = true, sensivity = 75 } ):ibSetStyle( "slim_nobg" )

        for k, v in pairs( LIST["completed"] ) do
            CreateItemList( ( k - 1 ) * 64, v, UI_elements.scroll_panel, TAB_COMPLETED )
        end

        UI_elements.scroll_panel:AdaptHeightToContents()
        UI_elements.scroll_v:UpdateScrollbarVisibility( UI_elements.scroll_panel )

    else
        ibCreateLabel( 0, 182, 740, 0, "Вы не завершили ни одного задания, перейдите в доступные для выполнения заданий", content_area, 0xFFB0B8C0, 1, 1, "center", "top", ibFonts.regular_16 )
    end

    return content_area

end