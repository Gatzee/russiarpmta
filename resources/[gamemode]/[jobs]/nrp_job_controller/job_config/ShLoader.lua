JOB_DATA[ JOB_CLASS_LOADER ] =
{
    has_fines = true,
    
    blip_id = 42,
    marker_color = { 255, 128, 128 },
    marker_postions = 
    {
    	{ 
            city = 0, 
            name = "Грузчик: Подработка", 
            x = -1495.205, y = -1492.810 + 860, z = 21.850,
            fn = function( player, job_class )
                if player:GetLevel( ) < 2 then
                    return false, "Требуется 2-й уровень!"
                end

                local job_id = player:GetJobID( ) or player:GetAvailableJobId( job_class )
                if job_id ~= "loader_base" then
                    return false, "Вам доступна работа в компании в морском порту.\nИнформация доступна в F1"
                end
                return true
            end,
            marker_icon = "marker1.png",
        },

        { 
            city = 1,
            name = "Грузчик: Подработка", 
            x = 2491.983, y = -1713.512 + 860, z = 74.053,
            fn = function( player, job_class )
                if player:GetLevel( ) < 2 then
                    return false, "Требуется 2-й уровень!"
                end

                local job_id = player:GetJobID( ) or player:GetAvailableJobId( job_class )
                if job_id ~= "loader_base" then
                    return false, "Вам доступна работа в компании в морском порту.\nИнформация доступна в F1"
                end
                return true
            end,
            marker_icon = "marker1.png",
        },

        {
            city = 1,
            name = "Грузчик: Компания", 
            x = -803.673, y = -1157.338 + 860, z = 15.79,
            fn = function( player, job_class )
                if player:GetLevel( ) < 5 then
                    return false, "Требуется 5-й уровень!"
                end
                
                local job_id = player:GetJobID( ) or player:GetAvailableJobId( job_class )
                if job_id == "loader_base" then
                    return false, "Вам доступна работа грузчиком только на заводе.\nИнформация доступна в F1"
                end
                return true
            end,
            marker_icon = "marker2.png",
        },
    },

    conf = {
        { 
            id = "loader_base",
            name = "Подработка",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 2 then
                    return false, "Требуется 2-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно со 2 уровня",
            event = "PlayeStartQuest_task_loader_base",
        },
        {
            id = "loader_company_1",
            name = "В Компании I",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 5 then
                    return false, "Требуется 5-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 5 уровня",
            event = "PlayeStartQuest_task_loader_company",
            reset_event = "onLoaderCompany_EndShiftRequestReset",
            require_vehicle = true,
            require_license = LICENSE_TYPE_AUTO,
            hide_ui = "Ваше место работы - Морской Порт.\nИнформация доступна в F1",
        },
        {
            id = "loader_company_2",
            name = "В компании II",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 8 then
                    return false, "Требуется 8-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 8 уровня",
            event = "PlayeStartQuest_task_loader_company",
            reset_event = "onLoaderCompany_EndShiftRequestReset",
            require_vehicle = true,
            require_license = LICENSE_TYPE_AUTO,
            hide_ui = "Ваше место работы - Морской Порт.\nИнформация доступна в F1",
        },
        {
            id = "loader_company_3",
            name = "В Компании III",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 10 then
                    return false, "Требуется 10-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 10 уровня",
            event = "PlayeStartQuest_task_loader_company",
            reset_event = "onLoaderCompany_EndShiftRequestReset",
            require_vehicle = true,
            require_license = LICENSE_TYPE_AUTO,
            hide_ui = "Ваше место работы - Морской Порт.\nИнформация доступна в F1",
        }
    },

    tasks = {
        -- Подработка
        {
            company = "loader_base",
            id = "earn_1k_loader",
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
            company = "loader_base",
            id = "loads_20",
            text = "Погрузить 20 коробок",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "l_loads_counter" ) or 0 ) >= 20
            end,
            cleanup = function( player )
                player:SetPermanentData( "l_loads_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "l_loads_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 20", value / 20
            end,
            reward = 300,
        },
        {
            company = "loader_base",
            id = "nonstop_2h",
            text = "Отработать 2 часа,\nне завершая смену",
            check = function( player, job_class, job_id  )
                return not player:GetPermanentData( "l_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) ) >= 2 * 60 * 60
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "l_ended_shift", nil )
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
            company = "loader_company_1",
            id = "earn_5k_loader",
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
            company = "loader_company_1",
            id = "loads_30",
            text = "Погрузить 30 коробок",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "l_loads_counter" ) or 0 ) >= 30
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "l_loads_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "l_loads_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 30", value / 30
            end,
            reward = 500
        },
        {
            company = "loader_company_1",
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

        -- Компания 2
        {
            company = "loader_company_2",
            id = "earn_5k_loader",
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
            company = "loader_company_2",
            id = "loads_30",
            text = "Погрузить 30 коробок",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "l_loads_counter" ) or 0 ) >= 30
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "l_loads_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "l_loads_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 30", value / 30
            end,
            reward = 500
        },
        {
            company = "loader_company_2",
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

        -- Компания 3
        {
            company = "loader_company_3",
            id = "earn_5k_loader",
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
            company = "loader_company_3",
            id = "loads_30",
            text = "Погрузить 30 коробок",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "l_loads_counter" ) or 0 ) >= 30
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "l_loads_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "l_loads_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 30", value / 30
            end,
            reward = 500
        },
        {
            company = "loader_company_3",
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
    },

    vehicle_position =
    {
        [ 1 ] = 
        {
            [ DEFAULT_COMPANY_VEHICLE ] =
            {
                vehicle_id = 530,
                positions =
                {
                    { position = Vector3( -804.454, -1183.961 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -804.454, -1177.961 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -804.454, -1171.961 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -804.454, -1165.961 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -804.454, -1148.793 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -804.454, -1142.793 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -804.454, -1136.793 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -804.454, -1130.793 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -772.44, -1183.961 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -772.44, -1177.961 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -772.44, -1171.961 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -772.44, -1165.961 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -772.44, -1148.793 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -772.44, -1142.793 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -772.44, -1136.793 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -772.44, -1130.793 + 860, 15.785 ), rotation = Vector3( 0, 0, 90 ) },
                    { position = Vector3( -772.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -775.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -778.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -781.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -784.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -787.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -790.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -793.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -796.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -799.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -802.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -805.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -808.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -811.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -814.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( -817.411, -1102.043 + 860, 15.953 ), rotation = Vector3( 0, 0, 180 ) },
                },
            },
        },
    },

}


if localPlayer then
    local VISUAL_VEHICLES = 
    {
        -- НСК
        { area = "visual", model = 508, x = -1441.36 + 860, y = -1592.828, z = 20.88, rz = 0 },
        { area = "visual", model = 499, x = -1431.081 + 860, y = -1592.828, z = 20.86, rz = 0 },
        { area = "visual", model = 498, x = -1419.324 + 860, y = -1602.25, z = 20.89, rz = -90 },
        { area = "visual", model = 508, x = -1419.324 + 860, y = -1621.183, z = 20.89, rz = -90 },
        { area = "visual", model = 498, x = -1441.86 + 860, y = -1630.504, z = 20.89, rz = 180 },
        { area = "visual", model = 498, x = -1431.381 + 860, y = -1630.504, z = 20.89, rz = 180 },
        { area = "visual", model = 498, x = -1442.546 + 860, y = -1606.63, z = 20.89, rz = -90 },
        { area = "visual", model = 498, x = -1442.546 + 860, y = -1615.088, z = 20.89, rz = -90 },
    
        -- Горки
        { area = "visual", model = 498, x = 2393.891 + 860, y = -1713.352, z = 73.927, rz = 90 },
        { area = "visual", model = 498, x = 2393.891 + 860, y = -1719.9, z = 73.927, rz = 90 },
        { area = "visual", model = 498, x = 2393.891 + 860, y = -1726.283, z = 73.927, rz = 90 },
    }
    
    for i, v in pairs( VISUAL_VEHICLES ) do
        local vehicle = createVehicle( v.model, v.x, v.y, v.z, 0, 0, v.rz )
        vehicle:setColor( 255, 255, 255 )
        vehicle.frozen = true
    end
end