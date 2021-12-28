local ui = {}
local pDataCache = {}

function ShowUI_Tournament( state, data )
	if state then
		if isElement(ui.main) then return end
		showCursor(true)
		pDataCache = data

		ui.black_bg = ibCreateBackground( _, ShowUI_Tournament, _, true )
		ui.main = ibCreateImage( 0, 0, 800, 580, "files/img/tournament/bg.png", ui.black_bg ):center()
				
		ui.close = ibCreateButton( 750, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick(  function( key, state )
        	    if key ~= "left" or state ~= "down" then return end
        	    ShowUI_Tournament(false)
			end, false )
		
		ui.btn_rules = ibCreateButton( 630, 122, 112, 12, ui.main, "files/img/tournament/btn_rules.png", "files/img/tournament/btn_rules.png", "files/img/tournament/btn_rules.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function( key, state )
        	    if key ~= "left" or state ~= "down" then return end
        	    ShowUI_Rules(true)
        	end, false )

		ui.l_slots = ibCreateLabel( 185, 429, 0, 0, data.slots_left, ui.main, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_14)
	
		ui.btn_participants = ibCreateButton( 150, 500, 240, 44, ui.main, "files/img/tournament/btn_participants.png", "files/img/tournament/btn_participants.png", "files/img/tournament/btn_participants.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function( key, state )
        	    if key ~= "left" or state ~= "down" then return end
        	    ShowUI_Participants(true)
        	end, false )	

		ui.btn_participate = ibCreateButton( 400, 480, 278, 82, ui.main, "files/img/tournament/btn_participate.png", "files/img/tournament/btn_participate.png", "files/img/tournament/btn_participate.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
        	:ibOnClick( function( key, state )
        	    if key ~= "left" or state ~= "down" then return end
				
				if confirmation then confirmation:destroy() end
        	    confirmation = ibConfirm( {
        	        title = "Участие в турнире", 
        	        text = "Ты действительно хочешь принять участие в турнире?\nВзнос за участие - 100 000",
        	        black_bg = 0xaa202025,
        	        fn = function( self ) 
        	            self:destroy()
        	            ShowUI_Tournament( false )
        	            triggerServerEvent("FC:OnPlayerTryParticipate", resourceRoot, localPlayer)
					end,
					escape_close = true,
        	    } )
        	end )
	else
		ShowUI_Participants( false )
		ShowUI_Rules( false )
		if isElement(ui and ui.black_bg) then
			destroyElement( ui.black_bg )
		end
		ui = {}
		showCursor(false)
	end
end
--addEvent("FC:ShowUI_Tournament", true)
--addEventHandler("FC:ShowUI_Tournament", resourceRoot, ShowUI_Tournament)

function ShowUI_Rules( state )
	if state then
		showCursor(true)

		ui.overlay = ibCreateImage( 0, 0, _SCREEN_X, _SCREEN_Y, nil, nil, 0xEE000000)
		ui.rules = ibCreateImage( (_SCREEN_X-520)/2, (_SCREEN_Y-560)/2, 520, 560, "files/img/tournament/bg_rules.png", ui.overlay )
		
		ibCreateLabel( 30, 140, 0, 0, TOURNAMENT_RULES, ui.rules, 0xFFFFFFFF, 1, 1, "left", "top" ):ibData( "font", ibFonts.regular_14 )

		ui.r_close = ibCreateButton( 520-50, 25, 24, 24, ui.rules, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function( key, state )
        	    if key ~= "left" or state ~= "down" then return end
        	    ShowUI_Rules(false)
        	end, false )

		ui.btn_ok = ibCreateButton( (520-128)/2, 480, 128, 42, ui.rules, "files/img/tournament/btn_ok.png", "files/img/tournament/btn_ok.png", "files/img/tournament/btn_ok.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function( key, state )
        	    if key ~= "left" or state ~= "down" then return end
        	    ShowUI_Rules(false)
        	end, false )
	elseif isElement(ui.overlay) then
		destroyElement( ui.overlay )
	end
end

function ShowUI_Participants( state )
	if state then
		showCursor(true)

		ui.participants = ibCreateImage( 0, 0, 800, 580, "files/img/grid/bg.png" ):center()
		ui.p_close = ibCreateButton( 750, 25, 24, 24, ui.participants, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
			:ibOnClick( function( key, state )
        	    if key ~= "left" or state ~= "down" then return end
        	    ShowUI_Participants(false)
        	end, false )

		ui.scrollpane = ibCreateScrollpane( 0,  90, 800, 480, ui.participants, { scroll_px = -25 } )

		local py = 0
		for i, v in pairs(pDataCache.fights or {}) do
			ui["l_block"..i] = ibCreateImage( 40, py, 300, 54, "files/img/grid/item.png", ui.scrollpane )
			ui["l_label"..i] = ibCreateLabel( 0, 0, 300, 54, v.participants[1] and v.participants[1].name or "Свободный слот", ui["l_block"..i], 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_14)
			ui["r_block"..i] = ibCreateImage( 460, py, 300, 54, "files/img/grid/item.png", ui.scrollpane )
			ui["r_label"..i] = ibCreateLabel( 0, 0, 300, 54, v.participants[2] and v.participants[2].name or "Свободный слот", ui["r_block"..i], 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_14)
			ui["line"..i] = ibCreateImage( 340, py+27, 120, 1, nil, ui.scrollpane, 0x44FFFFFF )
			py = py + 64
		end

		if not pDataCache.fights or #pDataCache.fights == 0 then
			local py = 0
			for i = 1, 16, 2 do
				ui["l_block"..i] = ibCreateImage( 40, py, 300, 54, "files/img/grid/item.png", ui.scrollpane )
				ui["l_label"..i] = ibCreateLabel( 0, 0, 300, 54, pDataCache.participants[i] and pDataCache.participants[i].name or "Свободный слот", ui["l_block"..i], 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_14)
				ui["r_block"..i] = ibCreateImage( 460, py, 300, 54, "files/img/grid/item.png", ui.scrollpane )
				ui["r_label"..i] = ibCreateLabel( 0, 0, 300, 54, pDataCache.participants[i+1] and pDataCache.participants[i+1].name or "Свободный слот", ui["r_block"..i], 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_14)
				ui["line"..i] = ibCreateImage( 340, py+27, 120, 1, nil, ui.scrollpane, 0x44FFFFFF )
				py = py + 64
			end
		end

		ui.scrollpane:AdaptHeightToContents( )
	elseif isElement(ui.participants) then
		destroyElement( ui.participants )
	end
end