reward_tooltips_text =
{
    money        = "Игровая валюта",
    money_hard_test = "Игровая валюта",
    soft         = "Игровая валюта",
    hard         = "Донат валюта",
    donate       = "Донат валюта",
    exp          = "Игровой опыт",
    car_discount = "Скидка на авто",
    canister     = "Канистра",
    rand_tuning  = "Тюнинг-деталь",
    repairbox    = "Ремкомплект",
    premium      = "Премиум",
    package      = "Пакет",
    firstaid     = "Аптечка",
    wof_coin_gold = "VIP-жетон колеса фортуны",
}

reward_count_format_fns = {
    premium = function( count )
        return count .. " д."
    end,
}

local GetPackageData = function( package )
    return "package_" .. package.id, package.name .. "\n" .. package.desc
end

function CreateMainTabView()

    local content_area = ibCreateArea( TAB_PX, 137, 740, 413, UI_elements.bg )

    local sx = dxGetTextWidth( "Сюжетные задания", 1, ibFonts.bold_16 )
    ibCreateLabel( 1, -2, sx, 16, "Сюжетные задания", content_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )

    local available = 0
    for _, v in pairs( LIST[ "active" ] ) do
        if v.id and not v.tutorial then
            available = available + 1
        end
    end

    local count = 0
    local max_count = 2
    local items_area = ibCreateArea( 0, 29, 740, 118, content_area )
    if available > 0 then
        ibCreateLabel( 8 + sx, -2, 0, 16, "( Доступно: " .. available .. " )", content_area, 0xFFCBCDCF, 1, 1, "left", "center", ibFonts.regular_14 )
        local py = 0
        local quests = #LIST[ "active" ] > 0 and LIST[ "active" ] or LIST[ "completed" ]
        for _, v in pairs( quests ) do
            if count == max_count then break end
            CreateItemList( py, v, items_area )
            count = count + 1
            py = py + 64
        end
        ibCreateImage( 0, 163, 740, 1, _, content_area, 0x99596C81 )
    elseif not localPlayer:IsTutorialCompleted() then
        ibCreateLabel( 0, 0, 740, 143, "Вам пока недоступны задания, пройдите обучение", items_area, 0xFFB0B8C0, 1, 1, "center", "center", ibFonts.regular_16 )
    end



    local daily_area = ibCreateArea( 0, 185, 740, 229, content_area )
    ibCreateImage( 0, 0, 16, 18, "images/menu/clock_icon.png", daily_area )

    ibCreateLabel( 26, 9, 0, 0, "Ежедневные задания", daily_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )
    sx = dxGetTextWidth( "Ежедневные задания", 1, ibFonts.bold_16 )

    if #LIST[ "daily" ] > 0 then

        available = 0
        for _, v in pairs( LIST[ "daily" ] ) do
            if v.id then
                available = available + 1
            end
        end

        ibCreateLabel( 33 + sx, 9, 0, 0, "( Доступно: " .. available .. " )", daily_area, 0xFFCBCDCF, 1, 1, "left", "center", ibFonts.regular_14 )

        count = 0
        max_count = 3
        items_area = ibCreateArea( 0, 29, 740, 118, daily_area )

        local px = 0
        for _, v in pairs( LIST["daily"] ) do
            if count == max_count then break end

            if v.name then
                CreateBoxItem( px, 0, v, items_area )
                count = count  + 1
                px = px + 253
            end
        end

        if count < max_count then

            for _, v in pairs( LIST["daily"] ) do
                if count == max_count then break end

                if not v.name then
                    CreateDummyBoxItem( px, 0, v, items_area )
                    count = count  + 1
                    px = px + 253
                end
            end

        end

        CreateTasksButton( 644, 188, "Все задания", content_area, function()
            SwitchTab( TAB_DAILY )
        end )
    elseif not localPlayer:IsTutorialCompleted() then
        ibCreateLabel( 0, 0, 740, 270, "Вам пока недоступны задания, пройдите обучение", daily_area, 0xFFB0B8C0, 1, 1, "center", "center", ibFonts.regular_16 )
    end

    CreateTasksButton( 644, 0, "Все задания", content_area, function()
        SwitchTab( TAB_AVAILABLE )
    end )

    

    return content_area

end

function CreateTasksButton( x, y, text, parent, callback )

    local btn_area = ibCreateArea( x - 2, y, 120, 20, parent )

    sx = dxGetTextWidth( text, 1, ibFonts.bold_14 )
    local company_task_labels = ibCreateLabel( 0, 0, sx, 14, text, btn_area, 0xFF7294BB, 1, 1, "center", "center", ibFonts.bold_14 )
    :ibBatchData({ disabled = true, alpha = 200 })

    local company_task_icon = ibCreateImage( sx + 5, 4, 5, 8, "images/menu/arrow_icon.png", btn_area, 0xFF7294BB )
    :ibBatchData({ disabled = true, alpha = 200 })

    btn_area
    :ibOnHover( function( )
        company_task_labels:ibData( "color", 0xFF7FA5D0 )
        company_task_icon:ibData( "color", 0xFF7FA5D0 )
    end )
    :ibOnLeave( function( )
        company_task_labels:ibData( "color", 0xFF7294BB )
        company_task_icon:ibData( "color", 0xFF7294BB )
    end )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )
        if callback then callback() end
    end )

end

function CreateItemList( py, item_data, parent, current_tab )

    local item_area = ibCreateButton( 0, py, 740, 54, parent, "images/menu/item.png", "images/menu/item_hovered.png", "images/menu/item_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xCCFFFFFF )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )
        OpenQuestDetails( item_data )
    end )

    if current_tab == TAB_COMPLETED then
        local quest_state_icon = ibCreateImage( 21, 21, 16, 12, "images/menu/task_completed.png", item_area )
        :ibData( "disabled", true )
    elseif current_tab == TAB_BLOCKED then
        local quest_state_icon = ibCreateImage( 21, 21, 12, 14, "images/menu/lock.png", item_area ):ibData( "disabled", true )
    else
        local quest_state = item_data.current and 0xFF48F85A or 0xFFFFFFFF
        local quest_state_icon = ibCreateImage( 20, 22, 10, 10, "images/menu/circle.png", item_area, quest_state )
        :ibData( "disabled", true )
    end

    local name_quest = ibCreateLabel( 50, 15, 0, 0, item_data.name, item_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.regular_14 )
    :ibData( "disabled", true )

    if current_tab == TAB_BLOCKED then
        local text_label = ""
        if localPlayer:GetLevel() < item_data.level_request then
            text_label = text_label .. "(Доступно " .. item_data.level_request .. " уровня)"
        elseif item_data.quests_request then
            text_label = text_label .. "(Завершите предыдущие квесты)"
        end

        ibCreateLabel( name_quest:width() + 5, 0, 0, 0, text_label, name_quest, 0xFFAAAAAA, 1, 1, "left", "center", ibFonts.regular_12 )
        :ibData( "disabled", true )
    end

    if item_data.steps then
        ibCreateLabel( 320, 37, 0, 0, item_data.current_step .. "/" .. item_data.steps, item_area, 0xFFD1D8E0, 1, 1, "left", "center", ibFonts.regular_14 )
        :ibData( "disabled", true )
        local size_step = 260 / item_data.steps
        ibCreateImage( 50, 34, item_data.current_step * size_step, 8, _, item_area, 0xFF47AFFF ):ibData( "disabled", true )
    elseif current_tab == TAB_COMPLETED then
        ibCreateLabel( 320, 37, 0, 0, "1/1", item_area, 0xFFD1D8E0, 1, 1, "left", "center", ibFonts.regular_14 )
        :ibData( "disabled", true )
        ibCreateImage( 50, 34, 260, 8, _, item_area, 0xFF47AFFF ):ibData( "disabled", true )
    else
        ibCreateLabel( 320, 37, 0, 0, "0/1", item_area, 0xFFD1D8E0, 1, 1, "left", "center", ibFonts.regular_14 )
        :ibData( "disabled", true )
    end

    if item_data.rewards then
        local px = 703
        for k, v in pairs( item_data.rewards ) do
            px = px - 36

            local reward_id = k
            local reward_tooltip = reward_tooltips_text[ k ]
            if reward_id == "package" then 
                reward_id, reward_tooltip = GetPackageData( v )
            end

            ibCreateImage( px, 11, 0, 0, "images/rewards/".. reward_id ..".png", item_area )
            :ibSetRealSize( )
            :ibSetInBoundSize( _, 32 )
            :ibAttachTooltip( tostring( reward_tooltips_text[ k ] and reward_tooltip ) or tostring( k ) )

            if tonumber( v ) then
                local v = reward_count_format_fns[ k ] and reward_count_format_fns[ k ]( v ) or v
                local sx = dxGetTextWidth( v, 1, ibFonts.bold_16 )
                px = px - sx - 2
                ibCreateLabel( px, 0, sx, 54, v, item_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 )
                :ibData( "disabled", true )
            end
        end
        ibCreateImage( px - 92, 19, 82, 16, "images/menu/reward_text.png", item_area):ibData( "disabled", true )
    end
    
end

function CreateBoxItem( px, py, item_data, parent )

    local item_area = ibCreateButton( px, py, 233, 196, parent, "images/menu/item_box.png", "images/menu/item_box_hovered.png", "images/menu/item_box_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xCCFFFFFF )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )
        OpenQuestDetails( item_data )
    end )

    local name_quest = ibCreateLabel( 0, 10, 233, 0, item_data.name, item_area, 0xFFFFFFFF, 1, 1, "center", "top", ibFonts.regular_14 )
    :ibData( "wordbreak", true )

    if item_data.rewards then
        local reward_icon = ibCreateImage( 117, 68, 82, 16, "images/menu/reward_text.png", item_area ):ibData( "disabled", true )
        local py = 86
        for type, reward in pairs( item_data.rewards ) do
            local sx = 0
            if tonumber( reward ) then
                local reward = reward_count_format_fns[ type ] and reward_count_format_fns[ type ]( reward ) or reward
                sx = dxGetTextWidth( reward, 1, ibFonts.bold_16 )
                ibCreateLabel( 117, py - 10, sx, 54, reward, item_area, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_16 ):ibData( "disabled", true )
            end
            
            local reward_id = type
            local reward_tooltip = reward_tooltips_text[ type ]
            if reward_id == "package" then 
                reward_id, reward_tooltip = GetPackageData( reward )
            end

            ibCreateImage( 116 + sx + 2, py, 0, 0, "images/rewards/".. reward_id ..".png", item_area )
            :ibSetRealSize( )
            :ibSetInBoundSize( _, 32 )
            :ibAttachTooltip( reward_tooltip )
            py = py + 20
        end
    end

    local circle = ibCreateImage( 20, 58, 80, 80, "images/menu/ring.png", item_area, 0x30000000 )
    :ibData( "disabled", true )

    if item_data.steps then
        ibCreateLabel( 0, 0, 80, 80, item_data.current_step .. "/" .. item_data.steps, circle, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 )
        :ibData( "disabled", true )

        local size_step = 2 / item_data.steps

        local shader = dxCreateShader( "fx/circle.fx" )
        local texture = dxCreateTexture( "images/menu/ring.png" )
        dxSetShaderValue( shader, "tex", texture )
        dxSetShaderValue( shader, "angle", 0.4 )
        dxSetShaderValue( shader, "dg", item_data.current_step * size_step )
        dxSetShaderValue( shader, "rgba", 71, 175, 255, 255 )

        ibCreateImage( 0, 0, 80, 80, shader, circle )
        :ibData( "disabled", true )
        :ibOnDestroy( function( )
            shader:destroy( )
            texture:destroy( )
        end )
    else

        ibCreateLabel( 0, 0, 80, 80, "0/1", circle, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_16 )
        :ibData( "disabled", true )

    end

    ibCreateImage( 53, 150, 14, 16, "images/menu/clock_icon.png", item_area, 0xFFC7CED5 )
    ibCreateLabel( 74, 158, 0, 0, "Закончится через:", item_area, 0xFFC7CED5, 1, 1, "left", "center", ibFonts.regular_12 )
    UI_elements[ item_area ] = ibCreateLabel( 0, 167, 233, 0, "00:00:00", item_area, 0xFFFFDE96, 1, 1, "center", "top", ibFonts.bold_14 )
    :ibOnRender( function()
        local time_left = item_data.time_left - getRealTimestamp() - 60*60*2
        local date, hours = GetStringDataFromUNIX( time_left )
        UI_elements[ item_area ]:ibData( "text", date )
        UI_elements[ item_area ]:ibData( "color", hours < 1 and 0xffff3a3a or 0xffffffff )
    end )

end


function CreateDummyBoxItem( px, py, item_data, parent )

    local item_area = ibCreateButton( px, py, 233, 196, parent, "images/menu/item_box.png", "images/menu/item_box_hovered.png", "images/menu/item_box_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xCCFFFFFF )
    :ibData( "disabled", true )
    ibCreateImage( 10, 82, 14, 16, "images/menu/clock_icon.png", item_area, 0xFFC7CED5 )
    ibCreateLabel( 30, 91, 0, 0, "Новое задание появится через:", item_area, 0xFFC7CED5, 1, 1, "left", "center", ibFonts.regular_12 )
    UI_elements[ item_area ] = ibCreateLabel( 0, 104, 233, 0, "00:00:00", item_area, 0xFFFFDE96, 1, 1, "center", "top", ibFonts.bold_14 )
    :ibOnRender( function()
        local date, hours = GetStringDataFromUNIX( item_data.time_left - getRealTimestamp() )
        UI_elements[ item_area ]:ibData( "text", date )
        UI_elements[ item_area ]:ibData( "color", hours < 1 and 0xffff3a3a or 0xffffffff )
    end )

end

function OpenQuestDetails( quest_data )

    ibOverlaySound()
    if UI_elements and isElement( UI_elements.quest_details_area ) then
        UI_elements.quest_details_area:destroy()
    end

    UI_elements.content_area:ibBatchData( { disabled = true, priority = -10 } )
    UI_elements.quest_details_area  = ibCreateRenderTarget( 0, 72, 800, 508, UI_elements.bg ):ibData( "priority", -1 )
    UI_elements.quest_bg = ibCreateImage( 0, 508, 800, 508, _, UI_elements.quest_details_area, ibApplyAlpha( 0xff1f2934, 95 ) )

    ibCreateLabel( 30, 76, 0, 0, quest_data.name, UI_elements.quest_bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_16 )
    ibCreateLabel( 30, 122, 713, 0, quest_data.description, UI_elements.quest_bg, 0xFF9BA0A5, 1, 1, "left", "top", ibFonts.regular_14 )
    :ibBatchData( { wordbreak = true, disabled = true } )

    local quest_name_sx = dxGetTextWidth( quest_data.name, 1, ibFonts.bold_16 )
    if quest_data.current or quest_data.daily then
        ibCreateLabel( quest_name_sx + 40, 78, 0, 0, "(В процессе выполнения)", UI_elements.quest_bg, 0xFF39BC4C, 1, 1, "left", "top", ibFonts.regular_14 )
    elseif quest_data.quests_request and not localPlayer:getData( "ignore_quests_request" ) or localPlayer:GetLevel( ) < quest_data.level_request then
        local text_label = "(Недоступно"
        if quest_data.quests_request then
            text_label = text_label .. ", завершите предыдущие квесты"
        end
        if not quest_data.quests_request and localPlayer:GetLevel() < quest_data.level_request then
            text_label = text_label .. ", требуется " .. quest_data.level_request .. " уровень"
        end
        ibCreateLabel( quest_name_sx + 40, 78, 0, 0, text_label .. ")", UI_elements.quest_bg, 0xFFBC3939, 1, 1, "left", "top", ibFonts.regular_14 )
    elseif quest_data.completed then
        ibCreateLabel( quest_name_sx + 40, 78, 0, 0, "(Завершено)", UI_elements.quest_bg, 0xFF39BC4C, 1, 1, "left", "top", ibFonts.regular_14 )
    else
        ibCreateLabel( quest_name_sx + 40, 78, 0, 0, "(Ожидает выполнения)", UI_elements.quest_bg, 0xFFEAB648, 1, 1, "left", "top", ibFonts.regular_14 )
    end


    local quest_executed = false
    for k, v in pairs( LIST.all ) do
        if v.current then
            quest_executed = v
            break
        end
    end

    if not quest_data.daily and not quest_data.completed and not quest_data.quests_request and localPlayer:GetLevel( ) >= quest_data.level_request and not localPlayer:IsOnFactionDuty() and not localPlayer:getData( "jailed" ) then
        if not quest_data.current and not quest_executed then
            local button = ibCreateButton(	622, 19, 210, 135, UI_elements.quest_bg, "images/menu/btn_start.png", "images/menu/btn_start_hovered.png", "images/menu/btn_start_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ShowUIQuestsList()
                ibClick( )
                triggerServerEvent( "PlayeStartQuest_".. quest_data.id, root )
            end, false )
        elseif quest_executed and quest_executed.id == quest_data.id then
            local button = ibCreateButton(	642, 67, 130, 39, UI_elements.quest_bg, "images/menu/btn_stop.png", "images/menu/btn_stop_hovered.png", "images/menu/btn_stop_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ShowUIQuestsList()
                ibClick( )

                local result, err = CheckPlayerCanCancelQuest( )
                if not result then
                    if err then localPlayer:ErrorWindow( err ) end
                    return
                end

                triggerServerEvent( "PlayeStopQuest_".. quest_data.id, root )
            end, false )
        end
    end

    if quest_data.rewards then

        ibCreateImage( 30, 362, 40, 24, "images/menu/reward_icon.png", UI_elements.quest_bg )
        ibCreateLabel( 79, 368, 0, 0, "Награда за выполнение задания:", UI_elements.quest_bg, 0xFFFFD236, 1, 1, "left", "top", ibFonts.regular_14 )

        local px = 320
        for k, v in pairs( quest_data.rewards ) do
            if tonumber( v ) then
                local v = reward_count_format_fns[ k ] and reward_count_format_fns[ k ]( v ) or v
                local sx = dxGetTextWidth( v, 1, ibFonts.bold_16 )
                ibCreateLabel( px, 367, sx, 0, v, UI_elements.quest_bg, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_16 ):ibData( "disabled", true )
                px = px + sx + 2
            end
            
            local reward_id = k
            local reward_tooltip = reward_tooltips_text[ k ]
            
            if reward_id == "package" then 
                reward_id, reward_tooltip = GetPackageData( v )
            end

            ibCreateImage( px, 363, 31, 31, "images/rewards/".. reward_id ..".png", UI_elements.quest_bg )
            :ibAttachTooltip( reward_tooltip )
            px = px + 40
        end

    end

    local hide_button = ibCreateButton(	346, 436, 108, 42, UI_elements.quest_bg, "images/menu/btn_hide.png", "images/menu/btn_hide_hovered.png", "images/menu/btn_hide_hovered.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFCCCCCC )
    :ibOnClick( function( key, state )
        if key ~= "left" or state ~= "up" then return end
        ibClick( )
        UI_elements.quest_bg:ibMoveTo( 0, 508, 250 )
        UI_elements.quest_bg:ibTimer( function()
            if UI_elements.quest_details_area then
                UI_elements.quest_details_area:destroy()
                UI_elements.content_area:ibBatchData( { disabled = false, priority = 0 } )
            end
        end, 250, 1 )
    end, false )

    local quest_config = DAILY_QUEST_LIST[ quest_data.id ]
    if quest_config and quest_data.daily and quest_config.get_location then
        local btn_navigate = ibCreateButton( 580, 68, 190, 34, UI_elements.quest_bg, 
            "images/btn_navigate_i.png", "images/btn_navigate_h.png", "images/btn_navigate_h.png",
             COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        :ibOnClick( function( key, state ) 
            if key ~= "left" or state ~= "up" then return end
            ibClick( )

            local location = quest_config.get_location( )
            triggerEvent( "ToggleGPS", localPlayer, location )
        end )
    end

    UI_elements.quest_bg:ibMoveTo( 0, 0, 250 )

end

function GetStringDataFromUNIX( unix_time )
    local hours, minutes, seconds = math.floor( unix_time / 3600 % 24 ), math.floor( unix_time / 60 % 60 ), math.floor( unix_time % 60 )
    return string.format( "%02d:%02d:%02d ", hours, minutes, seconds ), hours, minutes, seconds
end

Player.IsTutorialCompleted = function( self )
	--local quests_info = self:GetQuestsData()
    --return (quests_info.completed and quests_info.completed[ "angela_1" ]) and true or false
    return true -- TODO: Заменить на что-то адекватное
end

function CheckPlayerCanCancelQuest( )
    local cam_target = getCameraTarget( )
    if not ( cam_target == localPlayer or localPlayer.vehicle and cam_target == localPlayer.vehicle ) then
        return false, "Нельзя отменить квест во время катсцены!"
    end
    return true
end