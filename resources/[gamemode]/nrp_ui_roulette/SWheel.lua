loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )
Extend( "rewards/Server" )

local REWARDS_CACHE = { }

function math.rand_chance( value )
	return math.random( ) <= value
end

function GetRandomReward( player, reward_chances, is_inventory )
	local random
	local ACTUAL_CHANCES = table.copy( reward_chances )

	repeat
		for k, v in pairs( ACTUAL_CHANCES ) do
			local rand = math.rand_chance( ( is_inventory and v.chances or v [ 2 ] ) / 100 )
			if rand then
				random = is_inventory and k or v[ 1 ]
				break
			end
		end
	until
		random

	return random
end

-- получить section и index рандомной награды
function GetReward( player, roulette, boost_type )
	local section, index
	local boost = boost_type == TYPE_BOOST_DEFAULT and boost_type or TYPE_BOOST
	section = GetRandomReward( player, REWARD_CHANCES[ roulette ][ boost ] )

	-- для товаров инвенторя свои рандомные шансы + boost
	if section == SECTION_INVENTORY then
		index = GetRandomReward( player, INVENTORY_CONFIG[ roulette ][ boost_type ], true )
	elseif section == SECTION_JACKPOT then
		index = REWARDS_CACHE[ player ].rewards[ roulette ][ SECTION_JACKPOT ].jackpot_index
	else
		index = index == 1 and index or math.random( 1, REWARD_CHANCES[ roulette ][ boost ][ section ][ 3 ] )
	end

	return section, index
end

function CheckNotGiveReward( player, wof_data )
	for k, v in pairs( wof_data ) do
		if next( v.last_wheel_reward ) and not v.last_wheel_reward.passed then
			GiveWheelReward_handler( player, k )
			break
		elseif next( v.last_season_reward ) and not v.last_season_reward.passed then
			GiveSeasonReward_handler( player, k )
			break
		end
	end
end

-- открыть колесо
function InitRouletteWindow( )
	local wof_data = GetData( client )
	local next_coin_time = client:GetPermanentData( "next_coin" ) or FREE_COIN_PERIOD
	local level = client:GetLevel( )
	local season = GetSeason( )
	local date_now = convertUnixToDate( getRealTimestamp( ) )
	local update_data = false

	REWARDS_CACHE[ client ] = {
		level = level,
		season = season,
		rewards = GenerateRewardByLevel( level ),
	}

	for k, v in pairs( wof_data ) do
		local last_game_date = v.last_game_date ~= 0 and convertUnixToDate( v.last_game_date ) or 0
		
		-- если день не совпадает с последней игрой, обнуляем
		if last_game_date ~= 0 and ( date_now.day ~= last_game_date.day or date_now.month ~= last_game_date.month or date_now.year ~= last_game_date.year ) then
			v.last_game_date = 0
			v.game_count_day = 0
			update_data = true
		end
		
		-- если не совпадает сезон с текущим, обнуляем
		if v.current_season ~= season and v.current_season ~= 0 then
			v.current_season = season
			v.season_points = 0
			v.season_passed = 0
			update_data = true
		end
	end

	if update_data then
		client:SetPermanentData( "wof_data", wof_data )
	end

	triggerClientEvent( client, "InitWheel", client, true, wof_data, REWARDS_CACHE[ client ], next_coin_time )

	CheckNotGiveReward( client, wof_data )
end
addEvent( "InitRouletteWindow", true )
addEventHandler( "InitRouletteWindow", root, InitRouletteWindow )

-- крутить колесо
function SpinWheel_handler( roulette, animation )
	if client:TakeCoins( 1, roulette, "SPIN", "NRPDszx5x" ) then
		local wof_data = GetData( client )
		local rewards_cache = REWARDS_CACHE[ client ].rewards[ roulette ]

		-- если есть не использованный boost
		local boost_type = wof_data[ roulette ].last_wheel_reward.boost_type and wof_data[ roulette ].last_wheel_reward.boost_type or TYPE_BOOST_DEFAULT

		-- ТЕСТИРОВАНИЕ
		local wheel_boost_type = client:getData( "wheel_boost_type" )
		boost_type = wheel_boost_type and wheel_boost_type or boost_type

		local boost_count = wof_data[ roulette ].last_wheel_reward.boost_count and wof_data[ roulette ].last_wheel_reward.boost_count or 1

		-- определение награды
		local section, index = GetReward( client, roulette, boost_type )

		-- ТЕСТИРОВАНИЕ
		local wheel_section = client:getData( "wheel_section" )
		local wheel_index = client:getData( "wheel_index" )

		client:setData( "wheel_section", false, false )
		client:setData( "wheel_index", false, false )
		client:setData( "wheel_boost_type", false, false )

		section = wheel_section and wheel_section or section
		index = wheel_index and wheel_index or index

		-- подкрутить награду, если первая покупка жетона
		if client:GetPermanentData( "first_coins_purchase" ) and not client:GetPermanentData( "first_coins_reward" ) then
			client:SetPermanentData( "first_coins_reward", true )

			section = SECTION_MEDIUM
			index = math.random( 1, #WHEEL_REWARD_PERCENTS[ roulette ][ SECTION_MEDIUM ] )
		end

		-- сохранить награду перед получением, на случай выхода, вылета
		SaveRewardData( client, { roulette }, section, index, wof_data, boost_count, boost_type )

		-- запуск анимации прокрутки колеса
		triggerClientEvent( client, "SpinTheWheel", resourceRoot, section, index )

		if roulette == "default" then
			triggerEvent( "onPlayerSomeDo", client, "spin_wheel" ) -- achievements
		elseif roulette == "gold" then
			triggerEvent( "onPlayerSomeDo", client, "spin_wheel_gold" ) -- achievements
		end

		client:CompleteDailyQuest( "wof_use" )
	else
		client:ShowError( "Недостаточно жетонов!" )
	end
end
addEvent( "SpinWheel", true )
addEventHandler( "SpinWheel", root, SpinWheel_handler )

-- очки прогресса за день
function GetProgressPoints( roulette, game_count_day )
	for k, v in ipairs( PROGRESS_POINTS[ roulette ] ) do
		if game_count_day == v.games then
			return v.points
		end
	end
end

-- сезонная награда
function GetSeasonReward( roulette, times_tamp, season, wof_data, progress_points )
	local rewards = PROGRESS_REWARDS[ season ].rewards[ roulette ]
	local season_points = wof_data.season_points
	local last_season_reward_index = wof_data.last_season_reward.index and wof_data.last_season_reward.index or 0
	local last_season_reward_season = wof_data.last_season_reward.season and wof_data.last_season_reward.season or 0
	local rewards_len = #rewards
	local points_max = PROGRESS_REWARDS_POINTS[ rewards_len ]
	local season_points_over = progress_points == 2 and season_points - 1 or season_points

	if season_points >= points_max then
		return rewards_len, true, season_points - points_max
	end

	for i = rewards_len, 1, -1 do
		local need_points = PROGRESS_REWARDS_POINTS[ i ]
		if ( season_points == need_points or season_points_over == need_points ) and ( i ~= last_season_reward_index or season ~= last_season_reward_season ) then
			return i, false, season_points
		end
	end
end

-- получить текущий сезон
function GetSeason( )
	local times_tamp = getRealTimestamp( )

	for k, v in ipairs( PROGRESS_REWARDS ) do
		if times_tamp <= v.finish_date and times_tamp >= v.start_date then
			return k
		end
	end
end

-- получить весь прогресс
function GetData( player )
	if not player or not isElement( player ) then return end

	local wof_data = player:GetPermanentData( "wof_data" )
	if not wof_data then
		wof_data = {
			[ "default" ] = {
				game_count_day = 0,
				last_game_date = 0,
				current_season = 0,
				season_points = 0,
				season_passed = 0,
				last_wheel_reward = { },
				last_season_reward = { }
			},
			[ "gold" ] = {
				game_count_day = 0,
				last_game_date = 0,
				current_season = 0,
				season_points = 0,
				season_passed = 0,
				last_wheel_reward = { },
				last_season_reward = { }
			}
		}
	end

	return wof_data
end

-- сохранить награду перед получением, на случай выхода, вылета
function SaveRewardData( player, roulettes, section, index, wof_data, boost_count, boost_type )
	if not player or not isElement( player ) then return end

	local times_tamp = getRealTimestamp( )
	local date_now = convertUnixToDate( times_tamp )

	for k, roulette in pairs( roulettes ) do
		-- сохраняем награду из колеса c учетом boost
		if section == SECTION_BOOST_PLUS_50 or section == SECTION_BOOST_X2 then
			boost_count = WHEEL_REWARD_PERCENTS[ roulette ][ section ][ 1 ].count
			boost_type = WHEEL_REWARD_PERCENTS[ roulette ][ section ][ 1 ].type
		end

		wof_data[ roulette ].current_season = REWARDS_CACHE[ player ].season

		wof_data[ roulette ].last_wheel_reward = {
			section = section,
			index = index,
			level = REWARDS_CACHE[ player ].level,
			passed = false,
			boost_count = boost_count,
			boost_type = boost_type,
		}

		local last_game_date = wof_data[ roulette ].last_game_date ~= 0 and convertUnixToDate( wof_data[ roulette ].last_game_date ) or 0
		-- если день не совпадает с последней игрой, обнуляем
		if last_game_date ~= 0 and date_now.day ~= last_game_date.day and date_now.month ~= last_game_date.month and date_now.year ~= last_game_date.year then
			wof_data[ roulette ].last_game_date = 0
			wof_data[ roulette ].game_count_day = 0
		end

		wof_data[ roulette ].game_count_day = wof_data[ roulette ].game_count_day + 1
		wof_data[ roulette ].last_game_date = times_tamp
	
		-- получить очки прогресса, если достаточно количество игр
		local progress_points = GetProgressPoints( roulette, wof_data[ roulette ].game_count_day )
		if not progress_points then 
			player:SetPermanentData( "wof_data", wof_data )
			return 
		end

		wof_data[ roulette ].season_points = wof_data[ roulette ].season_points + progress_points

		-- analytics
		SendElasticGameEvent( player:GetClientID( ), "wof_progression", { 
			type = ROULETTE_CONFIG[ roulette ].analytics,
			points_num = wof_data[ roulette ].season_points,
			points_receive = progress_points,
		} )
		
		-- получить сезонную награду, если достаточно очков
		local reward_index, season_passed, season_points = GetSeasonReward( roulette, times_tamp, REWARDS_CACHE[ player ].season, wof_data[ roulette ], progress_points )
		if not reward_index then 
			player:SetPermanentData( "wof_data", wof_data )
			return 
		end

		-- сохраняем сезонную награду
		-- если последняя награда непройденного сезона, то выдавать награду, а не софт
		local is_soft_replace = wof_data[ roulette ].season_passed == REWARDS_CACHE[ player ].season

		wof_data[ roulette ].season_points = season_points
		wof_data[ roulette ].season_passed = ( not season_passed and wof_data[ roulette ].season_passed ~= REWARDS_CACHE[ player ].season ) and 0 or REWARDS_CACHE[ player ].season
		wof_data[ roulette ].last_season_reward = {
			season = REWARDS_CACHE[ player ].season,
			index = reward_index,
			passed = false,
			is_soft_replace = is_soft_replace,
		}

	end

	player:SetPermanentData( "wof_data", wof_data )
end

-- генерация наград относительно уровня игрока
function GenerateRewardByLevel( level )
	level = level <= 2 and 1 or level - 1

	local wheel_rewards = { }

	for roulette, sections in pairs( WHEEL_REWARD_PERCENTS ) do
		local rwds = WHEEL_REWARD_LEVELS[ roulette ]
		local data = rwds[ level ] and rwds[ level ] or rwds[ #rwds ]

		wheel_rewards[ roulette ] = { }

		for section, rewards in ipairs( sections ) do
			wheel_rewards[ roulette ][ section ] = { }
	
			-- ячейка jackpot одна, ставим рандомный индекс награды
			if section == SECTION_JACKPOT then
				local jackpot_index = math.random( 1, #sections[ section ] )
				wheel_rewards[ roulette ][ section ].jackpot_index = jackpot_index
			end

			for k, reward in ipairs( rewards ) do
				table.insert( wheel_rewards[ roulette ][ section ], {
					type = reward.type,
					count = ( reward.percent and data[ reward.type ] ) and ( data[ reward.type ] * reward.percent ) / 100 or reward.count,
					name_reward = reward.name_reward or nil,
				} )
			end
		end
	end

	return wheel_rewards
end

-- покупка жетонов
function BuyCoins_handler( count, roulette )
	if not isElement( client ) or not client:IsInGame( ) then return end

	count = tonumber( count )
	if not count or count <= 0 or not ROULETTE_CONFIG[ roulette ] then return end

	local cost, coupon_discount_value = client:GetCostRoullete( roulette )
	if client:TakeDonate( count * cost, "wof", roulette ) then
		if coupon_discount_value then 
			client:TakeSpecialCouponDiscount( coupon_discount_value, roulette == "default" and "default_wof" or "special_vip_wof" )
			triggerClientEvent( client, "onClientRefreshCouponsRoullete", resourceRoot )
		end

		client:GiveCoins( count, roulette, "BOUGHT COINS", "NRPDszx5x" )
		client:ShowInfo( "Вы успешно приобрели " .. count .. " " .. plural( count, "жетон", "жетона", "жетонов" ) .. "!" )

		-- отметка первой покупки жетонов ( для подкрутки баланса )
		if not client:GetPermanentData( "first_coins_purchase" ) then
			client:SetPermanentData( "first_coins_purchase", true )
		end

		triggerEvent( "onPlayerWofCoinsPurchase", client, roulette, count )

		-- analytics
		SendElasticGameEvent( client:GetClientID( ), "wof_purchase", { 
			type = ROULETTE_CONFIG[ roulette ].analytics,
			cost = cost,
			quantity = count,
			spend_sum = count * cost,
			currency = "hard"
		} )
	else
		client:ShowError( "Недостаточно денег!" )
	end
end
addEvent( "BuyCoins", true )
addEventHandler( "BuyCoins", root, BuyCoins_handler )

-- выдать награду колеса
function GiveWheelReward_handler( player, roulette )
	if not isElement( player ) then return end
	if not REWARDS_CACHE[ player ] then return end

	local wof_data = GetData( player )
	local reward_cache = REWARDS_CACHE[ player ]
	local last_wheel_reward = next( wof_data[ roulette ].last_wheel_reward ) and wof_data[ roulette ].last_wheel_reward or nil

	-- если получил сезонную награду, показать ее в callback после полчения награды колеса
	local last_season_reward = next( wof_data[ roulette ].last_season_reward ) and wof_data[ roulette ].last_season_reward or nil
	local is_season_reward = ( last_season_reward and not last_season_reward.passed ) and true or false

	if not last_wheel_reward then return end
	if last_wheel_reward.passed then return end

	-- если уровень сохраненной награды отличается, то генерируем новый список
	if last_wheel_reward.level ~= reward_cache.level then
		reward_cache = GenerateRewardByLevel( last_wheel_reward.level )
	end

	local boost_count = last_wheel_reward.boost_count or 1
	local reward = nil
	if last_wheel_reward.section == SECTION_INVENTORY then
		reward = INVENTORY_CONFIG[ roulette ][ last_wheel_reward.boost_type ][ last_wheel_reward.index ]
	elseif reward_cache.rewards then
		reward = reward_cache.rewards[ roulette ][ last_wheel_reward.section ][ last_wheel_reward.index ]
	else
		reward = reward_cache[ roulette ][ last_wheel_reward.section ][ last_wheel_reward.index ]
	end
	
	local show_reward_data = {
		roulette = roulette,
		is_season_reward = is_season_reward
	}

	local type_reward
	local receive_sum
	local currency
	local bonus_coef = last_wheel_reward.boost_count

	if reward.type == TYPE_EXP then
		local count = math.round( reward.count * last_wheel_reward.boost_count, 0 )
		player:GiveExp( count, "wof", ROULETTE_CONFIG[ roulette ].analytics )
		show_reward_data.reward = { params = { count = count }, type = "exp" }
		wof_data[ roulette ].last_wheel_reward.boost_count = 1
		wof_data[ roulette ].last_wheel_reward.boost_type = TYPE_BOOST_DEFAULT
		type_reward = "exp"
		receive_sum = count
		currency = "exp"
	elseif reward.type == TYPE_SOFT then
		local count = math.round( reward.count * last_wheel_reward.boost_count )
		player:GiveMoney( count, "wof", ROULETTE_CONFIG[ roulette ].analytics )
		show_reward_data.reward = { params = { count = count }, type = "soft" }
		wof_data[ roulette ].last_wheel_reward.boost_count = 1
		wof_data[ roulette ].last_wheel_reward.boost_type = TYPE_BOOST_DEFAULT
		type_reward = "money"
		receive_sum = count
		currency = "soft"
	elseif reward.type == TYPE_BOOST_PLUS_50 then
		player:ShowSuccess( "Бонус +50%" )
		type_reward = "bonus_1"
		receive_sum = 0
		receive_sum = "bonus"
	elseif reward.type == TYPE_BOOST_X2 then
		player:ShowSuccess( "Бонус X2" )
		type_reward = "bonus_2"
		receive_sum = 0
		currency = "bonus"
	elseif reward.type == TYPE_INVENTORY then		
		show_reward_data.reward = reward.reward
		wof_data[ roulette ].last_wheel_reward.boost_count = 1
		wof_data[ roulette ].last_wheel_reward.boost_type = TYPE_BOOST_DEFAULT
		type_reward = "item"
		receive_sum = reward.analytics.cost
		currency = "hard"

		player:Reward( reward.reward )
	end

	local name_reward = reward.type ~= TYPE_INVENTORY and reward.name_reward or reward.analytics.name
	local quantity = reward.type ~= TYPE_INVENTORY and 1 or reward.analytics.count

	-- analytics
	SendElasticGameEvent( player:GetClientID( ), "wof_reward", { 
		type = ROULETTE_CONFIG[ roulette ].analytics,
		type_reward = type_reward,
		name_reward = name_reward,
		id_reward = name_reward,
		bonus_coef = bonus_coef,
		quantity = quantity,
		receive_sum = receive_sum,
		currency = currency,
		points_num = wof_data[ roulette ].game_count_day,
	} )

	local update_rewards_cache
	local update_rewards_season
	local level = player:GetLevel( )
	local season = GetSeason( )

	-- если у игрока изменился уровень
	if level > REWARDS_CACHE[ player ].level  then
		update_rewards_cache = true
		REWARDS_CACHE[ client ].level = level
		REWARDS_CACHE[ client ].rewards = GenerateRewardByLevel( level )
		REWARDS_CACHE[ client ].season = season
	end

	-- если обновился сезон
	if season ~= REWARDS_CACHE[ player ].season then
		update_rewards_season = true
		REWARDS_CACHE[ client ].season = season
	end

	-- рандомная замена jackpot
	local jackpot_index = math.random( 1, #WHEEL_REWARD_PERCENTS[ roulette ][ SECTION_JACKPOT ] )

	if jackpot_index ~= REWARDS_CACHE[ player ].rewards[ roulette ][ SECTION_JACKPOT ] then
		update_rewards_cache = true
		REWARDS_CACHE[ player ].rewards[ roulette ][ SECTION_JACKPOT ].jackpot_index = jackpot_index
	end
	
	-- ставим флаг получения награды
	if reward.type ~= TYPE_BOOST_PLUS_50 and reward.type ~= TYPE_BOOST_X2 then
		wof_data[ roulette ].last_wheel_reward.passed = true
	end
	
	player:SetPermanentData( "wof_data", wof_data )

	-- показываем получение награды
	triggerClientEvent( player, "ShowReward", resourceRoot, wof_data, show_reward_data, update_rewards_cache and REWARDS_CACHE[ player ] or nil, update_rewards_season and season or nil )
end
addEvent( "GiveWheelReward", true )
addEventHandler( "GiveWheelReward", root, GiveWheelReward_handler )

-- выдать сезонную награду
function GiveSeasonReward_handler( player, roulette, is_confirmation_passed, data )
	if not isElement( player ) then return end

	local wof_data = GetData( player )
	local reward_cache = REWARDS_CACHE[ player ]
	local last_season_reward = next( wof_data[ roulette ].last_season_reward ) and wof_data[ roulette ].last_season_reward or nil

	if not last_season_reward then return end
	if last_season_reward.passed then return end
	
	local progress_reward = PROGRESS_REWARDS[ last_season_reward.season ].rewards[ roulette ][ last_season_reward.index ]

	-- подтвержение для получения винила ( callback )
	if is_confirmation_passed and progress_reward.reward.type == "vinyl" then
		wof_data[ roulette ].last_season_reward.passed = true
		player:SetPermanentData( "wof_data", wof_data )
		player:Reward( progress_reward.reward, data )

		-- analytics
		SendElasticGameEvent( player:GetClientID( ), "wof_progression_reward", { 
			type = ROULETTE_CONFIG[ roulette ].analytics,
			name_reward = progress_reward.analytics.name,
			id_reward = tostring( progress_reward.analytics.id ),
			type_reward = "position_" .. last_season_reward.index,
		} )
		return
	end

	local show_reward_data = {
		roulette = roulette,
		is_season_reward = is_season_reward,
		reward = progress_reward.reward
	}

	-- ставим флаг получения награды ( для винилов нужно подтвержение выбора авто )
	if progress_reward.reward.type ~= "vinyl" then
		wof_data[ roulette ].last_season_reward.passed = true
		if last_season_reward.is_soft_replace and progress_reward.analytics.cost_soft then
			player:GiveMoney( progress_reward.analytics.cost_soft, "wof", ROULETTE_CONFIG[ roulette ].analytics )
			show_reward_data.reward = { params = { count = progress_reward.analytics.cost_soft }, type = "soft" }
		else
			player:Reward( progress_reward.reward )
		end

		player:SetPermanentData( "wof_data", wof_data )
	else
		show_reward_data.is_confirmation_passed = true
	end 

	-- analytics
	SendElasticGameEvent( player:GetClientID( ), "wof_progression_reward", { 
		type = ROULETTE_CONFIG[ roulette ].analytics,
		name_reward = progress_reward.analytics.name,
		id_reward = progress_reward.analytics.id,
		type_reward = last_season_reward.index,
	} )

	-- показываем получение награды
	triggerClientEvent( player, "ShowReward", resourceRoot, _, show_reward_data, _, _ )
end
addEvent( "GiveSeasonReward", true )
addEventHandler( "GiveSeasonReward", root, GiveSeasonReward_handler )

-- выдать бесплатный жетон
function UpdateTimeUntilNextCoin( )
	for i, player in pairs( getElementsByType( "player" ) ) do
		if player:IsInGame( ) then
			if player:GetAFKTime( ) <= 300000 then
				local time_left = player:GetPermanentData( "next_coin" ) or FREE_COIN_PERIOD
				if time_left <= 1 then
					player:GiveCoins( player:IsPremiumActive() and 2 or 1, "default", "FREE COIN", "NRPDszx5x" )
					player:SetPermanentData( "next_coin", FREE_COIN_PERIOD )

					local notification = 
					{
						title = "Колесо фортуны",
						msg = "Ты получил жетон для колеса фортуны!",
						special = "roulette_spin_earned",
					}

					player:PhoneNotification( notification )

				else
					player:SetPermanentData( "next_coin", time_left - 1 )
				end
			end
		end
	end
end
setTimer( UpdateTimeUntilNextCoin , 60000, 0 )

function math.round( num,  idp )
	local mult = 10 ^ ( idp or 0 )
	return math.floor( num * mult + 0.5 ) / mult
end

-- ТЕСТИРОВАНИЕ

if SERVER_NUMBER > 100 then
	-- количество игр
    addCommandHandler( "wof_reset_first_purchase", function( player )
        player:SetPermanentData( "first_coins_purchase", nil ) 
		player:SetPermanentData( "first_coins_reward", nil )
		player:ShowInfo( "сброшена первая покупка жетона" )
	end )
	
	addCommandHandler( "wof_set_game_count_day", function( player, cmd, roulette, count )
		count = tonumber( count )
		if not roulette or not count or count > 75 or not ROULETTE_CONFIG[ roulette ] then player:ShowInfo( "формат: команда roulette count" ) return end
		local wof_data = GetData( player )
		wof_data[ roulette ].game_count_day = count
		player:SetPermanentData( "wof_data", wof_data )
		
		player:ShowInfo( "устновлено количество игр" )
	end )
	
	-- сезонные очки
	addCommandHandler( "wof_set_season_points", function( player, cmd, roulette, count )
		count = tonumber( count )
		if not roulette or not count or count > 28 or not ROULETTE_CONFIG[ roulette ] then player:ShowInfo( "формат: команда roulette count" ) return end
		local wof_data = GetData( player )
		wof_data[ roulette ].season_points = count
		player:SetPermanentData( "wof_data", wof_data )
		
		player:ShowInfo( "устновлены сезонные очки" )
	end )
	
	-- неполученная награда из колеса
	addCommandHandler( "wof_set_wheel_reward_not_passed", function( player, cmd, roulette, section, index, level, boost_type )
		section = tonumber( section )
		index = tonumber( index )
		level = tonumber( level )
		boost_type = tonumber( boost_type )

		if not roulette or not section or not index or not level or not boost_type or
		   not ROULETTE_CONFIG[ roulette ] or
		   not WHEEL_REWARD_PERCENTS[ roulette ][ section ] or
		   not WHEEL_REWARD_PERCENTS[ roulette ][ section ][ index ] or
		   ( boost_type ~= TYPE_BOOST_DEFAULT and boost_type ~= TYPE_BOOST_PLUS_50 and boost_type ~= TYPE_BOOST_X2 ) or
		   level < 1 or level > 28
		then player:ShowInfo( "формат: команда roulette section index level boost_type" ) return end

		local wof_data = GetData( player )

		wof_data[ roulette ].last_wheel_reward = {
			section = section,
			index = index,
			level = level,
			passed = false,
			boost_count = boost_type == TYPE_BOOST_PLUS_50 and 1.5 or boost_type == TYPE_BOOST_X2 and 2 or 1,
			boost_type = boost_type,
		}

		player:SetPermanentData( "wof_data", wof_data )
		player:ShowInfo( "установлена неполученная награда из колеса" )
	end )

	-- неполученная награда из сезона
	addCommandHandler( "wof_set_season_reward_not_passed", function( player, cmd, roulette, index, season, is_soft_replace )
		index = tonumber( index )
		season = tonumber( season )
		is_soft_replace = is_soft_replace == "true" and true or false

		if not roulette or not index or not season or
		   not ROULETTE_CONFIG[ roulette ] or
		   not PROGRESS_REWARDS[ season ] or
		   not PROGRESS_REWARDS[ season ].rewards[ roulette ][ index ]
		then player:ShowInfo( "формат: команда roulette index season is_soft_replace" ) return end

		local wof_data = GetData( player )

		wof_data[ roulette ].last_season_reward = {
			season = season,
			index = index,
			passed = false,
			is_soft_replace = is_soft_replace,
		}

		player:SetPermanentData( "wof_data", wof_data )
		player:ShowInfo( "установлена неполученная награда из сезона" )
	end )

	-- желаемая награда колеса
	addCommandHandler( "wof_set_wheel_reward", function( player, cmd, roulette, section, index, boost_type )
		section = tonumber( section )
		index = tonumber( index )
		boost_type = tonumber( boost_type )

		if not roulette or not section or not index or not boost_type or
		   not ROULETTE_CONFIG[ roulette ] or
		   not WHEEL_REWARD_PERCENTS[ roulette ][ section ] or
		   ( not WHEEL_REWARD_PERCENTS[ roulette ][ section ][ index ] and section ~= SECTION_INVENTORY ) or
		   ( boost_type ~= TYPE_BOOST_DEFAULT and boost_type ~= TYPE_BOOST_PLUS_50 and boost_type ~= TYPE_BOOST_X2 )
		then player:ShowInfo( "формат: команда roulette section index boost_type" ) return end

		player:setData( "wheel_section", section, false )
		player:setData( "wheel_index", index, false )
		player:setData( "wheel_boost_type", boost_type, false )
		
		player:ShowInfo( "устновлены желаемая награда колеса" )
	end )

	-- сбросить все
	addCommandHandler( "wof_reset_wheel", function( player )
		local wof_data = {
			[ "default" ] = {
				game_count_day = 0,
				last_game_date = 0,
				current_season = 0,
				season_points = 0,
				season_passed = 0,
				last_wheel_reward = { },
				last_season_reward = { }
			},
			[ "gold" ] = {
				game_count_day = 0,
				last_game_date = 0,
				current_season = 0,
				season_points = 0,
				season_passed = 0,
				last_wheel_reward = { },
				last_season_reward = { }
			}
		}
		
		player:SetPermanentData( "wof_data", wof_data )
		player:ShowInfo( "сброшены все данные" )
	end )
end