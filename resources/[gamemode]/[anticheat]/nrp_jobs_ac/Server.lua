loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )

TIME_MINIMUM_LIMIT = { }
PLAYER_JOB_START = { }

UPDATE_INTERVAL_MS = 60000 --Интервал подтягивания данных с бд

function onJobStart_handler( )
	PLAYER_JOB_START[ source ] = { event = string.gsub( eventName, "PlayeStartQuest_", "" ), startTime = getRealTimestamp( ) }
end

function GetPlayerInfo( player )
	if not player then return end

	local jobInfo = PLAYER_JOB_START[ source ]
	if not jobInfo then return end

	local event = jobInfo.event
	local time_to_complete = getRealTimestamp( ) - jobInfo.startTime

	return time_to_complete or -1, event
end

function onJobEarnMoney_handler( job_class, money_reward, desc, exp )
	if not source or not PLAYER_JOB_START[ source ] then return end

	local time_to_complete, event = GetPlayerInfo( source )

	--analytics
	SendElasticGameEvent( source:GetClientID( ), "ac_job_time", {
		task_id       			= event,
		duration_to_complete 	= time_to_complete,
	} )

	isEarnedWithRestrictedTime( source, event, time_to_complete )
end
addEvent( "onJobEarnMoney", true )
addEventHandler( "onJobEarnMoney", root, onJobEarnMoney_handler )

function isEarnedWithRestrictedTime( player, event, time_to_complete )
	if not player then return end
	PLAYER_JOB_START[ player ] = nil

	local limit = TIME_MINIMUM_LIMIT[ event ]
	if not limit or time_to_complete > limit then return end

	--логи
	WriteLog( "anti_cheat", "[Jobs:античит] %s выполнил работу за %s сек. (рекомендуемое время: %s сек.)", player, time_to_complete, limit )

	--Рассылка админам
	-- local isKicked = player:GetPermanentData( "warned_by_jobs_anticheat" )
	-- local kickString = isKicked and "и был за это кикнут" or ""

	local id = player:GetID( )
	for i, v in pairs( GetPlayersInGame( ) ) do
		if v:GetAccessLevel( ) > 0 then
			-- v:outputChat( string.format( "[Jobs:античит] ID: %s выполнил работу слишком быстро (за %s секунд)", v:GetID( ), time_to_complete ), 255, 0, 0, true )
			v:outputChat( "[Античит] ID: " .. id .. " выполнил работу слишком быстро", 255, 0, 0, true )
		end
	end

	--triggerEvent( "DetectPlayerAC", player, "42", true )

	-- if isKicked then 
	-- 	player:kick( "Подозрение в читерстве" )
	-- else
	-- 	player:SetPermanentData( "warned_by_jobs_anticheat", true )
	-- end
end

function onResourceStart_handler( )
	CommonDB:createTable( "nrp_jobs_timelimits", {
		{ Field = "key",		Type = "varchar(128)",		Null = "NO",	Key = "PRI"	};
		{ Field = "value",		Type = "int(11)",			Null = "NO",    Key = "" 	};
	} )

	ExecuteSelectQuery( )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function ExecuteSelectQuery( )
	CommonDB:queryAsync( function( query )
		local result = query:poll( -1 )
		local newList = {}
		if #result >= 1 then
			for i,v in pairs( result ) do
				newList[ v.key ] = v.value
			end
		end
		--apply differences
		for i,v in pairs( TIME_MINIMUM_LIMIT ) do
			if not newList[ i ] then
				outputDebugString( "Removing event handler ".."PlayeStartQuest_"..i.."("..v.." s.)" )
				removeEventHandler( "PlayeStartQuest_"..i, root, onJobStart_handler )
				TIME_MINIMUM_LIMIT[ i ] = nil
			else
				if newList[ i ] ~= v then
					outputDebugString( "Updating limit of ".."PlayeStartQuest_"..i.."("..v.." s. -> "..newList[ i ].." s.)" )
					TIME_MINIMUM_LIMIT[ i ] = newList[ i ]
				end
			end
		end

		for i,v in pairs( newList ) do
			if not TIME_MINIMUM_LIMIT[ i ] then
				outputDebugString( "Adding new event handler ".."PlayeStartQuest_"..i.."("..v.." s.)" )
				addEventHandler( "PlayeStartQuest_"..i, root, onJobStart_handler )
				TIME_MINIMUM_LIMIT[ i ] = v
			end
		end

		setTimer( ExecuteSelectQuery, UPDATE_INTERVAL_MS, 1 )
	end, { }, "SELECT * FROM nrp_jobs_timelimits" )
end

addEventHandler( "onPlayerQuit", root, function ( )
	if PLAYER_JOB_START[ source ] then PLAYER_JOB_START [ source ] = nil end
end )