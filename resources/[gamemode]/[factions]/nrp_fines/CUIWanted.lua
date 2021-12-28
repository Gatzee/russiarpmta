local ui = {}
local pWantedAndFinesList = {}
local iSelectedOption

ibUseRealFonts(true )

CWANTED_LIST = {
	{
		id = "1.2",
		mapToGlobal = WANTED_REASONS_LIST,
		name = "Нарушение порядка",
		duration = 5,
		desc = "Нарушение общественного порядка",
	},
	{
		id = "1.8",
		mapToGlobal = WANTED_REASONS_LIST,
		name = "Неподчинение",
		duration = 15,
		desc = "Неподчинение сотрудникам госорганов при исполнении",
	},
	{
		id = "1.13",
		mapToGlobal = FINES_LIST,
		name = "Хранение запрещенного оружия",
		cost = 10000,
		desc = "Хранение огнестрельного оружия без лицензии",
	},
}

function ShowUI_AddWanted( state, data )
	if state then
		ShowUI_AddWanted( false )

		if not data.target or not isElement(data.target) then return end

		showCursor( true )

		local function UpdateList()
			if iSelectedOption then
				ui.selected_fine_name:ibData( "text", "ст. "..CWANTED_LIST[ iSelectedOption ].id.." - "..CWANTED_LIST[ iSelectedOption ].name)
			end

			local px, py = 30, 0

			for k,v in pairs(pWantedAndFinesList) do
				local pWantedData = CWANTED_LIST[ v ]

				local wanted_bg = ibCreateImage( px, py, 740, 83, "files/img/bg_fine.png", ui.scrollpane )
				ibCreateLabel( 20, 35, 0, 0, "Статья:", wanted_bg, 0x80FFFFFF, 1, 1, "left", "bottom", ibFonts.regular_14 )
				ibCreateLabel( 80, 35, 0, 0, "ст. "..pWantedData.id.." - "..pWantedData.name, wanted_bg, 0xffffffff, 1, 1, "left", "bottom", ibFonts.regular_14 )

				ibCreateLabel( 20, 60, 0, 0, "Описание:", wanted_bg, 0x80FFFFFF, 1, 1, "left", "bottom", ibFonts.regular_12 )
				ibCreateLabel( 90, 60, 0, 0, pWantedData.desc or pWantedData.name, wanted_bg, 0xffffffff, 1, 1, "left", "bottom", ibFonts.regular_12 )

				local group = ibCreateDummy( wanted_bg )
				local lbl_cost_title = ibCreateLabel( 0, 0, 0, 0, ( pWantedData.duration and "Наказание: " or "Сумма штрафа: " ) , group, 0x80ffffff, 1, 1, "left", "center", ibFonts.regular_14 )
				local lbl_cost = ibCreateLabel( lbl_cost_title:ibGetAfterX(5), 0, 0, 0, ( pWantedData.duration and pWantedData.duration .. " мин КПЗ" ) or pWantedData.cost or 0, group, 0xffffffff, 1, 1, "left", "center", ibFonts.bold_18 )

				local icon_soft = ibCreateImage( lbl_cost:ibGetAfterX(5), 0, 24, 19, pWantedData.duration and "files/img/timer_icon1.png" or "files/img/icon_soft.png", group ):center_y( )

				local btn_rm = ibCreateButton( icon_soft:ibGetAfterX( 12 ), 0, 13, 13, group, "files/img/close_small.png", "files/img/close_small.png", "files/img/close_small.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
					:center_y( )
					:ibOnClick( function( button, state )
						if button == "left" and state == "down" then
							table.remove(pWantedAndFinesList, k)
							destroyElement( wanted_bg )
							UpdateList()
						end
					end)

				group:ibBatchData( { sx = btn_rm:ibGetAfterX() } ):ibData("px", wanted_bg:ibGetAfterX( -group:ibData( "sx" ) - 50 ) ):center_y()

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
				for k,v in pairs( CWANTED_LIST ) do
					if not v.manual_disabled then
						local item = ibCreateButton( px, py, 736, 40, scrollpane, nil, nil, nil, 0x00000000, 0x1affffff, 0x1affffff )
						:ibOnClick( function( button, state )
							if button == "left" and state == "down" then
								if #pWantedAndFinesList >= 3 then
									localPlayer:ShowError("Нельзя применять более трёх статей за раз!")
									return false
								end

								for i, value in pairs(pWantedAndFinesList) do
									if value == k then
										localPlayer:ShowError("Нельзя применять две одинаковых статьи!")
										return false
									end
								end

								iSelectedOption = k
								table.insert(pWantedAndFinesList, k)
								SwitchSelector( false )
								UpdateList()
							end
						end)

						ibCreateLabel( 20, 0, 0, 40, "ст."..v.id.." - "..v.name, item, 0xffffffff, 1, 1, "left", "center", ibFonts.regular_12 ):ibData("disabled", true)

						if next(CWANTED_LIST, k) then
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

		ui.main = ibCreateImage( 0, 0, 0, 0, "files/img/bg1.png" ):ibSetRealSize( ):center()
		ibCreateLabel( 30, 47, 0, 0, "Розыск", ui.main, COLOR_WHITE, 1, 1, "left", "bottom", ibFonts.bold_16 )

		-- close
		ibCreateButton( 750, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then
				ShowUI_AddWanted( false )
			end
		end)

		-- target name
		ibCreateLabel( 30, 110, 0, 0, "Розыск обьявляется игроку:", ui.main, 0x80ffffff, 1, 1, "left", "bottom", ibFonts.bold_16 )
		ibCreateLabel( 285, 110, 0, 0, data.target:GetNickName(), ui.main, 0xffffffff, 1, 1, "left", "bottom", ibFonts.bold_16 )

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

		-- add wanted btn
		ibCreateButton( 330, 505, 140, 45, ui.main, "files/img/btn_addfine.png", "files/img/btn_addfine.png", "files/img/btn_addfine.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function( button, state )
			if button == "left" and state == "down" then
				local pWantedList, pFinesList = {}, {}

				local function separate( )
					-- делим по типу розыск | штраф
					-- если штраф и статья штрафа есть в WANTED_REASONS_LIST  --> также добавляем к розыску
					for _, idx in pairs( pWantedAndFinesList ) do
						local cw = CWANTED_LIST[ idx ]
						if cw.mapToGlobal == WANTED_REASONS_LIST then
							table.insert( pWantedList, cw.id )
						elseif cw.mapToGlobal == FINES_LIST then
							for index, pFine in ipairs( FINES_LIST ) do
								if pFine.id == cw.id then
									table.insert( pFinesList, index )
									if WANTED_REASONS_LIST[pFine.id] then
										--iprint("штраф и розыск")
										table.insert( pWantedList, pFine.id )
									end
								end
							end
						end
					end
				end

				separate( )

				triggerServerEvent( "OnPlayerTryAddWanted", resourceRoot, data.target, pWantedList, pFinesList, localPlayer:getData("on_police_post") )
				ShowUI_AddWanted( false )
			end
		end)

		UpdateList()
	else
		iSelectedOption = nil
		pWantedAndFinesList = {}

		for k,v in pairs( ui ) do
			if isElement( v ) then
				destroyElement( v )
			end
		end

		showCursor(false)
	end
end

addEvent("ShowUI_AddWanted", true)
addEventHandler("ShowUI_AddWanted", resourceRoot, ShowUI_AddWanted)