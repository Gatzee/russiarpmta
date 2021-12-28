HUD_CONFIGS.daily_quest = {
    order = 995,
    elements = { },
    use_real_fonts = false,
    
    create = function( self )
        local bg = ibCreateImage( 0, 0, 340, 50, _, _, 0xd72a323c )
        self.elements.bg = bg
        return bg
    end,

    destroy = function( self )
        DestroyTableElements( { self.elements.bg } )

        self.elements = { }
    end,
}

function RefreshDailyQuests( )
    ibUseRealFonts( true )
    RefreshDailyQuests_Wrapped( )
    ibUseRealFonts( false )
end

function RefreshDailyQuests_Wrapped( )
    local id = "daily_quest"
    local self = HUD_CONFIGS[ id ]

    DestroyTableElements( getElementChildren( self.elements.bg ) )

    local bg = self.elements.bg

    local quest = GetDailyQuestsList( )[ 1 ]
    if not quest then
        RemoveHUDBlock( "daily_quest" )
        return
    end

    ibCreateImage( 8, 6, 40, 40, "img/current_task_icon_small.png", bg )
    
    local task_name = DAILY_QUEST_LIST and DAILY_QUEST_LIST[ quest.id ] and ( DAILY_QUEST_LIST[ quest.id ].short_name or DAILY_QUEST_LIST[ quest.id ].name ) or "Без названия"
    local task_data = DAILY_QUEST_LIST and DAILY_QUEST_LIST[ quest.id ]

    local is_too_long = utf8.len( task_name ) > 16
    local font = is_too_long and ibFonts.semibold_12 or ibFonts.semibold_14
    task_name = is_too_long and ( utf8.sub( task_name, 1, 16 ).."..." ) or task_name
    local lbl_name = ibCreateLabel( 52, 8, 155, 0, task_name, bg, 0xffff945a, _, _, _, _, font )
    ibCreateLabel( 52, 26, 0, 0, "Ежедневное задание", bg, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, _, _, ibFonts.regular_12 )

    local dummy_details = ibCreateArea( 0, 0, 0, 0, bg )
    local current_type

    local fns = { }

    fns.SetInfoType = function( )
        DestroyTableElements( getElementChildren( dummy_details ) )
        ibCreateImage( 190, 10, 1, 30, _, dummy_details, COLOR_WHITE ):ibData( "alpha", 255*0.1 )

        local reward_data = task_data.rewards
        local reward_str = tostring( quest.first_exec and reward_data.first_value or reward_data.value )
        local reward_font = utf8.len( reward_str ) >= 4 and ibFonts.oxaniumbold_16 or ibFonts.oxaniumbold_20

        ibCreateLabel( 236, 0, 0, 50, reward_data.value, dummy_details, COLOR_WHITE, _, _, "right", "center", reward_font ):ibData( "outline", 1 )
        ibCreateImage( 242, 50/2-28/2, 28, 28, reward_data.type == "hard" and ":nrp_shared/img/hard_money_icon.png" or ":nrp_shared/img/money_icon.png", dummy_details )

        ibCreateImage( 286, 10, 8, 30, "img/icon_arrow.png", dummy_details )
        ibCreateImage( 306, 50/2-17/2, 17, 17, "img/icon_f2.png", dummy_details )
    end

    fns.SetTimerType = function( )
        DestroyTableElements( getElementChildren( dummy_details ) )
        local area_timer = ibCreateArea( 0, 16, 0, 0, dummy_details )

        local icon_timer = ibCreateImage( 0, 0, 16, 18, "img/icon_timer.png", area_timer )
        local lbl_timer = ibCreateLabel( icon_timer:ibGetAfterX( 7 ), -3, 0, 0, "", area_timer, COLOR_WHITE, _, _, _, _, ibFonts.bold_18 )

        local function UpdateTimer( )
            local times_to_end = GetDailyQuestRemainingTime( quest )

            if times_to_end < 0 then
                RefreshDailyQuests( )
                return
            end

            local hour = math.floor( times_to_end / 60 / 60 )
            local min = math.floor( times_to_end / 60 - hour * 60 )
            local sec = times_to_end - min * 60 - hour * 60 * 60

            lbl_timer:ibData( "text", string.format( "%02d:%02d:%02d", hour, min, sec ) )

            if times_to_end <= 60*60 then
                lbl_timer:ibData( "color", 0xffff3a3a )
                icon_timer:ibData( "color", 0xffff3a3a )
            else
                lbl_timer:ibData( "color", 0xffffffff )
                icon_timer:ibData( "color", 0xffffffff )
            end

            area_timer
                :ibData( "sx", lbl_timer:ibGetAfterX( ) )
                :ibData( "px", bg:ibData( "sx" ) - area_timer:ibData( "sx" ) - 16 )
        end

        lbl_timer:ibTimer( UpdateTimer, 500, 0 )
        UpdateTimer( )
    end

    local triangle
    fns.UpdateDetails = function( )
        local time = GetDailyQuestRemainingTime( quest )
        local required_type = time and time <= 0.5 * 60 * 60 and "timer" or "info"

        if time <= 60 * 60 then
            local last_notification = localPlayer:getData( "last_dq_expire_notification" ) or 0
            if getRealTimestamp() - last_notification >= 60 * 60 then
                localPlayer:PhoneNotification( { title = "Ежедневные задачи", msg = "До сброса ежедневных задач осталось ".. math.floor( time/60 ) .." мин" } )
                localPlayer:setData( "last_dq_expire_notification", getRealTimestamp(), false )
            end
        end

        if current_type ~= required_type then
            if required_type == "info" then
                fns.SetInfoType( )
            elseif required_type == "timer" then
                fns.SetTimerType( )
            end
            current_type = required_type
        end

        local is_triangle_active = isElement( triangle )
        if IsHUDBlockActive( "quest" ) then
            if not is_triangle_active then
                triangle = ibCreateImage( 163, -7, 16, 7, "img/icon_triangle.png", bg )
            end
        elseif is_triangle_active then
            destroyElement( triangle )
        end
    end
    lbl_name:ibTimer( fns.UpdateDetails, 500, 0 )
    fns.UpdateDetails( )
end

function GetDailyQuestsList( )
    local value = getElementData( localPlayer, "cur_daily_quests" ) or { }
    local available_daily_quests = { }
    for i, v in pairs( value ) do
        if v.id and v.time_left and v.time_left - getRealTimestamp( ) > 0 then
            table.insert( available_daily_quests, v )
        end
    end

    table.sort( available_daily_quests, function( a, b ) 
        local quest1, quest2 = DAILY_QUEST_LIST[ a.id ], DAILY_QUEST_LIST[ b.id ]
        local reward1, reward2 = ( quest1.rewards.value * ( quest1.rewards.type == "hard" and 1000 or 1 ) ), ( quest2.rewards.value * ( quest2.rewards.type == "hard" and 1000 or 1 ) )
        local forced1, forced2 = a.is_forced and 1 or 0, b.is_forced and 1 or 0

        if forced1 or forced2 then
            return forced1 > forced2
        else
            return reward1 > reward2
        end
    end )

    return available_daily_quests
end

function GetDailyQuestRemainingTime( quest )
    return quest.time_left and quest.time_left - getRealTimestamp( )
end

function IsCanShowDailyQuests()
    if localPlayer:getData( "in_race" ) then
        return false
    end
    return true
end

function DAILYQUEST_onElementDataChange( key )
    if IsCanShowDailyQuests() and (not key or key == "cur_daily_quests") then
        if #GetDailyQuestsList( ) < 0 then RemoveHUDBlock( "daily_quest" ) return end

        AddHUDBlock( "daily_quest" )
        RefreshDailyQuests( )
    end
end
addEventHandler( "onClientElementDataChange", localPlayer, DAILYQUEST_onElementDataChange )

function onClientShowDailyQuests_handler()
    if #GetDailyQuestsList( ) < 0 then RemoveHUDBlock( "daily_quest" ) return end

    AddHUDBlock( "daily_quest" )
    RefreshDailyQuests( )
end
addEvent( "onClientShowDailyQuests", true )
addEventHandler( "onClientShowDailyQuests", root, onClientShowDailyQuests_handler )

function DAILYQUEST_onStart( )
    DAILYQUEST_onElementDataChange( )
end
addEventHandler( "onClientResourceStart", resourceRoot, DAILYQUEST_onStart )