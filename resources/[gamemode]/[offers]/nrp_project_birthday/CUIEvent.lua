
scX, scY = guiGetScreenSize()
sizeX, sizeY = 800, 580


UI_elements = {}

function ShowUI_Event( state, data )
	if state then
		ShowUI_Event(false)
		
		showCursor( true )
		UI_elements.main = ibCreateImage( 0, 0, sizeX, sizeY, "files/img/bg.png" ):center()
		UI_elements.timer = ibCreateLabel( 680, 96, 0, 0, getHumanTimeString( EVENT_ENDS, true ), UI_elements.main, 0xFFFFDE96, _, _, "left", "center", ibFonts.bold_18 )
		ibCreateButton( sizeX-50, 25, 24, 24, UI_elements.main, ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", ":nrp_shared/img/confirm_btn_close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "up" then return end
			ShowUI_Event( false )
			ibClick()
		end)

		local px, py = 30, 308
		for k,v in pairs( data ) do
			local fProgress = v.current / PROGRESSES[ k ].max
			local offset_y = (50 * PROGRESSES[ k ].id)
			local label = ibCreateLabel( px, py + offset_y, 0, 0, PROGRESSES[ k ].visible_name, UI_elements.main, 0xFFFFFFFF, _, _, "left", "bottom", ibFonts.regular_16 )
			local bg = ibCreateImage( px, py + 6 + offset_y, 280, 14, "files/img/bar_bg.png", UI_elements.main )
			local body = ibCreateImage( px - 18, py - 12 + offset_y, 316 * fProgress, 50, "files/img/bar_body.png", UI_elements.main )
			:ibBatchData( { u = 0, v = 0, u_size = 316 * fProgress } )
			
			local counter = ibCreateLabel( px + 290, py + 6 + offset_y, 0, 14, v.current .. " / " .. PROGRESSES[ k ].max .. " " .. (PROGRESSES[ k ].unit or ""), UI_elements.main, 0xffffffff, _, _, "left", "center", ibFonts.regular_12 )
		end
	else
		if not CURRENT_DIALOG then
			showCursor( false )
		end
		for k, v in pairs(UI_elements) do
			if isElement(v) then
				destroyElement( v )
			end
		end
	end
end
addEvent( "ShowUI_Event", true )
addEventHandler( "ShowUI_Event", resourceRoot, ShowUI_Event )