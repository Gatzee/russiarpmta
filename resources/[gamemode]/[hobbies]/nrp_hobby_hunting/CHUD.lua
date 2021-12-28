local ui = {}

function ToggleHuntingHUD( state )
	if state then
		ToggleHuntingHUD( false )

		ui.rod_icon = ibCreateImage( scx-154, scy-160, 24, 23, "files/img/icon_rifle_1.png" )
		ui.tool_bar_bg = ibCreateImage( scx-120, scy-150,  100, 10, nil, nil, 0x80000000  )
		ui.tool_bar_body = ibCreateImage( 0, 0,  100*0.5, 10, nil, ui.tool_bar_bg, 0xFFff9936  )

		ui.backpack_icon = ibCreateImage( scx-154, scy-130, 26, 26, "files/img/icon_backpack.png" )
		ui.backpack_bar_bg = ibCreateImage( scx-120, scy-120,  100, 10, nil, nil, 0x80000000  )
		ui.backpack_bar_body = ibCreateImage( 0, 0,  100*0.5, 10, nil, ui.backpack_bar_bg, 0xFF4394d5  )

		ui.harvest_bar_bg = ibCreateImage( scx/2-250, scy-250, 500, 26, nil, nil, 0x80000000  )
		ui.harvest_bar_body = ibCreateImage( 1, 1, 498, 24, nil, ui.harvest_bar_bg, 0xFF22AAFF  )
		ui.harvest_bar_label = ibCreateLabel( 0, 0, 500, 26, "Прогресс добычи...", ui.harvest_bar_bg, 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_12):ibData("outline", 1)
		ui.harvest_bar_bg:ibData("alpha", 0)

		UpdateBars()

		addEventHandler("onClientElementDataChange", localPlayer, OnHobbyDataChanged)
	else
		for k,v in pairs(ui) do
			if isElement(v) then
				destroyElement( v )
			end
		end

		removeEventHandler("onClientElementDataChange", localPlayer, OnHobbyDataChanged)
		removeEventHandler("onClientRender", root, RenderHarvest)
	end
end

function UpdateBars()
	-- Backpack
	local fBackpackSize = localPlayer:GetHobbyBackpackSize()
	local pItems = localPlayer:GetHobbyItems()

	local fUsedBackpackSpace = 0
	for k,v in pairs( pItems[HOBBY_HUNTING] or {} ) do
		fUsedBackpackSpace = fUsedBackpackSpace + v.weight
	end
	ui.backpack_bar_body:ibData("sx", 100*( fUsedBackpackSpace/fBackpackSize ) )

	-- Tool state
	local pEquipment = localPlayer:GetHobbyEquipment()
	local pTool

	for k,v in pairs(pEquipment) do
		if v.class == "hunting:rifle" and v.equipped then
			pTool = v
			break
		end
	end

	local fStatus = pTool and (pTool.durability / HUNTING_DATA.tool_data.durability) or 0

	ui.tool_bar_body:ibData("sx", 100*fStatus )
end

function OnHobbyDataChanged( key, value )
	if key == "hobby_equipment" or key == "hobby_items" then
		UpdateBars()
	end
end

local iFinishHarvesting = 0
local iHarvestDuration = 0

function ShowHarvestProgress( iTime )
	iHarvestDuration = iTime
	iFinishHarvesting = getTickCount() + iTime

	ui.harvest_bar_bg:ibAlphaTo( 255, 3000 )

	addEventHandler("onClientRender", root, RenderHarvest)
end

function RenderHarvest()
	local fProgress = 1-( iFinishHarvesting - getTickCount() ) / iHarvestDuration

	if fProgress >= 1 then
		ui.harvest_bar_bg:ibData("alpha", 0)
		removeEventHandler("onClientRender", root, RenderHarvest)
		FinishHarvesting()
	else
		ui.harvest_bar_body:ibData('sx', 498*fProgress)
	end
end

