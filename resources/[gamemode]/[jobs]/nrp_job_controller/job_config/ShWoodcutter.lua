JOB_DATA[ JOB_CLASS_WOODCUTTER ] =
{
    has_fines = true,
    
    blip_id = 20,
    marker_color = { 255, 105, 0 },
    marker_postions = 
    {
    	{ city = 1, name = "Дровосек",  x = 1947.2537, y = 290.9189 + 860, z = 16.6167 },
    },

    conf = {
    
        {
            id = "woodcutter_company_1",
            name = "В Компании I",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 19 then
                    return false, "Требуется 19-й уровень!"
                end
                return true
            end,
            pre_start = function( player )
                LoadWoodcutterStocks( player )
            end,
            condition_text = "Доступно с 19 уровня",
            event = "PlayeStartQuest_task_woodcutter_company_1",
            reset_event = "onWoodcutterCompany_1_EndShiftRequestReset",
            require_vehicle = true,
            require_license = LICENSE_TYPE_AUTO,
        },

        {
            id = "woodcutter_company_2",
            name = "В компании II",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 21 then
                    return false, "Требуется 21-й уровень!"
                end
                return true
            end,
            pre_start = function( player )
                LoadWoodcutterStocks( player )
            end,
            condition_text = "Доступно с 21 уровня",
            event = "PlayeStartQuest_task_woodcutter_company_2",
            reset_event = "onWoodcutterCompany_2_EndShiftRequestReset",
            require_vehicle = true,
            require_license = LICENSE_TYPE_TRUCK,
        },

        {
            id = "woodcutter_company_3",
            name = "В Компании III",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 23 then
                    return false, "Требуется 23-й уровень!"
                end
                return true
            end,
            pre_start = function( player )
                LoadWoodcutterStocks( player )
            end,
            condition_text = "Доступно с 23 уровня",
            event = "PlayeStartQuest_task_woodcutter_company_3",
            reset_event = "onWoodcutterCompany_3_EndShiftRequestReset",
            require_vehicle = true,
            require_license = LICENSE_TYPE_AUTO,
        }

    },

    tasks = {
        
        -- В компании I
        {
            company = "woodcutter_company_1",
            id = "earn_3k_woodcutter",
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
            company = "woodcutter_company_1",
            id = "cut_5tree",
            text = "Срубить 5 деревьев",
            check = function( player, job_class, job_id  )
                local cut_trees = player:GetPermanentData( "wc_cut_trees" ) or 0
                return cut_trees >= 5
            end,
            fn_finish = function( player )
                local cut_trees = player:GetPermanentData( "wc_cut_trees" ) or 0
                player:SetPermanentData( "wc_cut_trees", cut_trees + 1 )
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "wc_cut_trees", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "wc_cut_trees" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 5", value / 5
            end,
            reward = 500,
        },
        {
            company = "woodcutter_company_1",
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
            company = "woodcutter_company_2",
            id = "earn_5k_woodcutter",
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
            company = "woodcutter_company_2",
            id = "move_15logs",
            text = "Перевезти 15 брёвен",
            check = function( player, job_class, job_id  )
                local move_trees = player:GetPermanentData( "wc_move_logs" ) or 0
                return move_trees >= 15
            end,
            fn_finish = function( player )
                local cut_trees = player:GetPermanentData( "wc_move_logs" ) or 0
                player:SetPermanentData( "wc_move_logs", cut_trees + 5 )
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "wc_move_logs", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "wc_move_logs" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 15", value / 15
            end,
            reward = 500,
        },
        {
            company = "woodcutter_company_2",
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
            company = "woodcutter_company_3",
            id = "earn_10k_woodcutter",
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
            company = "woodcutter_company_3",
            id = "process_5logs",
            text = "Обработать 5 брёвен",
            check = function( player, job_class, job_id  )
                local process_logs = player:GetPermanentData( "wc_process_logs" ) or 0
                return process_logs >= 5
            end,
            fn_finish = function( player )
                local cut_trees = player:GetPermanentData( "wc_process_logs" ) or 0
                player:SetPermanentData( "wc_process_logs", cut_trees + 1 )
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "wc_process_logs", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "wc_process_logs" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 5", value / 5
            end,
            reward = 700,
        },
        {
            company = "woodcutter_company_3",
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
    },

    vehicle_position = 
    {
	    [ 1 ] = {
            woodcutter_company_1 = 
            {
                vehicle_id = 400,
                positions =
                {
                    { position = Vector3( 1956.2639, 275.4252 + 860, 16.5208 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 1950.3941, 276.3941 + 860, 16.5139 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 1943.7681, 276.3322 + 860, 16.5139 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 1938.0603, 276.2791 + 860, 16.5139 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 1931.6553, 276.2626 + 860, 16.5139 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 1924.5131, 275.6854 + 860, 16.5139 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 1919.774, 276.2296 + 860, 16.5139 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 1961.871, 283.5981 + 860, 16.8392 ), rotation = Vector3( 0, 0, 270 ) },
                    { position = Vector3( 1961.9132, 288.0336 + 860, 16.8181 ), rotation = Vector3( 0, 0, 270 ) },
                    { position = Vector3( 1962.4311, 293.6348 + 860, 16.8479 ), rotation = Vector3( 0, 0, 270 ) },
                },
            },
            woodcutter_company_2 = 
            {
                vehicle_id = 456,
                positions =
                {
                    { position = Vector3( 1914.893, 217.8668 + 860, 16.5208 ), rotation = Vector3( 0, 0, 335 ) },
                    { position = Vector3( 1924.1267, 236.1143 + 860, 16.5139 ), rotation = Vector3( 0, 0, 335 ) },
                    { position = Vector3( 1930.7297, 254.3527 + 860, 16.5139 ), rotation = Vector3( 0, 0, 335 ) },
                    { position = Vector3( 1942.01, 250.2572 + 860, 16.5139 ), rotation = Vector3( 0, 0, 335 ) },
                    { position = Vector3( 1954.9903, 243.1201 + 860, 16.8299 ), rotation = Vector3( 0, 0, 335 ) },
                    { position = Vector3( 1936.2615, 228.3991 + 860, 16.5139 ), rotation = Vector3( 0, 0, 335 ) },
                    { position = Vector3( 1926.184, 214.0859 + 860, 16.5139 ), rotation = Vector3( 0, 0, 335 ) },
                    { position = Vector3( 1933.7172, 211.185 + 860, 16.7158 ), rotation = Vector3( 0, 0, 335 ) },
                    { position = Vector3( 1943.8779, 224.2691 + 860, 16.5765 ), rotation = Vector3( 0, 0, 335 ) },
                    { position = Vector3( 1908.7742, 203.9143 + 860, 16.7743 ), rotation = Vector3( 0, 0, 335 ) },
                },
            },
            woodcutter_company_3 =
            {
                vehicle_id = 400,
                positions =
                {
                    { position = Vector3( 1838.0375976563, 246.5032958984 + 860, 16.921421051025 ), rotation = Vector3( 0, 0, 270 ) },
                    { position = Vector3( 1838.6854248047, 241.4123535156 + 860, 16.904489517212 ), rotation = Vector3( 0, 0, 270 ) },
                    { position = Vector3( 1838.6376953125, 233.8005371094 + 860, 16.896770477295 ), rotation = Vector3( 0, 0, 270 ) },
                    { position = Vector3( 1838.3963623047, 226.5705566406 + 860, 16.861104965212 ), rotation = Vector3( 0, 0, 270 ) },
                    { position = Vector3( 1830.4702148438, 253.7446289063 + 860, 16.959274291992 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 1824.7900390625, 253.7819824219 + 860, 16.959274291992 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 1819.1298828125, 253.6701660156 + 860, 16.959274291992 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 1811.9500732422, 253.5423583984 + 860, 16.959274291992 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 1793.1839599609, 252.1330566406 + 860, 16.823682785034 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 1783.3066406252, 252.2379150391 + 860, 16.534683227539 ), rotation = Vector3( 0, 0, 0 ) },
                },
            }
        },
    },
}