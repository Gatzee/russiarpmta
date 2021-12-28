local scx, scy = guiGetScreenSize()
local sizeX, sizeY = 402, 400
local posX, posY = scx/2-sizeX/2, scy/2-sizeY/2

local ui = {}
local iSelection = 1
local pSelectedValue = nil

function ShowUI_Selector( state, data )
	if state then
		showCursor(true)

		iSelection = 1
		pSelectedValue = nil

		ui.overlay = ibCreateImage( 0, 0, scx, scy, nil, false, 0xE0394a5c)
		ui.main = ibCreateImage( posX, posY, sizeX, sizeY, "files/img/bg_selector.png", ui.overlay )

		-- SCROLLBAR
		local scrollpane, scrollbar = ibCreateScrollpane( 0, 140, sizeX, sizeY-230, ui.main, { scroll_px = -20 } )
        scrollbar:ibSetStyle( "slim_small_nobg" ):ibData( "sensivity", 0.2 )

		-- close
		ibCreateButton( sizeX-50, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "up" then return end
			ShowUI_Selector( false )
			ibClick()
		end)

		ui.hover_img = ibCreateImage( 0, 0, sizeX, 41, nil, scrollpane, 0x10FFFFFF ):ibData("disabled", true):ibData("alpha", 0)
		ibCreateImage( sizeX-50, 12, 20, 16, "files/img/icon_check_green.png", ui.hover_img )

		local py = 0
		for k,v in pairs( data.list ) do
			ui["button"..k] = ibCreateButton( 0, py, sizeX, 40, scrollpane, nil, nil, nil, 0x00FFFFFF, 0x00FFFFFF, 0x00FFFFFF )
			:ibOnClick( function(key, state)
				if key ~= "left" or state ~= "up" then return end
				iSelection = k
				pSelectedValue = v

				ui.hover_img:ibMoveTo(0, source:ibData("py"), 0):ibData("alpha", 255)
				ibClick()
			end)

			if data.selected_value and data.selected_value == v then
				iSelection = k
	       		pSelectedValue = data.selected_value
	       		ui.hover_img:ibMoveTo(0, ui["button"..k]:ibData("py"), 0):ibData("alpha", 255)
	       	end

			ibCreateLabel( 20, 0, 0, 40, "Класс - "..VEHICLE_CLASSES_NAMES[v], ui["button"..k], 0xFFFFFFFF, _, _, "left", "center", ibFonts.bold_16 )

			ibCreateImage( 20, py+40, sizeX-40, 1, nil, scrollpane, 0x20FFFFFF )

			py = py + 42
		end

		scrollpane:AdaptHeightToContents( )
       	scrollbar:UpdateScrollbarVisibility( scrollpane )

		-- select
		ibCreateButton( sizeX/2-60, sizeY-70, 120, 44, ui.main, "files/img/btn_select.png", "files/img/btn_select.png", "files/img/btn_select.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "up" then return end
			if not pSelectedValue then 
				localPlayer:ShowError("Ничего не выбрано")
				return
			end

			if not data.player_classes[pSelectedValue] then
				local confirmation = ibConfirm(
				    {
				        title = "Получение награды", 
				        text = "У тебя нет машины на выбранный класс, и эту деталь ты сможешь использовать только когда купишь машину этого класса! Ты уверен?" ,
				        fn = function( self )
				        	triggerServerEvent("DA:OnItemParamsReceived", localPlayer, { [P_CLASS] = pSelectedValue })
							ShowUI_Selector( false )
				            self:destroy()
						end,
						escape_close = true,
				    }
				)
			else
				local confirmation = ibConfirm(
				    {
				        title = "Получение награды", 
				        text = "Ты уверен в своём выборе?" ,
				        fn = function( self )
				        	triggerServerEvent("DA:OnItemParamsReceived", localPlayer, { [P_CLASS] = pSelectedValue })
							ShowUI_Selector( false )
				            self:destroy()
						end,
						escape_close = true,
				    }
				)
			end
			ibClick()
		end)
	else
		if isElement(ui.overlay) then
			destroyElement( ui.overlay )
		end

		showCursor(false)
	end
end
addEvent("DA:ShowUI_Selector", true)
addEventHandler("DA:ShowUI_Selector", resourceRoot, ShowUI_Selector)