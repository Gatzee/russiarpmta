JOB_DATA[ JOB_CLASS_TRUCKER ] =
{
    has_fines = true,
    
    blip_id = 13,
    marker_color = { 255, 128, 128 },
    marker_postions = 
    {	
        { city = 0, name = "Дальнобойщик: Компания", x = -2951.630, y = -782.335 + 860, z = 18.526, },
        { city = 1,  name = "Дальнобойщик: Компания",  x = 2416.068, y = -1775.272 + 860, z = 73.919, }
    },

    conf = {
        {
            id = "trucker_company_1",
            name = "В Компании I",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 10 then
                    return false, "Требуется 10-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 10 уровня",
            event = "PlayeStartQuest_task_trucker_company",
            require_vehicle = true,
            require_license = LICENSE_TYPE_TRUCK,
        },
        {
            id = "trucker_company_2",
            name = "В компании II",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 16 then
                    return false, "Требуется 16-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 16 уровня",
            event = "PlayeStartQuest_task_trucker_company",
            require_vehicle = true,
            require_license = LICENSE_TYPE_TRUCK,
        },
        {
            id = "trucker_company_3",
            name = "В Компании III",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 24 then
                    return false, "Требуется 24-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 24 уровня",
            event = "PlayeStartQuest_task_trucker_company",
            require_vehicle = true,
            require_license = LICENSE_TYPE_TRUCK,
        }
    },

    tasks = {
        -- Компания 1
        {
            company = "trucker_company_1",
            id = "earn_3k_trucker",
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
            reward = 500
        },
        {
            company = "trucker_company_1",
            id = "deliveries_2",
            text = "Разгрузиться\nв 2 точках",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "t_deliveries_counter" ) or 0 ) >= 2
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "t_deliveries_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "t_deliveries_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 2", value / 2
            end,
            reward = 500
        },
        {
            company = "trucker_company_1",
            id = "nonstop_4h",
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
            reward = {
                trucker_company_1 = 500,
                trucker_company_2 = 500,
                trucker_company_3 = 700,
            }
        },

        -- Компания 2
        {
            company = "trucker_company_2",
            id = "earn_5k_trucker",
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
            company = "trucker_company_2",
            id = "nonstop_4h",
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
        {
            company = "trucker_company_2",
            id = "deliveries_3",
            text = "Разгрузиться\nв 3 точках",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "t_deliveries_counter" ) or 0 ) >= 3
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "t_deliveries_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "t_deliveries_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 3", value / 3
            end,
            reward = 500
        },

        -- Компания 3
        {
            company = "trucker_company_3",
            id = "earn_10k_trucker",
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
            company = "trucker_company_3",
            id = "nonstop_4h",
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
        {
            company = "trucker_company_3",
            id = "deliveries_4",
            text = "Разгрузиться\nв 4 точках",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "t_deliveries_counter" ) or 0 ) >= 4
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "t_deliveries_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "t_deliveries_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 4", value / 4
            end,
            reward = 700
        },
    },

    vehicle_position = 
    {
        [ 0 ] =
        {
            [ DEFAULT_COMPANY_VEHICLE ] = 
            {
                vehicle_id = {
                    trucker_company_1 = 455,
                    trucker_company_2 = 455,
                    trucker_company_3 = 515,
                },
                positions =
                {
                    { position = Vector3( -2911.584, -699.056 + 860, 18.36 ), rotation = Vector3( 0, 0, 113 ) },
                    { position = Vector3( -2913.459, -694.583 + 860, 18.36 ), rotation = Vector3( 0, 0, 113 ) },
                    { position = Vector3( -2915.335, -690.111 + 860, 18.36 ), rotation = Vector3( 0, 0, 113 ) },
                    { position = Vector3( -2917.21, -685.638 + 860, 18.36 ), rotation = Vector3( 0, 0, 113 ) },
                    { position = Vector3( -2919.086, -681.166 + 860, 18.36 ), rotation = Vector3( 0, 0, 113 ) },
                    { position = Vector3( -2920.961, -676.693 + 860, 18.36 ), rotation = Vector3( 0, 0, 113 ) },
                    { position = Vector3( -2922.837, -672.22 + 860, 18.36 ), rotation = Vector3( 0, 0, 113 ) },
                    { position = Vector3( -2924.712, -667.748 + 860, 18.36 ), rotation = Vector3( 0, 0, 113 ) },
                    { position = Vector3( -2926.588, -663.275 + 860, 18.36 ), rotation = Vector3( 0, 0, 113 ) },
                    { position = Vector3( -2928.463, -658.803 + 860, 18.36 ), rotation = Vector3( 0, 0, 113 ) },
                    { position = Vector3( -2930.339, -654.33 + 860, 18.36 ), rotation = Vector3( 0, 0, 113 ) },
                    { position = Vector3( -2932.215, -649.857 + 860, 18.36 ), rotation = Vector3( 0, 0, 113 ) },
                }
            },
        },
        
        [ 1 ] = 
        {
            [ DEFAULT_COMPANY_VEHICLE ] =
            {
                vehicle_id = {
                    trucker_company_1 = 455,
                    trucker_company_2 = 455,
                    trucker_company_3 = 515,
                },
                positions =
                {
                    { position = Vector3( 2410.94, -1764 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                    { position = Vector3( 2410.94, -1758 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                    { position = Vector3( 2410.94, -1752 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                    { position = Vector3( 2387.94, -1812 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                    { position = Vector3( 2387.94, -1806 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                    { position = Vector3( 2387.94, -1800 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                    { position = Vector3( 2387.94, -1794 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                    { position = Vector3( 2387.94, -1788 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                    { position = Vector3( 2387.94, -1782 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                    { position = Vector3( 2387.94, -1776 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                    { position = Vector3( 2387.94, -1770 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                    { position = Vector3( 2387.94, -1764 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                    { position = Vector3( 2387.94, -1758 + 860, 74.22 ), rotation = Vector3( 0, 0, -90 ) },
                },
            },
        },
    },
}