loadstring(exports.interfacer:extend("Interfacer"))()
Extend("CUI")
Extend("ib")

local x,y = guiGetScreenSize()
local fontsAA = "cleartype_natural"
local fonts
local APConfig = {
	px = x-10,
	py = 150,
	max_py = y-150,
	line_height = 22,
	list_font = "default-bold",
	list_font_scale = 1,
	bg_gap = 10,
	bg_gap_vertical = 3,

	wsx = 640,
	wsy = 50,
	bg_color = 0xdF181818,

	current_scroll = 0,
}
APConfig.wpx = x/2-APConfig.wsx/2
APConfig.wpy = y-APConfig.wsy

APConfig.linebox_height = APConfig.max_py-APConfig.py
APConfig.lines_amount = math.floor(APConfig.linebox_height/APConfig.line_height)

local APElements = {}
local APPlayers = {}

function APOnElementDataChange(key)
	local player = source
	if key == APData then
		local data = getElementData(player,key)
		APSetState(data)
	elseif key == APDutyData then
		local data = getElementData(player,key)
		if getElementData(localPlayer,APData) and data then
			APSetState(false)
		end
	end
end
addEventHandler( "onClientElementDataChange", localPlayer, APOnElementDataChange )

function APOnResourceStart()
	if getElementData(localPlayer,APData) then
		APSetState(true)
	end
end
addEventHandler("onClientResourceStart",resourceRoot,APOnResourceStart)

function APSetState(state)
	APSTATE = true
	if isTimer(SAVETIMER) then killTimer(SAVETIMER) end
	if state then
		if isTimer(RESET_DATA_TIMER) then killTimer(RESET_DATA_TIMER) end
		SAVED_POSITION = {getElementPosition(localPlayer)}
		SAVED_POSITION[3] = SAVED_POSITION[3]
		SAVED_INTERIOR = getElementInterior(localPlayer) or 0
		SAVED_DIMENSION = getElementDimension(localPlayer)
		updateSavedValues()
		APSetState(false)
		showCursor(true)
		addEventHandler("onClientRender",root,APRender,true,"low-500000")
		addEventHandler("onClientPlayerJoin",root,APUpdatePlayers)
		addEventHandler("onClientPlayerQuit",root,APUpdatePlayers)
		APUpdatePlayers()
		APElements.MAIN = ibCreateImage( APConfig.wpx,APConfig.wpy,APConfig.wsx,APConfig.wsy, nil, nil, APConfig.bg_color )
		APElements.Search = ibCreateEdit(80, 10, 225, APConfig.wsy-20, "", APElements.MAIN, 0xffffffff, 0x77000000 )
		:ibData( "priority", 1 )
		:ibOnDataChange( function( key, value )
			if key == "text" then
				APSetSearch( utf8.lower(value) )
			end
		end )
		APElements.Search_label = ibCreateLabel( 10, 10, 60, APConfig.wsy-20, "Поиск", APElements.MAIN, 0xFFFFFFFF, 1, 1, "center", "center" )
		:ibData( 'font', ibFonts.regular_10 )

		APElements.Teleport_label = ibCreateLabel( 0,-30,APConfig.wsx,30,"F6 - переключение режима, F7 - перемещение в текущую позицию", APElements.MAIN, 0xFFFFFFFF, 1, 1, "center", "center" )
		:ibData( 'font', ibFonts.regular_10 )

		APElements.Spectator_button = ibCreateButton( 320, 10, 70, APConfig.wsy-20, APElements.MAIN, nil,nil,nil,0xFF000000,0xFF303030,0xFF404040 )
		APElements.Spectator_button_label = ibCreateLabel( 0, 0, 70, APConfig.wsy-20, "Spec", APElements.Spectator_button, 0xFFFFFFFF, 1, 1, "center", "center" )
		:ibData( 'disabled', true )
		:ibData( 'font', ibFonts.regular_10 )

		addEventHandler( "ibOnElementMouseClick", APElements.Spectator_button, function( button, state )
			if button ~= "left" or state ~= "up" then return end
			APSetCameraMode("spectate")
		end )

		APElements.Freecam_button = ibCreateButton( 390, 10, 70, APConfig.wsy-20, APElements.MAIN, nil,nil,nil,0xFF000000,0xFF303030,0xFF404040 )
		APElements.Freecam_button_label = ibCreateLabel( 0, 0, 70, APConfig.wsy-20, "Free", APElements.Freecam_button, 0xFFFFFFFF, 1, 1, "center", "center" )
		:ibData( 'disabled', true )
		:ibData( 'font', ibFonts.regular_10 )

		addEventHandler( "ibOnElementMouseClick", APElements.Freecam_button, function( button, state )
			if button ~= "left" or state ~= "up" then return end
			APSetCameraMode("freecam")
		end )

		APElements.Player_label = ibCreateLabel( 0, 10, APConfig.wsx-10, APConfig.wsy-20, "Поиск", APElements.MAIN, 0xFFFFFFFF, 1, 1, "right", "center" )
		:ibData( 'font', ibFonts.regular_10 )

		APSetCameraMode(APConfig.current_mode or "spectate")
		bindKey("F6","down",APControlBinds)
		bindKey("F7","down",APSaveCurrentCamera)
		bindKey("l","down",APSwitchUI)
		addEventHandler("onClientClick",root,APOnClick)
		toggleControl("accelerate",false)
		toggleControl("brake_reverse",false)

		REFRESH_PLAYERS_TIMER = setTimer(APUpdatePlayers, 1000, 0)
	else
		if isTimer(REFRESH_PLAYERS_TIMER) then killTimer(REFRESH_PLAYERS_TIMER) end
		if next(APElements) then
			if APElements.MAIN then
				APElements.MAIN:destroy()
			end
		end
		APSetCameraMode()
		APElements = {}
		showCursor(false)
		unbindKey("F6","down",APControlBinds)
		unbindKey("F7","down",APSaveCurrentCamera)
		unbindKey("l","down",APSwitchUI)
		removeEventHandler("onClientRender",root,APRender)
		removeEventHandler("onClientPlayerJoin",root,APUpdatePlayers)
		removeEventHandler("onClientPlayerQuit",root,APUpdatePlayers)
		removeEventHandler("onClientClick",root,APOnClick)
		setElementFrozen(localPlayer,true)
		if isTimer(RESET_DATA_TIMER) then killTimer(RESET_DATA_TIMER) end
		RESET_DATA_TIMER = setTimer(function()
			setElementFrozen(localPlayer,false)
			if SAVED_POSITION then
				setElementPosition(localPlayer,SAVED_POSITION[1],SAVED_POSITION[2],SAVED_POSITION[3])
			end
			if SAVED_INTERIOR then
				setElementInterior(localPlayer,SAVED_INTERIOR)
			end
			if SAVED_DIMENSION then
				setElementDimension(localPlayer,SAVED_DIMENSION)
			end
			updateCameraSwitch(localPlayer)
			--SAVETIMER = setTimer(updateSavedValues,1000,1,true)
			--localPlayer:setData( "spec_int", false, false )
			--localPlayer:setData( "spec_dim", false, false )
			--triggerServerEvent("onAdminPanelDataSwitch",localPlayer,{interior = SAVED_INTERIOR, dimension = SAVED_DIMENSION})
		end,300,1)
		toggleControl("accelerate",true)
		toggleControl("brake_reverse",true)
	end
end

function APSetCameraMode(mode)
	showCursor( false )
	setFreecamDisabled()
	setElementFrozen(localPlayer,false)
	if localPlayer.vehicle and localPlayer.vehicle.occupants[ 0 ] == localPlayer then localPlayer.vehicle.frozen = true end
	if mode == "spectate" then
		setElementFrozen(localPlayer,true)
		showCursor( true )
		APConfig.current_mode = mode
		localPlayer:setData( "cam_target", localPlayer, false )
		APElements.Spectator_button_label:ibData( 'color', 0xffffffff )
		APElements.Freecam_button_label:ibData( 'color', 0xff808080 )
	elseif mode == "freecam" then
		localPlayer:setData( "cam_target", nil, false )
		setElementFrozen(localPlayer,true)
		APConfig.current_mode = mode
		APElements.Spectator_button_label:ibData( 'color', 0xff808080 )
		APElements.Freecam_button_label:ibData( 'color', 0xffffffff )
		showCursor(false)
		setFreecamEnabled()
	else
		localPlayer:setData( "cam_target", nil, false )
		setCameraTarget(localPlayer)
		if localPlayer.vehicle and localPlayer.vehicle.occupants[ 0 ] == localPlayer then localPlayer.vehicle.frozen = false end
	end
end

function OnSpectateRequest( pTarget )
	if isElement(pTarget) then
		APSetCameraMode("spectate")
		localPlayer:setData( "cam_target", pTarget, false )
	end
end
addEvent("AP:OnSpectateRequest", true)
addEventHandler("AP:OnSpectateRequest", root, OnSpectateRequest)
 
function APControlBinds(key,state)
	if state ~= "down" then return end
	local new_state = APConfig.current_mode == "spectate" and "freecam" or "spectate"
	APSetCameraMode(new_state)
end

function APToggleCursor()
	local cursor = isCursorShowing()
	showCursor(not cursor)
end

function APSetSearch(search)
	APConfig.search = search or nil
	APUpdatePlayers()
end

function APRender()
	if not isElementFrozen(localPlayer) then
		setElementFrozen(localPlayer,true)
	end
	if SAVED_POSITION then
		setElementPosition(localPlayer,SAVED_POSITION[1],SAVED_POSITION[2],SAVED_POSITION[3])
	end
	local font_scale,font = APConfig.list_font_scale,APConfig.list_font
	local camera_target = getCameraTarget() or getElementData(localPlayer,"SpecTarget")
	if isElement(camera_target) and getElementType(camera_target) == "vehicle" then
		camera_target = getVehicleOccupant(camera_target)
	end
	for i,player_data in pairs(APPlayers.list) do
		while true do
			local i = i + APConfig.current_scroll
			local px,py = APConfig.px,APConfig.py+(i-1)*APConfig.line_height
			if py < APConfig.py or py > APConfig.max_py then break end

			local rpx,rpy,rsx,rsy = px-player_data.width-APConfig.bg_gap,py-APConfig.bg_gap_vertical,player_data.width+APConfig.bg_gap*2,player_data.height+APConfig.bg_gap_vertical*2
			local previous_hover = player_data.hover
			local current_hover = isMouseWithinRangeOf(rpx,rpy,rsx,rsy)
			if current_hover and not previous_hover then
				APPlayers.list[i].hover = true
			elseif not current_hover and previous_hover then
				APPlayers.list[i].hover = nil
			end

			dxDrawRectangle(rpx,rpy,rsx,rsy,(camera_target == player_data.player and i == 1) and 0x99333333 or current_hover and 0x99333333 or 0xbb000000)
			dxDrawText(player_data.display_name,rpx+APConfig.bg_gap,rpy,rpx+rsx,rpy+rsy,(camera_target == player_data.player and 0xffffff00 or 0xffffffff),font_scale,font,"left","center",false,false,false,true)
			break
		end
	end
	local camera_target_name = camera_target and APPlayers.byelement[camera_target] and APPlayers.byelement[camera_target].display_name or ""
	if APElements.Player_label:ibData( 'text' ) ~= camera_target_name then
		APElements.Player_label:ibData( 'text', camera_target_name )
	end
end

function APSaveCurrentCamera()
	if not APSTATE then return end
	local mx,my,mz = getCameraMatrix()
	SAVED_POSITION = {mx,my,mz}
	SAVED_POSITION[3] = SAVED_POSITION[3]
	SAVED_INTERIOR = localPlayer.interior
	SAVED_DIMENSION = localPlayer.dimension

	if localPlayer.vehicle then
		setElementPosition( localPlayer.vehicle, SAVED_POSITION[1], SAVED_POSITION[2], SAVED_POSITION[3] )
	end
	triggerServerEvent("onAdminPanelDataSwitch", localPlayer, {interior = localPlayer.interior, dimension = localPlayer.dimension})
	outputChatBox("Вы были перемещены на позицию камеры",0,255,0)
	updateSavedValues()
end

function updateSavedValues(clear)
	local save = {SAVED_POSITION, SAVED_INTERIOR, SAVED_DIMENSION}
	if clear then save = nil end
	triggerServerEvent("onAdminPanelDefaultSwitch", localPlayer, save)
end

function APOnClick(button,state)
	if not isCursorShowing() then return end
	if button ~= "left" or state ~= "down" then return end
	for i,player_data in pairs(APPlayers.list) do
		if player_data.hover then
			--setCameraTarget(localPlayer,player_data.player)
			local player = player_data.player
			localPlayer:setData( "cam_target", player, false )
			updateCameraSwitch(player)
			break
		end
	end
end

function updateCameraSwitch(player)
	local new_interior = player == localPlayer and SAVED_INTERIOR or player.interior
	local new_dimension = player == localPlayer and SAVED_DIMENSION or player.dimension
	localPlayer.interior = new_interior
	localPlayer.dimension = new_dimension
	--localPlayer:setData( "spec_int", new_interior, false )
	--localPlayer:setData( "spec_dim", new_dimension, false )
	triggerServerEvent("onAdminPanelDataSwitch", localPlayer, {interior = new_interior, dimension = new_dimension})
end

function APUpdatePlayers()
	local search = APConfig.search
	local players = getElementsByType("player")
	APPlayers.list = {}
	APPlayers.byelement = {}
	for i,player in pairs(players) do
		while true do
			local id = player:GetID() --string.match(tostring(getElementData(player,"Nametag::Text")),"%d+")
			local name = getPlayerNametagText( player )
			if not id or not name then break end
			local real_name = getPlayerName(player)
			local player_data = {player = player,id = id,name = name,real_name = real_name,display_name = ("%s. %s"):format(id,name)}
			player_data.width = dxGetTextWidth(player_data.display_name,APConfig.list_font_scale,APConfig.list_font)
			local text_was_changed = false
			while player_data.width > 150 do
				player_data.display_name = utf8.sub(player_data.display_name,1,-2)
				player_data.width = dxGetTextWidth(player_data.display_name,APConfig.list_font_scale,APConfig.list_font)
				text_was_changed = true
			end
			if text_was_changed then player_data.display_name = player_data.display_name.."..." end
			player_data.width = 150
			player_data.height = dxGetFontHeight(APConfig.list_font_scale,APConfig.list_font)
			APPlayers.byelement[player] = player_data
			if not search or search and utf8.find(utf8.lower(player_data.display_name),search,1,true) then
				table.insert(APPlayers.list,player_data)
			end
			break
		end
	end
	table.sort(APPlayers.list,function(a,b) return a.id < b.id end)
end

function isMouseWithinRangeOf(px,py,sx,sy)
  if not isCursorShowing() then
    return false
  end
  local cx,cy = getCursorPosition()
  cx,cy = cx*x,cy*y
  if cx >= px and cx <= px+sx and cy >= py and cy <= py+sy then
    return true,cx,cy
  else
    return false
  end
end

local pScreenSource = dxCreateScreenSource( x, y )
local bUIHidden = false

function APSwitchUI()
	if bUIHidden then
		removeEventHandler( "onClientHUDRender", root, RenderWithoutEverything )
	else
		addEventHandler( "onClientHUDRender", root, RenderWithoutEverything, true, "high+100" )
	end
	bUIHidden = not bUIHidden
end

function RenderWithoutEverything()
	dxUpdateScreenSource( pScreenSource, true )
	dxDrawImage( 0, 0, x, y, pScreenSource, 0, 0, 0, tocolor(255,255,255,255), true )
end

