TABS_CONF.tasks = {
    fn_create = function( self, parent )

        local bg = ibCreateImage( 30, 20, 964, 563, "img/tasks/bg.png", parent )

        local result_left_area = ibCreateArea( 0, 0, 174, 0, bg )
        -- Позиция клана в лидерборде
        local str_position = CLAN_DATA.leaderboard_position == "Картель" and "Картель" or ( ( CLAN_DATA.leaderboard_position or "?" ) .. " место" )
        local lbl_value = ibCreateLabel( 0, 160, 0, 0, str_position, result_left_area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_12 )
            :center_x( )
        -- До №-го места не хватает
        if CLAN_DATA.need_score then
            local next_position = ( CLAN_DATA.leaderboard_position or 0 ) - 1
            ibCreateLabel( 0, 189, 0, 0, "До " .. next_position .. "-го места не хватает", result_left_area, 0xFF909aa4, 1, 1, "center", "top", ibFonts.regular_12 )
                :center_x( )
            ibCreateLabel( 0, 204, 0, 0, CLAN_DATA.need_score .. plural( CLAN_DATA.need_score, " очко", " очка", " очков" ), result_left_area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_12 )
                :center_x( )
        end

        if next( CLAN_DATA.today_best_member or { } ) then
            local result_right_area = ibCreateArea( 175, 0, 174, 0, bg )
            -- Самый ценный член клана за сегодня
            ibCreateLabel( 0, 160, 0, 0, CLAN_DATA.today_best_member.name, result_right_area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_12 )
                :center_x( )
            -- Принесенные очки
            ibCreateLabel( 0, 204, 0, 0, CLAN_DATA.today_best_member.score, result_right_area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_12 )
                :center_x( )
        end

        --Ежедневные задания по поставкам:
        local UPGRADE_ID_BY_PRODUCT_TYPE = {
            [ "alco" ] = CLAN_UPGRADE_ALCO_FACTORY,
            [ "hash" ] = CLAN_UPGRADE_HASH_FACTORY,
        }
        local oy = 0
        for ti, product_type in pairs( { "alco", "hash" } ) do
            local area_batch = ibCreateArea( 385, 126 + oy, 0, 0, bg )

            local upgrade_id = UPGRADE_ID_BY_PRODUCT_TYPE[ product_type ]
            local factory_lvl = localPlayer:GetClanUpgradeLevel( upgrade_id ) or 0
            if factory_lvl > 0 then
                local ready_batches_count = CLAN_DATA.today_batches and CLAN_DATA.today_batches[ product_type ] or 0
                local current_batch_number = ready_batches_count >= MAX_BATCHES_COUNT_IN_DAY and MAX_BATCHES_COUNT_IN_DAY or ready_batches_count
                local batch_text = product_type == "alco" and "Партия алкоголя " or "Партия петрушки "
                local lbl_batch_text = ibCreateLabel( 0, 1, 0, 0, batch_text, area_batch, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_12 )
                local lbl_batch_number = ibCreateLabel( lbl_batch_text:ibGetAfterX( ), 0, 0, 0, current_batch_number, area_batch, COLOR_WHITE, _, _, "left", "center", ibFonts.regular_14 )
                local lbl_max_batches_count = ibCreateLabel( lbl_batch_number:ibGetAfterX( 1 ), 2, 0, 0, "/" .. MAX_BATCHES_COUNT_IN_DAY, area_batch, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.regular_12 )

                local count = 0
                local need_count_for_batch = FACTORY_UPGRADES[ factory_lvl ] and FACTORY_UPGRADES[ factory_lvl ].need_count_for_batch or 1
                if ready_batches_count >= MAX_BATCHES_COUNT_IN_DAY then
                    count = need_count_for_batch
                else
                    count = CLAN_DATA.freezer and CLAN_DATA.freezer[ product_type ] and CLAN_DATA.freezer[ product_type ].total_count or 0
                end
                local progress = math.min( 1, count / need_count_for_batch )
                local progressbar = ibCreateImage( 385, 139 + oy, 308 * progress, 7, _, bg, 0xFF47afff )
                ibCreateLabel( 0, 1, 308, 0, math.floor( progress * 100 ) .. "%", area_batch, COLOR_WHITE, _, _, "right", "center", ibFonts.regular_12 )
            else
                ibCreateImage( 0, -7, 12, 12, "img/levels/icon_locked.png", area_batch, ibApplyAlpha( COLOR_WHITE, 75 ) )
                ibCreateLabel( 15, -10, 308, 20, "Необходимо приобрести " .. CLAN_UPGRADES_LIST[ upgrade_id ].name, area_batch, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_12 )
                    :ibData( "wordbreak", true )
                    :ibAttachTooltip( "Улучшения приобретаются внутри бункера клана\nчерез панель управления" )
            end
            oy = oy + 69
        end

        -- До конца сезона
        local season_end_area = ibCreateArea( 732, 0, 232, 0, bg )
        local current_date = getRealTimestamp( )
        local season_data = CLAN_DATA.season_data
        local season_end_date = season_data.end_date
        local time_left = season_end_date - current_date
        local text = ""
        if time_left > 0 then
            text = "До конца сезона"
        else
            text = "До начала нового сезона"
            season_end_date = season_data.locked and season_data.start_date or season_end_date + 32 * 60 * 60
        end
        ibCreateLabel( 0, 74, 0, 0, text, season_end_area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.regular_14 )
            :center_x( )
        local text = ( getHumanTimeString( season_end_date ) or "0" ):match( "%d+ ?[^%s]*" )
        ibCreateLabel( 0, 187, 0, 0, text, season_end_area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_16 )
            :center_x( )

        local clan_tasks_info = {
            {
                title = "РЕЙДЕРСКИЙ ЗАХВАТ",
                time = "Каждый день 19:00-22:00",
                score = "Очки чести за победу - 240",
                duration = "Продолжительность матча - 12:00",
                score_key = "holdarea_score",
            },
            {
                title = "СМЕРТЕЛЬНЫЙ МАТЧ",
                time = "Каждый день 16:00-19:00",
                score = "Очки чести за победу - 240",
                duration = "Продолжительность матча - 12:00",
                score_key = "deathmatch_score",
            },
            {
                title = "СБРОС ГРУЗА",
                time = "Каждый день в 12:00, 16:00, 20:00, 00:00",
                score = "Очки чести за выполнение - 500",
                duration = "Время на выполнение - 2 ч",
                score_key = "cargodrops_score",
            },
        }

        local col_sx = 307
        for i, task_info in pairs( clan_tasks_info ) do
            local col_area = ibCreateArea( ( col_sx + 22 ) * ( i - 1 ), 275, col_sx, 288, bg )
            ibCreateLabel( 0, 20, col_sx, 0, task_info.title, col_area, COLOR_WHITE, 1, 1, "center", "top", ibFonts.bold_14 )
            ibCreateLabel( 0, 50, col_sx, 0, task_info.time, col_area, 0xFFb3bbc3, 1, 1, "center", "top", ibFonts.regular_12 )

            ibCreateLabel( 64, 120, 0, 0, task_info.score, col_area, 0xFFd1d4d7, 1, 1, "left", "top", ibFonts.regular_12 )
            -- local area = ibCreateArea( 0, 0, 0, 0, col_area )
            -- ibCreateImage( 0, 119, 23, 20, "img/tasks/icon_honor.png", area )
            -- local lbl = ibCreateLabel( 33, 120, 0, 0, task_info.score, area, 0xFFd1d4d7, 1, 1, "left", "top", ibFonts.regular_12 )
            -- area:ibData( "sx", lbl:ibGetAfterX( ) ):center_x( )
            
            ibCreateLabel( 64, 154, 0, 0, task_info.duration, col_area, 0xFFd1d4d7, 1, 1, "left", "top", ibFonts.regular_12 )
            -- local area = ibCreateArea( 0, 0, 0, 0, col_area )
            -- ibCreateImage( 0, 151, 26, 24, "img/tasks/icon_time.png", area )
            -- local lbl = ibCreateLabel( 36, 154, 0, 0, task_info.duration, area, 0xFFd1d4d7, 1, 1, "left", "top", ibFonts.regular_12 )
            -- area:ibData( "sx", lbl:ibGetAfterX( ) ):center_x( )

            ibCreateLabel( 0, 240, col_sx, 0, "Заработанные очки: " .. ( CLAN_DATA[ task_info.score_key ] or 0 ), col_area, 0xFFb3bbc3, 1, 1, "center", "top", ibFonts.regular_12 )
        end
    end,
}