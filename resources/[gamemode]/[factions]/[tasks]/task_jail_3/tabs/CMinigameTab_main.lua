

function createMainTabView()

    generateMinigameData()

    local contentArea = ibCreateImage( 0, 117, 800, 463, "assets/img/tab_main.png", UI_elements.bg_area )

    local taskInfoText = string.format( "Выстроить электронную цепь, \nвращая компоненты вокруг своей\nоси. Чтобы ток из порта %d достиг\nпорт %d", PORTS.START_PORT, PORTS.END_PORT )
    UI_elements.taskInfo = ibCreateLabel( 532, 61, 234, 0, taskInfoText, contentArea, 0xFFFFDE96, 1, 1, "center", "top", ibFonts.regular_14 )

    local px = 602
    if not ATTEMPTS_NUMBER then
        ATTEMPTS_NUMBER = 3
    end
    for i = 1, ATTEMPTS_NUMBER do
        UI_elements[ "attempt_" .. i ] = ibCreateImage( px, 211, 24, 23, "assets/img/star_icon.png", contentArea )
        px = px + 34 
    end

    ibCreateButton( 623, 264, 50, 50, contentArea, "assets/img/btn_reset.png", "assets/img/btn_reset_hovered.png", "assets/img/btn_reset_hovered.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        if ATTEMPTS_NUMBER > 0 and not IS_GAME_ACTIVE then
            resetMinigame( contentArea )
        end
        ibClick( )
    end, false )

    UI_elements.play_button = ibCreateButton( 560, 380, 166, 56, contentArea, "assets/img/btn_play.png", "assets/img/btn_play_hovered.png", "assets/img/btn_play_hovered.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        if ATTEMPTS_NUMBER > 0 then
            playMinigame()
            toggleButtons( true )
            IS_GAME_ACTIVE = true
        end
        ibClick( )
    end, false )

    UI_elements.game_area = ibCreateArea( 47, 21, 438, 411, contentArea )
    arrangeItems( UI_elements.game_area )

    return contentArea

end