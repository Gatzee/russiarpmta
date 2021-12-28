local sizeX, sizeY = 670, 580
local posX, posY = (scx-sizeX)/2, (scy-sizeY)/2

local pData = {}
local ui = {}

local iSelection = 1
local HOBBY_ID = 1
local HOBBY_ITEMS = HOBBY_EQUIPMENT[HOBBY_ID]

local pHobbiesData = 
{
	[HOBBY_FISHING] = 
	{
		bg = "bg_fishing",
		sell_title = "ПРОДАЖА РЫБЫ",
		sell_msg = "рыбы",
		tool_name = "эту удочку",
	},

	[HOBBY_HUNTING] = 
	{
		bg = "bg_hunting",
		sell_title = "ПРОДАЖА ДОБЫЧИ",
		sell_msg = "добычи",
		tool_name = "это ружье",
	},

	[HOBBY_DIGGING] = 
	{
		bg = "bg_digging",
		sell_title = "ПРОДАЖА ДОБЫЧИ",
		sell_msg = "добычи",
		tool_name = "эту лопату",
	},
}

function HobbyStore_ShowUI( state, hobby, data )
	if state then
		HobbyEquipment_ShowUI(false)
		HobbyStore_ShowUI(false)
		showCursor(true)

		HOBBY_ID = hobby
		HOBBY_ITEMS = HOBBY_EQUIPMENT[HOBBY_ID]
		pData = data

		iSelection = 1

		ui.black_bg = ibCreateBackground(_, HobbyStore_ShowUI, true, true)

		ui.main = ibCreateImage( posX, posY, sizeX, sizeY, "files/img/"..pHobbiesData[HOBBY_ID].bg..".png", ui.black_bg )
		ui.close = ibCreateButton( sizeX-50, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )

		addEventHandler( "ibOnElementMouseClick", ui.close, function( key, state )
			if key ~= "left" or state ~= "down" then return end
			HobbyStore_ShowUI(false)
		end, false )

		ui.btn_equipment = ibCreateButton( 30, sizeY-74, 160, 44, ui.main, "files/img/btn_equipment.png", "files/img/btn_equipment.png", "files/img/btn_equipment.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
		ui.btn_sell = ibCreateButton( 200, sizeY-74, 160, 44, ui.main, "files/img/btn_sell.png", "files/img/btn_sell.png", "files/img/btn_sell.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )

		addEventHandler( "ibOnElementMouseClick", ui.btn_equipment, function( key, state )
			if key ~= "left" or state ~= "down" then return end
			HobbyStore_ShowUI(false)
			HobbyEquipment_ShowUI( true )
			ibClick()
		end, false )

		addEventHandler( "ibOnElementMouseClick", ui.btn_sell, function( key, state )
			if key ~= "left" or state ~= "down" then return end

			local fBackpackSize = localPlayer:GetHobbyBackpackSize()
			local pItems = localPlayer:GetHobbyItems()
			local iTotalCost = 0
			local fTotalWeight = 0

			local iGameLevel = localPlayer:GetLevel()
			local fGameLevelMultiplier = 1
			for k,v in pairs(HOBBY_SELL_MULTIPLIERS) do
				if iGameLevel >= k and v > fGameLevelMultiplier then
					fGameLevelMultiplier = v
				end
			end

			for k,v in pairs(pItems[HOBBY_ID] or {}) do
				if v.level then
					local iCost = v.weight * HOBBY_EQUIPMENT[ HOBBY_ID ][1].items[v.level].cost_multiplier * fGameLevelMultiplier
					iTotalCost = iTotalCost + iCost
				else
					local iCost = v.weight * 170 * fGameLevelMultiplier
					iTotalCost = iTotalCost + iCost
				end

				if v.is_unique then
					iTotalCost = HOBBY_ID == HOBBY_DIGGING and 75000 or 50000
					fTotalWeight = fBackpackSize
					break
				end

				fTotalWeight = fTotalWeight + v.weight
			end
			if fTotalWeight > 0 then
				ibConfirm(
						{
							title = pHobbiesData[HOBBY_ID].sell_title,
							text = "Ты хочешь продать " .. math.floor(fTotalWeight*10)/10 .. " кг. "..pHobbiesData[HOBBY_ID].sell_msg.." за " .. format_price(iTotalCost) .. "р. ?" ,
							fn = function( self )
								self:destroy()
								triggerServerEvent( "OnPlayerSellHobbyItems", localPlayer, HOBBY_ID )
							end,
							escape_close = true,
						}
				)
			else
				localPlayer:ShowError("Твой рюкзак пуст")
			end
			ibClick()
		end, false )

		local pItems = HOBBY_EQUIPMENT[HOBBY_ID][1]["items"]
		local iMaxHobbyLevel = #pItems

		local pUnlocks = localPlayer:GetHobbyUnlocks( HOBBY_ID )
		local iUnlockedItemId = pUnlocks[PRIMARY_TOOLS[HOBBY_ID]]
		local iUnlockedItemLevel = iUnlockedItemId and pItems[iUnlockedItemId].level or pData.level
		iUnlockedItemLevel = math.max( iUnlockedItemLevel, pData.level )

		local iTotalExpRequired = 0
		local iTotalExpGained = 0

		for k,v in pairs(HOBBY_LEVELS[HOBBY_ID]) do
			iTotalExpRequired = iTotalExpRequired + v.exp

			v.total_exp = iTotalExpRequired

			if iUnlockedItemLevel >= k and k ~= iMaxHobbyLevel then
				iTotalExpGained = iTotalExpGained + v.exp
			end
		end

		iTotalExpGained = iTotalExpGained + pData.exp
		pData.total_exp = iTotalExpGained

		local iNextLockedItemLevel = iUnlockedItemLevel < iMaxHobbyLevel and iUnlockedItemLevel + 1 or iMaxHobbyLevel

		local pNextLevelData = HOBBY_LEVELS[HOBBY_ID][iNextLockedItemLevel]
		local fProgress = 1
		local fUnlockProgress = 1
		local pNextLevelUnlocks = {}
		local iExpLeftUntilUnlock = 0

		if pNextLevelData then
			fProgress = math.min( iTotalExpGained / iTotalExpRequired, 1 )

			fUnlockProgress = ( iTotalExpGained - pData.exp + pNextLevelData.exp ) / iTotalExpRequired
			iExpLeftUntilUnlock = pNextLevelData.exp - pData.exp

			for _, class in pairs( HOBBY_EQUIPMENT[HOBBY_ID] ) do
				-- если предмет есть среди разлоченных игроком, сравниваем уровень хобби с уровнем предмета и берем максимальный
				local iUnlockedItemId = pUnlocks[class.class]
				local iItemLevel = iUnlockedItemId and class.items[iUnlockedItemId].level or 1
				iItemLevel = math.max( pData.level, iItemLevel )

				for i, item in pairs(class.items) do
					if item.level and item.level > iItemLevel then
						local pItem = {
							icon = class.default_icon,
							name = class.default_name,
							id = i,
						}

						table.insert( pNextLevelUnlocks, pItem )

						break
					end
				end
			end
		end


		local sx = hobby == HOBBY_DIGGING and 390 or sizeX-60

		ui.l_your_progress = ibCreateLabel( 30, 80, 0, 40, "Ваш прогресс", ui.main, 0xAAFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_12)
		ui.l_exp = ibCreateLabel( sx+30, 80, 0, 40, pData.exp, ui.main, 0xAAFFFFFF, 1, 1, "right", "center" ):ibData("font", ibFonts.regular_12)

		ui.progress_bar_bg = ibCreateImage( 30, 120, sx, 14, nil, ui.main, 0x40000000)
		ui.progress_bar_body = ibCreateImage( 0, 0, sx*fProgress, 14, nil, ui.progress_bar_bg, 0xFF47afff)
		ui.progress_bar_next_unlock = ibCreateImage( sx*fUnlockProgress, -4, 1, 22, nil, ui.progress_bar_bg, 0xFFFFFFFF)

		if HOBBY_ID == HOBBY_DIGGING then
			ibCreateLabel( sx+60, 80, 0, 40, "Найденные сокровища", ui.main, 0xAAFFFFFF, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_10)
			ibCreateLabel( sx+250, 80, 0, 40, pData.treasures_count.."/50", ui.main, 0xAAFFFFFF, 1, 1, "right", "center" ):ibData("font", ibFonts.regular_10)

			ui.treasures_bar_bg = ibCreateImage( sx+60, 120, 190, 14, nil, ui.main, 0x40000000)
			ui.treasures_bar_body = ibCreateImage( 0, 0, 190*(pData.treasures_count/50), 14, nil, ui.treasures_bar_bg, 0xFF47afff)
		end

		if next( pNextLevelUnlocks ) then
			local fConstrainX = sx - dxGetTextWidth( "Необходимо - XXXXX опыта", 1, ibFonts.regular_9 )
			local px, py = sx*fUnlockProgress, 20
			px = px < fConstrainX and px or fConstrainX
			local sItemsStr = ""
			for k,v in pairs( pNextLevelUnlocks ) do
				ibCreateImage( px, py, 24, 24, v.icon, ui.progress_bar_bg, 0xFFFFFFFF )
				sItemsStr = sItemsStr..v.name.." "..ROMAN_NUMBERS[v.id].." и "
				px = px + 35
			end
			sItemsStr = sItemsStr:sub( 1, -4 )

			local px = sx*fUnlockProgress < fConstrainX and sx*fUnlockProgress or fConstrainX
			ibCreateLabel( px-10, py+30, 0, 0, sItemsStr, ui.progress_bar_bg, 0xFFEEEEEE ):ibData("font", ibFonts.bold_9)
			ibCreateLabel( px-10, py+44, 0, 0, iExpLeftUntilUnlock > 0 and "Необходимо - "..iExpLeftUntilUnlock.." опыта" or "", ui.progress_bar_bg, 0xFFAAAAAA ):ibData( "font", ibFonts.regular_9 )
		end
	else
		if isElement( ui.black_bg ) then
			destroyElement( ui.black_bg )
		end
		showCursor(false)
	end
end

function HobbyEquipment_ShowUI( state, data )
	if state then
		HobbyEquipment_ShowUI( false )
		showCursor(true)

		ui.black_bg = ibCreateBackground(_, HobbyEquipment_ShowUI, true, true)

		ui.main = ibCreateImage( posX, posY, sizeX, sizeY, "files/img/bg.png", ui.black_bg )
		ui.close = ibCreateButton( sizeX-50, 25, 24, 24, ui.main, "files/img/close.png", "files/img/close.png", "files/img/close.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )

		addEventHandler( "ibOnElementMouseClick", ui.close, function( key, state )
			if key ~= "left" or state ~= "down" then return end
			HobbyEquipment_ShowUI(false)
		end, false )

		ui.back = ibCreateButton( 30, 28, 109, 17, ui.main, "files/img/btn_back.png", "files/img/btn_back.png", "files/img/btn_back.png", 0xAAFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )

		addEventHandler( "ibOnElementMouseClick", ui.back, function( key, state )
			if key ~= "left" or state ~= "down" then return end
			HobbyEquipment_ShowUI(false)
		end, false )

		local sx = HOBBY_ID == HOBBY_DIGGING and 390 or sizeX-60

		if HOBBY_ID == HOBBY_DIGGING then
			ibCreateLabel( sx+60, 80, 0, 40, "Найденные сокровища", ui.main, 0xAAFFFFFF, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_10 )
			ibCreateLabel( sx+250, 80, 0, 40, pData.treasures_count.."/50", ui.main, 0xAAFFFFFF, 1, 1, "right", "center" ):ibData( "font", ibFonts.regular_10 )

			ui.treasures_bar_bg = ibCreateImage( sx+60, 120, 190, 14, nil, ui.main, 0x40000000)
			ui.treasures_bar_body = ibCreateImage( 0, 0, 190*( pData.treasures_count/50), 14, nil, ui.treasures_bar_bg, 0xFF47afff )
		end

		local px = 30
		for k,v in pairs(HOBBY_ITEMS) do
			local iWidth = dxGetTextWidth( v.default_name, 1, ibFonts.bold_12  ) + 6
			ui["section"..k] = ibCreateButton( px, 210, iWidth, 30, ui.main, nil, nil, nil, 0x00000000, 0x00000000, 0x00000000 )
			ui["section_name"..k] = ibCreateLabel( 0, 0, iWidth, 30, v.default_name, ui["section"..k], 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_10)
			ui["section_name"..k]:ibData("disabled", true)
			ui["section_name"..k]:ibData("alpha", 150)
			px = px + iWidth

			addEventHandler( "ibOnElementMouseClick", ui["section"..k], function( key, state )
				if key ~= "left" or state ~= "down" then return end
				SwitchSection( k )
			end, false )
		end

		ui.line1 = ibCreateImage( 35, 248, sizeX-70, 1, nil, ui.main, 0x40FFFFFF )
		ui.selector_line = ibCreateImage( 35, 246, 48, 3, nil, ui.main, 0xFFff965d )

		local sCash = format_price( localPlayer:GetMoney() )
		local sDonate = format_price( localPlayer:GetDonate() )

		ui.label_donate = ibCreateLabel( sizeX-60, 210, 0, 30, sDonate, ui.main, 0xFFFFFFFF, 1, 1, "right", "center" ):ibData( "font", ibFonts.bold_10 )
		ui.label_cash = ibCreateLabel( sizeX-110-ui.label_donate:width(), 210, 0, 30, sCash, ui.main, 0xFFFFFFFF, 1, 1, "right", "center" ):ibData( "font", ibFonts.bold_10 )
		ui.icon_cash = ibCreateImage( sizeX-100-ui.label_donate:width(), 212, 24, 24, icon_soft, ui.main )
		ui.label_balance = ibCreateLabel( ui.label_cash:ibData("px")-15-dxGetTextWidth( sCash, 1, ibFonts.bold_10) , 210, 0, 30, "Ваш баланс:", ui.main, 0xFFAAAAAA, 1, 1, "right", "center" ):ibData( "font", ibFonts.regular_12 )
		ui.icon_donate = ibCreateImage( sizeX-54, 212, 24, 24, icon_hard, ui.main )


		ui.label_column1 = ibCreateLabel( 30, 260, 0, 20, "Товар", ui.main, 0xFFAAAAAA, 1, 1, "left", "center"):ibData("font", ibFonts.regular_10)
		ui.label_column2 = ibCreateLabel( 220, 260, 0, 20, "Прочность", ui.main, 0xFFAAAAAA, 1, 1, "left", "center"):ibData("font", ibFonts.regular_10)
		ui.label_column3 = ibCreateLabel( 375, 260, 0, 20, "Стоимость", ui.main, 0xFFAAAAAA, 1, 1, "left", "center"):ibData("font", ibFonts.regular_10)

		ui.scrollpane, ui.scrollbar = ibCreateScrollpane( 0, 290, sizeX, sizeY-290, ui.main, { scroll_px = -20, bg_color = 0 } )

		SwitchSection( 1 )
		addEventHandler("onClientElementDataChange", localPlayer, OnEquipmentDataChanged)
	else
		for k,v in pairs(ui) do
			if isElement(v) then
				destroyElement( v )
			end
		end

		showCursor(false)
		removeEventHandler("onClientElementDataChange", localPlayer, OnEquipmentDataChanged)
	end
end
addEvent("HobbyStore_ShowUI", true)
addEventHandler("HobbyStore_ShowUI", root, HobbyStore_ShowUI)

function HobbyEquipment_UpdateProgressBar( iSection )

	if HOBBY_ID == HOBBY_DIGGING and iSection == 2 or iSection == 3 then
		-- если секция с картами, либо секция с сумками то возврат
		return
	end

	local pItems = HOBBY_ITEMS[iSection].items
	local iMaxHobbyEquipmentLevel = pItems[#pItems].level or pItems[#pItems].player_level

	local pUnlocks = localPlayer:GetHobbyUnlocks( HOBBY_ID )
	local iUnlockedItemId = pUnlocks[HOBBY_ITEMS[iSection].class]
	local iUnlockedItemLevel = iUnlockedItemId and pItems[iUnlockedItemId].level or pData.level
	iUnlockedItemLevel = math.max( iUnlockedItemLevel, pData.level )
	iUnlockedItemLevel = math.min( iUnlockedItemLevel, iMaxHobbyEquipmentLevel )

	local iTotalExpRequired = 0
	local iTotalExpGained = 0

	for k,v in pairs( HOBBY_LEVELS[HOBBY_ID] ) do
		if k > iMaxHobbyEquipmentLevel then
			break
		end

		iTotalExpRequired = iTotalExpRequired + v.exp

		if iUnlockedItemLevel >= k and k ~= iMaxHobbyEquipmentLevel then
			iTotalExpGained = iTotalExpGained + v.exp
		end
	end

	iTotalExpGained = iTotalExpGained + pData.exp

	local iNextLockedItemLevel = iUnlockedItemLevel < iMaxHobbyEquipmentLevel and iUnlockedItemLevel + 1 or iMaxHobbyEquipmentLevel

	local pNextLevelData = HOBBY_LEVELS[HOBBY_ID][iNextLockedItemLevel]
	local pNextLevelUnlocks = {}
	local fProgress = 1
	local fUnlockProgress = 1
	local iExpLeftUntilUnlock = 0

	if pNextLevelData and iSection then

		fProgress = math.min( iTotalExpGained / iTotalExpRequired, 1 )
		fUnlockProgress = (iTotalExpGained - pData.exp + pNextLevelData.exp) / iTotalExpRequired

		iExpLeftUntilUnlock = pNextLevelData.exp - pData.exp

		for _, class in pairs( HOBBY_EQUIPMENT[HOBBY_ID] ) do
			-- если предмет есть среди разлоченных игроком, сравниваем уровень хобби с уровнем предмета и берем максимальный
			local iUnlockedItemId = pUnlocks[class.class]
			local iItemLevel = iUnlockedItemId and class.items[iUnlockedItemId].level or 1
			iItemLevel = math.max( pData.level, iItemLevel )

			for i, item in pairs(class.items) do
				if item.level and item.level > iItemLevel and class.class == HOBBY_ITEMS[iSection].class then
					local pItem = {
						icon = class.default_icon,
						name = class.default_name,
						id = i,
					}

					table.insert( pNextLevelUnlocks, pItem )

					break
				end
			end
		end
	end

	local sx = HOBBY_ID == HOBBY_DIGGING and 390 or sizeX-60

	if isElement( ui.l_your_progress ) then destroyElement( ui.l_your_progress ) end
	if isElement( ui.l_exp ) then destroyElement( ui.l_exp ) end
	if isElement( ui.progress_bar_bg ) then destroyElement( ui.progress_bar_bg ) end
	if isElement( ui.progress_bar_body ) then destroyElement( ui.progress_bar_body ) end
	if isElement( ui.progress_bar_next_unlock ) then destroyElement( ui.progress_bar_next_unlock ) end

	ui.l_your_progress = ibCreateLabel( 30, 80, 0, 40, "Ваш прогресс", ui.main, 0xAAFFFFFF, 1, 1, "left", "center" ):ibData( "font", ibFonts.regular_12 )
	ui.l_exp = ibCreateLabel( sx+30, 80, 0, 40, pData.exp, ui.main, 0xAAFFFFFF, 1, 1, "right", "center" ):ibData( "font", ibFonts.regular_12 )
	ui.progress_bar_bg = ibCreateImage( 30, 120, sx, 14, nil, ui.main, 0x40000000 )
	ui.progress_bar_body = ibCreateImage( 0, 0, sx*fProgress, 14, nil, ui.progress_bar_bg, 0xFF47afff )
	ui.progress_bar_next_unlock = ibCreateImage( sx*fUnlockProgress, -4, 1, 22, nil, ui.progress_bar_bg, 0xFFFFFFFF )

	if next( pNextLevelUnlocks ) then
		local fConstrainX = sx - dxGetTextWidth( "Необходимо - XXXXX опыта", 1, ibFonts.regular_9 )
		local px, py = sx*fUnlockProgress, 20
		px = px < fConstrainX and px or fConstrainX

		local sItemsStr = ""
		for k,v in pairs( pNextLevelUnlocks ) do
			ibCreateImage( px, py, 24, 24, v.icon, ui.progress_bar_bg, 0xFFFFFFFF )
			sItemsStr = sItemsStr..v.name.." - "..ROMAN_NUMBERS[v.id].." и "
			px = px + 35
		end
		sItemsStr = sItemsStr:sub( 1, -4 )

		local px = sx*fUnlockProgress < fConstrainX and sx*fUnlockProgress or fConstrainX
		ibCreateLabel( px-10, py+30, 0, 0, sItemsStr, ui.progress_bar_bg, 0xFFEEEEEE ):ibData( "font", ibFonts.bold_9 )
		ibCreateLabel( px-10, py+44, 0, 0, iExpLeftUntilUnlock > 0 and "Необходимо - "..iExpLeftUntilUnlock.." опыта" or "", ui.progress_bar_bg, 0xFFAAAAAA ):ibData( "font", ibFonts.regular_9 )
	end
end

function SwitchSection( iNewSection )
	HobbyEquipment_UpdateProgressBar( iNewSection )

	local px = ui["section"..iNewSection]:ibData("px") + 3
	local py = ui.selector_line:ibData( "py" )
	local sx = ui["section"..iNewSection]:ibData("sx")

	ui.selector_line:ibMoveTo( px, py, 200, "InOutQuad" )
	ui.selector_line:ibResizeTo( sx-6, 3, 200, "InOutQuad" )

	ui["section_name"..iSelection]:ibAlphaTo( 150, 200 )
	ui["section_name"..iNewSection]:ibAlphaTo( 255, 200 )

	for k,v in pairs(HOBBY_ITEMS[iSelection].items) do
		if isElement(ui["item"..k]) then
			destroyElement( ui["item"..k] )
		end
	end

	local py = 0
	local is_dark = true
	local item = HOBBY_ITEMS[iNewSection]
	local pEquipment = localPlayer:GetHobbyEquipment()

	ui.label_column1:ibData('text', item.column_names[1] or "")
	ui.label_column2:ibData('text', item.column_names[2] or "")
	ui.label_column3:ibData('text', item.column_names[3] or "")

	for k,v in pairs(item.items) do
		local bLocked = not localPlayer:IsHobbyEquipmentUnlocked( HOBBY_ID, item.class, k )
		local px = 30

		ui["item"..k] = ibCreateImage( 0, py, sizeX, 50, nil, ui.scrollpane, is_dark and 0xAA314050 or 0x00000000 )

		if bLocked then
			ui["item_lock"..k] = ibCreateImage( px, 17, 12, 16, "files/img/icon_lock.png", ui["item"..k] )
			px = px + 20
		end
		ui["item_icon"..k] = ibCreateImage( px, 12, 24, 23, item.default_icon, ui["item"..k], bLocked and 0xAAAAAAAA or 0xFFFFFFFF )
		
		ui["tooltip_zone"..k] = ibCreateImage( px, 0, 100, 50, item.default_icon, ui["item"..k], 0x00000000 )

		ui["tooltip_zone"..k]:ibOnHover( function( )
				if isElement(ui["tooltip"..k]) then
					ui["tooltip"..k]:ibAlphaTo( 255, 200 )
		        end
	       end, false )
	       :ibOnLeave( function( ) 
			   if isElement(ui["tooltip"..k]) then
				ui["tooltip"..k]:ibAlphaTo( 0, 200 )
		        end
	       end, false )

		px = px + 40
		
		ui["item_name"..k] = ibCreateLabel( px, 0, 0, 40, item.default_name.." - "..ROMAN_NUMBERS[k], ui["item"..k], bLocked and 0xAAAAAAAA or 0xFFFFFFFF, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_12 )
		
		if SECONDARY_TOOLS[HOBBY_ID] and item.class == SECONDARY_TOOLS[HOBBY_ID] and v.multiplier > 0 then
			ui["item_desk"..k] = ibCreateLabel( px, 25, 0, 25, "+"..v.multiplier .."% к шансу добычи", ui["item"..k], bLocked and 0xAA4ff35b or 0xFF4ff35b, 1, 1, "left", "center" ):ibData("font", ibFonts.regular_10)
		end

		px = 240

		if item.class == PRIMARY_TOOLS[HOBBY_ID] then
			ui["item_durability"..k] = ibCreateLabel( px, 0, 0, 50, v.durability, ui["item"..k], bLocked and 0xAAAAAAAA or 0xFFFFFFFF, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_12 )
		elseif item.class == "backpack" then
			ui["max_weight"..k] = ibCreateLabel( px, 0, 0, 50, v.size.." кг.", ui["item"..k], bLocked and 0xAAAAAAAA or 0xFFFFFFFF, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_12 )
		elseif SECONDARY_TOOLS[HOBBY_ID] and item.class == SECONDARY_TOOLS[HOBBY_ID] then
			ui["btn_minus"..k] = ibCreateButton( px, 10, 30, 30, ui["item"..k], nil, nil, nil, 0x16FFFFFF, 0x20FFFFFF, 0x18FFFFFF )
			ibCreateLabel( 0, 0, 30, 30, "-", ui["btn_minus"..k], 0xFFAAAAAA, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_14):ibData("disabled", true)

			addEventHandler( "ibOnElementMouseClick", ui["btn_minus"..k], function( key, state )
				if key ~= "left" or state ~= "down" or bLocked then return end

				local iCurrent = tonumber( ui["label_cnt"..k]:ibData( "text" ) )
				local value = math.max( iCurrent - 1, 1 )
				ui["label_cnt"..k]:ibData( "text", value )

				local cost = bLocked and format_price( v.unlock_cost ) or format_price( v.cost )
				ui["item_cost"..k]:ibData( "text", cost * value )
				ui["cost_icon"..k]:ibData( "px", px + ui[ "item_cost" .. k ]:width( ) + 10 )
			end, false )

			ui["btn_plus"..k] = ibCreateButton( px+64, 10, 30, 30, ui["item"..k], nil, nil, nil, 0x16FFFFFF, 0x20FFFFFF, 0x18FFFFFF )
			ibCreateLabel( 0, 0, 30, 30, "+", ui["btn_plus"..k], 0xFFAAAAAA, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_14):ibData("disabled", true)
			addEventHandler( "ibOnElementMouseClick", ui["btn_plus"..k], function( key, state )
				if key ~= "left" or state ~= "down" or bLocked then return end

				local iCurrent = tonumber( ui["label_cnt"..k]:ibData( "text" ) )
				local value = math.min( iCurrent + 1, v.max_capacity or 1 )
				ui["label_cnt"..k]:ibData( "text", value )

				local cost = bLocked and format_price( v.unlock_cost ) or format_price( v.cost )
				ui["item_cost"..k]:ibData( "text", cost * value )
				ui["cost_icon"..k]:ibData( "px", px + ui[ "item_cost" .. k ]:width( ) + 10 )
			end, false )

			local pFoundItem
			for i, equipment in pairs(pEquipment) do
				if equipment.class == item.class and equipment.id == k then
					pFoundItem = equipment
					break
				end
			end

			ui["item_icon"..k]:ibData("priority", 1)
			ui["tooltip"..k] = ibCreateImage( 0, 15, 140, 20, nil, ui["item_icon"..k], 0xAA000000 ):ibData("alpha", 0)
			ui["tooltip_body"..k] = ibCreateLabel( 0, 0, 140, 20, "В инвентаре: ".. (pFoundItem and pFoundItem.amount or 0), ui["tooltip"..k], 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_10)

			ui["label_cnt"..k] = ibCreateLabel( px+30, 0, 34, 50, "1", ui["item"..k], 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_14)
		end

		px = 375

		if item.class == PRIMARY_TOOLS[HOBBY_ID] then
			local pFoundItem
			for i, equipment in pairs(pEquipment) do
				if equipment.class == item.class and equipment.id == k then
					if equipment.equipped then
						ui["icon_equipped"..k] = ibCreateImage( sizeX-70, 17, 20, 16, "files/img/icon_check.png", ui["item"..k] )
					else
						ui["item_equip"..k] = ibCreateButton( sizeX-130, 9, 100, 32, ui["item"..k], "files/img/btn_select.png", "files/img/btn_select.png", "files/img/btn_select.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
						addEventHandler( "ibOnElementMouseClick", ui["item_equip"..k], function( key, state )
							if key ~= "left" or state ~= "down" then return end
							triggerServerEvent("OnPlayerEquipHobbyItem", root, item.class, k)
							ibClick()
						end, false )
					end

					if equipment.durability < v.durability then
						ui["item_icon"..k]:ibData("px", ui["item_icon"..k]:ibData("px")+25)
						ui["item_name"..k]:ibData("px", ui["item_name"..k]:ibData("px")+22)

						ui["btn_fix"..k] = ibCreateButton( 30, 16, 18, 18, ui["item"..k], "files/img/btn_fix.png", "files/img/btn_fix.png", "files/img/btn_fix.png", 0xFFAAAAAA, 0xFFFFFFFF, 0xFFFFFFFF )
						addEventHandler( "ibOnElementMouseClick", ui["btn_fix"..k], function( key, state )
							if key ~= "left" or state ~= "down" then return end
							local iPointsToRestore = v.durability - equipment.durability
							local iCost = math.floor( iPointsToRestore * (v.cost/v.durability) )

							ibConfirm(
						        {
						            title = "ПОЧИНКА ИНСТРУМЕНТА",
						            text = "Ты хочешь починить "..pHobbiesData[HOBBY_ID].tool_name.." за " .. format_price(iCost) .. "р. ?" ,
						            fn = function( self )
						                self:destroy()
						                triggerServerEvent( "OnPlayerTryFixHobbyEquipment", localPlayer, equipment.class, equipment.id )
									end,
									escape_close = true,
						        }
						    )
							ibClick()
						end, false )
					end

					pFoundItem = equipment
					break
				end
			end

			if not pFoundItem then
				if bLocked then
					ui["item_buy"..k] = ibCreateButton( sizeX-190, 9, 160, 32, ui["item"..k], "files/img/btn_unlock.png", "files/img/btn_unlock.png", "files/img/btn_unlock.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
					addEventHandler( "ibOnElementMouseClick", ui["item_buy"..k], function( key, state )
						if key ~= "left" or state ~= "down" then return end
						triggerServerEvent("OnPlayerTryUnlockHobbyEquipment", root, HOBBY_ID, item.class, k)
						ibClick()
					end, false )
				else
					ui["item_buy"..k] = ibCreateButton( sizeX-130, 9, 100, 32, ui["item"..k], "files/img/btn_buy.png", "files/img/btn_buy.png", "files/img/btn_buy.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
					addEventHandler( "ibOnElementMouseClick", ui["item_buy"..k], function( key, state )
						if key ~= "left" or state ~= "down" then return end
						triggerServerEvent("OnPlayerTryBuyHobbyEquipment", root, item.class, k, 1)
						ibClick()
					end, false )
				end
			end


			local iLevel = math.min( v.level, #HOBBY_LEVELS[HOBBY_ID] )
			local iExpLeft = HOBBY_LEVELS[HOBBY_ID][iLevel].total_exp-pData.total_exp
			ui["tooltip"..k] = ibCreateImage( 0, 15, 200, 20, nil, ui["item_icon"..k], 0x88000000 ):ibData("alpha", 0)
			ui["tooltip_body"..k] = ibCreateLabel( 0, 0, 200, 20, iExpLeft > 0 and "Необходимо ещё ".. format_price(iExpLeft-pData.total_exp) .." опыта" or "Разблокировано", ui["tooltip"..k], 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.regular_10)

			ui["item_cost"..k] = ibCreateLabel( px, 0, 0, 50, bLocked and format_price( v.unlock_cost ) or format_price( v.cost ), ui["item"..k], 0xFFFFFFFF, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_12 )
			ui["cost_icon"..k] = ibCreateImage( px + ui["item_cost"..k]:width() + 10, 12, 24, 24, bLocked and icon_hard or icon_soft, ui["item"..k] )
		elseif SECONDARY_TOOLS[HOBBY_ID] and item.class == SECONDARY_TOOLS[HOBBY_ID] then
			if bLocked then
				ui["item_buy"..k] = ibCreateButton( sizeX-190, 9, 160, 32, ui["item"..k], "files/img/btn_unlock.png", "files/img/btn_unlock.png", "files/img/btn_unlock.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				addEventHandler( "ibOnElementMouseClick", ui["item_buy"..k], function( key, state )
					if key ~= "left" or state ~= "down" then return end
					triggerServerEvent("OnPlayerTryUnlockHobbyEquipment", root, HOBBY_ID, item.class, k)
					ibClick()
				end, false )
			else
				ui["item_buy"..k] = ibCreateButton( sizeX-130, 9, 100, 32, ui["item"..k], "files/img/btn_buy.png", "files/img/btn_buy.png", "files/img/btn_buy.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				addEventHandler( "ibOnElementMouseClick", ui["item_buy"..k], function( key, state )
					if key ~= "left" or state ~= "down" then return end
					local iAmount = tonumber( ui["label_cnt"..k]:ibData( "text" ) )
					triggerServerEvent("OnPlayerTryBuyHobbyEquipment", root, item.class, k, iAmount)
					ibClick()
				end, false )
			end
			
			ui["item_cost"..k] = ibCreateLabel( px, 0, 0, 50, bLocked and format_price( v.unlock_cost ) or format_price( v.cost ), ui["item"..k], 0xFFFFFFFF, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_12 )
			ui["cost_icon"..k] = ibCreateImage( px + ui["item_cost"..k]:width() + 10, 12, 24, 24, bLocked and icon_hard or icon_soft, ui["item"..k] )
		elseif item.class == "backpack" then
			if bLocked then
				ui["label_level"..k] = ibCreateLabel( sizeX-30, 0, 0, 50, "Доступен с ".. v.player_level .." уровня", ui["item"..k], 0xFFFFFFFF, 1, 1, "right", "center" ):ibData("font", ibFonts.regular_10)
			else
				if not isElement( ui.checked_item ) then
					ui.checked_item = ibCreateImage( sizeX-50, 17, 20, 16, "files/img/icon_check.png", ui["item"..k] )
				end

				if not isElement( ui.backpack_bar ) then
					ui.backpack_bar = ibCreateImage( px, 20, 90, 10, nil, ui["item"..k], 0x32000000 )
					ui.backpack_bar_body = ibCreateImage( 0, 0, 90, 10, nil, ui.backpack_bar, 0xAA47afff )
				end

				local pItems = localPlayer:GetHobbyItems()

				local fUsedBackpackSpace = 0
				for k,v in pairs( pItems[HOBBY_ID] or {} ) do
					fUsedBackpackSpace = fUsedBackpackSpace + v.weight
				end

				ui.checked_item:setParent( ui["item"..k] )
				ui.backpack_bar:setParent( ui["item"..k] )
				ui.backpack_bar_body:ibData("sx", 90 * (fUsedBackpackSpace/v.size) )
			end
		elseif item.class == "digging:map" then
			px = 240

			ui["btn_minus"..k] = ibCreateButton( px, 10, 30, 30, ui["item"..k], nil, nil, nil, 0x16FFFFFF, 0x20FFFFFF, 0x18FFFFFF )
			ibCreateLabel( 0, 0, 30, 30, "-", ui["btn_minus"..k], 0xFFAAAAAA, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_14):ibData("disabled", true)

			addEventHandler( "ibOnElementMouseClick", ui["btn_minus"..k], function( key, state )
				if key ~= "left" or state ~= "down" or bLocked then return end

				local iCurrent = tonumber( ui["label_cnt"..k]:ibData( "text" ) )
				local value = math.max( iCurrent - 1, 1 )
				ui["label_cnt"..k]:ibData( "text", value )

				local cost = bLocked and format_price( v.unlock_cost ) or format_price( v.cost )
				ui["item_cost"..k]:ibData( "text", cost * value )
				ui["cost_icon"..k]:ibData( "px", px + ui[ "item_cost" .. k ]:width( ) + 10 )
			end, false )

			ui["btn_plus"..k] = ibCreateButton( px+64, 10, 30, 30, ui["item"..k], nil, nil, nil, 0x16FFFFFF, 0x20FFFFFF, 0x18FFFFFF )
			ibCreateLabel( 0, 0, 30, 30, "+", ui["btn_plus"..k], 0xFFAAAAAA, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_14):ibData("disabled", true)
			addEventHandler( "ibOnElementMouseClick", ui["btn_plus"..k], function( key, state )
				if key ~= "left" or state ~= "down" or bLocked then return end

				local iCurrent = tonumber( ui["label_cnt"..k]:ibData( "text" ) )
				local value = math.min( iCurrent + 1, v.max_capacity or 1 )
				ui["label_cnt"..k]:ibData( "text", value )

				local cost = bLocked and format_price( v.unlock_cost ) or format_price( v.cost )
				ui["item_cost"..k]:ibData( "text", cost * value )
				ui["cost_icon"..k]:ibData( "px", px + ui[ "item_cost" .. k ]:width( ) + 10 )
			end, false )

			ui["item_icon"..k]:ibData("priority", 1)
			ui["label_cnt"..k] = ibCreateLabel( px+30, 0, 34, 50, "1", ui["item"..k], 0xFFFFFFFF, 1, 1, "center", "center" ):ibData("font", ibFonts.bold_14)

			px = 375

			if bLocked then
				ui["item_buy"..k] = ibCreateButton( sizeX-190, 9, 160, 32, ui["item"..k], "files/img/btn_unlock.png", "files/img/btn_unlock.png", "files/img/btn_unlock.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				addEventHandler( "ibOnElementMouseClick", ui["item_buy"..k], function( key, state )
					if key ~= "left" or state ~= "down" then return end
					triggerServerEvent("OnPlayerTryUnlockHobbyEquipment", root, HOBBY_ID, item.class, k)
					ibClick()
				end, false )
			else
				ui["item_buy"..k] = ibCreateButton( sizeX-130, 9, 100, 32, ui["item"..k], "files/img/btn_buy.png", "files/img/btn_buy.png", "files/img/btn_buy.png", 0xDDFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF )
				addEventHandler( "ibOnElementMouseClick", ui["item_buy"..k], function( key, state )
					if key ~= "left" or state ~= "down" then return end
					local iAmount = tonumber( ui["label_cnt"..k]:ibData( "text" ) )
					triggerServerEvent("OnPlayerTryBuyHobbyEquipment", root, item.class, k, iAmount)
					ibClick()
				end, false )
			end

			ui["item_cost"..k] = ibCreateLabel( px, 0, 0, 50, bLocked and format_price( v.unlock_cost ) or format_price( v.cost ), ui["item"..k], 0xFFFFFFFF, 1, 1, "left", "center" ):ibData( "font", ibFonts.bold_12 )
			ui["cost_icon"..k] = ibCreateImage( px + ui["item_cost"..k]:width() + 10, 12, 24, 24, bLocked and icon_hard or icon_soft, ui["item"..k] )
		end

		py = py + 50
		is_dark = not is_dark
	end

	ui.scrollpane:AdaptHeightToContents()
	ui.scrollbar:UpdateScrollbarVisibility( ui.scrollpane )

	if iSelection ~= iNewSection then
		ui.scrollbar:ibData( "position", 0 )
	end

	iSelection = iNewSection
end

function OnEquipmentDataChanged( key, value )
	if key == "hobby_equipment" or key == "hobby_data" then
		if isElement(ui.main) then
			SwitchSection( iSelection )
		end
	elseif key == "money" or key == "donate" then
		if isElement(ui.label_cash) then
			local sCash = format_price( localPlayer:GetMoney() )
			local sDonate = format_price( localPlayer:GetDonate() )

			ui.label_donate:ibData("text", sDonate)
			ui.label_cash:ibData("text", sCash)
		end
	end
end
