Import( "ib" )

---
--- Общая обертка для совершения ВСЕХ платежей
--- Интегрирован выбор способа платежа и вся хуйня сверху этого
--- Еблан который не будет это юзать в новых акциях получит свой же хребет себе в жопу
---

function ibPayment( )
    local self = {
        -- Сервисное говно
        selector = ibPaymentSelector( ),
        browser = ibPaymentBrowser( ),

        -- Изменяемые данные
        data = { },
    }

    self.selector.callback = function( item )
        -- Селектор больше не нужен
        self.selector.destroy( )

        -- Берем параметры игрока (всегда общие)
        local game_server = localPlayer:getData( "_srv" )[ 1 ]
        local client_id = localPlayer:GetClientID( )
        self.data.game_server = self.data.game_server or game_server
        self.data.client_id = self.data.client_id or client_id
        
        -- Выбран метод платежа если он есть
        self.data.preferred_method = item.item_name

        -- Устанавливаем параметры платежа
        self.browser.data = self.data

        -- Устанавливаем платежку для браузера
        self.browser.pmethod = item.pmethod or "unitpay"

        -- Запускаем все говно
        self.browser.init( )
    end

    local function destroy( )
        DestroyTableElements( self )
    end

    local function init( )
        self.selector.init( )
    end

    -- И снова дохуя ООП
    self.destroy = destroy
    self.init = init

    -- Особенно тут
    return self
end

--
-- Универсальный браузер для совершения платежей
-- Использовать только внутри ibPayment, ВРУЧНУЮ НЕ ВЫЗЫВАТЬ (!!!)
--
-- Пример:
-- local browser = ibPaymentBrowser( )
-- browser.data = { client_id = "...", game_server = 123, sum = 1000, ... }
-- browser.control_cursor = false
-- browser.loading_parent = UI.main_window
-- browser.init( )
-- browser.destroy( )

function ibPaymentBrowser( )
    local self = {
        -- Изменяемые параметры
        url = "https://pyapi.gamecluster.nextrp.ru/v1.0/payments/pay", -- ссылка на API
        pmethod = "unitpay", -- дефолтный платежный метод

        control_cursor = false, -- управлять ли курсором
        loading_parent = nil, -- родительский элемент анимации загрузки

        data = { }, -- таблица из данных на платежку (client_id, sum, game_server, ...)
    }

    local ui = { }

    -- Полное уничтожение браузера и его элементов
    local function destroy( )
        if self.control_cursor then
            showCursor( false, false )
        end
        DestroyTableElements( ui )
        ui = { }
    end

    -- Размеры браузера
    local margin = 20
    local px, py, sx, sy = margin, margin, _SCREEN_X - margin * 2, _SCREEN_Y - margin * 2

    -- Кнопки переключения на другую платежку в углу окна
    local active_switch_buttons = { gamemoney = "unitpay" }

    -- Костылизация для жсона
    local function convert_to_json( t )
        return toJSON( t ):sub( 2, -2 )
    end

    -- Создание анимации загрузки
    local function create_loading( )
        ui.loading = ibLoading( { parent = loading_parent, priority = 10 } )
            :ibData( "alpha", 0 ):ibAlphaTo( 255, 200 )
    end

    -- Удаление анимации загрузки
    local function destroy_loading( )
        if isElement( ui.loading ) then destroyElement( ui.loading ) end
        ui.loading = nil
    end

    -- Удаление кнопки смены платежки
    local function destroy_switch_button( )
        if isElement( ui.switch_button ) then destroyElement( ui.switch_button ) end
        ui.switch_button = nil
    end

    -- Добавление кнопки смены платежки
    local function create_switch_button( )
        local bsx, bsy = 446, 70
        local bpx, bpy = sx - bsx - 10, sy - bsy - 10
        ui.switch_button = ibCreateButton( bpx, bpy, bsx, bsy, ui.browser, ":nrp_shared/img/payments/change_hover.png", ":nrp_shared/img/payments/change.png", ":nrp_shared/img/payments/change_hover.png", 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                destroy_switch_button( )

                self.pmethod = active_switch_buttons[ self.pmethod ]
                ui.browser:Navigate( self.url  .. "/" .. self.pmethod, convert_to_json( self.data ) )
            end )
    end

    -- Создание браузера и переход по ссылке
    local function create_browser( )
        local ready = 0
        -- Сам браузер
        ui.browser = ibCreateBrowser( px, py + 100, sx, sy, _, false, false ):ibData( "alpha", 0 )
            :ibOnCreated( function( )
                iprint( self.url  .. "/" .. self.pmethod, convert_to_json( self.data ) )
                source:Navigate( self.url  .. "/" .. self.pmethod, convert_to_json( self.data ) )
            end )
            :ibOnDocumentReady( function( )
                -- Ждем пока контент полностью загрузится
                ready = ready + 1
                if ready == 2 then
                    destroy_loading( )

                    source:ibMoveTo( px, py, 500 ):ibAlphaTo( 255, 300 )

                    -- Кнопка "Проблема с оплатой?" - должна быть только после загрузки страницы
                    if active_switch_buttons[ self.pmethod ] then
                        create_switch_button( )
                    end
                end
            end )
        
        -- Кнопка "Закрыть"
        ibCreateButton( sx - 24 - 30, 25, 24, 24, ui.browser, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFF000000, 0xFF333333, 0xFF555555 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                destroy( )
            end )
    end

    -- Запускаем движ
    function init( )
        if self.control_cursor then
            showCursor( true, true )
        end
        create_loading( )
        create_browser( )
    end

    -- Типа публичные методы и свойства
    self.ui = ui
    self.destroy = destroy
    self.init = init

    -- Дохуя ООП
    return self
end

--
-- Окно выбора способа платежа
--
-- Пример:
-- local selector = ibPaymentSelector( )
-- selector.control_cursor = false
-- selector.init( )
-- selector.destroy( )

function ibPaymentSelector( )
    local self = {
        -- Изменяемые параметры
        control_cursor = false, -- Управлять ли курсором
    }

    -- Размеры и всякая шляпа
    local sx, sy = 1024, 720
    local ui = { }

    -- Уничтожение
    local function destroy( )
        if self.control_cursor then
            showCursor( false, false )
        end
        DestroyTableElements( ui )
        ui = { }
    end

    -- Фон и всякая шмаль
    local function create_background( )
        ui.bg = ibCreateBackground( )
        ui.window = ibCreateImage( 0, 0, sx, sy, ":nrp_shared/img/payments/methods_selector/bg.png", ui.bg )
            :center()
        ui.scrollpane, ui.scrollbar = ibCreateScrollpane( 0, 80, sx, sy - 80, ui.window, { scroll_px = -20, scroll_py = 10, bg_color = 0x00FFFFFF } )
        ui.scrollbar:ibSetStyle( "slim_nobg" )

        ui.bg
            :ibData( "alpha", 0 )
            :ibAlphaTo( 255, 500 )

        local px, py = ui.window:ibData( "px" ), ui.window:ibData( "py" )
        ui.window:ibBatchData( { px = px, py = py + 50 } )
        ui.window:ibMoveTo( px, py, 500 )
    end

    -- Заголовок и кнопка закрыть
    local function create_header( )
        ui.header = ibCreateButton( sx - 28 - 30, 25, 28, 28, ui.window, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", COLOR_WHITE, 0xAAFFFFFF, 0xAAFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                destroy( )
            end )
    end

    -- Ебейшая кнопка автоскроллинга с кучей костылей
    local function create_scroller( )
        local nsx, nsy = 629, 44

        local enabled = false

        ui.scroll_btn = ibCreateButton( 0, 579, nsx, nsy, ui.scrollpane, 
            ":nrp_shared/img/payments/methods_selector/other_options.png", 
            ":nrp_shared/img/payments/methods_selector/other_options_hover.png", 
            ":nrp_shared/img/payments/methods_selector/other_options_hover.png", 
        COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
            :center_x( )
            :ibData( "alpha", 0 )
            :ibData( "priority", 1 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ui.scrollbar:ibScrollTo( 560 / ( ui.scrollpane:ibData( "sy" ) - ui.scrollpane:ibData( "viewport_sy" ) ) )
                ibClick( )
            end )
            :ibOnRender( function( )
                local position = ui.scrollbar:ibData( "position" )
                local enabled_target = position <= 0.12 and ui.contents_second

                if enabled ~= enabled_target then
                    enabled = enabled_target
                    if enabled then
                        ui.scroll_btn:ibAlphaTo( 255 )
                        ui.scroll_btn:ibData( "disabled", false )
                        if ui.contents_second then
                            ui.contents_second:ibMoveTo( 0, 630 )
                        end
                    else
                        ui.scroll_btn:ibAlphaTo( 0 )
                        ui.scroll_btn:ibData( "disabled", true )
                        if ui.contents_second then
                            ui.contents_second:ibMoveTo( 0, 560 )
                        end
                    end
                end
            end )
    end

    -- Создание группы платежных систем
    local function contents_creator( configuration )
        local row, column = 0, 0
        local current_item = 0

        local area_sx, area_sy = configuration.base_sx or 1024, configuration.base_sy or 640

        local csx, csy = 260, 289
        local base_px, base_py = configuration.base_px or 0, configuration.base_py or 0

        local area = ibCreateArea( base_px, base_py, area_sx, area_sy, ui.scrollpane )

        while ( configuration.items[ current_item + 1 ] ) do
            current_item = current_item + 1
            if column >= configuration.per_row then
                column = 0
                row = row + 1
            end
            column = column + 1

            local item = configuration.items[ current_item ]

            local ipx, ipy = 13 + (column - 1) * 246, 14 + row * 274
            local bg = ibCreateImage( ipx, ipy, csx, csy, ":nrp_shared/img/payments/methods_selector/item_bg.png", area )
            local bg_hover = ibCreateImage( 0, 0, 0, 0, ":nrp_shared/img/payments/methods_selector/item_bg_hover.png", bg )
                :ibSetRealSize( )
                :center( )
                :ibData( "alpha", 0 )
                :ibData( "disabled", true )

            bg
                :ibOnHover( function( )
                    bg_hover:ibAlphaTo( 255 )
                end )
                :ibOnLeave( function( )
                    bg_hover:ibAlphaTo( 0 )
                end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    if self.callback then
                        if not item.pmethod then
                            item.pmethod = localPlayer:GetPMethod( )
                        end
                        self.callback( item )
                    end
                    ibClick( )
                end )

            local img_icon = ibCreateImage( ipx, ipy, csx, csy, ":nrp_shared/img/payments/methods_selector/" .. item.icon .. ".png", area )
                :ibData( "disabled", true )
        end

        return area
    end

    -- Зацени этот костыль
    function create_contents( contents_data )
        local contents_configuration = {
            base_px = 0,
            base_py = 0,
            per_row = 4,
            items = contents_data,
        }
        ui.contents_first = contents_creator( contents_configuration )
    end

    -- И этот
    function create_secondary_contents( contents_data )
        if ( #contents_data == 0 ) then return end
        local contents_configuration = {
            base_px = 0,
            base_py = 560,
            base_sy = math.max( 640, 12 + math.ceil( #contents_data / 4 ) * 274 + 30 ),

            per_row = 4,
            items = contents_data,
        }
        ui.contents_second = contents_creator( contents_configuration )
    end

    -- Создание
    function init( )
        destroy()

        local data = exports.nrp_donate:GetPaymentMethodsInfo( )
        iprint( "internal data", data )

        if self.control_cursor then
            showCursor( true, true )
        end

        create_background( )
        create_header( )
        create_scroller( )

        local data_first, data_rest = { }, { }
        for i, v in pairs( data ) do
            table.insert( i <= 8 and data_first or data_rest, v )
        end
        create_contents( data_first )
        create_secondary_contents( data_rest )
        ui.scrollpane:AdaptHeightToContents( )
        ui.scrollbar:UpdateScrollbarVisibility( ui.scrollpane )
    end

    -- Вах сматри че умею
    self.ui = ui
    self.destroy = destroy
    self.init = init

    -- Ой красота
    return self
end