loadstring( exports.interfacer:extend( "Interfacer" ) )( )
Extend( "SPlayer" )
Extend( "SDB" )

TIME_BEFORE_END = 2 * 24 * 60 * 60
CHECK_INTERVAL = 15 * 60

ENDING_CASE_NAMES = { }
END_TIME = 0

function onPlayerCompleteLogin_handler( player )
	local player = isElement( player ) and player or source

	if os.time( ) > END_TIME then return end
	if not player:HasFinishedTutorial( ) then return end

	if player:GetPermanentData( "cases_ending_show_time" ) == END_TIME then return end
	player:SetPermanentData( "cases_ending_show_time", END_TIME )

	triggerClientEvent( player, "onClientCasesSaleEnding", resourceRoot, ENDING_CASE_NAMES, END_TIME )

	SendElasticGameEvent( player:GetClientID( ), "case_notification_show" )
end
addEventHandler( "onPlayerReadyToPlay", root, onPlayerCompleteLogin_handler, true, "high+9999999" )

function onResourceStart_handler( )
	setTimer( CheckEndingCases, CHECK_INTERVAL * 1000, 0 )
	CheckEndingCases( )

	setTimer( function( )
		for i, player in pairs( GetPlayersInGame( ) ) do
			onPlayerCompleteLogin_handler( player )
		end
	end, 1000, 1 )
end
addEventHandler( "onResourceStart", resourceRoot, onResourceStart_handler )

function CheckEndingCases( current_date )
	local cases_info = exports.nrp_shop:GetCasesInfo( )

	if not cases_info then return end
	
	-- Не юзаем getRealTimestamp, чтобы функция не срабатывала при тесте другого контента с setfaketime
	current_date = current_date or os.time( )

	local cases_list = { }
	for i, case_data in pairs( cases_info ) do
		table.insert( cases_list, case_data )
	end
    table.sort( cases_list, function( a, b ) return ( a.temp_end or 0 ) < ( b.temp_end or 0 ) end )

	ENDING_CASE_NAMES = { }
	END_TIME = 0

    local cases_to_update = { }
    local current_temp_ends_by_position = { }
    local cases_by_temp_start_by_position = { }

	for i, case_data in pairs( cases_list ) do
		local temp_end = case_data.temp_end
		if temp_end then
			if current_date > ( case_data.temp_start or 0 ) and temp_end > current_date then
				if temp_end - current_date < TIME_BEFORE_END then
					END_TIME = temp_end
					table.insert( ENDING_CASE_NAMES, case_data.name )
				end
			end
        end
	end
end