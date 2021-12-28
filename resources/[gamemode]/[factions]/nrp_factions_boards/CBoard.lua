loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "CPlayer" )
Extend( "Globals" )
Extend( "ShUtils" )
Extend( "ib" )

local sizeX, sizeY = 800, 580

local ui = {}

local synced_data = {}
local current_section = 1
local click_timeout = 0

function ShowUI( state, data )
	if state then
		ShowUI(false)
		showCursor(true)

		synced_data = data
		current_section = 1
		pCurrentlyEditing = nil
		ui = {}

		ui.black_bg = ibCreateBackground( 0xBF1D252E, ShowUI, _, true )
		ui.main = ibCreateImage( 0, 0, sizeX, sizeY, "files/img/bg.png", ui.black_bg ):center()

		ui.close = ibCreateButton( sizeX-50, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF)
			:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "down" then return end
				ibClick( )
	
				ShowUI( false )	
			end )
		
		ui.btn_section_1 = ibCreateButton( 220, 0, 150, 75, ui.main, nil, nil, nil, 0x00CCCCCC, 0x00FFFFFF, 0x00FFFFFF)
						   ibCreateLabel( 0, 0, 0, 0, "Сообщение дня", ui.btn_section_1, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_13 ):center( )
		ui.btn_section_1:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" or current_section == 1 then return end
			ibClick( )

			current_section = 1
			GenerateSection( current_section )

			ui.selected_section_line:ibMoveTo( ui.btn_section_1:ibData( "px" ) ):ibResizeTo( ui.btn_section_1:width( ) )
		end )

		if data.is_faction then
			ui.btn_section_2 = ibCreateButton( 400, 0, 180, 75, ui.main, nil, nil, nil, 0x00CCCCCC, 0x00FFFFFF, 0x00FFFFFF)
							   ibCreateLabel( 0, 0, 0, 0, "Доска объявлений", ui.btn_section_2, COLOR_WHITE, 1, 1, "center", "center", ibFonts.bold_13 ):center( )
			ui.btn_section_2:ibOnClick( function( button, state )
				if button ~= "left" or state ~= "down" or current_section == 2 then return end
				ibClick( )

				current_section = 2
				GenerateSection( current_section )

				ui.selected_section_line:ibMoveTo( ui.btn_section_2:ibData( "px" ) ):ibResizeTo( ui.btn_section_2:width( ) )
			end )
		end

		ui.selected_section_line = ibCreateImage( ui.btn_section_1:ibData( "px" ), 68, ui.btn_section_1:width( ), 4, nil, ui.main, 0xFFff965d )
		
		GenerateSection( 1 )
	else
		if isElement( ui.black_bg  ) then
			destroyElement( ui.black_bg  )
		end
		showCursor(false)
	end
end
addEvent("FB:ShowUI", true)
addEventHandler("FB:ShowUI", resourceRoot, ShowUI)

function CreateBoard( px, py, sx, sy, title, text, parent, data )
	local board = { is_edit = false, data = data }
	board.bg = ibCreateImage( px, py, sx, sy, nil, parent, 0x2A000000 )
	board.title = ibCreateLabel( 20, 0, 200, 50, title, board.bg, 0xFFFFFFFF, 1, 1, "left", "center", ibFonts.bold_11 )

	board.line = ibCreateImage( 20, 50, sx-40, 2, nil, board.bg, 0x14FFFFFF )

	board.scrollpane, board.scrollbar = ibCreateScrollpane( 20, 60, sx-40, sy-70, board.bg, { scroll_px = -10 } )
	board.scrollbar:ibSetStyle( "slim_small_nobg" )
		:ibBatchData{ handle_color = 0x25ffffff, handle_py = 0, handle_lower_limit = 0, handle_upper_limit = -60 }

	local lines_count = select( 2, text:gsub( "\n", "" ) ) + 1
	board.text = ibCreateLabel( 0, 0, sx-50, lines_count * 22, text, board.scrollpane, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.semibold_13 )
		:ibData( "clip", true )

	board.scrollpane:AdaptHeightToContents()
	board.scrollbar:UpdateScrollbarVisibility( board.scrollpane )

	board.btn_edit = ibCreateButton( sx - 30, 20, 15, 15, board.bg, "files/img/btn_edit.png", "files/img/btn_edit.png", "files/img/btn_edit.png", 0xFFBBBBBB, 0xFFFFFFFF, 0xFFFFFFFF)
		:ibData( "visible", data and data.has_access )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			ibClick( )
			board:SwitchMode()
		end )

	board.btn_save = ibCreateButton( sx - 60, 20, 16, 12, board.bg, "files/img/btn_apply.png", "files/img/btn_apply.png", "files/img/btn_apply.png", 0xFFBBBBBB, 0xFFFFFFFF, 0xFFFFFFFF)
		:ibData( "visible", false )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			if click_timeout > getTickCount( ) then return end
			click_timeout = getTickCount( ) + 1000
			ibClick( )
			board:Save()
		end )

	board.btn_delete = ibCreateButton( sx - 30, 20, 12, 12, board.bg, "files/img/btn_close.png", "files/img/btn_close.png", "files/img/btn_close.png", 0xFFBBBBBB, 0xFFFFFFFF, 0xFFFFFFFF)
		:ibData( "visible", false )
		:ibOnClick( function( button, state )
			if button ~= "left" or state ~= "down" then return end
			if click_timeout > getTickCount( ) then return end
			click_timeout = getTickCount( ) + 1000
			ibClick( )
			board:Destroy()
		end )

	board.SwitchMode = function( self )
		self.is_edit = not self.is_edit

		if self.is_edit then
			if pCurrentlyEditing and isElement(pCurrentlyEditing.bg) then
				pCurrentlyEditing:SwitchMode()
			end
			
			board.memo = ibCreateWebMemo( 10, 50, sx-20, sy-50, text, board.bg, 0xDDFFFFFF, 0x00FFFFFF)
				:ibBatchData{ font = "bold_12", focusable = true, max_length = self.data.is_daily_message and 3500 or 700 }
				:ibTimer( function( self ) self:ibData( "focused", true ) end, 100, 1 )	

			pCurrentlyEditing = self
			self.data.stored_text = self.text:ibData( "text" )
		else
			if pCurrentlyEditing == self then
				pCurrentlyEditing = nil
			end

			if isElement( board.memo ) then
				board.memo:ibData( "visible", false )
				board.memo:ibTimer( destroyElement, 100, 1 )
			end
		end
		
		self.bg:ibData( "color", self.is_edit and 0x5A000000 or 0x2A000000 )

		self.btn_edit:ibData( "visible", not self.is_edit )
		self.btn_save:ibData( "visible", self.is_edit )
		self.btn_delete:ibData( "visible", self.is_edit )
		self.scrollpane:ibData( "visible", not self.is_edit )
		self.scrollbar:ibData( "visible", not self.is_edit )
	end

	board.Save = function( self )
		local new_text = self.memo:ibData( "text" )
		local lines_count = select( 2, new_text:gsub( "\n", "" ) ) + 1
		self.text:ibBatchData{ sy = lines_count * 22, text = new_text }
		board.scrollpane:AdaptHeightToContents()
		board.scrollbar:UpdateScrollbarVisibility( board.scrollpane )

		if self.data.is_new then
			triggerServerEvent( "OnPlayerAdsAction", localPlayer, synced_data.board.id, "add", { msg = new_text } )
		elseif self.data.is_daily_message then
			triggerServerEvent( "OnPlayerUpdateDailyMessage", localPlayer, synced_data.board.id, new_text  )
		else
			triggerServerEvent( "OnPlayerAdsAction", localPlayer, synced_data.board.id, "edit", { id = self.data.id, msg = new_text } )
		end
		self:SwitchMode()
	end

	board.Restore = function( self )
		self.text:ibData( "text", self.data.stored_text )
	end

	board.Destroy = function( self )
		if self.data.is_new then
			GenerateSection(2)
		elseif self.data.is_daily_message then
			GenerateSection(1)
		else
			triggerServerEvent( "OnPlayerAdsAction", localPlayer, synced_data.board.id, "remove", { id = self.data.id } )
			synced_data.board.ads[self.data.id] = nil
			GenerateSection(2)
		end
	end

	board.destroy = function(self)
		if isElement( self.bg ) then
			destroyElement( self.bg )
		end
		setmetatable( self, nil )
	end

	return board
end

function GenerateSection( section )
	if ui.section then
		for k,v in pairs(ui.section) do
			if isElement(v) then
				destroyElement( v )
			elseif type(v) == "table" then
				if isElement(v.bg) then
					v:destroy()
				end
			end
		end
	end

	ui.section = {}

	if section == 1 then
		local pData = 
		{
			has_access = synced_data.is_leader,
			is_daily_message = true,
		}

		local title = synced_data.board.message and synced_data.board.message.name or ""
		local text = synced_data.board.message and synced_data.board.message.text or "Повестка дня пуста..."
		ui.section.board = CreateBoard( 20, 100, sizeX-40, sizeY-150, title, text, ui.main, pData)

	elseif section == 2 then
		ui.section.scrollpane, ui.section.scrollbar = ibCreateScrollpane( 30, 80, sizeX-30, sizeY-90, ui.main, { scroll_px = -20 } )
		ui.section.scrollbar:ibSetStyle( "slim_nobg" )	

		local px, py = 0, 10
		local uid = localPlayer:GetUserID()

		local ads = { }
		for k, v in pairs( synced_data.board.ads ) do
			v.i = k
			table.insert( ads, v )
		end
		table.sort( ads, function( a, b ) return (tonumber( a.i ) or 0) < (tonumber( b.i ) or 0) end )

		for k,v in pairs( ads ) do
			local has_access = v.user == uid or synced_data.is_leader

			local pData = 
			{ 
				has_access = has_access,
				id = k,
			}

			ui.section["board"..k] = CreateBoard( px, py, 240, 200, v.name, v.msg, ui.section.scrollpane, pData )

			px = px + 250
			if px >= 600 then
				py = py + 210
				px = 0
			end
		end
		if synced_data.is_level_3 then
			ui.section.btn_add = ibCreateButton( px, py, 240, 200, ui.section.scrollpane, 
												 "files/img/add.png", "files/img/add.png", "files/img/add.png", 
												 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF )
				:ibOnClick( function( button, state )
					if button ~= "left" or state ~= "down" then return end
					local px, py = source:ibData( "px" ), source:ibData( "py" )
					destroyElement( source )

					ui.section.new_board = CreateBoard( px, py, 240, 200, localPlayer:GetNickName(), "", ui.section.scrollpane, 
														{ has_access = true, is_new = true } )

					ui.section.new_board:SwitchMode()
				end)
		end

		ui.section.scrollpane:AdaptHeightToContents()
		ui.section.scrollbar:UpdateScrollbarVisibility( ui.section.scrollpane )	
	end
end

function ForceSync(data)
	synced_data = data

	if isElement(ui.main) then
		GenerateSection(current_section)
	end
end
addEvent("FB:ForceSync", true)
addEventHandler("FB:ForceSync", resourceRoot, ForceSync)
