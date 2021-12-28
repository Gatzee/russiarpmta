local ui = {}
local minigame = {}
local fWireLevel = 0
local last_update = 0

local circle_textures = {}

function ToggleFishingHUD( state )
	if state then
		ui.rod_icon = ibCreateImage( scx-154, scy-35, 24, 23, "files/img/icon_rod_1.png" )
		ui.tool_bar_bg = ibCreateImage( scx-120, scy-25,  100, 10, nil, nil, 0x80000000  )
		ui.tool_bar_body = ibCreateImage( 0, 0,  100*0.5, 10, nil, ui.tool_bar_bg, 0xFFff9936  )

		ui.backpack_icon = ibCreateImage( scx-154, scy-70, 26, 26, "files/img/hud/icon_backpack.png" )
		ui.backpack_bar_bg = ibCreateImage( scx-120, scy-60,  100, 10, nil, nil, 0x80000000  )
		ui.backpack_bar_body = ibCreateImage( 0, 0,  100*0.5, 10, nil, ui.backpack_bar_bg, 0xFF4394d5  )

		ui.l_hook = ibCreateLabel( scx/2, scy/3-55, 0, 0, "Подсекай", nil, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_12):ibData("outline", 1):ibData("alpha", 0)
		ui.hint1 = ibCreateImage( scx/2+30, scy/2, 377, 34, "files/img/hud/hint1.png" ):ibData("alpha", 0)
		ui.hint2 = ibCreateImage( scx/2+50, scy/2, 401, 34, "files/img/hud/hint2.png" ):ibData("alpha", 0)

		UpdateBars()

		addEventHandler("onClientKey", root, MinigameKeyHandler)
		addEventHandler("onClientElementDataChange", localPlayer, OnHobbyDataChanged)
	else
		for k,v in pairs(ui) do
			if isElement(v) then
				destroyElement( v )
			end
		end

		removeEventHandler("onClientKey", root, MinigameKeyHandler)
		removeEventHandler("onClientElementDataChange", localPlayer, OnHobbyDataChanged)
	end
end

function UpdateBars()
	-- Backpack
	local fBackpackSize = localPlayer:GetHobbyBackpackSize()
	local pItems = localPlayer:GetHobbyItems()

	local fUsedBackpackSpace = 0
	for k,v in pairs( pItems[HOBBY_FISHING] or {} ) do
		fUsedBackpackSpace = fUsedBackpackSpace + v.weight
	end
	ui.backpack_bar_body:ibData("sx", 100*( fUsedBackpackSpace/fBackpackSize ) )

	-- Tool state
	local pEquipment = localPlayer:GetHobbyEquipment()
	local pTool = FISHING_DATA.tool

	for k,v in pairs(pEquipment) do
		if v.class == "fishing:rod" and v.equipped then
			pTool = v
			break
		end
	end

	local fStatus = pTool and (pTool.durability / FISHING_DATA.tool_data.durability) or 0

	ui.tool_bar_body:ibData("sx", 100*fStatus )
end

function OnHobbyDataChanged( key, value )
	if key == "hobby_equipment" or key == "hobby_items" then
		UpdateBars()
	end
end

local disabled_controls = 
{
	"forwards",
	"backwards",
	"left",
	"right",
}

function StartMinigame()
	minigame = 
	{
		stage = 1,
		iter = 0,
		started = getTickCount(),
	}
	minigame.blow_in = math.random( 8,24 )
	minigame.lost_in = minigame.started + minigame.blow_in*1000 + 15000
	addEventHandler("onClientRender", root, RenderMinigame)

	circle_textures[1] = dxCreateTexture( "files/img/hud/circle_new.png" )
	circle_textures[2] = dxCreateTexture( "files/img/hud/empty_circle.png" )

	for k,v in pairs(disabled_controls) do
		toggleControl( v, false )
	end
end

function StopMinigame( is_win )
	minigame = {}
	ui.hint1:ibData("alpha", 0)
	ui.l_hook:ibData("alpha", 0)
	ui.hint2:ibData("alpha", 0)
	removeEventHandler("onClientRender", root, RenderMinigame)

	setPedAnimation(localPlayer, nil)
	setElementAlpha( FISHING_DATA.floater, 0 )

	for k,v in pairs(circle_textures) do
		if isElement(v) then
			destroyElement( v )
		end
	end

	for k,v in pairs(disabled_controls) do
		toggleControl( v, true )
	end
end


local last_switch = 0
local isGreen = false

function NextMinigameStage()
	minigame.action_phase = false

	if minigame.stage == 1 then
		minigame.stage = 2
		minigame.started = getTickCount()
		minigame.lost_in = minigame.started + 15000

		ui.hint1:ibData("alpha", 0)
		ui.l_hook:ibData("alpha", 0)
		ui.hint2:ibData("alpha", 255)

		FISHING_DATA.sfx = playSound( "files/sounds/sfx_process.wav", true )
		setSoundVolume( FISHING_DATA.sfx, 1 )
	elseif minigame.stage == 2 then
		if isElement(FISHING_DATA.sfx) then destroyElement( FISHING_DATA.sfx ) end

		minigame.stage = 1
		last_switch = 0
		minigame.iter = minigame.iter + 1

		ui.hint2:ibData("alpha", 0)

		if minigame.iter >= 3 then
			SwitchFishingMinigame( false, true )

			FISHING_DATA.sfx = playSound( "files/sounds/sfx_caught.wav" )
			setSoundVolume( FISHING_DATA.sfx, 1 )

			triggerServerEvent("OnPlayerCatchedFish", resourceRoot, FISHING_DATA.item_uid)
		else
			minigame.started = getTickCount()
			minigame.blow_in = 0
			minigame.lost_in = minigame.started + 8000
		end
	end
end

local bar_x, bar_y, bar_sx, bar_sy = scx/2, scy/2, 10, 120

function RenderMinigame()
	if minigame.stage == 1 then
		local iTimeLeft = getTickCount() - minigame.started
		local fProgress = iTimeLeft / 1000 / minigame.blow_in
		if fProgress >= 1 then
			minigame.action_phase = true
			ui.hint1:ibData("alpha", 255)
			ui.l_hook:ibData("alpha", 255)

			local fClickProgress = (getTickCount()-last_switch)/3000
			if fClickProgress >= 1 then
				fClickProgress = 1
				last_switch = getTickCount()
			end
			local fSize = interpolateBetween( 10, 0, 0, 98, 0, 0, fClickProgress, "SineCurve")
			isGreen = (fClickProgress >= 0.25 and fClickProgress <= 0.4) or (fClickProgress >= 0.55 and fClickProgress <= 0.7)
			dxDrawImage( scx/2-98/2, scy/3-98/2, 98, 98, circle_textures[1], 0, 0, 0, 0x88FFFFFF )
			dxDrawImage( scx/2-fSize/2, scy/3-fSize/2, fSize, fSize, circle_textures[2], 0, 0, 0, isGreen and 0xAA00FF00 or 0xAAFF0000 )
		end
	elseif minigame.stage == 2 then
		dxDrawRectangle( bar_x, bar_y, bar_sx, bar_sy, 0x80000000 )
		local part_size = (bar_sy-2)*fWireLevel
		dxDrawRectangle( bar_x+1, bar_y+bar_sy-part_size, 8, part_size, 0xFFe3ca41 )

		if getTickCount() - minigame.started >= 500 then
			local fTimePassed = (getTickCount() - last_update) / 1000
			fWireLevel = math.max( fWireLevel - 0.2 * fTimePassed, 0 )
		end

		last_update = getTickCount()
	end

	if getTickCount() >= minigame.lost_in then
		localPlayer:MissionFailed( "Рыба сорвалась!" )
		SwitchFishingMinigame( false, true )
	end
end

local last_click = 0
function MinigameKeyHandler( key, state )
	if key == "mouse1" then
		if minigame.stage == 1 and minigame.action_phase then
			if isGreen then
				setPedAnimation( localPlayer, "BSKTBALL", "BBALL_SkidStop_L", -1, false, false, false, false )
				NextMinigameStage()
			else
				localPlayer:MissionFailed( "Рыба сорвалась!" )
				SwitchFishingMinigame( false, true )
			end
		end
	elseif key == "mouse2" and state then
		if minigame.stage == 2 then
			if getTickCount() - last_click <= 100 then return end

			fWireLevel = fWireLevel + math.random(8,12)/100
			setPedAnimation( localPlayer, "flame", "flame_fire", -1, false, false, false, false )
			
			if fWireLevel >= 1 then
				setPedAnimation( localPlayer, "sword", "sword_idle", -1, false, false, false, true )
				NextMinigameStage()
				fWireLevel = 0
			end

			last_click = getTickCount()
		end
	end
end

local circle_texture
local end_x, end_y, end_z

function RenderThrowZone( )
	local start_x, start_y, start_z = getElementPosition(localPlayer)

	if localPlayer.vehicle then
		start_x, start_y, start_z = localPlayer.vehicle.position.x, localPlayer.vehicle.position.y, localPlayer.vehicle.position.z
	end

	end_x, end_y, end_z = getWorldFromScreenPosition( scx / 2, scy / 2, 25 )
	start_x, start_y, start_z = PointsSegment( start_x, start_y, start_z, end_x, end_y, end_z, 0.9 )
	local hit, s_end_x, s_end_y, s_end_z = processLineOfSight( start_x, start_y, start_z, end_x, end_y, end_z, true, false )

	if not hit then
		s_end_x, s_end_y, s_end_z = end_x, end_y, end_z
	end

	s_end_x, s_end_y, s_end_z = PointsSegment( start_x, start_y, start_z, s_end_x, s_end_y, s_end_z, 0.2 )
	hit, end_x, end_y, end_z = processLineOfSight( s_end_x, s_end_y, s_end_z + 1.5, s_end_x, s_end_y, s_end_z - 50, true, false )

	if not hit then
		return
	end

	end_z = getWaterLevel( getElementPosition(localPlayer) ) or start_z
	end_z = end_z + 1

	local half_size = 1
	dxDrawMaterialLine3D( end_x - half_size, end_y - half_size, end_z - 0.95, end_x + half_size, end_y + half_size, end_z - 0.95, circle_texture, half_size*3, tocolor( 200, 50, 50, 255 ), end_x, end_y, end_z + 2 )
end

function PointsSegment( s_x, s_y, s_z, e_x, e_y, e_z, percent )
	percent = math.max( 0.01, math.min( 1, percent ) );

    x = e_x * ( 1 - percent ) + s_x * percent;
    y = e_y * ( 1 - percent ) + s_y * percent;
	z = e_z * ( 1 - percent ) + s_z * percent;
	
	return x, y, z
end

function GetAimTargetPosition()
	return end_x, end_y, end_z - 1
end

function ToggleRenderThrowZone( state )
	removeEventHandler("onClientRender", root, RenderThrowZone)
	if isElement(circle_texture) then destroyElement( circle_texture ) end
	if state then
		if not isElement(circle_texture) then
			circle_texture = dxCreateTexture( ":nrp_clans/img/dropimage.dds" )
		end
		addEventHandler("onClientRender", root, RenderThrowZone)
	end
end