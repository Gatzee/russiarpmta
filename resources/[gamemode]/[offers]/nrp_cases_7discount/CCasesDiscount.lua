Extend( "ib" )
Extend( "CPlayer" )

DISCOUNT_DATA = nil

local UI, UI_REWARDS
local CASES_DATA
local bSynced = false

local SEND_DATA_TIMEOUT = 0
local CHECK_ACTIVE_WINDOWS_TIMER
local RELOAD_WEB_DATA_TIMER
local CONST_GET_DATA_URL

local iSelectedCase = 1
local iCasesAmount = 1
local bCaseContentShown = false
local bFastSpinEnabled = false
local pLightningTimer, bLightningState = false, false
local bMoveSide = true

function ShowUI_7CasesDiscountOnLogin( )
    if CHECK_ACTIVE_WINDOWS_TIMER then return end

    CHECK_ACTIVE_WINDOWS_TIMER = setTimer( function( )
        if ibIsAnyWindowActive( ) then return end

        sourceTimer:destroy( )
        ShowUI_CasesDiscount( true )
    end, 1000, 0 )
end
addEvent( "ShowUI_7CasesDiscountOnLogin", true )
addEventHandler( "ShowUI_7CasesDiscountOnLogin", resourceRoot, ShowUI_7CasesDiscountOnLogin )

function Is7CasesDiscountShown( )
    return UI and isElement( UI.bg )
end

function ShowUI_CasesDiscount( state, data )
	if state then
        if not DISCOUNT_DATA then return end

		if not CASES_DATA then
			LoadWebData( )
			return
		end

        if not bSynced then
            triggerServerEvent("OnClientRequestDiscountData", resourceRoot)
            return
        end

		ShowUI_CasesDiscount( false )
		ibUseRealFonts( true )

		iSelectedCase = data and data.selected_case or 1
        iCasesAmount = 1
        bCaseContentShown = false
        bFastSpinEnabled = false

		-- BG
		UI = { }
        UI_REWARDS = { }
		UI.black_bg = ibCreateBackground( _, _, 0xaa000000 )

		UI.bg = ibCreateImage( 0, 0, 0, 0, "img/bg.png", UI.black_bg )
		:ibSetRealSize( )
		:center( )
		:ibData( "alpha", 0 )
		:ibAlphaTo( 255, 700 )

		local sx, sy = UI.bg:ibData( "sx" ), UI.bg:ibData( "sy" )
		local bg = UI.bg

		UI.btn_close = ibCreateButton( sx - 24 - 26, 26, 24, 24, UI.bg,
                              ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png",
                               0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
            :ibOnClick( function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick( )
                ShowUI_CasesDiscount( false )
            end )

        -- Countdown
        UI.hours = ibCreateLabel( 854, 0, 0, 80, "2", bg, _, _, _, "left", "center", ibFonts.bold_16 )
        :ibData("disabled", true)
        UI.l_hours = ibCreateLabel( UI.hours:ibData("px")+UI.hours:width()+4, 0, 0, 80, "ч.", bg, _, _, _, "left", "center", ibFonts.regular_16 )
        :ibData("disabled", true)

        UI.minutes = ibCreateLabel( UI.l_hours:ibData("px")+UI.l_hours:width()+4, 0, 0, 80, "2", bg, _, _, _, "left", "center", ibFonts.bold_16 )
        :ibData("disabled", true)
        UI.l_minutes = ibCreateLabel( UI.minutes:ibData("px")+UI.minutes:width()+4, 0, 0, 80, "мин.", bg, _, _, _, "left", "center", ibFonts.regular_16 )
        :ibData("disabled", true)

        local function UpdateCountdown()
        	local iSeconds = DISCOUNT_DATA.finish_ts - getRealTimestamp()
        	local iHours = math.floor( iSeconds / 60 / 60 )
        	local iMinutes = math.floor( ( iSeconds - iHours*60*60  ) / 60 )

        	UI.hours:ibData( "text", iHours )
        	UI.minutes:ibData( "text", iMinutes )

        	UI.l_hours:ibData( "px", UI.hours:ibData("px")+UI.hours:width()+4 )
        	UI.minutes:ibData( "px", UI.l_hours:ibData("px")+UI.l_hours:width()+4 )
        	UI.l_minutes:ibData( "px", UI.minutes:ibData("px")+UI.minutes:width()+4 )
        end
        UpdateCountdown()

        UI.hours:ibTimer(UpdateCountdown, 15000, 0)

        -- Progress bar
        UI.pbar_bg = ibCreateImage( 30-12, 146-16, 957, 48, "img/bg_progress_bar.png", bg )

        UI.pbar_body = ibCreateImage( 16, 16, 0, 16, _, UI.pbar_bg, 0xff6cb5ff )
        :ibData("sx", 0)
        :ibTimer(function()
        	UI.pbar_body:ibResizeTo( GetPointBarSize(), _, 700 )
        end, 700, 1)

        UI.points_bg = ibCreateImage( 30-12, 124-12, 84, 84, "img/bg_points.png", bg )
        UI.l_points = ibCreateLabel( 0, 26+12, 86, 0, localPlayer:Get7CasesPoints(), UI.points_bg, _, _, _, "center", "center", ibFonts.oxaniumbold_18 )

        UI.l_delta_points = ibCreateLabel( 0, 0, 84, 0, "+25", UI.points_bg, 0xff9ccaff, _, _, "center", "center", ibFonts.oxaniumbold_12 )
        UI.l_delta_points:ibData( "alpha", 0 )

        -- Rewards
        local px = 220-16-100
        for i, v in pairs( DISCOUNT_DATA.rewards ) do
        	local bIsReceived = IsPointsRewardReceived( i )
        	local pItem = REGISTERED_ITEMS[ v.type ]

        	local rbg = ibCreateImage( px, 48/2-126/2, 126, 126, bIsReceived and "img/reward_received_"..v.bg_color..".png" or "img/bg_reward_"..v.bg_color..".png", UI.pbar_bg )
        	local outline = ibCreateImage( 0, 0, 90, 90, "img/reward_outline_"..v.bg_color..".png", rbg ):center()
        	:ibData("disabled", true)

        	local reward_area = ibCreateArea( 0, 0, 126, 126, rbg )
        	:ibData("disabled", true)
        	:ibData("alpha", bIsReceived and 255*0.1 or 255)

        	if pItem.uiGetDescriptionData then
        		local pDesc = pItem.uiGetDescriptionData( v.id, v )

        		local tooltip_area = ibCreateArea( 10, 10, 106, 106, rbg )
        		:ibAttachTooltip( pDesc.title )
        	end

        	local reward_img = ibCreateRewardImage( 0, 0, 90, 90, v, reward_area )
            reward_img:center( 0, -2 )

            local l_desc

        	if v.desc then
        		l_desc = ibCreateLabel( 0, 90, 126, 0, v.desc, rbg, _, _, _, "center", "center", ibFonts.bold_14 )
        		:ibData("alpha", bIsReceived and 255*0.1 or 255)
        		:ibData("disabled", true)
        	end

        	local check = ibCreateImage( 0, 0, 59, 42, "img/icon_check.png", rbg ):center()
        	:ibData("disabled", true)
            :ibData("visible", bIsReceived)

	        local points_frame = ibCreateImage( 0, 0, 90, 35, "img/bg_reward_points.png", rbg )
            :center()
            :ibData("py", -2)
            :ibAttachTooltip( "Наберите "..v.points.." очков для получения награды" )
            :ibData("visible", not bIsReceived)

	        local l_points = ibCreateLabel( 0, 0, 90, 35, v.points, points_frame, _, _, _, "center", "center", ibFonts.oxaniumbold_12 )
	        :ibData("outline", true)
	        :ibData("disabled", true)

        	px = px + 766 / (#DISCOUNT_DATA.rewards-1)

            UI_REWARDS[ i ] = { bg = rbg, check = check, points = points_frame, received = bIsReceived, area = reward_area, desc = l_desc }
        end

        -- Case data
        local pCaseData = DISCOUNT_DATA.cases[iSelectedCase]
        local pCaseInfo = CASES_DATA[ pCaseData.case_id ]

        UI.slide_rt = ibCreateRenderTarget( 0, 221, sx, 314, bg )
        UI.slide_bg = ibCreateArea( 0, 0, sx, 314, UI.slide_rt )

        UI.case_bg = ibCreateImage( 91, 0, 441, 314, "img/case_1/big_bg.png", UI.slide_bg ):ibData("priority", 1)
        UI.case_lightning = ibCreateImage( 0, 0, 441, 314, "img/case_2/lightning.png", UI.case_bg )
        :ibData("alpha", 0)
        :ibData("disabled", true)

        local line = ibCreateImage( -1, 0, 1, 314, _, UI.case_bg, ibApplyAlpha( 0xff9ccaff, 40 ) )
        local separator = ibCreateImage( 439, -4, 15, 322, "img/separator.png", UI.case_bg ):ibData("priority", 3)

        UI.case_img = ibCreateContentImage( 0, 0, 372, 252, "case", pCaseData.case_id, UI.case_bg )
        :center( 0, -10 )
        :ibData("disabled", true)

        UI.big_discount = ibCreateImage( 441-121, 0, 121, 120, "img/discounts/"..pCaseData.discount..".png", UI.case_bg )

        UI.btn_details = ibCreateButton( 441/2-122/2, 270, 122, 24, UI.case_bg, 
            "img/btn_details_i.png", "img/btn_details_h.png", "img/btn_details_h.png",
            COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        :ibData("priority", 2)
        :ibOnClick(function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            ToggleContentMode()
        end)

        UI.case_info_area = ibCreateArea( 530, 0, 492, 314, UI.slide_bg )
        UI.case_name = ibCreateLabel( 40, 60, 0, 0, pCaseInfo.name, UI.case_info_area, _, _, _, "left", "center", ibFonts.bold_36 )
        UI.case_points_bg = ibCreateImage( UI.case_name:ibGetAfterX(), 20, 84, 84, "img/bg_points.png", UI.case_info_area )
        UI.l_case_points = ibCreateLabel( 0, 26+12, 86, 0, "+"..pCaseData.points, UI.case_points_bg, _, _, _, "center", "center", ibFonts.oxaniumbold_18 )

        UI.l_old_cost = ibCreateLabel( 40, 106, 0, 0, "Старая стоимость:", UI.case_info_area, 
            ibApplyAlpha( COLOR_WHITE, 35 ), _, _, "left", "center", ibFonts.regular_18 )
        UI.l_old_cost_value = ibCreateLabel( UI.l_old_cost:ibGetAfterX( 5 ), 106, 0, 0, pCaseData.old_cost, UI.case_info_area, 
            ibApplyAlpha( COLOR_WHITE, 35 ), _, _, "left", "center", ibFonts.oxaniumbold_24 )

        UI.old_cost_icon = ibCreateImage( UI.l_old_cost_value:ibGetAfterX( 5 ), 106-14, 28, 28, ":nrp_shared/img/hard_money_icon.png", UI.case_info_area, ibApplyAlpha( COLOR_WHITE, 35 ) )
        UI.old_cost_line = ibCreateImage( -3, 0, UI.l_old_cost_value:width()+6+5+28, 1, _, UI.l_old_cost_value, COLOR_WHITE )

        UI.l_cost = ibCreateLabel( 40, 140, 0, 0, "Новая стоимость:", UI.case_info_area, 
            ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_24 )
        UI.l_cost_value = ibCreateLabel( UI.l_cost:ibGetAfterX( 6 ), 140, 0, 0, pCaseData.old_cost, UI.case_info_area, 
            _, _, _, "left", "center", ibFonts.oxaniumbold_36 )

        UI.cost_icon = ibCreateImage( UI.l_cost_value:ibGetAfterX( 5 ), 140-14, 38, 32, "img/icon_hard_big.png", UI.case_info_area )

        -- Count
        local function UpdateBuyCount( value )
            local iNewCasesAmount = iCasesAmount + value
            if iNewCasesAmount <= 0 then 
                iNewCasesAmount = 99
            elseif iNewCasesAmount >= 99 then
                iNewCasesAmount = 1
            end

            iCasesAmount = iNewCasesAmount

            UI.l_cases_count:ibData("text", iCasesAmount)
        end

        UI.l_count = ibCreateLabel( 40, 180, 0, 0, "Выберите количество:", UI.case_info_area, ibApplyAlpha( COLOR_WHITE, 25 ),
            _, _, "left", "center", ibFonts.regular_14 )

        UI.btn_minus = ibCreateButton( 42, 196, 31, 31, UI.case_info_area, 
            "img/btn_minus_i.png", "img/btn_minus_h.png", "img/btn_minus_h.png",
            COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        :ibOnClick(function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            UpdateBuyCount( -1 )
        end)

        UI.btn_plus = ibCreateButton( 42+90, 196, 31, 31, UI.case_info_area, 
            "img/btn_plus_i.png", "img/btn_plus_h.png", "img/btn_plus_h.png",
            COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        :ibOnClick(function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            UpdateBuyCount( 1 )
        end)

        UI.bg_cases_count = ibCreateImage( 42+36, 196, 48, 30, "img/bg_cases_amount.png", UI.case_info_area )
        UI.l_cases_count = ibCreateLabel( 0, 0, 48, 30, iCasesAmount, UI.bg_cases_count, _, _, _, "center", "center", ibFonts.oxaniumbold_18 )

        UI.l_cases_left = ibCreateLabel( 42+90+40, 210, 0, 0, "Осталось:", UI.case_info_area, ibApplyAlpha( COLOR_WHITE, 75 ), _, _, "left", "center", ibFonts.regular_14 )
        UI.l_cases_left_value = ibCreateLabel( UI.l_cases_left:ibGetAfterX(5), 210, 0, 0, "100", UI.case_info_area, _, _, _, "left", "center", ibFonts.oxaniumbold_16 )
        UI.l_cases_left2 = ibCreateLabel( UI.l_cases_left_value:ibGetAfterX(5), 212, 0, 0, "шт.", UI.case_info_area, _, _, _, "left", "center", ibFonts.regular_14 )

        UI.fast_spin_bg = ibCreateImage( 200, 258, 36, 20, "img/bg_fast_spin.png", UI.case_info_area )
        :ibData("alpha", 255*0.4)

        UI.fast_spin_circle = ibCreateImage( 3, 3, 14, 14, "img/fast_spin_circle.png", UI.fast_spin_bg )
        :ibData("disabled", true)

        UI.fast_spin_bg:ibOnClick(function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()

            bFastSpinEnabled = not bFastSpinEnabled

            UI.fast_spin_circle:ibMoveTo( bFastSpinEnabled and 36-3-14 or 3, _, 200 )
            UI.fast_spin_bg:ibAlphaTo( bFastSpinEnabled and 255 or 255*0.4, 200 )
        end)

        UI.l_fast_spin = ibCreateLabel( 200+43, 258, 0, 20, "Быстрая прокрутка", UI.case_info_area, ibApplyAlpha( COLOR_WHITE, 75 ), 
            _, _, "left", "center", ibFonts.bold_14 )

        -- Buy / Open button
        UI.btn_buy = ibCreateButton( 34, 240, 158, 66, UI.case_info_area, 
                "img/btn_buy_i.png", "img/btn_buy_h.png", "img/btn_buy_h.png",
                COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        :ibOnClick(function( key, state )
            if SEND_DATA_TIMEOUT > getTickCount( ) then return end
            SEND_DATA_TIMEOUT = getTickCount( ) + 500

            local pCaseData = DISCOUNT_DATA.cases[ iSelectedCase ]
            local pCaseInfo = CASES_DATA[ pCaseData.case_id ]

            if localPlayer:HasCase( nil, pCaseInfo.id ) then
                triggerServerEvent( "PlayerWantOpenCase", getResourceRootElement( getResourceFromName("nrp_shop") ), pCaseInfo.id, bFastSpinEnabled )
                ibClick( )
            else
                if pCaseInfo.count and pCaseInfo.count < iCasesAmount then
                    if pCaseInfo.count <= 0 then
                        localPlayer:ShowError( "Кейс больше недоступен для покупки" )
                    else
                        localPlayer:ShowError( "На складе нет столько кейсов (доступно ".. pCaseInfo.count .." шт.)" )
                    end
                    return
                end

                if pCaseInfo.purchase_disabled then
                    localPlayer:ShowError( "Кейс больше недоступен для покупки" )
                    return
                end


                if not localPlayer:HasDonate( pCaseData.cost * iCasesAmount ) then
                    triggerEvent( "onShopNotEnoughHard", localPlayer, "Cases", "onCaseReturnToMenu" )
                    return
                end
                ibBuyDonateSound()

                triggerServerEvent( "PlayerWantBuyCase", getResourceRootElement( getResourceFromName("nrp_shop") ), pCaseInfo.id, iCasesAmount )
            end
        end)

        UI.btn_open = ibCreateButton( 34, 240, 158, 66, UI.case_info_area, 
                "img/btn_open_i.png", "img/btn_open_h.png", "img/btn_open_h.png",
                COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        :ibOnClick(function( key, state )
            if SEND_DATA_TIMEOUT > getTickCount( ) then return end
            SEND_DATA_TIMEOUT = getTickCount( ) + 500

            local pCaseData = DISCOUNT_DATA.cases[ iSelectedCase ]
            local pCaseInfo = CASES_DATA[ pCaseData.case_id ]

            triggerServerEvent( "PlayerWantOpenCase", getResourceRootElement( getResourceFromName("nrp_shop") ), pCaseData.case_id, bFastSpinEnabled )
            ibClick( )
        end)


        -- Arrows
        UI.arrow_l = ibCreateButton( 0, 221, 90, 314, bg, "img/arrow_l_i.png", "img/arrow_l_h.png", "img/arrow_l_h.png", 
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        :ibOnClick(function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            if iSelectedCase <= 1 then return end
            SetSelectedCase( iSelectedCase - 1 )
        end)

        UI.arrow_r = ibCreateButton( sx-90, 221, 90, 314, bg, "img/arrow_r_i.png", "img/arrow_r_h.png", "img/arrow_r_h.png", 
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        :ibOnClick(function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            if iSelectedCase >= 7 then return end
            SetSelectedCase( iSelectedCase + 1 )
        end)

        UI.l_total_cases = ibCreateLabel( sx-13, sy-196, 0, 0, "/07", bg, ibApplyAlpha( COLOR_WHITE, 50 ), 
            _, _, "right", "bottom", ibFonts.oxaniumregular_14 )
        UI.l_current_case = ibCreateLabel( sx-13-UI.l_total_cases:width()-2, sy-193, 0, 0, "01", bg, _, 
            _, _, "right", "bottom", ibFonts.oxaniumregular_20 )

        -- Cases selector
        local px = 4
        for i, v in pairs( DISCOUNT_DATA.cases ) do
        	local pCaseData = CASES_DATA[ v.case_id ]

        	UI["case_selector"..i] = ibCreateButton( px, sy-172, 144, 167, bg, 
        							"img/case_"..v.color.."/bg_i.png", "img/case_"..v.color.."/bg_h.png", "img/case_"..v.color.."/bg_a.png", 
        							COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        	
        	UI["case_selector"..i]:ibOnClick(function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()
        		SetSelectedCase( i )
        	end)

        	UI["case_selector"..i]:ibOnHover(function()
        		if iSelectedCase == i then
        			UI.case_selection:ibData("texture", "img/case_"..v.color.."/bg_selected_h.png")
        		end
        	end)

        	UI["case_selector"..i]:ibOnLeave(function()
        		if iSelectedCase == i then
        			UI.case_selection:ibData("texture", "img/case_"..v.color.."/bg_selected_i.png")
        		end
        	end)

        	local content_area = ibCreateArea( 0, 0, 144, 167, UI["case_selector"..i] )
        	:ibData("disabled", true)
        	:ibData("priority", 2)

        	local discount_bg = ibCreateImage( 144-32, 2, 30, 20, "img/bg_corner_discount.png", content_area )
        	:ibData("disabled", true)
        	:ibData("priority", 3)

        	local l_discount = ibCreateLabel( 0, 0, 30, 20, v.discount.."%", discount_bg, _, _, _, "center", "center", ibFonts.oxaniumbold_11 )
        	:ibData("disabled", true)

        	local case_img = ibCreateContentImage( 0, 0, 130, 90, "case", v.case_id, content_area )
        	:ibData("disabled", true)
        	:center()

        	local sName, sFont = GetCaseShortName( pCaseData.name )
        	local case_name = ibCreateLabel( 0, 26, 144, 0, sName, content_area, _, _, _, "center", "center", ibFonts[sFont] )

        	local case_points_bg = ibCreateImage( 90, 36, 52, 51, "img/bg_case_points.png", content_area )
        	:ibData("disabled", true)

        	local l_case_points = ibCreateLabel( 0, 0, 52, 51, "+"..v.points, case_points_bg, _, _, _, "center", "center", ibFonts.oxaniumbold_14 )
        	:ibData("disabled", true)

        	local l_old_cost = ibCreateLabel( 0, 142, 0, 0, v.old_cost, content_area, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.oxaniumregular_14 )
        	:ibData("disabled", true)

        	local l_cost = ibCreateLabel( 0, 140, 0, 0, v.cost, content_area, _, _, _, "left", "center", ibFonts.oxaniumbold_22 )
        	:ibData("disabled", true)

        	local iTotalCostWidth = l_old_cost:width() + l_cost:width() + 28 + 10

        	l_old_cost:ibData( "px", 144/2-iTotalCostWidth/2 )
        	l_cost:ibData( "px", l_old_cost:ibGetAfterX( 5 ) )

        	local icon_money = ibCreateImage( l_cost:ibGetAfterX( 5 ), 140-14, 28, 28, ":nrp_shared/img/hard_money_icon.png", content_area )
        	:ibData("disabled", true)

        	local old_cost_line = ibCreateImage( -3, -1, l_old_cost:width()+6, 1, _, l_old_cost, ibApplyAlpha( COLOR_WHITE, 75 ) )

        	px = px + 145
        end

        SetSelectedCase( iSelectedCase, true )

		showCursor( true )
	else
		DestroyTableElements( UI )
        UI = nil
        UI_REWARDS = nil
		
		showCursor( false )
	end
end
addEvent("ShowUI_7CasesDiscount", true)
addEventHandler("ShowUI_7CasesDiscount", root, ShowUI_CasesDiscount)

function ToggleContentMode()
    bCaseContentShown = not bCaseContentShown

    if bCaseContentShown then
        local pCaseData = DISCOUNT_DATA.cases[iSelectedCase]
        local pCaseInfo = CASES_DATA[ pCaseData.case_id ]

        UI.btn_details:ibAlphaTo( 0, 300, "InOutQuad" )
        UI.btn_details:ibData( "disabled", true )

        UI.arrow_l:ibAlphaTo( 0, 300, "InOutQuad" ):ibData( "disabled", true )
        UI.arrow_r:ibAlphaTo( 0, 300, "InOutQuad" ):ibData( "disabled", true )

        UI.case_bg:ibMoveTo( 1, _, 300, "InOutQuad" )
        UI.case_info_area:ibData("disabled", true)
        UI.case_info_area:ibAlphaTo( 0, 300, "InOutQuad" )

        UI.l_total_cases:ibAlphaTo( 0, 300, "InOutQuad" )
        UI.l_current_case:ibAlphaTo( 0, 300, "InOutQuad" )

        UI.content_bg = ibCreateImage( 1, 0, 581, 315, "img/bg_content.png", UI.slide_bg )
        :ibData("alpha", 0)
        :ibMoveTo( 443, _, 300, "InOutQuad" )
        :ibAlphaTo( 255, 300, "InOutQuad" )

        UI.btn_back = ibCreateButton( 14, 14, 81, 14, UI.content_bg, 
            "img/btn_back_i.png", "img/btn_back_h.png", "img/btn_back_h.png",
            COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        :ibOnClick(function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            ToggleContentMode()
        end)

        UI.btn_close_details = ibCreateButton( 581-15-14, 12, 14, 14, UI.content_bg,
            "img/btn_close_small.png", "img/btn_close_small.png", "img/btn_close_small.png", 
            0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
        :ibOnClick(function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            ToggleContentMode()
        end)

        UI.content_case_name = ibCreateLabel( 0, 0, 581, 40, pCaseInfo.name, UI.content_bg, COLOR_WHITE, _, _, "center", "center", ibFonts.bold_20 )
        :ibData("disabled", true)

        UI.items_pane, UI.scroll_v    = ibCreateScrollpane( 0, 80, 581, 232, UI.content_bg, { scroll_px = -25, bg_color = 0x00FFFFFF } )
        UI.scroll_v:ibData( "sensivity", 0.1 )
        UI.scroll_v:ibData( "alpha", 0.35*255 )

        if next( pCaseInfo.items ) then
            for j, item in pairs( pCaseInfo.items ) do
                if REGISTERED_CASE_ITEMS[ item.id ] then
                    CreateCaseItem( item, 80 + 108 * ( ( j - 1 ) % 4 ), 5 + 108 * math.floor( ( j - 1 ) / 4 ), UI.items_pane )
                end
            end
        end

        UI.items_pane:AdaptHeightToContents( )

        UI.bg:ibTimer(function()
        end, 300, 1)
    else
        UI.btn_details:ibAlphaTo( 255, 300, "InOutQuad" )
        UI.btn_details:ibData( "disabled", false )

        UI.arrow_l:ibAlphaTo( 255, 300, "InOutQuad" ):ibData( "disabled", false )
        UI.arrow_r:ibAlphaTo( 255, 300, "InOutQuad" ):ibData( "disabled", false )

        UI.case_bg:ibMoveTo( 91, _, 300, "InOutQuad" )
        UI.case_info_area:ibData("disabled", false)
        UI.case_info_area:ibAlphaTo( 255, 300, "InOutQuad" )

        UI.l_total_cases:ibAlphaTo( 255, 300, "InOutQuad" )
        UI.l_current_case:ibAlphaTo( 255, 300, "InOutQuad" )

        UI.content_bg:ibMoveTo( 1, _, 300, "InOutQuad" ):ibAlphaTo( 0, 300, "InOutQuad" )

        UI.bg:ibTimer(function()
            destroyElement( UI.content_bg )
        end, 300, 1)
    end
end

function UpdateSelectedCase( ignore_anim )
    local pCaseData = DISCOUNT_DATA.cases[iSelectedCase]
    local pCaseInfo = CASES_DATA[ pCaseData.case_id ]
    local pPlayerCases = localPlayer:GetCases()

    local iCaseSwitchDelay = ignore_anim and 0 or 300

    local bHasCase = pPlayerCases[ pCaseData.case_id ] and pPlayerCases[ pCaseData.case_id ] > 0
    local bIsLimited = pCaseData.color == 3 and pCaseInfo.count and true
    local iLimitedCasesLeft = bIsLimited and pCaseInfo.count
    local iOwnedCasesLeft = pPlayerCases[ pCaseData.case_id ] or 0

    if isTimer( pLightningTimer ) then
        killTimer( pLightningTimer )
    end

    if pCaseData.color >= 2 then
        UI.case_lightning:ibData("alpha", 255)

        pLightningTimer = setTimer(function()
            if not UI or not isElement( UI.case_lightning ) then return end

            bLightningState = not bLightningState
            UI.case_lightning:ibAlphaTo( bLightningState and 0 or 255, 300, "InOutElastic" )
        end, 300, 0)
    else
        UI.case_lightning:ibAlphaTo( 0, 0 )
    end

    UI.slide_bg:ibAlphaTo( 0, iCaseSwitchDelay, "InOutQuad" )
    UI.slide_bg:ibMoveTo( bMoveSide and -900 or 900, _, iCaseSwitchDelay, "InOutQuad" )

    UI.case_info_area:ibTimer(function()
        UI.case_bg:ibData("texture", "img/case_"..pCaseData.color.."/big_bg.png")
        destroyElement( UI.case_img )
        UI.case_img = ibCreateContentImage( 0, 0, 372, 252, "case", pCaseData.case_id, UI.case_bg ):center()
        UI.big_discount:ibData( "texture", "img/discounts/"..pCaseData.discount..".png" )

        if utf8.len( pCaseInfo.name ) >= 14 then
            UI.case_name:ibData( "font", ibFonts.bold_30 )
        else
            UI.case_name:ibData( "font", ibFonts.bold_36 )
        end

        UI.case_name:ibData( "text", pCaseInfo.name )
        UI.case_points_bg:ibData( "px", UI.case_name:ibGetAfterX() )
        UI.l_case_points:ibData( "text", "+"..pCaseData.points )

        -- Cost
        UI.l_old_cost_value:ibData( "text", pCaseData.old_cost)
        UI.old_cost_icon:ibData( "px", UI.l_old_cost_value:ibGetAfterX( 5 ) )
        UI.old_cost_line:ibData( "sx", UI.l_old_cost_value:width()+6+5+28 )

        UI.l_cost_value:ibData( "text", pCaseData.cost )
        UI.cost_icon:ibData( "px", UI.l_cost_value:ibGetAfterX( 5 ) )

        UI.l_current_case:ibData("text", "0"..iSelectedCase)

        if bHasCase then
            UI.btn_buy:ibData("disabled", true):ibData("alpha", 0)
            UI.btn_open:ibData("disabled", false):ibData("alpha", 255)

            UI.l_cases_count:ibData( "text", iOwnedCasesLeft )

            UI.btn_plus:ibData( "alpha", 255*0.5 ):ibData( "disabled", true )
            UI.btn_minus:ibData( "alpha", 255*0.5 ):ibData( "disabled", true )
        else
            UI.btn_buy:ibData("disabled", false):ibData("alpha", 255)
            UI.btn_open:ibData("disabled", true):ibData("alpha", 0)

            UI.btn_plus:ibData( "alpha", 255 ):ibData( "disabled", false )
            UI.btn_minus:ibData( "alpha", 255 ):ibData( "disabled", false )

            UI.l_cases_count:ibData( "text", 1 )
            iCasesAmount = 1
        end

        UI.l_cases_left:ibData("alpha", bIsLimited and 255*0.75 or 0)
        UI.l_cases_left_value:ibData("alpha", bIsLimited and 255 or 0)
        UI.l_cases_left2:ibData("alpha", bIsLimited and 255 or 0)

        if bIsLimited then
            UI.l_cases_left_value:ibData("text", iLimitedCasesLeft)
            UI.l_cases_left2:ibData("px", UI.l_cases_left_value:ibGetAfterX(5))
        end

        UI.slide_bg:ibAlphaTo( 255, iCaseSwitchDelay, "InOutQuad" )
        UI.slide_bg:ibData("px", bMoveSide and 900 or -900)
        UI.slide_bg:ibMoveTo( 0, _, iCaseSwitchDelay, "InOutQuad" )
    end, iCaseSwitchDelay+50, 1)

    if bCaseContentShown then
        UI.content_case_name:ibAlphaTo( 0, iCaseSwitchDelay, "InOutQuad" )
        UI.items_pane:ibAlphaTo( 0, iCaseSwitchDelay, "InOutQuad" )

        UI.content_bg:ibTimer(function()
            UI.items_pane:destroy()
            UI.scroll_v:destroy()

            UI.content_case_name:ibData( "text", pCaseInfo.name )
            :ibAlphaTo( 255, iCaseSwitchDelay, "InOutQuad" )

            UI.items_pane, UI.scroll_v    = ibCreateScrollpane( 0, 80, 581, 232, UI.content_bg, { scroll_px = -25, bg_color = 0x00FFFFFF } )
            UI.scroll_v:ibData( "sensivity", 0.1 )

            UI.items_pane:ibData( "alpha", 0 ):ibAlphaTo( 255, iCaseSwitchDelay, "InOutQuad" )

            if next( pCaseInfo.items ) then
                for j, item in pairs( pCaseInfo.items ) do
                    if REGISTERED_CASE_ITEMS[ item.id ] then
                        CreateCaseItem( item, 80 + 108 * ( ( j - 1 ) % 4 ), 5 + 108 * math.floor( ( j - 1 ) / 4 ), UI.items_pane )
                    end
                end
            end

            UI.items_pane:AdaptHeightToContents( )

        end, iCaseSwitchDelay+50, 1)
    end
end

function SetSelectedCase( id, ignore_anim )
	if not isElement( UI.bg ) then return end

	if isElement( UI.case_selection ) then
		destroyElement( UI.case_selection )
	end

    bMoveSide = iSelectedCase < id

	iSelectedCase = id
	local pCaseData = DISCOUNT_DATA.cases[ iSelectedCase ]

	UI.case_selection = ibCreateImage( 0, 0, 170, 199, "img/case_"..pCaseData.color.."/bg_selected_i.png", UI["case_selector"..id] )
	:center()
	:ibData("py", -20)
	:ibData("disabled", true)

    UpdateSelectedCase( ignore_anim )

    UI.arrow_l:ibData( "disabled", iSelectedCase == 1 and true or false )
    UI.arrow_l:ibData( "alpha", iSelectedCase == 1 and 255*0.5 or 255 )

    UI.arrow_r:ibData( "disabled", iSelectedCase == 7 and true or false )
    UI.arrow_r:ibData( "alpha", iSelectedCase == 7 and 255*0.5 or 255 )
end

-- Utils
function IsPointsRewardReceived( id )
	return DISCOUNT_DATA.rewards[ id ].points <= localPlayer:Get7CasesPoints()
end

function GetCaseShortName( name )
	local sName = string.gsub( name, "Кейс ", "" )
	local iFontSize = 17
	local sFont = "bold_"..iFontSize
	local bIsFits = false

	for i = 1, 3 do
		iFontSize = iFontSize - 1
		sFont = "bold_"..iFontSize

		if dxGetTextWidth( sName, 1, ibFonts[sFont] ) <= 144-20 then
			bIsFits = true
			break
		end
	end

	if not bIsFits then
		sName = utf8.sub( sName, 1, 13 ).."..." 
	end

	return sName, sFont
end

local CONST_RARE_COLORS = {
    [1] = 0xffaff7ff;
    [2] = 0xffa975ff;
    [3] = 0xfffd56ff;
    [4] = 0xffff6464;
    [5] = 0xffffb346;
}

function CreateCaseItem( item, pos_x, pos_y, bg )
    local item_bg       = ibCreateImage( pos_x, pos_y, 96, 96, ":nrp_shop/img/cases/item_bg.png", bg )
    local item_bg_hover = ibCreateImage( 0, 0, 96, 96, ":nrp_shop/img/cases/item_bg_hover.png", item_bg ):ibData( "alpha", 0 )
    ibCreateImage( 16, -9, 65, 29, ":nrp_shop/img/cases/rare.png", item_bg, CONST_RARE_COLORS[ item.rare ] )
    REGISTERED_CASE_ITEMS[ item.id ].uiCreateItem_func( item.id, item.params, item_bg, fonts )

    local description_area  = ibCreateArea( 3, 3, 90, 90, item_bg )
    addEventHandler( "ibOnElementMouseEnter", description_area, function( )
        if isElement( UI.description_box ) then
            destroyElement( UI.description_box )
        end

        item_bg_hover:ibAlphaTo( 255, 350 )

        local description_data = REGISTERED_CASE_ITEMS[ item.id ].uiGetDescriptionData_func( item.id, item.params )
        if description_data then
            local title_len = dxGetTextWidth( description_data.title, 1, ibFonts.bold_15 ) + 30
            local box_s_x = math.max( 170, title_len )
            local box_s_y = 92
            if not description_data.description then
                box_s_x = title_len
                box_s_y = 35
            end

            local pos_x, pos_y = getCursorPosition( )
            pos_x, pos_y = pos_x * _SCREEN_X, pos_y * _SCREEN_Y
    
            UI.description_box = ibCreateImage( pos_x - 5, pos_y - box_s_y - 5, box_s_x, box_s_y, nil, nil, 0xCC000000 )
                :ibData( "alpha", 0 )
                :ibAlphaTo( 255, 350 )
                :ibOnRender( function ( )
                    local cx, cy = getCursorPosition( )
                    cx, cy = cx * _SCREEN_X, cy * _SCREEN_Y
                    UI.description_box:ibBatchData( { px = cx - 5, py = cy - box_s_y - 5 } )
                end )

            ibCreateLabel( 0, 17, box_s_x, 0, description_data.title, UI.description_box ):ibBatchData( { font = ibFonts.bold_15, align_x = "center", align_y = "center" })
            if description_data.description then
                ibCreateLabel( 0, 30, box_s_x, 0, description_data.description, UI.description_box, 0xffd3d3d3 ):ibBatchData( { font = ibFonts.regular_13, align_x = "center", align_y = "top" })
            end
        end
    end, false )

    addEventHandler( "ibOnElementMouseLeave", description_area, function( )
        if isElement( UI.description_box ) then
            destroyElement( UI.description_box )
        end

        item_bg_hover:ibAlphaTo( 0, 350 )
    end, false )

    return item_bg
end

function GetPointBarSize()
    local iLen = 0
    local iPoints = localPlayer:Get7CasesPoints()
    local iBias = 766 / (#DISCOUNT_DATA.rewards-1)

    local px = 220-14-100
    for k, v in pairs( DISCOUNT_DATA.rewards ) do
        if iPoints >= v.points then
            iLen = px
        else
            local iPrevPoints = ( DISCOUNT_DATA.rewards[ k-1 ] and DISCOUNT_DATA.rewards[ k-1 ].points ) or 0
            iLen = iLen + (k > 1 and 90 or 0) + (k > 1 and (iBias-90) or px) * ( ( iPoints - iPrevPoints ) / ( v.points - iPrevPoints ) )
            break
        end

        px = px + iBias
    end

    return iLen
end

function OnClientElementDataChange( key, old_value, value )
    if source ~= localPlayer then return end
    if not UI then return end

    if key == "7cases_points" then
        local fDelta = value - (old_value or 0)

        UI.pbar_body:ibResizeTo( GetPointBarSize(), _, 1000, "InOutQuad" )

        UI.l_delta_points:ibData( "text", "+"..fDelta )
        UI.l_delta_points:ibAlphaTo( 255, 300, "InOutQuad" )

        UI.l_points:ibAlphaTo( 0, 300, "InOutQuad" )
        :ibTimer(function()
            UI.l_points:ibData( "text", localPlayer:Get7CasesPoints() )
            UI.l_points:ibAlphaTo( 255, 300, "InOutQuad" )
        end, 300, 1)

        UI.l_delta_points:ibTimer(function()
            UI.l_delta_points:ibAlphaTo( 0, 300, "InOutQuad" )
        end, 3000, 1)

        UI.l_points:ibTimer(function()
            for i, v in pairs( DISCOUNT_DATA.rewards ) do
                local bIsReceived = IsPointsRewardReceived( i )
                local reward = UI_REWARDS[ i ]

                if bIsReceived and bIsReceived ~= reward.received then
                    reward.received = true
                    reward.bg:ibData( "texture", "img/reward_received_"..v.bg_color..".png" )
                    reward.check:ibAlphaTo( 255, 400, "InOutQuad" ):ibData( "visible", true )
                    reward.points:ibAlphaTo( 0, 400, "InOutQuad" )
                    reward.area:ibAlphaTo( 0.1*255, 400, "InOutQuad" )

                    if reward.desc then
                        reward.desc:ibAlphaTo( 0.1*255, 400, "InOutQuad" )
                    end
                end
            end
        end, 1500, 1)
    elseif key == "cases" then
        SetSelectedCase( iSelectedCase, true )
    end
end
addEventHandler("onClientElementDataChange", localPlayer, OnClientElementDataChange)

function onUpdateCasesCacheGlobalCount_handler( case_id, new_count )
    if not CASES_DATA then return end

    for i, info in pairs( CASES_DATA ) do
        if info.id == case_id then
            info.count = new_count
            break
        end
    end
end
addEvent( "onUpdateCasesCacheGlobalCount", true )
addEventHandler( "onUpdateCasesCacheGlobalCount", root, onUpdateCasesCacheGlobalCount_handler )

function On7CasesDiscountDataReceived( data )
    bSynced = true
    
    if data then
        DISCOUNT_DATA = fromJSON( data )
        DISCOUNT_DATA.cases_reverse = { }

        for i, case in pairs( DISCOUNT_DATA.cases ) do
            DISCOUNT_DATA.cases_reverse[ case.case_id ] = case
        end

        table.sort( DISCOUNT_DATA.cases, function( a, b ) 
            return a.cost < b.cost
        end)

        localPlayer:setData( "7cases_discounts", DISCOUNT_DATA.finish_ts, false )
    else
        localPlayer:setData( "7cases_discounts", false, false )
    end
end
addEvent( "On7CasesDiscountDataReceived", true )
addEventHandler( "On7CasesDiscountDataReceived", resourceRoot, On7CasesDiscountDataReceived )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
    if not bSynced then
        triggerServerEvent("OnClientRequestDiscountData", resourceRoot)
        return
    end
end)

addEventHandler( "onClientResourceStop", resourceRoot, function( )
    localPlayer:setData( "7cases_discounts", false, false )
end)

Player.Get7CasesPoints = function( self )
    return self:getData("7cases_points") or 0
end

function Get7CasesDiscountData()
    return DISCOUNT_DATA
end

function GetCase7CasesDiscountData( case_id )
    local pDiscountData = Get7CasesDiscountData()

    if pDiscountData then
        return pDiscountData.cases_reverse and pDiscountData.cases_reverse[ case_id ]
    end
end

function GetAdditionalCasesIDs( )
    local additional_ids = { }
    for i, v in pairs( DISCOUNT_DATA.cases ) do
        table.insert( additional_ids, v.case_id )
    end
    return additional_ids
end

function LoadWebData( )
    if not CONST_GET_DATA_URL then
        CONST_GET_DATA_URL = exports.nrp_shop:GetConstDataURL( )
    end

    if not CONST_GET_DATA_URL then
        if isTimer( RELOAD_WEB_DATA_TIMER ) then killTimer( RELOAD_WEB_DATA_TIMER ) end
        RELOAD_WEB_DATA_TIMER = setTimer(LoadWebData, 1000, 1)
        return 
    end

    local server = localPlayer:getData( "_srv" )[ 1 ]
    local url = CONST_GET_DATA_URL .. server
    local additional_ids = GetAdditionalCasesIDs( )
    if #additional_ids > 0 then
        url = url .. "?additional=" .. table.concat( additional_ids, "," )
    end

    fetchRemote( url,
        {
            queueName = "f4_data",
            connectionAttempts = 10,
            connectTimeout = 15000,
            method = "GET",
        },
        function( json_data, err )
            -- Если ошибка чтения, но раньше уже читались кейсы
            if ( not err.success or err.statusCode ~= 200 ) then
                UpdateCasesInfo( false )
                return
            end

            local data = fromJSON( json_data )
            UpdateCasesInfo( data.cases_info )
        end
    )
end
addEvent( "onPlayerLoad7CasesWebData", true )
addEventHandler( "onPlayerLoad7CasesWebData", localPlayer, LoadWebData )

function UpdateCasesInfo( cases_info )
    if not cases_info then return end

    CASES_DATA = cases_info
    ShowUI_CasesDiscount( true )
end