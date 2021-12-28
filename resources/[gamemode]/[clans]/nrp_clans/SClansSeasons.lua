SEASON_DATA = { }

LOCKED_SEASON = false
LOCKED_SEASON_DURATION = ( 8 + 24 ) * 60 * 60
TOTAL_SEASON_DURATION = 14 * 24 * 60 * 60
SEASON_DURATION = TOTAL_SEASON_DURATION - LOCKED_SEASON_DURATION

CURRENT_SEASON_ID = 1
SEASON_START_DATE = nil
SEASON_END_DATE = nil

SEASON_TIMERS = { }

function CalculateSeasonPeriodDates( )
	local current_date = os.time( )

	if not SEASON_START_DATE then
		local offset_date = getTimestampFromString( "15 июня 2020 00:00" ) -- точка отсчёта начала сезонов
		if offset_date > current_date then
			-- Начало первого сезона после релиза на текущих серверах
			SEASON_START_DATE = getTimestampFromString( "13 июня 2020 12:00" )
			SEASON_END_DATE = getTimestampFromString( "27 июня 2020 16:00" )
		else
			-- Начало первого сезона на новых серверах, добавленных после релиза
			local passed_time = current_date - offset_date
			SEASON_START_DATE = current_date - passed_time % TOTAL_SEASON_DURATION

			-- Если это только первый сезон и до начала следующего осталось меньше недели 
			if CURRENT_SEASON_ID == 1 and ( current_date - SEASON_START_DATE ) > ( 7 * 24 * 60 * 60 ) then
				SEASON_START_DATE = SEASON_START_DATE + 7 * 24 * 60 * 60
			end
			SEASON_END_DATE = SEASON_START_DATE + SEASON_DURATION
		end

		SaveSeasonData( )
	end

	CalculateCartelsTaxDates( )

	iprint( "    SEASON_START_DATE", os.date( "%Y-%m-%d %H:%M:%S", SEASON_START_DATE ) )
	iprint( "    SEASON_END_DATE", os.date( "%Y-%m-%d %H:%M:%S", SEASON_END_DATE ) )

	UpdateSeasonTimers( )
end

function UpdateSeasonTimers( )
	DestroyTableElements( SEASON_TIMERS )

	local current_date = os.time( )

	if current_date < SEASON_END_DATE then
		-- Начало первого сезона после релиза на текущих серверах
		if current_date < SEASON_START_DATE then
			SEASON_TIMERS.first_season_start = setTimer( ResetClans, ( SEASON_START_DATE - current_date ) * 1000, 1 )
		end

		local time_left = SEASON_END_DATE - current_date
		SEASON_TIMERS.season_end = setTimer( OnSeasonEnd, time_left * 1000, 1 ) -- в субботу в 16:00
		SEASON_TIMERS.check_cartel_wars = setTimer( CheckCartelWars, ( time_left + CARTEL_WARS_WAITING_DURATION ) * 1000, 1 ) -- в субботу в 19:00
		SEASON_TIMERS.next_season = setTimer( NextSeason, ( time_left + LOCKED_SEASON_DURATION ) * 1000, 1 ) -- в вск в 23:59 (пн 00:00)

		-- для дебага
		if SERVER_NUMBER > 100 then
			SEASON_TIMERS.AllowCartelTaxRequestsAndWars = setTimer( AllowCartelTaxRequestsAndWars, ( time_left + ALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION ) * 1000, 1 )
			SEASON_TIMERS.DisallowCartelTaxes = setTimer( DisallowCartelTaxes, ( time_left + ALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION + DISALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION ) * 1000, 1 )
			SEASON_TIMERS.DisallowCartelsDeclareWar = setTimer( DisallowCartelsDeclareWar, ( time_left + ALLOW_CARTELS_TAX_REQUESTS_WAITING_DURATION + DISALLOW_CARTELS_TAX_WARS_WAITING_DURATION ) * 1000, 1 )
		end

	else
		-- Межсезонье
		local passed_time = current_date - SEASON_END_DATE
		if LOCKED_SEASON then
			if passed_time <= LOCKED_SEASON_DURATION then
				if passed_time < CARTEL_WARS_WAITING_DURATION then
					SEASON_TIMERS.check_cartel_wars = setTimer( CheckCartelWars, ( CARTEL_WARS_WAITING_DURATION - passed_time ) * 1000, 1 ) -- в субботу в 19:00
				end
				SEASON_TIMERS.next_season = setTimer( NextSeason, ( LOCKED_SEASON_DURATION - passed_time ) * 1000, 1 ) -- в вск в 23:59 (пн 00:00)
			else
				-- Сервер был выключен, когда должен был сработать таймер SEASON_TIMERS.next_season в вск в 23:59 (пн 00:00)
				Debug( "LOCKED_SEASON and current_date > ( SEASON_END_DATE + LOCKED_SEASON_DURATION )", 1 )
				NextSeason( )
			end
		else
			if current_date < SEASON_END_DATE + LOCKED_SEASON_DURATION then
				-- Сервер был выключен, когда должен был сработать таймер SEASON_TIMERS.season_end в субботу в 16:00
				if passed_time < CARTEL_WARS_WAITING_DURATION then
					OnSeasonEnd( )
					SEASON_TIMERS.check_cartel_wars = setTimer( CheckCartelWars, ( CARTEL_WARS_WAITING_DURATION - passed_time ) * 1000, 1 ) -- в субботу в 19:00
					SEASON_TIMERS.next_season = setTimer( NextSeason, ( LOCKED_SEASON_DURATION - passed_time ) * 1000, 1 ) -- в вск в 23:59 (пн 00:00)
				else
					Debug( "not LOCKED_SEASON and current_date > ( SEASON_END_DATE + CARTEL_WARS_WAITING_DURATION )", 1 )
				end
			else
				Debug( "not LOCKED_SEASON and current_date > ( SEASON_END_DATE + LOCKED_SEASON_DURATION )", 1 )
				-- -- Сервер был выключен, когда должен был закончиться сезон и начаться новый
				-- NextSeason( ) -- Начать новый сезон ?
			end
		end
	end
end

function OnSeasonEnd( )
	print( "OnSeasonEnd", formatTimestamp( os.time( ) ) )
	local current_season_id = CURRENT_SEASON_ID
	local leaderboard = { } 
	local cartels_data = { } 
	for i = 1, #CLANS_LIST do
		local clan = CLANS_LIST[ i ]
		if not clan.cartel then
			-- Юзаем leaderboard_data, чтобы результат не отличался от того, что отображается игрокам в интерфейсе
			table.insert( leaderboard, clan.leaderboard_data )
		else
			cartels_data[ clan.cartel ] = clan.leaderboard_data
			local seasons_positions = clan:GetPermanentData( "seasons_positions" ) or { }
			seasons_positions[ current_season_id ] = -clan.cartel
			clan:SetPermanentData( "seasons_positions", seasons_positions )
		end
	end
	table.sort( leaderboard, function( a, b ) return a[ LB_CLAN_SCORE ] > b[ LB_CLAN_SCORE ] or a[ LB_CLAN_SCORE ] == b[ LB_CLAN_SCORE ] and a[ LB_CLAN_MEMBERS_COUNT ] > b[ LB_CLAN_MEMBERS_COUNT ] end )

	local leaderboard_count = #leaderboard
	for position = 1, leaderboard_count > 8 and 8 or leaderboard_count do
		local leaderboard_data = leaderboard[ position ]
		local clan = CLANS_BY_ID[ leaderboard_data[ LB_CLAN_ID ] ]

		if position <= 8 then
			WriteLog( "clans/seasons", "Клан %s (ID:%s) занял %s место в %s сезоне", clan.name, clan.id, position, current_season_id )

			clan:SetPermanentData( "last_season_reward_data", {
				date = os.time( ),
				season = current_season_id,
				position = position, 
			} )
			
			for i, item in pairs( CLAN_SEASON_REWARDS[ position ].clan ) do
				if item.type == "money" then
					clan:GiveMoney( item.count )
				elseif item.type == "weapon" then
					clan:AddItemToStorage( { type = IN_WEAPON, id = item.id, count = item.count } )
				end
			end

			Async:foreach( clan:GetOnlineMembers( ), function( player, i )
				if isElement( player ) then
					GiveClanSeasonRewards( player, current_season_id, position )
				end
			end )
		end

		local seasons_positions = clan:GetPermanentData( "seasons_positions" ) or { }
		seasons_positions[ CURRENT_SEASON_ID ] = position
		clan:SetPermanentData( "seasons_positions", seasons_positions )
	end
	
	LOCKED_SEASON_LEADEBOARD = table.copy( leaderboard )
	LOCKED_SEASON_CARTELS = cartels_data
	-- Добавляем клантеги для отображения в ShowSeasonResults
	for i = 1, leaderboard_count > 8 and 8 or leaderboard_count do
		local data = LOCKED_SEASON_LEADEBOARD[ i ]
		data[ LB_CLAN_TAG ] = CLANS_BY_ID[ data[ LB_CLAN_ID ] ].tag
	end

	LOCKED_SEASON = true
	SaveSeasonData( )
end

function NextSeason( )
	print( "NextSeason", formatTimestamp( os.time( ) ) )
    
	LOCKED_SEASON = false
	CURRENT_SEASON_ID = ( CURRENT_SEASON_ID or 1 ) + 1
	SEASON_START_DATE = SEASON_END_DATE + LOCKED_SEASON_DURATION
	SEASON_END_DATE = SEASON_END_DATE + TOTAL_SEASON_DURATION

	SEASON_DATA = { }
	SaveSeasonData( )

	CalculateSeasonPeriodDates( )

    ResetClans( )
end

function ResetClans( )
    Async:foreach( CLANS_LIST, function( clan )
        clan:SetHonor( 0, true )
        clan:SetPermanentData( "packages", 0 )
        clan:SetPermanentData( "packages_score", 0 )
        clan:SetPermanentData( "cargodrops", 0 )
        clan:SetPermanentData( "cargodrops_score", 0 )
        clan:SetPermanentData( "holdarea_score", 0 )
        clan:SetPermanentData( "deathmatch_score", 0 )
    end )

    triggerEvent( "onClansReset", root )
end

function GiveClanSeasonRewards( player, season, clan_position )
	player:PhoneNotification( {
		title = "Окончание сезона №" .. season,
		msg = "Ваш клан занял " .. clan_position .. " место."
	} )

	if not player:GetClanStats( "join_season" ) then
        player:SetClanStats( "join_season", LOCKED_SEASON and ( CURRENT_SEASON_ID + 1 ) or CURRENT_SEASON_ID )
	end

	if player:GetClanStats( "join_season" ) > season then
		-- Если игрок вступил в клан позже окончания победного сезона - плюхи не выдаются
		return
	end

	-- Если игрок - один из вступивших за 3 дня до окончания сезона
	--[[local ts = player:GetPermanentData( "clan_join_ts" ) or 0
	-- SEASON_LOCK_TIME = 3 * 24 * 60 * 60
	if ( SEASON_END_DATE - ts ) <= SEASON_LOCK_TIME then
		return
	end]]

	if player:GetPermanentData( "clan_reward_season" ) ~= season then
		player:SetPermanentData( "clan_reward_season", season )

		for i, item in pairs( CLAN_SEASON_REWARDS[ clan_position ].members ) do
			if item.type == "money" then
				player:GiveMoney( item.count, "clan_season_win" )
			elseif item.type == "weapon" then
				player:InventoryAddItem( IN_WEAPON, { item.id }, item.count )
			end
		end
	end
end

function CheckClanSeasonRewards( clan, player )
	local last_season_reward_data = clan:GetPermanentData( "last_season_reward_data" )

	if last_season_reward_data and ( last_season_reward_data.date + SEASON_DURATION ) > os.time( ) then
		GiveClanSeasonRewards( player, last_season_reward_data.season, last_season_reward_data.position )
	end
end



if SERVER_NUMBER > 100 then

	addCommandHandler( "OnSeasonEnd", function( )
		if LOCKED_SEASON then
			NextSeason( )
		end
		DestroyTableElements( SEASON_TIMERS )

		SEASON_END_DATE = os.time( )
		CalculateCartelsTaxDates( )
		OnSeasonEnd( )
	end )

	addCommandHandler( "CheckCartelWars", CheckCartelWars )

	addCommandHandler( "AllowCartelTaxes", AllowCartelTaxes )

	addCommandHandler( "NextSeason", function( )
		NextSeason( )

		SEASON_START_DATE = os.time( )
		SEASON_END_DATE = SEASON_START_DATE + SEASON_DURATION
		CalculateSeasonPeriodDates( )
		SaveSeasonData( )
	end )

	addCommandHandler( "ResetClans", ResetClans )


	addCommandHandler( "SetSeasonEnd", function( player, cmd, ... )
		local str_time = table.concat( { ... }, " " )
		local result, time = pcall( getTimestampFromString, str_time )
		if not result then
			outputConsole( "ОШИБКА! Пример правильного ввода: SetSeasonEnd 20 февраля 2020 20:02", player )
			return
		end
		SEASON_END_DATE = time
		CalculateCartelsTaxDates( )

		DestroyTableElements( SEASON_TIMERS )
		
		SEASON_TIMERS.season_end = setTimer( OnSeasonEnd, ( SEASON_END_DATE - os.time( ) ) * 1000, 1 )

		outputConsole( "Время окончания сезона успешно установлено на " .. str_time, player )
	end )


	addEvent( "SetSeasonSettings", true )
	addEventHandler( "SetSeasonSettings", root, function( data )
		for var, value in pairs( data ) do
			_G[ var ] = value
		end
		TOTAL_SEASON_DURATION = SEASON_DURATION + LOCKED_SEASON_DURATION
		
		DestroyTableElements( SEASON_TIMERS )

		LOCKED_SEASON = false
		CURRENT_SEASON_ID = 1
		SEASON_START_DATE = os.time( ) + NEW_SEASON_START_AFTER_TIME
		SEASON_END_DATE = SEASON_START_DATE + SEASON_DURATION
		SEASON_DATA = { }
		SaveSeasonData( )
		CalculateSeasonPeriodDates( )

		SEASON_TIMERS.first_season_start_debug = setTimer( function( )
			print( "OnSeasonStart", formatTimestamp( os.time( ) ) )
		end, ( SEASON_START_DATE - os.time( ) ) * 1000, 1 )

		SetCartelClan( 1, false )
		SetCartelClan( 2, false )

		source:ShowSuccess "Успешно!"
	end )



end