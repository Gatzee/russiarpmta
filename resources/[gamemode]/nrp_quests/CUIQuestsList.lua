Extend( "ib" )
ibUseRealFonts( true )

local _SCREEN_X,      _SCREEN_Y      = guiGetScreenSize( )
local _SCREEN_X_HALF, _SCREEN_Y_HALF = _SCREEN_X / 2, _SCREEN_Y / 2

UI_elements = {}

TAB_MAIN      = 1
TAB_DAILY     = 2
TAB_AVAILABLE = 3
TAB_BLOCKED   = 4
TAB_COMPLETED = 5

TAB_PX = nil
CURRENT_TAB_ID = nil
TABS_MENU =
{
    [ TAB_MAIN ] =
    {
        text = "Главная",
        content = function()
            return CreateMainTabView()
        end,
    },
    [ TAB_DAILY ] =
    {
        text = "Ежедневные",
        content = function()
            return CreateDailyTabView()
        end,
    },
    [ TAB_AVAILABLE ] =
    {
        text = "Доступные",
        content = function()
            return CreateAvailableTabView()
        end,
    },
    [ TAB_BLOCKED ] =
    {
        text = "Недоступные",
        content = function()
            return CreateBlockedTabView()
        end,
    },
    [ TAB_COMPLETED ] =
    {
        text = "Выполненные",
        content = function()
            return CreateCompletedTabView()
        end,
    },
}

--Отображение интерфейса
function ShowUIQuestsList()
    
    if not localPlayer:IsInGame() or localPlayer:getData( "photo_mode" ) then return end
    if UI_elements and isElement( UI_elements.black_bg ) then
        HideUIQuestList( )
		return
    end

    ibAutoclose( )
    ibWindowSound()
    
    UI_elements = {}
    --Генерируем список
    local quests_data = localPlayer:GetQuestsData()
    GenerateQuestList( quests_data )

    --Фон, окно
    UI_elements.black_bg = ibCreateBackground( 0xBF1D252E, HideUIQuestList, _, true )

    UI_elements.real_bg = ibCreateImage( _SCREEN_X_HALF - 400, _SCREEN_Y_HALF - 240, 800, 580, "images/menu/bg.png", UI_elements.black_bg )
    :ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )
    UI_elements.rt  = ibCreateRenderTarget( 0, 0, 800, 580, UI_elements.real_bg ):ibData( "priority", -1 )
    UI_elements.bg = ibCreateImage( 0, 0, 800, 580, _, UI_elements.rt, 0x00000000 )

    --Линия таб панели
    ibCreateImage( 32, 116, 740, 1, _, UI_elements.bg, 0x99596C81 )

    --Закрыть
    UI_elements.btn_close = ibCreateButton(	748, 25, 24, 24, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )
        HideUIQuestList()
    end, false )

    --Таб-кнопки
    local px = 32
    for k, v in ipairs( TABS_MENU ) do
        local sx = dxGetTextWidth( v.text, 1, ibFonts.bold_14 )
        UI_elements[ "btn_"  .. k ] = ibCreateArea( px, 93, sx, 24, UI_elements.bg )
        UI_elements[ "text_" .. k ] = ibCreateLabel( 0, -7, sx, 24, v.text,  UI_elements[ "btn_"  .. k ], 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_14 )
        :ibBatchData({ disabled = true, alpha = 200 })

        UI_elements[ "btn_"  .. k ]
        :ibOnHover( function( )
            UI_elements[ "text_"  .. k ]:ibAlphaTo( 255 )
        end )
        :ibOnLeave( function( )
            UI_elements[ "text_"  .. k ]:ibAlphaTo( 200 )
        end )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" or k == CURRENT_TAB_ID then return end
            ibClick( )
            SwitchTab( k )
        end )

        if not UI_elements.active_line then
            UI_elements.active_line = ibCreateImage( 30, 114, sx, 3, _,  UI_elements.bg, 0xFFFF9759 )
        end

        if not CURRENT_TAB_ID then SwitchTab( k ) end

        if k == TAB_DAILY then
            for _, quest in pairs( LIST.daily ) do
                if quest.is_new then
                    ibCreateImage( sx, -17, 23, 23, "images/menu/icon_indicator_new.png", UI_elements[ "btn_"  .. k ] )
                    break
                end
            end
        end

        TABS_MENU[ k ].px = px
        TABS_MENU[ k ].sx = sx

        px = px + sx + 30
    end

    local level = tostring(localPlayer:GetLevel())
    local level_sx = dxGetTextWidth( level, 1, ibFonts.bold_14 )
    UI_elements.level = ibCreateLabel( 772 -  level_sx, 84, 0, 24, level,  UI_elements.bg, 0xFF4791CE, 1, 1, "left", "center", ibFonts.bold_14 )
    local sx = dxGetTextWidth( "Ваш уровень - ", 1, ibFonts.regular_14 )
    UI_elements.level_info = ibCreateLabel( 770 -  level_sx - sx, 84, 0, 24, "Ваш уровень - ",  UI_elements.bg, 0xFF4791CE, 1, 1, "left", "center", ibFonts.regular_14 )

    UI_elements.real_bg:ibMoveTo( _, _SCREEN_Y_HALF - 290, 200 )
    showCursor( true )

end
bindKey( "F2", "up", ShowUIQuestsList )

--Скрытие интерфейса
function HideUIQuestList()
    showCursor( false )
    if isElement(UI_elements and UI_elements.black_bg) then
        destroyElement( UI_elements.black_bg )
    end
    CURRENT_TAB_ID = nil
    UI_elements = nil
end

ibAttachAutoclose( function( ) HideUIQuestList( ) end )

--Переключение таб-страниц
function SwitchTab( new_tab_id )

    local animation_duration = 200
    if CURRENT_TAB_ID then
        TAB_PX = new_tab_id > CURRENT_TAB_ID and 130 or -70
        UI_elements[ "text_" .. CURRENT_TAB_ID ]:ibData( "alpha", 200 )
    end

    if UI_elements and isElement( UI_elements.quest_details_area ) then
        UI_elements.quest_details_area:destroy()
    end

    --Инициализируем новый таб
    UI_elements[ "text_" .. new_tab_id ]:ibData( "alpha", 255 )

    --Перемещаем активную полоску панели
    UI_elements.active_line:ibMoveTo(   TABS_MENU[ new_tab_id ].px, 114, animation_duration, "Linear" )
    UI_elements.active_line:ibResizeTo( TABS_MENU[ new_tab_id ].sx, 3,   animation_duration, "Linear" )


    local new_content_area = TABS_MENU[ new_tab_id ].content()
    if isElement( UI_elements.content_area ) then

        new_content_area
        :ibData( "priority", 0 )
        :ibData("alpha", 0)
        :ibAlphaTo( 255, animation_duration )

        -- Анимация появления с правой стороны
        if new_tab_id > CURRENT_TAB_ID then
            UI_elements.content_area:ibMoveTo( -70, _, animation_duration ):ibAlphaTo( 0, animation_duration )
            new_content_area:ibMoveTo( 30, _, animation_duration )
        -- Анимация появления с левой стороны
        elseif new_tab_id < CURRENT_TAB_ID then
            UI_elements.content_area:ibMoveTo( 130, _, animation_duration ):ibAlphaTo( 0, animation_duration )
            new_content_area:ibMoveTo( 30, _, animation_duration )
        end

        UI_elements.content_area:ibTimer( function( self, old_area )
            if isElement( old_area ) then
                old_area:destroy()
            end
        end, animation_duration, 1, UI_elements.content_area )

        UI_elements.content_area = new_content_area
    else
        UI_elements.content_area = new_content_area
        UI_elements.content_area:ibData( "px", 30 )
    end

    CURRENT_TAB_ID = new_tab_id

end

function onStart()
    local quests_data = localPlayer:GetQuestsData()
    GenerateQuestList( quests_data )	
end
addEvent( "onClientStartQuests", true )
addEventHandler( "onClientStartQuests", root, onStart )
addEventHandler( "onClientResourceStart", resourceRoot, onStart )

addEvent( "ShowUIQuestsList" )
addEventHandler( "ShowUIQuestsList", root, ShowUIQuestsList )