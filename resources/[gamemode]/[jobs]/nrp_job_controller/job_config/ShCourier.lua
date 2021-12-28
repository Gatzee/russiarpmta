JOB_DATA[ JOB_CLASS_COURIER ] =
{
    has_fines = true,
    
    blip_id = 51,
    marker_color = { 255, 128, 128 },
    marker_postions = 
    {
    	{ 
            city = 0, 
            name = "Курьер: Подработка", 
            x = -862.5679, y = -1734.5719 + 860, z = 20.95,
            fn = function( player, job_class )
                if player:GetLevel( ) < 2 then
                    return false, "Требуется 2-й уровень!"
                end
                
                local job_id = player:GetJobID( ) or player:GetAvailableJobId( job_class )
                if job_id ~= "courier_base" then
                    return false, "Вам доступна работа в компании - ООО 'Лепта'.\nИнформация доступна в F1"
                end
                return true
            end,
            marker_icon = "marker1.png",
        },

    	{ 
            city = 1,
            name = "Курьер: Подработка", 
            x = 2057.864, y = -637.791 + 860, z = 60.701,
            fn = function( player, job_class )
                if player:GetLevel( ) < 2 then
                    return false, "Требуется 2-й уровень!"
                end

                local job_id = player:GetJobID( ) or player:GetAvailableJobId( job_class )
                if job_id ~= "courier_base" then
                    return false, "Вам доступна работа в компании - ООО 'Лепта'.\nИнформация доступна в F1"
                end
                return true
            end,
            marker_icon = "marker1.png",
        },

        {
            city = 0,
            name = "Курьер: Компания", 
            x = 311.043, y = -2788.131 + 860, z = 21.029,
            fn = function( player, job_class )
                if player:GetLevel( ) < 4 then
                    return false, "Требуется 4-й уровень!"
                end

                local job_id = player:GetJobID( ) or player:GetAvailableJobId( job_class )
                if job_id == "courier_base" then
                    return false, "Вам доступна работа курьером только в отделении Почты России.\nИнформация доступна в F1"
                end
                return true
            end,
            marker_icon = "marker2.png",
        },
    },

    conf = 
    {
        { 
            id = "courier_base",
            name = "Подработка",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 2 then
                    return false, "Требуется 2-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно со 2 уровня",
            event = "PlayeStartQuest_task_courier_base",
        },
        {
            id = "courier_company_1",
            name = "В Компании I",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 4 then
                    return false, "Требуется 4-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 4 уровня",
            event = "PlayeStartQuest_task_courier_company",
            require_vehicle = true,
            require_license = LICENSE_TYPE_AUTO,
            hide_ui = "Ваше место работы - ООО 'Лепта'.\nИнформация доступна в F1",
        },
        {
            id = "courier_company_2",
            name = "В компании II",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 7 then
                    return false, "Требуется 7-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 7 уровня",
            event = "PlayeStartQuest_task_courier_company",
            require_vehicle = true,
            require_license = LICENSE_TYPE_AUTO,
            hide_ui = "Ваше место работы - ООО 'Лепта'.\nИнформация доступна в F1",
        },
        {
            id = "courier_company_3",
            name = "В Компании III",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 10 then
                    return false, "Требуется 10-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 10 уровня",
            event = "PlayeStartQuest_task_courier_company",
            require_vehicle = true,
            require_license = LICENSE_TYPE_AUTO,
            hide_ui = "Ваше место работы - ООО 'Лепта'.\nИнформация доступна в F1",
        }
    },

    tasks = 
    {
        -- Подработка
        {
            company = "courier_base",
            id = "earn_1k_courier",
            text = "Заработать\n1000 рублей",
            check = function( player, job_class, job_id  )
                return player:GetEarnedToday( job_class ) >= 1000
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetEarnedToday( job_class  )
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 1000", value / 1000
            end,
            reward = 300,
        },
        {
            company = "courier_base",
            id = "deliveries_20",
            text = "Отнести 20 посылок",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "c_deliveries_counter" ) or 0 ) >= 20
            end,
            cleanup = function( player )
                player:SetPermanentData( "c_deliveries_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "c_deliveries_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 20", value / 20
            end,
            reward = 300,
        },
        {
            company = "courier_base",
            id = "nonstop_2h",
            text = "Отработать 2 часа,\nне завершая смену",
            check = function( player, job_class, job_id  )
                return not player:GetPermanentData( job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) ) >= 2 * 60 * 60
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( job_class .. "_ended_shift", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return not player:GetPermanentData( job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) )
            end,
            get_progress_text = function( self, value, job_class, job_id )
                local time = math.floor( value / 60 / 60 * 10 ) / 10
                return time.." из 2ч", time / 2
            end,
            reward = 300,
        },

        -- Компания 1
        {
            company = "courier_company_1",
            id = "earn_5k_courier",
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
            company = "courier_company_1",
            id = "deliveries_30",
            text = "Погрузить 30 посылок",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "c_deliveries_counter" ) or 0 ) >= 20
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "c_deliveries_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "c_deliveries_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 30", value / 30
            end,
            reward = 500,
        },
        {
            company = "courier_company_1",
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
            reward = 500,
        },

        -- Компания 2
        {
            company = "courier_company_2",
            id = "earn_5k_courier",
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
            company = "courier_company_2",
            id = "deliveries_30",
            text = "Погрузить 30 посылок",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "c_deliveries_counter" ) or 0 ) >= 20
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "c_deliveries_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "c_deliveries_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 30", value / 30
            end,
            reward = 500,
        },
        {
            company = "courier_company_2",
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
            reward = 500,
        },

        -- Компания 3
        {
            company = "courier_company_3",
            id = "earn_5k_courier",
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
            reward = 700,
        },
        {
            company = "courier_company_3",
            id = "deliveries_30",
            text = "Отвезти 30 посылок",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "c_deliveries_counter" ) or 0 ) >= 20
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "c_deliveries_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "c_deliveries_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 30", value / 30
            end,
            reward = 700,
        },
        {
            company = "courier_company_3",
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
            reward = 700,
        },
    },

    vehicle_position =
    {
        [ 0 ] = 
        {
            [ DEFAULT_COMPANY_VEHICLE ] =
            {
                vehicle_id = 
                {
                    courier_company_1 = 499,
                    courier_company_2 = 499,
                    courier_company_3 = 498,
                },
                positions =
                {
                    { position = Vector3( 262.5, -2775.796 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 266.1, -2775.796 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 269.7, -2775.796 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 273.3, -2775.796 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 276.9, -2775.796 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 280.3, -2775.796 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 284, -2775.796 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 287.7, -2775.796 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 291.2, -2775.796 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 294.792, -2775.796 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 262.5, -2769.327 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 266.1, -2769.327 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 269.7, -2769.327 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 273.3, -2769.327 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 276.9, -2769.327 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 280.3, -2769.327 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 284, -2769.327 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 287.7, -2769.327 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 291.2, -2769.327 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 294.792, -2769.327 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 262.5, -2796.042 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 266.1, -2796.042 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 269.7, -2796.042 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 273.3, -2796.042 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 276.9, -2796.042 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 280.3, -2796.042 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 284, -2796.042 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 287.7, -2796.042 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 291.2, -2796.042 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 294.792, -2796.042 + 860, 20.857 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 262.5, -2804.433 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 266.1, -2804.433 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 269.7, -2804.433 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 273.3, -2804.433 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 276.9, -2804.433 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 280.3, -2804.433 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 284, -2804.433 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 287.7, -2804.433 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 291.2, -2804.433 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 294.792, -2804.433 + 860, 20.857 ), rotation = Vector3( 0, 0, 180 ) },
                },
            },
        },
    },
}