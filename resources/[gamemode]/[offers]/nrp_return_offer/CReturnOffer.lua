loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "CPayments" )

local UI = { }

local OFFERS_CONF = {
    {
        image = "img/bg_x2.png",
        pack = 601,
        mul = 2,
    },

    {
        image = "img/bg_x3.png",
        pack = 602,
        mul = 3,
    }
}

function SelectPack( pack_id, sum )
    HidePaymentWindow( )
    
    local payment_window = ibPayment( )
    payment_window.data = { pack_id = pack_id, sum = sum }
    payment_window.init( )

    UI.payment_window = payment_window
end

function HidePaymentWindow( )
    local payment_window = UI.payment_window
    if payment_window then
        payment_window.destroy( )
        UI.payment_window.payment_window = nil
    end
end

function ShowOfferUI( state, conf )
    if state then
        local conf = conf or { }

        local offer_conf = OFFERS_CONF[ conf.offer ]
        if not offer_conf then return end

        conf.time_left = conf.time_finish - getRealTime( ).timestamp

        x, y = guiGetScreenSize( )
        sx, sy = 800, 580
        px, py = ( _SCREEN_X - sx ) / 2, ( _SCREEN_Y - sy ) / 2

        -- Сам фон
        UI.black_bg = ibCreateBackground( _, _, true )
        UI.bg = ibCreateImage( px, py - 100, sx, sy, offer_conf.image ):ibData( "alpha", 0 ):ibMoveTo( px, py, 500 ):ibAlphaTo( 255, 300 )

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
            UI[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ] - 46, v[ 2 ] + 30, 0, 0, "0", UI.bg ):ibBatchData( { font = ibFonts.regular_22, align_x = "center", align_y = "center" } )
        end

        local function UpdateTimer( )
            local passed = getTickCount( ) - tick
            local time_diff = math.ceil( conf.time_left - passed / 1000 )

            if time_diff < 0 then
                ResetOffer( )
                return
            end

            local hours = math.floor( time_diff / 60 / 60 )
            local minutes = math.floor( ( time_diff - hours * 60 * 60 ) / 60 )
            local seconds = math.floor( ( ( time_diff - hours * 60 * 60 ) - minutes * 60 ) )

            if hours > 99 then minutes = 60; seconds = 0 end

            hours = string.format( "%02d", math.min( hours, 99 ) )
            minutes = string.format( "%02d", math.min( minutes, 60 ) )
            seconds = string.format( "%02d", seconds )

            local str = hours .. minutes .. seconds

            for i = 1, #label_elements do
                local element = UI[ "tick_num_" .. i ]
                if isElement( element ) then
                    element:ibData( "text", utf8.sub( str, i, i ) )
                end
            end
        end
        UI.timer_timer = Timer( UpdateTimer, 500, 0 )
        UpdateTimer( )

        -- Кнопка "Закрыть"
        ibCreateButton( sx - 24 - 30, 25, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ShowOfferUI( false )
            end )

        -- Кнопка "Назад"
        local btn_back = ibCreateButton( 0, 0, 41 * 2 + 8, 30 * 2 + 13, UI.bg, nil, nil, nil, 0, 0, 0 )
        local bg_back = ibCreateImage( 31, 22, 30, 30, "img/btn_back_hover.png", btn_back ):ibBatchData( { disabled = true, alpha = 0 } )
        ibCreateImage( 41, 30, 8, 13, "img/btn_back.png", btn_back ):ibBatchData( { disabled = true, alpha = 255 } )
        btn_back
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ShowOfferUI( false )
                triggerEvent( "ShowUIDonate", root )
            end )
            :ibOnHover( function( ) bg_back:ibAlphaTo( 255, 200 ) end )
            :ibOnLeave( function( ) bg_back:ibAlphaTo( 0, 200 ) end )

        -- Текст
        local lbl_increased = ibCreateLabel( 400, 365, 0, 0, "300", UI.bg ):ibData( "font", ibFonts.bold_12 )

        -- Поле для ввода
        local edit = ibCreateEdit( 400, 278, 280, 30, "150", UI.bg, 0xffffffff, 0x00000000, 0xffffffff )
            :ibBatchData( { font = ibFonts.bold_12, max_length = 20 } )
            :ibOnDataChange( function( key, value )
                if key == "text" then
                    if tonumber( value ) then
                        lbl_increased:ibData( "text", tonumber( value ) * offer_conf.mul )
                    else
                        lbl_increased:ibData( "text", "0" )
                    end
                end
            end )

        lbl_increased:ibData( "text", ( tonumber( edit:ibData( "text" ) ) or 0 ) * offer_conf.mul )

        -- Кнопка покупки
        ibCreateButton( 235, 452, 329, 132, UI.bg, "img/btn_buy_x2.png", "img/btn_buy_x2_hover.png", "img/btn_buy_x2_hover.png", 0xFFFFFFFF, 0xFFF0F0F0, 0xFFFFFFFF )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                local amount = tonumber( edit:ibData( "text" ) )
                if amount and amount >= 50 then
                    SelectPack( offer_conf.pack, amount )
                else
                    localPlayer:ErrorWindow( "Минимальный платеж - 50 р.!" )
                end
            end )

        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = { }
        showCursor( false )
    end
end

function onClientPlayerStartOffer_handler( segment, time_left, first_time )
    CURRENT_OFFER_DATA = { offer = segment, time_finish = getRealTime( ).timestamp + time_left }
    localPlayer:setData( "offer_data", CURRENT_OFFER_DATA, false )

    if first_time then ShowOfferUI( true, CURRENT_OFFER_DATA ) end
end
addEvent( "onClientPlayerStartOffer", true )
addEventHandler( "onClientPlayerStartOffer", root, onClientPlayerStartOffer_handler )

function onClientPlayerShowCurrentOfferRequest_handler( )
    if CURRENT_OFFER_DATA then ShowOfferUI( true, CURRENT_OFFER_DATA ) end
end
addEvent( "onClientPlayerShowCurrentOfferRequest" )
addEventHandler( "onClientPlayerShowCurrentOfferRequest", root, onClientPlayerShowCurrentOfferRequest_handler )

function ResetOffer( )
    localPlayer:setData( "offer_data", false, false )
    HidePaymentWindow( )
    ShowOfferUI( false )
end
addEvent( "onClientPlayerResetOffer", true )
addEventHandler( "onClientPlayerResetOffer", root, ResetOffer )

--ShowOfferUI( true, { offer = 2, time_left = 24 * 60 * 60 } )

--[[function onStartX2Request_handler( time_left, is_first_time, url )
    BASE_URL = url
    OFFER_X2_FINISH = getRealTime( ).timestamp + time_left
    if is_first_time then ShowOfferUI( true, { time_left = time_left } ) end
    triggerEvent( "ShowSplitOfferInfo", root, time_left )
    localPlayer:setData( "x2_offer_finish", OFFER_X2_FINISH, false )
end
addEvent( "onStartX2Request", true )
addEventHandler( "onStartX2Request", root, onStartX2Request_handler )

function ShowOfferUI_Remembered_handler( )
    local time_left = OFFER_X2_FINISH - getRealTime( ).timestamp
    if time_left > 0 then 
        ShowOfferUI( true, { time_left = time_left } )
        triggerServerEvent( "onX2Click", localPlayer )
    end
end
addEvent( "ShowOfferUI_Remembered", true )
addEventHandler( "ShowOfferUI_Remembered", root, ShowOfferUI_Remembered_handler )]]