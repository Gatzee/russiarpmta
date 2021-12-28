JOB_DATA[ JOB_CLASS_TAXI_PRIVATE ] =
{
    has_fines = true,
    
    blip_id = 56,
    marker_color = { 255, 255, 0 },
    marker_postions = 
    {
    	{ city = 0, name = "Таксист Частник",  x = 466.7771, y = -2211.947 + 860, z = 20.5901 },
        { city = 1, name = "Таксист Частник",  x = 1774.570, y = -517.00479 + 860, z = 60.5931 },
    },

    conf = 
    {
        {
            id = "taxi_private_1",
            name = "Таксист Частник",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 6 then
                    return false, "Требуется 6-й уровень!"
                end
                if not is_open_window and not player:HasAnyTaxiLicense( ) then
                    return false, "Нужно иметь хотя бы одну лицензию для работы!"
                end
                return true
            end,
            condition_text = "Доступно с 6 уровня",
            event = "PlayeStartQuest_task_taxi_private",
            on_start_shift = function( player )
                triggerEvent( "onTaxiPrivateShiftStart", player )
            end,
            on_end_shift = function( player )
                player:SetSelectedTaxiVehicle( nil )
                triggerEvent( "onTaxiPrivateShiftEnd", player )
            end,
            pre_start_check = function( player, job_class, job_id  )
                local locked = player:GetPermanentData( "txp_locked" )
                if locked and locked + TAXI_LOCK_TIME >= getRealTime( ).timestamp then
                    local remaining = locked + TAXI_LOCK_TIME - getRealTime( ).timestamp
            
                    local days = math.floor( remaining / ( 24 * 60 * 60 ) )
                    local hours = math.floor( ( remaining % ( 24 * 60 * 60 ) ) / 60 / 60 )
            
                    player:ErrorWindow( "Ты был отстранен за недобросовестную работу!\nОставшееся время: " .. string.format( "%s д. %s ч.", days, hours )  )
                    return false
                end
            
                -- Проверяем по лицензиям при попытке начать смену
                if player:CheckFireFromTaxi( ) then 
                    return false
                end
            
                -- Проверка на наличие выбранной машины
                local class = player:GetCurrentClass( )
                if not class then
                    player:ErrorWindow( "Ты не выбрал автомобиль для развозки" )
                    return false
                end
            
                return true
            end,
            require_license = LICENSE_TYPE_AUTO,
        },
    },

    tasks = {
        {
            id = "meters_3000",
            company = "taxi_private_1",
            text = "Проехать\n3000 метров",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "txp_deliveries_meters" ) or 0 ) >= 3000
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "txp_deliveries_meters", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "txp_deliveries_meters" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return math.floor(value).." из 3000", value / 3000
            end,
            reward = 300,
        },
        {
            id = "earn_1k",
            company = "taxi_private_1",
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
            reward = 300
        },
        {
            id = "passengers_20",
            company = "taxi_private_1",
            text = "Отвезти\n20 пассажиров",
            check = function( player, job_class, job_id  )
                return ( player:GetPermanentData( "txp_deliveries_count" ) or 0 ) >= 20
            end,
            cleanup_full = function( player, job_class, job_id )
                player:SetPermanentData( "txp_deliveries_count", nil )
            end,
            get_progress = function( self, player, job_class, job_id )
                return player:GetPermanentData( "txp_deliveries_count" ) or 0
            end,
            get_progress_text = function( self, value, job_class, job_id )
                return value .. " из 20", value / 20
            end,
            reward = 300,
        },
       
    },
}