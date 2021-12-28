-- Еще бы блять раз это говно тронуть пришлось

TAXIAPP = nil

APPLICATIONS.taxi = {
    id = "taxi",
    icon = "img/apps/taxi.png",
    name = "Вызов такси",
    elements = { },

    create_common_elements = function( self )
        if isElement( self.elements.header ) then
            destroyElement( self.elements.header )
        end
        local parent = self.parent
        local conf = self.conf
        local hsx, hsy = 204, 55
        local size_y = hsy * conf.sx / hsx
        self.elements.header = ibCreateImage( 0, 0, hsx, size_y, "img/elements/taxi_header.png", parent, 0xFFFFFFFF )
    end,

    create = function( self, parent, conf )
        if TAXIAPP then
            DestroyTableElements( TAXIAPP.elements )
        end

        self.parent = parent
        self.conf = conf

        TAXIAPP = self

        local task, rate_player = GetCurrentTask( ), GetRatePlayer( )

        -- Если игрок ждет такси
        if task and task.state == "waiting" then
            TAXIAPP:create_waiting_for_driver( TAXIAPP.parent, TAXIAPP.conf, task )

        -- Если игрока сейчас везут
        elseif task and task.state == "driving" then
                TAXIAPP:create_driving( TAXIAPP.parent, TAXIAPP.conf, task )

        -- Если нужно рейтить игрока, то всегда открываем рейтер
        elseif rate_player then
            TAXIAPP:create_rate( TAXIAPP.parent, TAXIAPP.conf, rate_player )

        -- Если в поиске, то меню поиска
        elseif IsSearchingForTaxi( ) then
            TAXIAPP:create_search( TAXIAPP.parent, TAXIAPP.conf, SEARCH_INFO )

        -- В ином случае - выбор класса для заказа новой таксишки
        else
            TAXIAPP:create_selector( TAXIAPP.parent, TAXIAPP.conf )

        end

        -- Создания интерфейсов того или иного рода

        --TAXIAPP:create_selector( TAXIAPP.parent, TAXIAPP.conf )
        --TAXIAPP:create_search( TAXIAPP.parent, TAXIAPP.conf, { class = 2, tick_start = getTickCount( ) } )
        --TAXIAPP:create_popup_found( TAXIAPP.parent, TAXIAPP.conf, { model_name = "Aventador", license_plate = "Х123УЙ" } )
        --TAXIAPP:create_waiting_for_driver( TAXIAPP.parent, TAXIAPP.conf, { model_name = "Aventador", license_plate = "Х123УЙ" } )
        --TAXIAPP:create_driving( TAXIAPP.parent, TAXIAPP.conf, { distance = 1234, amount = 123123 } )
        --TAXIAPP:create_rate( TAXIAPP.parent, TAXIAPP.conf, { amount = 123123 } )

        return self
    end,

    create_selector = function( self, parent, conf, info )
        DestroyTableElements( self.elements )
        self:create_common_elements( )

        self.elements.create_overlay = ibCreateImage( 0, 0, conf.sx, conf.sy, nil, parent, 0x00000000 )
        local parent = self.elements.create_overlay

        local npx, npy = 0, 55
        local nsx, nsy = conf.sx, 40

        local costs = getElementData( root, "taxi_private_economy" ) or {
            [ 1 ] = 50,
            [ 2 ] = 100,
            [ 3 ] = 150,
            [ 4 ] = 200,
            [ 5 ] = 250,
        }

        local selected

        for class, price in ipairs( costs ) do
            local bg = ibCreateArea( npx, npy, nsx, nsy, parent )
            local bg_img = ibCreateImage( 0, 0, 0, nsy, _, bg, 0xff5680b3 )

            self.elements[ "list_" .. class .. "_bg_img" ] = bg_img
            ibCreateLabel( 12, 0, 0, nsy, "Класс " .. VEHICLE_CLASSES_NAMES[ class ], bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )
            ibCreateLabel( conf.sx - 12, 0, 0, nsy, "за 100м", bg, 0xFFFFFFFF, _, _, "right", "center", ibFonts.regular_9 )
            ibCreateLabel( conf.sx - 80, 0, 0, nsy, price, bg, 0xFFFFFFFF, _, _, "right", "center", ibFonts.regular_10 )
            ibCreateImage( conf.sx - 75, nsy / 2 - 8, 16, 16, ":nrp_shared/img/money_icon.png", bg )
            ibCreateArea(	npx, npy, nsx, nsy, parent )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end

                for class in pairs( costs ) do
                    self.elements[ "list_" .. class .. "_bg_img" ]:ibResizeTo( 0, nsy, 200 )
                end

                bg_img:ibResizeTo( nsx, nsy, 200 )
                selected = class
            end )

            npy = npy + nsy
        end

        function UpdateDescriptionByMouseMove( _, _, pos_x, pos_y )
            if isElement( self.elements.description_box ) then
                self.elements.description_box:ibBatchData( { px = pos_x - 5 - self.elements.description_box:width( ), py = pos_y - self.elements.description_box:ibData( "sy" ) - 5 } )
            end
        end

        ibCreateButton(	51, 296, 100, 30, parent,
                        "img/elements/btn_taxi_call.png", "img/elements/btn_taxi_call.png", "img/elements/btn_taxi_call.png",
                        0xFFFFFFFF, 0xCCFFFFFF, 0xAAFFFFFF )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end       
            if selected then
                if localPlayer:getData("jailed") then
                    localPlayer:ShowError( "В колонии нельзя вызывать такси!" )
                    return
                end
                if localPlayer:GetMoney( ) < costs[ selected ] * 6 or localPlayer:IsInOrAroundWater( ) then return end
                ibClick( )
                StartSearchingForTaxi( { class = selected, tick_start = getTickCount( ) } )
                TAXIAPP:create_search( TAXIAPP.parent, TAXIAPP.conf )
            else
                localPlayer:ShowError( "Класс не выбран!" )
            end
        end )
        :ibOnHover( function( )
            if not selected then return end

            local required_balance = costs[ selected ] * 6
            if localPlayer:GetMoney( ) >= required_balance then return end

            local x, y = guiGetScreenSize( )
            if isElement( self.elements.description_box ) then destroyElement( UI_elements.description_box ) end

            local description_title = "На счету должно быть больше: " .. required_balance .. " р."
            local title_len = dxGetTextWidth( description_title, 1, ibFonts.bold_10 ) + 15
            local pos_x, pos_y = getCursorPosition( )
            pos_x, pos_y = pos_x * x, pos_y * y
        
            self.elements.description_box = ibCreateImage( pos_x - 5, pos_y - 35 - 5, title_len, 35, nil, nil, 0xFFFFFFFF0 - 0x33000000 ):ibData( "alpha", 0 )
            ibCreateLabel( 0, 17, title_len, 0, description_title, self.elements.description_box, 0xFFFFFFFF ):ibBatchData( { font = ibFonts.bold_10, align_x = "center", align_y = "center" } )
                
            self.elements.description_box:ibAlphaTo( 255, 350 )
            addEventHandler( "onClientCursorMove", root, UpdateDescriptionByMouseMove )
        end )
        :ibOnLeave( function( )
            removeEventHandler( "onClientCursorMove", root, UpdateDescriptionByMouseMove )
            if isElement( self.elements.description_box ) then destroyElement( self.elements.description_box ) end
        end )
        :ibOnDestroy( function( )
            removeEventHandler( "onClientCursorMove", root, UpdateDescriptionByMouseMove )
            if isElement( self.elements.description_box ) then destroyElement( self.elements.description_box ) end
        end )
    end,

    create_search = function( self, parent, conf, info )
        DestroyTableElements( self.elements )
        self:create_common_elements( )

        self.elements.search_overlay = ibCreateImage( 0, 0, conf.sx, conf.sy, _, parent, 0x00000000 )
        local parent = self.elements.search_overlay

        local info = SEARCH_INFO

        ibCreateImage( 0, 64, conf.sx, 15, _, parent, 0xFFFFFFFF - 0xF5000000 )
        ibCreateLabel( 14, 64, conf.sx-30, 15, "Поиск такси", parent, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )
        self.elements.l_waiting = ibCreateLabel( conf.sx / 2, 102, 0, 0, "", parent, 0xFFFFFFFF, _, _, "center", "center", ibFonts.regular_10 ):ibData( "colored", true )
        
        local tick_start = info.tick_start or getTickCount( )
        self.elements.fn_update_timer = function( )
            local passed = math.floor( ( getTickCount( ) - tick_start ) / 1000 )
            local minutes = string.format( "%02d", math.floor( passed / 60 ) )
            local seconds = string.format( "%02d", passed % 60 )
            self.elements.l_waiting:ibData( "text", "#999999Идет поиск:#ffffff " .. minutes .. ":" .. seconds )
        end
        self.elements.fn_update_timer( )
        self.elements.waiting_timer = setTimer( self.elements.fn_update_timer, 100, 0 )

        ibCreateButton(	51, 128, 100, 30, parent,
                        "img/elements/btn_taxi_cancel.png", "img/elements/btn_taxi_cancel.png", "img/elements/btn_taxi_cancel.png",
                        0xFFFFFFFF, 0xCCFFFFFF, 0xAAFFFFFF )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )   
            StopSearchingForTaxi( )
            ShowPhoneTaxiApp( )
        end )
    end,

    create_popup_found = function( self, parent, conf, info )
        self:create_common_elements( )

        self.elements.overlay = ibCreateImage( 0, 0, conf.sx, conf.sy, _, parent, 0xBB000000 )
        self.elements.selector_bg = ibCreateImage( conf.sx/2-176/2, 100, 176, 186, "img/elements/races/popup_bg2.png", self.elements.overlay )
        
        ibCreateButton( conf.sx/2+176/2-18, 75, 18, 18, self.elements.overlay, 
                        ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 
                        0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            destroyElement( self.elements.overlay )
        end )

        ibCreateLabel( 0, 20, 176, 0, "НАЙДЕНО", self.elements.selector_bg, 0xFFFFFFFF, _, _, "center", "top", ibFonts.regular_10  )
        ibCreateLabel( 15, 60, 176, 0, "#999999Модель:#ffffff ".. ( info.model_name or "Aventador" ), self.elements.selector_bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 ):ibData( "colored", true )
        ibCreateLabel( 15, 80, 176, 0, "#999999Номер:#ffffff ".. ( info.license_plate or "Х123УЙ" ), self.elements.selector_bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 ):ibData( "colored", true )
        
        ibCreateButton( 176/2-148/2, 105, 148, 28, self.elements.selector_bg,
                        "img/elements/btn_taxi_accept.png", "img/elements/btn_taxi_accept.png", "img/elements/btn_taxi_accept.png", 
                        0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            StopSearchingForTaxi( )
            destroyElement( self.elements.overlay )
            triggerServerEvent( "onPlayerConfirmTaxiDrive", localPlayer, info.vehicle )
        end )

        ibCreateButton( 176/2-148/2, 142, 148, 28, self.elements.selector_bg, 
                        "img/elements/btn_taxi_decline.png", "img/elements/btn_taxi_decline.png", "img/elements/btn_taxi_decline.png", 
                        0xaaFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            destroyElement( self.elements.overlay )
        end )
    end,

    create_waiting_for_driver = function( self, parent, conf, info )
        DestroyTableElements( self.elements )
        self:create_common_elements( )

        ibCreateImage( 0, 64, conf.sx, 15, _, parent, 0xFFFFFFFF - 0xF5000000 )
        ibCreateLabel( 14, 64, conf.sx-30, 15, "Ожидание такси", parent, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )
        ibCreateLabel( 15, 98, 0, 0, "#999999Модель:#ffffff ".. ( info.model_name or "Aventador" ), parent, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 ):ibData( "colored", true )
        ibCreateLabel( 15, 118, 0, 0, "#999999Номер:#ffffff ".. ( info.license_plate or "Х123УЙ" ), parent, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 ):ibData( "colored", true )
        ibCreateLabel( 104, 200, 0, 0, "Примерное время ожидания:", parent, 0xFFFFFFFF - 0x55000000, _, _, "center", "center", ibFonts.regular_10 )

        self.elements.l_waiting_driver_time = ibCreateLabel( 104, 220, 0, 0, "", parent, _, _, _, "center", "center", ibFonts.regular_10 )

        local tick_start = info.tick_start or getTickCount( )
        local tick_left = info.tick_left or 5 * 60

        self.elements.fn_update_waiting_driver_timer = function( )
            local passed = math.floor( ( getTickCount( ) - tick_start ) / 1000 )
            local left = tick_left - passed
            local minutes = string.format( "%02d", math.floor( left / 60 ) )
            local seconds = string.format( "%02d", left % 60 )
            self.elements.l_waiting_driver_time:ibData( "text", minutes .. ":" .. seconds )
        end
        self.elements.fn_update_waiting_driver_timer( )
        self.elements.waiting_driver_timer = setTimer( self.elements.fn_update_waiting_driver_timer, 100, 0 )
    end,

    create_driving = function( self, parent, conf, info )
        DestroyTableElements( self.elements )
        self:create_common_elements( )

        self.elements.lbl_bg = ibCreateImage( 0, 64, conf.sx, 15, _, parent, 0xFFFFFFFF - 0xF5000000 )
        self.elements.lbl_counter = ibCreateLabel( 14, 64, conf.sx-30, 15, "Счетчик", parent, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )
        
        self.elements.lbl_distance = ibCreateLabel( 15, 98, 0, 0, "#999999Вы проехали:#ffffff ".. ( info.distance or 0 ), parent, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 ):ibData( "colored", true )

        local amount = format_price( info.amount or 0 )
        self.elements.lbl_money = ibCreateLabel( 15, 118, 0, 0, "#999999Сумма:#ffffff ".. amount, parent, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 ):ibData( "colored", true )
        self.elements.img_money = ibCreateImage( 15, 110, 16, 16, ":nrp_shared/img/money_icon.png", parent )

        self.elements.lbl_routing = ibCreateLabel( 104, 200, 0, 0, "Вы в пути, по завершению\nзаказа, оцените качество\nпоездки", parent, 0xFFFFFFFF - 0x55000000, _, _, "center", "center", ibFonts.regular_10 )
        
        onPhoneTaxiUpdateCounter_handler( COUNTER )
    end,

    create_rate = function( self, parent, conf )
        DestroyTableElements( self.elements )
        self:create_common_elements( )
        
        local amount = format_price( RATE_PLAYER[ 2 ] or 0 )
        local bg = ibCreateImage( 0, 55, conf.sx, 40, _, parent, 0xff314c4c )
        local lbl_amount = ibCreateLabel( 12, 0, 0, 40, "Оплачено: " .. amount, bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )
        ibCreateImage( 12 + lbl_amount:width( ) + 5, 12, 16, 16, ":nrp_shared/img/money_icon.png", bg )

        local npx, npy = 0, 96
        local nsx, nsy = conf.sx, 40
        for i = 1, 5 do
            local bg = ibCreateArea( npx, npy, nsx, nsy, parent )
            local bg_img = ibCreateImage( 0, 0, 0, nsy, _, bg, 0xff5680b3 )
            self.elements[ "list_" .. i .. "_bg_img" ] = bg_img

            local text = i .. " " .. plural( i, "балл", "балла", "баллов" )
            ibCreateLabel( 12, 0, 0, nsy, text, bg, 0xFFFFFFFF, _, _, "left", "center", ibFonts.regular_10 )

            ibCreateImage( conf.sx - 87 - 12, nsy / 2 - 7, 87, 14, "img/elements/stars/" .. i .. ".png", bg )

            local area = ibCreateArea( npx, npy, nsx, nsy, parent )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "down" then return end       
                for n = 1, 5 do
                    self.elements[ "list_" .. n .. "_bg_img" ]:ibResizeTo( 0, nsy, 200 )
                end
                bg_img:ibResizeTo( nsx, nsy, 200 )
                selected = i
            end )

            if i == 4 then
                area:ibSimulateClick( "left", "down" )
            end

            npy = npy + nsy
        end

        ibCreateButton(	51, 317, 100, 30, parent,
                        "img/elements/btn_taxi_rate.png", "img/elements/btn_taxi_rate.png", "img/elements/btn_taxi_rate.png",
                        0xFFFFFFFF, 0xCCFFFFFF, 0xAAFFFFFF )
        :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end

            if not selected then
                localPlayer:ErrorWindow( "Не выбран рейтинг!" )
                return
            end

            ibClick( )

            triggerServerEvent( "onTaxiPrivateRateRequest", localPlayer, RATE_PLAYER, selected )
            RATE_PLAYER = nil

            localPlayer:ShowInfo( "Спасибо за отзыв!" )
            ShowPhoneUI( false )
        end )
    end,

    destroy = function( self, parent, conf )
        DestroyTableElements( self.elements )
        TAXIAPP = nil
    end,
}

function ShowPhoneTaxiApp( )
    if not GetPhoneState( ) then
        ShowPhoneUI( true )
    end

    if TAXIAPP then TAXIAPP:destroy( ) end
    CreateApplication( "taxi", UI_elements.background, CURRENT_PHONE_CONF.usable_area )
end

-- Таймер поиска водителя
SEARCH_INFO = nil

function StartSearchingForTaxi( search_info )
    StopSearchingForTaxi( )

    SEARCH_INFO = search_info

    local request_num = 0
    TAXI_SEARCH_TIMER = setTimer(
        function( )
            request_num = request_num + 1
            triggerServerEvent( "onTaxiFindRequest", localPlayer, SEARCH_INFO.class, request_num )
        end, 
    5000, 0 )
end

function StopSearchingForTaxi( )
    if isTimer( TAXI_SEARCH_TIMER ) then killTimer( TAXI_SEARCH_TIMER ) end
    TAXI_SEARCH_TIMER = nil
end

function IsSearchingForTaxi( )
    return isTimer( TAXI_SEARCH_TIMER )
end

-- Водитель найден
function onTaxiFindRequest_Found_handler( info )
    StopSearchingForTaxi( )
    ShowPhoneTaxiApp( )
    TAXIAPP:create_popup_found( TAXIAPP.parent, TAXIAPP.conf, info )
    
    --Проверка на вхождения игрока в воду, в то время когда он вызвал Такси
    TAXI_CANCEL_TIMER = setTimer(function(player)
        
        local task, rate_player = GetCurrentTask( ), GetRatePlayer( )
        if player:IsInOrAroundWater( ) then
            
            triggerServerEvent( "onTaxiPrivateFailWaitingCallerEnterInWater", player)
            TAXI_CANCEL_TIMER:destroy()
       
        elseif task and task.state ~= "waiting" then
            
            if isTimer(TAXI_CANCEL_TIMER) then
                TAXI_CANCEL_TIMER:destroy()
                TAXI_CANCEL_TIMER = nil
            end
        
        end
        
    end, 5000, 0, localPlayer)

end
addEvent( "onTaxiFindRequest_Found", true )
addEventHandler( "onTaxiFindRequest_Found", root, onTaxiFindRequest_Found_handler )

function onTaxiStartWaiting_handler( info )
    TAXI_TASK = info
    TAXI_TASK.state = "waiting"
    TAXI_TASK.tick_start = getTickCount( )
    ShowPhoneTaxiApp( )
end
addEvent( "onTaxiStartWaiting", true )
addEventHandler( "onTaxiStartWaiting", root, onTaxiStartWaiting_handler )

function onTaxiStopWaiting_handler( )
    TAXI_TASK.state = nil
    if TAXIAPP then
        ShowPhoneUI( false )
    end
end
addEvent( "onTaxiStopWaiting", true )
addEventHandler( "onTaxiStopWaiting", root, onTaxiStopWaiting_handler )

function onPhoneTaxiSetCounterState_handler( state )
    --iprint( "TAXI TASK", TAXI_TASK )
    if state then
        TAXI_TASK.state = "driving"
        TAXI_TASK.tick_start = getTickCount( )
        ShowPhoneTaxiApp( )
    else
        TAXI_TASK.state = nil
        COUNTER = nil
        --iprint( "TAXI TASK SET NIL" )
        ShowPhoneTaxiApp( )
    end
end
addEvent( "onPhoneTaxiSetCounterState", true )
addEventHandler( "onPhoneTaxiSetCounterState", root, onPhoneTaxiSetCounterState_handler )



function onPhoneTaxiUpdateCounter_handler( counter )
    local counter = counter or { distance = 0, temp_distance = 0, money = 0 }

    --iprint( "Update counter", counter )
    local total_distance = math.floor( counter.distance + counter.temp_distance )

    if TAXIAPP and isElement( TAXIAPP.elements.lbl_distance ) then
        TAXIAPP.elements.lbl_distance:ibData( "text", "#999999Вы проехали:#ffffff " .. total_distance )
        TAXIAPP.elements.lbl_money:ibData( "text", "#999999Сумма:#ffffff " .. counter.money )

        TAXIAPP.elements.img_money:ibData( "px", 15 + TAXIAPP.elements.lbl_money:width( ) + 5 )
    else
        COUNTER = counter
        
    end
end
addEvent( "onPhoneTaxiUpdateCounter", true )
addEventHandler( "onPhoneTaxiUpdateCounter", root, onPhoneTaxiUpdateCounter_handler )

-- triggerClientEvent( self, "onTaxiPrivateRateInfo", self, client_id, force_show )
function onTaxiPrivateRateInfo_handler( info, force_show )
    --iprint( "Rate:", RATE_PLAYER, info )
    RATE_PLAYER = info
    if force_show then
        COUNTER = nil
        ShowPhoneTaxiApp( )
    end
end
addEvent( "onTaxiPrivateRateInfo", true )
addEventHandler( "onTaxiPrivateRateInfo", root, onTaxiPrivateRateInfo_handler )

-- Необходимо рейтнуть
function GetRatePlayer( )
    return RATE_PLAYER
end

-- Текущее состояние игрока
function GetCurrentTask( )
    return TAXI_TASK
end