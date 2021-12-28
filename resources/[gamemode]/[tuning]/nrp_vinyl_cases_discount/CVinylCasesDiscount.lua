Extend( "CPlayer" )
Extend( "ib" )

ibUseRealFonts( true )

OFFER_START_DATE = 0
OFFER_END_DATE = 0
DISCOUNTS = {}

local UI

function ShowVinylCasesDiscountUI( state, cases, discounts )
    if state then
        ShowVinylCasesDiscountUI( false )

        UI = { }
        UI.black_bg = ibCreateBackground( _, _, true )

        local elastic_duration  = 2200
        local alpha_duration    = 700

        UI.bg = ibCreateImage( 0, 0, 0, 0, "img/bg.png", UI.black_bg )
            :ibSetRealSize( )
            :center( 0, -100 )
            :ibData( "alpha", 0 )
            :ibMoveTo( 0, 100, elastic_duration, "OutElastic", true ):ibAlphaTo( 255, alpha_duration )

        local bg_sx = UI.bg:ibData( "sx" )
        local bg_sy = UI.bg:ibData( "sy" )

        UI.btn_close = ibCreateButton( bg_sx - 24 - 26, 24, 24, 24, UI.bg,
            ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                ShowVinylCasesDiscountUI( false )
            end )

        UI.balance_area = ibCreateArea( 0, 0, 100, 80, UI.bg )
        UI.account_img = ibCreateImage( 0, 0, 40, 40, ":nrp_shop/img/icon_account.png", UI.balance_area ):center_y( )
        UI.balance_text_lbl = ibCreateLabel( 55, 20, 0, 0, "Ваш баланс:", UI.balance_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_14 )
        UI.balance_lbl = ibCreateLabel( UI.balance_text_lbl:ibGetAfterX( 8 ), 16, 0, 0, format_price( localPlayer:GetMoney( ) ), UI.balance_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
        UI.balance_money_img = ibCreateImage( UI.balance_lbl:ibGetAfterX( 8 ), 16, 24, 24, ":nrp_shared/img/money_icon.png", UI.balance_area )
        UI.btn_recharge = ibCreateButton( 0, 22, 115, 21, UI.balance_text_lbl, 
            ":nrp_tuning_cases/images/btn_recharge.png", ":nrp_tuning_cases/images/btn_recharge.png", ":nrp_tuning_cases/images/btn_recharge.png", 
            0xFFFFFFFF, 0xAAFFFFFF, 0x70FFFFFF )
            :ibOnClick( function( button, state )
                if button ~= "left" or state ~= "up" then return end
                ibClick( )

                triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate", "vinyl_cases_discount" )
                ShowVinylCasesDiscountUI( false )
            end )
            
        local function UpdateBalance( )
            UI.balance_lbl:ibData( "text", format_price( localPlayer:GetMoney( ) ) )
            UI.balance_money_img:ibData( "px", UI.balance_lbl:ibGetAfterX( 8 ) )
            UI.balance_area:ibData( "px", UI.btn_close:ibGetBeforeX( -30 - UI.balance_money_img:ibGetAfterX( ) ) )
        end
        UpdateBalance( )
        UI.balance_area:ibTimer( UpdateBalance, 1000, 0 )

        local cols_count = 3
        local col_sx = bg_sx / 3

        for col_i = 1, cols_count do
            local col_area = ibCreateArea( ( col_i - 1 ) * col_sx, 0, col_sx, bg_sy, UI.bg )
                :ibData( "priority", -1 )

            local discount_lbl = ibCreateLabel( 0, 124, 0, 0, "Выгода 10%", col_area )
                :ibBatchData( { font = ibFonts.bold_14, align_x = "center", align_y = "center" } )
                :center_x( )

            local case_info = cases[ col_i ]

            local class_img = ibCreateImage( 271, 353, 30, 21, ":nrp_tuning_cases/images/class_bg.png", col_area )
            ibCreateLabel( 0, 0, 30, 21, case_info.class, class_img )
                :ibBatchData( { font = ibFonts.bold_12, align_x = "center", align_y = "center" } ):center( )
            
            local selected_discount = discounts[ 1 ]
            local case_cost = exports.nrp_tuning_shop:ApplyDiscount( case_info.cost )
        
            local cost_area = ibCreateArea( 0, 430, 0, 0, col_area )
            local cost_lbl = ibCreateLabel( 0, 0, 0, 0, format_price( case_cost ), cost_area )
                :ibBatchData( { font = ibFonts.bold_26 } ):center_y( )
            local cost_img = ibCreateImage( cost_lbl:ibGetAfterX( 10 ), 4, 28, 28, 
                ":nrp_shared/img/".. ( case_info.cost_is_soft and "" or "hard_" ) .."money_icon.png", cost_area )
            cost_area:ibData( "sx", cost_img:ibGetAfterX( ) ):center_x( )
        
            local function UpdateCost( )
                cost_lbl:ibData( "text", format_price( case_cost * selected_discount.buy_count * ( 1 - selected_discount.value ) ) )
                cost_img:ibData( "px", cost_lbl:ibGetAfterX( 10 ) )
                cost_area:ibData( "sx", cost_img:ibGetAfterX( ) ):center_x( )
            end
            UpdateCost( )

            local count_selector_area = ibCreateArea( 0, 594, 0, 0, col_area )
            local selected_count_btn
            for i, discount in pairs( discounts ) do
                local count_bg = ibCreateImage( ( i - 1 ) * ( 48 + 20 ), 0, 48, 30, "img/count_bg.png", count_selector_area )
                    :ibData( "alpha", 38 )
                    :ibOnHover( function( )
                        if source == selected_count_btn then return end
                        source:ibAlphaTo( 128, 250 )
                    end )
                    :ibOnLeave( function( )
                        if source == selected_count_btn then return end
                        source:ibAlphaTo( 38, 250 )
                    end )
                    :ibOnClick( function( key, state )
                        if key ~= "left" or state ~= "up" then return end
                        if source == selected_count_btn then return end
                        ibClick( )

                        selected_count_btn:ibData( "texture", "img/count_bg.png" )
                        selected_count_btn:ibAlphaTo( 38, 250 )
                        source:ibData( "texture", "img/count_bg_active.png" )
                        selected_count_btn = source

                        discount_lbl:ibData( "text", "Выгода " .. math.floor(( discount.value * 100 )) .. "%" )

                        selected_discount = discount
                        UpdateCost( )
                    end )

                ibCreateLabel( count_bg:ibGetCenterX( ), count_bg:ibGetCenterY( ), 0, 0, discount.buy_count, count_selector_area )
                    :ibBatchData( { font = ibFonts.bold_17, align_x = "center", align_y = "center" } )

                count_selector_area:ibData( "sx", count_bg:ibGetAfterX( ) )
                if i == 1 then
                    count_bg:ibData( "alpha", 128 )
                    count_bg:ibData( "texture", "img/count_bg_active.png" )
                    selected_count_btn = count_bg
                end
            end
            count_selector_area:center_x( )

            local btn_buy_click_area = ibCreateArea( 0, bg_sy - 30 - 44, 140, 44, col_area )
                :center_x( )
                :ibData( "alpha", 0 )
                :ibOnHover( function( ) source:ibAlphaTo( 255, 350 ) end )
                :ibOnLeave( function( ) source:ibAlphaTo( 0, 350 ) end )
                :ibOnClick( function( key, state )
                    if key ~= "left" or state ~= "up" then return end
                    ibClick( )

                    local total_cost = case_cost * ( 1 - selected_discount.value ) * selected_discount.buy_count
                    if case_info.cost_is_soft then
                        if not localPlayer:HasMoney( total_cost ) then
                            localPlayer:ShowError( "Недостаточно средств" )
                            return
                        end
                    else
                        if not localPlayer:HasDonate( total_cost ) then
                            localPlayer:ShowError( "Недостаточно средств" )
                            return
                        end
                    end
        
                    triggerServerEvent( "PlayerWantBuyVinylCasesWithDiscount", resourceRoot, case_info.id, selected_discount.id )
                end )

            ibCreateImage( 0, 0, 0, 0, "img/btn_buy.png", btn_buy_click_area )
                :ibData( "disabled", true )
                :ibSetRealSize( )
                :center( )
        end

        showCursor( true )
    else
        DestroyTableElements( UI )
        UI = nil
        showCursor( false )
    end
end

addEvent( "ShowVinylCasesDiscountUI", true )
addEventHandler( "ShowVinylCasesDiscountUI", root, function( cases_info, vehicle_tier, discounts )
    local cases = { }
    for case_id, case in pairs( cases_info ) do
        case.id = case_id
        case.class = vehicle_tier
        table.insert( cases, case )
    end
    table.sort( cases, function( a, b ) return a.id < b.id end )

    ShowVinylCasesDiscountUI( true, cases, discounts )
end )

function GetOfferEndTime( )
    return OFFER_END_DATE
end
function IsOfferActive()
	local ts = getRealTimestamp( )
    return ts >= OFFER_START_DATE and ts <= OFFER_END_DATE
end

addEvent( "UpdateVinylDiscounts", true )
addEventHandler( "UpdateVinylDiscounts", root, function( start_date, finish_date, discounts )
	DISCOUNTS = discounts
	OFFER_START_DATE = start_date
	OFFER_END_DATE = finish_date
end )