JOB_DATA[ JOB_CLASS_PARK_EMPLOYEE ] =
{
    has_fines = true,
    
    blip_id = 62,
    marker_color = { 30, 160, 60 },
    marker_postions = 
    {
	    { city = 1, name = "Сотрудник парка",  x = 2093.4291, y = 922.6384 + 860, z = 16.3870 },
    },

    conf = {
    
        {
            id = "park_employee_company_1",
            name = "В Компании I",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 4 then
                    return false, "Требуется 4-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 4 уровня",
            event = "PlayeStartQuest_task_park_employee_company_1",
            reset_event = "onParkEmployeeCompany_1_EndShiftRequestReset",
            require_vehicle = true,
        },

        {
            id = "park_employee_company_2",
            name = "В компании II",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 7 then
                    return false, "Требуется 7-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 7 уровня",
            event = "PlayeStartQuest_task_park_employee_company_2",
            reset_event = "onParkEmployeeCompany_2_EndShiftRequestReset",
            require_vehicle = true,
        },

        {
            id = "park_employee_company_3",
            name = "В Компании III",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 9 then
                    return false, "Требуется 9-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 9 уровня",
            event = "PlayeStartQuest_task_park_employee_company_3",
            reset_event = "onParkEmployeeCompany_3_EndShiftRequestReset",
            require_vehicle = true,
        }
    
    },

    tasks = {
        -- В компании I
        {
            company = "park_employee_company_1",
            id = "earn_3k_park_employee",
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
            company = "park_employee_company_1",
            id = "cut_2a",
            text = "Подстричь 2 области",
            check = function( player, job_class, job_id  )
                local cut_areas_count = player:GetPermanentData( "pe_cut_areas" ) or 0
                return cut_areas_count >= 2
            end,
            fn_finish = function( player )
                local cut_areas_count = player:GetPermanentData( "pe_cut_areas" ) or 0
                player:SetPermanentData( "pe_cut_areas", cut_areas_count + 1 )
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "pe_cut_areas", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "pe_cut_areas" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 2", value / 2
            end,
            reward = 500,
        },
        {
            company = "park_employee_company_1",
            id = "nonstop_4h_1",
            text = "Отработать 4 часа,\nне завершая смену",
            check = function( player, job_class, job_id  )
                return not player:GetPermanentData(  job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) ) >= 4 * 60 * 60
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData(  job_class .. "_ended_shift", nil )
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
            company = "park_employee_company_2",
            id = "earn_5k_park_employee",
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
            company = "park_employee_company_2",
            id = "water_2a",
            text = "Полить 2 области",
            check = function( player, job_class, job_id  )
                local watered_areas_count = player:GetPermanentData( "pe_watered_areas" ) or 0
                return watered_areas_count >= 2
            end,
            fn_finish = function( player )
                local watered_areas_count = player:GetPermanentData( "pe_watered_areas" ) or 0
                player:SetPermanentData( "pe_watered_areas", watered_areas_count + 1 )
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "pe_watered_areas", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "pe_watered_areas" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 2", value / 2
            end,
            reward = 500,
        },
        {
            company = "park_employee_company_2",
            id = "nonstop_4h_2",
            text = "Отработать 4 часа,\nне завершая смену",
            check = function( player, job_class, job_id  )
                return not player:GetPermanentData(  job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) ) >= 4 * 60 * 60
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData(  job_class .. "_ended_shift", nil )
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
            company = "park_employee_company_3",
            id = "earn_10k_park_employee",
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
            company = "park_employee_company_3",
            id = "repair_5e",
            text = "Починить 5 элементов",
            check = function( player, job_class, job_id  )
                local repair_elements_count = player:GetPermanentData( "pe_repair_elements" ) or 0
                return repair_elements_count >= 5
            end,
            fn_finish = function( player )
                local repair_elements_count = player:GetPermanentData( "pe_repair_elements" ) or 0
                player:SetPermanentData( "pe_repair_elements", repair_elements_count + 1 )
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "pe_repair_elements", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "pe_repair_elements" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 5", value / 5
            end,
            reward = 700,
        },
        {
            company = "park_employee_company_3",
            id = "nonstop_4h_3",
            text = "Отработать 4 часа,\nне завершая смену",
            check = function( player, job_class, job_id  )
                return not player:GetPermanentData(  job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) ) >= 4 * 60 * 60
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData(  job_class .. "_ended_shift", nil )
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
    },

    vehicle_position =
    {
        [ 1 ] =
        {
            [ DEFAULT_COMPANY_VEHICLE ] =
            {
                vehicle_id = 572,
                positions =
                {
                    { position = Vector3( 2030.2664, 1044.8677 + 860, 16.1697 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2029.9005, 1041.6199 + 860, 16.1697 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2030.0705, 1038.7681 + 860, 16.1697 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2029.8886, 1036.083 + 860, 16.1697 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2029.8146, 1033.2795 + 860, 16.162 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2029.8145, 1030.4176 + 860, 16.162 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2029.8145, 1027.8576 + 860, 16.162 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2029.8145, 1025.267 + 860, 16.162 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2029.9912, 1022.6247 + 860, 16.162 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2029.9654, 1019.6556 + 860, 16.162 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2029.9426, 1017.0661 + 860, 16.162 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2029.904, 1014.5804 + 860, 16.162 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2029.9578, 1011.5642 + 860, 16.162 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2030.0657, 1009.1711 + 860, 16.162 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2030.1297, 1006.9476 + 860, 16.162 ), rotation = Vector3( 0, 0, 290 ) },
                    { position = Vector3( 2030.1297, 1004.4011 + 860, 16.162 ), rotation = Vector3( 0, 0, 290 ) },
                },
            }
        }
    },
}