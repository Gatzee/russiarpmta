JOB_DATA[ JOB_CLASS_TAXI ] =
{
    has_fines = true,
    
    blip_id = 56,
    marker_color = { 255, 128, 128 },
    marker_postions = 
    {
    	{ city = 0, name = "Таксист",  x = 466.308, y = -2223.019 + 860, z = 20.598 },
        { city = 1, name = "Таксист",  x = 1785.641, y = -518.468 + 860, z = 60.603  },
    },

    conf = {
        {
            id = "taxi_company_1",
            name = "В Компании I",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 12 then
                    return false, "Требуется 12-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 12 уровня",
            event = "PlayeStartQuest_task_taxi_company",
            require_license = LICENSE_TYPE_AUTO,
            require_vehicle = true,
            on_start_shift = function( player )
                removeEventHandler( "onPlayerVehicleEnter", player, CheckOnJobVehicle )
                addEventHandler( "onPlayerVehicleEnter", player, CheckOnJobVehicle )
            end,
            on_end_shift = function( player )
                removeEventHandler( "onPlayerVehicleEnter", player, CheckOnJobVehicle )
            end,
        },
        {
            id = "taxi_company_2",
            name = "В компании II",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 14 then
                    return false, "Требуется 14-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 14 уровня",
            event = "PlayeStartQuest_task_taxi_company",
            require_vehicle = true,
            require_license = LICENSE_TYPE_AUTO,
            on_start_shift = function( player )
                removeEventHandler( "onPlayerVehicleEnter", player, CheckOnJobVehicle )
                addEventHandler( "onPlayerVehicleEnter", player, CheckOnJobVehicle )
            end,
            on_end_shift = function( player )
                removeEventHandler( "onPlayerVehicleEnter", player, CheckOnJobVehicle )
            end,
        },
        {
            id = "taxi_company_3",
            name = "В Компании III",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 17 then
                    return false, "Требуется 17-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 17 уровня",
            event = "PlayeStartQuest_task_taxi_company",
            require_vehicle = true,
            require_license = LICENSE_TYPE_AUTO,
            on_start_shift = function( player )
                removeEventHandler( "onPlayerVehicleEnter", player, CheckOnJobVehicle )
                addEventHandler( "onPlayerVehicleEnter", player, CheckOnJobVehicle )
            end,
            on_end_shift = function( player )
                removeEventHandler( "onPlayerVehicleEnter", player, CheckOnJobVehicle )
            end,
        }
    },

    tasks = {
        -- Компания 1
        {
            company = "taxi_company_1",
            id = "earn_5k_taxi",
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
            company = "taxi_company_1",
            id = "meters_5000",
            text = "Проехать\n5000 метров",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "tx_deliveries_meters" ) or 0 ) >= 5000
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "tx_deliveries_meters", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "tx_deliveries_meters" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return math.floor(value).." из 5000", value / 5000
            end,
            reward = 500
        },
        {
            company = "taxi_company_1",
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
            reward = 500,
        },

        -- Компания 2
        {
            company = "taxi_company_2",
            id = "earn_5k_taxi",
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
            company = "taxi_company_2",
            id = "meters_5000",
            text = "Проехать\n5000 метров",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "tx_deliveries_meters" ) or 0 ) >= 5000
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "tx_deliveries_meters", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "tx_deliveries_meters" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return math.floor(value).." из 5000", value / 5000
            end,
            reward = 500,
        },
        {
            company = "taxi_company_2",
            id = "nonstop_3h",
            text = "Отработать 3 часа,\nне завершая смену",
            check = function( player, job_class, job_id  )
                return not player:GetPermanentData( job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) ) >= 3 * 60 * 60
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( job_class .. "_ended_shift", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return not player:GetPermanentData( job_class .. "_ended_shift" ) and ( player:GetShiftDuration( ) - player:GetShiftRemainingTime( ) )
            end,
            get_progress_text = function( self, value, job_class, job_id )
                local time = math.floor( value / 60 / 60 * 10 ) / 10
                return time.." из 3ч", time / 3
            end,
            reward = 500,
        },

        -- Компания 3
        {
            company = "taxi_company_3",
            id = "earn_5k_taxi",
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
            company = "taxi_company_3",
            id = "meters_5000",
            text = "Проехать\n5000 метров",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "tx_deliveries_meters" ) or 0 ) >= 5000
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "tx_deliveries_meters", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "tx_deliveries_meters" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return math.floor(value).." из 5000", value / 5000
            end,
            reward = 500,
        },
        {
            company = "taxi_company_3",
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
        -- НСК
        [ 0 ] = 
        {
            [ DEFAULT_COMPANY_VEHICLE ] =
            {
                vehicle_id = {
                    taxi_company_1 = 404,
		            taxi_company_2 = 529,
		            taxi_company_3 = 546,
                },
                positions =
                {
                    { position = Vector3( 462.1, -2195.6 + 860, 20.55 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 458.1, -2195.6 + 860, 20.55 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 426.1, -2195.6 + 860, 20.55 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 430.1, -2195.6 + 860, 20.55 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 434.1, -2195.6 + 860, 20.55 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 438.1, -2195.6 + 860, 20.55 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 442.1, -2195.6 + 860, 20.55 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 446.1, -2195.6 + 860, 20.55 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 450.1, -2195.6 + 860, 20.55 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 454.1, -2195.6 + 860, 20.55 ), rotation = Vector3( 0, 0, 180 ) },
                    { position = Vector3( 438.2998, -2229.4004 + 860, 20.46155 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 426.2998, -2229.4004 + 860, 20.46155 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 430.2998, -2229.4004 + 860, 20.46155 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 434.2998, -2229.4004 + 860, 20.46155 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 442.2998, -2229.4004 + 860, 20.46155 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 446.2998, -2229.4004 + 860, 20.46995 ), rotation = Vector3( 0, 0, 0 ) },
                    { position = Vector3( 427.60001, -2204.0002 + 860, 20.5 ), rotation = Vector3( 0, 0, 270 ) },
                    { position = Vector3( 427.59961, -2219.9004 + 860, 20.5 ), rotation = Vector3( 0, 0, 270 ) },
                    { position = Vector3( 427.59961, -2216 + 860, 20.5 ), rotation = Vector3( 0, 0, 270 ) },
                    { position = Vector3( 427.59961, -2212 + 860, 20.5 ), rotation = Vector3( 0, 0, 270 ) },
                    { position = Vector3( 427.59961, -2208 + 860, 20.5 ), rotation = Vector3( 0, 0, 270 ) },
                    { position = Vector3( 480, -2195 + 860, 20.4 ), rotation = Vector3( 0, 0, 135 ) },
                    { position = Vector3( 476, -2195 + 860, 20.4 ), rotation = Vector3( 0, 0, 135 ) },
                    { position = Vector3( 472, -2195 + 860, 20.4 ), rotation = Vector3( 0, 0, 135 ) },
                    { position = Vector3( 474, -2204 + 860, 20.4 ), rotation = Vector3( 0, 0, 45 ) },
                    { position = Vector3( 479, -2204 + 860, 20.4 ), rotation = Vector3( 0, 0, 45 ) },
                    { position = Vector3( 469, -2204 + 860, 20.4 ), rotation = Vector3( 0, 0, 45 ) },
                },
                after_apply_fn = function( vehicle )
                    vehicle:setColor( 255, 150, 0 )
	                vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_TAXI ) )
                end,
            }
        },
    
        -- Горки
        [ 1 ] = 
        {
            [ DEFAULT_COMPANY_VEHICLE ] =
            {
                vehicle_id = {
                    taxi_company_1 = 404,
		            taxi_company_2 = 529,
		            taxi_company_3 = 546,
                },
                positions =
                {
                    { position = Vector3( 1752.9, -552.20001 + 860, 60.5 ), rotation = Vector3( 0, 0, 264 ) },
                    { position = Vector3( 1753.4, -548.60001 + 860, 60.5 ), rotation = Vector3( 0, 0, 264 ) },
                    { position = Vector3( 1755.9, -525.5 + 860, 60.6 ), rotation = Vector3( 0, 0, 264 ) },
                    { position = Vector3( 1753.7998, -544.90039 + 860, 60.5 ), rotation = Vector3( 0, 0, 264 ) },
                    { position = Vector3( 1754.2998, -541 + 860, 60.5 ), rotation = Vector3( 0, 0, 264 ) },
                    { position = Vector3( 1754.5996, -537 + 860, 60.5 ), rotation = Vector3( 0, 0, 264 ) },
                    { position = Vector3( 1755.0996, -533.2002 + 860, 60.6 ), rotation = Vector3( 0, 0, 264 ) },
                    { position = Vector3( 1755.5, -529.2998 + 860, 60.6 ), rotation = Vector3( 0, 0, 264 ) },
                    { position = Vector3( 1756.4, -521.39999 + 860, 60.5 ), rotation = Vector3( 0, 0, 264 ) },
                    { position = Vector3( 1756.8, -517.39999 + 860, 60.5 ), rotation = Vector3( 0, 0, 264 ) },
                    { position = Vector3( 1787.6, -556.29999 + 860, 60.4 ), rotation = Vector3( 0, 0, 83 ) },
                    { position = Vector3( 1788.1, -552.70001 + 860, 60.4 ), rotation = Vector3( 0, 0, 83 ) },
                    { position = Vector3( 1788.5, -549.29999 + 860, 60.4 ), rotation = Vector3( 0, 0, 83 ) },
                    { position = Vector3( 1789.7, -538.29999 + 860, 60.4 ), rotation = Vector3( 0, 0, 83 ) },
                    { position = Vector3( 1788.7998, -545.90039 + 860, 60.4 ), rotation = Vector3( 0, 0, 83 ) },
                    { position = Vector3( 1789.2002, -542.2002 + 860, 60.4 ), rotation = Vector3( 0, 0, 83 ) },
                    { position = Vector3( 1780, -558 + 860, 60.5 ), rotation = Vector3( 0, 0, 353 ) },
                    { position = Vector3( 1776.5, -557.60001 + 860, 60.5 ), rotation = Vector3( 0, 0, 353 ) },
                    { position = Vector3( 1772.9, -557.10001 + 860, 60.5 ), rotation = Vector3( 0, 0, 353 ) },
                    { position = Vector3( 1761.7, -555.70001 + 860, 60.5 ), rotation = Vector3( 0, 0, 353 ) },
                    { position = Vector3( 1769.3, -556.5 + 860, 60.5 ), rotation = Vector3( 0, 0, 353 ) },
                    { position = Vector3( 1765.6, -556.10001 + 860, 60.5 ), rotation = Vector3( 0, 0, 353 ) },
                    { position = Vector3( 1790.7, -526.99995 + 860, 60.5 ), rotation = Vector3( 0, 0, 120 ) },
                    { position = Vector3( 1791.1, -522.29999 + 860, 60.5 ), rotation = Vector3( 0, 0, 120 ) },
                },
                after_apply_fn = function( vehicle )
                    vehicle:setColor( 255, 150, 0 )
	                vehicle:SetNumberPlate( GenerateRandomNumber( PLATE_TYPE_TAXI ) )
                end,
            }
        },
    
    },
}