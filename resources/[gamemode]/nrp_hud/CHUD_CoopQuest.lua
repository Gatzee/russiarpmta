HUD_CONFIGS.coop_quest = {
    order = 996,
    elements = { },
    use_real_fonts = false,

    create = function( self )
        local bg = ibCreateImage( 0, 0, 340, 98, _, _, 0xd72a323c )
        self.elements.bg = bg
        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements.temp )
        DestroyTableElements( { self.elements.bg, self.elements.timer } )

        self.elements = { }
    end,
}

REGISTERED_COOP_QUESTS_INFO = {}

function AddClientCoopQuestInfo_handler( id, data )
    REGISTERED_COOP_QUESTS_INFO[ id ] = data
end
addEvent( "AddClientCoopQuestInfo" )
addEventHandler( "AddClientCoopQuestInfo", root, AddClientCoopQuestInfo_handler )

function RemoveClientCoopQuestInfo_handler( id )
    REGISTERED_COOP_QUESTS_INFO[ id ] = nil
end
addEvent( "RemoveClientCoopQuestInfo" )
addEventHandler( "RemoveClientCoopQuestInfo", root, RemoveClientCoopQuestInfo_handler )

function COOP_QUEST_onElementDataChange( key )
    if key == "current_quest" or key == "CoopQuestTimerFail" then
        local value = getElementData( localPlayer, "current_quest" )
        if not value or not REGISTERED_COOP_QUESTS_INFO[ value.id ] then 
            RemoveHUDBlock( "coop_quest" ) 
            return 
        end
        AddHUDBlock( "coop_quest" )
        RefreshCoopQuests( )
    end
end
addEventHandler( "onClientElementDataChange", localPlayer, COOP_QUEST_onElementDataChange )

function COOP_QUEST_onStart( )
    COOP_QUEST_onElementDataChange( )
end
addEventHandler( "onClientResourceStart", resourceRoot, COOP_QUEST_onStart )

function RefreshCoopQuests( )
    ibUseRealFonts( true )
    RefreshCoopQuests_Wrapped( )
    ibUseRealFonts( false )
end

function RefreshCoopQuests_Wrapped( )
    local current_quest = getElementData( localPlayer, "current_quest" )
    local data = REGISTERED_COOP_QUESTS_INFO[ current_quest.id ]
    if not data then return end

    local id = "coop_quest"
    local self = HUD_CONFIGS[ id ]

    -- Удаляем старые элементы
    DestroyTableElements( getElementChildren( self.elements.bg ) )

    local bg = self.elements.bg
    local quest_timer = getElementData( localPlayer, "CoopQuestTimerFail" )

    local task_name = quest_timer and "Задание: " .. quest_timer[ 1 ] or "Основное задание"

    ibCreateImage( 279, 9, 52, 52, "img/current_task_icon.png", bg )
    local quest_title = ibCreateLabel( 15, 18, 260, 0, data.title, bg, 0xffff9759, _, _, _, "top", ibFonts.bold_18 )
    local y_down = 0
    local y_lines = 0
    local y_line_size = quest_title:height()
    string.gsub( data.title, "\n", function( s ) y_lines = y_lines + 1 end )
    if y_lines and y_lines >= 1 then
       y_down = y_lines * y_line_size
       bg:ibData( "sy", 98 + y_down )
       RearrangeHUD()
    end

    ibCreateLabel( 15, 40 + y_down, 260, 0, task_name, bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, _, "top", ibFonts.regular_12 )

    if quest_timer then
        quest_timer[ 2 ] = getRealTimestamp() + quest_timer[ 2 ] 

        ibCreateLabel( 15, 64 + y_down, 0, 0, "Время на выполнение задания:", bg, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, _, _, ibFonts.regular_14 )
        local area_timer = ibCreateArea( 0, 64 + y_down, 0, 0, bg )

        local icon_timer = ibCreateImage( 0, 0, 16, 18, "img/icon_timer.png", area_timer )
        local lbl_timer = ibCreateLabel( icon_timer:ibGetAfterX( 7 ), -3, 0, 0, "", area_timer, COLOR_WHITE, _, _, _, _, ibFonts.bold_18 )

        local function UpdateTimer( )
            local times_to_end = quest_timer[ 2 ] - getRealTimestamp()
            if times_to_end < 0 then
                localPlayer:setData( "CoopQuestTimerFail", false, false )
                return
            end

            local min = math.floor( times_to_end / 60 )
            local sec = times_to_end - min * 60

            lbl_timer:ibData( "text", string.format( "%02d:%02d", min, sec ) )

            area_timer
                :ibData( "sx", lbl_timer:ibGetAfterX( ) )
                :ibData( "px", bg:ibData( "sx" ) - area_timer:ibData( "sx" ) - 16 )
        end

        lbl_timer:ibTimer( UpdateTimer, 500, 0 )
        UpdateTimer( )
    else
        ibCreateImage( 16, 68 + y_down, 9, 9, "img/icon_dot.png", bg, 0xff45e356 )

        local role_id = localPlayer:getData( "coop_job_role_id" )
        local task_name = data.tasks[ current_quest.task ][ role_id ]
        ibCreateLabel( 33, 63 + y_down, 0, 0, task_name, bg, ibApplyAlpha( COLOR_WHITE, 85 ), _, _, _, _, ibFonts.regular_14 )
    end
end