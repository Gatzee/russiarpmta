Extend( "CPlayer" )
Extend( "ib" )
Extend( "ShUtils" )

ibUseRealFonts( true )

UI = { }
DATA = { }

function ReceiveRegisteredTuningCases_handler( cases_info, vehicle_tier )
    PreShowUICases( "tuning", cases_info, nil, vehicle_tier )
end
addEvent( "ReceiveRegisteredTuningCases", true )
addEventHandler( "ReceiveRegisteredTuningCases", root, ReceiveRegisteredTuningCases_handler )

function ReceiveRegisteredVinylCases_handler( cases_info, last_item, vehicle_tier )
    for case_id, case_info in pairs( cases_info ) do
        for _, item in pairs( case_info.items ) do
			item.params = FixTableData( item.params )

			item.params[ P_CLASS ] = CASE_CLASSES[ case_id ]
			item.params[ P_IMAGE ] = item.params[ P_NAME ]
			item.params[ P_PRICE ] = tonumber( item.cost )
            item.params[ P_PRICE_TYPE ] = case_info.cost_is_soft and "soft" or "hard"
            
            item.img = ":nrp_vinyls/img/" .. item.params[ P_NAME ] .. ".dds"
        end
    end

    PreShowUICases( "vinyl", cases_info, last_item, vehicle_tier )
end
addEvent( "ReceiveRegisteredVinylCases", true )
addEventHandler( "ReceiveRegisteredVinylCases", root, ReceiveRegisteredVinylCases_handler )

function PreShowUICases( case_type, cases_info, last_item, vehicle_tier, parts )
    local cases = { }

    if case_type == "tuning" then
        for case_id, case in pairs( cases_info ) do
            local charOfClass = VEHICLE_CLASSES_NAMES[ vehicle_tier ]

            if case.items[ charOfClass ] and case.prices[ charOfClass ] then
                table.insert( cases, {
                    id = case_id,
                    type = "tuning",
                    name = "Кейс " .. case.name,
                    description = case.description,
                    cost = case.prices[ charOfClass ].cost,
                    img = "tuning_" .. case_id,
                    class = charOfClass,
                    items = case.items[ charOfClass ],
                    tier = vehicle_tier,
                    cost_is_soft = case.prices[ charOfClass ].currency == "soft" and true or false
                } )
            end
        end

        table.sort( cases, function( a, b ) return a.id > b.id end )
    else
        for case_id, case_info in pairs( cases_info ) do
            table.insert( cases, case_info )

            case_info.id = case_id
            case_info.type = case_type
            case_info.class = VEHICLE_CLASSES_NAMES[ vehicle_tier ]

            local case_num = CASE_CONVERSIONS[ case_info.type ][ case_id ]
            case_info.name = "Кейс " .. CASES[ case_info.type ][ case_num ]
            case_info.img = "vinyl_" .. CASE_CONVERSIONS[ case_info.type ][ case_num ]
            case_info.description = CASE_TEXTS[ case_info.type ][ case_num ] or ""

            iprint( case_id, "<<<" )
        end

        table.sort( cases, function( a, b ) return a.id < b.id end )
    end

    ShowUICasesList( true, cases, case_type )

    if last_item then
        ShowTuningCasesReward( last_item, case_type )
    end

	SendElasticGameEvent( case_type .. "_case_window_open" )
end

function ShowUICasesList( state, cases, case_type )
    if state and not UI.black_bg then
        UI.black_bg = ibCreateBackground( 0xBF1D252E )
                :ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )

        showCursor( true )

        UI.bg = ibCreateImage( 0, 0, 1024, 768, _, UI.black_bg, 0xFF475d75 ):center( )

        UI.head_bg  = ibCreateImage( 0, 0, UI.bg:ibData( "sx" ), 80, _, UI.bg, 0x1A000000 )
        ibCreateImage( 0, UI.head_bg:ibGetAfterY( -1 ), UI.bg:ibData( "sx" ), 1, _, UI.head_bg, 0x1Affffff )

        local head_text = "Кейсы " .. ( case_type == "tuning" and "с деталями" or "с винилами" )
        ibCreateLabel( 30, 0, 0, UI.head_bg:ibData( "sy" ), head_text, UI.head_bg, COLOR_WHITE, 1, 1, "left", "center", ibFonts.bold_20 )

        UI.btn_close = ibCreateButton( UI.bg:ibData( "sx" ) - 55, 24, 25, 25, UI.head_bg,
                ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                0xFFCCCCCC, 0xFFFFFFFF, 0xFFCCCCCC )
                :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            ShowUICasesList( false )
        end )

        UI.balance_area = ibCreateArea( 0, 0, 100, UI.head_bg:ibData( "sy" ), UI.head_bg )
        UI.account_img = ibCreateImage( 0, 0, 40, 40, ":nrp_shop/img/icon_account.png", UI.balance_area ):center_y( )
        UI.balance_text_lbl = ibCreateLabel( 55, 20, 0, 0, "Ваш баланс:", UI.balance_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.regular_14 )
        UI.balance_lbl = ibCreateLabel( UI.balance_text_lbl:ibGetAfterX( 8 ), 16, 0, 0, format_price( localPlayer:GetMoney( ) ), UI.balance_area, COLOR_WHITE, 1, 1, "left", "top", ibFonts.bold_18 )
        UI.balance_money_img = ibCreateImage( UI.balance_lbl:ibGetAfterX( 8 ), 16, 24, 24, ":nrp_shared/img/money_icon.png", UI.balance_area )
        UI.btn_recharge = ibCreateButton( 0, 22, 115, 21, UI.balance_text_lbl,
                "images/btn_recharge.png", "images/btn_recharge.png", "images/btn_recharge.png",
                0xFFFFFFFF, 0xAAFFFFFF, 0x70FFFFFF )
                :ibOnClick( function( button, state )
            if button ~= "left" or state ~= "up" then return end
            ibClick( )

            triggerServerEvent( "onPlayerRequestDonateMenu", localPlayer, "donate", "tuning_cases_list" )
            ShowUICasesList( false )
        end )

        local function UpdateBalance( )
            UI.balance_lbl:ibData( "text", format_price( localPlayer:GetMoney( ) ) )
            UI.balance_money_img:ibData( "px", UI.balance_lbl:ibGetAfterX( 8 ) )
            UI.balance_area:ibData( "px", UI.btn_close:ibGetBeforeX( -30 - UI.balance_money_img:ibGetAfterX( ) ) )
        end
        UpdateBalance( )
        UI.balance_area:ibTimer( UpdateBalance, 1000, 0 )

        UI.scrollpane, UI.scrollbar = ibCreateScrollpane( 0, UI.head_bg:ibGetAfterY( ),
                UI.bg:ibData( "sx" ), UI.bg:ibData( "sy" ) - UI.head_bg:ibData( "sy" ),
                UI.bg, { scroll_px = -20 }
        )
        UI.scrollbar:ibSetStyle( "slim_nobg" )

        local case_sx, case_sy = 472, 360
        local gap = 20
        for i, case_info in pairs( cases ) do
            local case_px = 30 + ( i - 1 ) % 2 * ( case_sx + gap )
            local case_py = 20 + math.floor( ( i - 1 ) / 2 ) * ( case_sy + gap )
            local case_bg = ibCreateImage( case_px, case_py, case_sx, case_sy, "images/case_bg.png", UI.scrollpane )
            local case_bg_hover = ibCreateImage( 0, 0, case_sx, case_sy, "images/case_bg_hover.png", case_bg )
                    :ibData( "alpha", 0 )

            local case_name = ibCreateLabel( 0, 20, 0, 0, case_info.name, case_bg )
                    :ibBatchData( { font = ibFonts.regular_18, align_x = "center" } ):center_x( )

            local case_img = ibCreateContentImage( 0, 0, 472, 360, "case", case_info.img, case_bg )
            :center( 0, 5 )

            local class_img = ibCreateImage( 0, 0, 30, 21, "images/class_bg.png", case_img )
                    :center( case_type == "tuning" and 147 or 137, 86 )
            ibCreateLabel( 0, 0, 30, 21, case_info.class, class_img )
                    :ibBatchData( { font = ibFonts.bold_12, align_x = "center", align_y = "center" } ):center( )

            local cost_area = ibCreateArea( 0, case_sy - 51, 0, 0, case_bg )
            local cost = exports.nrp_tuning_shop:ApplyDiscount( case_info.cost )
            local cost_lbl = ibCreateLabel( 0, 0, 0, 0, format_price( cost ), cost_area )
                    :ibBatchData( { font = ibFonts.bold_26 })
            local cost_icon = ibCreateImage( cost_lbl:ibGetAfterX( 8 ), 4, 28, 28,
                    ":nrp_shared/img/".. ( case_info.cost_is_soft and "" or "hard_" ) .."money_icon.png", cost_area )
            cost_area:ibData( "sx", cost_icon:ibGetAfterX( ) ):center_x( )

            ibCreateArea( case_px, case_py, case_sx, case_sy, UI.scrollpane )
                    :ibOnHover( function( )
                case_bg_hover:ibAlphaTo( 255, 250 )
            end )
                    :ibOnLeave( function( )
                case_bg_hover:ibAlphaTo( 0, 250 )
            end )
                    :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )

                UI.bg:ibMoveTo( - UI.bg:ibData( "sx" ), _, 500, "OutBack" )

                ShowUICaseInfo( case_info )

                UI.info_bg:ibData( "px", _SCREEN_X ):ibMoveTo( _SCREEN_X / 2 - UI.info_bg:ibData( "sx" ) / 2, _, 500, "OutBack" )
            end )

            if i == #cases then ibCreateArea( 0, case_py + case_sy, gap, gap, UI.scrollpane ) end -- fix adaptive
        end

        UI.scrollpane:AdaptHeightToContents()
        UI.scrollbar:UpdateScrollbarVisibility( UI.scrollpane )
    elseif not state and UI.black_bg then
        showCursor( false )
        DestroyTableElements( UI )
        UI = { }
    end
end