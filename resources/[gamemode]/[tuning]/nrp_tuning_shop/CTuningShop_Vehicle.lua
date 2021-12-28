function RepositionPreviewVehicles( )
    if isElement( UI_elements.fake_vehicle ) then
        UI_elements.fake_vehicle.dimension = 1
        UI_elements.fake_vehicle.position = DATA.position + Vector3( 0.110, -1.690, 0.420 )
        UI_elements.fake_vehicle.rotation = Vector3( 0, 0, 90 )
    end

    if isElement( UI_elements.vehicle ) then
        UI_elements.vehicle.dimension = 1
        UI_elements.vehicle.position = DATA.position + Vector3( 0, 10, 0.5 )
        UI_elements.vehicle.rotation = Vector3( 0, 0, 0 )
    end
end

function CreatePreview( )
    DestroyPreview( )

    local data = DATA

    local vehicle = data.vehicle

    UI_elements.fake_vehicle = Vehicle( 541, 0, 0, 0, 0, 0, 0 )
    UI_elements.fake_vehicle:SetColor( 255, 150, 0 )

    local temp_vehicle = Vehicle( vehicle.model, 0, 0, 0, 0, 0, 0 )
    --temp_vehicle.interior = 1
    setVehicleOverrideLights( temp_vehicle, 2 )

    -- Установка параметров
    if data.element_data then
        for i, v in pairs( data.element_data ) do
            temp_vehicle:setData( i, v, false )
        end
    end

    -- Цвет машины
    temp_vehicle:SetColor( unpack( data.color ) )
    RefreshDefaultColor( data.color )

    -- Фары
    if data.headlights_color then
        local r, g, b = unpack( data.headlights_color or { } )
        if r and g and b then
            temp_vehicle:SetHeadlightsColor( r, g, b )
        end
    end

    -- Гидравлика
    if data.hydraulics then
        temp_vehicle:SetHydraulics( data.hydraulics )
    end

    -- Колёса
    if data.wheels and data.wheels ~= 0 then
        temp_vehicle:SetWheels( data.wheels )
    end

    -- Ширина колес
    temp_vehicle:SetWheelsWidth( vehicle:GetWheelsWidth( ) )

    -- Вылет колес
    temp_vehicle:SetWheelsOffset( vehicle:GetWheelsOffset( ) )

    -- Развал колес
    temp_vehicle:SetWheelsCamber( vehicle:GetWheelsCamber( ) )

    if data.wheels_color then
        local r, g, b = unpack( data.wheels_color or { 255, 255, 255 } )
        if r and g and b then
            temp_vehicle:SetWheelsColor( r, g, b )
        end
    end

    -- Высота машины
    if data.height_level and data.height_level > 0 then
        temp_vehicle:SetHeightLevel( data.height_level )
    end

    -- Variant
    temp_vehicle:SetVariant( vehicle:GetVariant( ) )

    -- Неон
    temp_vehicle:SetNeon( data.neon_image )

    -- Всякая дрочь
    UI_elements.vehicle = temp_vehicle
    UI_elements.fake_vehicle.frozen = true

    Timer( function ( )
        if not isElement( UI_elements.vehicle ) then return end
        UI_elements.vehicle.frozen = true
    end, 2000, 1 )

    RepositionPreviewVehicles( )
    InitialaziVinylController()
    RefreshDefaultColor( data.color )
    RefreshVehicleVinyl( DATA.installed_vinyls )
end

function StartPreview( )
    StopPreview( )
    if isElement( UI_elements.vehicle ) then
        fadeCamera( false, 0 )
        --localPlayer.interior = 1
        localPlayer.dimension = 1
        localPlayer:setData( "cam_target", UI_elements.vehicle, false )
        setWeather( 0 )
        setTime( 22, 0 )

        RepositionPreviewVehicles( )
        UI_elements.vehicle.frozen = false
        UI_elements.fake_vehicle.frozen = false

        setTimer( function( )
            RepositionPreviewVehicles( )
        end, 500, 1 )

        setTimer( function( )
            fadeCamera( true, 2 )
            RepositionPreviewVehicles( )
        end , 500, 1 )
    end
end

function StopPreview( )
    if localPlayer:getData( "cam_target" ) then
        fadeCamera( false, 0 )
        setTimer( fadeCamera, 50, 1, true )
        --localPlayer.interior = 0
        localPlayer.dimension = 0
        localPlayer:setData( "cam_target", false, false )
        setCameraTarget( localPlayer )
        triggerServerEvent( "onGameTimeRequest", localPlayer )
    end
end

function DestroyPreview( )
    if isElement( UI_elements.vehicle ) then destroyElement( UI_elements.vehicle ) end
    if isElement( UI_elements.fake_vehicle ) then destroyElement( UI_elements.fake_vehicle ) end
end

-- Очистка машины при удалении предмета из корзины
function onTuningShopCartRemove_PreviewHandler( class, value, ignore_vehicle_changes )
    if ignore_vehicle_changes then return end

    -- Цвет машины
    if class == TUNING_TASK_COLOR then
        UI_elements.vehicle:SetColor( unpack( DATA.color ) )
        RefreshDefaultColor( DATA.color )
        RefreshVehicleVinyl( DATA.installed_vinyls )
        
    -- Цвет фар
    elseif class == TUNING_TASK_LIGHTSCOLOR then
        UI_elements.vehicle:SetHeadlightsColor( DATA.vehicle:getHeadLightColor() )

    -- Уровень тонировки
    elseif class == TUNING_TASK_TONING then
        local toning_alpha = DATA.vehicle:GetWindowsColor()[ 4 ]
        local toning = UI_elements.vehicle:GetWindowsColor()
        toning[ 4 ] = toning_alpha
        UI_elements.vehicle:SetWindowsColor( unpack( toning ) )

    -- Колёса
    elseif class == TUNING_TASK_WHEELS then
        local wheels = DATA.vehicle:GetWheels()
        UI_elements.vehicle:SetWheels( wheels )
        iprint( wheels )
        if not wheels or wheels == 0 then
            CartRemove( TUNING_TASK_WHEELS_EDIT )
            if LAST_MENU_TASK == TUNING_TASK_WHEELS_EDIT then
                GoBack( )
            end
        else
            if not CartIsAdded( TUNING_TASK_WHEELS_EDIT ) then
                onTuningShopCartRemove_PreviewHandler( TUNING_TASK_WHEELS_EDIT )
            end
            if not CartIsAdded( TUNING_TASK_WHEELS_COLOR ) then
                onTuningShopCartRemove_PreviewHandler( TUNING_TASK_WHEELS_COLOR )
            end
        end

    -- Изменение колес
    elseif class == TUNING_TASK_WHEELS_EDIT then
        UI_elements.vehicle:SetWheelsWidth( DATA.vehicle:GetWheelsWidth( ) )
        UI_elements.vehicle:SetWheelsOffset( DATA.vehicle:GetWheelsOffset( ) )
        UI_elements.vehicle:SetWheelsCamber( DATA.vehicle:GetWheelsCamber( ) )
    
    elseif class == TUNING_TASK_WHEELS_COLOR then
        UI_elements.vehicle:SetWheelsColor( DATA.vehicle:GetWheelsColor() )

    -- Номера
    elseif class == TUNING_TASK_NUMBERS then
        UI_elements.vehicle:SetNumberPlate( DATA.vehicle:GetNumberPlate( false, true ) )

    -- Гидравлика и ысота подвески
    elseif class == TUNING_TASK_HYDRAULICS or class == TUNING_TASK_SUSPENSION then
        UI_elements.vehicle:SetHeightLevel( DATA.height_level )
        UI_elements.vehicle:SetHydraulics( DATA.vehicle:GetHydraulics() )

    -- Компонентный тюнинг
    elseif TUNING_IDS[ class ] then
        local component_id = TUNING_IDS[ class ]
        local this_component = DATA.vehicle:GetExternalTuningValue( component_id )
        UI_elements.vehicle:SetExternalTuningValue( component_id, this_component )

    end
end
addEvent( "onTuningShopCartRemove", true )
addEventHandler( "onTuningShopCartRemove", root, onTuningShopCartRemove_PreviewHandler )

function onBlackTuningResetCallback_handler( alpha )
    UI_elements.vehicle:SetWindowsColor( 0, 0, 0, alpha )
	UI_elements.vehicle:SetNumberPlate( UI_elements.vehicle:GetNumberPlate() )
end
addEvent( "onBlackTuningResetCallback", true )
addEventHandler( "onBlackTuningResetCallback", root, onBlackTuningResetCallback_handler )

function onTuningPreviewChangeNeon_handler( neon_image )
    UI_elements.vehicle:SetNeon( neon_image )
    DATA.neon_image = neon_image
end
addEvent( "onTuningPreviewChangeNeon", true )
addEventHandler( "onTuningPreviewChangeNeon", root, onTuningPreviewChangeNeon_handler )

function onTuningChangeOriginalColor_handler( color )
    UI_elements.vehicle:SetColor( unpack( color ) )
    DATA.color = color
end
addEvent( "onTuningChangeOriginalColor", true )
addEventHandler( "onTuningChangeOriginalColor", resourceRoot, onTuningChangeOriginalColor_handler )


function onTuningChangeWheelsColor_handler( color )
    UI_elements.vehicle:SetWheelsColor( unpack( color ) )
    DATA.wheels_color = color
end
addEvent( "onTuningChangeWheelsColor", true )
addEventHandler( "onTuningChangeWheelsColor", resourceRoot, onTuningChangeWheelsColor_handler )