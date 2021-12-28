Extend( "ib" )
Extend( "CPlayer" )
Extend( "cases/Client" )

DISCOUNT_DATA = nil

local CASE_AMOUNTS = { 3, 6, 9, 12 }

local UI
local bSynced = false

local SEND_DATA_TIMEOUT = 0
local CHECK_ACTIVE_WINDOWS_TIMER

local iSelectedCase = 1
local iCasesAmount = 3
local bCaseContentShown = false
local bFastSpinEnabled = false
local pLightningTimer, bLightningState = false, false
local bMoveSide = true

function ShowUI_WholesomeCaseDiscountOnLogin( )
    if CHECK_ACTIVE_WINDOWS_TIMER then return end

    CHECK_ACTIVE_WINDOWS_TIMER = setTimer( function( )
        if ibIsAnyWindowActive( ) then return end

        sourceTimer:destroy( )
        ShowUI_CasesDiscount( true )
    end, 1000, 0 )
end
addEvent( "ShowUI_WholesomeCaseDiscountOnLogin", true )
addEventHandler( "ShowUI_WholesomeCaseDiscountOnLogin", resourceRoot, ShowUI_WholesomeCaseDiscountOnLogin )

function IsWholesomeCaseDiscountShown( )
    return UI and isElement( UI.bg )
end

function ShowUI_CasesDiscount( state, data )
	if state then
        if not DISCOUNT_DATA then return end

		if not WEB_CASES_DATA then
			LoadCasesWebData( GetAdditionalCasesIDs( ), "ShowUI_WholesomeCaseDiscount", true )
			return
		end

        if not bSynced then
            triggerServerEvent("OnClientRequestDiscountData", resourceRoot)
            return
        end

		ShowUI_CasesDiscount( false )
		ibUseRealFonts( true )

        addEventHandler( "onClientKey", root, EscapeKeyHandler )

		iSelectedCase = data and data.selected_case or 1
        iCasesAmount = 3
        bCaseContentShown = false
        bFastSpinEnabled = false

		-- BG
		UI = { }
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

        -- Case data
        local pCaseData = DISCOUNT_DATA.cases[iSelectedCase]
        local pCaseInfo = WEB_CASES_DATA[ pCaseData.case_id ]

        UI.slide_rt = ibCreateRenderTarget( 0, 181, sx, 314, bg )
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
        UI.l_cases_count = ibCreateLabel( 50, 210, 48, 30, iCasesAmount, UI.case_info_area, _, _, _, "left", "center", ibFonts.bold_14 )
        :ibData( "alpha", 0 )

        UI.l_count = ibCreateLabel( 40, 180, 0, 0, "Выберите количество:", UI.case_info_area, ibApplyAlpha( COLOR_WHITE, 25 ),
            _, _, "left", "center", ibFonts.regular_14 )

        local px = 40
        for k, v in pairs( CASE_AMOUNTS ) do
            UI[ "btn_amount"..k ] = ibCreateButton( px, 190, 69, 50, UI.case_info_area, 
                iCasesAmount == v and "img/btn_amount_p.png" or "img/btn_amount_i.png", "img/btn_amount_h.png", "img/btn_amount_p.png",
                COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
            :ibOnClick(function( key, state )
                if key ~= "left" or state ~= "up" then return end
                ibClick()

                iCasesAmount = v

                for k,v in pairs( CASE_AMOUNTS ) do
                    UI[ "btn_amount"..k ]:ibData( "texture", iCasesAmount == v and "img/btn_amount_p.png" or "img/btn_amount_i.png" )
                end

                UpdateCost( )
            end)

            local l_x = ibCreateLabel( 0, 0, 69, 40, "x"..v, UI[ "btn_amount"..k ], COLOR_WHITE, _, _, "center", "center", ibFonts.oxaniumbold_16 )
            :ibData( "disabled", true )

            px = px + 64
        end

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
            local pCaseInfo = WEB_CASES_DATA[ pCaseData.case_id ]

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

                if not localPlayer:HasDonate( GetCaseDiscountCostForAmount( pCaseData.old_cost, iCasesAmount ) ) then
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
            local pCaseInfo = WEB_CASES_DATA[ pCaseData.case_id ]

            triggerServerEvent( "PlayerWantOpenCase", getResourceRootElement( getResourceFromName("nrp_shop") ), pCaseData.case_id, bFastSpinEnabled )
            ibClick( )
        end)


        -- Arrows
        UI.arrow_l = ibCreateButton( 0, 180, 90, 314, bg, "img/arrow_l_i.png", "img/arrow_l_h.png", "img/arrow_l_h.png", 
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        :ibOnClick(function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            if iSelectedCase <= 1 then return end
            SetSelectedCase( iSelectedCase - 1 )
        end)

        UI.arrow_r = ibCreateButton( sx-90, 180, 90, 314, bg, "img/arrow_r_i.png", "img/arrow_r_h.png", "img/arrow_r_h.png", 
                                    COLOR_WHITE, COLOR_WHITE, COLOR_WHITE )
        :ibOnClick(function( key, state )
            if key ~= "left" or state ~= "up" then return end
            ibClick()
            if iSelectedCase >= 6 then return end
            SetSelectedCase( iSelectedCase + 1 )
        end)

        UI.l_total_cases = ibCreateLabel( sx-13, sy-196-40, 0, 0, "/06", bg, ibApplyAlpha( COLOR_WHITE, 50 ), 
            _, _, "right", "bottom", ibFonts.oxaniumregular_14 )
        UI.l_current_case = ibCreateLabel( sx-13-UI.l_total_cases:width()-2, sy-193-40, 0, 0, "01", bg, _, 
            _, _, "right", "bottom", ibFonts.oxaniumregular_20 )

        -- Cases selector
        local px = 55
        for i, v in pairs( DISCOUNT_DATA.cases ) do
        	local pCaseData = WEB_CASES_DATA[ v.case_id ]

        	UI["case_selector"..i] = ibCreateButton( px, sy-196, 144, 167, bg, 
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

        	local discount_bg = ibCreateImage( 144-52, 2, 50, 20, "img/bg_corner_discount.png", content_area )
        	:ibData("disabled", true)
        	:ibData("priority", 3)

            local l_discount_s = ibCreateLabel( 4, 0, 50, 20, "до", discount_bg, _, _, _, "left", "center", ibFonts.regular_12 )
        	local l_discount = ibCreateLabel( 20, 0, 50, 20, v.discount.."%", discount_bg, _, _, _, "left", "center", ibFonts.oxaniumbold_11 )
        	:ibData("disabled", true)

        	local case_img = ibCreateContentImage( 0, 0, 130, 90, "case", v.case_id, content_area )
        	:ibData("disabled", true)
        	:center()

        	local sName, sFont = GetCaseShortName( pCaseData.name )
        	local case_name = ibCreateLabel( 0, 26, 144, 0, sName, content_area, _, _, _, "center", "center", ibFonts[sFont] )

        	local l_old_cost = ibCreateLabel( 0, 142, 0, 0, v.old_cost*3, content_area, ibApplyAlpha( COLOR_WHITE, 50 ), _, _, "left", "center", ibFonts.oxaniumregular_14 )
        	:ibData("disabled", true)

        	local l_cost = ibCreateLabel( 0, 140, 0, 0, GetCaseDiscountCostForAmount( v.old_cost, 3 ), content_area, _, _, _, "left", "center", ibFonts.oxaniumbold_22 )
        	:ibData("disabled", true)

        	local iTotalCostWidth = l_old_cost:width() + l_cost:width() + 28 + 10

        	l_old_cost:ibData( "px", 144/2-iTotalCostWidth/2 )
        	l_cost:ibData( "px", l_old_cost:ibGetAfterX( 5 ) )

        	local icon_money = ibCreateImage( l_cost:ibGetAfterX( 5 ), 140-14, 28, 28, ":nrp_shared/img/hard_money_icon.png", content_area )
        	:ibData("disabled", true)

        	local old_cost_line = ibCreateImage( -3, -1, l_old_cost:width()+6, 1, _, l_old_cost, ibApplyAlpha( COLOR_WHITE, 75 ) )

            local selector_count = ibCreateImage( 2, 36, 140, 22, "img/selector_count.png", UI["case_selector"..i] )
            :ibData( "disabled", true )
            :ibData("priority", 3)

        	px = px + 154
        end

        SetSelectedCase( iSelectedCase, true )

		showCursor( true )
	else
		DestroyTableElements( UI )
        UI = nil
		 
        removeEventHandler( "onClientKey", root, EscapeKeyHandler ) 

		showCursor( false )
	end
end
addEvent("ShowUI_WholesomeCaseDiscount", true)
addEventHandler("ShowUI_WholesomeCaseDiscount", root, ShowUI_CasesDiscount)

function EscapeKeyHandler( key, state )
    if key ~= "escape" then return end

    cancelEvent()
    ShowUI_CasesDiscount( false )
end

function ToggleContentMode()
    bCaseContentShown = not bCaseContentShown

    if bCaseContentShown then
        local pCaseData = DISCOUNT_DATA.cases[iSelectedCase]
        local pCaseInfo = WEB_CASES_DATA[ pCaseData.case_id ]

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

        UI.case_items, UI.scroll_v = ibCreateCaseContentPane( 0, 80, 581, 232, pCaseData.case_id, UI.content_bg, 80 )
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
    local pCaseInfo = WEB_CASES_DATA[ pCaseData.case_id ]
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

        -- Cost
        UI.l_old_cost_value:ibData( "text", pCaseData.old_cost)
        UI.old_cost_icon:ibData( "px", UI.l_old_cost_value:ibGetAfterX( 5 ) )
        UI.old_cost_line:ibData( "sx", UI.l_old_cost_value:width()+6+5+28 )

        UI.l_cost_value:ibData( "text", pCaseData.cost * iCasesAmount )
        UI.cost_icon:ibData( "px", UI.l_cost_value:ibGetAfterX( 5 ) )

        UI.l_current_case:ibData("text", "0"..iSelectedCase)

        if bHasCase then
            UI.btn_buy:ibData("disabled", true):ibData("alpha", 0)
            UI.btn_open:ibData("disabled", false):ibData("alpha", 255)

            for k,v in pairs( CASE_AMOUNTS ) do
                UI[ "btn_amount"..k ]:ibData( "texture", iCasesAmount == v and "img/btn_amount_p.png" or "img/btn_amount_i.png" ):ibData( "alpha", 0 ):ibData( "disabled", true )
            end

            UI.l_count:ibData( "alpha", 0 )

            UI.l_cases_count:ibData( "text", "Осталось кейсов: "..iOwnedCasesLeft ):ibData( "alpha", 255 )
        else
            UI.btn_buy:ibData("disabled", false):ibData("alpha", 255)
            UI.btn_open:ibData("disabled", true):ibData("alpha", 0)
            UI.l_cases_count:ibData( "alpha", 0 )

            iCasesAmount = 3

            for k,v in pairs( CASE_AMOUNTS ) do
                UI[ "btn_amount"..k ]:ibData( "texture", iCasesAmount == v and "img/btn_amount_p.png" or "img/btn_amount_i.png" ):ibData( "alpha", 255 ):ibData( "disabled", false )
            end

            UI.l_count:ibData( "alpha", 255 )
        end

        UpdateCost( )

        UI.slide_bg:ibAlphaTo( 255, iCaseSwitchDelay, "InOutQuad" )
        UI.slide_bg:ibData("px", bMoveSide and 900 or -900)
        UI.slide_bg:ibMoveTo( 0, _, iCaseSwitchDelay, "InOutQuad" )
    end, iCaseSwitchDelay+50, 1)

    if bCaseContentShown then
        UI.content_case_name:ibAlphaTo( 0, iCaseSwitchDelay, "InOutQuad" )
        UI.case_items:ibAlphaTo( 0, iCaseSwitchDelay, "InOutQuad" )

        UI.content_bg:ibTimer(function()
            UI.case_items:destroy()
            UI.scroll_v:destroy()

            UI.content_case_name:ibData( "text", pCaseInfo.name )
            :ibAlphaTo( 255, iCaseSwitchDelay, "InOutQuad" )

            UI.case_items, UI.scroll_v = ibCreateCaseContentPane( 0, 80, 581, 232, pCaseData.case_id, UI.content_bg, 80 )

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

    if not bCaseContentShown then
        UI.arrow_l:ibData( "disabled", iSelectedCase == 1 and true or false )
        UI.arrow_l:ibData( "alpha", iSelectedCase == 1 and 255*0.5 or 255 )
    
        UI.arrow_r:ibData( "disabled", iSelectedCase == 6 and true or false )
        UI.arrow_r:ibData( "alpha", iSelectedCase == 6 and 255*0.5 or 255 )
    end
end

-- Utils
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

function OnClientElementDataChange( key, old_value, value )
    if source ~= localPlayer then return end
    if not UI then return end

    if key == "cases" then
        SetSelectedCase( iSelectedCase, true )
    end
end
addEventHandler("onClientElementDataChange", localPlayer, OnClientElementDataChange)

function OnWholesomeCaseDiscountDataReceived( data )
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

        localPlayer:setData( "wholesome_case_discount", DISCOUNT_DATA.finish_ts, false )
    else
        localPlayer:setData( "wholesome_case_discount", false, false )
    end
end
addEvent( "OnWholesomeCaseDiscountDataReceived", true )
addEventHandler( "OnWholesomeCaseDiscountDataReceived", resourceRoot, OnWholesomeCaseDiscountDataReceived )

addEventHandler( "onClientResourceStart", resourceRoot, function( )
    if not bSynced then
        triggerServerEvent("OnClientRequestDiscountData", resourceRoot)
        return
    end
end)

addEventHandler( "onClientResourceStop", resourceRoot, function( )
    localPlayer:setData( "wholesome_case_discount", false, false )
end)

function GetWholesomeCaseDiscountData()
    return DISCOUNT_DATA
end

function GetCaseWholesomeCaseDiscountData( case_id )
    local pDiscountData = GetWholesomeCaseDiscountData()

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

local TEX_DISCOUNT_FOR_AMOUNT = { [3] = 15, [6] = 20, [9] = 30, [12] = 35 }

function UpdateCost( )
    local pCaseData = DISCOUNT_DATA.cases[iSelectedCase]

    UI.l_old_cost_value:ibData( "text", pCaseData.old_cost*iCasesAmount )
    UI.old_cost_icon:ibData( "px", UI.l_old_cost_value:ibGetAfterX( 5 ) )
    UI.old_cost_line:ibData( "sx", UI.l_old_cost_value:width()+6+5+28 )
    UI.l_cost_value:ibData( "text", GetCaseDiscountCostForAmount( pCaseData.old_cost, iCasesAmount ) )
        UI.cost_icon:ibData( "px", UI.l_cost_value:ibGetAfterX( 5 ) )

    UI.big_discount:ibData( "texture", "img/discounts/"..TEX_DISCOUNT_FOR_AMOUNT[iCasesAmount]..".png" )
end