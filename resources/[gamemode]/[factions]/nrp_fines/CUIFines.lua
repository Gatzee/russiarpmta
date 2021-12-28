local sizeX, sizeY = 800, 580
local posX, posY = (scx-sizeX)/2, (scy-sizeY)/2

local ui = {}
local confiscation = {}
local pFinesList = {}
local iSelectedFine

function ShowUI_AddFine( state, data )
	if state then
		ShowUI_AddFine( false )

		if not data.target or not isElement(data.target) then return end

		showCursor( true )

		local function UpdateList()
			if iSelectedFine then
				ui.selected_fine_name:ibData( "text", "ст. "..FINES_LIST[ iSelectedFine ].id.." - "..FINES_LIST[ iSelectedFine ].name)
			end

			local px, py = 30, 0

			for k,v in pairs(pFinesList) do
				local pFineData = FINES_LIST[ v ]

				local fine_bg = ibCreateImage( px, py, 740, 83, "files/img/bg_fine.png", ui.scrollpane )
				ibCreateLabel( 20, 35, 0, 0, "Статья:", fine_bg, 0x80ffffff, 1, 1, "left", "bottom", ibFonts.regular_14 )
				ibCreateLabel( 80, 35, 0, 0, "ст. "..pFineData.id.." - "..pFineData.name, fine_bg, 0xffffffff, 1, 1, "left", "bottom", ibFonts.regular_14 )

				ibCreateLabel( 20, 60, 0, 0, "Описание:", fine_bg, 0x80ffffff, 1, 1, "left", "bottom", ibFonts.regular_12 )
				ibCreateLabel( 90, 60, 0, 0, pFineData.desc or pFineData.name, fine_bg, 0xffffffff, 1, 1, "left", "bottom", ibFonts.regular_12 )

				ibCreateLabel( 740-230, 0, 0, 83, "Сумма штрафа:", fine_bg, 0x80ffffff, 1, 1, "left", "center", ibFonts.regular_14 )
				local lbl_cost = ibCreateLabel( 740-115, 0, 0, 83, pFineData.cost or 0, fine_bg, 0xffffffff, 1, 1, "left", "center", ibFonts.bold_18 )

				local icon_soft = ibCreateImage( lbl_cost:ibGetAfterX(5), 83/2-19/2, 24, 19, "files/img/icon_soft.png", fine_bg )

				ibCreateButton( 740-33, 83/2-13/2, 13, 13, fine_bg, "files/img/close_small.png", "files/img/close_small.png", "files/img/close_small.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				:ibOnClick( function( button, state )
					if button == "left" and state == "down" then
						table.remove(pFinesList, k)
						destroyElement( fine_bg )
						UpdateList()
					end
				end)

				py = py + 93
			end

			ui.scrollpane:AdaptHeightToContents()
        	ui.scrollbar:UpdateScrollbarVisibility( ui.scrollpane )
		end

		local function SwitchSelector( state )
			if state then
				ui.selector = ibCreateImage( 5, 130, 790, 251, "files/img/selector.png", ui.main )

				local scrollpane, scrollbar = ibCreateScrollpane( 25, 64, 740, 160, ui.selector, { scroll_px = -20 } )
				scrollbar:ibSetStyle( "slim_nobg" )

				local px, py = 2, 0
				for k,v in pairs( FINES_LIST ) do
					if not v.manual_disabled then
						local item = ibCreateButton( px, py, 736, 40, scrollpane, nil, nil, nil, 0x00000000, 0x1affffff, 0x1affffff )
						:ibOnClick( function( button, state )
							if button == "left" and state == "down" then
								if #pFinesList >= 3 then
									localPlayer:ShowError("Нельзя выписать более трёх штрафов за раз!")
									return false
								end

								for i, value in pairs(pFinesList) do
									if value == k then
										localPlayer:ShowError("Нельзя выписывать два одинаковых штрафа!")
										return false
									end
								end

								iSelectedFine = k
								table.insert(pFinesList, k)
								SwitchSelector( false )
								UpdateList()
							end
						end)

						ibCreateLabel( 20, 0, 0, 40, "ст."..v.id.." - "..v.name, item, 0xffffffff, 1, 1, "left", "center", ibFonts.regular_12 ):ibData("disabled", true)
						
						if next(FINES_LIST, k) then
							ibCreateImage( 0, py+39, 740, 1, nil, scrollpane, 0xbf000000 )
						end

						py = py + 40
					end
				end

				scrollpane:AdaptHeightToContents()
        		scrollbar:UpdateScrollbarVisibility( scrollpane )

        		addEventHandler("ibOnElementMouseClick", root, EmptySpaceClickHandler)
			else
				if isElement( ui.selector ) then
					destroyElement( ui.selector )
				end

				removeEventHandler("ibOnElementMouseClick", root, EmptySpaceClickHandler)
			end
		end

		function EmptySpaceClickHandler( button, state )
			if source == ui.selector then return end
			if button == "left" and state == "up" then
				SwitchSelector( false )
			end
		end

		ui.black_bg = ibCreateBackground( 0x80495F76, ShowUI_AddFine, _, true )
		ui.main = ibCreateImage( posX, posY, sizeX, sizeY, "files/img/bg.png", ui.black_bg )

		-- close
		ibCreateButton( sizeX-50, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then
				ShowUI_AddFine( false )
			end
		end)

		-- target name
		ibCreateLabel( 30, 110, 0, 0, "Штраф выписывается игроку:", ui.main, 0x80ffffff, 1, 1, "left", "bottom", ibFonts.bold_16 )
		ibCreateLabel( 300, 110, 0, 0, data.target:GetNickName(), ui.main, 0xffffffff, 1, 1, "left", "bottom", ibFonts.bold_16 )

		-- selector
		ibCreateLabel( 30, 144, 0, 0, "Выберите статью", ui.main, 0x80ffffff, 1, 1, "left", "bottom", ibFonts.regular_12 )
		ui.selector_btn = ibCreateButton( 30, 156, 740, 40, ui.main, "files/img/btn_selector.png", "files/img/btn_selector_hover.png", "files/img/btn_selector_hover.png" )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then
				SwitchSelector( true )
			end
		end)

		ui.selected_fine_name = ibCreateLabel( 20, 0, 0, 40, "", ui.selector_btn, 0xffffffff, 1, 1, "left", "center", ibFonts.regular_12 ):ibData("disabled", true)
	
		-- list
		ui.scrollpane, ui.scrollbar = ibCreateScrollpane( 0, 220, 800, 290, ui.main, { scroll_px = -20 } )

		-- add fines btn
		ibCreateButton( 330, 505, 140, 45, ui.main, "files/img/btn_addfine.png", "files/img/btn_addfine.png", "files/img/btn_addfine.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then
				triggerServerEvent( "OnPlayerTryAddFines", resourceRoot, data.target, pFinesList, localPlayer:getData("on_police_post") )
				ShowUI_AddFine( false )
			end
		end)

		UpdateList()
	else
		iSelectedFine = nil
		pFinesList = {}

		if isElement( ui.black_bg ) then
			destroyElement( ui.black_bg )
		end
		showCursor(false)
	end
end
addEvent("ShowUI_AddFine", true)
addEventHandler("ShowUI_AddFine", resourceRoot, ShowUI_AddFine)

function ShowUI_FinesList( state, data )
	if state then
		ShowUI_FinesList( false )
		showCursor( true )

		ibInterfaceSound()

		ui.black_bg = ibCreateBackground( 0x80495F76, ShowUI_FinesList, _, true )
		ui.main = ibCreateImage( posX, posY, sizeX, sizeY, "files/img/bg.png", ui.black_bg )

		-- close
		ibCreateButton( sizeX-50, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then
				ShowUI_FinesList( false )
			end
		end)

		ibCreateLabel( sizeX-290, 0, 0, 72, "Ваш баланс:", ui.main, 0xffffffff, 1, 1, "left", "center", ibFonts.regular_14 )
		local lbl_cash = ibCreateLabel( sizeX-195, 0, 0, 72, format_price( localPlayer:GetMoney() ), ui.main, 0xffffffff, 1, 1, "left", "center", ibFonts.bold_18 )
		ibCreateImage( lbl_cash:ibGetAfterX(8), 26, 24, 19, "files/img/icon_soft.png", ui.main )

		ibCreateLabel( 30, 102, 0, 0, "Статья", ui.main, 0x80ffffff, 1, 1, "left", "bottom", ibFonts.regular_12 )
		ibCreateLabel( sizeX-50, 102, 0, 0, "Стоимость", ui.main, 0x80ffffff, 1, 1, "right", "bottom", ibFonts.regular_12 )

		ui.scrollpane, ui.scrollbar = ibCreateScrollpane( 0, 120, 800, 360, ui.main, { scroll_px = -20 } )

		local iTotalCost = 0

		local px, py = 0, 0
		for k,v in pairs(data.fines) do
			local pFineData = FINES_LIST[ v ]

			local fine_bg = ibCreateImage( px, py, sizeX, 36, nil, ui.scrollpane, k/2 == math.floor(k/2) and 0x00000000 or 0x5a314050 )
			ibCreateLabel( 30, 0, 0, 36, "ст. "..pFineData.id.." - "..pFineData.name, fine_bg, 0x80ffffff, 1, 1, "left", "center", ibFonts.regular_14 )
			ibCreateImage( sizeX-64, 9, 24, 19, "files/img/icon_soft.png", fine_bg )
			ibCreateLabel( sizeX-70, 0, 0, 36, pFineData.cost, fine_bg, 0xffffffff, 1, 1, "right", "center", ibFonts.bold_16 )
			
			py = py + 36
			iTotalCost = iTotalCost + pFineData.cost
		end

		ui.scrollpane:AdaptHeightToContents()
        ui.scrollbar:UpdateScrollbarVisibility( ui.scrollpane )

        ibCreateLabel( 30, sizeY-44, 0, 0, "Общая сумма: ", ui.main, 0x80ffffff, 1, 1, "left", "bottom", ibFonts.bold_16 )
        local lbl_cash = ibCreateLabel( 160, sizeY-44, 0, 0, format_price( iTotalCost ), ui.main, 0xffffffff, 1, 1, "left", "bottom", ibFonts.bold_20 )
        ibCreateImage( lbl_cash:ibGetAfterX(8), sizeY-68, 25, 20, "files/img/icon_soft.png", ui.main )


        -- pay
        local btn_pay = ibCreateButton( sizeX-330, sizeY-75, 140, 45, ui.main, "files/img/btn_pay.png", "files/img/btn_pay.png", "files/img/btn_pay.png", 0xaaffffff, 0xffffffff, 0xffffffff )
        :ibOnClick(function( button, state )
			if button == "left" and state == "down" then
				ibClick()

				local confirmation = ibConfirm(
				    {
				        title = "ОПЛАТА ШТРАФОВ", 
				        text = "Ты хочешь оплатить штрафы на сумму "..format_price(iTotalCost).."р.?" ,
				        fn = function( self )
				        	triggerServerEvent("OnPlayerTryPayFines", root )
				            self:destroy()
				            ShowUI_FinesList( false )
						end,
						escape_close = true,
				    }
				)
			end
		end)

        -- go to jail
        local btn_jail = ibCreateButton( sizeX-170, sizeY-75, 140, 45, ui.main, "files/img/btn_jail.png", "files/img/btn_jail.png", "files/img/btn_jail.png", 0xaaffffff, 0xffffffff, 0xffffffff )
		:ibOnClick(function( button, state )
			if button == "left" and state == "down" then
				ibClick()

				local confirmation = ibConfirm(
				    {
				        title = "ОПЛАТА ШТРАФОВ", 
				        text = "Ты хочешь добровольно отправиться в тюрьму?" ,
				        fn = function( self )
				        	triggerServerEvent("OnPlayerTryPayFines", root, "jail", data.jail_id )
				            self:destroy()
				            ShowUI_FinesList( false )
						end,
						escape_close = true,
				    }
				)
			end
		end)

		if iTotalCost <= 0 then
			btn_pay:ibData("disabled", true)
			btn_jail:ibData("disabled", true)
		end
	else
		if isElement( ui.black_bg ) then
			destroyElement( ui.black_bg )
		end

		showCursor(false)
	end
end
addEvent("ShowUI_FinesList", true)
addEventHandler("ShowUI_FinesList", resourceRoot, ShowUI_FinesList)