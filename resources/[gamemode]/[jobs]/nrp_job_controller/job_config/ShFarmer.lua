
JOB_DATA[ JOB_CLASS_FARMER ] =
{
    has_fines = true,
    
    blip_id = 34,
    marker_color = { 255, 128, 128 },
    marker_postions = 
    {
    	{ x = -1292.417, y = -260.013 + 860, z = 28.732, city = 0, name = "Западное фермерство" },
    	{ x = -1123.400, y = -427.4 + 860, z = 21.300, city = 1, name = "Восточное фермерство" },
    },

    conf = 
    {
        { 
            id = "farmer_helper",
            name = "Помощник",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 3 then
                    return false, "Требуется 3-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 3 уровня",
            event = "PlayeStartQuest_task_farmer_helper",
        },
        
        {
            id = "farmer_company_1",
            name = "В Компании I",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 6 then
                    return false, "Требуется 6-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 6 уровня",
            event = "PlayeStartQuest_task_farmer_helper",
            require_license = LICENSE_TYPE_AUTO,
        },
        {
            id = "farmer_company_2",
            name = "В компании II",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 9 then
                    return false, "Требуется 9-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 9 уровня",
            event = "PlayeStartQuest_task_farmer_helper",
            require_license = LICENSE_TYPE_AUTO,
        },
        {
            id = "farmer_company_3",
            name = "В Компании III",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 11 then
                    return false, "Требуется 11-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 11 уровня",
            event = "PlayeStartQuest_task_farmer_helper",
            require_license = LICENSE_TYPE_AUTO,
        }
    },

    tasks = 
    {
        -- Задачи помошника
        {
            company = "farmer_helper",
            id = "earn_1k",
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
            company = "farmer_helper",
            id = "boxes_2",
            text = "Отнести 2 ящика",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "f_boxes_counter" ) or 0 ) >= 2
            end,
            cleanup = function( player )
                player:SetPermanentData( "f_boxes_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "f_boxes_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 2", value / 2
            end,
            reward = 300,
        },
        {
            company = "farmer_helper",
            id = "plants_20",
            text = "Собрать 20 растений",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "f_plants_counter" ) or 0 ) >= 20
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "f_plants_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "f_plants_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 20", value / 20
            end,
            reward = 300
        },

        -- В компании 1
        {
            company = "farmer_company_1",
            id = "earn_5k",
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
            reward = 500
        },
        {
            company = "farmer_company_1",
            id = "sell_5",
            text = "Продать 5 ящиков",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "f_sell_counter" ) or 0 ) >= 5
            end,
            cleanup = function( player )
                player:SetPermanentData( "f_sell_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "f_sell_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 5", value / 5
            end,
            reward = 500
        },
        {
            company = "farmer_company_1",
            id = "put_plants_30",
            text = "Посадить 30 растений",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "f_plants_put_counter" ) or 0 ) >= 30
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "f_plants_put_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "f_plants_put_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 30", value / 30
            end,
            reward = 500
        },

        -- В компании 2
        {
            company = "farmer_company_2",
            id = "earn_5k",
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
            reward = 500
        },
        {
            company = "farmer_company_2",
            id = "sell_5",
            text = "Продать 5 ящиков",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "f_sell_counter" ) or 0 ) >= 5
            end,
            cleanup = function( player )
                player:SetPermanentData( "f_sell_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "f_sell_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 5", value / 5
            end,
            reward = 500
        },
        {
            company = "farmer_company_2",
            id = "put_plants_30",
            text = "Посадить 30 растений",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "f_plants_put_counter" ) or 0 ) >= 30
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "f_plants_put_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "f_plants_put_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 30", value / 30
            end,
            reward = 500
        },

        -- В компании 3
        {
            company = "farmer_company_3",
            id = "earn_5k",
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
            reward = 700
        },
        {
            company = "farmer_company_3",
            id = "sell_5",
            text = "Продать 5 ящиков",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "f_sell_counter" ) or 0 ) >= 5
            end,
            cleanup = function( player )
                player:SetPermanentData( "f_sell_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "f_sell_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 5", value / 5
            end,
            reward = 700
        },
        {
            company = "farmer_company_3",
            id = "put_plants_30",
            text = "Посадить 30 растений",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "f_plants_put_counter" ) or 0 ) >= 30
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "f_plants_put_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "f_plants_put_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 30", value / 30
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
                vehicle_id = 508,
                positions =
                {
                    { position = Vector3( -1361.292, -405.949 + 860, 23.329 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -1354.422, -401.517 + 860, 23.302 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -1349.07, -397.916 + 860, 23.252 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -1343.771, -394.351 + 860, 23.214 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -1338.681, -390.926 + 860, 23.178 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -1333.476, -387.424 + 860, 23.141 ), rotation = Vector3( 0, 0, 180 ) },
                },
            },
        },
        
        [ 1 ] = 
        {
            [ DEFAULT_COMPANY_VEHICLE ] =
            {
                vehicle_id = 508,
                positions =
                {
                    { position = Vector3( -1314.978, -422.485 + 860, 23.614 ), rotation = Vector3( ) },
                    { position = Vector3( -1306.556, -418.775 + 860, 23.589 ), rotation = Vector3( ) },
                    { position = Vector3( -1299.77, -415.78 + 860, 23.574 ), rotation = Vector3( ) },
                    { position = Vector3( -1293.914, -413.194 + 860, 23.574 ), rotation = Vector3( ) },
                    { position = Vector3( -1326.013, -429.41 + 860, 23.578 ), rotation = Vector3( ) },
                    { position = Vector3( -1333.802, -434.494 + 860, 23.544 ), rotation = Vector3( ) },
                },
            },
        },
    },
}