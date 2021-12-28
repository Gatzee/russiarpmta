loadstring( exports.interfacer:extend( "Interfacer" ) )()
Extend( "SPlayer" )
Extend( "SPlayerOffline" )
Extend( "SDB" )
Extend( "SInterior" )
Extend( "SChat" )

enum "eVotingSteps" {
	"VOTING_STEP_WAIT",
	"VOTING_STEP_START",
	"VOTING_STEP_END",
	"VOTING_STEP_NEW",
}

local CONST_CANDIDACY_COST = 2000000
local CONST_CANDIDACY_LEVEL_FREE = 7
local CONST_REQUEST_MIN_VOTING_LEVEL = 6
local COST_CITY_MAYOR_TIME_LEN = 21 * 24 * 60 * 60
local CONST_VOTING_STEPS_TIME = {
	[ VOTING_STEP_WAIT ] = 2 * 24 * 60 * 60;
	[ VOTING_STEP_START ] = 36 * 60 * 60;
	[ VOTING_STEP_END ] = COST_CITY_MAYOR_TIME_LEN - 3.5 * 24 * 60 * 60;
}
local CONST_DEFAULT_MAYOR_RATING = 75

VOTING_CANDIDATES = { }
VOTINGS_REGISTERED = { }
VOTING_STATE = { }
CURRENT_CITY_MAYOR = { }
CURRENT_CITY_MAYOR_END_TIME = { }
CURRENT_CITY_MAYOR_CACHE_NAME = { }
CURRENT_CITY_MAYOR_RATING = { }
HISTORY_CITY_MAYOR = {
	[7] = { };
	[8] = { };
	[13] = {},
}

VOTING_TENTS = { }

DB:createTable( "nrp_gov_candidates",
	{
		{ Field = "user_id",		Type = "int(11) unsigned",	Null = "NO",    Key = "PRI",	Default = 0		},
        { Field = "gov_id",			Type = "int(11) unsigned",	Null = "NO",	Key = ""						},
        { Field = "name",			Type = "varchar(32)",		Null = "NO",	Key = ""						},
	}
)

DB:createTable( "nrp_gov_votes",
	{
		{ Field = "user_id",		Type = "int(11) unsigned",	Null = "NO",    Key = ""						},
        { Field = "gov_id",			Type = "int(11) unsigned",	Null = "NO",	Key = ""						},
        { Field = "candidate_id",	Type = "int(11) unsigned",	Null = "NO",	Key = ""						},
	}
)

DB:createTable( "nrp_gov_voting_state",
	{
		{ Field = "gov_id",			Type = "int(11) unsigned",	Null = "NO",    Key = "PRI",	Default = 0		},
        { Field = "step",			Type = "int(11) unsigned",	Null = "NO",	Key = ""						},
        { Field = "start_time",		Type = "int(11) unsigned",	Null = "NO",	Key = ""						},
	}
)

DB:createTable( "nrp_gov_mayor",
	{
		{ Field = "gov_id",			Type = "int(11) unsigned",	Null = "NO",    Key = "PRI",	Default = 0		},
        { Field = "user_id",		Type = "int(11) unsigned",	Null = "YES",	Key = ""						},
        { Field = "name",			Type = "varchar(32)",		Null = "YES",	Key = ""						},
        { Field = "end_time",		Type = "int(11) unsigned",	Null = "YES",	Key = ""						},
        { Field = "history",		Type = "json",				Null = "NO",	Key = ""						},
		{ Field = "rating",			Type = "float unsigned",	Null = "NO",	Key = "",		Default = 50.0	};
	}
)

addEventHandler( "onResourceStart", resourceRoot, function( )
	DB:queryAsync( function( query )
		local results = dbPoll( query, -1 )
		for _, result in pairs( results ) do
			VOTING_CANDIDATES[ result.user_id ] = {
				gov_id = result.gov_id;
				name = result.name;
				votes = 0;
			}

			WriteLog( "government/voting_db_load", "[ VOTING_CANDIDATES ][ GOV_ID : %s ][ NAME : %s ]", result.gov_id, result.name )
		end
	end, { }, "SELECT * FROM nrp_gov_candidates" )

	DB:queryAsync( function( query )
		local results = dbPoll( query, -1 )
		for _, result in pairs( results ) do
			if not VOTINGS_REGISTERED[ result.gov_id ] then VOTINGS_REGISTERED[ result.gov_id ] = { } end
			VOTINGS_REGISTERED[ result.gov_id ][ result.user_id ] = result.candidate_id

			if VOTING_CANDIDATES[ result.candidate_id ] then
				VOTING_CANDIDATES[ result.candidate_id ].votes = VOTING_CANDIDATES[ result.candidate_id ].votes + 1

				WriteLog( "government/voting_db_load", "[ VOTINGS_REGISTERED ][ GOV_ID : %s ][ USER_ID : %s ][ CANDIDATE_ID : %s ][ CANDIDATE_VOTES_NOEW_COUNT : %s ]", result.gov_id, result.user_id, result.candidate_id, VOTING_CANDIDATES[ result.candidate_id ].votes )
			end
		end
	end, { }, "SELECT * FROM nrp_gov_votes" )

	DB:queryAsync(  function( query )
		local results = dbPoll( query, -1 )
		for _, result in pairs( results ) do
			VOTING_STATE[ result.gov_id ] = {
				step = result.step;
				start_time = result.start_time;
			}

			WriteLog( "government/voting_db_load", "[ VOTING_STATE ][ GOV_ID : %s ][ STEP : %s ][ START_TIME : %s ]", result.gov_id, result.step, result.start_time )
		end

		for gov_id, state_data in pairs( VOTING_STATE ) do
			CreateVotingTentsInWorld( gov_id )
		end
	end, { }, "SELECT * FROM nrp_gov_voting_state" )

	DB:queryAsync(  function( query )
		local results = dbPoll( query, -1 )
		for _, result in pairs( results ) do
			CURRENT_CITY_MAYOR[ result.gov_id ] = result.user_id or nil
			CURRENT_CITY_MAYOR_CACHE_NAME[ result.gov_id ] = result.name or nil
			CURRENT_CITY_MAYOR_END_TIME[ result.gov_id ] = result.end_time
			HISTORY_CITY_MAYOR[ result.gov_id ] = fromJSON( result.history )
			CURRENT_CITY_MAYOR_RATING[ result.gov_id ] = result.rating

			WriteLog( "government/voting_db_load", "[ CITY_MAYOR ][ GOV_ID : %s ][ USER_ID : %s ][ NAME : %s ][ END_TIME : %s ][ RATING : %s ][ HISTORY : %s ]", result.gov_id, ( result.user_id or "-1" ), ( result.name or "NONE" ), result.end_time, result.rating, result.history )
		end
	end, { }, "SELECT * FROM nrp_gov_mayor" )

	Timer( TickVotingCheck, 60000, 0 )
end )

function TickVotingCheck( )
	local timestamp = getRealTime( ).timestamp
	for gov_id, state_data in pairs( VOTING_STATE ) do
		if ( state_data.start_time + CONST_VOTING_STEPS_TIME[ state_data.step ] ) <= timestamp then
			local restart_current = false

			if state_data.step == VOTING_STEP_WAIT then
				local found = false
				for user_id, data in pairs( VOTING_CANDIDATES ) do
					if data.gov_id == gov_id then
						found = true
					end
				end

				if not found then
					restart_current = true
				end
			end

			if restart_current then
				state_data.start_time = timestamp

				DB:exec( "REPLACE INTO nrp_gov_voting_state ( gov_id, step, start_time ) VALUES ( ?, ?, ? )", gov_id, VOTING_STATE[ gov_id ].step, VOTING_STATE[ gov_id ].start_time )

				WriteLog( "government/voting_update", "[ RESTART_VOTING ][ GOV_ID : %s ][ STEP : %s ][ START_TIME : %s ]", gov_id, VOTING_STATE[ gov_id ].step, VOTING_STATE[ gov_id ].start_time )
			else
				state_data.step = state_data.step + 1
				state_data.start_time = timestamp

				DB:exec( "REPLACE INTO nrp_gov_voting_state ( gov_id, step, start_time ) VALUES ( ?, ?, ? )", gov_id, VOTING_STATE[ gov_id ].step, VOTING_STATE[ gov_id ].start_time )

				WriteLog( "government/voting_update", "[ NEXT_VOTING_STEP ][ GOV_ID : %s ][ STEP : %s ][ START_TIME : %s ]", gov_id, VOTING_STATE[ gov_id ].step, VOTING_STATE[ gov_id ].start_time )

				if state_data.step == VOTING_STEP_END then
					if SelectAndSetNewCityMayor( gov_id ) then
						CleanUpVotingCandidates( gov_id )
						CleanUpVotingsRegistered( gov_id )

						WriteLog( "government/voting_update", "[ MAYOR_SELECT_SUCCESSFUL ][ GOV_ID : %s ]", gov_id )
					else
						WriteLog( "government/voting_update", "[ MAYOR_SELECT_FAILED ][ GOV_ID : %s ]", gov_id )

						triggerEvent( "StartGovernmentVoting", root, gov_id )
					end

				elseif state_data.step == VOTING_STEP_NEW then
					triggerEvent( "StartGovernmentVoting", root, gov_id )
				end
			end

			UpdateVotingTentsInWorld( gov_id )
		end
	end

	for gov_id, end_time in pairs( CURRENT_CITY_MAYOR_END_TIME ) do
		if not end_time or end_time <= timestamp then
			RemoveCurrentCityMayor( gov_id, "Конец срока" )
		end
	end

	for gov_id in pairs( CURRENT_CITY_MAYOR ) do
		local rating = CURRENT_CITY_MAYOR_RATING[ gov_id ]
		if rating then
			if rating == 0 then
				RemoveCurrentCityMayor( gov_id, "Импичмент. Рейтинг власти снизился до 0" )

				if VOTING_STATE[ gov_id ].step == VOTING_STEP_END then
					triggerEvent( "StartGovernmentVoting", root, gov_id )
				end
			else
				UpdateCityMayorRating( gov_id, - ( 100 / ( 36 * 60 ) ) )
			end
		end
	end
end

function StartGovernmentVoting_handler( gov_id, leave_himself )
	if leave_himself and VOTING_STATE[ gov_id ] and VOTING_STATE[ gov_id ].step ~= VOTING_STEP_END then
		return
	end

	CleanUpVotingCandidates( gov_id )
	CleanUpVotingsRegistered( gov_id )
	DeleteVotingTentsInWorld( gov_id )

	VOTING_STATE[ gov_id ] = {
		step = VOTING_STEP_WAIT;
		start_time = getRealTime( ).timestamp;
	}

	DB:exec( "REPLACE INTO nrp_gov_voting_state ( gov_id, step, start_time ) VALUES ( ?, ?, ? )", gov_id, VOTING_STATE[ gov_id ].step, VOTING_STATE[ gov_id ].start_time )

	WriteLog( "government/voting_update", "[ START_VOTING ][ GOV_ID : %s ]", gov_id )

	CreateVotingTentsInWorld( gov_id )
end
addEvent( "StartGovernmentVoting" )
addEventHandler( "StartGovernmentVoting", root, StartGovernmentVoting_handler )

function CleanUpVotingCandidates( gov_id )
	local count = 0
	for user_id, data in pairs( VOTING_CANDIDATES ) do
		if data.gov_id == gov_id then
			VOTING_CANDIDATES[ user_id ] = nil
			
			count = count + 1
		end
	end

	DB:exec( "DELETE FROM nrp_gov_candidates WHERE gov_id=?", gov_id )

	WriteLog( "government/voting_update", "[ CLEANUP_CANDIDATES ][ GOV_ID : %s ][ COUNT : %s ]", gov_id, count )
end

function CleanUpVotingsRegistered( gov_id )
	VOTINGS_REGISTERED[ gov_id ] = { }

	DB:exec( "DELETE FROM nrp_gov_votes WHERE gov_id=?", gov_id )

	WriteLog( "government/voting_update", "[ CLEANUP_VOTES ][ GOV_ID : %s ]", gov_id )
end

function CreateVotingTentsInWorld( gov_id )
	if VOTING_STATE[ gov_id ].step ~= VOTING_STEP_WAIT and VOTING_STATE[ gov_id ].step ~= VOTING_STEP_START then return end

	DeleteVotingTentsInWorld( gov_id )

	VOTING_TENTS[ gov_id ] = { }

	for i, position in pairs( VOTING_TENTS_POSITIONS[ gov_id ] ) do
		local object = createObject( 744, position + Vector3( 0, 0, -1 ) )

		local conf = {}
		conf.x = position.x
		conf.y = position.y
		conf.z = position.z
		conf.radius = 2
		conf.color = { 145, 145, 255, 40 }
		if VOTING_STATE[ gov_id ].step == VOTING_STEP_WAIT then
			conf.marker_text = "Выборы мэра:\nРегистрация кандидатуры"
		elseif VOTING_STATE[ gov_id ].step == VOTING_STEP_START then
			conf.marker_text = "Выборы мэра:\nГолосование"
		end
		conf.keypress = false
		local marker = TeleportPoint( conf )
		marker:SetImage( "images/marker_icon.png" )
		marker.element:setData( "material", true, false )
		marker:SetDropImage( { ":nrp_shared/img/dropimage.png", 145, 145, 255, 255, 1.45 } )
		--marker.elements = { }
		--marker.elements.blip = Blip( conf.x, conf.y, conf.z, 0, 2, 0, 255, 0, 255, 1, 500 )

		marker.PostJoin = function( self, player )
			local user_id = player:GetID( )

			if VOTING_STATE[ gov_id ].step == VOTING_STEP_WAIT then
				if VOTING_CANDIDATES[ user_id ] then
					player:ShowError( "Вы уже подали свою кандидатуру в ".. FACTIONS_NAMES[ VOTING_CANDIDATES[ user_id ].gov_id ] )
					return false
				end

				if player:GetLevel( ) < CONST_REQUEST_MIN_VOTING_LEVEL then
					player:ShowError( "Требуется ".. CONST_REQUEST_MIN_VOTING_LEVEL .." уровень" )
					return
				end
				if player:GetSocialRating( ) < 50 then
					player:ShowError( "Требуется не меньше 50 ед. социального рейтинга" )
					return
				end
				if not player:HasMilitaryTicket() then
					player:ShowError( "Требуется наличие военного билета" )
					return
				end

				local cost = GetPlayerCostToRegisterCandidacy( player )
				triggerClientEvent( player, "ShowConfirmRegisterCandidacy", resourceRoot, gov_id, cost )
			
			elseif VOTING_STATE[ gov_id ].step == VOTING_STEP_START then
				ShowPlayerUIVoting( player, gov_id )
			end
		end

		table.insert( VOTING_TENTS[ gov_id ], {
			object = object;
			marker = marker;
		} )
	end
end

function UpdateVotingTentsInWorld( gov_id )
	DeleteVotingTentsInWorld( gov_id )
	CreateVotingTentsInWorld( gov_id )
end

function DeleteVotingTentsInWorld( gov_id )
	if not VOTING_TENTS[ gov_id ] then return end

	for i, data in pairs( VOTING_TENTS[ gov_id ] ) do
		if isElement( data.object ) then
			destroyElement( data.object )
		end

		data.marker:destroy( )

		VOTING_TENTS[ i ] = nil
	end

	VOTING_TENTS[ gov_id ] = nil
end



function SelectAndSetNewCityMayor( gov_id )
	local candidate_user_id = nil
	local candidate_votes = 0

	for candidate_id, candidate_data in pairs( VOTING_CANDIDATES ) do
		if candidate_data.gov_id == gov_id then
			if candidate_data.votes >= candidate_votes then
				candidate_votes = candidate_data.votes
				candidate_user_id = candidate_id
			end
		end
	end

	if candidate_user_id then
		return SetNewCityMayor( gov_id, candidate_user_id, "Конец срока" )
	end

	return false
end

function SetNewCityMayor( gov_id, user_id, reason_str )
	CleanUpVotingCandidates( gov_id )
	CleanUpVotingsRegistered( gov_id )

	DeleteVotingTentsInWorld( gov_id )

	VOTING_STATE[ gov_id ] = {
		step = VOTING_STEP_END;
		start_time = getRealTime( ).timestamp;
	}
	DB:exec( "REPLACE INTO nrp_gov_voting_state ( gov_id, step, start_time ) VALUES ( ?, ?, ? )", gov_id, VOTING_STATE[ gov_id ].step, VOTING_STATE[ gov_id ].start_time )

	WriteLog( "government/voting_update", "[ VOTING_END ][ GOV_ID : %s ]", gov_id )

	RemoveCurrentCityMayor( gov_id, reason_str )

	for mayor_gov_id, mayor_user_id in pairs( CURRENT_CITY_MAYOR ) do
		if mayor_user_id == user_id then
			RemoveCurrentCityMayor( mayor_gov_id, "Назначение в новом городе" )
		end
	end

	local player_msg = {
		title = FACTIONS_NAMES[ gov_id ];
		msg_short = "Назначение на должность";
		msg = "Вы победили в выборах мэра. Поздравляем!";
	}

	local player = GetPlayer( user_id )
	if player then
		CURRENT_CITY_MAYOR_CACHE_NAME[ gov_id ] = player:GetNickName( )

		player:SetFaction( gov_id, "Выборы" )
		player:SetFactionLevel( FACTION_OWNER_LEVEL, "Выборы", true )

		player:PhoneNotification( player_msg )

		triggerEvent( "PlayerFailStopQuest", player, { type = "quest_stop" } )
		player:SetJobID( nil )
		player:SetJobClass( nil )
	else
		CURRENT_CITY_MAYOR_CACHE_NAME[ gov_id ] = VOTING_CANDIDATES[ user_id ] and VOTING_CANDIDATES[ user_id ].name or "-"

		DB:exec( "UPDATE nrp_players SET faction_id=?, faction_level=?, faction_exp=0, job_class=NULL, job_id=NULL WHERE id=? LIMIT 1", gov_id, FACTION_OWNER_LEVEL, user_id )

		tostring( user_id ):PhoneNotification( player_msg )
	end

	CURRENT_CITY_MAYOR[ gov_id ] = user_id
	CURRENT_CITY_MAYOR_END_TIME[ gov_id ] = getRealTime( ).timestamp + COST_CITY_MAYOR_TIME_LEN

	DB:exec( "REPLACE INTO nrp_gov_mayor ( gov_id, user_id, name, history, end_time, rating ) VALUES ( ?, ?, ?, ?, ?, ? )", gov_id, user_id, CURRENT_CITY_MAYOR_CACHE_NAME[ gov_id ], toJSON( HISTORY_CITY_MAYOR[ gov_id ], true ), CURRENT_CITY_MAYOR_END_TIME[ gov_id ], CONST_DEFAULT_MAYOR_RATING )

	WriteLog( "government/voting_update", "[ SET_NEW_MAYOR ][ GOV_ID : %s ][ USER_ID : %d ][ NAME : %s ][ END_TIME : %s ][ REASON : %s ]", gov_id, user_id, CURRENT_CITY_MAYOR_CACHE_NAME[ gov_id ], CURRENT_CITY_MAYOR_END_TIME[ gov_id ], reason_str )

	CURRENT_CITY_MAYOR_RATING[ gov_id ] = CONST_DEFAULT_MAYOR_RATING
	exports.nrp_factions_gov_ui_control:ResetGovStateToDefault( gov_id )

	if player then
		triggerClientEvent( player, "onUpdateMayorRating", root, CURRENT_CITY_MAYOR_RATING[ gov_id ] )
	end

	return true
end

function RemoveCurrentCityMayor( gov_id, reason_str )
	local user_id = CURRENT_CITY_MAYOR[ gov_id ]
	if not user_id then return false end

	local player_msg = {
		title = FACTIONS_NAMES[ gov_id ];
		msg_short = "Отстранение от должности";
		msg = "Вы были отстранены от должности мэра по причине: ".. reason_str;
	}

	local player = GetPlayer( user_id )
	if player then
		player:SetFaction( _, reason_str )
		player:PhoneNotification( player_msg )

		triggerClientEvent( player, "onUpdateMayorRating", root )
	else
		DB:exec( "UPDATE nrp_players SET faction_id=0, faction_level=0, faction_exp=0 WHERE id=? LIMIT 1", user_id )

		tostring( user_id ):PhoneNotification( player_msg )
	end

	triggerClientEvent( "OnClientReceivePhoneNotification", root, {
		title = FACTIONS_NAMES[ gov_id ];
		msg_short = "Мэр отстранен от должности";
		msg = "Мэр был отстранен от должности по причине: ".. reason_str;
	} )

	CURRENT_CITY_MAYOR[ gov_id ] = nil
	CURRENT_CITY_MAYOR_END_TIME[ gov_id ] = nil
	table.insert( HISTORY_CITY_MAYOR[ gov_id ], 1, user_id )

	DB:exec( "REPLACE INTO nrp_gov_mayor ( gov_id, user_id, name, history, end_time ) VALUES ( ?, ?, ?, ?, ? )", gov_id, nil, nil, toJSON( HISTORY_CITY_MAYOR[ gov_id ], true ), CURRENT_CITY_MAYOR_END_TIME[ gov_id ] )

	WriteLog( "government/voting_update", "[ REMOVE_MAYOR ][ GOV_ID : %s ][ USER_ID : %s ][ REASON : %s ]", gov_id, user_id, reason_str )

	exports.nrp_factions_gov_ui_control:ResetGovStateToDefault( gov_id )

	return true
end

function UpdateCityMayorRating( gov_id, chg_rating )
	CURRENT_CITY_MAYOR_RATING[ gov_id ] = math.min( 100, math.max( 0, CURRENT_CITY_MAYOR_RATING[ gov_id ] + chg_rating ) )

	DB:exec( "UPDATE nrp_gov_mayor SET rating = ? WHERE gov_id = ? LIMIT 1", CURRENT_CITY_MAYOR_RATING[ gov_id ], gov_id )

	WriteLog( "government/rating_update", "[ UPDATE_MAYOR_RATING ][ GOV_ID : %s ][ RATING : %s ][ CHG_RATING : %s ]", gov_id, CURRENT_CITY_MAYOR_RATING[ gov_id ], chg_rating )

	local user_id = CURRENT_CITY_MAYOR[ gov_id ]
	if user_id then
		local player = GetPlayer( user_id )
		if player then
			triggerClientEvent( player, "onUpdateMayorRating", root, CURRENT_CITY_MAYOR_RATING[ gov_id ] )
		end
	end
end

-------------------
--//  Регистрация кандидатуры в голосовании
-------------------

function GetPlayerCostToRegisterCandidacy( player )
	local faction_id = player:GetFaction( )
	if FACTIONS_BY_CITYHALL[ faction_id ] and FACTIONS_BY_CITYHALL[ faction_id ] == faction_id then
		local faction_level = player:GetFactionLevel( )
		if faction_level >= CONST_CANDIDACY_LEVEL_FREE then
			return
		end
	end

	return CONST_CANDIDACY_COST
end

local required_rating =
{
	[ F_GOVERNMENT_NSK ]   = 50,
	[ F_GOVERNMENT_GORKI ] = 50,
	[ F_GOVERNMENT_MSK ]   = 500,
}

function PlayerRegisterCandidacy_handler( gov_id )
	local player = client or source
	if not player then return end

	if player:GetLevel( ) < CONST_REQUEST_MIN_VOTING_LEVEL then
		player:ShowError( "Требуется ".. CONST_REQUEST_MIN_VOTING_LEVEL .." уровень" )
		return
	end
	
	if client:GetSocialRating( ) < required_rating[ gov_id ] then
		client:ShowError( "Требуется не меньше " .. required_rating[ gov_id ] .. " ед. социального рейтинга" )
		return
	end

	if not player:HasMilitaryTicket() then
		player:ShowError( "Требуется наличие военного билета" )
		return
	end

	if not VOTING_STATE[ gov_id ] or VOTING_STATE[ gov_id ].step ~= VOTING_STEP_WAIT then return end

	local user_id = player:GetID( )
	if CURRENT_CITY_MAYOR[ gov_id ] then
		if CURRENT_CITY_MAYOR[ gov_id ] == user_id and HISTORY_CITY_MAYOR[ gov_id ][1] == user_id then
			if vvp then
				player:ShowError( "Ну Владимир Владимирович, мб хватит? :C" )
			end

			player:ShowError( "3-ий срок подряд?! Не, неее, у нас такое не прокатит" )
			return
		end
	elseif HISTORY_CITY_MAYOR[ gov_id ][1] == user_id and HISTORY_CITY_MAYOR[ gov_id ][2] == user_id then
		player:ShowError( "3-ий срок подряд?! Не, неее, у нас такое не прокатит" )
		return
	end

	if VOTING_CANDIDATES[ user_id ] then
		player:ShowError( "Вы уже подали свою кандидатуру в ".. FACTIONS_NAMES[ VOTING_CANDIDATES[ user_id ].gov_id ] )
		return
	end

	local cost = GetPlayerCostToRegisterCandidacy( player )
	if cost and not player:TakeMoney( cost, "mayoralty_candidate_pay" ) then
		player:EnoughMoneyOffer( "Register Mayor Candidacy", cost, "PlayerRegisterCandidacy", player, gov_id )
		return
	end

	VOTING_CANDIDATES[ user_id ] = {
		gov_id = gov_id;
		name = player:GetNickName( );
		votes = 0;
	}

	DB:exec( "INSERT INTO nrp_gov_candidates ( user_id, gov_id, name ) VALUES ( ?, ?, ? )", user_id, gov_id, VOTING_CANDIDATES[ user_id ].name )

	WriteLog( "government/voting_update", "[ REGISTER_CANDIDACY ][ GOV_ID : %s ][ USER_ID : %s ][ NAME : %s ][ COST : %s ]", gov_id, user_id, VOTING_CANDIDATES[ user_id ].name, ( cost or "FREE" ) )

	--ShowPlayerUIVoting( client, gov_id )
end
addEvent( "PlayerRegisterCandidacy", true )
addEventHandler( "PlayerRegisterCandidacy", root, PlayerRegisterCandidacy_handler )



-------------------
--//  Выбор кандидата из списка
-------------------

function ShowPlayerUIVoting( player, gov_id )
	if player:GetLevel( ) < CONST_REQUEST_MIN_VOTING_LEVEL then
		player:ShowError( "Требуется ".. CONST_REQUEST_MIN_VOTING_LEVEL .." уровень" )
		return
	end
	if not VOTING_STATE[ gov_id ] or VOTING_STATE[ gov_id ].step ~= VOTING_STEP_START then return end

	local candidates_list = { }
	for candidate_id, candidate_data in pairs( VOTING_CANDIDATES ) do
		if candidate_data.gov_id == gov_id then
			candidates_list[ candidate_id ] = candidate_data.name
		end
	end

	local player_vote = VOTINGS_REGISTERED[ gov_id ] and VOTINGS_REGISTERED[ gov_id ][ player:GetID( ) ]
	if player_vote then
		player_vote = VOTING_CANDIDATES[ player_vote ].name
	end

	triggerClientEvent( player, "ShowUIVoting", resourceRoot, gov_id, candidates_list, player_vote )
end

function PlayerSelectVotingCandidate_handler( user_id )
	if not client then return end
	if client:GetLevel( ) < CONST_REQUEST_MIN_VOTING_LEVEL then
		client:ShowError( "Требуется ".. CONST_REQUEST_MIN_VOTING_LEVEL .." уровень" )
		return
	end
	if not VOTING_CANDIDATES[ user_id ] then return end

	local gov_id = VOTING_CANDIDATES[ user_id ].gov_id

	if not VOTING_STATE[ gov_id ] or VOTING_STATE[ gov_id ].step ~= VOTING_STEP_START then return end
	if VOTINGS_REGISTERED[ gov_id ] and VOTINGS_REGISTERED[ gov_id ][ client:GetID( ) ] then return end

	if not VOTINGS_REGISTERED[ gov_id ] then
		VOTINGS_REGISTERED[ gov_id ] = { }
	end
	VOTINGS_REGISTERED[ gov_id ][ client:GetID( ) ] = user_id
	VOTING_CANDIDATES[ user_id ].votes = VOTING_CANDIDATES[ user_id ].votes + 1

	DB:exec( "INSERT INTO nrp_gov_votes ( user_id, gov_id, candidate_id ) VALUES ( ?, ?, ? )", client:GetID( ), gov_id, user_id )

	WriteLog( "government/voting_update", "[ ADD_VOTE ][ GOV_ID : %s ][ USER_ID : %s ][ CANDIDATE_ID : %s ]", gov_id, client:GetID( ), user_id )

	ShowPlayerUIVoting( client, gov_id )
end
addEvent( "PlayerSelectVotingCandidate", true )
addEventHandler( "PlayerSelectVotingCandidate", resourceRoot, PlayerSelectVotingCandidate_handler )

function GetAllVotesData( )
	local vote_data = { }

	for gov_id in pairs( HISTORY_CITY_MAYOR ) do
		vote_data[ gov_id ] = { }
		local user_id = CURRENT_CITY_MAYOR[ gov_id ]
		if user_id then
			local mayor_name = CURRENT_CITY_MAYOR_CACHE_NAME[ gov_id ] or "-"

			local player = GetPlayer( user_id )
			if player then
				mayor_name = player:GetNickName( )
				CURRENT_CITY_MAYOR_CACHE_NAME[ gov_id ] = mayor_name
			end

			vote_data[ gov_id ].mayor_name = mayor_name
			vote_data[ gov_id ].rating = CURRENT_CITY_MAYOR_RATING[ gov_id ]
		end
	end

	for gov_id, state_data in pairs( VOTING_STATE ) do
		if not vote_data[ gov_id ] then vote_data[ gov_id ] = { } end

		vote_data[ gov_id ].candidates = { }
		vote_data[ gov_id ].all_votes = 0
	end

	for candidate_id, candidate_data in pairs( VOTING_CANDIDATES ) do
		local gov_id = candidate_data.gov_id
		if vote_data[ gov_id ] then
			table.insert( vote_data[ gov_id ].candidates, {
				name = candidate_data.name;
				votes = candidate_data.votes;
			} )

			vote_data[ gov_id ].all_votes = vote_data[ gov_id ].all_votes + candidate_data.votes
		end
	end

	return vote_data
end

addEvent( "OnPlayerJailed", true )
addEventHandler( "OnPlayerJailed", root, function( )
	if not source:IsInFaction( ) then return end

	local player_faction = source:GetFaction( )
	local user_id = source:GetID( )
	if CURRENT_CITY_MAYOR[ player_faction ] and CURRENT_CITY_MAYOR[ player_faction ] == user_id then
		source:PhoneNotification( {
			title = FACTIONS_NAMES[ player_faction ];
			msg_short = "Рейтинг власти упал на -25%";
			msg = "Вы попали в тюрьму. Рейтинг власти упал на -25%";
		} )

		UpdateCityMayorRating( player_faction, -25 )
	end
end )

-- FOR TEST SERVER
if SERVER_NUMBER > 100 then
	addCommandHandler( "fastgovvotingstep", function ( )
		CONST_VOTING_STEPS_TIME[ 1 ] = 1
		CONST_VOTING_STEPS_TIME[ 2 ] = 1
	end )
end