loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "CPayments" )

local UI_elements = { }

function SelectPack( pack_id, sum )
    HidePaymentWindow( )

    local payment_window = ibPayment( )
    payment_window.data = { pack_id = pack_id, sum = sum }
    payment_window.init( )

    UI_elements.payment_window = payment_window
end

function HidePaymentWindow( )
    local payment_window = UI_elements.payment_window
    if payment_window then
        payment_window.destroy( )
        UI_elements.payment_window = nil
    end
end

function onParseOfferPurchase_handler( )
    HidePaymentWindow( )
    ShowX2UI( false )
    OFFER_X2_FINISH = nil
    triggerEvent( "HideSplitOfferInfo", root, "welcome_x2" )
    triggerEvent( "DestroyUIDonate", root )
    localPlayer:setData( "x2_offer_finish", false, false )
end
addEvent( "onParseX2Purchase", true )
addEventHandler( "onParseX2Purchase", root, onParseOfferPurchase_handler )

function ShowX2UI( state, conf )
    if state then
        ShowX2UI( false )
        local conf = conf or { }

        x, y = guiGetScreenSize( )
        sx, sy = 800, 580
        px, py = ( x - sx ) / 2, ( y - sy ) / 2

        -- Сам фон
        UI_elements.black_bg = ibCreateBackground( _, _, true )
        UI_elements.bg = ibCreateImage( px, py - 100, sx, sy, "img/bg_x2.png" ):ibData( "alpha", 0 ):ibMoveTo( px, py, 500 ):ibAlphaTo( 255, 300 )

        -- Таймер акции
        local tick = getTickCount( )
        local label_elements = {
            { 500, 104 },
            { 528-5, 104 },

            { 574-10, 104 },
            { 602-13, 104 },

            { 646-19, 104 },
            { 674-23, 104 },
        }

        for i, v in pairs( label_elements ) do
            UI_elements[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ] - 46, v[ 2 ] + 30, 0, 0, "0", UI_elements.bg ):ibBatchData( { font = ibFonts.regular_22, align_x = "center", align_y = "center" } )
        end

        local function UpdateTimer( )
            local passed = getTickCount( ) - tick
            local time_diff = math.ceil( conf.time_left - passed / 1000 )

            if time_diff < 0 then OFFER_A_LEFT = nil return end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
            local seconds = math.floor( ( ( time_diff - hours * 60 * 60 ) - minutes * 60 ) )

            if hours > 99 then minutes = 60; seconds = 0 end

            hours = string.format( "%02d", math.min( hours, 99 ) )
            minutes = string.format( "%02d", math.min( minutes, 60 ) )
            seconds = string.format( "%02d", seconds )

            local str = hours .. minutes .. seconds

            for i = 1, #label_elements do
                local element = UI_elements[ "tick_num_" .. i ]
                if isElement( element ) then
                    element:ibData( "text", utf8.sub( str, i, i ) )
                end
            end
        end
        UI_elements.timer_timer = Timer( UpdateTimer, 500, 0 )
        UpdateTimer( )

        -- Кнопка "Закрыть"
        ibCreateButton( sx - 24 - 30, 25, 24, 24, UI_elements.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ShowX2UI( false )
        end )

        -- Кнопка "Назад"
        local btn_back = ibCreateButton( 0, 0, 41 * 2 + 8, 30 * 2 + 13, UI_elements.bg, nil, nil, nil, 0, 0, 0 )
        local bg_back = ibCreateImage( 31, 22, 30, 30, "img/btn_back_hover.png", btn_back ):ibBatchData( { disabled = true, alpha = 0 } )
        ibCreateImage( 41, 30, 8, 13, "img/btn_back.png", btn_back ):ibBatchData( { disabled = true, alpha = 255 } )
        btn_back:ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ShowX2UI( false )
            triggerEvent( "ShowUIDonate", root )
        end )
        :ibOnHover( function( ) bg_back:ibAlphaTo( 255, 200 ) end )
        :ibOnLeave( function( ) bg_back:ibAlphaTo( 0, 200 ) end )

        -- Текст х2
        local lbl_x2 = ibCreateLabel( 400, 365, 0, 0, "300", UI_elements.bg ):ibData( "font", ibFonts.bold_12 )

        -- Поле для ввода
        local edit = ibCreateEdit( 400, 278, 280, 30, "150", UI_elements.bg, 0xffffffff, 0x00000000, 0xffffffff )
        :ibBatchData( { font = ibFonts.bold_12, max_length = 20 } )
        :ibOnDataChange( function( key, value )
            if key == "text" then
                if tonumber( value ) then
                    lbl_x2:ibData( "text", tonumber( value ) * 2 )
                else
                    lbl_x2:ibData( "text", "0" )
                end
            end
        end )

        -- Кнопка покупки
        ibCreateButton( 235, 452, 329, 132, UI_elements.bg, "img/btn_buy_x2.png", "img/btn_buy_x2_hover.png", "img/btn_buy_x2_hover.png", 0xFFFFFFFF, 0xFFF0F0F0, 0xFFFFFFFF )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            local amount = tonumber( edit:ibData( "text" ) )
            if amount and amount >= 50 then
                SelectPack( 601, amount )
            else
                localPlayer:ErrorWindow( "Минимальный платеж - 50 р.!" )
            end
        end )

        showCursor( true )
    else
        DestroyTableElements( UI_elements )
        UI_elements = { }
        showCursor( false )
    end
end

function onStartX2Request_handler( time_left, is_first_time, url )
    BASE_URL = url
    OFFER_X2_FINISH = getRealTime( ).timestamp + time_left
    if is_first_time then ShowX2UI( true, { time_left = time_left } ) end
    triggerEvent( "ShowSplitOfferInfo", root, "welcome_x2", time_left )
    localPlayer:setData( "x2_offer_finish", OFFER_X2_FINISH, false )
end
addEvent( "onStartX2Request", true )
addEventHandler( "onStartX2Request", root, onStartX2Request_handler )

function ShowX2UI_Remembered_handler( )
    local time_left = OFFER_X2_FINISH - getRealTime( ).timestamp
    if time_left > 0 then 
        ShowX2UI( true, { time_left = time_left } )
        triggerServerEvent( "onX2Click", localPlayer )
    end
end
addEvent( "ShowX2UI_Remembered", true )
addEventHandler( "ShowX2UI_Remembered", root, ShowX2UI_Remembered_handler )