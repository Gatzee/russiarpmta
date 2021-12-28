local scx, scy = guiGetScreenSize( )
local sizeX, sizeY = 800, 580
local posX, posY = scx/2-sizeX/2, scy/2-sizeY/2

local ui = { }

local pSelection = { 
	day = 1,
	is_premium = false, 
	variant = 1 
}

function ShowUI_DailyAwards( state, data, seasonNum, timeLeft, current_day )
	if state then
		ibAutoclose( )
		ibWindowSound()
		
		ShowUI_DailyAwards( false )
		showCursor( true )

		local is_premium = localPlayer:IsPremiumActive( )

		ui.black_bg = ibCreateBackground( 0xaa000000, ShowUI_DailyAwards, true, true )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 500 )
		
		ui.main = ibCreateImage( posX, posY+100, sizeX, sizeY, "files/img/bg.png", ui.black_bg ):ibMoveTo( posX, posY, 500 )
		:ibData("alpha", 0):ibAlphaTo(255, 800)

		-- close
		ibCreateButton( sizeX-50, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "down" then return end
			ShowUI_DailyAwards( false )
			ibClick()
		end)

		-- timer of seasons
		local lbl_time_left = ibCreateLabel( 730, 20, 0, 0, getHumanTimeString( timeLeft ), ui.main, 0xaaffffff, nil, nil, "right" )
		:ibData( "font", ibFonts.bold_14 )

		local lbl_timer_info = ibCreateLabel( 730 - lbl_time_left:width( ) - 5, 20, 0, 0, "Обновление через:", ui.main, 0xaaffffff, nil, nil, "right" )
		:ibData( "font", ibFonts.regular_14 )

		ibCreateImage( 730 - lbl_time_left:width( ) - lbl_timer_info:width( ) - 30, 19, 20, 20, "files/img/icon_timer.png", ui.main )

		--rules
		ibCreateButton( sizeX - 145, 40, 76, 13, ui.main, "files/img/btn_rules.png", "files/img/btn_rules.png", "files/img/btn_rules.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "down" then return end
			ShowUI_DailyAwardsRules( true )
			ibClick()
		end)
		
		local btn_take_regular = ibCreateButton( sizeX/4-65, sizeY-65, 130, 44, ui.main, 
			"files/img/btn_take.png", "files/img/btn_take.png", "files/img/btn_take.png", 0xC0FFFFFF, 0xFFFFFFFF, 0xFFFFFFFF ):ibData("priority", 3):ibData("alpha", 0):ibData("disabled", true)
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "up" then return end
			triggerServerEvent("DA:OnPlayerRequestTakeAwards", resourceRoot, localPlayer, pSelection.day, pSelection.variant, pSelection.is_premium)
			ShowUI_DailyAwards( false )
			ibClick()
		end)

		local btn_buy_premium = ibCreateButton( sizeX/2+sizeX/4-100, sizeY-65, 200, 44, ui.main,
			"files/img/btn_buy.png", "files/img/btn_buy.png", "files/img/btn_buy.png", 0xC0FFFFFF, 0xFFFFFFFF, 0xFFFFFFFF ):ibData("priority", 3):ibData("alpha", 0):ibData("disabled", true)
		:ibOnClick( function(key, state)
			if key ~= "left" or state ~= "up" then return end
			triggerServerEvent( "onPlayerRequestDonateMenu", getResourceFromName("nrp_shop").rootElement, 4 )
			ShowUI_DailyAwards( false )
			ibClick()
		end)

		local btn_take_premium = ibCreateButton( sizeX-150, sizeY-65, 130, 44, ui.main, 
			"files/img/btn_take.png", "files/img/btn_take.png", "files/img/btn_take.png", 0xC0FFFFFF, 0xFFFFFFFF, 0xFFFFFFFF ):ibData("priority", 3):ibData("alpha", 0):ibData("disabled", true)
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "up" then return end
			triggerServerEvent("DA:OnPlayerRequestTakeAwards", resourceRoot, localPlayer, pSelection.day, pSelection.variant, pSelection.is_premium)
			ShowUI_DailyAwards( false )
			ibClick()
		end)

		-- top h-line
		ibCreateImage( 0, 150, sizeX, 1, nil, ui.main, 0xff5b6e82 )

		if is_premium then
			ibCreateImage( 30, 88, 40, 38, "files/img/icon_crown_big.png", ui.main )
			ibCreateLabel( 90, 70, sizeX/2, 35, "Награды для игроков с премиумом", ui.main, 0xFFFFFFFF, _, _, "left", "bottom" ):ibData("font", ibFonts.bold_16)
			
			ibCreateLabel( 90, 110, sizeX/2, 20, "Подробнее >", ui.main, 0xFF7fa5d0, _, _, "left", "top" ):ibData("font", ibFonts.bold_14):ibData("alpha", 200)
			:ibOnHover( function() 
				source:ibData("alpha", 255)
			end)
			:ibOnLeave( function()
				source:ibData("alpha", 200)
			end)
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				triggerServerEvent( "onPlayerRequestDonateMenu", getResourceFromName("nrp_shop").rootElement, 4 )
				ShowUI_DailyAwards( false )
				ibClick()
			end)

			local lbl_time_left = ibCreateLabel( sizeX-130, 108, 0, 0, getHumanTimeString( localPlayer:getData( "premium_time_left" ), true ), ui.main, 0xFFFFFFFF, _, _, "right", "center", ibFonts.regular_14 )
			ibCreateLabel( sizeX-135-lbl_time_left:width(), 108, 0, 0, "До конца премиума - ", ui.main, 0xFFcccccc, _, _, "right", "center", ibFonts.regular_12 )

			ui.but_extend = ibCreateButton( sizeX-122, 90, 102, 32, ui.main, 
			"files/img/btn_extend.png", "files/img/btn_extend.png", "files/img/btn_extend.png", 0xC0FFFFFF, 0xFFFFFFFF, 0xFFFFFFFF ):ibData("priority", 3)
			:ibOnClick( function(key, state) 
				if key ~= "left" or state ~= "up" then return end
				triggerServerEvent( "onPlayerRequestDonateMenu", getResourceFromName("nrp_shop").rootElement, 4 )
				ShowUI_DailyAwards( false )
				ibClick()
			end)
		else

			btn_buy_premium:ibData('disabled', false):ibData('alpha', 255)
			-- central v-line
			ibCreateImage( sizeX/2, 70, 1, sizeY-70, nil, ui.main, 0xff5b6e82 )

			-- left v-line
			ibCreateImage( sizeX/4, 151, 1, sizeY-151, nil, ui.main, 0xff5b6e82 )

			-- LEFT SIDE
			ibCreateLabel( 0, 70, sizeX/2, 35, "Награды для игроков без премиума", ui.main, 0xFFFFFFFF, _, _, "center", "bottom" ):ibData("font", ibFonts.bold_16)
			if data[current_day] and data[current_day][2] == 0 then 
				ibCreateLabel( 0, 110, sizeX/2, 40, "Выберите 1 из наград на сегодня", ui.main, 0xA0FFFFFF, _, _, "center", "top" ):ibData("font", ibFonts.regular_14)
			else
				ibCreateLabel( 0, 110, sizeX/2, 40, "Вы сможете получить награду завтра после 02:00(Мск)", ui.main, 0xA0FFFFFF, _, _, "center", "top" ):ibData("font", ibFonts.regular_14)
			end

			-- RIGHT SIDE
			ibCreateImage( sizeX/2+35, 82, 21, 20, "files/img/icon_crown.png", ui.main )
			ibCreateLabel( sizeX/2+20, 70, sizeX/2, 35, "Награды для игроков с премиумом", ui.main, 0xFFFFFFFF, _, _, "center", "bottom" ):ibData("font", ibFonts.bold_16)
			
			ibCreateLabel( sizeX/2, 110, sizeX/2, 40, "Подробнее >", ui.main, 0xFF7fa5d0, _, _, "center", "top" ):ibData("font", ibFonts.bold_14)
			:ibOnHover( function() 
				source:ibData("alpha", 255)
			end)
			:ibOnLeave( function()
				source:ibData("alpha", 200)
			end)
			:ibOnClick( function( key, state )
				if key ~= "left" or state ~= "up" then return end
				triggerServerEvent( "onPlayerRequestDonateMenu", getResourceFromName("nrp_shop").rootElement, 4 )
				ShowUI_DailyAwards( false )
				ibClick()
			end)
		end

		-- SCROLLBAR
		local scrollpane, scrollbar = ibCreateScrollpane( 0, 151, sizeX, sizeY-230, ui.main, { scroll_px = -20 } )
		scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.02 )
		ui.scrollpane, ui.scrollbar = scrollpane, scrollbar

        local hovered_regular = ibCreateImage( 0, 0, 200, 160, nil, scrollpane, 0x30000000):ibData("alpha", 0):ibData("priority", -1):ibData("disabled", true)
        ibCreateImage( 200-40, 20, 18, 14, "files/img/icon_check_blue.png", hovered_regular )
        local hovered_premium = ibCreateImage( 0, 0, sizeX, 160, nil, scrollpane, 0x30000000):ibData("alpha", 0):ibData("priority", -1):ibData("disabled", true)
        ibCreateImage( 600, 20, 18, 14, "files/img/icon_check_blue.png", hovered_premium )

        local hovered_regular_dyn = ibCreateImage( 0, 0, 200, 160, nil, scrollpane, 0x20000000):ibData("alpha", 0):ibData("priority", -1):ibData("disabled", true)
        local hovered_premium_dyn = ibCreateImage( 0, 0, sizeX, 160, nil, scrollpane, 0x20000000):ibData("alpha", 0):ibData("priority", -1):ibData("disabled", true)

        local py = 0
		for day, items in ipairs( REWARDS_BY_DAYS[ seasonNum ] ) do
			local day_data = data[ day ] or { }
        	if is_premium and ( day_data[ 2 ] or 0 ) == 0 then
        		-- CENTER
        		local btn = ibCreateImage( 0, py, sizeX, 160, nil, scrollpane, 0x00FF2222 ):ibData("priority", -1)

	        	local premium = ConstructItemsBlock( items.premium, "premium", day )
	        	premium:setParent( btn )
	        	premium:ibData("px", sizeX / 2 - 150)
	        	premium:ibData("disabled", true)

	        	if day_data[ 3 ] == 1 and day_data[ 2 ] ~= -1 then
	        		ibCreateLabel( 30, 0, 0, 160, day.." день ", btn, 0x33000000, _, _, "left", "center" ):ibData("font", ibFonts.extra_bold_50):ibData("disabled", true)
	        		ibCreateImage( sizeX-118, 38, 88, 84, "files/img/icon_crown_bg.png", btn, 0xFFFFFFFF ):ibData('disabled', true)

		        	btn:ibOnClick( function(key, state) 
						if key ~= "left" or state ~= "up" then return end
						hovered_premium:ibData("alpha", 255):setParent(source)
						ibClick()
						pSelection = { 
							day = day,
							is_premium = true, 
							variant = 1,
						}

						if btn_take_premium:ibData("disabled") then
							btn_take_premium:ibData("disabled", false):ibAlphaTo( 255, 500 )
						end
					end)
					:ibOnHover( function() 
						if hovered_premium_dyn.parent ~= source then
							hovered_premium_dyn:ibData("alpha", 0):ibAlphaTo(255, 500):setParent(source)
						end
					end)
					:ibOnLeave( function()
						if hovered_premium_dyn.parent == source then
							hovered_premium_dyn:ibAlphaTo(0, 100)
						end
					end)
				else
					if day_data[ 3 ] == -1 then
						btn:ibData("color", 0x30000000)
						ibCreateImage( 600, 20, 18, 14, "files/img/icon_check_blue.png", btn )
					elseif day == current_day and ( day_data[ 1 ] or 0 ) < REQUIRED_DAILY_PLAYTIME then
						local time_left = REQUIRED_DAILY_PLAYTIME - ( day_data[1] or 0 )
						if time_left > 0 then
							ibCreateLabel( sizeX-118, py+38+84, 88, 40, time_left.." мин.", scrollpane, 0x80FFFFFF, _, _, "center", "center", ibFonts.regular_16):ibData("disabled", true)
						end
					end

					premium:ibData("alpha", 100)
					ibCreateLabel( 30, py, 0, 160, day.." день ", scrollpane, 0x11000000, _, _, "left", "center" ):ibData("font", ibFonts.extra_bold_50):ibData("disabled", true)
					ibCreateImage( sizeX-118, py+38, 88, 84, "files/img/icon_crown_bg.png", scrollpane, 0x80FFFFFF ):ibData('disabled', true)
				end
        	else
	        	-- LEFT
	        	local bg_day = ibCreateImage( sizeX/4-40, py, 80, 30, "files/img/day.png", scrollpane ):ibData("priority", 1)
	        	ibCreateLabel( 0, 0, 80, 30, "День "..day, bg_day, 0xFFFFFFFF, _, _, "center", "center" ):ibData("font", ibFonts.bold_12)

	        	for variant = 1, 2 do
		        	local regular = ConstructItemsBlock( items.regular[variant], "regular", day)
		        	if day_data[ 2 ] == 1 and day_data[ 3 ] ~= -1 then
			        	regular:ibOnClick( function(key, state) 
							if key ~= "left" or state ~= "down" then return end
							hovered_regular:ibData("alpha", 255):setParent(source)

							pSelection = { 
								day = day,
								is_premium = false, 
								variant = variant,
							}
							ibClick()
							if btn_take_regular:ibData("disabled") then
								btn_take_regular:ibData("disabled", false):ibAlphaTo( 255, 500 )
							end
						end)
						:ibOnHover( function()
							if hovered_regular_dyn.parent ~= source then
								hovered_regular_dyn:ibData("alpha", 0):ibAlphaTo(255, 500):setParent(source)
							end
						end)
						:ibOnLeave( function()
							if hovered_regular_dyn.parent == source then
								hovered_regular_dyn:ibAlphaTo(0, 100)
							end
						end)

					else
						regular:ibData("alpha", 100)
						bg_day:ibData("alpha", 100)

						if day_data[2] == -1 then
							regular:ibData("color", 0x60000000)
							if day_data[4] == variant then
								ibCreateImage( 200-40, 20, 18, 14, "files/img/icon_check_blue.png", regular )
							end
						elseif day == current_day and ( day_data[ 1 ] or 0 ) < REQUIRED_DAILY_PLAYTIME then
							local time_left = REQUIRED_DAILY_PLAYTIME - ( day_data[1] or 0 )
							if time_left > 0 then
								ibCreateLabel( 0, py+120, sizeX/2, 40, "Осталось "..time_left.." "..plural( time_left, "минута", "минуты", "минут" ), scrollpane, 0x80FFFFFF, _, _, "center", "center", ibFonts.regular_14):ibData("disabled", true)
							end
						end
					end

		        	regular:setParent( scrollpane )
		        	regular:ibData("px", variant == 1 and 0 or sizeX/4)
		        	regular:ibData("py", py)
		        end

		        -- RIGHT
	        	local bg_day = ibCreateImage( sizeX/2+sizeX/4-40, py, 80, 30, "files/img/day.png", scrollpane )
	        	ibCreateLabel( 0, 0, 80, 30, "День "..day, bg_day, 0xFFFFFFFF, _, _, "center", "center" ):ibData("font", ibFonts.bold_12)

	        	local premium = ConstructItemsBlock( items.premium, "premium", day )
	        	premium:setParent( scrollpane )
	        	premium:ibData("px", sizeX/2)
	        	premium:ibData("py", py)

	        	if day_data[ 3 ] == 1 and day_data[ 2 ] ~= -1 then
		        	premium:ibOnClick( function(key, state) 
						if key ~= "left" or state ~= "up" then return end
						hovered_premium:ibData("alpha", 255):setParent(source)

						pSelection = {
							day = day,
							is_premium = true,
							variant = 1,
						}
						ibClick()

						if btn_take_premium:ibData( "disabled" ) then
							btn_take_premium:ibData( "disabled", false ):ibAlphaTo( 255, 500 )
							btn_buy_premium:ibBatchData( { disabled = true, alpha = 0 } )
						end
					end)
				else
					premium:ibData("alpha", 100)
					bg_day:ibData("alpha", 100)
				end
	        end

	        ibCreateImage( 0, py+159, sizeX, 1, nil, scrollpane, 0xff5b6e82 )
        	py = py + 160
        end

        ibCreateImage( 0, py, sizeX, 50, nil, scrollpane, 0x00000000 )

        scrollpane:AdaptHeightToContents( )
       	scrollbar:UpdateScrollbarVisibility( scrollpane ):ibData("priority", 2)

		-- bottom gradint
		ibCreateImage( 0, sizeY-193, sizeX, 194, "files/img/gradient.png", ui.main ):ibData("priority", 1):ibData("disabled", true)
	else
		if isElement(ui and ui.black_bg) then
			destroyElement( ui.black_bg )
		end

		showCursor(false)
	end
end
addEvent("ShowUI_DailyAwards", true)
addEventHandler("ShowUI_DailyAwards", resourceRoot, ShowUI_DailyAwards)

ibAttachAutoclose( function( ) ShowUI_DailyAwards( false ) end )

function ShowUI_DailyAwardsRules( state )
	if state then
		ShowUI_DailyAwardsRules( false )
		ui.rules = ibCreateImage( 0, 72, 0, 0, "files/img/bg_rules.png", ui.main )
		:ibSetRealSize()
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 800 )

		ui.rules_hide = ibCreateButton( ui.rules:ibGetCenterX( - 108 / 2 ), 370, 108, 42, ui.rules,
		"files/img/btn_hide.png", "files/img/btn_hide.png", "files/img/btn_hide.png", 0xC0FFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "up" then return end
			ShowUI_DailyAwardsRules( false )
			ibClick()
		end)
	else
		if ui.rules and isElement( ui.rules ) then
			destroyElement( ui.rules )
		end
	end

	if isElement( ui.but_extend ) then
		ui.but_extend:ibData( "disabled", state ):ibData( "alpha", state and 0 or 255 )
	end

	ui.scrollpane:ibData( "disabled", state ):ibData( "alpha", state and 0 or 255 )
	ui.scrollbar:ibData( "disabled", state ):ibData( "alpha", state and 0 or 255 )
end

bindKey("f6", "down", function()
	if isElement(ui.black_bg) then
		ShowUI_DailyAwards(false)
	else
		if localPlayer:getData("_apanel") then return end

		triggerServerEvent( "OnPlayerSwitchDailyAwardsUI", localPlayer )
	end
end)

function OnAwardGiven()
	ibGetRewardSound()
end
addEvent("DA:OnAwardGiven", true)
addEventHandler("DA:OnAwardGiven", resourceRoot, OnAwardGiven)