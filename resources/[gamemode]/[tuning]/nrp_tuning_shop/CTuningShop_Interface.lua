UI_elements = { }

function CreateInitialData( )
    if not _DATA_INITIALIZED then
        Extend( "CVehicle" )
        Extend( "ShVehicleConfig" )
        Extend( "CUI" )
        Extend( "ShUtils" )
        Extend( "ShNeons" )

        x, y = guiGetScreenSize()

        ANIM_MUL = 2

        MENU_STRUCTURE = {
            { name = "Винилы",              img = "vinyl.png",          allow_moto = true,      task = TUNING_TASK_VINYL },
            { name = "Внутренний тюнинг",   img = "parts.png",          allow_moto = true,      task = TUNING_TASK_PARTS },
            { name = "Внешний тюнинг",      img = "bodyparts.png",      allow_moto = false,     task = TUNING_TASK_BODYPARTS },
            { name = "Цвет кузова",         img = "color.png",          allow_moto = true,      task = TUNING_TASK_COLOR },
            { name = "Цвет фар",            img = "lightscolor.png",    allow_moto = true,      task = TUNING_TASK_LIGHTSCOLOR },
            { name = "Неон",                img = "neon.png",           allow_moto = false,     task = TUNING_TASK_NEON },
            { name = "Уровень тонировки",   img = "toning.png",         allow_moto = false,     task = TUNING_TASK_TONING },
            { name = "Колёса",              img = "wheels.png",         allow_moto = false,     task = TUNING_TASK_WHEELS },
            { name = "Изменение колёс",     img = "wheels_edit.png",    allow_moto = false,     task = TUNING_TASK_WHEELS_EDIT },
            { name = "Покраска дисков",     img = "wheels_color.png",   allow_moto = false,     task = TUNING_TASK_WHEELS_COLOR },
            --{ name = "Гидравлика",        img = "hydraulics.png",     allow_moto = true,      task = TUNING_TASK_HYDRAULICS },
            { name = "Занижение авто",      img = "suspension.png",     allow_moto = false,     task = TUNING_TASK_SUSPENSION },
            { name = "Номера",              img = "numbers.png",        allow_moto = false,     task = TUNING_TASK_NUMBERS },
            { name = "Черный рынок",        img = "blackmarket.png",    allow_moto = false,     task = TUNING_TASK_BLACKMARKET },
        }

        -- Худ с деньгами
        wHUD = { }
        wHUD.sx, wHUD.sy = 340, 55
        wHUD.px, wHUD.py = x - wHUD.sx - 20, 20

        -- Кнопка кейсов
        wCases = { }
        wCases.sx, wCases.sy = 340, 80
        wCases.px, wCases.py = wHUD.px + wHUD.sx / 2 - wCases.sx / 2, wHUD.py + wHUD.sy + 10

        -- Правая боковая панель - дефолтные настройки
        wSide = { }

        wSide.back_sy = 50
        wSide.sx = 340
        wSide.px, wSide.py = x - wSide.sx - 20, 20 + wHUD.sy + 20
        wSide.sy = y - wSide.py - 20 - wSide.back_sy

        -- Правая боковая панель - инвентарь
        wInventory = { }

        wInventory.back_sy = wSide.back_sy
        wInventory.sx = wSide.sx
        wInventory.sy = wSide.sy - 55 - 25
        wInventory.px, wInventory.py = wSide.px, wHUD.py + wHUD.sy + 100


        -- Нижняя панель - дефолтные настройки
        wBottom = { }

        local sx, sy = 699, 178
        local scale = x / 1280
        scale = scale > 1 and 1 or scale

        wBottom.scale = scale
        wBottom.sx, wBottom.sy = sx * scale, sy * scale

        wBottom.px = x / 2 - wBottom.sx / 2 - 50
        wBottom.py = y - wBottom.sy - 20
        wBottom.py_dragged = wBottom.py - 20 - wBottom.sy

        -- Нижняя панель - корзина
        wBottomCart = { }

        local sx, sy = 589, 70

        wBottomCart.scale = scale
        wBottomCart.sx, wBottomCart.sy = sx * scale, sy * scale

        wBottomCart.px = x / 2 - wBottomCart.sx / 2 - 50
        wBottomCart.py = y - wBottomCart.sy - 20
        wBottomCart.py_dragged = wBottomCart.py - 20 - wBottomCart.sy

        -- Сама корзина
        wCart = { }
        wCart.sx, wCart.sy = 600, 500
        wCart.px, wCart.py = x / 2 - wCart.sx / 2, y / 2 - wCart.sy / 2


        -- Боковая панель с деталями - дефолтные настройки
        wParts = { }
        wParts.sections = P_MAX_TYPES

        wParts.section_sx, wParts.section_sy = 90 * scale, 90 * scale
        wParts.gap = 11 * scale

        wParts.sy = wParts.sections * ( wParts.section_sy + wParts.gap ) - wParts.gap + 76
        wParts.px = 0
        wParts.py = y / 2 - wParts.sy / 2
        wParts.sx = wParts.section_sx + 200 * scale

        wParts.save_sx, wParts.save_sy = 90 * scale, 66 * scale

        -- Боковая панель с винилами - дефолтные настройки
        wVinyls = { }
        wVinyls.sections = 7.5

        wVinyls.section_sx, wVinyls.section_sy = 86 * scale, 86 * scale
        wVinyls.gap = 10 * scale

        wVinyls.sy = math.min( y - ( wVinyls.section_sy * 2 ), wVinyls.sections * ( wVinyls.section_sy + wVinyls.gap ) - wVinyls.gap )
        wVinyls.px = 0
        wVinyls.py = y / 2 - wVinyls.sy / 2 - wVinyls.section_sy / 2
        wVinyls.sx = wVinyls.section_sx + 200 * scale

        -- Меню настройки винила
        wSetttingMenu = {}
        wSetttingMenu.sx, wSetttingMenu.sy = 60 * scale, 438 * scale
        wSetttingMenu.px = x - (20 * scale) - wSetttingMenu.sx
        wSetttingMenu.py = 242 * scale
        wSetttingMenu.scale = scale

        -- Окно настроек цвета винила
        wSettingColor = {}
        wSettingColor.sx, wSettingColor.sy = 266 * scale, 395 * scale
        wSettingColor.px = x - (94 * scale) - wSettingColor.sx
        wSettingColor.py = 242 * scale
        wSettingColor.scale = scale

        -- Окно настройки поворота винила
        wSettingRotation = {}
        wSettingRotation.sx, wSettingRotation.sy = 266 * scale, 190 * scale
        wSettingRotation.px = x - (94 * scale) - wSettingRotation.sx
        wSettingRotation.py = 309 * scale
        wSettingRotation.scale = scale

        -- Окно настройки позиции винила
        wSettingPosition = {}
        wSettingPosition.sx, wSettingPosition.sy = 266 * scale, 295 * scale
        wSettingPosition.px = x - (94 * scale) - wSettingPosition.sx
        wSettingPosition.py = 376 * scale
        wSettingPosition.scale = scale

        -- Тултип внизу экрана
        wSettingHelpPosition = {}
        wSettingHelpPosition.sx, wSettingHelpPosition.sy = 304 * scale, 54 * scale
        wSettingHelpPosition.px = ( x - wSettingHelpPosition.sx ) / 2
        wSettingHelpPosition.py = y - wSettingHelpPosition.sy
        wSettingHelpPosition.scale = scale

        -- Окно настройки размера винила
        wSettingSize = {}
        wSettingSize.sx, wSettingSize.sy = 266 * scale, 190 * scale
        wSettingSize.px = x - (94 * scale) - wSettingSize.sx
        wSettingSize.py = 443 * scale
        wSettingSize.scale = scale

         -- Окно настройки размера винила
         wBottomVinylSell = {}
         wBottomVinylSell.sx, wBottomVinylSell.sy = sx * scale, sy * scale
         wBottomVinylSell.px = 60
         wBottomVinylSell.py = wVinyls.py + wVinyls.sy + wVinyls.gap
         wBottomVinylSell.scale = scale

        _DATA_INITIALIZED = true
    end
end

function isTuningUIOpen( )
    return getElementData( localPlayer, "isWithinTuning" )
end

function ShowTuningShopUI( state, data )

    CreateInitialData( )

    if state then
        ShowTuningShopUI( false )

        DATA = data
        DATA.position = Vector3( unpack( DATA.position_tbl ) )
        DATA.vehicle.frozen = true
        DATA.vehicle:SetVariant( DATA.variant )
        DATA.is_moto = VEHICLE_CONFIG[ DATA.vehicle.model ].is_moto
        DATA.current_tier = DATA.vehicle:GetTier( )

        local convertedData = { }
        for tier, parts in pairs( DATA.all_parts or { } ) do
            convertedData[ tier ] = { }

            for _, id in pairs( parts ) do
                local part = getTuningPartByID( id, tier )

                if part then
                    if convertedData[ tier ][ part.id ] then
                        convertedData[ tier ][ part.id ].amount = ( convertedData[ tier ][ part.id ].amount or 1 ) + 1
                    else
                        convertedData[ tier ][ part.id ] = part
                    end
                end
            end
        end
        DATA.all_parts = convertedData

        DisableHUD( true )
        setElementData( localPlayer, "isWithinTuning", true, false )

        -- Создать машину
        CreateMap( )
        CreatePreview( )
        StartPreview( )

        UI_elements.music = playSound( "sfx/music_tuning.ogg", true )
        UI_elements.music.volume = 0.2

        UI_elements.main_timer = setTimer(
            function()

                showCursor( true )

                -- HUD
                CreateHUD( )
                HideHUD( true )
                ShowHUD( )
                
                -- Кнопка кейсов для запчастей
                CreateCases( )
                HideCases( true )

                -- Кнопка кейсов для винилов
                CreateVinylCases()
                HideVinylCases( true )

                -- Создание сайдбара и показ с анимацией
                CreateSidebar( )
                HideSidebar( true )
                ShowSidebar( )

                -- Создать базовое меню
                InitMenuTree( )

                -- Кнопка "назад" и анимация
                CreateBackButton( )
                HideBackButton( true )
                ShowBackButton( )

                -- Нижняя панель по машинке
                CreateBottombar( )
                HideBottombar( true )
                ShowBottombar( )

                -- Нижнее меню корзины
                CreateBottomCart( )
                HideBottomCart( true )

            end
        , 500, 1 )
    else
        DestroyMap( )
        StopPreview( )
        showCursor( false )
        DisableHUD( false )
        setElementData( localPlayer, "isWithinTuning", false, false )

        for i, v in pairs( UI_elements or { } ) do
            if isTimer( v ) then killTimer( v ) end
            if isElement( v ) then destroyElement( v ) end
        end

        UI_elements = { }

		if DATA and DATA.vehicle then
            -- Фикс багающейся подвески на некоторых тс
            local vehicle = DATA.vehicle
			vehicle.frozen = true
            local b = vehicle:GetHydraulics( )
            vehicle:ApplyHydraulics( not b )
            setTimer( function( )
                if not isElement( vehicle ) then return end
                vehicle:ApplyHydraulics( b )
                vehicle.frozen = false
            end, 50, 1 )
            -- resetVehicleParameters( DATA.vehicle )
		end

        DATA = nil
    end

end
addEvent( "ShowTuningShopUI", true )
addEventHandler( "ShowTuningShopUI", root, ShowTuningShopUI )
