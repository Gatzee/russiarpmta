loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "CPlayer" )
Extend( "ShUtils" )
Extend( "Globals" )
Extend( "ib" )

local ui = {}
local scX, scY = guiGetScreenSize()
local posX, posY = 120, scY / 2 - 120

UI_elements = {}
CURRENT_JAIL_DATA = {}
JAIL_REASONS = ""

function OnPlayerJailed( data )
	data.end_tick = getTickCount() + data.time_left * 1000 

	CURRENT_JAIL_DATA = data

	JAIL_REASONS = ""

	local pWantedData = getElementData( localPlayer, "wanted_data" ) or {}
	if #pWantedData > 1 then
		JAIL_REASONS = "А так же: "
		for k,v in pairs( pWantedData ) do
			JAIL_REASONS = JAIL_REASONS..v[1].. (next(pWantedData, k) and "," or "")
		end
	end

	if data.time_left * 1000 > PRISON_TIME then
		if isElement( UI_elements.black_bg ) then
			UI_elements.black_bg:destroy()
		end
		UI_elements.black_bg = ibCreateBackground( 0xBF1D252E, CloseInfoWindow, _, true )
		UI_elements.bg = ibCreateImage( 0, 0, 789, 561, "img/bg.png", UI_elements.black_bg ):center( )
		:ibData( "alpha", 0 ):ibAlphaTo( 255, 250 )
		ibCreateButton(	341, 489, 108, 42, UI_elements.bg, "img/btn_close.png", "img/btn_close_hovered.png", "img/btn_close_hovered.png", 0xFFFFFFFF, 0xFFCCCCCC, 0xFF808080 )
		:ibOnClick( function( key, state )
			if key ~= "left" or state ~= "up" then return end
			
			ibClick( )
			CloseInfoWindow()
		end, false )
		showCursor( true )
	else
		triggerServerEvent( "onPlayerReadJailInfo", localPlayer )
	end

	local sx, sy, sz = getElementVelocity( localPlayer )
	setElementVelocity( localPlayer, sx + math.random(-10, 10) / 1000, sy + math.random(-10, 10) / 1000, sz)

	addEventHandler("onClientPreRender", root, CheckForEscape)
	ShowJailData()
end
addEvent("jail:OnPlayerJailed", true)
addEventHandler("jail:OnPlayerJailed", root, OnPlayerJailed)

function CloseInfoWindow()
	if isElement( UI_elements.black_bg ) then
		UI_elements.black_bg:destroy()
		showCursor( false )
		triggerServerEvent( "onPlayerReadJailInfo", localPlayer )
	end
end

function OnPlayerReleased( move_prison )
	CURRENT_JAIL_DATA = {}

	removeEventHandler("onClientPreRender", root, CheckForEscape)
	if not move_prison then
		setElementInterior( localPlayer, 0 )
		setElementDimension( localPlayer, 0 )
	end
	HideJailData()
end
addEvent("jail:OnPlayerReleased", true)
addEventHandler("jail:OnPlayerReleased", root, OnPlayerReleased)

function CheckForEscape( )
	if isElementWithinColShape( localPlayer, CURRENT_JAIL_DATA.room_element) then return end
	localPlayer:Teleport( CURRENT_JAIL_DATA.room_element.position, CURRENT_JAIL_DATA.room_element.dimension, CURRENT_JAIL_DATA.room_element.interior )
end

-- Отображение данных о аресте
function ShowJailData()

	ui.bg_jailarea = ibCreateArea( posX, posY, 0, 0 ):ibData("priority", -100)
	
	ui.arest = ibCreateLabel( 0, 0, 0, 0, "Вы под арестом!", ui.bg_jailarea, 0xFFFFE2A7, 1, 1, "left", "top", ibFonts.bold_18 )
	:ibData("outline", 1)

	ui.arest_reason = ibCreateLabel( 0, 35, 0, 0, "Причина - "..CURRENT_JAIL_DATA.reason.."\n"..JAIL_REASONS, ui.bg_jailarea, 0xDDFFFFFF, 1, 1, "left", "top", ibFonts.bold_12 )
	:ibData("outline", 1)

	ui.arest_time = ibCreateLabel( 0, 75, 0, 0, "на "..CURRENT_JAIL_DATA.reason.."\n"..JAIL_REASONS, ui.bg_jailarea, 0xFFFFFFFF, 1, 1, "left", "top", ibFonts.bold_18 )
	:ibData("outline", 1)
	:ibOnRender( function()
		local iTimeLeft = math.max( ( CURRENT_JAIL_DATA.end_tick - getTickCount() ) / 1000, 0 )
		local iHours = math.floor( iTimeLeft / 3600 ) 
		local iMinutes = math.ceil( iTimeLeft / 60 ) - iHours * 60
		local time = (iHours > 0 and iHours..plural(iHours, " час ", " часа ", " часов ") or "")..iMinutes..plural(iMinutes, " минуту", " минуты", " минут")
		ui.arest_time
		:ibData( "text", "на " .. time )
	end )
end

function HideJailData()
	if isElement( ui.bg_jailarea ) then
		ui.bg_jailarea:destroy()
	end
end

local sizeX, sizeY = 400, 500
local posX, posY = (scX-sizeX)/2, (scY-sizeY)/2

function ShowReleaseUI(state)
	if state then

		ShowReleaseUI(false)

		local tex_close = dxCreateTexture( "img/cross.png" )

		ui.main = ibCreateImage( posX, posY, sizeX, sizeY, nil, false,  0xEE475D75)

		ui.title = ibCreateLabel( 40, 0, sizeX - 80, 100, "Выберите заключённого, которого хотите выпустить", ui.main, 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_14 )
		:ibData( "wordbreak", true )
		:ibData( "disabled", true )

		ui.close = ibCreateButton( sizeX - 50, 25, 24, 24, ui.main, "img/cross.png", "img/cross.png", "img/cross.png", 0xFFCCCCCC, 0xFFFFFFFF, 0xFFFFFFFF  )
		:ibOnClick( function( button, state ) 
			if button ~= "left" or state ~= "up" then return end
			ShowReleaseUI(false)
		end )

		ui.scrollpane, ui.scrollbar = ibCreateScrollpane( 0, 100, sizeX, sizeY - 100, ui.main )

		local pPlayersAround = {}
		for k,v in pairs(getElementsByType("player")) do
			if v:getData("jailed") then
				local distance = (localPlayer.position - v.position).length
				if distance <= 10 then
					table.insert(pPlayersAround, v)
				end
			end
		end

		local py = 0
		for k, v in pairs(pPlayersAround) do
			ui["player"..k] = ibCreateButton( 0, py, sizeX, 50, ui.scrollpane, nil, nil, nil, 0xEF475D75, 0xFF575D75, 0xFF475D75  )
			:ibOnClick( function( button, state ) 
				if button ~= "left" or state ~= "up" then return end
				triggerServerEvent( "jail:OnPlayerReleasedByUI", localPlayer, v )
				ShowReleaseUI(false)
			end )
			:ibOnHover( function( )
				ui["title"..k] :ibData( "alpha", 255 )
			end )
			:ibOnLeave( function( )
				ui["title"..k] :ibData( "alpha", 200 )
			end )

			ui["title"..k] = ibCreateLabel( 0, 0, sizeX, 50, v:GetNickName(), ui["player"..k], 0xFFFFFFFF, 1, 1, "center", "center", ibFonts.bold_14 )
			:ibBatchData( { disabled = true, alpha = 200 } )

			py = py + 55
		end

		ui.scrollpane:AdaptHeightToContents()
		ui.scrollbar:UpdateScrollbarVisibility( ui.scrollpane )

		showCursor(true)
	else
		for k,v in pairs(ui) do
			if isElement(v) then
				destroyElement( v )
			end
		end
		showCursor(false)
	end
end
addEvent("jail:ShowReleaseUI", true)
addEventHandler("jail:ShowReleaseUI", root, ShowReleaseUI)