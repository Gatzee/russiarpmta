

local SESSIONS_IS_CRASH = 
{
    [ "Timed out" ] = true,
    [ "Bad Connection" ] = true,
}

function onCasinoSlotStart( player, game_id, casino_name, unic_game_id )
    SendElasticGameEvent( player:GetClientID( ), "casino_slot_" .. CASINO_GAME_STRING_IDS[ game_id ] .. "_start", 
    { 
    	casino_name  = tostring( casino_name ),
		unic_game_id = tostring( unic_game_id ),
		current_lvl  = tonumber( player:GetLevel() ),
		game_type    = tostring( "slot_" .. CASINO_GAME_STRING_IDS[ game_id ] ),
    } )
end

function onCasinoSlotLeave( player, game_id, unic_game_id, bet_sum, reward_sum, lost_count_bet, win_count_bet, start_time, leave_reason )
	local lost_sum = math.abs( bet_sum - reward_sum )
	local game_duration = getRealTimestamp() - start_time

	SendElasticGameEvent( player:GetClientID( ), "casino_slot_" .. CASINO_GAME_STRING_IDS[ game_id ] .. "_leave", 
    { 
    	unic_game_id 	= tostring( unic_game_id ),
		current_lvl 	= tonumber( player:GetLevel() ),
		bet_sum 		= tonumber( bet_sum ),
		reward_sum 		= tonumber( reward_sum ),
		lost_sum 	  	= tonumber( lost_sum > 0 and lost_sum or 0 ),
		lost_count_bet 	= tonumber( lost_count_bet ),
		win_count_bet  	= tonumber( win_count_bet ),
		currency 		= "soft",
		game_duration 	= tonumber( game_duration ),
		leave_reason 	= tostring( SESSIONS_IS_CRASH[ leave_reason ] and "crash" or "exit" ),
    } )
end