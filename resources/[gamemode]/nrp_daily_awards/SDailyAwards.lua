loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SVehicle" )

-- 0 - not unlocked yet
-- 1 - unlocked, not took yet
-- -1 - unlocked and took

PLAYER_AWARDS = { }
TRACKED_PLAYERS = { }
AWARD_DAY = { }

ONE_MINUTE_SECONDS = 60000
ONE_DAY_SECONDS = 3600 * 24
SECONDS_IN_ONE_SEASON = ONE_DAY_SECONDS * 30
TIME_TO_RESET = 120 -- min
TIME_TO_NOTIFY = 90
DAYS_IN_ONE_SEASON = 30
SEASON_START_DATE = getTimestampFromString( "13 августа 2020 00:00" )

addEventHandler( "onResourceStart", resourceRoot, function( )
	StartAwardsTimer( true )

	for _, v in pairs( GetPlayersInGame( ) ) do
		OnPlayerJoin( v )
	end

	setTimer( UpdateAwards, ONE_MINUTE_SECONDS, 0 )
end )

addEventHandler( "onResourceStop", resourceRoot, function( )
	for _, v in pairs( GetPlayersInGame( ) ) do
		OnPlayerQuit( v )
	end
end )

function OnPlayerJoin( pPlayer )
	local source = pPlayer or source

	if not PLAYER_AWARDS[ source ] then 
		PLAYER_AWARDS[ source ] = source:GetPermanentData( "dawards" ) or { }
	end

	local seasonNum = getCurrentSeason( )
	local playerSeasonNum = source:GetPermanentData( "dawards_season" )
	local iDay = GetAwardDay( source )
	local bStartCounter = true

	if playerSeasonNum ~= seasonNum then
		-- New season start
		ResetAwards( source, "START_NEW_SEASON" )
		return

	elseif iDay > #REWARDS_BY_DAYS[ seasonNum ] then
		ResetAwards( source, "NEW_ROUND" )
		return

	elseif iDay > 1 then
		-- Вчерашняя не получена, автоматический сброс
		if not PLAYER_AWARDS[ source ][ iDay - 1 ]
		or ( PLAYER_AWARDS[ source ][ iDay - 1 ][ 2 ] >= 0 and PLAYER_AWARDS[ source ][ iDay - 1 ][ 3 ] >= 0 ) then
			ResetAwards( source, "CHAIN_BREAK" )
			return
		end
	end

	if not PLAYER_AWARDS[ source ][ iDay ] then
		PLAYER_AWARDS[ source ][ iDay ] = { 0, 0, 0 }
	end

	-- Сегодняшняя награда уже получена
	if iDay >= 1 and ( PLAYER_AWARDS[ source ][ iDay ][ 2 ] ~= 0 or PLAYER_AWARDS[ source ][ iDay ][ 3 ] ~= 0 ) then
		bStartCounter = false
	end

	if iDay < 1 then
		bStartCounter = false
	end

	if bStartCounter then
		TRACKED_PLAYERS[ source ] = PLAYER_AWARDS[ source ][ iDay ][ 1 ]
	end

	if source:GetLevel( ) <= 1 then return end
	
	local index = source:IsPremiumActive( ) and 3 or 2

	for _, day_info in pairs( PLAYER_AWARDS[ source ] or { } ) do
		if day_info[ index ] == 1 then
			source:PhoneNotification( {
				title = "Ежедневная награда!",
				msg = "Вы можете получить ежедневную награду. Клавиша F6."
			} )
			break
		end
	end
end
addEvent( "onPlayerReadyToPlay", true )
addEventHandler( "onPlayerReadyToPlay", root, OnPlayerJoin, true, "high+1000000" )

function OnPlayerQuit( pPlayer )
	local source = isElement( pPlayer ) and pPlayer or source

	if PLAYER_AWARDS[ source ] then
		source:SetPermanentData( "dawards", PLAYER_AWARDS[source] )
	end

	PLAYER_AWARDS[ source ] = nil
	TRACKED_PLAYERS[ source ] = nil
	AWARD_DAY[ source ] = nil
end
addEvent( "onPlayerPreLogout", true )
addEventHandler( "onPlayerPreLogout", root, OnPlayerQuit )

function UnlockDailyAward( pPlayer )
	local iDay = GetAwardDay( pPlayer )
	local seasonNum = getCurrentSeason( )
	local playerSeasonNum = pPlayer:GetPermanentData( "dawards_season" )

	if playerSeasonNum ~= seasonNum then
		ResetAwards( pPlayer, "START_NEW_SEASON", true )
		return
	end

	local index = pPlayer:IsPremiumActive( ) and 3 or 2

	if PLAYER_AWARDS[ pPlayer ][ iDay ][ index ] == 0 then
		PLAYER_AWARDS[ pPlayer ][ iDay ][ index ] = 1

		pPlayer:PhoneNotification( {
			title = "Ежедневная награда!",
			msg = "Вы можете получить ежедневную награду. Клавиша F6."
		} )
	end

	SendToLogserver( "Игрок " .. pPlayer:GetNickName( ) .. " получил доступ к новой награде", { day = iDay, dawards_count = PLAYER_AWARDS[ pPlayer ], current_dawward_day = CURRENT_DAWARD_DATE } )
end

function GetAwardDay( pPlayer )
	if not isElement( pPlayer ) then return end

	if AWARD_DAY[ pPlayer ] then 
		return AWARD_DAY[ pPlayer ]
	end

	local last_dawards_reset = pPlayer:GetPermanentData( "last_dawards_reset" )

	if not last_dawards_reset then
		pPlayer:SetPermanentData( "last_dawards_reset", CURRENT_DAWARD_DATE )
		last_dawards_reset = CURRENT_DAWARD_DATE
	end

	local iDay = 1
	local count_days = math.floor( ( CURRENT_DAWARD_DATE - last_dawards_reset ) / ONE_DAY_SECONDS ) -- Считаем разницу между текущим сбросом и последним

	if count_days ~= 0 then -- Если разница между текущим и последним сбросом не совпадает инкрементим
		iDay = count_days + 1
	end

	AWARD_DAY[ pPlayer ] = iDay

	return iDay
end

function ResetAwards( pPlayer, sReason, bBreakTimer )
	local iDay = GetAwardDay( pPlayer )
	local seasonNum = getCurrentSeason( )

	local last_dawards_reset = pPlayer:GetPermanentData( "last_dawards_reset" ) or CURRENT_DAWARD_DATE
	SendToLogserver( "Игроку " .. pPlayer:GetNickName( ) .. " сброшен день наград", { day = iDay, dawards_count = PLAYER_AWARDS[ pPlayer ], reason = sReason, break_timer = bBreakTimer, last_dawards_reset = last_dawards_reset, current_dawward_day = CURRENT_DAWARD_DATE } )

	PLAYER_AWARDS[ pPlayer ] = { { 0, 0, 0 } }
	AWARD_DAY[ pPlayer ] = nil

	pPlayer:SetPermanentData( "dawards", { { 0, 0, 0 } } )
	pPlayer:SetPermanentData( "last_dawards_reset", CURRENT_DAWARD_DATE )
	pPlayer:SetPermanentData( "dawards_season", seasonNum )
	
	TRACKED_PLAYERS[ pPlayer ] = not bBreakTimer

	-- Награда была сброшена, даём награду за 1 день
	OnPlayerJoin( pPlayer )
end

function UpdateAwards( )
	local cur_timestamp = getRealTimestamp()

	for player, time in pairs( TRACKED_PLAYERS ) do
		if isElement( player ) and player:GetLevel( ) > 1 then
			local iDay = GetAwardDay( player )
			time = ( tonumber(time) or 0 ) + 1

			if iDay >= 1 then
				PLAYER_AWARDS[ player ][ iDay ][ 1 ] = time
				TRACKED_PLAYERS[ player ] = time

				if time >= REQUIRED_DAILY_PLAYTIME then
					UnlockDailyAward( player )
				elseif time >= REQUIRED_DAILY_PLAYTIME + TIME_TO_NOTIFY then
					local index = player:IsPremiumActive( ) and 3 or 2

					if PLAYER_AWARDS[ pPlayer ][ iDay ][ index ] == 1 then
						local last_notify = player:GetPermanentData( "last_dawards_notify" ) or 0

						if cur_timestamp - last_notify >= 90*60 then
							player:PhoneNotification( {
								title = "Ежедневная награда!",
								msg = "Вы можете получить ежедневную награду. Клавиша F6."
							} )
							player:SetPermanentData( "last_dawards_notify", cur_timestamp )
						end
					end
				end
			else
				TRACKED_PLAYERS[ player ] = nil
			end
		else
			OnPlayerQuit( player )
		end
	end
end

function OnPlayerSwitchDailyAwardsUI( )
	if client:GetLevel( ) <= 1 or not PLAYER_AWARDS[ client ] then return end

	local seasonNum, timeLeft = getCurrentSeason( )

	triggerClientEvent( client, "ShowUI_DailyAwards", resourceRoot, true, PLAYER_AWARDS[ client ], seasonNum, timeLeft, GetAwardDay( client ) )
end
addEvent( "OnPlayerSwitchDailyAwardsUI", true )
addEventHandler( "OnPlayerSwitchDailyAwardsUI", root, OnPlayerSwitchDailyAwardsUI )

function StartAwardsTimer( is_start )
	local date = os.date( "*t" )

	CURRENT_DAWARD_DATE = os.time( {
		year = date.year, 
		month = date.month, 
		day = date.day + 1, 
		hour = 2, 
		min = 0, 
		sec = 0, 
	} )

	local next_daward_date = CURRENT_DAWARD_DATE - os.time( )
	setTimer( StartAwardsTimer, next_daward_date * 1000, 1 )
	
	if is_start then return end

	-- Сутки прошли обновляем данные для получения новой награды
	PLAYER_AWARDS = { }

	for _, v in pairs( GetPlayersInGame( ) ) do
		if AWARD_DAY[ v ] then
			AWARD_DAY[ v ] = AWARD_DAY[ v ] + 1
		end

		OnPlayerJoin( v )
	end
end

function getCurrentSeason( )
	local currentTimestamp = getRealTimestamp( )
	local seasonNum = ( currentTimestamp - SEASON_START_DATE + SECONDS_IN_ONE_SEASON ) / SECONDS_IN_ONE_SEASON
	seasonNum = seasonNum < 1 and 1 or math.floor( seasonNum )

	local timeLeft = SECONDS_IN_ONE_SEASON * seasonNum + SEASON_START_DATE

	local function convertSeasonNum( v )
		if v > 3 then
			v = v - 3
			return convertSeasonNum( v )
		else
			return v
		end
	end

	return convertSeasonNum( seasonNum ), timeLeft
end

if SERVER_NUMBER > 100 then
	addCommandHandler( "dawards_gt", function( player ) 
		local iDay = GetAwardDay( player )
		PLAYER_AWARDS[ player ][ iDay ][ 1 ] = REQUIRED_DAILY_PLAYTIME - 1
		TRACKED_PLAYERS[ player ] = REQUIRED_DAILY_PLAYTIME - 1

		outputChatBox( "Награда будет разблокирована через одну минуту", player, 255, 255, 255 )
	end )

	addCommandHandler( "dawards_nt", function( player ) 
		local iDay = GetAwardDay( player )
		PLAYER_AWARDS[ player ][ iDay ][ 1 ] = REQUIRED_DAILY_PLAYTIME + TIME_TO_NOTIFY - 1
		TRACKED_PLAYERS[ player ] = REQUIRED_DAILY_PLAYTIME + TIME_TO_NOTIFY - 1
		player:SetPermanentData( "last_dawards_notify", 0 )

		outputChatBox( "Уведомление поступит через одну минуту", player, 255, 255, 255 )
	end )

	addCommandHandler( "reset_da", function( player ) 
		ResetAwards( player, "test_cmd" )

		outputChatBox( "Награды сброшены", player, 255, 255, 255 )
	end )
end