loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "ib" )
Extend( "ShUtils" )
Extend( "CPlayer" )
Extend( "CPayments" )

ibUseRealFonts( true )

local UI = { }

addEvent( "onPlayerShowDonate", true )

function onPlayerOfferThirdPayment_handler( state, end_time )
    if state then
        UI.black_bg = ibCreateBackground( _, _, true ):ibData( "alpha", 0 )
        UI.bg = ibCreateImage( 0, 0, 1024, 768, "img/bg.png", UI.black_bg ):ibSetRealSize():center( )

        ibCreateButton( 983, 40, 24, 24, UI.bg, ":nrp_shared/img/confirm_btn_close.png", _, _, COLOR_WHITE, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick( function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick( )
            onPlayerOfferThirdPayment_handler( )
        end, false )

        local tick = getTickCount( )
        local label_elements = { { 585,  123 }, { 614, 123 }, { 661, 123 }, { 688, 123 }, { 732, 123 }, { 760, 123 } }
        for i, v in pairs( label_elements ) do
            UI[ "tick_num_" .. i ] = ibCreateLabel( v[ 1 ], v[ 2 ], 0, 0, "0", UI.bg ):ibBatchData( { font = ibFonts.regular_36, align_x = "center", align_y = "center" } )
        end

        local time_left = end_time - getRealTimestamp()
        local function UpdateTimer( )
            local passed = getTickCount( ) - tick
            local time_diff = math.ceil( time_left - passed / 1000 )

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
                local element = UI[ "tick_num_" .. i ]
                if isElement( element ) then
                    element:ibData( "text", utf8.sub( str, i, i ) )
                end
            end
        end
        UI.bg:ibTimer( UpdateTimer, 500, 0 )
        UpdateTimer( )
        
        local buttons = { { 352, 339 }, { 844, 339 }, { 352, 589 }, { 844, 589 } }
        for k, v in ipairs( buttons ) do
            ibCreateButton( v[ 1 ], v[ 2 ], 130, 46, UI.bg, "img/buy.png", "img/buy_h.png" )
            :ibOnClick( function( key, state ) 
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                triggerServerEvent( "onServerThirdPaymentBuyRequest", localPlayer, k )
                onPlayerOfferThirdPayment_handler()
            end )
        end

		ibCreateButton( 845, 706, 149, 34, UI.bg, "img/details.png", "img/details_h.png" )
		:ibOnClick( function( key, state ) 
			if key ~= "left" or state ~= "up" then return end
            ibClick( )
            
            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "premium", "third_payment" )
            
			addEventHandler( "onPlayerShowDonate", root, onPlayerShowDonate_handler )
		end )
		
        UI.black_bg:ibAlphaTo( 255 )
        showCursor( true )
    elseif isElement( UI.black_bg ) then
        destroyElement( UI.black_bg )
        showCursor( false )
    end
end
addEvent( "onPlayerOfferThirdPayment", true )
addEventHandler( "onPlayerOfferThirdPayment", root, onPlayerOfferThirdPayment_handler )

function onPlayerShowDonate_handler( )
    triggerEvent( "onPremiumDescriptionRequest", localPlayer )
    removeEventHandler( "onPlayerShowDonate", root, onPlayerShowDonate_handler )
end

function onStartOfferThirdPaymentRequest_handler( time_left )
    OFFER_THIRD_PAYMENT = getRealTimestamp() + time_left
    localPlayer:setData( "third_payment_end_date", OFFER_THIRD_PAYMENT, false )

    onPlayerOfferThirdPayment_handler( true, OFFER_THIRD_PAYMENT ) 
    triggerEvent( "Show3rdPaymentInfo", localPlayer, time_left )
end
addEvent( "onStartOfferThirdPaymentRequest", true )
addEventHandler( "onStartOfferThirdPaymentRequest", resourceRoot, onStartOfferThirdPaymentRequest_handler )

function ShowOfferThirdPaymentUI_Remembered_handler( )
    local time_left = OFFER_THIRD_PAYMENT - getRealTimestamp()
    if time_left < 0 then return end 
    
    onPlayerOfferThirdPayment_handler( true, OFFER_THIRD_PAYMENT )
end
addEvent( "ShowOfferThirdPaymentUI_Remembered", true )
addEventHandler( "ShowOfferThirdPaymentUI_Remembered", root, ShowOfferThirdPaymentUI_Remembered_handler )