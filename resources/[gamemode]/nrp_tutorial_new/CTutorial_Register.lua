local UI

ibUseRealFonts( true )

function ShowCharacterSelectionUI_handler( state )
    if state then
        ShowCharacterSelectionUI_handler( false )

        UI = { }

        UI.black_bg = ibCreateBackground( 0, false, true )
        
        -------------
        -- Оверлей --
        -------------

        local show_duration = 2500
        local last_click = 0
        --local friction_length = 100
        --local friction_duration = 2500
        local overlay_px = _SCREEN_X - 620
        UI.overlay = ibCreateImage( _SCREEN_X, 0, 620, _SCREEN_Y, "img/bg_register.png", UI.black_bg )
            :ibMoveTo( overlay_px, _, show_duration, "OutQuad" )
            --[[:ibTimer( function( self )
                local fns = { }

                fns.GoLeft = function( )
                    self:ibMoveTo( overlay_px, _, friction_duration, "InOutQuad" )
                    self:ibTimer( fns.GoRight, friction_duration, 1 )
                end

                fns.GoRight = function( )
                    self:ibMoveTo( overlay_px + friction_length, _, friction_duration, "InOutQuad" )
                    self:ibTimer( fns.GoLeft, friction_duration, 1 )
                end

                fns.GoRight( )
            end, show_duration ,1 )]]


        UI.area = ibCreateArea( _SCREEN_X, 0, _SCREEN_X, 445, UI.black_bg )

        ibCreateLabel( _SCREEN_X - 60, 0, 0, 0, "ВЫБОР ПЕРСОНАЖА", UI.area, COLOR_WHITE, 1, 1, "right", "top", ibFonts.bold_30 )

        local function CleanError( )
            if isElement( UI.error_area ) then destroyElement( UI.error_area ) end
            UI.error_area = nil
        end

        local function shake( element )
            local diff      = 5
            local speed     = 50
            local base_pos  = element:ibData( "px" )
            local right_pos = base_pos + diff
            local left_pos  = base_pos - diff
            
            UI.error_area
                :ibMoveTo( left_pos, _, speed )
                :ibTimer( function( self )
                    self:ibMoveTo( right_pos, _, speed )
                end, speed, 1 )
                :ibTimer( function( self )
                    self:ibMoveTo( base_pos, _, speed )
                end, speed * 2, 1 )
        end

        local function Error( text, shake_element )
            CleanError( )
            ibError( )

            UI.error_area = ibCreateArea( _SCREEN_X - 290, 324, 230, 0, UI.area )
            local icon = ibCreateImage( 0, 0, 18, 18, "img/icon_info.png", UI.error_area )

            ibCreateLabel( icon:ibGetAfterX( 8 ), 0, 190, 0, text, UI.error_area, ibApplyAlpha( 0xffffd892, 75 ), _, _, _, _, ibFonts.regular_14 ):ibData( "wordbreak", true )
        
            shake( UI.error_area )
        end

        -----------------
        -- Выбор скина --
        -----------------

        local selected_gender, selected_skin = _, 1
        local lbl_skin_name = ibCreateLabel( _SCREEN_X - 140, 116, 0, 0, "Миловидная", UI.area, COLOR_WHITE, _, _, "center", "center", ibFonts.regular_16 )

        local function SelectSkin( skin, gender )
            iprint( "New skin", getTickCount( ), skin )

            selected_skin = skin

            local skins_list = REG_SKINS[ gender ]
            local skin = skins_list[ skin ]
            local name = SKINS_NAMES[ skin ]

            lbl_skin_name:ibData( "text", name )

            SwitchSkinPreview( skin )
        end

        -- Влево
        local img = ibCreateImage( _SCREEN_X - 213 - 10, 109, 0, 0, "img/icon_arrow.png", UI.area )
            :ibSetRealSize( )
            :ibData( "alpha", 200 )
        ibCreateArea( img:ibData( "px" ) - 20, img:ibData( "py" ) - 20, img:width( ) + 40, img:height( ) + 40, UI.area )
            :ibOnHover( function( ) img:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) img:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                if getTickCount( ) - last_click <= 5000 then return end

                ibClick( )
                SelectSkin( ( selected_skin - 2 ) % #REG_SKINS[ selected_gender ] + 1, selected_gender )
            end )
        
        -- Вправо
        local img = ibCreateImage( _SCREEN_X - 61 - 10, 109, 0, 0, "img/icon_arrow_right.png", UI.area )
            :ibSetRealSize( )
            :ibData( "alpha", 200 )
        ibCreateArea( img:ibData( "px" ) - 20, img:ibData( "py" ) - 20, img:width( ) + 40, img:height( ) + 40, UI.area )
            :ibOnHover( function( ) img:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) img:ibAlphaTo( 200, 200 ) end )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                if getTickCount( ) - last_click <= 5000 then return end
                
                ibClick( )
                SelectSkin( ( selected_skin ) % #REG_SKINS[ selected_gender ] + 1, selected_gender )
            end )

        ----------------
        -- Выбор пола --
        ----------------

        UI.gender_area = ibCreateArea( 0, 60, 0, 0, UI.area )
        local genders = { [ 0 ] = "Мужской", [ 1 ] = "Женский" }
        local genders_lbls = { }

        local function SelectGender( gender )
            if selected_gender == gender then return end

            local lbl = genders_lbls[ gender + 1 ]
            local move_speed = 250
            
            if isElement( UI.handle ) then
                UI.handle:ibMoveTo( lbl:ibData( "px" ), _, move_speed, "OutQuad" ):ibResizeTo( lbl:width( ), _, move_speed, "OutQuad" )
            else
                UI.handle = ibCreateImage( lbl:ibData( "px" ), 23, lbl:width( ), 1, _, UI.gender_area ):ibData( "alpha", 0 ):ibAlphaTo( 255, move_speed )
            end

            SelectSkin( 1, gender )
            selected_gender = gender
        end

        local npx = 0
        for i, v in pairs( genders ) do
            local lbl = ibCreateLabel( npx, 0, 0, 0, v, UI.gender_area, COLOR_WHITE, _, _, "left", "top", ibFonts.regular_16 )
            table.insert( genders_lbls, lbl )

            ibCreateArea( npx - 10, -10, lbl:width( ) + 20, 40, UI.gender_area )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )
                    SelectGender( i )
                end )
            npx = npx + lbl:width( ) + 25
        end
        UI.gender_area:ibData( "sx", genders_lbls[ #genders_lbls ]:ibGetAfterX( ) ):ibData( "px", UI.area:ibData( "sx" ) - UI.gender_area:ibData( "sx" ) - 60 )

        -- Выбор мужского по дефолту
        SelectGender( 0 )
        --SelectSkin( 1, 0 )

        ----------------
        -- Ввод имени --
        ----------------

        local edit_bg = ibCreateImage( _SCREEN_X - 230 - 60, 164, 230, 40, "img/bg_input.png", UI.area )
        local edit_name = ibCreateWebEdit( 0, 0, edit_bg:width( ), edit_bg:height( ), "", edit_bg, COLOR_WHITE, 0 )
            :ibData( "placeholder", "Введите имя" )
            :ibData( "placeholder_color", ibApplyAlpha( COLOR_WHITE, 50 ) )
            :ibData( "font", "regular_11_600" )
            :ibData( "max_length", 16 )
        ibWebEditSetLinting( edit_name )

        ibCreateLabel( edit_bg:ibData( "px" ) - 12, edit_bg:ibData( "py" ) + edit_bg:height( ) / 2, 0, 0, "Имя", UI.area, COLOR_WHITE, _, _, "right", "center", ibFonts.regular_14 )
            :ibData( "outline", 1 )

        ------------------
        -- Ввод Фамилии --
        ------------------

        local edit_bg = ibCreateImage( _SCREEN_X - 230 - 60, 214, 230, 40, "img/bg_input.png", UI.area )
        local edit_last_name = ibCreateWebEdit( 0, 0, edit_bg:width( ), edit_bg:height( ), "", edit_bg, COLOR_WHITE, 0 )
            :ibData( "placeholder", "Введите фамилию" )
            :ibData( "placeholder_color", ibApplyAlpha( COLOR_WHITE, 50 ) )
            :ibData( "font", "regular_11_600" )
            :ibData( "max_length", 16 )
        ibWebEditSetLinting( edit_last_name )

        ibCreateLabel( edit_bg:ibData( "px" ) - 12, edit_bg:ibData( "py" ) + edit_bg:height( ) / 2, 0, 0, "Фамилия", UI.area, COLOR_WHITE, _, _, "right", "center", ibFonts.regular_14 )
            :ibData( "outline", 1 )

        -------------------
        -- Ввод Возраста --
        -------------------

        local edit_bg = ibCreateImage( _SCREEN_X - 230 - 60, 264, 70, 40, "img/bg_input_small.png", UI.area )
        local edit_day = ibCreateWebEdit( 0, 0, edit_bg:width( ), edit_bg:height( ), "", edit_bg, COLOR_WHITE, 0 )
            :ibData( "placeholder", "День" )
            :ibData( "placeholder_color", ibApplyAlpha( COLOR_WHITE, 50 ) )
            :ibData( "font", "regular_11_600" )
            :ibData( "max_length", 2 )
            --:ibData( "focusable", true )
            --:ibData( "focused", true )
        ibCreateLabel( edit_bg:ibData( "px" ) - 12, edit_bg:ibData( "py" ) + edit_bg:height( ) / 2, 0, 0, "Дата рождения", UI.area, COLOR_WHITE, _, _, "right", "center", ibFonts.regular_14 )
            :ibData( "outline", 1 )

        local edit_bg = ibCreateImage( _SCREEN_X - 210, 264, 70, 40, "img/bg_input_small.png", UI.area )
        local edit_month = ibCreateWebEdit( 0, 0, edit_bg:width( ), edit_bg:height( ), "", edit_bg, COLOR_WHITE, 0 )
            :ibData( "placeholder", "Месяц" )
            :ibData( "placeholder_color", ibApplyAlpha( COLOR_WHITE, 50 ) )
            :ibData( "font", "regular_11_600" )
            :ibData( "max_length", 2 )

        local edit_bg = ibCreateImage( _SCREEN_X - 130, 264, 70, 40, "img/bg_input_small.png", UI.area )
        local edit_year = ibCreateWebEdit( 0, 0, edit_bg:width( ), edit_bg:height( ), "", edit_bg, COLOR_WHITE, 0 )
            :ibData( "placeholder", "Год" )
            :ibData( "placeholder_color", ibApplyAlpha( COLOR_WHITE, 50 ) )
            :ibData( "font", "regular_11_600" )
            :ibData( "max_length", 4 )

        ---------------
        -- Применить --
        ---------------

        local btn_apply = ibCreateImage( _SCREEN_X - 130 - 62, 404, 0, 0, "img/btn_apply.png", UI.area )
            :ibSetRealSize( )
            :ibData( "alpha", 150 )
            :ibOnHover( function( ) source:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) source:ibAlphaTo( 150, 200 ) end )

        btn_apply
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                if getTickCount( ) - last_click <= 5000 then return end
                last_click = getTickCount( )

                ibClick( )

                CleanError( )

                btn_apply:ibData( "disabled", true )
                    :ibTimer( function( self )
                        self:ibData( "disabled", false )
                    end, 5000, 1 )

                local name      = edit_name:ibData( "text" )
                local last_name = edit_last_name:ibData( "text" )
                local day       = tonumber( edit_day:ibData( "text" ) )
                local month     = tonumber( edit_month:ibData( "text" ) )
                local year      = tonumber( edit_year:ibData( "text" ) )
                local gender    = selected_gender
                local skin      = REG_SKINS[ selected_gender ][ selected_skin ]
                
                name, last_name = FixWarningCharacters( name, last_name )
                local result, err = CheckRegistrationData( name, last_name, day, month, year, gender, skin )

                if not result then
                    if err then Error( err ) end
                    return
                else
                    triggerServerEvent( "onRegisterConfirmRequest", resourceRoot,
                        {
                            name      = name,
                            last_name = last_name,
                            gender    = gender,
                            skin      = skin,
                            day       = day,
                            month     = month,
                            year      = year,
                        }
                    )
                end
            end )
        

        --------------

        UI.area:center_y( )
        UI.area:ibMoveTo( 0, _, show_duration, "OutQuad" )
        
        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = nil
        showCursor( false )
    end
end
addEvent( "ShowCharacterSelectionUI", true )
addEventHandler( "ShowCharacterSelectionUI", root, ShowCharacterSelectionUI_handler )

function onRegisterConfirm_handler( )
    TUTORIAL_START_TICK = TUTORIAL_START_TICK or getRealTimestamp( )
    
    -- Шаг 2 - Конец регистрации
    triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), 1, getRealTimestamp( ) - TUTORIAL_START_TICK )

    DisableHUD( true )

    if UI then
        local hide_duration = 500
        UI.area:ibMoveTo( _SCREEN_X, _, hide_duration, "OutQuad" )
        UI.overlay:ibAlphaTo( 0, hide_duration )
    end

    fadeCamera( false, 0.0 )

    setTimer( function( )
        iprint( "DISABLE CHARACTER SELECTION" )
        ShowCharacterSelectionUI_handler( false )
        StopSkinPreview( )
        
        -- Начинаем туториал с поездки до автосалона
        DisableHUD( false )
        triggerEvent( "ShowInventoryHotbar", localPlayer, false, "tutorial" )
        StartTutorialStep( "drive_to_carsell", false )
        --StartTutorialStep( "crash_cutscene", false )
    end, 1000, 1 )
end
addEvent( "onRegisterConfirm", true )
addEventHandler( "onRegisterConfirm", root, onRegisterConfirm_handler )

function onRegisterStart_handler( )
    -- Шаг 1 - Начало регистрации
    TUTORIAL_START_TICK = getRealTimestamp( )

    triggerServerEvent( "onPlayerTutorialAnalyticsStep", localPlayer, localPlayer:GetClientID( ), -1, 0 )
    StartSkinPreview( )
    ShowCharacterSelectionUI_handler( true )
end
addEvent( "onRegisterStart", true )
addEventHandler( "onRegisterStart", root, onRegisterStart_handler )

--[[addCommandHandler( "s", function( )
    StartSkinPreview( )
    ShowCharacterSelectionUI_handler( true )
    --StartTutorialStep( "crash_cutscene", false )
end )]]

--[[addCommandHandler( "d", function( )
    StopSkinPreview( )
    ShowCharacterSelectionUI_handler( false )
end )]]