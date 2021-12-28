local sizeX, sizeY = 800, 580
local posX, posY = (scx-sizeX)/2, (scy-sizeY)/2

local ui = {}
local CACHED_DATA = {}

function ShowUI_Events( state, data )
	if state then
		CACHED_DATA = data

		ShowUI_Events( false )
		ibInterfaceSound()
		showCursor(true)

		ui.black_bg = ibCreateBackground( 0xD7000000, ShowResultUI, nil, true )
		ui.main = ibCreateImage( posX, -sizeY, sizeX, sizeY, "files/img/bg.png", ui.black_bg ):ibData("alpha", 0)
		:ibMoveTo( posX, posY, 400 ):ibAlphaTo(255, 400)

		-- close
		ibCreateButton( sizeX-50, 25, 24, 24, ui.main, "files/img/btn_close.png", "files/img/btn_close.png", "files/img/btn_close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "down" then return end
			ShowUI_Events( false )
			ibClick()
		end)

		local px, py = 30, 100

		for i = 1, 3 do
			local section = ibCreateImage( px, py, 234, 448, "files/img/icon_game_"..i..".png", ui.main )
			:ibOnClick( function(key, state) 
				if key ~= "left" or state ~= "down" then return end
				ibClick()
				ShowEvent( i, data[i] )
			end)

			local hover = ibCreateImage( 0, 0, 234, 448, "files/img/icon_game_"..i.."_hover.png", section )
			:ibData("alpha", 0):ibData("disabled", true)
			section:ibOnHover( function() 
				hover:ibAlphaTo( 255, 300 )
			end)
			section:ibOnLeave( function()
				hover:ibAlphaTo( 0, 300 )
			end)

			ui["lbl_" .. i] = ibCreateLabel( 146, 379, 0, 0, "", section, 0xFFCCCED0, 1, 1, "left", "top", ibFonts.bold_12 )
			:ibOnRender( function()
				local time_left = GetStringDataFromUNIX( data[ i ].start_time - getRealTimestamp() )
				ui["lbl_" .. i]:ibData( "text", time_left )
			end )

			px = px + 254
		end
	else
		if isElement( ui.black_bg ) then
			destroyElement( ui.black_bg )
		end
		showCursor( false )
	end
end
addEvent("ShowUI_ClanEventsRegister", true)
addEventHandler("ShowUI_ClanEventsRegister", root, ShowUI_Events)

function ShowEvent( id, data )
	if isElement(ui.main) then
		ui.event = ibCreateImage( posX, -sizeY, sizeX, sizeY, "files/img/bg_game_"..id..".png", false ):ibData("alpha", 0)

		-- close
		ibCreateButton( sizeX-50, 25, 24, 24, ui.event, "files/img/btn_close.png", "files/img/btn_close.png", "files/img/btn_close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "down" then return end
			ShowUI_Events( true, CACHED_DATA )
			ibClick()
		end)

		local btn_register = ibCreateButton( 225, 510, 200, 40, ui.event, "files/img/btn_register.png", "files/img/btn_register_hover.png", "files/img/btn_register_hover.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "down" then return end
			triggerServerEvent("CEV:OnPlayerRequestEventRegister", resourceRoot, data.lobby_id)

			ShowUI_Events( false )
			ibClick()
		end)
		:ibData("alpha", 180):ibData("disabled", true)

		if data.can_register then
			btn_register:ibData("alpha", 255):ibData("disabled", false)
		end

		local btn_leave = ibCreateButton( 225, 510, 200, 40, ui.event, "files/img/btn_leave.png", "files/img/btn_leave_hover.png", "files/img/btn_leave_hover.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "down" then return end
			triggerServerEvent("CEV:OnPlayerRequestEventCancelRegister", resourceRoot)

			ShowUI_Events( false )
			ibClick()
		end)
		:ibData("alpha", 0):ibData("disabled", true)

		if data.can_leave then
			btn_register:ibData("alpha", 0):ibData("disabled", true)
			btn_leave:ibData("alpha", 255):ibData("disabled", false)
		end

		local btn_join = ibCreateButton( 445, 510, 130, 40, ui.event, "files/img/btn_join.png", "files/img/btn_join_hover.png", "files/img/btn_join_hover.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		:ibOnClick( function(key, state) 
			if key ~= "left" or state ~= "down" then return end
			triggerServerEvent("CEV:OnPlayerRequestEventJoin", resourceRoot)

			ShowUI_Events( false )
			ibClick()
		end)
		:ibData("alpha", 180):ibData("disabled", true)

		ui.event_time = ibCreateLabel( 625, 25, 0, 0, "", ui.event, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_16 )
		:ibOnRender( function()
			local time_left = GetStringDataFromUNIX( data.start_time - getRealTimestamp() )
			ui.event_time:ibData( "text", time_left )
		end )

		if data.can_join then
			btn_join:ibData("alpha", 255):ibData("disabled", false)
		end

		ui.event:ibMoveTo( posX, posY, 400 )
		ui.event:ibAlphaTo( 255, 400 )
		ui.main:ibMoveTo( posX, scy+posY, 400 )
	end
end

function GetStringDataFromUNIX( unix_time )
    local hours, minutes = math.floor( unix_time / 3600 % 24 ), math.floor( unix_time / 60 % 60 )
    return string.format( "%02d ч %02d мин ", hours, minutes )
end

--ShowUI_Events(true)