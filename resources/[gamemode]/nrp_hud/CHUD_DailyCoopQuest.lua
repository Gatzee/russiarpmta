HUD_CONFIGS.daily_coop_quest = {
    order = 996,
    elements = { },
    use_real_fonts = false,

    create = function( self )
        local bg = ibCreateImage( 0, 0, 340, 98+10, _, _, 0xd72a323c )
        self.elements.bg = bg
        return bg
    end,

    destroy = function( self )
        DestroyTableElements( self.elements.temp )
        DestroyTableElements( { self.elements.bg, self.elements.timer } )

        self.elements = { }
    end,
}

local QUEST_DATA = 
{
    title = "Захват точки",
    task_name = "Захватите точку",
    timer = { getRealTimestamp(),  60*5 },
}

function COOP_QUEST_onElementDataChange( key )
    if key == "current_daily_coop_quest" then
        local value = getElementData( localPlayer, "current_daily_coop_quest" )
        if not value then 
            RemoveHUDBlock( "daily_coop_quest" ) 
            return 
        end
        AddHUDBlock( "daily_coop_quest" )
        RefreshDailyCoopQuest( )
    end
end
addEventHandler( "onClientElementDataChange", localPlayer, COOP_QUEST_onElementDataChange )

function COOP_QUEST_onStart( )
    COOP_QUEST_onElementDataChange( )
end
addEventHandler( "onClientResourceStart", resourceRoot, COOP_QUEST_onStart )

function RefreshDailyCoopQuest( )
    ibUseRealFonts( true )
    RefreshDailyCoopQuest_Wrapped( )
    ibUseRealFonts( false )
end

function RefreshDailyCoopQuest_Wrapped( )
    local data = getElementData( localPlayer, "current_daily_coop_quest" )
    if not data then return end

    QUEST_DATA = data

    local id = "daily_coop_quest"
    local self = HUD_CONFIGS[ id ]

    -- Удаляем старые элементы
    DestroyTableElements( getElementChildren( self.elements.bg ) )

    local bg = self.elements.bg
    local task_name = data.task_name
    local quest_timer = data.timer

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

    ibCreateLabel( 15, 40 + y_down, 260, 0, "Текущая задача", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, _, "top", ibFonts.regular_12 )
    ibCreateImage( 16, 68 + y_down, 9, 9, "img/icon_dot.png", bg, 0xff45e356 )
    ibCreateLabel( 33, 63 + y_down, 220, 0, task_name, bg, ibApplyAlpha( COLOR_WHITE, 85 ), _, _, _, _, ibFonts.regular_14 ):ibData( "wordbreak", true )

    if quest_timer then
        local time_left = quest_timer[2] - ( getRealTimestamp() - quest_timer[ 1 ] )
        local area_timer = ibCreateArea( 0, 72 + y_down, 0, 0, bg )
        local icon_timer = ibCreateImage( 0, 0, 16, 18, "img/icon_timer.png", area_timer )
        local lbl_timer = ibCreateLabel( icon_timer:ibGetAfterX( 7 ), -3, 0, 0, "", area_timer, COLOR_WHITE, _, _, _, _, ibFonts.bold_18 )

        local function UpdateTimer( )
            local time_left = quest_timer[2] - ( getRealTimestamp() - quest_timer[ 1 ] )
            if time_left <= 0 then
                icon_timer:ibData( "alpha", 0 )
                lbl_timer:ibData( "alpha", 0 )
                return
            end

            local min = math.floor( time_left / 60 )
            local sec = time_left - min * 60

            lbl_timer:ibData( "text", string.format( "%02d:%02d", min, sec ) )

            area_timer
                :ibData( "sx", lbl_timer:ibGetAfterX( ) )
                :ibData( "px", bg:ibData( "sx" ) - area_timer:ibData( "sx" ) - 16 )
        end

        lbl_timer:ibTimer( UpdateTimer, 500, 0 )
        UpdateTimer( )
    end
end