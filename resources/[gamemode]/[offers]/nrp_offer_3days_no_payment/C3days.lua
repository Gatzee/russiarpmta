loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "CPayments" )
ibUseRealFonts( true )

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

function onParse3daysOfferPurchase_handler( )
    HidePaymentWindow( )
    Show3days( false )
    ShowCaseInfo( false )
    OFFER_3DAYS_FINISH = nil
    triggerEvent( "Hide3daysInfo", root )
    localPlayer:setData( "3days_offer_finish", false, false )
end
addEvent( "onParse3daysOfferPurchase", true )
addEventHandler( "onParse3daysOfferPurchase", root, onParse3daysOfferPurchase_handler )

function Show3days( state, conf )
    if state then
        Show3days( false )
        local conf = conf or { }

        x, y = guiGetScreenSize( )
        sx, sy = 800, 570
        px, py = ( x - sx ) / 2, ( y - sy ) / 2

        -- Сам фон
        UI_elements.black_bg = ibCreateBackground( 0x99000000, _, true )
        UI_elements.bg = ibCreateImage( px, py - 100, sx, sy, "img/bg.png" ):ibData( "alpha", 0 ):ibMoveTo( px, py, 500 ):ibAlphaTo( 255, 300 )

        -- Таймер акции
        local tick = getTickCount( )
        local label_elements = {
            { 500, 104 },
            { 528-6, 104 },

            { 574-20, 104 },
            { 602-27, 104 },

            { 646-38, 104 },
            { 674-46, 104 },
        }

        for i, v in pairs( label_elements ) do
            UI_elements[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ] + 81, v[ 2 ] - 68, 0, 0, "0", UI_elements.bg ):ibBatchData( { font = ibFonts.regular_21, align_x = "center", align_y = "center" } )
        end

        local function UpdateTimer( )
            local passed = getTickCount( ) - tick
            local time_diff = math.ceil( conf.time_left - passed / 1000 )

            if time_diff < 0 then OFFER_B_LEFT = nil return end

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
            ibClick( )
            Show3days( false )
        end )

        -- Кнопка "Назад"
        local btn_back = ibCreateButton( 0, 0, 41 * 2 + 8, 30 * 2 + 13, UI_elements.bg, nil, nil, nil, 0, 0, 0 )
        local bg_back = ibCreateImage( 20, 22, 30, 30, "img/btn_back_hover.png", btn_back ):ibBatchData( { disabled = true, alpha = 0 } )
        ibCreateImage( 30, 30, 8, 13, "img/btn_back.png", btn_back ):ibBatchData( { disabled = true, alpha = 255 } )
        btn_back:ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            Show3days( false )
            triggerEvent( "ShowUIDonate", root )
        end )
        :ibOnHover( function( ) bg_back:ibAlphaTo( 255, 200 ) end )
        :ibOnLeave( function( ) bg_back:ibAlphaTo( 0, 200 ) end )

        local cases_conf = {
            {
                name = "Минимальный",
                discount = 55,
                amount = 79,
                amount_target = 178,
            },
            {
                name = "Стандарт",
                discount = 58,
                amount = 149,
                amount_target = 347,
            },
            {
                name = "Солидный",
                discount = 60,
                amount = 199,
                amount_target = 496,
            },
            {
                name = "Лучший",
                discount = 62,
                amount = 249,
                amount_target = 645,
            },
        }

        local npx, npy = 1, 73
        local nsx, nsy = 399, 248

        for i = 1, #cases_conf do
            ibCreateImage( npx, npy, nsx, nsy, "img/cases/" .. i .. ".png", UI_elements.bg ):ibSetRealSize( ):ibData( "disabled", true )

            local bg = ibCreateImage( npx, npy, nsx, nsy, "img/cases_bg_hover.png", UI_elements.bg ):ibBatchData( { priority = -1, alpha = 0 } )

            bg
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "down" then return end
                    ibClick( )
                    Show3days( false )
                    ShowCaseInfo( true, { case_num = i, case_conf = cases_conf[ i ] } )
                end )
                :ibOnHover( function( )
                    bg:ibAlphaTo( 255, 200 )
                end )
                :ibOnLeave( function( )
                    bg:ibAlphaTo( 0, 200 )
                end )

            -- Перенос каждые 2 кейса
            if ( i + 1 ) % 2 == 1 then
                npx = 1
                npy = npy + nsy + 1
            else
                npx = npx + nsx + 1
            end
        end
        showCursor( true )
    else
        DestroyTableElements( UI_elements )
        UI_elements = { }
        showCursor( false )
    end
end

function IsCasesListActive( )
    return isElement( UI_elements and UI_elements.bg )
end

function onActivateGroup3daysOffer_handler( url, time_left, is_first_time )
    BASE_URL = url
    OFFER_3DAYS_FINISH = getRealTime( ).timestamp + time_left
    if is_first_time then Show3days( true, { time_left = time_left } ) end
    triggerEvent( "Show3daysInfo", root, time_left )
    localPlayer:setData( "3days_offer_finish", OFFER_3DAYS_FINISH, false )
end
addEvent( "onActivateGroup3daysOffer", true )
addEventHandler( "onActivateGroup3daysOffer", root, onActivateGroup3daysOffer_handler )

function Show3days_Remembered_handler( )
    local time_left = OFFER_3DAYS_FINISH - getRealTime( ).timestamp
    if time_left > 0 then
        Show3days( true, { time_left = time_left } )
    end
end
addEvent( "Show3days_Remembered", true )
addEventHandler( "Show3days_Remembered", root, Show3days_Remembered_handler )