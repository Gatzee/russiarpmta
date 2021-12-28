local CONST_DB_FIELD_NAME = "tuning_cases_info"

function GetVinylCases( )
	--local file = fileOpen( "cases_info.json")
	--local db_result = fileRead( file, fileGetSize(file)) --MariaGet( CONST_DB_FIELD_NAME )
	--fileClose(file)

	local db_result = MariaGet( CONST_DB_FIELD_NAME )

	local cases_info = db_result and fromJSON( db_result ) or { }
	local cases = { }

	for i, v in pairs( cases_info.active_cases ) do
		if string.sub( v.id, 1, 5 ) == "vinyl" then
			table.insert( cases, v )
		end
	end

	return cases
end

function GetVinylCasesForPlayer( player )
	if not isElement( player.vehicle ) then return end

	local tier = player.vehicle:GetTier( )
	
    local cases_num_list = VINYL_CASE_TIERS[ tier ]
    if not cases_num_list then return end

	local cases_info = GetVinylCases( )

	-- Отсылаем меньше инфы
	for i, v in pairs( cases_info ) do
		if not cases_num_list[ i ] then
			cases_info[ i ] = nil
		end
	end

	return cases_info, tier
end

function PlayerRequestRegisteredVinylCases_handler(  )
	if not client then return end

	local cases_info, tier = GetVinylCasesForPlayer( client )
	if not cases_info then return end

	-- Если вдруг это говно опять сломано
	local item = client:GetPermanentData( "open_vinyl_case_item" )
	if item then
		item.params = FixTableData( item.params )
	end

	triggerClientEvent( client, "ReceiveRegisteredVinylCases", resourceRoot, cases_info, item, tier )

	-- АНАЛИТИКА / Показ окна с кейсами / Для просмотра конверсии в покупку
	triggerEvent( "onVinylCasesWindowShow", client )
end
addEvent( "PlayerRequestRegisteredVinylCases", true )
addEventHandler( "PlayerRequestRegisteredVinylCases", root, PlayerRequestRegisteredVinylCases_handler )


function PlayerWantBuyVinylCase_handler( case_id, count )
	local player = client or source
	if not player then return end

	if not isElement( player.vehicle ) then return end
	
	local case = GetVinylCases( )[ case_id ]

	local case_cost     = exports.nrp_tuning_shop:ApplyDiscount( case.cost, player )
	local total_cost    = case_cost * count
	local method        = "BuyVinylCase.".. case_id ..".".. count

	local success = false

	if case.cost_is_soft then
		if player:TakeMoney( total_cost, "vinyl_case_purchase", case_id .. "_" .. count ) then
			success = true
		else
			local stateOfOffer = player:EnoughMoneyOffer( "Vinyl cases purchase", total_cost, "PlayerWantBuyVinylCase", player, case_id, count )
			return
		end
	else
		if player:TakeDonate( total_cost, "vinyl_case_purchase", case_id .. "_" .. count ) then
			success = true
		end
	end

	if success then
		player:GiveVinylCase( case_id, count )

		WriteLog( "cases_vinyl", "[BUY] %s / CASE_ID[ %s ]:COUNT[ %s ]:COST[ %s / %s ]", player, case_id, count, case_cost, total_cost )

		-- АНАЛИТИКА / Покупка кейса / Идентификатором кейса !является `case_id`
		triggerEvent( "onVinylCasesPurchaseCase", player, case_cost, count, case.id, "vinyl" )
	end
end
addEvent( "PlayerWantBuyVinylCase", true )
addEventHandler( "PlayerWantBuyVinylCase", root, PlayerWantBuyVinylCase_handler )

function PlayerWantOpenVinylCase_handler( case_id )
	if not client then return end

	if not isElement( client.vehicle ) then return end

	local open_vinyl_case_item = client:GetPermanentData( "open_vinyl_case_item" )
	if open_vinyl_case_item then
		triggerClientEvent( client, "ShowTuningCasesReward", resourceRoot, open_vinyl_case_item, "vinyl" )
		return
	end

	local roll_number = client:GetPermanentData( "vinyl_cases_bought" ) or 0
	roll_number = roll_number + 1
	client:SetPermanentData( "vinyl_cases_bought", roll_number )
	
	local item = GetRandomVinylCaseItem( client, case_id, roll_number <= 1 or client:GetPermanentData( "vinyl_cases_rigged" ) )

	if item then
		client:TakeVinylCase( case_id, 1 )

		client:SetPermanentData( "open_vinyl_case_item", item )

		WriteLog( "cases_vinyl", "[OPEN] %s / CASE_ID[ %s ]:ITEM[ %s ]", client, case_id, inspect( item ) )

		-- АНАЛИТИКА / Открытие кейса / Идентификатором кейса !является `case_id`
		triggerEvent( "onVinylCasesOpenCase", client, item.params[ P_PRICE ], item.params[ P_CLASS ], tostring(item.params[ P_IMAGE ]) )

		triggerClientEvent( client, "ShowTuningCasesReward", resourceRoot, item, "vinyl" )
	end
end
addEvent( "PlayerWantOpenVinylCase", true )
addEventHandler( "PlayerWantOpenVinylCase", resourceRoot, PlayerWantOpenVinylCase_handler )

function PlayerWantTakeOpenedVinylCaseItem_handler(  )
	if not client then return end

	if not isElement( client.vehicle ) then return end

	local open_vinyl_case_item = client:GetPermanentData( "open_vinyl_case_item" )
	if open_vinyl_case_item then

		local vinyl = FixTableData( open_vinyl_case_item.params )

		client:SetPermanentData( "open_vinyl_case_item", nil )
		client:GiveVinyl( vinyl )

		triggerClientEvent( client, "onVinylsInventoryUpdate", resourceRoot, client:GetVinyls( client.vehicle:GetTier() ) )
        		
		WriteLog( "cases_vinyl", "[TAKE_ITEM] %s / ITEM[ %s ]", client, inspect( open_vinyl_case_item ) )
		
		-- АНАЛИТИКА / Получение награды из кейса / Предметы могут иметь одинаковый `id`, но разные переменные в `params`.
		-- Лучше отправлять `open_vinyl_case_item.cost` как показатель ценности выпавшего предмета. На текущий момент используется следующие поля в `params`:
		-- count, model, days
		triggerEvent( "onVinylCasesTakeItem", client, vinyl[ P_PRICE ], vinyl[ P_CLASS ], tostring( vinyl[ P_NAME ] ) )
	end
end
addEvent( "PlayerWantTakeOpenedVinylCaseItem", true )
addEventHandler( "PlayerWantTakeOpenedVinylCaseItem", resourceRoot, PlayerWantTakeOpenedVinylCaseItem_handler )

local CASE_ITEM_CHANCE_REDUCE_TIMEOUT = 5 * 60 -- на 5 мин понижаем шанс выпадения предмета, если он уже выпадал пользователю
local CASE_ITEM_CHANCE_REDUCE_RATIO = 1 / 4 -- в 4 раза

function GetRandomVinylCaseItem( client, case_id, is_rigged )
	local case = GetVinylCases( )[ case_id ]

	local items = case.items

	-- Понижаем в 4 раза шансы выпадения тех предметов, которые уже выпадали пользователю в последние 5 минут
	local current_timestamp = getRealTime( ).timestamp
	local vinyl_cases_items_got_timestamps = client:GetPermanentData( "vinyl_cases_items_got_ts" ) or { }
	if vinyl_cases_items_got_timestamps[ case_id ] then
		local case_items_got_timestamps = vinyl_cases_items_got_timestamps[ case_id ]
		for i, item in pairs( items ) do
			local name = item.params[ tostring( P_NAME ) ]
			local got_timestamp = case_items_got_timestamps[ name ] or 0
			if current_timestamp - got_timestamp <= CASE_ITEM_CHANCE_REDUCE_TIMEOUT then
				item.chance = item.chance * CASE_ITEM_CHANCE_REDUCE_RATIO
			end
		end
	else
		vinyl_cases_items_got_timestamps[ case_id ] = { }
	end

	-- Подкрутка кейса
	if is_rigged then
		local min_rare, max_rare = 3, 4
		if is_rigged == "full" then min_rare, max_rare = 3, 5 end
		local max_chance = 0
		for i, v in pairs( items ) do
			max_chance = math.max( max_chance, v.chance )
		end
		for i, v in pairs( items ) do
			if v.rare >= min_rare and v.rare <= max_rare then
				v.chance = math.max( v.chance, max_chance - v.chance ) * 2
			end
		end
	end

	local total_chance_sum = 0
	for _, item in pairs( items ) do
		total_chance_sum = total_chance_sum + item.chance
	end

	if total_chance_sum <= 0 then return end

	local dot = math.random( ) * total_chance_sum
	local current_sum = 0

	for i, item in pairs( items ) do
		if current_sum <= dot and dot < ( current_sum + item.chance ) then
			item.params = FixTableData( item.params )
			
			local name = item.params[ P_NAME ]
			vinyl_cases_items_got_timestamps[ case_id ][ name ] = current_timestamp
			client:SetPermanentData( "vinyl_cases_items_got_ts", vinyl_cases_items_got_timestamps )

			item.params[ P_CLASS ] = CASE_CLASSES[ case_id ]
			item.params[ P_IMAGE ] = name
			item.params[ P_PRICE ] = tonumber( item.cost )
			item.params[ P_PRICE_TYPE ] = case.cost_is_soft and "soft" or "hard"
			
			return item, i
		end

		current_sum = current_sum + item.chance
	end
end