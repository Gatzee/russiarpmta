CONST_DB_TABLE_NAME = "f4_cases"
CONST_SCHEDULE_DB_TABLE_NAME = "f4_cases_schedule"
CONST_GET_CASES_URL = SERVER_NUMBER > 100 and "https://pyapi.devhost.nextrp.ru/v1.0/get_cases/" or "https://pyapi.gamecluster.nextrp.ru/v1.0/get_cases/"

TIME_BEFORE_CASE_END = 2 * 24 * 60 * 60
ENDING_CASE_START_COUNT = 1200

CASES_GLOBAL_COUNT_ON_SERVER = { }
CASES_GLOBAL_COUNT_BY_SERVER = { }

CASES = { }

function GetCasesInfo( )
	return CASES
end

function onMariaDBUpdate_handler_cases( key, value )
    if key == CONST_DB_TABLE_NAME then
		for case_id, new_case_data in pairs( value ) do
			local case_data = CASES[ case_id ] or new_case_data
			if CASES[ case_id ] then
				case_data.name = new_case_data.name
				case_data.cost = new_case_data.cost
				case_data.position = new_case_data.position
			else
				CASES[ case_id ] = new_case_data
				-- Временный костыль, пока не убёрем эти столбцы из f4_cases
				new_case_data.temp_start = new_case_data.temp_start and 0
				new_case_data.temp_end   = new_case_data.temp_end   and 0
			end
			case_data.items = new_case_data.items and fromJSON( new_case_data.items )
		end

	elseif key == CONST_SCHEDULE_DB_TABLE_NAME then
		local current_timestamp = getRealTimestamp()
		local is_active = {}
		for i, new_case_data in pairs( value ) do
			local case_id = new_case_data.id
			local case_data = CASES[ case_id ]
			if case_data and not is_active[ case_id ] then
				local temp_start = new_case_data.temp_start and getTimestampFromDateTimeString( new_case_data.temp_start )
				local temp_end   = new_case_data.temp_end   and getTimestampFromDateTimeString( new_case_data.temp_end   )
				if temp_start and current_timestamp >= temp_start and ( not temp_end or current_timestamp < temp_end ) then
					for k, v in pairs( new_case_data ) do
						case_data[ k ] = v
					end
					case_data.temp_start = temp_start
					case_data.temp_end   = temp_end
					is_active[ case_id ] = true
				else
					case_data.temp_start = 0
					case_data.temp_end   = 0
				end
			end
		end
	end
end
onMariaDBUpdate_handler_cases( CONST_DB_TABLE_NAME, MariaGet( CONST_DB_TABLE_NAME ) or {} )
onMariaDBUpdate_handler_cases( CONST_SCHEDULE_DB_TABLE_NAME, MariaGet( CONST_SCHEDULE_DB_TABLE_NAME ) or {} )
addEvent( "onMariaDBUpdate" )
addEventHandler( "onMariaDBUpdate", root, onMariaDBUpdate_handler_cases )

addEvent( "onFakeTimestampChange" )
addEventHandler( "onFakeTimestampChange", root, function()
	onMariaDBUpdate_handler_cases( CONST_DB_TABLE_NAME, MariaGet( CONST_DB_TABLE_NAME ) )
	onMariaDBUpdate_handler_cases( CONST_SCHEDULE_DB_TABLE_NAME, MariaGet( CONST_SCHEDULE_DB_TABLE_NAME ) )
end )

----------------------------
-- START: СКИДКИ НА КЕЙСЫ

-- Список в порядке приоритета
-- DISCOUNT_DATA, FINISH_TIME

DISCOUNTS = {
	{
		id = "cases_premium_discount",
		text = "Спешите купить! Только для премиум игроков!",
		array = { },
		boundaries = { },
		condition = function( self, player, boundaries )
			if not player:IsPremiumActive( ) then return end

			local ts = getRealTimestamp( )
			local current_dates
			for i, v in pairs( self.boundaries ) do
				if v[ 1 ] <= ts and v[ 2 ] >= ts then
					current_dates = v
				end
			end

			if not current_dates then return end

			local current_cases = { }
			for case_id, v in pairs( self.array ) do
				local case = CASES[ case_id ]
				if case and case.temp_start <= ts and case.temp_end >= ts then
					v.name = case.name
					v.cost_original = case.cost
					current_cases[ case_id ] = v
				end
			end

			return current_cases, current_dates[ 2 ]
		end,
	},

	{
		id = "cases30_last_discount",
		text = "Скидка на все кейсы до 30%",
		array = {
			platinum = { discount = 30, cost = 699 },
			gold     = { discount = 30, cost = 349 },
			silver   = { discount = 30, cost = 139 },
			bronze   = { discount = 30, cost = 69 },
			crazy    = { discount = 20, cost = 799 },
			diamond  = { discount = 20, cost = 1199 },
			elite    = { discount = 30, cost = 1049 },
		},
		boundaries = {
			{
				getTimestampFromString( "20 февраля 2020 00:00" ),
				getTimestampFromString( "23 февраля 2020 23:59" ),
			},
		},
		condition = function( self, player, boundaries )
			local ts = getRealTime( ).timestamp
			

			local current_dates
			for i, v in pairs( boundaries ) do
				if v[ 1 ] <= ts and v[ 2 ] >= ts then
					current_dates = v
				end
			end

			if not current_dates then return end

			local start_time, finish_time = current_dates[ 1 ], current_dates[ 2 ]
			return ts >= start_time and ts <= finish_time, finish_time
		end,
	},

	{
		id = "cases30_weekly",
		text = "Скидка на кейсы до 30%",
		array = {
			[ "major"   ] = { discount = 30, cost = 699 },
			[ "bronze"  ] = { discount = 30, cost = 69  },
			[ "brigada" ] = { discount = 30, cost = 99  },

			[ "silver"  ] = { discount = 20, cost = 149 },
			[ "german"  ] = { discount = 20, cost = 559 },
			[ "4etkii"  ] = { discount = 20, cost = 399 },
		},
		boundaries = {
			{
				getTimestampFromString( "1 мая 2020 00:00" ),
				getTimestampFromString( "2 мая 2020 23:59" ),
			},
		},
		condition = function( self, player, boundaries )
			local ts = getRealTimestamp()
			local current_dates
			for i, v in pairs( boundaries ) do
				if v[ 1 ] <= ts and v[ 2 ] >= ts then
					current_dates = v
				end
			end

			if not current_dates then return end

			local start_time, finish_time = current_dates[ 1 ], current_dates[ 2 ]
			return ts >= start_time and ts <= finish_time, finish_time
		end,
	},

	{
		id = "cases50",
		text = "Скидка на следующую покупку 50%",
		condition = function( self, player )
			local cases50_finish = player:GetPermanentData( "cases50_finish" )
			if cases50_finish and getRealTime( ).timestamp < cases50_finish then
				local cases50_case = player:GetPermanentData( "cases50_case" )
				if cases50_case then
					local conversion = {
						platinum = {
							platinum = { discount = 50, cost = 500 },
							gold     = { discount = 50, cost = 250 },
							silver   = { discount = 50, cost = 100 },
							bronze   = { discount = 50, cost = 50 },
						},
						gold = {
							gold     = { discount = 50, cost = 250 },
							silver   = { discount = 50, cost = 100 },
							bronze   = { discount = 50, cost = 50 },
						},
						silver = {
							silver   = { discount = 50, cost = 100 },
							bronze   = { discount = 50, cost = 50 },
						},
						bronze = {
							bronze   = { discount = 50, cost = 50 },
						},
					}
					return conversion[ cases50_case ], cases50_finish
				end
			end
		end,
	},

	{
		id = "7cases_discount",
		condition = function( self, player, boundaries )
			if not boundaries then return end

			local ts = getRealTimestamp()
			local current_dates
			for i, v in pairs( boundaries ) do
				if v[ 1 ] <= ts and v[ 2 ] >= ts then
					current_dates = v
				end
			end

			if not current_dates then return end

			local current_cases = { }
			local list = { }
			local cases_list = exports.nrp_cases_7discount:GetDiscountCases( )
			for k, v in pairs( cases_list ) do
				current_cases[ v.case_id ] = v
				table.insert( list, v )
			end

			self.cases_data = current_cases

			return list, current_dates[ 2 ]
		end,
	},

	{
		id = "wholesome_case_discount",
		condition = function( self, player, boundaries )
			if not boundaries then return end

			local ts = getRealTimestamp()
			local current_dates
			for i, v in pairs( boundaries ) do
				if v[ 1 ] <= ts and v[ 2 ] >= ts then
					current_dates = v
				end
			end

			if not current_dates then return end

			local current_cases = { }
			local list = { }
			local cases_list = exports.nrp_cases_wholesome_discount:GetDiscountCases( )
			for k, v in pairs( cases_list ) do
				current_cases[ v.case_id ] = v
				table.insert( list, v )
			end

			self.cases_data = current_cases

			return list, current_dates[ 2 ]
		end,
	},
}

DISCOUNTS_BY_ID = { }
for i,v in pairs( DISCOUNTS ) do
	DISCOUNTS_BY_ID[ v.id ] = v
end

addEventHandler( "onSpecialDataUpdate", root, function( key, value )
	local discount = DISCOUNTS_BY_ID[ key ] 
	if not discount then return end
	
	--Если актуальные офферы закончились, то ставим дефолт значения
	if next( value ) == nil then 
		discount.boundaries = { { 0, 0 }, }
		discount.array = {}
	else
		discount.boundaries = { { getTimestampFromString( value[1].startTime ) , getTimestampFromString( value[1].endTime ) }, }
		discount.array = value[1].cases or { }

		local costs = FixTableKeys( value[1].costs )
		if costs then
			for i, case in pairs( CASES ) do
				local cost_discount = costs[ case.cost ]
				if ( case.position or 0 ) >= 1 and ( case.position or 0 ) <= 6 and not discount.array[ case.id ] then
					discount.array[ case.id ] = {
						cost = cost_discount.cost,
						discount = cost_discount.discount,
					}
				end
			end
		end
	end

	--Обновляем отображение акций
	Async:foreach( GetPlayersInGame( ), function( v )
		if isElement( v ) then
			SyncPlayerCasesDiscounts( v )
		end
	end )
end )

function GetPlayerCasesDiscounts( player )
	for i, v in pairs( DISCOUNTS ) do
		if v.condition then
			local result, finish_time = v:condition( player, v.boundaries )
			if result then
				-- Поддержка динамических кейсов
				if type( result ) == "table" then
					v = table.copy( v )
					v.array = result
				end
				return v, finish_time
			end
		end
	end
end

function SyncPlayerCasesDiscounts( player, is_join )
    local discounts, finish_time = GetPlayerCasesDiscounts( player )
    triggerClientEvent( player, "onCasesDiscountsSync", resourceRoot, discounts, finish_time, is_join )
end

function onCasesDiscountsRefreshRequest_handler( )
	SyncPlayerCasesDiscounts( source )
end
addEvent( "onCasesDiscountsRefreshRequest", true )
addEventHandler( "onCasesDiscountsRefreshRequest", root, onCasesDiscountsRefreshRequest_handler )

function onPlayerCompleteLogin_handler( player )
	local player = isElement( player ) and player or source
	if next( GetPlayerCasesDiscounts( player ) or { } ) then
		SyncPlayerCasesDiscounts( player, true )
	end
end
addEventHandler( "onPlayerCompleteLogin", root, onPlayerCompleteLogin_handler )

function onResourceStart_handler( )
	setTimer( function( )
		for i, v in pairs( GetPlayersInGame( ) ) do
			onPlayerCompleteLogin_handler( v )
		end
	end, 2000, 1 )

	UpdateGlobalCasesCount( )
	
	for i,v in pairs( DISCOUNTS ) do
		triggerEvent( "onSpecialDataRequest", resourceRoot, v.id )
	end
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )


-- END: СКИДКИ НА КЕЙСЫ
--------------------------

function ClearExpiredGlobalCasesCount( )
	setTimer( ClearExpiredGlobalCasesCount, MS24H, 1 )

	for case_id, case_data in pairs( CASES ) do
		if CASES_GLOBAL_COUNT_ON_SERVER[ case_id ] then
			-- Если кейс просрочен или был продлен после просрочки в nrp_cases_sale_ending
			if case_data.temp_end and case_data.temp_end < getRealTimestamp( ) or ( case_data.temp_start or 0 ) > getRealTimestamp( ) then
				CASES_GLOBAL_COUNT_ON_SERVER[ case_id ] = nil

				local server = ( SERVER_NUMBER > 100 or CASES_GLOBAL_COUNT_BY_SERVER[ case_id ] ) and SERVER_NUMBER or 0
				CommonDB:exec( "DELETE FROM global_cases_count WHERE ckey = ? AND server = ?", case_id, server )
			end
		end
	end
end
ExecAtTime( "04:00", ClearExpiredGlobalCasesCount )

function UpdateGlobalCasesCount_callback( query, multiple_results, on_start )
	CASES_GLOBAL_COUNT_BY_SERVER = { }

	local result = query:poll( -1, multiple_results )
	if multiple_results then
		result = result[ 2 ][ 1 ]
	end
	for _, data in pairs( result ) do
		if not CASES_GLOBAL_COUNT_BY_SERVER[ data.ckey ] and ( data.server == 0 or data.server == tonumber( get( "server.number" ) ) ) then
			CASES_GLOBAL_COUNT_ON_SERVER[ data.ckey ] = tonumber( data.cvalue )

			if data.server ~= 0 then
				CASES_GLOBAL_COUNT_BY_SERVER[ data.ckey ] = true
			end
		end
	end
end

function UpdateGlobalCasesCount( )
	CommonDB:queryAsync( UpdateGlobalCasesCount_callback, { }, "SELECT * FROM global_cases_count" )
end

Player.GetOpenCaseItem = function( self )
	local item = self:GetPermanentData( "open_case_item" )
	if item and item.params.exchange then
		local item_class = REGISTERED_ITEMS[ item.id ]
		if not item_class.isExchangeAvailable_func( self, item.params ) then
			item.params.exchange = nil
		elseif not item_class.checkHasItem_func( self, item.params ) then
			item.params.exchange.or_take = true
		end
	end
	return item
end

function PlayerWantBuyCase_handler( case_id, count )
	local player = client
	if not player then return end

	local case_data = CASES[ case_id ]
	local current_date = getRealTimestamp( )
	local discounts = GetPlayerCasesDiscounts( player )
	local is_7cases_discount = discounts and discounts.id == "7cases_discount"
	local is_wholesome_case_discount = count >= 3 and discounts and discounts.id == "wholesome_case_discount"
	local final_cost

	if not is_7cases_discount then
		if case_data.temp_start and case_data.temp_start > current_date then
			return
		end

		if case_data.temp_end and case_data.temp_end < current_date then
			return
		end
	end

	if CASES_GLOBAL_COUNT_ON_SERVER[ case_id ] and CASES_GLOBAL_COUNT_ON_SERVER[ case_id ] < count then
		triggerClientEvent( player, "onUpdateCasesCacheGlobalCount", resourceRoot, case_id, CASES_GLOBAL_COUNT_ON_SERVER[ case_id ] )
		UpdateGlobalCasesCount( )
		return
	end

	local case_discount = discounts and discounts.array[ case_id ]
	if is_7cases_discount then
		case_discount = discounts.cases_data[ case_id ]
	elseif is_wholesome_case_discount then
		case_discount, final_cost = exports.nrp_cases_wholesome_discount:GetCaseWholesomeCaseDiscountData( case_id, count )
	end

	local cost, coupon_discount_value  = player:GetCostWithCouponDiscount( "special_case", case_data.cost )

	local base_cost = case_discount and case_discount.cost or cost
	local payment_source_class = ( is_7cases_discount or is_wholesome_case_discount ) and "sale" or "f4_case_purchase"
	local payment_source_class_type = ( is_7cases_discount and "updated_case" ) or ( is_wholesome_case_discount and "wholesale_case" ) or ( case_id .. "_" .. count )

	local complete = false
	if case_data.cost_is_soft then
		if player:TakeMoney( final_cost and final_cost or ( base_cost * count ), payment_source_class, payment_source_class_type ) then
			complete = true
		end
	elseif player:TakeDonate( final_cost and final_cost or ( base_cost * count ), payment_source_class, payment_source_class_type ) then
		if base_cost == cost and coupon_discount_value then
			player:TakeSpecialCouponDiscount( coupon_discount_value, "special_case" ) 
            triggerEvent( "onPlayerRequestDonateMenu", player, "cases" )
		end
		complete = true
	end

	if complete then
		triggerEvent( "onPlayerSomeDo", player, "buy_case" ) -- achievements

		player:GiveCase( case_id, count )

		SendElasticGameEvent( player:GetClientID( ), "f4r_f4_cases_purchase" )

		local cost = base_cost

		WriteLog( "cases", "[BUY] %s / CASE_ID[ %s ]:COUNT[ %s ]:COST[ %s / %s ]", player, case_id, count, cost, cost * count )

		local discount_id = discounts and discounts.id

		local case_type = case_data.versus and "battle_case" or ( case_data.temp_start_count and "limited" ) or "common"
		triggerEvent( "onCasesPurchaseCase", player, case_id, case_type, count, cost, case_discount and true, discount_id, case_data.cost )
		if case_discount then SyncPlayerCasesDiscounts( player ) end

		if CASES_GLOBAL_COUNT_ON_SERVER[ case_id ] then
			CASES_GLOBAL_COUNT_ON_SERVER[ case_id ] = CASES_GLOBAL_COUNT_ON_SERVER[ case_id ] - count

			local server_id = ( SERVER_NUMBER > 100 or CASES_GLOBAL_COUNT_BY_SERVER[ case_id ] ) and SERVER_NUMBER or 0
			CommonDB:queryAsync( UpdateGlobalCasesCount_callback, { true }, [[
				UPDATE global_cases_count SET cvalue=(cvalue - ?) WHERE server=? AND ckey=?;
				SELECT * FROM global_cases_count;
			]], count, server_id, case_id )
		else
			local start_global_count = false
			if case_data.temp_start_count then
				start_global_count = case_data.temp_start_count
			elseif not case_data.versus and case_data.temp_end and case_data.temp_end - current_date < TIME_BEFORE_CASE_END then
				start_global_count = ENDING_CASE_START_COUNT
			end

			local server = SERVER_NUMBER > 100 and SERVER_NUMBER or 0
			if start_global_count then
				CASES_GLOBAL_COUNT_ON_SERVER[ case_id ] = start_global_count - count

				if case_data.versus then
					CommonDB:queryAsync( UpdateGlobalCasesCount_callback, { true }, [[
						INSERT INTO global_cases_count (ckey, cvalue, server) VALUES (?, ?, ?)
							ON DUPLICATE KEY UPDATE cvalue = CASE 
								WHEN IFNULL ((SELECT cvalue FROM (SELECT cvalue FROM global_cases_count WHERE ckey = ? AND server = ?) AS t), 2500) > 0
								THEN cvalue - ? ELSE cvalue END;
						SELECT * FROM global_cases_count;
					]], case_id, CASES_GLOBAL_COUNT_ON_SERVER[ case_id ], server, case_data.versus, server, count )
				else
					CommonDB:queryAsync( UpdateGlobalCasesCount_callback, { true }, [[
						INSERT INTO global_cases_count (ckey, cvalue, server) VALUES (?, ?, ?)
							ON DUPLICATE KEY UPDATE cvalue = cvalue - ?;
						SELECT * FROM global_cases_count;
					]], case_id, CASES_GLOBAL_COUNT_ON_SERVER[ case_id ], server, count )
				end
			end
		end

		if CASES_GLOBAL_COUNT_ON_SERVER[ case_id ] then
			triggerClientEvent( "onUpdateCasesCacheGlobalCount", resourceRoot, case_id, CASES_GLOBAL_COUNT_ON_SERVER[ case_id ] )
		end

		if is_7cases_discount then
			triggerEvent( "OnPlayerBoughtCaseOn7Cases", getResourceRootElement( getResourceFromName( "nrp_cases_7discount" ) ), player, case_id, count )
		elseif is_wholesome_case_discount then
			triggerEvent( "OnPlayerBoughtCaseOnWholesomeCase", getResourceRootElement( getResourceFromName( "nrp_cases_wholesome_discount" ) ), player, case_id, count )
		end
	end
end
addEvent( "PlayerWantBuyCase", true )
addEventHandler( "PlayerWantBuyCase", resourceRoot, PlayerWantBuyCase_handler )

function PlayerWantOpenCase_handler( case_id, ignore_rolling )
    if not client then return end
    
	local open_case_item = client:GetOpenCaseItem( )
	if open_case_item then
		triggerClientEvent( client, "ShowCasesReward", resourceRoot, open_case_item, true )
		return
	end

	local case = CASES[ case_id ]
	if not case then return end
	
	local inc_chances, from_rare = GetPlayerIncChances( client, case_id )
	local item, item_index = GetRandomCaseItem( case.items, inc_chances, from_rare )

	if item then
		if case.by_exp then
			local cases_types_by_exp = { CONST_FIRST_CASES_EXP, CONST_MAX_CASES_EXP }
			if not client:TakeCasesExp( cases_types_by_exp[ case.by_exp ] ) then return end
		else
			if not client:TakeCase( case_id, 1 ) then return end
		end

		local count_open_cases = client:GetPermanentData( "count_open_cases" ) or { }
		count_open_cases[ case_id ] = ( count_open_cases[ case_id ] or 0 ) + 1
		client:SetPermanentData( "count_open_cases", count_open_cases )

		item.case_cost = case.cost
		item.case_id = case_id

		client:SetPermanentData( "open_case_item", item )

		WriteLog( "cases", "[OPEN] %s / CASE_ID[ %s ]:ITEM[ %s ]:COST[ %s ]:PARAMS[ count=%s, model=%s, days=%s ]", client, case_id, item.id, item.cost or 0, item.params.count or "-", item.params.model or "-", item.params.days or "-" )

		-- АНАЛИТИКА / Открытие кейса / Идентификатором кейса !является `case_id`
		triggerEvent( "onCasesOpenCase", client, case_id, item.params )

		--triggerClientEvent( client, "ShowCasesReward", resourceRoot, item )
		triggerClientEvent( client, "ShowCasesRollingReward", resourceRoot, case_id, item_index, client:GetOpenCaseItem( ), ignore_rolling )

		-- отправляем в ленту открытых кейсов
		if item.rare and item.rare >= 5 then
			local description_data = REGISTERED_ITEMS[ item.id ].uiGetDescriptionData_func( item.id, item.params )
			local item_title = description_data and description_data.title or "эпохалку"
			exports.nrp_live_case_drops:AddDropToLiveCaseStack( case_id, item_title, client )
		end
	end
end
addEvent( "PlayerWantOpenCase", true )
addEventHandler( "PlayerWantOpenCase", resourceRoot, PlayerWantOpenCase_handler )

function PlayerWantTakeOpenedCaseItem_handler( reward_func_args )
	if not client then return end

	local open_case_item = client:GetPermanentData( "open_case_item" )
	if open_case_item then
		client:SetPermanentData( "open_case_item", nil )
		
		if not reward_func_args then
			reward_func_args = { }
		end
		reward_func_args.source = "f4_case"
		REGISTERED_ITEMS[ open_case_item.id ].rewardPlayer_func( client, open_case_item.params, reward_func_args )

		WriteLog( "cases", "[TAKE_ITEM] %s / ITEM[ %s ]:COST[ %s ]:PARAMS[ count=%s, model=%s, days=%s ]", client, open_case_item.id, open_case_item.cost or 0, open_case_item.params.count or "-", open_case_item.params.model or "-", open_case_item.params.days or "-" )
		
		-- АНАЛИТИКА / Получение награды из кейса / Предметы могут иметь одинаковый `id`, но разные переменные в `params`.
		-- Лучше отправлять `open_case_item.cost` как показатель ценности выпавшего предмета. На текущий момент используется следующие поля в `params`:
		-- count, model, days
		triggerEvent( "onCasesTakeItem", client, open_case_item.case_id or "ops", open_case_item )
	end
end
addEvent( "PlayerWantTakeOpenedCaseItem", true )
addEventHandler( "PlayerWantTakeOpenedCaseItem", resourceRoot, PlayerWantTakeOpenedCaseItem_handler )

function PlayerWantSellOpenedCaseItem_handler( exchange_to )
	if not client then return end

	local open_case_item = client:GetPermanentData( "open_case_item" )
	if open_case_item then
		client:SetPermanentData( "open_case_item", nil )

		if exchange_to == "soft" then
			client:GiveMoney( open_case_item.params.exchange.soft, "f4_case_item_sell" )
		else
			client:GiveExp( open_case_item.params.exchange.exp, "f4_case_item_sell" )
		end

		WriteLog( "cases", "[SELL_ITEM] %s / ITEM[ %s ]:COST[ %s ]:EXP[ %s ]:SOFT[ %s ]:PARAMS[ count=%s, model=%s, days=%s ]", 
			client, open_case_item.id, open_case_item.cost or 0, 
			open_case_item.params.exchange.exp or 0, open_case_item.params.exchange.soft or 0, 
			open_case_item.params.count or "-", open_case_item.params.model or "-", open_case_item.params.days or "-" 
		)
		
		-- АНАЛИТИКА / Получение награды из кейса / Предметы могут иметь одинаковый `id`, но разные переменные в `params`.
		-- Лучше отправлять `open_case_item.cost` как показатель ценности выпавшего предмета. На текущий момент используется следующие поля в `params`:
		-- count, model, days
		triggerEvent( "onCasesSellItem", client, open_case_item )
	end
end
addEvent( "PlayerWantSellOpenedCaseItem", true )
addEventHandler( "PlayerWantSellOpenedCaseItem", resourceRoot, PlayerWantSellOpenedCaseItem_handler )


function GetPlayerIncChances( player, case_id )
	local player_cases_inc_chances = player:GetPermanentData( "cases_inc_chances" )
	if player_cases_inc_chances and player_cases_inc_chances == "Yes" then return 2, 3 end

	local db_result = MariaGet( "cases_inc_chances" )
	local cases_inc_chances = db_result and fromJSON( db_result ) or { }
	local inc_chances_data = cases_inc_chances[ player:GetClientID( ) ]
	if inc_chances_data then return inc_chances_data.mul or 2, inc_chances_data.rare or 3 end

	if player:GetDonate() >= 100 and player:GetPermanentData( "count_open_cases" ) then
		local count_open_cases = player:GetPermanentData( "count_open_cases" )
		if count_open_cases[ case_id ] then
			local chances_by_count_open = {
				[10] = 1.2;
				[15] = 1.4;
				[25] = 1.6;
			}

			local player_chance = nil
			for count, chance in pairs( chances_by_count_open ) do
				if count_open_cases[ case_id ] >= count and ( not player_chance or player_chance < chance ) then
					player_chance = chance
				end
			end

			return player_chance, 3
		else
			return 1.5, 2
		end
	end
end

function GetRandomCaseItem( items, inc_chances, from_rare )
	from_rare = from_rare or 3

	local total_chance_sum = 0
	for _, item in pairs( items ) do
		total_chance_sum = total_chance_sum + item.chance * ( item.rare >= from_rare and inc_chances or 1 )
	end

	if total_chance_sum <= 0 then return end

	local dot = math.random( ) * total_chance_sum
	local current_sum = 0

	for i, item in pairs( items ) do
		local item_chance = item.chance * ( item.rare >= from_rare and inc_chances or 1 )

		if current_sum <= dot and dot < ( current_sum + item_chance ) then
			return item, i
		end

		current_sum = current_sum + item_chance
	end
end

--[[local tbl = {
	[ "de7e8b9c-477c-4469-8609-7b8b06a72dba" ] = { mul = 2, rare = 3 },
	[ "4766415d-8ab7-4e35-a54b-581d0ff1ad02" ] = { mul = 2, rare = 3 },
	[ "1934b1c9-8319-4c40-82a1-f00c1d3413af" ] = { mul = 2, rare = 3 },
	[ "897c5fb2-487e-433d-bd61-1bd25d63d70a" ] = { mul = 2, rare = 3 },
	[ "02156f29-ebb6-4e3c-b350-93f87c6e6c43" ] = { mul = 2, rare = 3 },
	[ "8a12f781-a9a0-4bf8-9590-a080e429853f" ] = { mul = 2, rare = 3 },
	[ "d5411cb6-3be6-43d5-8c93-07cd995798f6" ] = { mul = 2, rare = 3 },
	[ "145333e7-c1ff-407f-b614-2a8508bd42d9" ] = { mul = 2, rare = 3 },
	[ "496f25b3-1faf-4cc8-b4d1-a39f21475701" ] = { mul = 2, rare = 3 },
	[ "69b8cddd-6e6d-408f-8f35-2ec2b4e79fd4" ] = { mul = 2, rare = 3 },
	[ "f8c59f4d-d5f0-45e7-9214-83ae56f128d7" ] = { mul = 2, rare = 3 },
	[ "c1124beb-c4e8-400c-a6f6-821d57960ea3" ] = { mul = 2, rare = 3 },
	[ "ce86d6cd-929c-43f7-9789-8b40e2665601" ] = { mul = 2, rare = 3 },
	[ "b146778b-123c-490c-a93e-1a840d191d31" ] = { mul = 2, rare = 3 },
	[ "ce9e16c3-8e8d-4547-b4b3-54afde6c7b5f" ] = { mul = 2, rare = 3 },
	[ "0f8397dc-c399-4cee-8f0a-750257acc913" ] = { mul = 2, rare = 3 },
	[ "996bf9a5-806f-415f-b746-6c0e95b398be" ] = { mul = 2, rare = 3 },
	[ "a1b05a36-eabf-4c20-9ab9-c198da614dde" ] = { mul = 2, rare = 3 },
	[ "2e468c8a-055a-48d2-acce-0d703324ce83" ] = { mul = 2, rare = 3 },
	[ "ebd00124-edbc-4074-92f7-cb1c1ee09e6d" ] = { mul = 2, rare = 3 },
	[ "d767a609-0a27-4f05-bf18-4700ffaf12b5" ] = { mul = 2, rare = 3 },
	[ "fd1b0087-915f-4f29-98f4-b5e2890e22bb" ] = { mul = 2, rare = 3 },
	[ "dd4c53d3-03ec-4cdf-9233-2327f9575830" ] = { mul = 2, rare = 3 },
	[ "647e483c-a88f-4bbe-9ca5-bf54eeecc409" ] = { mul = 2, rare = 3 },
	[ "8a307b9d-f7f1-422b-aec9-d9962f21a375" ] = { mul = 2, rare = 3 },
	[ "7cad4bc2-f8af-43f6-82c2-ee7f61711c60" ] = { mul = 2, rare = 3 },
	[ "ee113bbd-b5fe-4d3b-ac49-c6b0a9355083" ] = { mul = 2, rare = 3 },
	[ "5409295a-787e-4e5a-81a2-4825c25cdd69" ] = { mul = 2, rare = 3 },
	[ "1477ac0c-f895-4d43-8fa3-7a6a184155f3" ] = { mul = 2, rare = 3 },
	[ "3b59c146-fcbd-4e77-bf16-2176150ef26a" ] = { mul = 2, rare = 3 },
	[ "63f91e69-34ef-4ecb-af43-e49fe7507a60" ] = { mul = 2, rare = 3 },
	[ "56245b07-77f0-4d87-ad7c-64e2228045c2" ] = { mul = 2, rare = 3 },
	[ "c2a36eaa-0296-42eb-8b01-5c29a89d62a3" ] = { mul = 2, rare = 3 },
	[ "a811dba4-f650-4f58-a2ae-8ef95f4a81fc" ] = { mul = 2, rare = 3 },
	[ "374b0557-27be-40ea-baf0-850d120dafe8" ] = { mul = 2, rare = 3 },
	[ "0f44bf8e-3e98-4ad1-b0a5-3db6ecf1a8b8" ] = { mul = 2, rare = 3 },
	[ "6c2a7cb7-64f2-47bb-9676-cd5f53fb27e6" ] = { mul = 2, rare = 3 },
	[ "815d2c55-1f8a-46c6-b946-a6d845c6b4fa" ] = { mul = 2, rare = 3 },
	[ "a4629202-bb81-4747-bcf6-df317f41edb1" ] = { mul = 2, rare = 3 },
	[ "57ddfc32-b0b4-47d7-b2a3-38a475224ccb" ] = { mul = 2, rare = 3 },
	[ "e18bccc1-2242-4099-af95-ff421d3d1c57" ] = { mul = 2, rare = 3 },
	[ "a1b05a36-eabf-4c20-9ab9-c198da614dde" ] = { mul = 2, rare = 3 },
	[ "c34ca1a9-1eb6-4363-8c71-8c3acdfaa17a" ] = { mul = 2, rare = 3 },
	[ "78c07658-79f9-40ac-8080-fdc5cc217374" ] = { mul = 2, rare = 3 },
	[ "ca540d51-720c-4274-aead-d71e115b9757" ] = { mul = 2, rare = 3 },
	[ "891fe87b-2708-47c6-80bd-65c65e5f4ded" ] = { mul = 2, rare = 3 },
	[ "9d16fcc1-ef0e-4e7e-9f7f-a18ab23a71f4" ] = { mul = 2, rare = 3 },
	[ "13ee34f1-b0cd-4cde-a9be-c4437b4f824d" ] = { mul = 2, rare = 3 },
	[ "9025ec25-59f7-4f7a-8098-d08e2a03073d" ] = { mul = 2, rare = 3 },
	[ "0399ba2e-e956-4474-ac88-256de3254b46" ] = { mul = 2, rare = 3 },
	[ "63c8530f-d679-40c3-9c4e-8a442aa3785a" ] = { mul = 2, rare = 3 },
	[ "eb33903f-2627-492e-8f39-3b748d43c0ac" ] = { mul = 2, rare = 3 },
	[ "4de3f915-b195-4d71-8ade-b026eb190c48" ] = { mul = 2, rare = 3 },
	[ "68e23b8b-6b96-46e7-af42-2364a146c3a0" ] = { mul = 2, rare = 3 },
	[ "afaf8b66-5176-46bc-803f-1d408d6ddf94" ] = { mul = 2, rare = 3 },
	[ "bb1559ea-b664-4765-a16a-c65fa9a24f8e" ] = { mul = 2, rare = 3 },
}
local f = fileCreate( "f.json" )
fileWrite( f, toJSON( tbl, true ) )
fileClose( f )]]



----------------------------------------------------------------------------------------
-- Для теста

if SERVER_NUMBER > 100 then
	addEvent( "onFakeTimestampChange" )
	addEventHandler( "onFakeTimestampChange", root, ClearExpiredGlobalCasesCount )

	addCommandHandler( "set_case_count", function( source, cmd, case_id, count )
		local cases_info = GetCasesInfo() or {}
		
		if not cases_info[ case_id ] then
			outputConsole( "Введите case_id, список доступных:", source )
			for case_id, _ in pairs( cases_info ) do
				outputConsole( case_info.name .. " - " .. case_id )
			end
			return
		end

		count = tonumber( count )
		if not count then
			source:outputChat( "Введите колво" )
			return
		end

		CommonDB:exec( [[
			INSERT INTO global_cases_count (ckey, cvalue, server) VALUES (?, ?, ?)
			ON DUPLICATE KEY UPDATE cvalue = ?
		]], case_id, count, SERVER_NUMBER, count )
		CASES_GLOBAL_COUNT_ON_SERVER[ case_id ] = count
		triggerClientEvent( "onUpdateCasesCacheGlobalCount", resourceRoot, case_id, count )

		source:outputChat( "Вы успешно изменили колво" )
	end )

	addCommandHandler( "give_case_item", function( source, cmd, case_id, item_index )
		local cases_info = GetCasesInfo() or {}
		
		if not cases_info[ case_id ] then
			outputConsole( "Введите case_id, список доступных:", source )
			for case_id, case_info in pairs( cases_info ) do
				outputConsole( case_info.name .. " - " .. case_id )
			end
			return
		end

		item_index = tonumber( item_index )
		if not item_index or not cases_info[ case_id ].items[ item_index ] then
			source:outputChat( "Введите номер предмета от 1 до " .. #cases_info[ case_id ].items )
			return
		end

		local item = cases_info[ case_id ].items[ item_index ]

		item.case_cost = cases_info[ case_id ].cost
		item.case_id = case_id

		source:SetPermanentData( "open_case_item", item )
		triggerClientEvent( source, "ShowCasesReward", resourceRoot, source:GetOpenCaseItem( ) )
	end )

	addCommandHandler( "check_case_drops_count", function( source, cmd, case_id )
		local cases_info = GetCasesInfo() or {}
		
		if not cases_info[ case_id ] then
			outputConsole( "Введите case_id, список доступных:", source )
			for case_id, _ in pairs( cases_info ) do
				outputConsole( case_info.name .. " - " .. case_id )
			end
			return
		end

		local items = cases_info[ case_id ].items
		local item_drop_counts = { }
		for i = 1, 100000 do
			local item, item_index = GetRandomCaseItem( items )
			item_drop_counts[ item_index ] = ( item_drop_counts[ item_index ] or 0 ) + 1
		end

		for i = 1, #items do
			outputConsole( i .. " - " .. ( item_drop_counts[ i ] or 0 ) )
		end
	end )
end
