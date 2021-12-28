local ui = {}
local minigame = {}

function ToggleDiggingHUD( state )
	if state then
		ui.rod_icon = ibCreateImage( scx-154, scy-35, 24, 23, "files/img/icon_shovel_1.png" )
		ui.tool_bar_bg = ibCreateImage( scx-120, scy-25,  100, 10, nil, nil, 0x80000000  )
		ui.tool_bar_body = ibCreateImage( 0, 0,  100*0.5, 10, nil, ui.tool_bar_bg, 0xFFff9936  )

		ui.backpack_icon = ibCreateImage( scx-154, scy-70, 26, 26, "files/img/icon_backpack.png" )
		ui.backpack_bar_bg = ibCreateImage( scx-120, scy-60,  100, 10, nil, nil, 0x80000000  )
		ui.backpack_bar_body = ibCreateImage( 0, 0,  100*0.5, 10, nil, ui.backpack_bar_bg, 0xFF4394d5  )

		ui.hint1 = ibCreateImage( scx/2+30, scy/2, 385, 34, "files/img/hud/hint1.png" ):ibData("alpha", 0)
		ui.hint2 = ibCreateImage( scx/2+100, scy/2, 442, 34, "files/img/hud/hint2.png" ):ibData("alpha", 0)

		UpdateBars()
		ui.help_mapkey = ibCreateImage( scx-72, scy-120, 52, 45, "files/img/help_mapkey.png" )

		addEventHandler("onClientElementDataChange", localPlayer, OnHobbyDataChanged)
	else
		for k,v in pairs(ui) do
			if isElement(v) then
				destroyElement( v )
			end
		end

		removeEventHandler("onClientElementDataChange", localPlayer, OnHobbyDataChanged)
	end
end

function UpdateBars()
	-- Backpack
	local fBackpackSize = localPlayer:GetHobbyBackpackSize()
	local pItems = localPlayer:GetHobbyItems()

	local fUsedBackpackSpace = 0
	for k,v in pairs( pItems[HOBBY_DIGGING] or {} ) do
		fUsedBackpackSpace = fUsedBackpackSpace + v.weight
	end
	ui.backpack_bar_body:ibData("sx", 100*( fUsedBackpackSpace/fBackpackSize ) )

	-- Tool state
	local pEquipment = localPlayer:GetHobbyEquipment()
	local pTool = DIGGING_DATA.tool

	for k,v in pairs(pEquipment) do
		if v.class == "digging:shovel" and v.equipped then
			pTool = v
			break
		end
	end

	local fStatus = pTool and (pTool.durability / DIGGING_DATA.tool_data.durability) or 0

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

local iMinigameStarted = 0
local iLastDig = 0
local fZonePosition = 0
local iDigsMade, iGoodDigsMade = 0, 0

function StartDiggingMinigame()
	removeEventHandler("onClientPreRender", root, PreRenderMinigame)
	if isElement(minigame.bar_bg) then destroyElement(minigame.bar_bg) end

	iLastDig = getTickCount()+1000
	iMinigameStarted = getTickCount()
	iDigsMade = 0
	iGoodDigsMade = 0

	DIGGING_DATA.digging = true

	minigame.sfx = playSound( "files/sounds/digging.mp3", true )
	setSoundPosition( minigame.sfx, math.random(0, 40) )
	setPedAnimation(localPlayer, "DIGGING", "Dig", -1, true, false)

	fZonePosition = math.random(0, 80)/100

	local scx, scy = guiGetScreenSize()

	minigame.bar_bg = ibCreateImage( scx/2+80, scy/2-120, 14, 220, nil, false, 0x80212b36)
	minigame.bar_zone = ibCreateImage( 1, 220*fZonePosition, 12, 40, nil, minigame.bar_bg, 0xFFe3ca41 )
	minigame.bar_line = ibCreateImage( -4, 0, 22, 2, nil, minigame.bar_bg, 0xFFFFFFFF )

	minigame.good = ibCreateImage( scx/2+94, scy/2-110, 106, 52, "files/img/good.png" ):ibData("alpha", 0)
	minigame.bad = ibCreateImage( scx/2+94, scy/2-110, 88, 50, "files/img/bad.png" ):ibData("alpha", 0)

	addEventHandler("onClientPreRender", root, PreRenderMinigame)

	ui.hint1:ibData("alpha", 0)
	ui.hint2:ibData("alpha", 255)

	for k,v in pairs(disabled_controls) do
		toggleControl( v, false )
	end
end

function StopDiggingMinigame()
	ui.hint1:ibData("alpha", 255)
	ui.hint2:ibData("alpha", 0)

	DIGGING_DATA.digging = false

	for k,v in pairs(minigame) do
		if isElement(v) then
			destroyElement( v )
		end
	end
	removeEventHandler("onClientPreRender", root, PreRenderMinigame)

	setPedAnimation(localPlayer, nil)

	for k,v in pairs(disabled_controls) do
		toggleControl( v, true )
	end

	minigame = {}
end

function PreRenderMinigame()
	local fProgress = ( getTickCount() - iMinigameStarted ) / 2000

	local py = interpolateBetween( 10, 0, 0, 215, 0, 0, fProgress%1, "SineCurve" )
	minigame.bar_line:ibData("py", py)

	if iLastDig and getTickCount() - iLastDig > 15000 then
		localPlayer:ShowError("Не спи!")
		StopDiggingMinigame()
		return
	end

	if getKeyState("mouse1") then
		local is_good = py >= 220*fZonePosition and py <= 220*fZonePosition+40

		if OnPlayerDig( is_good ) then
			local mark_line = ibCreateImage( 0, py, 14, 2, nil, minigame.bar_bg, is_good and 0xff22dd22 or 0xffdd2222  )
			:ibTimer(function( element )
				destroyElement( element )
			end, 6000, 1, mark_line)
			:ibAlphaTo(0, 6000)

			table.insert(minigame, mark_line)

			minigame.bar_line:ibData("alpha", 50)
			:ibTimer( function() 
				minigame.bar_line:ibData("alpha", 255)
			end, 1800, 1)
		end
	end
end

function OnPlayerDig( is_good )
	if iLastDig and getTickCount() - iLastDig < 1800 then return end
	iLastDig = getTickCount()

	iDigsMade = iDigsMade + 1

	if is_good then
		iGoodDigsMade = iGoodDigsMade + 1
		minigame.hit_sfx = playSound("files/sounds/hit.mp3")
		minigame.good:ibAlphaTo(255, 500)
		:ibTimer(function()
			minigame.good:ibAlphaTo( 0, 500 )
		end, 1000, 1)
	else
		minigame.bad:ibAlphaTo(255, 500)
		:ibTimer(function()
			minigame.bad:ibAlphaTo( 0, 500 )
		end, 1000, 1)
	end

	local bIsWithinTreasureCol = isElementWithinColShape( localPlayer, DIGGING_DATA.t_col )

	if iGoodDigsMade >= 5 then
		StopDiggingMinigame()

		if bIsWithinTreasureCol then
			triggerServerEvent("OnPlayerDigged", resourceRoot, DIGGING_DATA.item_uid)
		else
			localPlayer:ShowInfo("Кажется, здесь ничего нет")
		end

		triggerServerEvent("OnPlayerHobbyToolUsed", localPlayer, localPlayer, HOBBY_DIGGING)
		return
	end

	if iDigsMade >= 12 then
		StopDiggingMinigame()

		if bIsWithinTreasureCol then
			triggerServerEvent("OnPlayerDigged", resourceRoot, DIGGING_DATA.item_uid)
		else
			localPlayer:ShowInfo("Кажется, здесь ничего нет")
		end

		triggerServerEvent("OnPlayerHobbyToolUsed", localPlayer, localPlayer, HOBBY_DIGGING)
		return
	end

	return true
end