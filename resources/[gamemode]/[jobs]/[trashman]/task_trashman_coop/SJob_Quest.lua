Extend( "SVehicle" )
Extend( "SPlayer" )
Extend( "SQuestCoop" )

addEventHandler( "onResourceStart", resourceRoot, function()
	SQuestCoop( QUEST_DATA )
end )

-- Начало смены
function onServerTrashmanStartWork_handler( lobby )
	local lobby_id = lobby.lobby_id
	local lobby_data = GetLobbyDataById( lobby_id )
	if lobby_data then
		WriteLog("#1 ERROR CREATE LOBBY TASK TOWTRUCKER")
		return false
	end
	lobby_data = CreateLobbyData( lobby_id, lobby )
	PreStartQuest( lobby_data )

	for idx, v in pairs( lobby_data.participants ) do
		v.player:CompleteDailyQuest( "np_start_trashman" )
		v.player:CompleteDailyQuest( "start_shift" )
	end
end
addEvent( "onServerTrashmanStartWork" )
addEventHandler( "onServerTrashmanStartWork", root, onServerTrashmanStartWork_handler )

-- Проверка на кол-во пассажиров в транспорте, после старта
function PreStartQuest( lobby_data )
	lobby_data.check_start_tmr = setTimer( function()
		lobby_data.count_delivered_bags = 0
	end, 2000, 1 )
end

-- Окончание смены
function onServerTrashmanEndWork_handler( lobby_id, reason_data )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	if isTimer( lobby_data.check_start_tmr ) then
		killTimer( lobby_data.check_start_tmr )
	end

	local timestamp = getRealTimestamp()
	for k, v in pairs( lobby_data.participants ) do
		RestoreData( v.player, v.role, lobby_data.lobby_id )
		-- Аналитика: Окончание смены
		onTrashmanJobFinish( v.player, lobby_data, reason_data )
	end
end
addEvent( "onServerTrashmanEndWork" )
addEventHandler( "onServerTrashmanEndWork", root, onServerTrashmanEndWork_handler )

-- Игрок покинул работу
function onServerPlayerLeaveLobbyCoopQuest_handler( lobby_id, player, reason_data )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	local player_data = GetPlayerData( lobby_id, player )
	if GetPlayerBag( player ) then
		RemovePlayerBag( player )
	end

	RestoreData( player, player_data.role, lobby_data.lobby_id )
	-- Аналитика: Окончание смены
	onTrashmanJobFinish( player, lobby_data, reason_data )
end
addEvent( "onServerPlayerLeaveLobbyCoopQuest" )
addEventHandler( "onServerPlayerLeaveLobbyCoopQuest", root, onServerPlayerLeaveLobbyCoopQuest_handler )

-- Обработка любого окончания смены
function onAnyFinishTrashman( lobby_id, finish_state )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	DestroyBagsData( lobby_data )
end

-- Награда
function onCoopJobCompletedLap_handler( player, lobby_id, money, exp )
	local lobby_data = GetLobbyDataById( lobby_id )
	if not lobby_data then return end

	onTrashmanJobFinishVoyage( player, lobby_data, money or 0, exp or 0 )

	-- Retention task "pharmacy5"
	triggerEvent( "onTrashManEndLoop", player )
end
addEvent( "onCoopJobCompletedLap" )
addEventHandler( "onCoopJobCompletedLap", resourceRoot, onCoopJobCompletedLap_handler )