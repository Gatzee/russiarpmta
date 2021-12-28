Extend("SPlayer")

local HOBBY_EQUIPMENT_UNPACKED = {}

for hobby, items in pairs(HOBBY_EQUIPMENT) do
	for i, item in pairs(items) do
		HOBBY_EQUIPMENT_UNPACKED[item.class] = item
	end
end

local function UpdateNrpInventory( player, pItem, bIsPrimaryTool, delta_count )
	if bIsPrimaryTool then return end

	local pItemData = HOBBY_EQUIPMENT_UNPACKED[pItem.class].items[pItem.id]
	local inv_item_id = HOBBY_ITEM_CLASS_to_INV_ITEM_ID[ pItem.class ]

	if bIsPrimaryTool then
		-- Удаляем все и выдаем только выбранного уровня (например, был выбран 1й ур, затем сменил на 2й)
		player:InventoryRemoveItem( inv_item_id )
		delta_count = pItem.amount
	end

	if delta_count > 0 then
		player:InventoryAddItem( inv_item_id, {
			id = pItem.id,
			durability = bIsPrimaryTool and pItem.durability or nil,
			multiplier = pItemData.multiplier,
		}, delta_count )

	elseif delta_count < 0 then
		player:InventoryRemoveItem( inv_item_id, {
			id = pItem.id,
			durability = bIsPrimaryTool and pItem.durability or nil,
			multiplier = pItemData.multiplier,
		}, math.abs( delta_count ) )
	end
end

addEvent( "onPlayerChangeInventory" )
addEventHandler( "onPlayerChangeInventory", root, function( inv_item_id, attributes, delta_count )
	local player = source
	local class = INV_ITEM_ID_to_HOBBY_ITEM_CLASS[ inv_item_id ]
	if not class then return end

	local pItemData = HOBBY_EQUIPMENT_UNPACKED[ class ].items[ attributes.id ]
	local default_durability = pItemData.durability
	local pEquipment = player:GetHobbyEquipment()
	local found = false
	for k, v in pairs( pEquipment ) do
		if v.class == class and v.id == attributes.id then
			v.amount = v.amount + delta_count
			if delta_count > 0 then
				-- Был взят предмет с измененным durability
				if default_durability and default_durability ~= attributes.durability then
					if v.durability ~= default_durability then
						-- У игрока уже был предмет с измененным durability
						-- Объединяем их
						v.amount = v.amount - 1
						v.durability = math.min( v.durability + attributes.durability, default_durability )
					else
						v.durability = attributes.durability
					end
					UpdateNrpInventory( player, v, true )
				end

			else
				if v.amount <= 0 then
					table.remove( pEquipment, k )
				else
					if default_durability then
						-- Предмет с измененным durability был перемещён в багажник,
						-- поэтому оставляем в инвентаре только с фулловым durability
						v.durability = default_durability
						UpdateNrpInventory( player, v, true )
					end
				end
			end

			SetPlayerHobbyEquipment( player, pEquipment )
			found = true
			break
		end
	end

	if not found and delta_count > 0 then
		local pItem =
		{
			class = class,
			id = attributes.id,
			amount = delta_count,
			durability = default_durability and attributes.durability or 0,
			equipped = default_durability and true,
		}
		for k, v in pairs( pEquipment ) do
			if v.class == class and v.equipped then
				pItem.equipped = false
				break
			end
		end
		
		table.insert( pEquipment, pItem )
		SetPlayerHobbyEquipment( player, pEquipment )
	end
end )

addEvent( "onInventoryConvertOldData" )
addEventHandler( "onInventoryConvertOldData", root, function()
	local player = source
	for k, v in pairs( player:GetHobbyEquipment() ) do
		local is_tool = PRIMARY_TOOLS_RESERSE[ v.class ]
		if not is_tool then
			local pItemData = HOBBY_EQUIPMENT_UNPACKED[ v.class ].items[ v.id ]
			player:InventoryAddItem( HOBBY_ITEM_CLASS_to_INV_ITEM_ID[ v.class ], {
				id = v.id,
				durability = is_tool and v.durability or nil,
				multiplier = pItemData.multiplier,
			}, v.amount )
		end
	end
end )

function OnPlayerTryBuyHobbyEquipment( sClass, iID, iAmount )
	local pPlayer = client

	local iAmount = iAmount or 1
	local pItemData = HOBBY_EQUIPMENT_UNPACKED[ sClass ].items[iID]
	local pEquipment = pPlayer:GetHobbyEquipment()

	local pFoundItem

	for k,v in pairs( pEquipment ) do
		if v.class == sClass and v.id == iID then
			pFoundItem = v
			break
		end
	end

	if pFoundItem then
		iAmount = math.min( (pItemData.max_capacity or 1) - pFoundItem.amount, iAmount )
	end

	if iAmount > 0 then
		if pPlayer:TakeMoney( pItemData.cost*iAmount, "hobby_equipment_purchase", sClass .. "_" .. pItemData.level ) then
			if HOBBY_EQUIPMENT_UNPACKED[ sClass ].on_bought then
				HOBBY_EQUIPMENT_UNPACKED[ sClass ].on_bought( pPlayer, iAmount )
			else
				local pItem =
				{
					class = sClass,
					id = iID,
					amount = iAmount,
					durability = pItemData.durability or 0,
					equipped = false,
				}
				GiveHobbyEquipment( pPlayer, pItem, iAmount )
			end

			pPlayer:ShowSuccess( HOBBY_EQUIPMENT_UNPACKED[ sClass ].custom_msg and HOBBY_EQUIPMENT_UNPACKED[ sClass ].custom_msg or ("Ты успешно приобрёл " .. HOBBY_EQUIPMENT_UNPACKED[ sClass ].default_name.. (iAmount > 1 and "(x"..iAmount..")" or "") ) )
			triggerClientEvent(client, "OnClientHobbyItemUnlocked", client)
			triggerEvent( "onPlayerHobbyPurchase", pPlayer, HOBBY_EQUIPMENT_UNPACKED[ sClass ].default_name, pItemData.cost*iAmount, iAmount )

			local is_primary_tool = PRIMARY_TOOLS_RESERSE[ sClass ]
			if is_primary_tool then
				triggerEvent( "OnPlayerEquipHobbyItem", pPlayer, sClass, iID )
			end
		else
			pPlayer:ShowError("Недостаточно денег!")
		end
	else
		pPlayer:ShowError("У тебя уже максимальное количество предметов этого типа")
	end
end
addEvent("OnPlayerTryBuyHobbyEquipment", true)
addEventHandler("OnPlayerTryBuyHobbyEquipment", root, OnPlayerTryBuyHobbyEquipment)

function OnPlayerTryUnlockHobbyEquipment( iHobby, sClass, iID )
	local pUnlocks = client:GetHobbyUnlocks( iHobby )
	local iLevel = pUnlocks[sClass] or 1
	local pItemData = HOBBY_EQUIPMENT_UNPACKED[ sClass ].items[iID]

	if not pItemData or not pItemData.unlock_cost then
		return false
	end

	if pItemData.level <= iLevel then
		client:ShowError("Данный предмет уже разблокирован")
		return false
	end

	if iID > 1 and not client:IsHobbyEquipmentUnlocked( iHobby, sClass, iID-1 ) then
		client:ShowError("Необходимо разблокировать предыдущий предмет")
		return false
	end

	if client:GetDonate() < pItemData.unlock_cost then
		client:ShowError("Недостаточно денег")
		return false
	end

	if client:TakeDonate(pItemData.unlock_cost, "hobby_item_unlock") then
		client:SetHobbyUnlock( iHobby, sClass, iID )

		client:ShowSuccess("Предмет успешно разблокирован!")
		triggerClientEvent(client, "OnClientHobbyItemUnlocked", client)
		triggerEvent( "onPlayerHobbyUnlock", client, HOBBY_EQUIPMENT_UNPACKED[ sClass ].default_name, iID, pItemData.unlock_cost )
	end
end
addEvent("OnPlayerTryUnlockHobbyEquipment", true)
addEventHandler("OnPlayerTryUnlockHobbyEquipment", root, OnPlayerTryUnlockHobbyEquipment)

function OnPlayerTryFixHobbyEquipment( sClass, iID )
	local pPlayer = client or source

	local pItemData = HOBBY_EQUIPMENT_UNPACKED[ sClass ].items[iID]
	local pEquipment = GetPlayerHobbyEquipment( client )

	local pFoundItem, iFoundItemID

	for k,v in pairs(pEquipment) do
		if v.class == sClass and v.id == iID then
			iFoundItemID = k
			pFoundItem = v
			break
		end
	end

	if pFoundItem then
		local iPointsToRestore = pItemData.durability - pFoundItem.durability
		local iCost = math.floor( iPointsToRestore * ( pItemData.cost/pItemData.durability ) )

		if client:TakeMoney( iCost, "hobby_equipment_repair" ) then
			pEquipment[iFoundItemID].durability = pItemData.durability
			SetPlayerHobbyEquipment( client, pEquipment )
			UpdateNrpInventory( pPlayer, pFoundItem, true )
			client:ShowSuccess( "Инструмент успешно отремонтирован" )
		else
			client:ShowError( "Недостаточно денег" )
		end
	end
end
addEvent("OnPlayerTryFixHobbyEquipment", true)
addEventHandler("OnPlayerTryFixHobbyEquipment", root, OnPlayerTryFixHobbyEquipment)

function OnPlayerEquipHobbyItem( sClass, iID )
	local pPlayer = client or source

	local pEquipment = pPlayer:GetHobbyEquipment()

	local pFoundItem, iFoundItemID

	for k,v in pairs(pEquipment) do
		if v.class == sClass and v.equipped then
			v.equipped = false
		end
	end

	for k,v in pairs(pEquipment) do
		if v.class == sClass and v.id == iID then
			iFoundItemID = k
			pFoundItem = v
			break
		end
	end

	if pFoundItem then
		pEquipment[iFoundItemID].equipped = not pEquipment[iFoundItemID].equipped
		SetPlayerHobbyEquipment( pPlayer, pEquipment )

		UpdateNrpInventory( pPlayer, pFoundItem, true )

		return true
	end
end
addEvent("OnPlayerEquipHobbyItem", true)
addEventHandler("OnPlayerEquipHobbyItem", root, OnPlayerEquipHobbyItem)

function OnPlayerHobbyToolUsed( pPlayer, iHobby )
	local pItem, iItemID = GetPlayerEquippedTool( pPlayer, iHobby )
	if pItem then
		local pEquipment = pPlayer:GetHobbyEquipment()
		pEquipment[iItemID].durability = pEquipment[iItemID].durability - 1
		if pEquipment[iItemID].durability <= 0 then
			TakeHobbyEquipment( pPlayer, pItem, pItem.amount )
			triggerEvent("OnPlayerHobbyToolBroken", pPlayer)

			if iHobby == HOBBY_DIGGING then
				triggerEvent("OnPlayerEndDigging", pPlayer, pPlayer)
			end
		else
			SetPlayerHobbyEquipment( pPlayer, pEquipment )
		end
		UpdateNrpInventory( pPlayer, pItem, true )
	end
end
addEvent("OnPlayerHobbyToolUsed", true)
addEventHandler("OnPlayerHobbyToolUsed", root, OnPlayerHobbyToolUsed)

function OnPlayerSellHobbyItems( iHobby )
	SellHobbyItems( client, iHobby )
end
addEvent("OnPlayerSellHobbyItems", true)
addEventHandler("OnPlayerSellHobbyItems", root, OnPlayerSellHobbyItems)

function GetPlayerEquippedTool( pPlayer, iHobby )
	local pEquipment = pPlayer:GetHobbyEquipment()

	local pFoundItem, iFoundItemID

	for k,v in pairs(pEquipment) do
		if v.class == PRIMARY_TOOLS[iHobby] and v.equipped then
			iFoundItemID = k
			pFoundItem = v
			break
		end
	end

	return pFoundItem, iFoundItemID
end

function SetPlayerHobbyEquipment( pPlayer, pEquipment )
	pPlayer:SetPermanentData( "hobby_equipment", pEquipment or {} )
	pPlayer:SetPrivateData( "hobby_equipment", pEquipment or {} )
	triggerEvent( "OnPlayerHobbyEquipmentUpdated", pPlayer, pEquipment )
end

function GiveHobbyEquipment( pPlayer, pItem, iAmount )
	local pEquipment = pPlayer:GetHobbyEquipment()

	local pFoundItem, iFoundItemID
	for k,v in pairs( pEquipment ) do
		if v.class == pItem.class and v.id == pItem.id then
			iFoundItemID = k
			pFoundItem = v
			break
		end
	end

	if pFoundItem then
		pEquipment[iFoundItemID].amount = pFoundItem.amount + iAmount
	else
		table.insert(pEquipment, pItem)
	end

	SetPlayerHobbyEquipment( pPlayer, pEquipment )
	UpdateNrpInventory( pPlayer, pFoundItem or pItem, PRIMARY_TOOLS_RESERSE[ pItem.class ], iAmount )
end

function TryEquipAnotherTool( pEquipment, class )
	for k, v in pairs( pEquipment ) do
		if v.class == class then
			v.equipped = true
			break
		end
	end
end

function TakeHobbyEquipment( pPlayer, pItem, iAmount )
	local pEquipment = pPlayer:GetHobbyEquipment()
	for k,v in pairs(pEquipment) do
		if v.class == pItem.class and v.id == pItem.id then
			-- local pItemData = HOBBY_EQUIPMENT_UNPACKED[ pItem.class ].items[ pItem.id ]
			-- v.durability = pItemData.durability
			v.amount = v.amount - iAmount
			if v.amount <= 0 then
				table.remove( pEquipment, k )
				-- if v.equipped then
				-- 	TryEquipAnotherTool( pEquipment, class )
				-- end
			end
			break
		end
	end

	SetPlayerHobbyEquipment( pPlayer, pEquipment )
end

function GetPlayerHobbyEquipment( pPlayer )
	return pPlayer:GetPermanentData( "hobby_equipment" ) or {}
end

function SetPlayerHobbyItems( pPlayer, pItems )
	pPlayer:SetPermanentData( "hobby_items", pItems or {} )
	pPlayer:SetPrivateData( "hobby_items", pItems or {} )
	triggerEvent( "OnPlayerHobbyItemsUpdated", pPlayer, pItems )
end

function GiveHobbyItem( pPlayer, iHobby, pItem, iEquipmentLevel )
	local pItems = pPlayer:GetHobbyItems()
	if not pItems[iHobby] then pItems[iHobby] = {} end
	local bFound = false

	if not pItem.is_unique then
		for k,v in pairs(pItems[iHobby]) do
			if iEquipmentLevel then
				if v.level and v.level == iEquipmentLevel then
					v.weight = v.weight + pItem.weight
					bFound = true
					break
				end
			else
				if not v.level then
					v.weight = v.weight + pItem.weight
					bFound = true
					break
				end
			end
		end
	end

	if not bFound then
		table.insert( pItems[iHobby], { weight = pItem.weight, level = iEquipmentLevel or 1, is_unique = pItem.is_unique } )
	end

	SetPlayerHobbyItems( pPlayer, pItems )

	triggerEvent( "HB:OnPlayerReceiveItem", pPlayer, iHobby )
end

function GetHobbyCostWeight( pPlayer, iHobby, pItems )
	local iTotalCost = 0
	local fTotalWeight = 0

	local iGameLevel = pPlayer:GetLevel()
	local fGameLevelMultiplier = 1
	for k, v in pairs( HOBBY_SELL_MULTIPLIERS ) do
		if iGameLevel >= k and v > fGameLevelMultiplier then
			fGameLevelMultiplier = v
		end
	end

	local fBackpackSize = pPlayer:GetHobbyBackpackSize()
	for k, v in pairs( pItems[ iHobby ] ) do
		if v.level then
			local iCost = v.weight * HOBBY_EQUIPMENT_UNPACKED[ PRIMARY_TOOLS[ iHobby ] ].items[ v.level ].cost_multiplier * fGameLevelMultiplier
			iTotalCost = iTotalCost + iCost
		else
			local iCost = v.weight * 170 * fGameLevelMultiplier
			iTotalCost = iTotalCost + iCost
		end

		if v.is_unique then
			iTotalCost = iHobby == HOBBY_DIGGING and 75000 or 50000
			fTotalWeight = fBackpackSize
			break
		end

		fTotalWeight = fTotalWeight + v.weight
	end

	return iTotalCost, fTotalWeight
end

function SellHobbyItems( pPlayer, iHobby )
	local pItems = pPlayer:GetHobbyItems()
	if not pItems[ iHobby ] then pItems[ iHobby ] = {} end

	local iTotalCost, fTotalWeight = GetHobbyCostWeight( pPlayer, iHobby, pItems )
	if fTotalWeight <= 0 then
		pPlayer:ShowError("Твой рюкзак пуст")
		return false
	end

	local timestamp = getRealTimestamp()
	local last_sell = pPlayer:getData( "last_sell" ) or { date = 0, hobby = nil }

	local diff_time = timestamp - last_sell.date
	if last_sell.hobby == iHobby and diff_time < 60 then
		WriteLog( "anti_pedor_hobby", "%s попытался продать добычу в хобби %s на сумму %s, за время между продажами %s сек", pPlayer, HOBBY_NAMES[ iHobby ], iTotalCost, diff_time )
		return false
	end

	pPlayer:setData( "last_sell", { date = timestamp, hobby = iHobby }, false )

	pItems[ iHobby ] = {}

	pPlayer:GiveMoney( iTotalCost, "hobby_item_sell", HOBBY_NAMES[ iHobby ] )
	SetPlayerHobbyItems( pPlayer, pItems )

	local sales_count = UpdateSalesCount( pPlayer, iHobby )

	triggerClientEvent( pPlayer, "HB:OnClientItemsSold", resourceRoot, true, { weight = fTotalWeight, cost = iTotalCost } )
	triggerEvent( "HB:OnPlayerSellItems", pPlayer, iHobby, fTotalWeight, sales_count )

	triggerEvent( "onHobbyEarnMoney", pPlayer, HOBBY_NAMES[ iHobby ], iHobby, iTotalCost )
	return iTotalCost
end

function UpdateSalesCount( pPlayer, iHobby )
	local pHobbiesData = pPlayer:GetHobbiesData()
	if not pHobbiesData[ iHobby ] then pHobbiesData[ iHobby ] = { } end

	pHobbiesData[ iHobby ].sales_count = ( pHobbiesData[ iHobby ].sales_count or 0 ) + 1

	pPlayer:SetPrivateData( "hobby_data", pHobbiesData )
	pPlayer:SetPermanentData( "hobby_data", pHobbiesData )
	return pHobbiesData[ iHobby ].sales_count
end

function OnPlayerTryObtainHobbyItem( iHobby, pData )
	local pPlayer = source

	local pItems = pPlayer:GetHobbyItems( iHobby )
	local pEquipment = pPlayer:GetHobbyEquipment( iHobby )
	local bStopActivity = false

	-- Check free space
	local fBackpackSize = pPlayer:GetHobbyBackpackSize()

	local fUsedBackpackSpace = 0
	for k,v in pairs( pItems[iHobby] or {} ) do
		fUsedBackpackSpace = fUsedBackpackSpace + v.weight
	end

	if fBackpackSize - fUsedBackpackSpace <= 0 then
		pPlayer:ShowError("У тебя закончилось место в рюкзаке!")
		bStopActivity = "fail"
	end

	-- Check tool state
	local pTool, iToolID = GetPlayerEquippedTool( pPlayer, iHobby )
	local pToolData = HOBBY_EQUIPMENT_UNPACKED[ PRIMARY_TOOLS[iHobby] ].items[ pTool and pTool.id or 1 ]

	if not pTool then
		if iHobby == HOBBY_FISHING then
			pPlayer:ShowError("У тебя нет удочки!")
		end
		bStopActivity = "fail"
	end

	if iHobby == HOBBY_FISHING then
		if pTool.durability <= 1 then
			pPlayer:ShowError("Твой инструмент сломался!")
			TakeHobbyEquipment( pPlayer, pTool, 1 )
			bStopActivity = "success"
		else
			pEquipment[iToolID].durability = pEquipment[iToolID].durability - 1
			SetPlayerHobbyEquipment( pPlayer, pEquipment )
		end
		UpdateNrpInventory( pPlayer, pTool, true )

		-- Check used bait
		local fAdditionalChance = 0
		local totalAmountBait = 0
		local pFoundBait
		for k,v in pairs(pEquipment) do
		if v.class == FISHING_BAIT and v.amount >= 1 then
				if pFoundBait then
					if pFoundBait.id < v.id then
						pFoundBait = v
					end
				else
					pFoundBait = v
				end

				totalAmountBait = totalAmountBait + v.amount
			end
		end

		if pFoundBait then
			fAdditionalChance = HOBBY_EQUIPMENT_UNPACKED[ FISHING_BAIT ].items[pFoundBait.id].multiplier / 100
			TakeHobbyEquipment( pPlayer, pFoundBait, 1 )
			UpdateNrpInventory( pPlayer, pFoundBait, false, -1 )
		end

		if not pFoundBait or totalAmountBait == 1 then
			pPlayer:ShowError("Закончилась наживка!")
			bStopActivity = "success"
		end

		if bStopActivity then
			triggerEvent("OnPlayerEndFishing", pPlayer, pPlayer)

			if bStopActivity == "fail" then
				return false
			end
		end

		-- Give item
		local pItem = GetRandomHobbyItem( pPlayer, iHobby, fAdditionalChance, pData )
		local fBackpackSpaceLeft = fBackpackSize - fUsedBackpackSpace

		pItem.weight = ( pItem.is_unique or pItem.weight > fBackpackSpaceLeft ) and fBackpackSpaceLeft or pItem.weight
		pItem.exp = pToolData.exp_amount

		pPlayer:GiveHobbyExp( iHobby, pItem.exp )
		GiveHobbyItem( pPlayer, iHobby, pItem, pTool.id )
		triggerClientEvent( pPlayer, "HB:OnClientItemReceived", resourceRoot, true, pItem )
		triggerEvent( "onPlayerSomeDo", pPlayer, "got_fish" ) -- achievements

		if pItem.icon == "fish_3" then
			pPlayer:SetPermanentData( "last_fish3_drop", getRealTime( ).timestamp )
		end

		pPlayer:CompleteDailyQuest( "start_fishing" )

	elseif iHobby == HOBBY_HUNTING then
		if bStopActivity then
			triggerEvent( "OnPlayerEndHunting", pPlayer, pPlayer )
		else
			triggerEvent( "OnPlayerRequestNextAnimal", pPlayer )
		end

		-- Give item
		local pItem = GetRandomHobbyItem( pPlayer, iHobby, fAdditionalChance, pData )
		local fBackpackSpaceLeft = fBackpackSize - fUsedBackpackSpace

		pItem.weight = ( pItem.is_unique or pItem.weight > fBackpackSpaceLeft ) and fBackpackSpaceLeft or pItem.weight
		pItem.exp = pToolData.exp_amount

		pPlayer:GiveHobbyExp( iHobby, pItem.exp )
		GiveHobbyItem( pPlayer, iHobby, pItem, pTool and pTool.id or 1 )
		triggerClientEvent( pPlayer, "HB:OnClientItemReceived", resourceRoot, true, pItem )
		triggerEvent( "onPlayerSomeDo", pPlayer, "got_animal" ) -- achievements

		if pItem.is_unique then
			pPlayer:SetPermanentData( "last_animal3_drop", getRealTime( ).timestamp )
		end
	elseif iHobby == HOBBY_DIGGING then
		-- Это было внутри блока if iHobby == HOBBY_FISHING then 
		-- мб уже и не нужно
		-- fAdditionalChance = pPlayer:GetPermanentData( "hobby_treasure3_chance" ) / 100

		-- Give item
		local pItem = GetRandomHobbyItem( pPlayer, iHobby, fAdditionalChance, pData )
		local fBackpackSpaceLeft = fBackpackSize - fUsedBackpackSpace

		pItem.weight = ( pItem.is_unique or pItem.weight > fBackpackSpaceLeft ) and fBackpackSpaceLeft or pItem.weight
		pItem.exp = pToolData.exp_amount

		pPlayer:GiveHobbyExp( iHobby, pItem.exp )
		GiveHobbyItem( pPlayer, iHobby, pItem, pTool and pTool.id or 1 )
		triggerClientEvent( pPlayer, "HB:OnClientItemReceived", resourceRoot, true, pItem )

		if pItem.is_unique then
			pPlayer:SetPermanentData( "hobby_treasure3_chance", 0 )
			pPlayer:SetPermanentData( "last_treasure3_drop", getRealTime( ).timestamp )
		else
			local iCurrentChance = pPlayer:GetPermanentData( "hobby_treasure3_chance" ) or 0
			if iCurrentChance < 50 then
				pPlayer:SetPermanentData( "hobby_treasure3_chance", iCurrentChance + 1 )
			end
		end

		pPlayer:CompleteDailyQuest( "find_treasure" )
	end
end
addEvent("OnPlayerTryObtainHobbyItem")
addEventHandler("OnPlayerTryObtainHobbyItem", root, OnPlayerTryObtainHobbyItem)

function GetRandomHobbyItem( player, iHobby, fAdditionalChance, pData )
	local fAdditionalChance = fAdditionalChance or 0

	local pItemsPool = HOBBY_ITEMS[iHobby]
	local pIgnoredItems = {}
	local pItem
	local iRange = 0

	for k,v in pairs(pItemsPool) do
		if v.f_available and not v.f_available( player ) then
			pIgnoredItems[k] = true
		end

		if iHobby == HOBBY_HUNTING then
			if v.animal_type ~= pData.animal_type then
				pIgnoredItems[k] = true
			end
		end
	end

	for k,v in pairs(pItemsPool) do
		if not pIgnoredItems[k] then
			if v.chance_increasable then
				iRange = iRange + v.chance * ( 1 + fAdditionalChance ) * 100
			else
				iRange = iRange + v.chance * 100
			end
		end
	end

	iRange = math.ceil(iRange)

	local iRandom = math.random(0, iRange)
	local iTop = 0

	for k,v in pairs(pItemsPool) do
		if not pIgnoredItems[k] then
			if v.chance_increasable then
				iTop = iTop + v.chance * ( 1 + fAdditionalChance ) * 100
			else
				iTop = iTop + v.chance * 100
			end
			if iRandom <= math.ceil( iTop ) then
				pItem = v
				break
			end
		end
	end

	local pOutput =
	{
		hobby = iHobby,
		name = pItem.name,
		is_unique = pItem.is_unique,
		weight = math.random( 50, 220 )/100,
		icon = pItem.icon,
	}

	if WEIGHTS_LIST[iHobby] then
		pOutput.weight = math.random( WEIGHTS_LIST[iHobby][1]*100, WEIGHTS_LIST[iHobby][2]*100 )/100
	end

	return pOutput
end

--[[function test( player, _, n, additional )
	local rolls = tonumber( n ) or 1000
	local additional = tonumber( additional ) or 0
	outputConsole( "Прогон " .. rolls .. " с увеличением шанса " .. additional )

	local items = { }
	for i = 1, rolls do
		local item = GetRandomHobbyItem( player, 1, additional )
		items[ item.name ] = ( items[ item.name ] or 0 ) + 1
	end
	local items_sorted = { }
	for i, v in pairs( items ) do
		table.insert( items_sorted, { i, v } )
	end
	table.sort( items_sorted, function( a, b ) return a[ 2 ] > b[ 2 ] end )
	for i, v in pairs( items_sorted ) do
		outputConsole( v[ 1 ] .. " => " .. v[ 2 ] )
	end
end
addCommandHandler( "tst", test )]]

function OnPlayerRequestHobbyStoreUI( iHobby )
	local iLevel = client:GetLevel()

	if iLevel < HOBBY_UNLOCKS[ iHobby ] then
		client:ShowError("Это хобби станет доступно с "..HOBBY_UNLOCKS[ iHobby ].." уровня")
		return
	end

	triggerClientEvent( client, "HobbyStore_ShowUI", resourceRoot, true, iHobby, { is_store = true, exp = client:GetHobbyExp( iHobby ), level = client:GetHobbyLevel( iHobby ), treasures_count = client:GetPermanentData("hobby_treasure3_chance") or 0 } )
end
addEvent("OnPlayerRequestHobbyStoreUI", true)
addEventHandler("OnPlayerRequestHobbyStoreUI", root, OnPlayerRequestHobbyStoreUI)

function OnPlayerReadyToPlay( pPlayer )
	local pPlayer = pPlayer or source
	pPlayer:SetPrivateData( "hobby_equipment", pPlayer:GetPermanentData("hobby_equipment") or {} )
	pPlayer:SetPrivateData( "hobby_items", pPlayer:GetPermanentData("hobby_items") or {} )
	pPlayer:SetPrivateData( "hobby_data", pPlayer:GetPermanentData("hobby_data") or {} )
end
addEventHandler("onPlayerReadyToPlay", root, OnPlayerReadyToPlay)

function OnPlayerHuntingRifleFire()
	local pPlayer = source

	local pEquipment = pPlayer:GetHobbyEquipment()
	local pTool, iToolID = GetPlayerEquippedTool( pPlayer, HOBBY_HUNTING )

	if not pTool then
		pPlayer:TakeAllWeapons()
		return
	end

	if pTool.durability <= 1 then
		pPlayer:ShowError("Твой инструмент сломался!")
		TakeHobbyEquipment( pPlayer, pTool, 1 )
		pPlayer:TakeAllWeapons()
	else
		pEquipment[iToolID].durability = pEquipment[iToolID].durability - 1
		SetPlayerHobbyEquipment( pPlayer, pEquipment )
	end
	UpdateNrpInventory( pPlayer, pTool, true )

	local pFoundAmmo
	for k,v in pairs(pEquipment) do
		if v.class == HUNTING_AMMO and v.amount >= 1 then
			if pFoundAmmo then
				if pFoundAmmo.id < v.id then
					pFoundAmmo = v
				end
			else
				pFoundAmmo = v
			end
		end
	end
	TakeHobbyEquipment( pPlayer, pFoundAmmo, 1 )
	UpdateNrpInventory( pPlayer, pFoundAmmo, false, -1 )
end
addEvent("OnPlayerHuntingRifleFire", true)
addEventHandler("OnPlayerHuntingRifleFire", root, OnPlayerHuntingRifleFire)