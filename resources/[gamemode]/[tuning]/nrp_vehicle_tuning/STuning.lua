loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "ShVehicleConfig" )

function onVehiclePostLoad_handler( data )
    local vehicle = source
    
    setElementData( vehicle, "tuning_external", data.tuning_external )

    -- Цвет машины
    if data.color then
        local r, g, b = unpack( data.color )
        if r and g and b then
            setVehicleColor( vehicle, r, g, b )
        end
    end

    local vehilce_vinyls = vehicle:GetVinyls()
    if next( vehilce_vinyls ) then
        setElementData( vehicle, "vehicle_vinyl_data", { vinyls = vehilce_vinyls, color = { vehicle:getColor( true ) } } )
    end

    local neon = vehicle:GetNeon( )
    if neon and next( neon ) then
        vehicle:setData( "ne_i", neon.neon_image )
    end

    if not vehicle:GetSpecialType( ) then
        -- Подгрузка колёс
        if data.wheels and data.wheels ~= 0 then
            vehicle:ApplyWheels( data.wheels )
        end

        -- Ширина колес
        vehicle:SetWheelsWidth( vehicle:GetWheelsWidth( ) )
    
        -- Вылет колес
        vehicle:SetWheelsOffset( vehicle:GetWheelsOffset( ) )
    
        -- Развал колес
        vehicle:SetWheelsCamber( vehicle:GetWheelsCamber( ) )

        if data.wheels_color then
            local r, g, b = unpack( data.wheels_color or { } )
            if r and g and b then
                vehicle:SetWheelsColor( r, g, b )
            end
        end

        -- Высота машины
        if data.height_level and data.height_level ~= 0 then
            vehicle:ApplyHeightLevel( data.height_level )
        end

        -- Гидравлика
        if data.hydraulics == "yes" then
            vehicle:ApplyHydraulics( true )
        end

        -- Цвет фар
        if data.headlights_color then
            local r, g, b = unpack( data.headlights_color or { } )
            if r and g and b then
                vehicle:ApplyHeadlightsColor( r, g, b )
            end
        end

        -- Проверка на наличие черного тюнинга
        local player = GetPlayer( vehicle:GetOwnerID(), true )
        local is_black_tuning_enabled = false
        if player then
            local access_data = player:GetBatchPermanentData( "vehicle_access_sub_id", "vehicle_access_sub_time" )
            is_black_tuning_enabled = ( access_data.vehicle_access_sub_id or 0 ) == data.id
            is_black_tuning_enabled = is_black_tuning_enabled and player:IsPremiumActive()
        end

        -- Черный тюнинг: цвет номеров
        if data.black_platecolor and is_black_tuning_enabled then
            vehicle:ApplyNumberPlateColor( data.black_platecolor )
        elseif data.black_platecolor then
            local pWindowsColor = vehicle:GetWindowsColor()
            vehicle:ResetBlackTuning( pWindowsColor[ 4 ] )
        end

        -- Цвет окон + черный тюнинг
        if data.windows_color then
            local wcolor = data.windows_color or { 0, 0, 0, 120 }
            if not is_black_tuning_enabled then
                wcolor[ 1 ], wcolor[ 2 ], wcolor[ 3 ] = 0, 0, 0
            end
            vehicle:SetWindowsColor( unpack( wcolor ) )
        end
    end
end
addEvent( "onVehiclePostLoad" )
addEventHandler( "onVehiclePostLoad", root, onVehiclePostLoad_handler )
