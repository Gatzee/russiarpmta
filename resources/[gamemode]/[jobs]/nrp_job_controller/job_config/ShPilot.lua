JOB_DATA[ JOB_CLASS_PILOT ] =
{
    has_fines = true,
    
    blip_id = 8,
    marker_color = { 255, 128, 128 },
    marker_postions = 
    {
    	{ city = 1,  name = "Лётчик: компания",  x = -2525.676, y = 256.522 + 860, z = 16.659, }
    },

    conf = 
    {
        {
            id = "pilot_company_1",
            name = "В Компании I",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 18 then
                    return false, "Требуется 18-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 18 уровня",
            event = "PlayeStartQuest_task_pilot_company",
            destroy_vehicle_restart = true,
            on_end_shift = function( player )
                local quest_vehicle = player:getData( "job_vehicle" )
                if isElement( quest_vehicle ) and player.vehicle == quest_vehicle then
                    removePedFromVehicle( player )
                    setElementFrozen( player, true )

                    local respawn_position = Vector3( -2477.332, 254.480 + 860, 15.250 )
                    player.position = respawn_position:AddRandomRange( 5 )
				    setCameraTarget( player, player )
                    toggleControl( player, "enter_exit", true )
                
                    setElementFrozen( player, false )
                end
            end,
            require_license = LICENSE_TYPE_HELICOPTER,
        },
        {
            id = "pilot_company_2",
            name = "В компании II",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 20 then
                    return false, "Требуется 20-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 20 уровня",
            event = "PlayeStartQuest_task_pilot_company",
            destroy_vehicle_restart = true,
            on_end_shift = function( player )
                local quest_vehicle = player:getData( "job_vehicle" )
                if isElement( quest_vehicle ) and player.vehicle == quest_vehicle then
                    removePedFromVehicle( player )
                    setElementFrozen( player, true )

                    local respawn_position = Vector3( -2477.332, 254.480 + 860, 15.250 )
                    player.position = respawn_position:AddRandomRange( 5 )
				    setCameraTarget( player, player )
                    toggleControl( player, "enter_exit", true )
                
                    setElementFrozen( player, false )
                end
            end,
            require_license = LICENSE_TYPE_HELICOPTER,
        },
        {
            id = "pilot_company_3",
            name = "В Компании III",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 22 then
                    return false, "Требуется 22-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 22 уровня",
            event = { "PlayeStartQuest_task_pilot_airplane", "PlayeStartQuest_task_pilot_airplane_drop" },
            destroy_vehicle_restart = true,
            on_end_shift = function( player )
                local quest_vehicle = player:getData( "job_vehicle" )
                if isElement( quest_vehicle ) and player.vehicle == quest_vehicle then
                    removePedFromVehicle( player )
                    setElementFrozen( player, true )

                    local respawn_position = Vector3( -2477.332, 254.480 + 860, 15.250 )
                    player.position = respawn_position:AddRandomRange( 5 )
				    setCameraTarget( player, player )
                    toggleControl( player, "enter_exit", true )
                
                    setElementFrozen( player, false )
                end
            end,
            require_license = LICENSE_TYPE_AIRPLANE,
        }
    },

    tasks = 
    {
        -- Компания 1
        {
            company = "pilot_company_1",
            id = "earn_3k_pilot",
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
            company = "pilot_company_1",
            id = "deliveries_2",
            text = "Сбросить груз в 2 точках",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "p_deliveries_counter" ) or 0 ) >= 2
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "p_deliveries_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "p_deliveries_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 2", value / 2
            end,
            reward = 500
        },
        {
            company = "pilot_company_1",
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
            company = "pilot_company_2",
            id = "earn_5k_pilot",
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
            company = "pilot_company_2",
            id = "deliveries_3",
            text = "Сбросить груз в 3 точках",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "p_deliveries_counter" ) or 0 ) >= 3
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "p_deliveries_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "p_deliveries_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 3", value / 3
            end,
            reward = 500
        },
        {
            company = "pilot_company_2",
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
            company = "pilot_company_3",
            id = "earn_10k_pilot",
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
            company = "pilot_company_3",
            id = "deliveries_4",
            text = "Завершить 4 рейса",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "p_deliveries_counter" ) or 0 ) >= 4
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "p_deliveries_counter", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "p_deliveries_counter" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 4", value / 4
            end,
            reward = 700
        },
        {
            company = "pilot_company_3",
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
    },

    vehicle_position =
    {
        [ 1 ] =
        {
            pilot_company_1 = 
            {
                vehicle_id = 487,
                positions =
                {
                    { position = Vector3( -2518.581, 534.943 + 860, 16 ), rotation = Vector3( 0, 0, 145 ) },
                    { position = Vector3( -2501.483, 524.469 + 860, 16 ), rotation = Vector3( 0, 0, 145 ) },
                    { position = Vector3( -2479.783, 512.668 + 860, 16 ), rotation = Vector3( 0, 0, 145 ) },
                    { position = Vector3( -2477.431, 481.469 + 860, 16 ), rotation = Vector3( 0, 0, 55 ) },
                },
            },
        
            pilot_company_2 = 
            {
                vehicle_id = 487,
                positions =
                {
                    { position = Vector3( -2518.581, 534.943 + 860, 16 ), rotation = Vector3( 0, 0, 145 ) },
                    { position = Vector3( -2501.483, 524.469 + 860, 16 ), rotation = Vector3( 0, 0, 145 ) },
                    { position = Vector3( -2479.783, 512.668 + 860, 16 ), rotation = Vector3( 0, 0, 145 ) },
                    { position = Vector3( -2477.431, 481.469 + 860, 16 ), rotation = Vector3( 0, 0, 55 ) },
                },
            },
        
            pilot_company_3 = 
            {
                vehicle_id = 577,
                positions =
                {
                    { position = Vector3( -2698.095, 376.614 + 860, 16 ), rotation = Vector3( 0, 0, 330 ) },
                    { position = Vector3( -2657.634, 359.336 + 860, 16 ), rotation = Vector3( 0, 0, 330 ) },
                    { position = Vector3( -2663.038, 467.9 + 860, 16 ), rotation = Vector3( 0, 0, 130 ) },
                    { position = Vector3( -2634.951, 447.663 + 860, 16 ), rotation = Vector3( 0, 0, 130 ) },
                },
            },
        }
    },
}