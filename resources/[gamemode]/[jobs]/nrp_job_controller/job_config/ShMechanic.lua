JOB_DATA[ JOB_CLASS_MECHANIC ] =
{
    blip_id = 58,
    marker_color = { 0, 100, 230 },
    marker_postions = 
    {
    	{ city = 0, name = "Автомеханик",  x = 1497.2316, y = 867.5745 + 860, z = 16.1673 },
    },

    conf = 
    {
        {
            id = "mechanic_company_1",
            name = "В Компании I",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 6 then
                    return false, "Требуется 6-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 6 уровня",
            event = "PlayeStartQuest_task_mechanic_company",
            reset_event = "onJobMechanicEndShiftRequestReset",
        },
        {
            id = "mechanic_company_2",
            name = "В компании II",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 8 then
                    return false, "Требуется 8-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 8 уровня",
            event = "PlayeStartQuest_task_mechanic_company",
            reset_event = "onJobMechanicEndShiftRequestReset",
        },
        {
            id = "mechanic_company_3",
            name = "В Компании III",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 11 then
                    return false, "Требуется 11-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 11 уровня",
            event = "PlayeStartQuest_task_mechanic_company",
            reset_event = "onJobMechanicEndShiftRequestReset",
        },
    },

    tasks = {
        -- В компании I
        {
            company = "mechanic_company_1",
            id = "earn_3k_mechanic",
            text = "Заработать\n3000 рублей",
            check = function( player, job_class, job_id  )
                return player:GetEarnedToday( job_class ) >= 3000
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetEarnedToday( job_class  )
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 3000", value / 3000
            end,
            reward = 500,
        },
        {
            company = "mechanic_company_1",
            id = "find_2be",
            text = "Найти 2\nнеисправных элемента",
            check = function( player, job_class, job_id  )
                local find_details = player:GetPermanentData( JOB_ID[ job_class ] .. "_find_details" ) or 0
                return find_details >= 2
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( JOB_ID[ job_class ] .. "_find_details" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 2", value / 2
            end,
            reward = 500,
        },
        {
            company = "mechanic_company_1",
            id = "nonstop_4h_1",
            text = "Отработать 4 часа,\nне завершая смену",
            check = function( player, job_class, job_id  )
                return not player:GetPermanentData( job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) ) >= 4 * 60 * 60
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( job_class .. "_ended_shift", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return not player:GetPermanentData( job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) )
            end,
            get_progress_text = function( self, value, job_class, job_id )
                local time = math.floor( value / 60 / 60 * 10 ) / 10
                return time.." из 4ч", time / 4
            end,
            reward = 500
        },

        -- В компании II
        {
            company = "mechanic_company_2",
            id = "earn_5k_mechanic",
            text = "Заработать\n5000 рублей",
            check = function( player, job_class, job_id  )
                return player:GetEarnedToday( job_class ) >= 5000
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetEarnedToday( job_class  )
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 5000", value / 5000
            end,
            reward = 500,
        },
        {
            company = "mechanic_company_2",
            id = "repl_2be",
            text = "Заменить 2\nнеисправных элементов",
            check = function( player, job_class, job_id  )
                local repl_details = player:GetPermanentData( JOB_ID[ job_class ] .. "_repl_details" ) or 0
                return repl_details >= 2
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( JOB_ID[ job_class ] .. "_repl_details" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 2", value / 2
            end,
            reward = 500,
        },
        {
            company = "mechanic_company_2",
            id = "nonstop_4h_2",
            text = "Отработать 4 часа,\nне завершая смену",
            check = function( player, job_class, job_id  )
                return not player:GetPermanentData( job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) ) >= 4 * 60 * 60
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( job_class .. "_ended_shift", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return not player:GetPermanentData( job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) )
            end,
            get_progress_text = function( self, value, job_class, job_id )
                local time = math.floor( value / 60 / 60 * 10 ) / 10
                return time.." из 4ч", time / 4
            end,
            reward = 500
        },

        -- В компании III
        {
            company = "mechanic_company_3",
            id = "earn_10k_mechanic",
            text = "Заработать\n10000 рублей",
            check = function( player, job_class, job_id  )
                return player:GetEarnedToday( job_class ) >= 10000
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetEarnedToday( job_class  )
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 10000", value / 10000
            end,
            reward = 700,
        },
        {
            company = "mechanic_company_3",
            id = "repl_5be",
            text = "Заменить 5\nнеисправных элементов",
            check = function( player, job_class, job_id  )
                local repl_details = player:GetPermanentData( JOB_ID[ job_class ] .. "_repl_details" ) or 0
                return repl_details >= 5
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( JOB_ID[ job_class ] .. "_repl_details" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 2", value / 2
            end,
            reward = 700,
        },
        {
            company = "mechanic_company_3",
            id = "nonstop_4h_3",
            text = "Отработать 4 часа,\nне завершая смену",
            check = function( player, job_class, job_id  )
                return not player:GetPermanentData( job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) ) >= 4 * 60 * 60
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( job_class .. "_ended_shift", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return not player:GetPermanentData( job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) )
            end,
            get_progress_text = function( self, value, job_class, job_id )
                local time = math.floor( value / 60 / 60 * 10 ) / 10
                return time.." из 4ч", time / 4
            end,
            reward = 700
        },

    }
}