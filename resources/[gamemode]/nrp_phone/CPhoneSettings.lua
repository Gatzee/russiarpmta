AVAILABLE_SETTINGS = {
            {
                id = "race_notifications",
                text = "Уведомления о гонках",
                variant = "toggle",
                description =
[[Определяет, будете ли Вы получать уведомления о гонках]],
                additional_height = 30,
            },
            {
                id = "jobs_notifications",
                text = "Уведомления о работах",
                variant = "toggle",
                description =
[[Определяет, будете ли Вы получать уведомления о работах]],
                additional_height = 30,
            },
            {
                id = "coop_quest_notifications",
                text = "Уведомления о квестах",
                variant = "toggle",
                description =
[[Определяет, будете ли Вы получать приглашения в кооп квесты]],
                additional_height = 30,
            },
            {
                id = "casinovolume",
                text = "Казино: Громкость",
                variant = "volume",
                description = 
[[Регулирует громкость звуков в казино]]
                ,
                additional_height = 55,
                condition = function( )
                    return getElementData( localPlayer, "in_casino" )
                end,
            },
            {
                id = "cinemavolume",
                text = "Кино: Громкость",
                variant = "volume",
                description = 
[[Регулирует громкость фильмов в кинотеатрах]]
                ,
                additional_height = 55,
                condition = function( )
                    return getElementData( localPlayer, "in_cinema" )
                end,
            },
            {
                id = "cinemaalpha",
                text = "Кино: Прозрачность",
                variant = "toggle",
                description =
[[Включает прозрачность всех персонажей в залах для комфортного просмотра во время показа видео]],
                additional_height = 55,
                condition = function( )
                    return getElementData( localPlayer, "in_cinema" )
                end,
            },
            {
                id = "notifications",
                text = "Уведомления",
                variant = "volume",
                description = 
[[Регулирует громкость уведомлений в телефоне]]
                ,
                additional_height = 55,
            },
            {
                id = "voice",
                text = "Громкость голоса",
                variant = "volume",
                description = 
[[Регулирует громкость голоса других игроков]]
                ,
                additional_height = 55,
            },
            {
                id = "radio_coeff",
                text = "Громкость радио",
                variant = "volume",
                description = 
[[Регулирует громкость радио]]
                ,
                additional_height = 55,
            },
            {
                id = "vehicle_engine",
                text = "Звуки двигателей",
                variant = "volume",
                description = 
[[Также влияет на сирены машин]]
                ,
                additional_height = 45,
            },

            {
                id = "drawdistance",
                text = "Прорисовка карты",
                variant = "volume",
                description = 
[[Чем больше, тем выше нагрузка]]
                ,
                additional_height = 45,
            },
            {
                id = "vehdrawdistance",
                text = "Прорисовка машин",
                variant = "volume",
                description = 
[[Дальность отрисовки машин в высоком качестве]]
                ,
                additional_height = 55,
            },
            {
                id = "reflection",
                text = "Отблеск машин",
                variant = "toggle",
                description =
[[Твоя ласточка будет выглядеть еще п... Лучше. Да, лучше.]],
                additional_height = 40,
            },
            {
                id = "lut",
                text = "Цветокоррекция",
                variant = "toggle",
                description =
[[Тебе больше не придётся фотошопить свои скриншоты.]],
                additional_height = 40,
            },
            {
                id = "ssao",
                text = "Затенение",
                variant = "toggle",
                description =
[[Не тени, конечно, но тоже ничего.]],
                additional_height = 20,
            },
            {
                id = "water",
                text = "HD Вода",
                variant = "toggle",
                description =
[[Круче, чем бутылка 0.75]],
                additional_height = 20,
            },
            {
                id = "skybox",
                text = "Динамичное небо",
                variant = "toggle",
                description =
[[Динамичные облака? Не вопрос!]],
                additional_height = 20,
            },
            {
                id = "sun",
                text = "Солнечные лучи",
                variant = "toggle",
                description =
[[Для полного комплекта летней атмосферы.]],
                additional_height = 20,
            },
            {
                id = "blur",
                text = "Размытие",
                variant = "toggle",
                description =
[[Любишь скорость? Это тебе поможет почувствовать её еще сильнее!]],
                additional_height = 30,
            },
            {
                id = "switch_channel",
                text = "Переключение чата",
                variant = "toggle",
                description =
[[Автоматическое переключение на общий чат-канал после сообщения]],
                additional_height = 30,
            },
            {
                id = "count_show_vinyls",
                text = "Кол-во авто с винилами",
                variant = "input_number",
                description =
[[Настрой количество отображаемых винилов под производительность ПК!]],
                additional_height = 48,
            },
            {
                id = "quality_show_vinyls",
                text = "Качество винилов",
                variant = "radio_button",
                description =
[[Настрой качество винилов под производительность ПК!]],
                additional_height = 48,
                data =
                {
                    { name = "Мин",  value = 512  },
                    { name = "Сред", value = 768  },
                    { name = "Макс", value = 1024 },
                },
            },
            {
                id = "count_show_neons",
                text = "Кол-во авто с неонами",
                variant = "input_number",
                description =
[[Настрой количество отображаемых неонов под производительность ПК!]],
                additional_height = 48,
            },
            {
                id = "init_spawn_in_home",
                text = "Начинать игру из дома",
                variant = "toggle",
                description =
[[Отключи, если хочешь появляться на том же месте, где вышел из игры]],
                additional_height = 30,
            },
            {
                id = "gps_enalbe",
                text = "Отображение GPS",
                variant = "toggle",
                description =
[[Отключи, если хочешь убрать построение маршрутов до цели]],
                additional_height = 30,
            },
            {
                id = "gps_quality",
                text = "Качество GPS",
                variant = "radio_button",
                description =
[[Настрой GPS под производительность ПК!]],
                additional_height = 48,
                data =
                {
                    { name = "Мин",  value = 3  },
                    { name = "Сред", value = 2  },
                    { name = "Макс", value = 1 },
                },
            },
}

SETTINGSAPP = nil

APPLICATIONS.settings = {
    id = "settings",
    icon = "img/apps/settings.png",
    name = "Настройки игры",
    elements = { },
    create = function( self, parent, conf )
        self.elements.header_texture = dxCreateTexture( "img/elements/app_header.png" )
        local hsx, hsy = dxGetMaterialSize( self.elements.header_texture )

        local size_y = hsy * conf.sx / hsx
        self.elements.header = ibCreateImage( 0, 0, hsx, size_y, self.elements.header_texture, parent )

        self.elements.header_text = ibCreateLabel( 15, 25, 0, 0, "Настройки", parent ):ibBatchData( { font = ibFonts.bold_12, color = 0xFFFFFFFF })

        local usable_y_space = conf.sy - size_y

        self.elements.rt, self.elements.sc = ibCreateScrollpane( 0, size_y, conf.sx, usable_y_space, UI_elements.background, 
            {
                scroll_px = -22,
                bg_sx = 0,
                handle_sy = 40,
                handle_sx = 16,
                handle_texture = ":nrp_shared/img/scroll_bg_small.png",
                handle_upper_limit = -40 - 20,
                handle_lower_limit = 20,
            }
        )
        self.elements.sc:ibData( "sensivity", 0.1 )

        self.header_y = size_y

        self.elements.checked_texture         = dxCreateTexture( "img/elements/checked.png" )
        self.elements.unchecked_texture       = dxCreateTexture( "img/elements/unchecked.png" )
        self.elements.line_horizontal_texture = dxCreateTexture( "img/elements/line_horizontal.png" )
        self.elements.scrollbg_texture        = dxCreateTexture( "img/elements/bar_bg.png" )
        self.elements.handle_texture          = dxCreateTexture( "img/elements/handle.png" )
        self.elements.config_texture          = dxCreateTexture( "img/elements/config.png" )

        local py = 10
        for i, v in pairs( AVAILABLE_SETTINGS ) do
            if not v.condition or v.condition() then
                local px = 5

                if v.variant == "toggle" then
                    ibCreateLabel( px + 35, py + 4, 0, 30, v.text, self.elements.rt ):ibBatchData( { font = ibFonts.semibold_10, color = 0xFFFFFFFF } )

                    local current_texture = SETTINGS[ v.id ] and self.elements.checked_texture or self.elements.unchecked_texture
                    
                    ibCreateButton( px + 3, py, 24, 24, self.elements.rt,
                                    current_texture, self.elements.checked_texture, self.elements.checked_texture,
                                    0xFFFFFFFF, 0xF0FFFFFF, 0xA0FFFFFF )
                        :ibData( "state", SETTINGS[ v.id ] or false )
                        :ibOnClick( function( button, state )
                            if button ~= "left" or state ~= "up" then return end
                            ibClick( )

                            local state = not source:ibData( "state" )
                            source:ibData( "state", state ):ibData( "texture", state and SETTINGSAPP.elements.checked_texture or SETTINGSAPP.elements.unchecked_texture )
                            SetSetting( v.id, state )
                        end )

                    if v.description then
                        ibCreateLabel( px + 3, py + 32, hsx - 32, 30, v.description, self.elements.rt, 0xaaffffff ):ibBatchData( { font = ibFonts.regular_7, wordbreak = true, color = 0xFFFFFFFF } )
                    end

                    py = py + 30 + ( v.additional_height or 0 )

                    local line_sx, line_sy = dxGetMaterialSize( self.elements.line_horizontal_texture )
                    local line_px = conf.sx / 2 - line_sx / 2

                    ibCreateImage( line_px, py, line_sx, line_sy, self.elements.line_horizontal_texture, self.elements.rt )

                    py = py + 10

                elseif v.variant == "volume" then
                    ibCreateLabel( px + 35, py + 4, 0, 30, v.text, self.elements.rt ):ibBatchData( { font = ibFonts.semibold_10, color = 0xFFFFFFFF } )
                    ibCreateImage( px + 3, py, 24, 24, self.elements.config_texture, self.elements.rt, 0xFFFFFFFF )

                    local scroll_sx, scroll_sy = hsx - 10, 20
                    local scroll_px, scroll_py = px, py + 28

                    local scroll_bg_sx = scroll_sx * 0.72
                    local scroll_bg_sy = scroll_sy / 15

                    local scroll_bg_px = scroll_px + scroll_sx / 2 - scroll_bg_sx / 2
                    local scroll_bg_py = scroll_py + scroll_sy / 2 - scroll_bg_sy / 2

                    self.elements[ "scrollbar_" .. i ] = ibScrollbarH( { px = scroll_bg_px, py = scroll_bg_py, sx = scroll_bg_sx, sy = scroll_bg_sy, parent = self.elements.rt } )
                    :ibSetStyle( "default" ):ibData( "position", ( SETTINGS[ v.id ] or 0.5 ) )
                    addEventHandler( "ibOnElementDataChange", self.elements[ "scrollbar_" .. i ], function( key )
                        if key == "position" then
                            local value = source:ibData( "position" )   
                            SetSetting( v.id, math.floor( math.min( 1, math.max( 0, value ) ) * 100 ) / 100 )
                        end
                    end )

                    if v.description then
                        ibCreateLabel( px + 3, py + 52, hsx - 32, 30, v.description, self.elements.rt, 0xaaffffff ):ibBatchData( { font = ibFonts.regular_7, wordbreak = true, color = 0xFFFFFFFF } )
                    end

                    py = py + 30 + ( v.additional_height or 0 )

                    local line_sx, line_sy = dxGetMaterialSize( self.elements.line_horizontal_texture )
                    local line_px = conf.sx / 2 - line_sx / 2

                    ibCreateImage( line_px, py, line_sx, line_sy, self.elements.line_horizontal_texture, self.elements.rt )

                    py = py + 10
                elseif v.variant == "input_number" then
                    ibCreateLabel( px + 35, py + 4, 0, 30, v.text, self.elements.rt ):ibBatchData( { font = ibFonts.semibold_10, color = 0xFFFFFFFF } )
                    ibCreateImage( px + 3, py, 24, 24, self.elements.config_texture, self.elements.rt, 0xFFFFFFFF )

                    local input_sx, input_sy = hsx, 20
                    local text_lenght = dxGetTextWidth( SETTINGS[ v.id ], 1, ibFonts.semibold_12 ) * 2
                    local l_px = px + input_sx / 2 - text_lenght / 2 - 45
                    local r_px = px + input_sx / 2 + text_lenght / 2 - 15
                    self.elements[ "lbl_input_number" .. i ] = ibCreateLabel( l_px + 30, py + 26, r_px - l_px - 30, 20, SETTINGS[ v.id ] or 1, self.elements.rt, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.semibold_12 )
                
                    self.elements[ "btn_minus_number" .. i ] = ibCreateImage( l_px, py + 26, 30, 20, _, self.elements.rt, 0xFF3F5368 )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        local value = math.max( 0, SETTINGS[ v.id ] - 1 )
                        SetSetting( v.id, value )
                        self.elements[ "lbl_input_number" .. i ]:ibData("text", value )
                    end )
                    :ibOnHover( function( )
                        self.elements[ "btn_minus_number" .. i ]:ibData( "color", 0xFF5D7B99 )
                    end )
                    :ibOnLeave( function( )
                        self.elements[ "btn_minus_number" .. i ]:ibData( "color", 0xFF3F5368 )
                    end )

                    ibCreateLabel( 0, 0, 30, 20, "-", self.elements[ "btn_minus_number" .. i ], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.semibold_14 ):ibData( "disabled", true )

                    self.elements[ "btn_plus_number" .. i ] = ibCreateImage( r_px, py + 26, 30, 20, _, self.elements.rt, 0xFF3F5368 )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        ibClick( )
                        local value = math.min( 999, SETTINGS[ v.id ] + 1 )
                        SetSetting( v.id, value )
                        self.elements[ "lbl_input_number" .. i ]:ibData("text", value )
                    end )
                    :ibOnHover( function( )
                        self.elements[ "btn_plus_number" .. i ]:ibData( "color", 0xFF5D7B99 )
                    end )
                    :ibOnLeave( function( )
                        self.elements[ "btn_plus_number" .. i ]:ibData( "color", 0xFF3F5368 )
                    end )
                    ibCreateLabel( 0, 0, 30, 20, "+", self.elements[ "btn_plus_number" .. i ], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.semibold_14 ):ibData( "disabled", true )

                    if v.description then
                        ibCreateLabel( px + 3, py + 52, hsx - 32, 30, v.description, self.elements.rt, 0xaaffffff ):ibBatchData( { font = ibFonts.regular_7, wordbreak = true, color = 0xFFFFFFFF } )
                    end

                    py = py + 30 + ( v.additional_height or 0 )

                    local line_sx, line_sy = dxGetMaterialSize( self.elements.line_horizontal_texture )
                    local line_px = conf.sx / 2 - line_sx / 2

                    ibCreateImage( line_px, py, line_sx, line_sy, self.elements.line_horizontal_texture, self.elements.rt )

                    py = py + 10
                elseif v.variant == "radio_button" then
                    ibCreateLabel( px + 35, py + 4, 0, 30, v.text, self.elements.rt ):ibBatchData( { font = ibFonts.semibold_10, color = 0xFFFFFFFF } )
                    ibCreateImage( px + 3, py, 24, 24, self.elements.config_texture, self.elements.rt, 0xFFFFFFFF )

                    local function RefreshRadioButtons( new_id )
                        for k, variant_data in pairs( v.data ) do
                            if k ~= new_id then
                                self.elements[ v.id .. "_value_" .. k ]:ibData( "color", 0xFF3F5368 )
                            end
                        end
                    end

                    local count_items = #v.data
                    local px_radio_button = (conf.sx - count_items * 40) / 2
                    for k, variant_data in pairs( v.data ) do
                        self.elements[ v.id .. "_value_" .. k ] = ibCreateImage( px_radio_button, py + 26, 40, 20, _, self.elements.rt, 0xFF3F5368 )
                        :ibOnClick( function( key, state )
                            if key ~= "left" or state ~= "up" then return end
                            ibClick( )
                            SetSetting( v.id, variant_data.value )
                            RefreshRadioButtons( k )
                        end )
                        :ibOnHover( function( )
                            self.elements[ v.id .. "_value_" .. k ]:ibData( "color", 0xFF5D7B99 )
                        end )
                        :ibOnLeave( function( )
                            if SETTINGS[ v.id ] ~= variant_data.value then
                                self.elements[ v.id .. "_value_" .. k ]:ibData( "color", 0xFF3F5368 )
                            end
                        end )
                        ibCreateLabel( 0, 0, 40, 20, variant_data.name, self.elements[ v.id .. "_value_" .. k ], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_9 ):ibData( "disabled", true )
                        if SETTINGS[ v.id ] == variant_data.value then
                            self.elements[ v.id .. "_value_" .. k ]:ibData( "color", 0xFF5D7B99 )
                        end
                        px_radio_button = px_radio_button + 40
                    end

                    if v.description then
                        ibCreateLabel( px + 3, py + 52, hsx - 32, 30, v.description, self.elements.rt, 0xaaffffff ):ibBatchData( { font = ibFonts.regular_7, wordbreak = true, color = 0xFFFFFFFF } )
                    end

                    py = py + 30 + ( v.additional_height or 0 )

                    local line_sx, line_sy = dxGetMaterialSize( self.elements.line_horizontal_texture )
                    local line_px = conf.sx / 2 - line_sx / 2

                    ibCreateImage( line_px, py, line_sx, line_sy, self.elements.line_horizontal_texture, self.elements.rt )

                    py = py + 10

                end
            end

            self.elements.rt:AdaptHeightToContents( )
        end

        SETTINGSAPP = self
        return self
    end,
    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        SETTINGSAPP = nil
    end,
}

SETTINGS = { 
--	snow                = true,
    notifications       = 0.3,
    radio_coeff         = 0.4,
    vehicle_engine      = 0.6,
    drawdistance        = 0.25,
    vehdrawdistance     = 0.25,
    voice               = 0.5,
    bandbalance         = true,
    cinemavolume        = 1,
    cinemaalpha         = false,
    switch_channel      = true,
    count_show_vinyls   = math.floor(dxGetStatus().VideoCardRAM / 100),
    count_show_neons    = math.min( math.floor( dxGetStatus( ).VideoCardRAM / 100 ), 30 ),
    quality_show_vinyls = 1024,
    race_notifications  = true,
    jobs_notifications  = true,
    coop_quest_notifications  = true,
    init_spawn_in_home  = true,
    skybox              = true,
    lut                 = false,
    ssao                = false,
    sun                 = false,
    gps_enalbe          = true,
    gps_quality         = 2,
}

if fileExists( "settings.nrp" ) then
    local settings_default = table.copy( SETTINGS )

    local file = fileOpen( "settings.nrp" )
    local file_contents = fileRead( file, file.size )
    SETTINGS = file_contents and fromJSON( file_contents ) or { }
    fileClose( file )

    for i, v in pairs( settings_default ) do
        if SETTINGS[ i ] == nil then
            SETTINGS[ i ] = settings_default[ i ]
        end
    end
end

triggerEvent( "onSettingsChange", localPlayer, SETTINGS, SETTINGS )

function SetSetting( key, value )
    SETTINGS[ key ] = value
    triggerEvent( "onSettingsChange", localPlayer, { [ key ] = true }, { [ key ] = value } )
    SETTINGS_CHANGED = true
end

function onSettingsUpdateRequest_handler( name )
    --iprint( "sending back", SETTINGS[ name ] )
    triggerEvent( "onSettingsChange", localPlayer, { [ name ] = true }, { [ name ] = SETTINGS[ name ] } )
end
addEvent( "onSettingsUpdateRequest", true )
addEventHandler( "onSettingsUpdateRequest", root, onSettingsUpdateRequest_handler )

function FlushSettings( force )
    if SETTINGS_CHANGED or force then
        if fileExists( "settings.nrp" ) then fileDelete( "settings.nrp" ) end
        local file = fileCreate( "settings.nrp" )
        fileWrite( file, toJSON( SETTINGS, true ) )
        fileClose( file )
        SETTINGS_CHANGED = nil
        --iprint( "Настройки сохранены" )
    end
end
Timer( FlushSettings, 5000, 0 )