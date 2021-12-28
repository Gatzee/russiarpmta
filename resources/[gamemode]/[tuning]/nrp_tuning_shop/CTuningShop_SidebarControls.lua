
BLOCKED_VINYL_VEHICLES =
{
    -- [ 477 ] = true, -- под вопросом
    -- [ 560 ] = true, -- под вопросом
    -- [ 575 ] = true, -- под вопросом
    -- [ 596 ] = true, -- под вопросом
    -- [ 600 ] = true, -- под вопросом
    [ 6551 ] = true,
    [ 6552 ] = true,
    [ 6553 ] = true,
    [ 6591 ] = true,
}

LAST_MENU_TASK = nil
PREVIEW_COLOR = nil

function ParseMenuNavigation( menu )
    --iprint( "parsed", menu )
    local task = menu.task
    LAST_MENU_TASK = task

    -- "Установка деталей"
    if task == TUNING_TASK_PARTS then
        HideSidebar( )

        -- Инвентарь и магазин
        CreateInventory( )
        HideInventory( true )
        ShowInventory( )

        -- Продажа деталей
        CreatePartsSell( )
        HidePartsSell( true )
        ShowPartsSell( )

        -- Левая панель с деталями
        CreatePartsMenu( )
        HidePartsMenu( true )
        ShowPartsMenu( )

        -- Кнопка кейсов
        HideCases( true )
        ShowCases( )

        SetBackButtonGoHome( )

    -- Цвет автомобиля
    elseif task == TUNING_TASK_COLOR then
        local blocked_color = {
            [ 6551 ] = true,
            [ 6552 ] = true,
            [ 6553 ] = true,
            [ 6591 ] = true,
        }

        if blocked_color[ DATA.vehicle.model ] then
            localPlayer:ErrorWindow( "Для этого транспорта нет возможности перекраски" )
            return
        end

        HideBottombar( true )
        HideSidebar( )

        local onCancel = function( )
            UI_elements.vehicle:SetColor( unpack( PREVIEW_COLOR or DATA.color ) )
            RefreshDefaultColor( PREVIEW_COLOR or DATA.color )
            RefreshVehicleVinyl( DATA.installed_vinyls )

            DestroyColorpicker( )
            ShowSidebar( )
            ResetBackButton( )
            ShowBottombar( )
        end

        CreateColorpicker(
            DATA,
            {
                title = "Цвет автомобиля",
                OnChange = function( r, g, b )
                    UI_elements.vehicle:SetColor( r, g, b )
                    RefreshDefaultColor( { r, g, b } )
                    RefreshVehicleVinyl( DATA.installed_vinyls )
                end,
                OnApply = function( r, g, b )
                    UI_elements.vehicle:SetColor( r, g, b )
                    RefreshDefaultColor( { r, g, b } )
                    RefreshVehicleVinyl( DATA.installed_vinyls )

                    DestroyColorpicker( )
                    ShowSidebar( )
                    ResetBackButton( )

                    -- Добавляем в корзину
                    CartRemove( TUNING_TASK_COLOR, nil,true )
                    CartAdd( TUNING_TASK_COLOR, { r, g, b } )

                    PREVIEW_COLOR = { r, g, b }
                end,
                OnCancel = onCancel,
            }
        )
        HideColorpicker( true )
        ShowColorpicker( )

        SetBackButtonFunction( onCancel )

    elseif task == TUNING_TASK_LIGHTSCOLOR then
        HideBottombar( true )
        HideSidebar( )

        local r, g, b = UI_elements.vehicle:getHeadLightColor( )

        local onCancel = function( )
            UI_elements.vehicle:SetHeadlightsColor( r, g, b )
            DestroyColorpicker( )
            ShowSidebar( )
            ResetBackButton( )
            ShowBottombar( )
        end

        CreateColorpicker(
            DATA,
            {
                title = "Цвет фар",
                OnChange = function( r, g, b )
                    UI_elements.vehicle:SetHeadlightsColor( r, g, b )
                end,
                OnApply = function( r, g, b )
                    UI_elements.vehicle:SetHeadlightsColor( r, g, b )
                    DestroyColorpicker( )
                    ShowSidebar( )
                    ResetBackButton( )

                    -- Добавляем в корзину
                    CartRemove( TUNING_TASK_LIGHTSCOLOR )
                    CartAdd( TUNING_TASK_LIGHTSCOLOR, { r, g, b } )
                end,
                OnCancel = onCancel,
            }
        )
        HideColorpicker( true )
        ShowColorpicker( )

        SetBackButtonFunction( onCancel )

    -- Генерация вариантов тонировки
    elseif task == TUNING_TASK_TONING then
        local blocked_toning = {
            [ 6553 ] = true,
            [ 6591 ] = true,
        }
        if blocked_toning[ DATA.vehicle.model ] then
            localPlayer:ErrorWindow( "Для этого транспорта нет возможности изменить тонировку" )
            return
        end

        HideBottombar( true )
        IS_HOME_MENU = false

        local this_alpha = DATA.vehicle:GetWindowsColor( )[ 4 ]
        local values = {
            name = "Уровень тонировки",
            { name = "Сток", value = 120 },
            { name = "25%", value = 150 },
            { name = "50%", value = 180 },
            { name = "75%", value = 220 },
            { name = "100%", value = 250 },
        }
        for i, v in ipairs( values ) do
            v.task = TUNING_TASK_TONING_PURCHASE
            if v.value == this_alpha then v.selected = true end
        end
        CreateList( values, true )
        SetBackButtonGoHome( )

    elseif task == TUNING_TASK_TONING_PURCHASE then
        local windows_color = DATA.vehicle:GetWindowsColor( )
        local this_alpha = windows_color[ 4 ]
        CartRemove( TUNING_TASK_TONING )
        if menu.value ~= this_alpha then
            CartAdd( TUNING_TASK_TONING, menu.value )
            windows_color[ 4 ] = menu.value
            UI_elements.vehicle:SetWindowsColor( unpack( windows_color ) )
        end


    elseif task == TUNING_TASK_WHEELS then
        local blocked_wheels = {
            [ 458 ] = true,
            [ 6591 ] = true,
            [ 503 ] = true, -- Пропадают стоковые колёса, если снять кастомные
        }

        if blocked_wheels[ DATA.vehicle.model ] then
            localPlayer:ErrorWindow( "Для этого транспорта нет возможности купить новые колёса" )
            return
        end

        HideBottombar( true )
        IS_HOME_MENU = false

        local this_wheels = DATA.vehicle:GetWheels()
        local values = { name = "Колёса", { name = "Сток", value = false}, }
        for i, v in pairs( TUNING_PARAMS[ TUNING_TASK_WHEELS ] ) do
            if v.Level and v.Level > 1 then
                table.insert( values, { name = v.Name, value = v.Level } )
            end
        end
        for i, v in ipairs( values ) do
            v.task = TUNING_TASK_WHEELS_PURCHASE
            if v.value == this_wheels then v.selected = true end
        end
        CreateList( values, true )
        SetBackButtonGoHome( )

    elseif task == TUNING_TASK_WHEELS_PURCHASE then
        HideBottombar( true )
        IS_HOME_MENU = false

        local this_wheels = DATA.vehicle:GetWheels() or false
        CartRemove( TUNING_TASK_WHEELS, nil, DATA.vehicle:GetWheels() ~= menu.value )
        UI_elements.vehicle:SetWheels( menu.value )

        if menu.value ~= this_wheels then
            CartAdd( TUNING_TASK_WHEELS, menu.value )

            -- Сбрасываем измененные настройки при смене колёс
            local front_width, rear_width = UI_elements.vehicle:GetWheelsWidth( )
            local front_camber, rear_camber = UI_elements.vehicle:GetWheelsCamber( )
            local front_offset, rear_offset = UI_elements.vehicle:GetWheelsOffset( )
            local r, g, b = UI_elements.vehicle:GetWheelsColor( )
            local is_wheels_changed = ( front_width + rear_width + front_camber + rear_camber + front_offset + rear_offset ) > 0 or (r)
            if is_wheels_changed and ( menu.value == false or not CartIsAdded( TUNING_TASK_WHEELS_EDIT ) ) then
                if menu.value == false then
                    CartRemove( TUNING_TASK_WHEELS_EDIT )
                end
                UI_elements.vehicle:SetWheelsWidth( 0 )
                UI_elements.vehicle:SetWheelsOffset( 0 )
                UI_elements.vehicle:SetWheelsCamber( 0 )
                UI_elements.vehicle:SetWheelsColor()
                localPlayer:InfoWindow( "Изменения колес сбросятся до базовых значений" )
            end
        else
            if not CartIsAdded( TUNING_TASK_WHEELS_EDIT ) then
                onTuningShopCartRemove_PreviewHandler( TUNING_TASK_WHEELS_EDIT )
            end
            if not CartIsAdded( TUNING_TASK_WHEELS_COLOR ) then
                onTuningShopCartRemove_PreviewHandler( TUNING_TASK_WHEELS_COLOR )
            end
        end
        exports.nrp_vehicle_wheels:UpdateVehicleWheelsStuff( )

    elseif task == TUNING_TASK_WHEELS_EDIT then
        if ( UI_elements.vehicle:GetWheels() or 0 ) == 0 then
            localPlayer:InfoWindow( "Изменение доступно только для кастомных колес" )
            return
        end

        HideBottombar( true )
        HideSidebar( )
        IS_HOME_MENU = false

        CreateWheelsEditor( )
        HideWheelsEditor( true )
        ShowWheelsEditor( )

        SetBackButtonGoHome( )

    elseif task == TUNING_TASK_WHEELS_COLOR then
        if ( UI_elements.vehicle:GetWheels() or 0 ) == 0 then
            localPlayer:InfoWindow( "Покраска доступна только для кастомных колес" )
            return
        end

        HideBottombar( true )
        HideSidebar( )

        local onCancel = function( )
            UI_elements.vehicle:SetWheelsColor( DATA.vehicle:GetWheelsColor() )

            DestroyColorpicker( )
            ShowSidebar( )
            ResetBackButton( )
            ShowBottombar( )
        end

        CreateColorpicker(
            DATA,
            {
                title = "Цвет дисков",
                OnChange = function( r, g, b )
                    UI_elements.vehicle:SetWheelsColor( r, g, b )
                    exports.nrp_vehicle_wheels:UpdateVehicleWheelsStuff( )
                end,
                OnApply = function( r, g, b )
                    UI_elements.vehicle:SetWheelsColor( r, g, b )

                    DestroyColorpicker( )
                    ShowSidebar( )
                    ResetBackButton( )

                    -- Добавляем в корзину
                    CartRemove( TUNING_TASK_WHEELS_COLOR, nil,true )
                    CartAdd( TUNING_TASK_WHEELS_COLOR, { r, g, b } )
                end,
                OnCancel = onCancel,
            }
        )
        HideColorpicker( true )
        ShowColorpicker( )

        SetBackButtonFunction( onCancel )

    elseif task == TUNING_TASK_NUMBERS_PURCHASE then
        CartRemove( TUNING_TASK_NUMBERS )

        local sOldNumber = DATA.vehicle:GetNumberPlate()

        if sOldNumber == menu.value[1] then
            localPlayer:ShowError("Это твой текущий номер!")
            return
        end

        local sFullNumber = UI_elements.vehicle:GetNumberPlate( false, true )
        local pOldNumber = split( sFullNumber, ":" )
        local sColor = ""

        if #pOldNumber >= 3 then
            sColor = pOldNumber[1]..":"
        end

        UI_elements.vehicle:SetNumberPlate( sColor..menu.value[1] )

        CartAdd( TUNING_TASK_NUMBERS, menu.value )
    -- Гидравлика
    elseif task == TUNING_TASK_HYDRAULICS then
        local this_hydraulics = DATA.vehicle:GetHydraulics( )
        local values = {
            name = "Гидравлика",
            { name = "Сток",                    value = false },
            { name = "Гидравлическая подвеска", value = true },
        }
        for i, v in ipairs( values ) do
            v.task = TUNING_TASK_HYDRAULICS_PURCHASE
            if v.value == this_hydraulics then v.selected = true end
        end
        CreateList( values, true )
        SetBackButtonGoHome( )

    elseif task == TUNING_TASK_HYDRAULICS_PURCHASE then
        local this_hydraulics = DATA.vehicle:GetHydraulics( )
        CartRemove( TUNING_TASK_SUSPENSION )
        CartRemove( TUNING_TASK_HYDRAULICS )
        UI_elements.vehicle:SetHeightLevel( 0 )
        UI_elements.vehicle:SetHydraulics( menu.value )
        if menu.value ~= this_hydraulics then
            CartAdd( TUNING_TASK_HYDRAULICS, menu.value )
        end

    -- Высота подвески
    elseif task == TUNING_TASK_SUSPENSION then
        local blocked_models = { 
            [ 6542 ] = true,
            [ 6539 ] = true,
            [ 6567 ] = true,
            [ 567 ] = true,
        }
        if blocked_models[ DATA.vehicle.model ] then
            localPlayer:ErrorWindow( "Изменение подвески запрещено для этой машины!" )
            return
        end

        HideBottombar( true )
        IS_HOME_MENU = false

        local this_suspension = DATA.height_level or 0
        local values = {
            name = "Высота подвески",
            --{ name = "Заниженная",              value = 1 },
            { name = "Сток",                    value = 0 },
            { name = "Высокая посадка",         value = 2 },
            { name = "Гидравлическая подвеска", value = true, task = TUNING_TASK_HYDRAULICS_PURCHASE }
        }
        for i, v in ipairs( values ) do
            v.task = v.task or TUNING_TASK_SUSPENSION_PURCHASE
            if v.value == this_suspension then v.selected = true end
        end
        CreateList( values, true )
        SetBackButtonGoHome( )

    elseif task == TUNING_TASK_SUSPENSION_PURCHASE then
        local this_suspension = DATA.height_level or 0
        local this_hydraulics = DATA.vehicle:GetHydraulics( )
        CartRemove( TUNING_TASK_HYDRAULICS )
        CartRemove( TUNING_TASK_SUSPENSION )
        UI_elements.vehicle:SetHydraulics( false )
        UI_elements.vehicle:SetHeightLevel( menu.value )
        if menu.value ~= this_suspension or this_hydraulics then
            CartAdd( TUNING_TASK_SUSPENSION, menu.value )
        end

    -- Внешний тюнинг
    elseif task == TUNING_TASK_BODYPARTS then
        local vehicle_model = getElementModel( UI_elements.vehicle )
        local components = VEHICLE_CONFIG[ vehicle_model ] and VEHICLE_CONFIG[ vehicle_model ].custom_tuning
        
        local visible_elements = 0
        for k, v in pairs( components or { } ) do
            if not v.hidden then
                visible_elements = visible_elements + 1
                break
            end
        end

        if components and next( components ) and visible_elements ~= 0 then
            local values = { name = "Внешний тюнинг" }
            for component_name, components_list in pairs( components ) do
                local component_id = TUNING_IDS[ component_name ]
                local component_human_name = TUNING_PARTS_NAMES[ component_id ]
                if not components_list.hidden then
                    table.insert( values,
                        {
                            name = component_human_name,
                            value =  component_name,
                            task = TUNING_TASK_BODYPARTS_LIST,
                        }
                    )
                end
            end
            CreateList( values, true )

            SetBackButtonGoHome( )
            HideBottombar( true )
            IS_HOME_MENU = false
        else
            localPlayer:ErrorWindow( "Для этого транспорта пока нет внешнего тюнинга" )
            return
        end

    elseif task == TUNING_TASK_BODYPARTS_LIST then
        local vehicle_model = getElementModel( UI_elements.vehicle )
        local component_name = menu.value
        local component_id = TUNING_IDS[ component_name ]
        local components = VEHICLE_CONFIG[ vehicle_model ] and VEHICLE_CONFIG[ vehicle_model ].custom_tuning
        local components_list = components[ component_name ]

        local values = { name = menu.name }
        for i, v in pairs( components_list ) do
            if type( v ) == "table" then
                table.insert( values,
                    {
                        name = v.name,
                        value = i,
                        component_name = component_name,
                        component_id = component_id,
                        task = TUNING_TASK_BODYPARTS_LIST_PURCHASE,
                    }
                )
            end
        end
        CreateList( values, true )
        SetBackButtonFunction( function()
            ParseMenuNavigation( { task = TUNING_TASK_BODYPARTS } )
        end )

    elseif task == TUNING_TASK_BODYPARTS_LIST_PURCHASE then
        local vehicle_model = getElementModel( UI_elements.vehicle )
        local component_name = menu.component_name
        local components = VEHICLE_CONFIG[ vehicle_model ] and VEHICLE_CONFIG[ vehicle_model ].custom_tuning
        local components_list = components[ component_name ]

        local this_component = DATA.vehicle:GetExternalTuningValue( menu.component_id )
        -- Если имеется стоковый компонент
        if not this_component then
            if components_list[ 1 ].stock then
                this_component = 1
            end
        end
        CartRemove( menu.component_name )
        UI_elements.vehicle:SetExternalTuningValue( menu.component_id, menu.value )
        if menu.value ~= this_component then
            CartAdd( menu.component_name, menu.value )
        end

    -- Черный тюнинг
    elseif task == TUNING_TASK_BLACKMARKET then
        if not DATA.subscription then
            localPlayer:ErrorWindow( "Черный рынок доступен только владельцам премиум аккаунта!", "ОШИБКА" )
            return
        end
        if not DATA.is_subscription_vehicle then
            localPlayer:ErrorWindow( "Черный рынок доступен только для выбранной машины в премиуме!", "ОШИБКА" )
            return
        end
        if VEHICLES_NO_NUMBERPLATES[ UI_elements.vehicle.model ] then
            localPlayer:ErrorWindow( "Черный тюнинг не доступен для этой машины" )
            return
        end

        HideBottombar( true )
        IS_HOME_MENU = false

        local values = {
            name = "Черный рынок",
            { name = "Цвет номеров",                task = TUNING_TASK_BLACKMARKET_PLATECOLOR },
            { name = "Цвет тонировки",              task = TUNING_TASK_BLACKMARKET_TONING },
            { name = "Сбросить весь черный тюнинг", task = TUNING_TASK_BLACKMARKET_RESET },

        }
        CreateList( values, true )
        SetBackButtonGoHome( )

    -- Цвет номеров
    elseif task == TUNING_TASK_BLACKMARKET_PLATECOLOR then
        HideSidebar( )
        
        local onCancel = function( )
            DestroyColorlist( )

            ShowSidebar( )
            SetBackButtonGoHome( )
        end

        CreateColorlist(
            DATA,
            {
                title = "Цвет номеров",
                OnChange = function( r, g, b )
                    local color = rgb2hex( { r, g, b }, true )
                    --iprint( "Change to", color )
                    UI_elements.vehicle:ApplyNumberPlateColor( color )
                    triggerServerEvent( "onNumberplateColorApplyRequest", resourceRoot, color )
                end,
            }
        )
        HideColorlist( true )
        ShowColorlist( )

        SetBackButtonFunction( onCancel )
    -- Номера
    elseif task == TUNING_TASK_NUMBERS then
        if VEHICLES_NO_NUMBERPLATES[ UI_elements.vehicle.model ] then
            localPlayer:ErrorWindow( "Номера не доступны для этой машины" )
            return
        end

        HideBottombar( true )
        HideSidebar( )
        IS_HOME_MENU = false

        -- Инвентарь и магазин
        CreateNumbersList( )
        HideNumbersList( true )
        ShowNumbersList( )

        SetBackButtonGoHome( )
    -- Цвет тонировки
    elseif task == TUNING_TASK_BLACKMARKET_TONING then
        HideSidebar( )
        local r, g, b, a = unpack( UI_elements.vehicle:GetWindowsColor( ) )

        local onCancel = function( )
            UI_elements.vehicle:SetWindowsColor( r, g, b, a )
            DestroyColorpicker( )
            ShowSidebar( )
            SetBackButtonGoHome( )
        end

        local brightness_mod = 0.4
        CreateColorpicker(
            DATA,
            {
                title = "Цвет тонировки",
                OnChange = function( r, g, b )
                    UI_elements.vehicle:SetWindowsColor( r * brightness_mod, g * brightness_mod, b * brightness_mod, a )
                end,
                OnApply = function( r, g, b )
                    UI_elements.vehicle:SetWindowsColor( r * brightness_mod, g * brightness_mod, b * brightness_mod, a )
                    DestroyColorpicker( )
                    ShowSidebar( )
                    SetBackButtonGoHome( )

                    triggerServerEvent( "onWindowsColorApplyRequest", resourceRoot, r * brightness_mod, g * brightness_mod, b * brightness_mod, a )
                end,
                OnCancel = onCancel,
            }
        )
        HideColorpicker( true )
        ShowColorpicker( )

        SetBackButtonFunction( onCancel )

    -- Сброс черного тюнинга
    elseif task == TUNING_TASK_BLACKMARKET_RESET then
        local r_, g_, b_, a_ = unpack( UI_elements.vehicle:GetWindowsColor( ) ) 
        UI_elements.vehicle:SetWindowsColor( 0, 0, 0, a_ )
        
        triggerServerEvent( "onBlackTuningResetRequest", resourceRoot, a_ )        

    -- Установка винилов
    elseif task == TUNING_TASK_VINYL then
        if BLOCKED_VINYL_VEHICLES[ DATA.vehicle.model ] then
            localPlayer:ErrorWindow( "Для этого транспорта нет возможности установить винил" )
            return
        else
            HideBottombar( true )
            HideSidebar( )
            IS_HOME_MENU = false

            -- Кнопка кейсов с винилами
            HideVinylCases( true )
            ShowVinylCases( )

            -- Продажа винилов
            CreateVinylsSell( )
            HideVinylsSell( true )
            ShowVinylsSell( )

            -- Левая панель с слоями
            CreateVinylsMenu( )
            HideVinylsMenu( true )
            ShowVinylsMenu( )

            --Панель с стилеями, инвентарём
            CreateVinylInventory( )
            HideVinylInventory( true )
            ShowVinylInventory( )

            SetBackButtonGoHome( )
        end


    elseif task == TUNING_TASK_NEON then
        local vehicle = UI_elements.vehicle
        local variant = vehicle:GetVariant( )

        if vehicle:GetTier( variant ) <= 3 then
            localPlayer:ErrorWindow( "Неоны доступны только для машин D и S класса!" )
        else
            HideSidebar( )
            HideBottombar( )
            
            -- Инвентарь и магазин
            CreateNeonsList( )
            HideNeonsList( true )
            ShowNeonsList( )

            SetBackButtonGoHome( )
        end
    end

end
