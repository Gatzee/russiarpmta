JOB_DATA[ JOB_CLASS_DRIVER ] =
{
    has_fines = true,
    
    blip_id = 43,
    marker_color = { 255, 128, 128 },
    marker_postions = 
    {
    	{  
            city = 0, 
            name = "Водитель: Компания",  
            x = -1256.862, y = -1800.125 + 860, z = 21.005,
            fn = function( player, job_class )
                return true
            end,
        },
        {  
            city = 1, 
            name = "Водитель: Компания",  
            x = -1065.97, y = 2202 + 860, z = 11.39,
            fn = function( player, job_class )
                return true
            end,
        },
    },

    conf = 
    {
        {
            id = "driver_company_1",
            name = "В Компании I",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 5 then
                    return false, "Требуется 5-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 5 уровня",
            event = "PlayeStartQuest_task_driver_company",
            require_vehicle = true,
            require_license = LICENSE_TYPE_AUTO,
        },
        {
            id = "driver_company_2",
            name = "В компании II",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 13 then
                    return false, "Требуется 13-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 13 уровня",
            event = "PlayeStartQuest_task_driver_company",
            require_vehicle = true,
            require_license = LICENSE_TYPE_BUS,
        },
        {
            id = "driver_company_3",
            name = "В Компании III",
            condition = function( player, is_open_window )
                if player:GetLevel( ) < 15 then
                    return false, "Требуется 15-й уровень!"
                end
                return true
            end,
            condition_text = "Доступно с 15 уровня",
            event = "PlayeStartQuest_task_driver_company",
            require_vehicle = true,
            require_license = LICENSE_TYPE_BUS,
        }
    },

    tasks = { },
    
    vehicle_position =
    {
        -- НСК
        [ 0 ] = 
        {
            [ DEFAULT_COMPANY_VEHICLE ] =
            {
                vehicle_id = {
                    driver_company_1 = 404,
                    driver_company_2 = 437,
                    driver_company_3 = 437,
                },
                positions =
                {
                    { position = Vector3( -1280.2, -1819.8 + 860, 21.2 ), rotation = Vector3( ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1288.2, -1819.8 + 860, 21.2 ), rotation = Vector3( ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1296.2, -1819.8 + 860, 21.2 ), rotation = Vector3( ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1304.2, -1819.8 + 860, 21.2 ), rotation = Vector3( ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1312.2, -1819.8 + 860, 21.2 ), rotation = Vector3( ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1320.2, -1819.8 + 860, 21.2 ), rotation = Vector3( ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1328.2, -1819.8 + 860, 21.2 ), rotation = Vector3( ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1268.448, -1735.872 + 860, 21.263 ), rotation = Vector3( 0, 0, 65 ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1268.356, -1742.052 + 860, 21.263 ), rotation = Vector3( 0, 0, 65 ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1268.369, -1748 + 860, 21.263 ), rotation = Vector3( 0, 0, 65 ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1268.295, -1754.126 + 860, 21.265 ), rotation = Vector3( 0, 0, 65 ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1268.629, -1760.157 + 860, 21.263 ), rotation = Vector3( 0, 0, 65 ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1268.347, -1766.376 + 860, 21.262 ), rotation = Vector3( 0, 0, 65 ), color = { 0, 100, 220 }, },
                    { position = Vector3( -1268.266, -1772.385 + 860, 21.264 ), rotation = Vector3( 0, 0, 65 ), color = { 0, 100, 220 }, },
                },
            },
        },

        [ 1 ] = 
        {
            [ DEFAULT_COMPANY_VEHICLE ] =
            {
                vehicle_id = {
                    driver_company_1 = 404,
                    driver_company_2 = 437,
                    driver_company_3 = 437,
                },
                positions =
                {
                    { position = Vector3( -1050.39, 2211.21 + 860, 12.06 ), rotation = Vector3( ), color = { 0, 100, 220 }, },
                },
            },
        },
    },
}