Extend( "SVehicle" )
Extend( "SPlayer" )
Extend( "SQuestCoop" )
Extend( "ShTimelib" )
Extend( "SDB" )

addEventHandler( "onResourceStart", resourceRoot, function()
	SQuestCoop( QUEST_DATA )
end )

function onServerTowStartWork_handler( lobby )
	local lobby_id = lobby.lobby_id
	local lobby_data = GetLobbyDataById( lobby_id )
	if lobby_data then
		WriteLog("#1 ERROR CREATE LOBBY TASK TOWTRUCKER")
		return false
	end
	
	lobby_data = CreateLobbyData( lobby_id, lobby )	

	lobby_data.cars_num = 0

	for idx, v in pairs( lobby_data.participants ) do
		v.player:CompleteDailyQuest( "np_start_towtrucker" )
		v.player:CompleteDailyQuest( "start_shift" )
	end
end
addEvent( "onServerTowStartWork" )
addEventHandler( "onServerTowStartWork", root, onServerTowStartWork_handler )

function onServerTowEndWork_handler( lobby_id, reason_data )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	for k, v in pairs( lobby_data.participants ) do
		if isElement( v.player ) then
			OnPlayerLeaveLobby( v.player, lobby_data )
		end
	end
end
addEvent( "onServerTowEndWork" )
addEventHandler( "onServerTowEndWork", root, onServerTowEndWork_handler )

function onServerPlayerLeaveLobbyCoopQuest_handler( lobby_id, player )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end
	OnPlayerLeaveLobby( player, lobby_data )
end
addEvent( "onServerPlayerLeaveLobbyCoopQuest" )
addEventHandler( "onServerPlayerLeaveLobbyCoopQuest", root, onServerPlayerLeaveLobbyCoopQuest_handler )

function OnPlayerLeaveLobby( player, lobby_data )
	local players_quantity = #lobby_data.participants
	local job_duration = getRealTimestamp() - lobby_data.job_start

	local receive_sum = 0
	local exp_sum = 0
	if lobby_data.sum_data and lobby_data.sum_data[ player ] then
		receive_sum = lobby_data.sum_data[ player ].receive_sum
		exp_sum = lobby_data.sum_data[ player ].exp_sum
	end

	OnEvacJobFinish( player, lobby_data.lobby_id, players_quantity, job_duration, lobby_data.cars_num, receive_sum, exp_sum )
end

function onCoopJobCompletedLap_handler( player, lobby_id, money, exp )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end
	
	-- Аналитика: Окончание рейса
	OnEvacJobVoyage( player, lobby_data, money or 0, exp or 0 )
end
addEvent( "onCoopJobCompletedLap" )
addEventHandler( "onCoopJobCompletedLap", resourceRoot, onCoopJobCompletedLap_handler )