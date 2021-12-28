JOB_DATA[ JOB_CLASS_HCS ] =
{
    blip_id = 35,
    marker_color = { 230, 230, 0 },
    marker_postions = 
    {
    	{ city = 0, name = "Работник ЖКХ",  x = 353.148,  y = -1627.886 + 860, z = 20.788 },
    	{ city = 1, name = "Работник ЖКХ",  x = 2269.385, y = -1134.679 + 860, z = 60.721 },
    },
    
    conf = 
    {
        
        {
            id = "hcs_company_1",
            name = "В Компании I",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 12 then
                    return false, "Требуется 12-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 12 уровня",
            event = "PlayeStartQuest_task_hcs_company_1",
            reset_event = "onHcsCompany_1_EndShiftRequestReset",
        },
    
        {
            id = "hcs_company_2",
            name = "В компании II",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 14 then
                    return false, "Требуется 14-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 14 уровня",
            event = "PlayeStartQuest_task_hcs_company_2",
            reset_event = "onHcsCompany_2_EndShiftRequestReset",
        },
        
        {
            id = "hcs_company_3",
            name = "В Компании III",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 17 then
                    return false, "Требуется 17-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 17 уровня",
            event = "PlayeStartQuest_task_hcs_company_3",
            reset_event = "onHcsCompany_3_EndShiftRequestReset",
        }
        
    },

    tasks = 
    {
        
        -- В компании I
        {
            company = "hcs_company_1",
            id = "earn_3k_hcs",
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
            company = "hcs_company_1",
            id = "repair_2obj",
            text = "Починить 2 объекта",
            check = function( player, job_class, job_id  )
                local repair_obj_count = source:GetPermanentData( "m_repair_objects" ) or 0
                return repair_obj_count >= 2
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "m_repair_objects" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 2", value / 2
            end,
            reward = 500,
        },
        {
            company = "hcs_company_1",
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
            company = "hcs_company_2",
            id = "earn_5k_hcs",
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
            company = "hcs_company_2",
            id = "repair_5obj",
            text = "Починить 5 объектов",
            check = function( player, job_class, job_id  )
                local repair_obj_count = source:GetPermanentData( "m_repair_objects" ) or 0
                return repair_obj_count >= 5
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "m_repair_objects" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 5", value / 5
            end,
            reward = 500,
        },
        {
            company = "hcs_company_2",
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
            company = "hcs_company_3",
            id = "earn_10k_hcs",
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
            company = "hcs_company_3",
            id = "repair_7obj",
            text = "Починить 7 объектов",
            check = function( player, job_class, job_id  )
                local repair_obj_count = source:GetPermanentData( "m_repair_objects" ) or 0
                return repair_obj_count >= 7
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "m_repair_objects" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 7", value / 7
            end,
            reward = 700,
        },
        {
            company = "hcs_company_3",
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