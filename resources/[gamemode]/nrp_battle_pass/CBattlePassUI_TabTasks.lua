TABS_CONF.tasks = {
    fn_create = function( self, parent )
        -- За этот сезон вы получили
        local total_reward_money = 0
        for task_id, task in pairs( DATA.tasks ) do
            if task.got_money then
                total_reward_money = total_reward_money + BP_TASKS_INFO_BY_ID[ task_id ][ 1 ].money
            end
        end
        local area_total_money = ibCreateArea( 0, -48, 0, 0, parent )
        local lbl_total_money_text = ibCreateLabel( 0, 16, 79, 0, "За этот сезон вы получили: ", area_total_money, ibApplyAlpha( COLOR_WHITE, 50 ), 1, 1, "left", "center", ibFonts.regular_14 )
        local lbl_total_money = ibCreateLabel( lbl_total_money_text:ibGetAfterX(), 15, 0, 0, format_price( total_reward_money ), area_total_money, _, 1, 1, "left", "center", ibFonts.bold_16 )
        local icon_money = ibCreateImage( lbl_total_money:ibGetAfterX( 5 ), 3, 24, 24, ":nrp_shared/img/money_icon.png", area_total_money )
        local btn_details = ibCreateButton( icon_money:ibGetAfterX( 10 ), 0, 120, 32, area_total_money, "img/tasks/btn_details.png", _, _, 0xCCFFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                localPlayer:InfoWindow( "После достижения максимального уровня вы будете получать игровую валюту за выполнение оставшихся задач" )
            end )
        area_total_money:ibData( "px", parent:width( ) - 30 - btn_details:ibGetAfterX() )

        CreateLevelProgressBar( "tasks", 918, parent )

        local area = ibCreateArea( 30, 70, 0, 0, parent )

        local selected_btn
        local selected_stage = BP_STAGES[ 1 ]
        for i, stage in ipairs( BP_STAGES ) do
            local btn = ibCreateButton( ( 79 + 10 ) * ( i - 1 ), 0, 79, 33, area, 
                    "img/tasks/btn_stage.png", _, _, 0xA1FFFFFF, 0xFFFFFFFF, 0xFFAAAAAA )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    selected_btn:ibBatchData( {
                        color = 0xA1FFFFFF, 
                        disabled = false, 
                    } )
                    source:ibBatchData( {
                        color = 0xFFFFFFFF, 
                        disabled = true, 
                    } )
                    selected_btn = source
                    selected_stage = stage
                    UpdateTasksList( ) 
                end )

            if i == 1 then
                selected_btn = btn:ibBatchData( {
                    color = 0xFFFFFFFF, 
                    disabled = true, 
                } )
            end

            ibCreateLabel( 0, 0, 79, 33, "ЭТАП " .. i, btn, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_12 )
                :ibData( "disabled", true )
            
            if stage.start_ts > getRealTimestamp( ) then
                btn:ibData( "disabled", true )
                btn:ibData( "alpha", 70 )
                ibCreateArea( 0, 0, 79, 33, btn ):ibAttachTooltip( "Доступно с " .. os.date( "%d.%m", stage.start_ts ) )
            end
        end

        local scrollpane, scrollbar

        function UpdateTasksList( old_data )
            local old_scroll_pos = old_data and scrollbar and scrollbar:ibData( "position" ) or 0
            if isElement( scrollpane ) then
                scrollpane:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
                scrollbar:ibAlphaTo( 0, 200 ):ibTimer( destroyElement, 200, 1 )
            end

            scrollpane, scrollbar = ibCreateScrollpane( 0, 53, parent:ibData( "sx" ) - 60, parent:ibData( "sy" ) - 123, area, { scroll_px = 10 } )
            scrollbar:ibSetStyle( "slim_nobg" )
            
            local py = 0
            local sy = 80
            for i, task in ipairs( selected_stage.tasks ) do
                if not task.condition or task.condition( localPlayer ) then
                    local task_data = DATA.tasks and DATA.tasks[ task.id ] or { }

                    local bg = ibCreateImage( 0, py, 964, sy, "img/tasks/bg_task.png", scrollpane )
                        :ibData( "alpha", task_data.completed and 128 or 255 )
                    
                    -- Название
                    ibCreateLabel( 30, 0, 120, sy, task.name, bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_14 )
                        :ibData( "wordbreak", true )

                    -- Описание
                    local progressbar_sx = DATA.level == BP_MAX_LEVEL and 500 or 300
                    ibCreateLabel( 160, 26, progressbar_sx + 50, 0, task.desc, bg, ibApplyAlpha( COLOR_WHITE, 65 ), 1, 1, "left", "center", ibFonts.regular_14 )
                        :ibData( "wordbreak", true )

                    -- Прогрессбар
                    local oy = ( task.desc:find( "\n" ) or dxGetTextWidth( task.desc, 1, ibFonts.regular_14 ) > ( progressbar_sx + 50 ) ) and 7 or 0
                    local bg_progressbar = ibCreateImage( 160, 46 + oy, progressbar_sx, 14, _, bg, ibApplyAlpha( COLOR_BLACK, 25 ) )
                    ibCreateImage( 0, 0, bg_progressbar:width( ) * ( task_data.progress or 0 ), 14, _, bg_progressbar, 0xFF47afff )

                    -- Прогресс
                    local progress = ( task_data.progress or 0 ) * task.need_progress
                    progress = ( math.ceil( progress ) - progress < 0.1 ^ 5 ) and math.ceil( progress ) or math.floor( progress )
                    local text = progress .. " / " .. task.need_progress
                    ibCreateLabel( bg_progressbar:width( ) + 10, 6, 0, 0, text, bg_progressbar, COLOR_WHITE, 1, 1, "left", "center", ibFonts.regular_12 )
                
                    -- Награда
                    local area_reward = ibCreateArea( 0, 0, 0, 0, bg )
                    ibCreateImage( 0, 32, 90, 16, "img/tasks/reward.png", area_reward )

                    if DATA.level == BP_MAX_LEVEL then
                        -- Софта
                        local lbl_reward = ibCreateLabel( 100, 39, 0, 0, format_price( task.money ), area_reward, _, 1, 1, "left", "center", ibFonts.bold_20 )
                        local icon_money = ibCreateImage( lbl_reward:ibGetAfterX( 8 ), 24, 28, 28, ":nrp_shared/img/money_icon.png", area_reward )
                        area_reward:ibData( "px", bg:width( ) - icon_money:ibGetAfterX( ) - 30 )
                    else
                        -- EXP
                        local reward = task.reward
                        if DATA.is_premium_active then
                            reward = reward + math.floor( task.reward * BP_PREMIUM_EXP_MULTIPLIER )
                        end
                        local reward_boosted = reward + math.floor( task.reward * BP_BOOSTER_EXP_MULTIPLIER )

                        ibCreateImage( 0, 32, 90, 16, "img/tasks/reward.png", area_reward )
                        if DATA.booster_end_ts and DATA.booster_end_ts > getRealTimestamp( ) then
                            local lbl_reward = ibCreateLabel( 100, 39, 0, 0, reward_boosted, area_reward, 0xFFffd236, 1, 1, "left", "center", ibFonts.bold_20 )
                            local icon_exp = ibCreateImage( lbl_reward:ibGetAfterX( -6 ), 19, 41, 41, "img/tasks/icon_exp_boosted.png", area_reward )
                            area_reward:ibData( "px", bg:width( ) - 130 - icon_exp:ibGetAfterX( -11 ) - 30 )
                        else
                            local lbl_reward = ibCreateLabel( 100, 39, 0, 0, reward, area_reward, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_18 )
                            local icon_exp = ibCreateImage( lbl_reward:ibGetAfterX( 5 ), 30, 18, 18, "img/tasks/icon_exp.png", area_reward )
                            
                            local line = ibCreateImage( icon_exp:ibGetAfterX( 15 ), 20, 1, 40, _, area_reward, ibApplyAlpha( COLOR_WHITE, 10 ) )
                            local lbl_boosted = ibCreateLabel( line:ibGetAfterX( 15 ), 26, 0, 0, "С усилением:", area_reward, ibApplyAlpha( COLOR_WHITE, 65 ), 1, 1, "left", "center", ibFonts.regular_12 )
                            local lbl_reward_boosted = ibCreateLabel( line:ibGetAfterX( 15 ), 50, 0, 0, reward_boosted, area_reward, 0xFFffd236, 1, 1, "left", "center", ibFonts.bold_20 )
                            ibCreateImage( lbl_reward_boosted:ibGetAfterX( -5 ), 29, 41, 41, "img/tasks/icon_exp_boosted.png", area_reward )
                            area_reward:ibData( "px", bg:width( ) - 130 - lbl_boosted:ibGetAfterX( ) - 30 )
                        end

                        local skip_cost = BP_TASK_SKIP_COSTS[ ( DATA.task_skip_count or 0 ) + 1 ]
                        local btn_skip = ibCreateButton( bg:width( ) - 130, 0, 130, sy, bg, _, _, _, ibApplyAlpha( 0xFF7ba0ca, 75 ), 0xFF7ba0ca, 0xFF57718f )
                            :ibData( "disabled", not not task_data.completed )
                            :ibData( "color_disabled", ibApplyAlpha( 0xFF7ba0ca, 50 ) )
                            :ibOnClick( function( key, state )
                                if key ~= "left" or state ~= "up" then return end
                                ibClick( )
                                
                                ibConfirm( {
                                    title = "ПОДТВЕРЖДЕНИЕ", 
                                    text = "Ты хочешь пропустить эту задачу за",
                                    cost = skip_cost,
                                    cost_is_soft = false,
                                    fn = function( self ) 
                                        self:destroy()
                                        triggerServerEvent( "BP:onPlayerWantSkipTask", resourceRoot, task.id )
                                    end,
                                    escape_close = true,
                                } )
                            end )

                        ibCreateLabel( 22, 27, 0, 0, "Пропустить за:", btn_skip, ibApplyAlpha( COLOR_WHITE, 65 ), 1, 1, "left", "center", ibFonts.regular_12 )
                        local cost_lbl = ibCreateLabel( 22, 50, 0, 0, format_price( skip_cost ), btn_skip, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 )
                        ibCreateImage( cost_lbl:ibGetAfterX( 8 ), 40, 24, 24, ":nrp_shared/img/hard_money_icon.png", btn_skip )
                            :ibData( "disabled", true )
                    end

                    py = py + sy + 10
                end
            end

            scrollpane:ibData( "sy", py )
            scrollbar:UpdateScrollbarVisibility( scrollpane ):ibData( "position", old_scroll_pos )
        end
        UpdateTasksList( )
        AddUpdateEventHandler( "booster_end_ts", "tasks_list", UpdateTasksList )
        AddUpdateEventHandler( "is_premium_active", "tasks_list", UpdateTasksList )
        AddUpdateEventHandler( "task_skip_count", "tasks_list", UpdateTasksList )
        AddUpdateEventHandler( "level", "tasks_list", function()
            if DATA.level == BP_MAX_LEVEL then
                UpdateTasksList( )
            end
        end )
    end,
}